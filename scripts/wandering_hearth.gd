extends Node2D
const Ogre=preload("res://scripts/ogre_actor.gd")
const HearthState=preload("res://scripts/wandering_hearth_state.gd")
const WorldState=preload("res://scripts/world_state.gd")
const Terrain=preload("res://scripts/opener_terrain.gd")
const Prop=preload("res://scripts/camp_prop.gd")
const Menu=preload("res://scripts/main_menu.gd")
var state=HearthState.new()
var ground_state=WorldState.new()
var player: CharacterBody2D
var camera: Camera2D
var world: Node2D
var hud: Label
var objective: Label
var notice: Label
var prompt: Label
var modal: Control
var stations: Array=[]
var supplies: Array=[]
var nearest: Dictionary={}
var save_clock=0.0
var sound: AudioStreamPlayer
var ambient: AudioStreamPlayer
var helper=Menu.new()
func _ready() -> void:
    get_tree().auto_accept_quit=false
    for key in {"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}:
        if not InputMap.has_action(key):
            InputMap.add_action(key)
            var event=InputEventKey.new();event.physical_keycode={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}[key]
            InputMap.action_add_event(key,event)
    var loaded=state.load_game()
    build_world()
    build_ui()
    sound=AudioStreamPlayer.new();sound.volume_db=-17;add_child(sound)
    ambient=AudioStreamPlayer.new();ambient.stream=load("res://assets/opener/ambient.wav");ambient.volume_db=-24;add_child(ambient)
    if not "--test" in OS.get_cmdline_user_args():ambient.play()
    say("Follow the trail for fallen timber. Bring supplies back to your hearth." if loaded else "Your Ogre save could not be read. It has been preserved; this visit will not overwrite it.")
    if "--startup-smoke" in OS.get_cmdline_user_args():get_tree().create_timer(2.0).timeout.connect(quit_game)
func build_world() -> void:
    ground_state.terrain.clear()
    for x in range(3,70):
        var center=27+int(sin(float(x)*0.13)*2)
        for y in range(center-1,center+2):ground_state.terrain["%d,%d"%[x,y]]="earth"
    for x in range(18,42):
        for y in range(17,33):
            if Vector2((x-29)/12.0,(y-25)/9.0).length()<1:ground_state.terrain["%d,%d"%[x,y]]="earth"
    for x in range(47,70):
        for y in range(3,14+int(sin(x*0.2)*2)):ground_state.terrain["%d,%d"%[x,y]]="water"
    ground_state.revision+=1
    var ground=Terrain.new();ground.state=ground_state;add_child(ground)
    world=Node2D.new();world.y_sort_enabled=true;add_child(world)
    player=Ogre.new();player.position=state.player_position;world.add_child(player)
    camera=Camera2D.new();camera.zoom=Vector2.ONE*0.75;camera.offset=Vector2(0,-185);camera.position_smoothing_enabled=true;camera.position_smoothing_speed=8
    camera.limit_left=0;camera.limit_top=0;camera.limit_right=2260;camera.limit_bottom=1408;player.add_child(camera)
    # Use the existing illustrated wilderness assets, lighting and ground material.
    var trees=[Vector2(170,360),Vector2(300,250),Vector2(440,340),Vector2(575,260),Vector2(750,240),Vector2(980,270),Vector2(1230,260),Vector2(1430,355),Vector2(1550,530),Vector2(1760,540),Vector2(1990,570),Vector2(2110,690),Vector2(190,650),Vector2(320,620),Vector2(190,1030),Vector2(400,1190),Vector2(590,1290),Vector2(790,1320),Vector2(1150,1300),Vector2(1400,1240),Vector2(1660,1130),Vector2(1870,1220),Vector2(2090,1140)]
    for p in trees:world_prop("tree",p)
    for p in [Vector2(390,440),Vector2(1480,570),Vector2(1800,690),Vector2(2100,940),Vector2(340,1100),Vector2(1380,1170)]:world_prop("rock",p)
    camp_item("wagon",Vector2(760,690),Rect2(10,4,800,580),0.74,Vector2(400,90),Vector2(0,-85))
    camp_item("tent",Vector2(1235,710),Rect2(832,16,700,560),0.58,Vector2(285,60),Vector2(0,-95))
    camp_item("hearth",Vector2(1030,1000),Rect2(140,555,560,440),0.34,Vector2(115,44),Vector2(0,-16))
    camp_item("provisions",Vector2(665,930),Rect2(804,665,710,325),0.33,Vector2(172,50),Vector2(0,-16))
    stations=[{"kind":"hearth","position":Vector2(1030,1035),"text":"E  Cook a hearty meal  •  2 meat + 1 timber"},{"kind":"wagon","position":Vector2(790,730),"text":"E  Your traveling household"},{"kind":"tent","position":Vector2(1240,720),"text":"E  Look inside the shelter"},{"kind":"provisions","position":Vector2(665,965),"text":"E  Take your hunting provisions"}]
    var positions=[Vector2(440,870),Vector2(1470,895),Vector2(1650,875),Vector2(1820,930),Vector2(520,1040)]
    for i in positions.size():
        var id="fallen_timber_%d"%i
        var prop=world_prop("log",positions[i])
        prop.visible=not id in state.collected
        if id in state.collected:prop.data.state="collected"
        supplies.append({"id":id,"kind":"wood","position":positions[i],"text":"E  Collect fallen timber","node":prop})
    for rect in [Rect2(-40,-40,2340,80),Rect2(-40,1360,2340,80),Rect2(-40,0,100,1408),Rect2(2200,0,100,1408)]:
        var body=StaticBody2D.new();body.position=rect.get_center();var shape=CollisionShape2D.new();var box=RectangleShape2D.new();box.size=rect.size;shape.shape=box;body.add_child(shape);add_child(body)
func world_prop(kind: String,at: Vector2) -> Node2D:
    var prop=Prop.new();prop.data={"kind":kind,"state":"intact","x":at.x,"y":at.y,"burning":false,"heat":0.0,"hp":100};prop.player=player;world.add_child(prop);return prop
func camp_item(kind: String,at: Vector2,region: Rect2,size: float,collision: Vector2,offset: Vector2) -> void:
    var body=StaticBody2D.new();body.name=kind;body.position=at
    # Nonrectangular atlas boundaries exclude neighboring silhouettes at the
    # wagon/hearth gutter. UVs select intact art; no texture pixels are edited.
    var points=PackedVector2Array([region.position,region.position+Vector2(region.size.x,0),region.end,region.position+Vector2(0,region.size.y)])
    if kind=="wagon":points=PackedVector2Array([Vector2(10,4),Vector2(810,4),Vector2(810,584),Vector2(450,584),Vector2(450,548),Vector2(350,548),Vector2(350,584),Vector2(10,584)])
    if kind=="hearth":points=PackedVector2Array([Vector2(350,555),Vector2(450,555),Vector2(450,590),Vector2(700,590),Vector2(700,995),Vector2(140,995),Vector2(140,590),Vector2(350,590)])
    var sprite=Polygon2D.new();sprite.texture=load("res://assets/ogre/traveling_camp.png");sprite.uv=points
    var vertices=PackedVector2Array()
    for point in points:vertices.append((point-region.position-Vector2(region.size.x*0.5,region.size.y))*size)
    sprite.polygon=vertices;body.add_child(sprite)
    var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=collision;col.shape=shape;col.position=offset;body.add_child(col);world.add_child(body)
func panel(at: Vector2,size: Vector2) -> PanelContainer:
    var p=PanelContainer.new();p.position=at;p.size=size;p.add_theme_stylebox_override("panel",helper.style("211e19ed","93734a"));return p
func build_ui() -> void:
    var layer=CanvasLayer.new();add_child(layer)
    var top=panel(Vector2(22,18),Vector2(1236,90));layer.add_child(top)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",35);top.add_child(row)
    var title=VBoxContainer.new();title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(title)
    title.add_child(helper.words("HEARTH AND HUNGER",27));objective=helper.words("THE FIRST HEARTH  •  Timber, provisions, a warm meal",16,"d6b176");title.add_child(objective)
    hud=helper.words("",18);hud.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(hud)
    var bottom=panel(Vector2(22,684),Vector2(1236,98));layer.add_child(bottom)
    var lines=VBoxContainer.new();lines.add_theme_constant_override("separation",5);bottom.add_child(lines)
    prompt=helper.words("",19);lines.add_child(prompt)
    notice=helper.words("",15,"d1bc97");lines.add_child(notice)
    lines.add_child(helper.words("WASD move     E interact     F5 save     Esc menu",14,"a7a891"))
    modal=Control.new();modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(modal);modal.hide()
func _process(delta: float) -> void:
    hud.text="Timber  %d     Meat  %d     Meals  %d"%[state.inventory.wood,state.inventory.meat,state.inventory.meals]
    if state.cooked>0:objective.text="A HEARTH OF YOUR OWN  •  %d meals prepared"%(state.cooked*3)
    nearest={};var best=110.0
    for entry in stations+supplies:
        if entry.has("id") and entry.id in state.collected:continue
        var distance=player.position.distance_to(entry.position)
        if distance<best:best=distance;nearest=entry
    prompt.text=nearest.get("text","Your home travels with you. Explore the clearing and follow the trail.")
    save_clock+=delta
    if save_clock>30:
        save_clock=0
        if not save_progress():say("Saving is unavailable. Your previous save has been preserved.")
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_ESCAPE:
            if modal.visible:close_modal()
            else:pause_menu()
        elif not modal.visible:
            if event.keycode==KEY_E and not nearest.is_empty():interact(nearest)
            elif event.keycode==KEY_F5:say("Progress saved." if save_progress() else "Save failed; previous progress preserved.")
func interact(entry: Dictionary) -> void:
    match entry.kind:
        "wood":
            if state.collect(entry.id,"wood",2):entry.node.data.state="collected";entry.node.refresh();say("Two lengths of fallen timber. Good fuel for the hearth.");play_sound("gather")
        "provisions":
            if state.collect("first_hunting_provisions","meat",6):say("Six cuts of meat from your provisions. Add timber at the cooking hearth.");play_sound("success")
            else:say("The provisions are in your pack. Keep them for the hearth.")
        "hearth":
            if state.cook():say("The pot is ready. Three hearty meals added to your household stores.");play_sound("success")
            else:say("The pot needs two cuts of meat and one timber. Collect provisions and fallen wood.")
        "wagon":show_panel("YOUR TRAVELING HEARTH","Heavy wheels. Canvas, hides and timber. A household built for the road.\n\nBeneath the red canopy: sleeping furs, the smell of woodsmoke, and a place among your own people.")
        "tent":show_panel("A MOMENT BY THE HEARTH","The hide ropes creak in the wind. Warm furs wait beneath the canvas.\n\nThe trail can wait a little longer. There is timber to gather and a pot to fill.")
    if not save_progress():say("Your action worked, but saving failed. Your previous save is preserved.")
func play_sound(kind: String) -> void:
    var path="res://assets/opener/"+kind+".wav"
    if ResourceLoader.exists(path):sound.stream=load(path);sound.play()
func say(text: String) -> void:notice.text=text
func show_panel(title: String,body: String) -> VBoxContainer:
    for child in modal.get_children():modal.remove_child(child);child.queue_free()
    var shade=ColorRect.new();shade.color=Color(0.03,0.03,0.02,0.65);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var box=panel(Vector2(320,235),Vector2(640,300));modal.add_child(box)
    var content=VBoxContainer.new();content.add_theme_constant_override("separation",15);box.add_child(content)
    content.add_child(helper.words(title,26));var copy=helper.words(body,18);copy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;copy.custom_minimum_size.x=590;content.add_child(copy)
    var resume=helper.action("Return",close_modal,content);resume.grab_focus();modal.show();player.enabled=false;return content
func close_modal() -> void:modal.hide();player.enabled=true
func pause_menu() -> void:
    var content=show_panel("BY THE WANDERING HEARTH","Your Ogre's progress saves separately from your earlier characters.")
    helper.action("Leave this unsaved visit" if state.unreadable else "Save and return to title",return_to_menu,content)
    helper.action("Quit without changing unreadable save" if state.unreadable else "Save and quit",quit_game,content)
func save_progress() -> bool:
    state.player_position=player.position;return state.save_game()
func return_to_menu() -> void:
    if not state.unreadable and not save_progress():say("Could not save; staying here to preserve your progress.");close_modal();return
    ambient.stop();get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
func quit_game() -> void:
    if not state.unreadable and not save_progress():say("Could not save; staying here to preserve your progress.");close_modal();return
    ambient.stop();get_tree().quit()
func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(player):quit_game()
func _exit_tree() -> void:
    if is_instance_valid(ambient):ambient.stop()
    helper.free()
