extends Node2D
const Orc = preload("res://scripts/orc.gd")
const WorldState = preload("res://scripts/world_state.gd")
const Prop = preload("res://scripts/world_prop.gd")
const Terrain = preload("res://scripts/terrain.gd")
const SAVE_PATH := "user://world_v2.json"
var state := WorldState.new()
var player: CharacterBody2D
var actors: Node2D
var ground: Node2D
var props: Dictionary = {}
var camera: Camera2D
var hud: Label
var hint: Label
var notice: Label
var help: PanelContainer
var tools_mode := false
var elapsed := 0.0
var fire_clock := 0.0
var save_clock := 0.0
var message_time := 0.0
var warning_time := -1.0
var warning_target := ""
var tint: CanvasModulate
var daylight := 0.0
var selected := ""
var footer: Label

func _ready() -> void:
    setup_input()
    ground=Terrain.new()
    ground.state=state
    add_child(ground)
    actors=Node2D.new()
    actors.y_sort_enabled=true
    add_child(actors)
    player=Orc.new()
    player.position=Vector2(760,600)
    actors.add_child(player)
    camera=Camera2D.new()
    camera.position_smoothing_enabled=true
    camera.position_smoothing_speed=9
    camera.limit_left=0
    camera.limit_top=0
    camera.limit_right=1536
    camera.limit_bottom=1024
    player.add_child(camera)
    for rect in [Rect2(-32,-32,1600,32),Rect2(-32,1024,1600,32),Rect2(-32,0,32,1024),Rect2(1536,0,32,1024)]:
        var body:=StaticBody2D.new()
        body.position=rect.position+rect.size/2
        var col:=CollisionShape2D.new()
        var shape:=RectangleShape2D.new()
        shape.size=rect.size
        col.shape=shape
        body.add_child(col)
        add_child(body)
    seed_world()
    if not "--fresh" in OS.get_cmdline_user_args():
        load_game()
    sync_props()
    tint=CanvasModulate.new()
    add_child(tint)
    create_ui()
    show_notice("The land can change. Press J for controls; F3 opens the world-system test tools.")

func setup_input() -> void:
    var keys: Dictionary={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S,"interact":KEY_E,"help":KEY_J,"inspect":KEY_F1,"tools":KEY_F3,"save":KEY_F5,"armor":KEY_C,"extinguish":KEY_G,"light":KEY_L}
    for action in keys:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var event:=InputEventKey.new()
            event.physical_keycode=keys[action]
            InputMap.action_add_event(action,event)

func seed_world() -> void:
    state.objects.clear()
    state.terrain.clear()
    state.next_id=0
    state.timber=0
    var trees := [Vector2(210,320),Vector2(280,410),Vector2(180,500),Vector2(280,590),Vector2(190,690),Vector2(360,310),Vector2(1200,340),Vector2(1280,400),Vector2(1200,480),Vector2(1310,540),Vector2(1250,650),Vector2(1370,730),Vector2(380,870),Vector2(470,930)]
    for i in trees.size():
        state.add_object("tree",trees[i],"pine_%02d" % i)
    for i in 3:
        state.add_object("wall",Vector2(600+i*88,340),"hall_back_%s" % i)
    state.add_object("wall",Vector2(600,430),"hall_front_left")
    state.add_object("wall",Vector2(776,430),"hall_front_right")
    state.add_object("roof",Vector2(688,407),"hall_roof")
    state.add_object("hearth",Vector2(660,650),"contained_hearth")
    state.add_object("log",Vector2(860,540),"starter_log")
    state.add_object("rock",Vector2(1020,360),"ridge_0")
    state.add_object("rock",Vector2(1090,300),"ridge_1")
    for y in range(14,31):
        for x in range(21,23):
            state.set_terrain(Vector2i(x,y),"earth")
    for y in range(20,32):
        for x in range(43,46):
            state.set_terrain(Vector2i(x,y),"water")
    for y in range(18,23):
        for x in range(18,23):
            state.set_terrain(Vector2i(x,y),"earth")

func sync_props() -> void:
    for id in props.keys():
        if not state.objects.has(id):
            actors.remove_child(props[id])
            props[id].queue_free()
            props.erase(id)
    for id in state.objects:
        if not props.has(id):
            var prop:=Prop.new()
            prop.data=state.objects[id]
            prop.player=player
            actors.add_child(prop)
            props[id]=prop
        else:
            props[id].data=state.objects[id]
        props[id].refresh()

func create_ui() -> void:
    var layer:=CanvasLayer.new()
    add_child(layer)
    var root:=Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter=Control.MOUSE_FILTER_IGNORE
    layer.add_child(root)
    var theme:=Theme.new()
    theme.default_font_size=17
    var style:=StyleBoxFlat.new()
    style.bg_color=Color(0.055,0.055,0.055,0.96)
    style.border_color=Color("80594d")
    style.set_border_width_all(2)
    style.content_margin_left=16
    style.content_margin_right=16
    style.content_margin_top=12
    style.content_margin_bottom=12
    theme.set_stylebox("panel","PanelContainer",style)
    root.theme=theme
    var panel:=PanelContainer.new()
    panel.position=Vector2(20,16)
    panel.size=Vector2(620,100)
    root.add_child(panel)
    hud=Label.new()
    panel.add_child(hud)
    notice=Label.new()
    notice.position=Vector2(24,130)
    notice.size=Vector2(700,110)
    notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    notice.add_theme_color_override("font_shadow_color",Color.BLACK)
    notice.add_theme_constant_override("shadow_offset_x",2)
    notice.add_theme_constant_override("shadow_offset_y",2)
    root.add_child(notice)
    hint=Label.new()
    hint.position=Vector2(24,660)
    hint.size=Vector2(1000,65)
    root.add_child(hint)
    footer=Label.new()
    footer.position=Vector2(24,748)
    footer.text="WASD  Move    E  Inspect / collect    C  Armor    G  Extinguish    J  Help    F3  Test tools    F5  Save"
    root.add_child(footer)
    help=PanelContainer.new()
    help.position=Vector2(260,230)
    help.size=Vector2(760,360)
    root.add_child(help)
    var text:=Label.new()
    text.text="CHIEFS OF WAR — WORLD FOUNDATION\n\nEvery tree, rock, wall and roof is an independent object.\nC: compare leather / iron outfit candidates. E: inspect or collect logs.\nG: extinguish nearby fire (free test action; bucket gameplay is pending).\n\nF3 toggles TEST TOOLS, not finished character actions:\nClick object: damage 25 HP. I: ignite hovered object.\nRight-click ground: grass → earth firebreak → water → grass.\nB: place wall. T: place tree. R: place rock. O: place roof.\nP: toggle fire spread. F4: warn, then ignite a test disaster after 8 seconds.\nF1: frame inspector; arrows step frame/direction. L: change lighting.\n\nF5 saves. F6 restores the pre-disaster checkpoint. Escape closes this panel or saves and exits.\n[J] Close — simulation pauses while this panel is open."
    help.add_child(text)
    help.hide()

func _process(delta: float) -> void:
    if help.visible:
        return
    elapsed+=delta
    message_time-=delta
    if message_time<=0:
        notice.text=""
    save_clock+=delta
    if save_clock>=30:
        save_game()
        save_clock=0
    fire_clock+=delta
    while fire_clock>=0.25:
        state.fire_tick(0.25)
        fire_clock-=0.25
    sync_props()
    if warning_time>=0:
        warning_time-=delta
        notice.text="FIRE WARNING: test strike in %.1f seconds. G cancels; clear fuel or prepare to extinguish." % maxf(warning_time,0)
        if warning_time<=0:
            state.ignite(warning_target,"disaster")
            warning_time=-1
            show_notice("The warned fire has started. G extinguishes nearby flames.")
    selected=object_at(get_global_mouse_position(),52)
    var burning:=0
    for o in state.objects.values():
        if o.burning:
            burning+=1
    hud.text="CHIEFS OF WAR  /  The Scarred Clearing\n0.1.0 systems prototype • Art unapproved • Armor: %s\nTimber: %s   Fires: %s   Spread: %s   %s" % [player.equipment,state.timber,burning,"ON" if state.spread_enabled else "OFF","TEST TOOLS" if tools_mode else "EXPLORATION"]
    hint.text=""
    if not selected.is_empty():
        var o: Dictionary=state.objects[selected]
        hint.text="%s  •  %s  •  HP %.0f  •  %s" % [o.kind.capitalize(),o.state,o.hp,"BURNING" if o.burning else "wet" if o.wet>0 else ""]
    if player.inspect_mode:
        hint.text="FRAME INSPECTOR: %s / frame %s. Arrows change direction and frame. F1 exits." % [player.facing,player.manual_frame+1]
    daylight=fmod(daylight+delta/900,1)
    tint.color=Color.WHITE.lerp(Color(0.45,0.50,0.65),(1-cos(daylight*TAU))*0.23)
    if "--capture" in OS.get_cmdline_user_args() and elapsed>1.0:
        var path:=OS.get_environment("CHIEFS_CAPTURE")
        if not path.is_empty():
            get_viewport().get_texture().get_image().save_png(path)
        get_tree().quit()

func object_at(pos: Vector2,radius: float) -> String:
    var result:=""
    var nearest:=radius
    for id in state.objects:
        var o: Dictionary=state.objects[id]
        if o.state!="intact":
            continue
        var distance: float=state.point(o).distance_to(pos)
        if distance<nearest:
            nearest=distance
            result=id
    return result

func can_place(pos: Vector2) -> bool:
    if not Rect2(50,100,1436,874).has_point(pos) or pos.distance_to(player.position)<55:
        return false
    if state.terrain_at(Vector2i((pos/32).floor()))=="water":
        return false
    return object_at(pos,65).is_empty()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("help"):
        help.visible=not help.visible
        player.set_physics_process(not help.visible)
        return
    if event.is_action_pressed("ui_cancel"):
        if help.visible:
            help.hide()
            player.set_physics_process(true)
        else:
            save_game()
            get_tree().quit()
        return
    if help.visible:
        return
    if event.is_action_pressed("tools"):
        tools_mode=not tools_mode
        show_notice("World test tools enabled. These commands test state changes; they are not finished gameplay actions." if tools_mode else "Returned to exploration.")
    if event.is_action_pressed("inspect"):
        player.inspect_mode=not player.inspect_mode
    if event.is_action_pressed("armor"):
        player.equip("iron" if player.equipment=="leather" else "leather")
    if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F6:
        warning_time=-1
        show_notice("Restored the pre-disaster checkpoint." if load_game("user://before_test_disaster.json") else "No valid pre-disaster checkpoint exists.")
    if event.is_action_pressed("light"):
        daylight=fmod(daylight+0.25,1)
    if event.is_action_pressed("save"):
        show_notice("World saved." if save_game() else "Could not save world.")
    if event.is_action_pressed("extinguish"):
        warning_time=-1
        for id in state.objects:
            if state.point(state.objects[id]).distance_to(player.position)<150:
                state.extinguish(id)
        show_notice("Nearby fuel wetted for 45 seconds. Pending test disaster cancelled.")
    if event.is_action_pressed("interact"):
        var id:=object_at(player.position,90)
        if not id.is_empty():
            if state.collect(id):
                show_notice("Timber collected.")
            else:
                show_notice("%s: %s. Use F3 to test damage and world changes; character work actions are still in development." % [state.objects[id].kind,state.objects[id].state])
    if player.inspect_mode and event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_RIGHT: player.manual_frame=(player.manual_frame+1)%4
            KEY_LEFT: player.manual_frame=(player.manual_frame+3)%4
            KEY_DOWN: player.facing=(player.facing+1)%4
            KEY_UP: player.facing=(player.facing+3)%4
    if not tools_mode or player.inspect_mode:
        return
    var mouse:=get_global_mouse_position()
    if event is InputEventMouseButton and event.pressed:
        if event.button_index==MOUSE_BUTTON_LEFT:
            var id:=object_at(mouse,52)
            if not id.is_empty():
                state.damage(id,25)
        elif event.button_index==MOUSE_BUTTON_RIGHT:
            var cell:=Vector2i((mouse/32).floor())
            if (Vector2(cell)*32+Vector2(16,16)).distance_to(player.position)<40:
                return
            var options:=["grass","earth","water"]
            var next: String=options[(options.find(state.terrain_at(cell))+1)%3]
            if next=="water" and not object_at(Vector2(cell)*32+Vector2(16,16),45).is_empty():
                show_notice("Clear the objects before excavating water here.")
            else:
                state.set_terrain(cell,next)
    if event is InputEventKey and event.pressed and not event.echo:
        var kind:=""
        match event.keycode:
            KEY_B: kind="wall"
            KEY_T: kind="tree"
            KEY_R: kind="rock"
            KEY_O: kind="roof"
            KEY_I:
                if not selected.is_empty():
                    state.ignite(selected,"deliberate")
            KEY_P:
                state.spread_enabled=not state.spread_enabled
            KEY_F4:
                if not selected.is_empty() and state.objects[selected].fuel>0:
                    save_game("user://before_test_disaster.json")
                    warning_target=selected
                    warning_time=8
        if not kind.is_empty():
            var pos:=(mouse/32).floor()*32+Vector2(16,16)
            if can_place(pos):
                state.add_object(kind,pos)
            else:
                show_notice("Placement blocked: leave room around objects, water and the player.")

func show_notice(message: String) -> void:
    notice.text=message
    message_time=8

func save_game(path: String=SAVE_PATH) -> bool:
    var data:=state.snapshot()
    data.player=[player.position.x,player.position.y]
    data.equipment=player.equipment
    data.daylight=daylight
    var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
    if file==null:
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    return DirAccess.rename_absolute(path+".tmp",path)==OK

func load_game(path: String=SAVE_PATH) -> bool:
    if not FileAccess.file_exists(path):
        return false
    var data=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary or not state.restore(data):
        return false
    var pos=data.get("player")
    if pos is Array and pos.size()==2 and (pos[0] is float or pos[0] is int) and (pos[1] is float or pos[1] is int):
        var candidate:=Vector2(pos[0],pos[1])
        if Rect2(20,20,1496,984).has_point(candidate) and state.terrain_at(Vector2i((candidate/32).floor()))!="water" and object_at(candidate,35).is_empty():
            player.position=candidate
    player.equip(str(data.get("equipment","leather")))
    daylight=fposmod(float(data.get("daylight",0)),1.0)
    sync_props()
    return true

func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_CLOSE_REQUEST:
        save_game()
