extends "res://scripts/wandering_hearth.gd"
const ChapterState=preload("res://scripts/chapter/state.gd")
const Actor=preload("res://scripts/chapter/actor.gd")
const Story=preload("res://scripts/chapter/story.gd")
const Wolf=preload("res://scripts/direwolf.gd")
const Raider=preload("res://scripts/raider.gd")
const NAMES={"crossing":"EMBERHIDE CROSSING","pines":"NORTHERN PINES","hollow":"WOLFSCAR HOLLOW","cairn":"GOBLIN CAIRN","pass":"SUNDERED PASS","host":"STONEBELLY HOST","trade":"BLACKSTONE TRADE POST"}
const ROADS={"crossing":[["pines","north"],["host","east"]],"pines":[["crossing","south"],["hollow","north"],["cairn","east"]],"hollow":[["pines","south"]],"cairn":[["pines","west"],["trade","east"],["pass","north"]],"host":[["crossing","west"],["pass","north"],["trade","east"]],"pass":[["host","south"],["cairn","east"]],"trade":[["host","west"],["cairn","north"]]}
var cast: Dictionary={}
var story
var director
var beast_frames: Dictionary={}
var npcs: Dictionary={}
var enemies: Array=[]
var region_root: Node2D
var dialog_text: Label
var reveal=0.0
var dialog_buttons: HBoxContainer
var dialog_mode=false
var map_mode=false
var dismember_enabled=false
var caravan: Node2D
var beast: Node2D
var caravan_active=false
var escort_start=Vector2(430,950)
var target_marker: Label
var smoke_nodes: Array=[]
var defeat_pending=false
func _ready() -> void:
    get_tree().auto_accept_quit=false
    for key in {"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}:
        if not InputMap.has_action(key):
            InputMap.add_action(key)
            var event=InputEventKey.new();event.physical_keycode={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}[key];InputMap.action_add_event(key,event)
    state=ChapterState.new();var loaded=state.load_game()
    director=preload("res://scripts/chapter/cinematic.gd").new();director.game=self;add_child(director)
    if FileAccess.file_exists("res://resources/chapter/beast.json"):beast_frames=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/beast.json"))
    cast=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/cast.json"));story=Story.new(self)
    build_world();build_ui()
    sfx=AudioStreamPlayer.new();sfx.volume_db=-16;add_child(sfx)
    ambient=AudioStreamPlayer.new();ambient.stream=load("res://assets/opener/ambient.wav");ambient.volume_db=-24;add_child(ambient)
    if not "--test" in OS.get_cmdline_user_args():ambient.play()
    say("WASD move · Follow the paths. J opens your journal and regional routes.")
    if not loaded:say("This chapter save could not be read. It is preserved; this visit cannot overwrite it.")
    if not state.scene.is_empty() and state.scene.key in story.scenes:dialogue(state.scene.key,true)
    elif not state.has("introduced"):state.mark("introduced");dialogue("bramm_work")
    if "--startup-smoke" in OS.get_cmdline_user_args():get_tree().create_timer(2.0).timeout.connect(quit_game)
func build_world() -> void:
    stations.clear();supplies.clear();npcs.clear();enemies.clear();smoke_nodes.clear();caravan=null;beast=null;caravan_active=false
    region_root=Node2D.new();add_child(region_root)
    ground_state=WorldState.new();ground_state.terrain.clear()
    for x in range(3,70):
        for y in range(26,30):ground_state.terrain["%d,%d"%[x,y]]="earth"
    for x in range(31,36):
        for y in range(2,42):ground_state.terrain["%d,%d"%[x,y]]="earth"
    if state.region in ["crossing","host","trade"]:
        for x in range(13,61):
            for y in range(18,37):
                if Vector2((x-37)/26.0,(y-27)/13.0).length()<1:ground_state.terrain["%d,%d"%[x,y]]="earth"
    if state.region=="crossing":
        for x in range(44,70):
            for y in range(3,13):ground_state.terrain["%d,%d"%[x,y]]="water"
    ground_state.revision+=1
    var terrain=Terrain.new();terrain.state=ground_state;region_root.add_child(terrain)
    world=Node2D.new();world.y_sort_enabled=true;region_root.add_child(world)
    player=Actor.new();player.identity="player";player.game=self;player.position=state.player_position;player.hp=state.hp
    player.struck.connect(player_strike);player.felled.connect(player_felled);player.stepped.connect(func():play_sound("step"));world.add_child(player)
    camera=Camera2D.new();camera.zoom=Vector2.ONE*0.77;camera.offset=Vector2(0,-170);camera.position_smoothing_enabled=true;camera.position_smoothing_speed=8
    camera.limit_left=0;camera.limit_top=0;camera.limit_right=2260;camera.limit_bottom=1408;player.add_child(camera)
    var forest=state.region in ["pines","hollow","crossing"]
    for i in range(24):
        var x=140+(i%8)*270;var y=330+(i/8)*470
        if i%8 in [3,4]:continue
        if y>650 and state.region in ["host","trade","crossing"]:continue
        world_prop("tree" if forest else "rock",Vector2(x+sin(i*4.3)*90,y+cos(i*1.7)*70))
    for rect in [Rect2(-40,-40,2340,100),Rect2(-40,1340,2340,100),Rect2(-40,0,100,1408),Rect2(2200,0,100,1408)]:
        var body=StaticBody2D.new();body.position=rect.get_center();var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=rect.size;col.shape=shape;body.add_child(col);region_root.add_child(body)
    for road in ROADS[state.region]:
        var at={"north":Vector2(1080,180),"south":Vector2(1080,1250),"east":Vector2(2080,900),"west":Vector2(180,900)}[road[1]]
        station("road",at,"Travel to "+NAMES[road[0]].capitalize(),road[0]);world_label(NAMES[road[0]],at-Vector2(0,70),Color("f0d396"))
    if state.region in ["crossing","host"]:build_camp()
    if state.region=="trade":build_trade()
    if state.region=="pass":build_pass()
    if state.region in ["pines","hollow","cairn"]:build_wilds()
    build_resources()
    if state.has("own_wagon") and not state.has("home_packed") and state.camp_region==state.region:build_home()
    if state.region=="crossing" and state.chapter==4:build_defense()
    if state.region=="crossing" and state.chapter==5:build_duel()
    if state.region=="crossing" and state.chapter==2 and state.has("hunt_won"):station("feast",Vector2(990,1130),"Prepare the clan feast · 2 meat")
func station(kind: String,at: Vector2,text: String,id: String="") -> void:
    stations.append({"kind":kind,"position":at,"text":"E  "+text,"id":id})
func world_label(text: String,at: Vector2,color: Color=Color("e2c79d")) -> Label:
    var label=helper.words(text,17);label.position=at-Vector2(160,0);label.size=Vector2(320,28);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_color_override("font_color",color)
    label.add_theme_color_override("font_shadow_color",Color("201c18"));label.add_theme_constant_override("shadow_offset_x",2);label.add_theme_constant_override("shadow_offset_y",2);world.add_child(label);return label
func wagon(at: Vector2,scale_factor: float=0.65) -> Node2D:
    camp_item("wagon",at,Rect2(10,4,800,580),scale_factor,Vector2(350,65),Vector2(0,-85));return world.get_child(world.get_child_count()-1)
func tent(at: Vector2,scale_factor: float=0.55) -> void:camp_item("tent",at,Rect2(832,16,700,560),scale_factor,Vector2(275,50),Vector2(0,-85))
func hearth(at: Vector2) -> void:camp_item("hearth",at,Rect2(140,555,560,440),0.32,Vector2(105,40),Vector2(0,-15))
func build_camp() -> void:
    var host=state.region=="host"
    var w=wagon(Vector2(740,690),0.76 if host else 0.65)
    if not host and not state.has("repaired"):w.modulate=Color("b7a38b")
    if not host and state.chapter>=4:w.modulate=Color("554a41")
    tent(Vector2(1300,710));hearth(Vector2(1050,1050))
    camp_item("provisions",Vector2(650,1000),Rect2(804,665,710,325),0.28,Vector2(150,40),Vector2(0,-16))
    station("hearth",Vector2(1050,1100),"Cook · 2 meat + 1 timber")
    station("offering",Vector2(1170,1110),"Sava's first portion · 1 meal")
    if not host:
        station("repair",Vector2(740,770),"Repair the family wagon · 6 timber")
        station("provisions",Vector2(650,1050),"Take the family's cooking supplies")
        if state.chapter<4:
            for id in ["bramm","svala","gorund","dorrik","astrid"]:npc(id)
        elif state.chapter>=6:
            station("pendant",Vector2(790,800),"Search Astrid's family coffer")
            world_label("THE EMBERHIDE HEARTH",Vector2(1050,1000))
        if state.chapter>=4:
            for at in [Vector2(740,590),Vector2(1300,620),Vector2(540,660)]:fire_column(at)
    else:
        for at in [Vector2(1780,700),Vector2(420,560),Vector2(1880,430)]:wagon(at,0.58)
        tent(Vector2(430,1150),0.48);tent(Vector2(1600,480),0.6);tent(Vector2(1180,400),0.5)
        hearth(Vector2(1450,1150));hearth(Vector2(350,880))
        for id in ["hrothgar","thyra","runa","eydis"]:npc(id)
        for i in range(3):add_beast(Vector2(410+i*190,1260),0.3)
        npc("svala",Vector2(1300,1150));npc("astrid",Vector2(1430,1250))
        if state.has("saved_bramm"):npc("bramm",Vector2(930,1230))
        if state.has("saved_dorrik"):npc("dorrik",Vector2(710,1190))
        station("trade",Vector2(1850,1220),"Trade provisions and hides")
        world_label("THE SACRED HEARTH",Vector2(1040,1000));world_label("BEAST PEN",Vector2(500,1180))
func npc(id: String,at: Vector2=Vector2.ZERO) -> Node2D:
    var info=cast[id];var actor=Actor.new();actor.identity=id;actor.height=info.height;actor.game=self;actor.controlled=false
    actor.position=Vector2(info.home[0],info.home[1]) if at==Vector2.ZERO else at
    actor.route=info.route if at==Vector2.ZERO else [[at.x,at.y],[at.x+90,at.y-30],[at.x-50,at.y+15]]
    world.add_child(actor);npcs[id]=actor
    return actor
func build_trade() -> void:
    # Reuse the old settlement's timber buildings for the smaller peoples' fixed post.
    for i in range(3):
        var building=preload("res://scripts/building.gd").new();building.kind=i;building.position=[Vector2(620,620),Vector2(1400,640),Vector2(1760,1080)][i];world.add_child(building)
    for x in range(350,1900,85):world_prop("wall",Vector2(x,470))
    wagon(Vector2(650,1080),0.5);hearth(Vector2(1160,1040))
    npc("eydis",Vector2(1380,920));station("trade",Vector2(1520,1010),"Trade · meat and hides")
    world_label("BLACKSTONE EXCHANGE",Vector2(1370,810));station("hearth",Vector2(1160,1100),"Cook at the trade hearth")
func build_resources() -> void:
    var cycle=int(state.clock/480)
    for i in range(8):
        var pos=[Vector2(400,850),Vector2(885,810),Vector2(1475,900),Vector2(1880,800),Vector2(500,1220),Vector2(960,1180),Vector2(1500,1260),Vector2(1940,1170)][i]
        var id="%s_wood_%d_%d"%[state.region,i,cycle]
        if not id in state.collected:
            var node=world_prop("log",pos);supplies.append({"kind":"wood","id":id,"position":pos,"text":"E  Gather 2 timber","node":node})
    if state.region in ["pass","cairn"]:
        for i in range(5):
            var pos=Vector2(550+i*270,600);var id="%s_ore_%d_%d"%[state.region,i,cycle]
            if not id in state.collected:
                var node=world_prop("rock",pos);supplies.append({"kind":"ore","id":id,"position":pos,"text":"E  Break loose 2 ore","node":node})
func build_wilds() -> void:
    if state.region=="pines":
        for i in range(3):
            var at=Vector2(820+i*130,890-i*240);station("track",at,"Read the predator's sign",str(i));world_prop("log" if i==1 else "rock",at)
            world_label(["GOUGED BARK","BLOOD ON THE NEEDLES","TRACKS INTO THE HOLLOW"][i],at-Vector2(0,45))
        add_wolf("pines_wolf_%d"%int(state.clock/480),Vector2(1660,710),false)
        if state.chapter==2:
            var father=npc("bramm",Vector2(880,1100));father.companion=true;father.target=player
            if state.has("companion"):
                var friend=npc("dorrik",Vector2(760,1160));friend.companion=true;friend.target=player
    elif state.region=="hollow":
        for at in [Vector2(650,600),Vector2(1450,650),Vector2(1650,950),Vector2(660,1080)]:world_prop("rock",at)
        if state.chapter==2:
            var father=npc("bramm",Vector2(900,1100));father.companion=true;father.target=player
            if state.has("companion"):
                var friend=npc("dorrik",Vector2(750,1140));friend.companion=true;friend.target=player
        if state.has("track_0") and state.has("track_1") and state.has("track_2"):add_wolf("hollow_alpha",Vector2(1130,700),true)
        else:world_label("THE TRAIL IS COLD · READ THE SIGNS IN THE PINES",Vector2(1100,800))
    else:
        tent(Vector2(1400,650),0.35);hearth(Vector2(1140,950))
        for i in range(3):add_raider("cairn_%d"%i,Vector2(850+i*260,800+(i%2)*300),"goblin")
func add_wolf(id: String,at: Vector2,alpha: bool) -> void:
    if id in state.defeated:
        if not ("loot_"+id) in state.collected:station("harvest",at,"Harvest the fallen wolf",id)
        return
    var wolf=Wolf.new();wolf.position=at;wolf.alpha=alpha;wolf.game=self;wolf.target=player;wolf.loot_id=id;wolf.set_meta("id",id)
    wolf.strike.connect(enemy_strike);wolf.slain.connect(enemy_slain);world.add_child(wolf);wolf.hp=state.encounters.get(id,wolf.hp);enemies.append(wolf)
func add_raider(id: String,at: Vector2,kind: String) -> void:
    if id in state.defeated:return
    var foe=Raider.new();foe.kind=kind;foe.position=at;foe.game=self;foe.target=player;foe.set_meta("id",id)
    foe.strike.connect(enemy_strike);foe.slain.connect(enemy_slain);world.add_child(foe);foe.hp=state.encounters.get(id,foe.hp);enemies.append(foe)
func build_defense() -> void:
    for i in range(4):add_raider("defense_%d"%i,Vector2(680+(i%2)*700,880+(i/2)*170),"orc")
    if not state.has("saved_bramm"):npc("bramm",Vector2(500,870));station("rescue",Vector2(500,900),"Get Bramm out · clear the western blades","bramm")
    if not state.has("saved_dorrik"):npc("dorrik",Vector2(1590,990));station("rescue",Vector2(1590,1020),"Get Dorrik out · clear the eastern blades","dorrik")
func build_duel() -> void:
    var chief=npc("hrothgar",Vector2(1320,940));chief.route=[];chief.hostile=true;chief.maximum=620;chief.hp=state.encounters.get("duel",620);chief.target=player
    chief.struck.connect(enemy_strike);chief.felled.connect(enemy_slain);chief.set_meta("id","duel");enemies.append(chief)
func build_pass() -> void:
    for i in range(3):
        if not state.has("rubble_"+str(i)):
            var at=Vector2(850+i*260,930);world_prop("rock",at);station("rubble",at+Vector2(0,45),"Clear the rockfall · gain 2 ore",str(i))
    beast=add_beast(Vector2(1530,740),0.55);station("beast",Vector2(1500,840),"Offer the stone-eater 3 ore")
    caravan=wagon(Vector2(state.escort_x,950) if not state.has("caravan_moved") else Vector2(1810,950),0.56)
    station("escort",Vector2(500,1020),"Lead the provision wagon through the pass")
    if state.has("escort_started") and not state.has("caravan_moved"):caravan_active=true
func add_beast(at: Vector2,factor: float) -> Node2D:
    var b=Node2D.new();b.position=at;world.add_child(b)
    if ResourceLoader.exists("res://assets/chapter/beast.png"):
        var spr=Sprite2D.new();spr.texture=load("res://assets/chapter/beast.png");spr.region_enabled=true
        var r=beast_frames.frames[0][0]
        spr.region_rect=Rect2(r[0],r[1],r[2],r[3]);spr.scale=Vector2.ONE*factor;spr.position.y=-r[3]*factor/2;b.add_child(spr)
    return b
func build_home() -> void:
    wagon(Vector2(1800,1230),0.46);hearth(Vector2(1940,1280));station("home",Vector2(1800,1310),"Your household · rest, improve, or take the road")
    world_label("YOUR HEARTH",Vector2(1830,1110))
    if state.has("platform"):camp_item("provisions",Vector2(1620,1300),Rect2(804,665,710,325),0.25,Vector2(140,40),Vector2(0,-16))
func fire_column(at: Vector2) -> void:
    # Smoke and flame are in-world effects over the existing camp illustrations.
    var plume=preload("res://scripts/chapter/smoke.gd").new();plume.position=at+Vector2(0,80);plume.z_index=3;world.add_child(plume);smoke_nodes.append(plume)
func rebuild() -> void:
    director.finish()
    if is_instance_valid(region_root):remove_child(region_root);region_root.queue_free()
    build_world()
func travel(region: String,spawn: Vector2=Vector2(1080,1000),forced: bool=false) -> void:
    if not forced:
        if state.chapter in [4,5]:say("Your clan is still fighting. Finish what you can here.");return
        if region in ["host","trade","pass"] and state.chapter<6:say("Stonebelly warriors hold that road. Your family needs you at Emberhide Crossing.");return
        if state.chapter==3 and state.has("ready") and state.region=="crossing":state.mark("departed")
        if region=="crossing" and state.chapter==3 and state.has("departed"):state.chapter=4;state.defense_left=100
    save_progress()
    state.hp=player.hp;state.region=region;state.player_position=spawn;rebuild();save_progress()
    say(NAMES[region].capitalize()+" · J opens your journal and the routes.")
    if state.chapter==4 and not state.has("burning_seen"):state.mark("burning_seen");dialogue("burning")
func build_ui() -> void:
    var layer=CanvasLayer.new();add_child(layer)
    var top=panel(Vector2(20,16),Vector2(1240,108));layer.add_child(top)
    var box=VBoxContainer.new();box.add_theme_constant_override("separation",5);top.add_child(box)
    hud=helper.words("",18);box.add_child(hud);objective=helper.words("",17,"e3bb78");box.add_child(objective)
    var controls=helper.words("WASD move   LMB axe   RMB block / parry   Space dodge   E interact   Q eat   J journal   I belongings   Esc pause",14,"b5ad98");box.add_child(controls)
    var bottom=panel(Vector2(20,698),Vector2(1240,86));layer.add_child(bottom)
    var lines=VBoxContainer.new();bottom.add_child(lines);prompt=helper.words("",20);lines.add_child(prompt);notice=helper.words("",15,"ccb68f");notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;notice.custom_minimum_size.x=1180;lines.add_child(notice)
    modal=Control.new();modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(modal);modal.hide()
func _process(delta: float) -> void:
    if leaving:return
    objective.text=story.objective()
    hud.text="%s   ·   Health %d / 160   ·   Guard %d   ·   Meals %d   ·   %s"%[NAMES[state.region],int(player.hp),int(player.guard),state.inventory.meals,"Well fed: %ds"%int(state.fed) if state.fed>0 else "A hungry road"]
    if dialog_mode:
        reveal+=delta*48;dialog_text.visible_characters=int(reveal)
        return
    if modal.visible:return
    state.clock+=delta;state.fed=maxf(0,state.fed-delta);state.hp=player.hp
    player.block(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT),get_global_mouse_position()-player.position)
    nearest={};var best=125.0
    for entry in stations+supplies:
        if entry.kind in ["wood","ore"] and entry.id in state.collected:continue
        var distance=player.position.distance_to(entry.position)
        if distance<best:nearest=entry;best=distance
    for id in npcs:
        var actor=npcs[id]
        if actor.hostile or actor.hp<=0:continue
        var distance=player.position.distance_to(actor.position)
        if distance<best:nearest={"kind":"npc","id":id,"position":actor.position,"text":"E  Speak with "+cast[id].name};best=distance
    prompt.text=nearest.get("text","Follow the worn paths · J shows regional exits and your next task")
    if state.chapter==4:
        state.defense_left=maxf(0,state.defense_left-delta)
        if state.defense_left<=0:finish_defense()
    if caravan_active:escort_tick(delta)
    if state.chapter==1 and state.has("eaten") and state.has("offering"):
        state.chapter=2;state.mark("axe");say("The first portion is given. Bramm has found signs of a great predator in the Northern Pines.");save_progress()
    save_clock+=delta
    if save_clock>25:save_clock=0;save_progress()
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and not modal.visible:
        if event.button_index==MOUSE_BUTTON_LEFT:player.attack(get_global_mouse_position()-player.position)
    if not event is InputEventKey or not event.pressed or event.echo:return
    var key=event.keycode
    if dialog_mode:
        if key in [KEY_SPACE,KEY_ENTER,KEY_E]:advance_dialogue()
        elif key==KEY_ESCAPE:finish_dialogue()
        elif key==KEY_F5:save_progress()
        return
    if key==KEY_ESCAPE:
        if modal.visible:close_modal()
        else:pause_menu()
        return
    if modal.visible:return
    match key:
        KEY_E:
            if not nearest.is_empty():interact(nearest)
        KEY_SPACE:player.dodge(Input.get_vector("move_left","move_right","move_up","move_down"))
        KEY_Q:
            state.hp=player.hp
            if state.eat():player.hp=state.hp;say("A warm meal: +65 health, three minutes of strength (+6 axe damage).");play_sound("success")
            else:say("No meals. Cook two meat and one timber at a hearth.")
            save_progress()
        KEY_F5:say("Chapter saved." if save_progress() else "Save unavailable; your previous save is preserved.")
        KEY_J:journal()
        KEY_I:belongings()
        KEY_B:
            if state.has("home_packed") and state.region in ["host","crossing","trade"]:
                state.camp_region=state.region;state.flags["home_packed"]=false;state.player_position=player.position;rebuild();save_progress();say("Your household is settled beside the road.")
func interact(entry: Dictionary) -> void:
    match entry.kind:
        "npc":story.talk(entry.id)
        "road":
            var dest=entry.id;var spawn=Vector2(1080,1100)
            if entry.position.x>2000:spawn=Vector2(260,900)
            elif entry.position.x<300:spawn=Vector2(1980,900)
            elif entry.position.y>1100:spawn=Vector2(1080,260)
            travel(dest,spawn)
        "wood","ore":
            if state.collect(entry.id,entry.kind,2):entry.node.data.state="collected";entry.node.refresh();say("Two %s added to your pack."%entry.kind);play_sound("gather")
        "provisions":
            if state.collect("family_provisions","meat",8):say("Eight cuts from the family stores. Svala expects you to make them useful.")
            else:say("The family provisions are already in your pack.")
        "repair":
            if state.has("repaired"):say("A sound rear axle. Your timber is part of the wagon now.")
            elif state.pay({"wood":6}):
                state.mark("repaired");state.chapter=1;state.change("bramm","admiration",2)
                if state.has("contest"):state.inventory.meals+=1;state.change("dorrik","friendship",2);state.mark("contest_won")
                state.player_position=player.position;rebuild();say("The new axle is fitted. Bramm nods. Svala is waiting at the cooking hearth.");play_sound("success")
            else:say("Six timber to repair the axle. Fallen logs lie along the camp trails.")
        "hearth":
            if state.cook():say("Three hearty meals prepared. Q eats one; the carved hearth stone takes Sava's portion.");play_sound("success")
            else:say("Two meat and one timber for three meals. Take the family provisions or hunt in the Pines.")
        "offering":
            if state.has("offering"):say("Sava has received the first portion. The fire is tended.")
            elif state.pay({"meals":1}):state.mark("offering");state.change("svala","loyalty",2);say("A portion for Sava. Svala presses a coal into the traveling ember-pot.")
            else:say("Cook a meal first. Sava's portion comes from the same pot as yours.")
        "track":
            state.mark("track_"+entry.id);say(["Deep claw marks above your head. Bramm points toward the blood on the next tree.","Fresh blood, thick gray fur. The trail turns north through the needles.","Heavy tracks enter Wolfscar Hollow. The predator is close; ready your axe."][int(entry.id)])
        "harvest":
            if state.collect("loot_"+entry.id,"meat",6):
                state.inventory.hide+=2
                if entry.id=="hollow_alpha":state.inventory.trophy+=1;state.mark("hunt_won");state.change("bramm","admiration",3);state.change("dorrik","admiration",2)
                say("Six meat, two hides%s. Return to Emberhide and prepare the feast."%(" and the great wolf's trophy" if entry.id=="hollow_alpha" else ""))
        "feast":story.action("feast")
        "rescue":
            var ids=["defense_0","defense_2"] if entry.id=="bramm" else ["defense_1","defense_3"]
            if not ids[0] in state.defeated or not ids[1] in state.defeated:say("The blades still bar the way. Defeat the two attackers on this side first.")
            else:
                state.mark("saved_"+entry.id);state.change(entry.id,"loyalty",4);say(cast[entry.id].name+" escapes with Svala and Astrid.")
                if npcs.has(entry.id):npcs[entry.id].hide();npcs[entry.id].enabled=false;npcs.erase(entry.id)
                if state.has("saved_bramm") and state.has("saved_dorrik"):finish_defense()
        "rubble":
            if not state.has("road"):say("Speak with Runa before moving the clan's road stones.")
            elif not state.has("rubble_"+entry.id):state.mark("rubble_"+entry.id);state.inventory.ore+=2;state.player_position=player.position;rebuild();say("The rockfall is cleared. Two ore retained for the forge or the stone-eater.");play_sound("gather")
        "beast":
            if state.has("beast_fed"):say("The stone-eater follows the sound of your ore pouch. Runa approves of a patient hand.")
            elif state.pay({"ore":3}):state.mark("beast_fed");state.change("runa","admiration",2);say("It grinds the ore between broad teeth, then follows your hand. Ready the wagon at the west end.")
            else:say("Three ore. The young beast is eating the exposed mineral seam.")
        "escort":
            if state.has("caravan_moved"):say("The provision wagon has crossed. The road is open.")
            elif state.has("rubble_0") and state.has("rubble_1") and state.has("rubble_2") and state.has("beast_fed"):
                caravan_active=true;state.mark("escort_started");say("Walk east beside the wagon. The stone-eater will pull while you stay within 400 paces.")
            else:say("Clear all three falls and feed the beast before moving the wagon.")
        "pendant":state.mark("pendant");say("You recover the bone hearth pendant and its broken clasp. Astrid waits with the survivors in the Host.")
        "trade":dialogue("trade")
        "home":home_menu()
    if state.has("hunt_won") and state.chapter==2 and state.region=="crossing":
        if not stations.any(func(e):return e.kind=="feast"):station("feast",Vector2(990,1130),"Prepare the clan feast · 2 meat")
    save_progress()
func finish_defense() -> void:
    if state.has("defense_ended"):return
    state.mark("defense_ended");state.mark("gorund_fallen");state.chapter=5
    for foe in enemies:foe.active=false
    player.position=Vector2(960,1030);state.player_position=player.position;state.hp=maxf(110,player.hp);player.hp=state.hp
    dialogue("challenge")
func contract_done() -> bool:return "cairn_0" in state.defeated and "cairn_1" in state.defeated and "cairn_2" in state.defeated
func escort_tick(delta: float) -> void:
    if not is_instance_valid(caravan):return
    if player.position.distance_to(caravan.position)>400:return
    caravan.position.x=minf(1810,caravan.position.x+100*delta);state.escort_x=caravan.position.x
    if is_instance_valid(beast):
        beast.position=caravan.position+Vector2(280,15)
        if beast.get_child_count()>0:
            var spr=beast.get_child(0);var r=beast_frames.frames[0][int(state.clock*5)%4];spr.region_rect=Rect2(r[0],r[1],r[2],r[3])
    if caravan.position.x>=1810:
        caravan_active=false;state.mark("caravan_moved");state.chapter=maxi(8,state.chapter);state.inventory.coin+=8;state.change("thyra","admiration",2);say("The wagon clears the pass. Eight coin earned. Eydis has paid work at Blackstone, east of the Host.");save_progress()
func has_line(from: Vector2,to: Vector2,_ignored=null) -> bool:
    var q=PhysicsRayQueryParameters2D.create(from,to,1);return get_world_2d().direct_space_state.intersect_ray(q).is_empty()
func route_direction(actor: Node2D,dest: Vector2) -> Vector2:
    var direct=(dest-actor.position).normalized()
    for angle in [0.0,0.6,-0.6,1.15,-1.15]:
        var trial=direct.rotated(angle)
        if has_line(actor.position,actor.position+trial*85):return trial
    return Vector2.ZERO
var last_attacker
func player_strike(actor) -> void:
    var hit=false
    for foe in enemies:
        if not is_instance_valid(foe) or foe.hp<=0:continue
        var off=foe.position-player.position
        if off.length()<145 and actor.locked.dot(off.normalized())>0.15 and has_line(player.position,foe.position):
            impact(foe.position)
            foe.receive_hit((36 if state.has("honed_axe") else 28)+(6 if state.fed>0 else 0),off.normalized());hit=true
    if hit:play_sound("hit")
    else:play_sound("swing")
func impact(at: Vector2) -> void:
    if not state.gore:return
    var splash=Node2D.new();splash.position=at;splash.z_index=1;world.add_child(splash)
    for i in range(5):
        var drop=Polygon2D.new();drop.color=Color("7e322f");drop.polygon=PackedVector2Array([Vector2(-3,-2),Vector2(4,-1),Vector2(2,3),Vector2(-2,2)]);drop.position=Vector2.from_angle(i*2.4)*float(8+i*4);splash.add_child(drop)
    var fade=splash.create_tween();fade.tween_interval(0.4);fade.tween_property(splash,"modulate:a",0.0,0.4);fade.tween_callback(splash.queue_free)
func enemy_strike(foe) -> void:
    var off=player.position-foe.position
    var reach=220 if foe is Actor else 115 if foe is Wolf else 120
    var direction=foe.locked if foe is Actor else foe.locked_direction
    if off.length()>reach or direction.dot(off.normalized())<0.1 or not has_line(foe.position,player.position):return
    last_attacker=foe;play_sound("hit");player.receive_hit(42 if foe is Actor else 22 if foe is Wolf else 18,off.normalized());state.hp=player.hp
func parry(_actor) -> void:
    if is_instance_valid(last_attacker):last_attacker.parried()
    say("Parried — strike while the weapon is checked.");play_sound("block")
func enemy_slain(foe) -> void:
    var id=foe.get_meta("id","")
    if id=="duel":
        state.mark("duel_won");state.change("hrothgar","admiration",5);dialogue("victory");return
    if not id in state.defeated:state.defeated.append(id)
    if foe is Wolf:station("harvest",foe.position,"Harvest meat, hide and trophy",id)
    elif id.begins_with("cairn"):state.inventory.coin+=2;state.inventory.meat+=1
    save_progress()
func player_felled(_actor) -> void:
    if defeat_pending:return
    defeat_pending=true;resolve_defeat.call_deferred()
func resolve_defeat() -> void:
    if state.chapter==5:
        var chief=npcs.get("hrothgar")
        if is_instance_valid(chief) and chief.hp<310:state.mark("duel_respected");state.change("hrothgar","admiration",2)
        state.hp=110;player.hp=110;dialogue("mercy")
    elif state.chapter==4:finish_defense()
    else:
        state.hp=110;state.player_position=Vector2(1080,1120);rebuild();say("You drag yourself out of danger. Your stores are intact. Eat, then try another approach.")
    defeat_pending=false
func toast(text: String,_at: Vector2) -> void:say(text.replace("Staggered • F from the side","Staggered — follow through with your axe"))
func play_sound(kind: String) -> void:
    var files={"hit":"camp/hit","block":"camp/metal","gather":"camp/wood","step":"camp/step","swing":"opener/swing","growl":"opener/growl","success":"opener/success"}
    if not leaving and kind in files and is_instance_valid(sfx):sfx.stream=load("res://assets/"+files[kind]+".wav");sfx.play()
func sound(kind: String) -> void:play_sound(kind)
func freeze(value: bool) -> void:
    player.enabled=not value
    for actor in npcs.values():actor.enabled=not value
    for foe in enemies:
        if foe is Actor:foe.enabled=not value
        else:foe.active=not value
func clear_modal() -> void:
    for child in modal.get_children():modal.remove_child(child);child.queue_free()
    modal.show();freeze(true)
func close_modal() -> void:
    modal.hide();dialog_mode=false;map_mode=false;director.finish();freeze(false)
func dialogue(key: String,resume=false) -> void:
    if not key in story.scenes:return
    if not resume:state.scene={"key":key,"cursor":0}
    clear_modal();dialog_mode=true
    var scene=story.scenes[key];var index=mini(int(state.scene.cursor),scene.lines.size()-1);state.scene.cursor=index
    var line=scene.lines[index]
    if line.has("requires") and not state.has(line.requires):
        state.scene.cursor+=1;dialogue(key,true);return
    var person=line.speaker
    director.stage(person,key)
    var shade=ColorRect.new();shade.color=Color(0.03,0.025,0.02,0.25);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var illustration=line.get("art",scene.art)
    if illustration>=0:shade.color=Color(0.03,0.025,0.02,0.82)
    if illustration>=0 and ResourceLoader.exists("res://assets/chapter/cinematics.png"):
        var art=TextureRect.new();var atlas=AtlasTexture.new();atlas.atlas=load(cinematic_texture_path())
        var width=atlas.atlas.get_width()/2.0;var height=atlas.atlas.get_height()/3.0;atlas.region=Rect2((int(illustration)%2)*width,int(illustration/2)*height,width,height)
        art.texture=atlas;art.position=Vector2(250,130);art.size=Vector2(780,350);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;modal.add_child(art)
    var box=panel(Vector2(20,495),Vector2(1240,288));modal.add_child(box)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",22);box.add_child(row)
    var portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(170,210);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture=portrait_texture(person,line.expression);row.add_child(portrait)
    var column=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",8);row.add_child(column)
    column.add_child(helper.words(cast[person].name.to_upper()+"  ·  "+cast[person].role,19,"efc580"))
    dialog_text=helper.words(line.get("brutal_text",line.text) if state.gore else line.text,21);dialog_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialog_text.custom_minimum_size=Vector2(960,112);dialog_text.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(dialog_text);reveal=0;dialog_text.visible_characters=0
    dialog_buttons=HBoxContainer.new();dialog_buttons.add_theme_constant_override("separation",10);column.add_child(dialog_buttons)
    if index<scene.lines.size()-1:helper.action("Continue  ·  Space",advance_dialogue,dialog_buttons)
    else:
        for choice in scene.choices:
            var action=choice[1];var button=helper.action(choice[0],func():choose(action),dialog_buttons);button.add_theme_font_size_override("font_size",17)
    column.add_child(helper.words("Space / Enter reveal and advance · Esc skips to the choices · F5 saves this moment",13,"b5ad98"))
    if npcs.has(person):npcs[person].face(player.position-npcs[person].position);npcs[person].show_frame(0)
    save_progress()
func portrait_texture(person: String,expression: String="neutral") -> Texture2D:
    var path="res://resources/chapter/"+person+".json"
    if not FileAccess.file_exists(path):return null
    var data=JSON.parse_string(FileAccess.get_file_as_string(path));var r=data.frames[0][0]
    var atlas=AtlasTexture.new();atlas.atlas=load("res://assets/chapter/"+person+".png")
    atlas.region=Rect2(r[0],r[1],r[2],r[3]*0.48)
    var expr_path="res://resources/chapter/portraits.json"
    if FileAccess.file_exists(expr_path):
        var expressions=JSON.parse_string(FileAccess.get_file_as_string(expr_path))
        if expressions.has(person):
            var e=expressions[person].get(expression,expressions[person].neutral);atlas.atlas=load(expressions[person].texture);atlas.region=Rect2(e[0],e[1],e[2],e[3])
    return atlas
func advance_dialogue() -> void:
    if not dialog_mode:return
    if dialog_text.visible_characters>=0 and dialog_text.visible_characters<dialog_text.text.length():reveal=100000;dialog_text.visible_characters=-1;return
    var scene=story.scenes[state.scene.key]
    if state.scene.cursor<scene.lines.size()-1:state.scene.cursor+=1;dialogue(state.scene.key,true)
    elif scene.choices.size()==1:choose(scene.choices[0][1])
func finish_dialogue() -> void:
    var scene=story.scenes[state.scene.key]
    state.scene.cursor=scene.lines.size()-1;dialogue(state.scene.key,true);reveal=100000;dialog_text.visible_characters=-1
func choose(action: String) -> void:
    state.scene={};close_modal();story.action(action);save_progress()
func save_progress() -> bool:
    if not is_instance_valid(player):return false
    state.player_position=player.position;state.hp=player.hp
    for foe in enemies:
        if is_instance_valid(foe):state.encounters[foe.get_meta("id","")]=foe.hp
    return state.save_game()
func simple_menu(title: String,copy: String) -> VBoxContainer:
    clear_modal();var shade=ColorRect.new();shade.color=Color(0.03,0.03,0.02,0.7);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var box=panel(Vector2(150,145),Vector2(980,520));modal.add_child(box);var col=VBoxContainer.new();col.add_theme_constant_override("separation",12);box.add_child(col)
    col.add_child(helper.words(title,27));var label=helper.words(copy,18);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.custom_minimum_size.x=920;col.add_child(label);return col
func pause_menu() -> void:
    var col=simple_menu("THE FIRE WE CARRY","The chapter autosaves. Earlier campaigns and the first Ogre visit have separate saves.")
    helper.action("Return to the fire",close_modal,col)
    helper.action("Journal and routes",journal,col)
    helper.action("Brutality: "+("full" if state.gore else "restrained"),func():state.gore=not state.gore;save_progress();pause_menu(),col)
    helper.action("Save and return to title" if not state.unreadable else "Leave this unsaved visit",return_to_menu,col)
    helper.action("Save and quit" if not state.unreadable else "Quit without changing unreadable save",quit_game,col)
func belongings() -> void:
    var text=""
    for item in state.inventory:text+="%s  %d     "%[item.capitalize(),state.inventory[item]]
    text+="\n\nHunting axe: %d damage. Well fed adds 6. A meal restores 65 health.\nGuard recovers while you are neither attacking nor blocking. Dodge costs 25 guard."%(36 if state.has("honed_axe") else 28)
    var col=simple_menu("BELONGINGS",text);helper.action("Return",close_modal,col)
func journal() -> void:
    var text=story.objective()+"\n\nROADS FROM HERE\n"
    for road in ROADS[state.region]:text+="%s: %s     "%[road[1].capitalize(),NAMES[road[0]].capitalize()]
    text+="\n\nEmberhide → Pines → Wolfscar Hollow. Pines → Goblin Cairn.\nStonebelly Host → Sundered Pass / Blackstone. Blackstone → Goblin Cairn.\n\n"
    if state.chapter>=6:text+="Bramm: %s. Dorrik: %s. Svala and Astrid escaped. Gorund fell in single combat.\n"%["escaped" if state.has("saved_bramm") else "fell defending the crossing","escaped" if state.has("saved_dorrik") else "fell holding the eastern path"]
    for id in ["astrid","runa","eydis"]:
        var rel=state.relationships[id];text+="%s: %s · admiration %d · loyalty %d\n"%[cast[id].name,"courting" if rel.courting else "acquainted" if rel.met else "not yet met",rel.admiration,rel.loyalty]
    var col=simple_menu("JOURNAL · CHAPTER ONE",text);helper.action("Return to the road",close_modal,col)
func home_menu() -> void:
    var col=simple_menu("YOUR HOUSEHOLD","A wagon, a fire, and a claim on your own future. Rest restores health. Add dry provision racks for six timber. You may settle in another safe region after traveling there.")
    helper.action("Rest beside your hearth",func():player.hp=160;state.hp=160;close_modal();save_progress(),col)
    helper.action("Build the provision racks · 6 timber",func():
        if state.has("platform"):say("Your provision racks is already built.")
        elif state.pay({"wood":6}):state.mark("platform");state.inventory.meals+=3;say("Dry provision racks and dry stores fitted. Three meals stocked.")
        else:say("Six timber needed.")
        state.player_position=player.position;close_modal();rebuild();save_progress(),col)
    helper.action("Explore Sundered Frontier · gameplay expedition",func():
        if not save_progress():return
        prepare_exit();await get_tree().create_timer(0.15).timeout;get_tree().change_scene_to_file("res://scenes/ogre_frontier.tscn"),col)
    helper.action("Pack for the road",func():state.mark("home_packed");state.player_position=player.position;close_modal();rebuild();say("Your household is packed. Press B in a safe region to settle it there.");save_progress(),col)
    helper.action("Return",close_modal,col)

func prepare_exit() -> void:
    director.finish();freeze(true);super.prepare_exit()

func cinematic_texture_path() -> String:
    return "res://assets/chapter/cinematics_brutal.png" if state.gore else "res://assets/chapter/cinematics.png"
