extends Node2D
const Menu = preload("res://scripts/main_menu.gd")
const Prop = preload("res://scripts/camp_prop.gd")
const Scale=preload("res://scripts/ogre_scale.gd")
const ChapterState=preload("res://scripts/chapter/state.gd")
const Actor=preload("res://scripts/chapter/actor.gd")
const Story=preload("res://scripts/chapter/story.gd")
const Wolf=preload("res://scripts/direwolf.gd")
const Raider=preload("res://scripts/raider.gd")
const OgreCamera=preload("res://scripts/ogre_camera.gd")
const OfferingStone = preload("res://scripts/chapter/offering_stone.gd")
const CampGround = preload("res://scripts/chapter/camp_ground.gd")
const OgreTerrain=preload("res://scripts/ogre_terrain.gd")
const BeastArt=preload("res://scripts/beast_art.gd")
const NAMES={"crossing":"EMBERHIDE CROSSING","pines":"NORTHERN PINES","hollow":"WOLFSCAR HOLLOW","cairn":"GOBLIN CAIRN","pass":"SUNDERED PASS","host":"STONEBELLY HOST","trade":"BLACKSTONE TRADE POST"}
const ROADS={"crossing":[["pines","north"],["host","east"]],"pines":[["crossing","south"],["hollow","north"],["cairn","east"]],"hollow":[["pines","south"]],"cairn":[["pines","west"],["trade","east"],["pass","north"]],"host":[["crossing","west"],["pass","north"],["trade","east"]],"pass":[["host","south"],["cairn","east"]],"trade":[["host","west"],["cairn","north"]]}
class GroundState:
    var terrain: Dictionary = {}
    var revision := 0

var state = ChapterState.new()
var player: CharacterBody2D
var camera: Camera2D
var world: Node2D
var hud: Label
var objective: Label
var notice: Label
var prompt: Label
const FITTING_VIEWS := [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]
var fitting_angle := 0
var loot_menu = preload("res://scripts/chapter/loot_menu.gd").new(self)
var modal: Control
var stations: Array=[]
var supplies: Array=[]
var speech: PanelContainer
var camp_pot: Node2D
var family_wagon: Node2D
var offering_stone: OfferingStone
var nearest: Dictionary={}
var save_clock=0.0
var leaving=false
# The dummy device has no listener; Godot Movie Maker is its one real consumer.
var audio_output_enabled := AudioServer.get_driver_name() != "Dummy" or not Engine.get_write_movie_path().is_empty()
var sfx: AudioStreamPlayer
const HearthAudio = preload("res://scripts/chapter/hearth_audio.gd")
var hearth_audio: HearthAudio
var ambient: AudioStreamPlayer
var helper=Menu.new()
var portrait_data: Dictionary = preload("res://resources/chapter/portraits.json").data
var cast: Dictionary={}
var story
var director
var beast_frames: Dictionary={}
var npcs: Dictionary={}
var enemies: Array=[]
var combat_effects_enabled := true
var region_root: Node2D
var dialog_text: Label
var reveal=0.0
var dialog_buttons: HBoxContainer
var dialog_mode=false
var map_mode=false
var dismember_enabled: bool:
    get: return state.gore
var caravan: Node2D
var beast: Node2D
var caravan_active=false
var escort_start=Vector2(430,950)
var target_marker: Label
var smoke_nodes: Array=[]
var defeat_pending=false
func _ready() -> void:
    get_tree().auto_accept_quit=false
    configure_movement()
    var loaded=state.load_game()
    director=preload("res://scripts/chapter/cinematic.gd").new();director.game=self;add_child(director)
    if FileAccess.file_exists("res://resources/chapter/beast.json"):beast_frames=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/beast.json"))
    cast=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/cast.json"))
    for person in cast.values():
        if person.name.ends_with(" Emberhide"):
            person.name = person.name.trim_suffix(" Emberhide") + " " + state.profile.clan_name
    story=Story.new(self)
    build_world();build_ui()
    sfx=AudioStreamPlayer.new();sfx.volume_db=-16;add_child(sfx)
    ambient=AudioStreamPlayer.new();ambient.stream=load("res://assets/opener/ambient.wav");ambient.volume_db=-24;add_child(ambient)
    if audio_output_enabled and not "--test" in OS.get_cmdline_user_args():ambient.play()
    say("WASD move · Follow the paths. J opens your journal and regional routes.")
    if not loaded:say("This chapter save could not be read. It is preserved; this visit cannot overwrite it.")
    if not state.scene.is_empty() and state.scene.key in story.scenes:dialogue(state.scene.key,true)
    elif not state.has("introduced"):state.mark("introduced");dialogue("bramm_work")
    if "--startup-smoke" in OS.get_cmdline_user_args():get_tree().create_timer(2.0).timeout.connect(quit_game)
func configure_movement() -> void:
    for key in {"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}:
        if not InputMap.has_action(key):
            InputMap.add_action(key)
            var event=InputEventKey.new();event.physical_keycode={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}[key];InputMap.action_add_event(key,event)

func build_world() -> void:
    nearest = {}
    camp_pot = null
    hearth_audio = null
    stations.clear();supplies.clear();npcs.clear();enemies.clear();smoke_nodes.clear();caravan=null;beast=null;caravan_active=false
    region_root=Node2D.new();add_child(region_root)
    var ground_state = GroundState.new()
    if state.region == "crossing":
        CampGround.mark_crossing(ground_state.terrain)
    else:
        for x in range(3,70):
            for y in range(26,30):ground_state.terrain["%d,%d"%[x,y]]="earth"
        for x in range(31,36):
            for y in range(2,42):ground_state.terrain["%d,%d"%[x,y]]="earth"
        if state.region in ["host","trade"]:
            for x in range(13,61):
                for y in range(18,37):
                    if Vector2((x-37)/26.0,(y-27)/13.0).length()<1:ground_state.terrain["%d,%d"%[x,y]]="earth"
    if state.region=="crossing":
        for x in range(44,70):
            for y in range(3,13):ground_state.terrain["%d,%d"%[x,y]]="water"
    ground_state.revision+=1
    var terrain=OgreTerrain.new();terrain.state=ground_state;terrain.z_index=-2;region_root.add_child(terrain)
    world=Node2D.new();world.y_sort_enabled=true;region_root.add_child(world)
    player=Actor.new();player.identity="player";player.game=self;player.position=state.player_position;player.hp=state.hp
    player.struck.connect(player_strike);player.felled.connect(player_felled);player.stepped.connect(func():play_sound("step"));world.add_child(player)
    player.set_hair_palette(state.profile.hair)
    player.equip_weapon(state.equipment.weapon)
    player.equip_body(state.equipment.body)
    player.equip_head(state.equipment.head)
    fit_insignia(player)
    camera=OgreCamera.new();player.add_child(camera)
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
    for id in state.treasure.items:
        var find: Dictionary = state.treasure.items[id]
        if find.place == "field" and find.region == state.region:
            place_find(id)
    if state.has("own_wagon") and not state.has("home_packed") and state.camp_region==state.region:build_home()
    if state.region=="crossing" and state.chapter==4:build_defense()
    if state.region=="crossing" and state.chapter==5:build_duel()
    if state.region=="crossing" and state.chapter==2 and state.has("hunt_won"):station("feast",Vector2(990,1170),"Prepare the clan feast · 2 meat")
func station(kind: String,at: Vector2,text: String,id: String="") -> void:
    stations.append({"kind":kind,"position":at,"text":"E  "+text,"id":id})
func world_label(text: String,at: Vector2,color: Color=Color("e2c79d")) -> Label:
    var label=helper.words(text,17);label.position=at-Vector2(160,0);label.size=Vector2(320,28);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.add_theme_color_override("font_color",color)
    label.add_theme_color_override("font_shadow_color",Color("201c18"));label.add_theme_constant_override("shadow_offset_x",2);label.add_theme_constant_override("shadow_offset_y",2);world.add_child(label);return label
func wagon(at: Vector2,scale_factor: float=0.65) -> Node2D:
    camp_item("wagon",at,Rect2(10,4,800,580),scale_factor,Vector2(350,65),Vector2(0,-85));return world.get_child(world.get_child_count()-1)
func tent(at: Vector2,scale_factor: float=0.55) -> void:camp_item("tent",at,Rect2(832,16,700,560),scale_factor,Vector2(275,50),Vector2(0,-85))
func hearth(at: Vector2) -> void:camp_item("hearth",at,Rect2(140,555,560,440),0.32,Vector2(105,40),Vector2(0,-15))
func build_pot(at: Vector2, site: String) -> void:
    camp_pot = preload("res://scripts/chapter/camp_pot.gd").new()
    camp_pot.position = at
    world.add_child(camp_pot)
    var kettle_body := StaticBody2D.new()
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(105, 40)
    collision.shape = shape
    collision.position = Vector2(0, -15)
    kettle_body.add_child(collision)
    camp_pot.add_child(kettle_body)
    camp_pot.set_servings(int(state.pot_servings.get(site, 0)))
    stations.append({"kind": "hearth", "id": site, "node": camp_pot, "position": at + Vector2(0, 44), "text": "E  Cook · 2 meat + 1 timber"})

func spawn_cut(id: String) -> void:
    var point: Array = state.field_cuts[id]
    var cut = preload("res://scripts/chapter/goblin_cut.gd").new()
    cut.position = Vector2(point[0], point[1])
    world.add_child(cut)
    cut.set_restrained(not state.gore)
    supplies.append({"kind": "goblin_cut", "id": id, "position": cut.position, "node": cut, "text": "Goblin cut   ·   E  Carry   ·   F  Eat raw (+25 health)"})

func interaction_prompt(fallback: String) -> String:
    if nearest.get("kind") != "hearth":
        return nearest.get("text", fallback)
    var portions := int(state.pot_servings.get(nearest.id, 0))
    var cook_hint := "" if nearest.id == "yard" else "   ·   C  Cook provisions"
    if state.inventory.goblin_meat > 0:
        var ladle := "   ·   F  Ladle stew" if portions > 0 else ""
        return "E  Add goblin cut to pot" + ladle + cook_hint
    if portions > 0:
        return "E  Ladle goblin stew (%d left)%s" % [portions, cook_hint]
    if nearest.id == "yard":
        return "Cookpot   ·   Bring a goblin cut to make two portions of stew."
    return nearest.text

func use_food_shortcut(key: Key) -> void:
    if player.hp <= 0:
        return
    if key == KEY_F and nearest.get("kind") == "goblin_cut":
        take_field_cut(nearest, true)
    elif nearest.get("kind") == "hearth":
        if key == KEY_F and state.ladle_stew(nearest.id):
            served_from_pot(nearest)
        elif key == KEY_C and nearest.id != "yard":
            cook_provisions(nearest.get("node"))
        else:
            return
    else:
        return
    save_progress()

func take_field_cut(entry: Dictionary, eat_now: bool) -> void:
    state.hp = player.hp
    if not state.take_cut(entry.id, eat_now):
        return
    player.hp = state.hp
    entry.node.queue_free()
    supplies.erase(entry)
    nearest = {}
    play_sound("gather")
    if eat_now:
        say("You eat the goblin cut where it fell. Health %d / 160." % ceili(player.hp))
    else:
        say("Goblin cut packed. Drop it in a camp pot for two portions of stew.")

func eat_carried_cut() -> void:
    if not state.pay({"goblin_meat": 1}):
        return
    player.hp = minf(160.0, player.hp + ChapterState.RAW_CUT_HEAL)
    play_sound("gather")
    say("You eat a goblin cut. Health %d / 160." % ceili(player.hp))
    save_progress()

func served_from_pot(entry: Dictionary) -> void:
    entry.node.set_servings(state.pot_servings[entry.id], true)
    svala_at_hearth("serve", entry.node)
    play_sound("gather")
    say("One meal packed. Q eats it. %d portions left for the hearth." % state.pot_servings[entry.id])

func cook_provisions(kettle = null) -> void:
    var first_meal := not state.has("cooked")
    if state.cook():
        svala_at_hearth("cook", kettle)
        if first_meal:family_line("svala", "One for Sava. Take your father a bowl, too.")
        play_sound("success")
        say("Three hearty meals prepared. Q eats one; the carved hearth stone takes Sava's portion.")
    else:
        say("Two meat and one timber for three meals. Take the family provisions or hunt in the Pines.")

func svala_at_hearth(action: String, kettle) -> void:
    var cook = npcs.get("svala")
    if is_instance_valid(cook) and is_instance_valid(cook.camp_work) and cook.camp_work.pot == kettle:
        cook.camp_work.respond_to_meal(action)

func build_camp() -> void:
    var host=state.region=="host"
    if hearth_access():
        station("chest",Vector2(840,770),"Open the wagon chest")
    var w=wagon(Vector2(740,690),0.76 if host else 0.65)
    if not host:
        family_wagon = w
        if not state.has("repaired"):
            family_wagon.rotation = deg_to_rad(-4)
            family_wagon.modulate = Color("b7a38b")
    if not host and state.chapter>=4:w.modulate=Color("554a41")
    tent(Vector2(1300,710))
    camp_item("provisions",Vector2(650,1000),Rect2(804,665,710,325),0.28,Vector2(150,40),Vector2(0,-16))
    build_pot(Vector2(1050,1050), state.region)
    if not host and state.chapter < 4 and audio_output_enabled:
        hearth_audio = HearthAudio.new()
        region_root.add_child(hearth_audio)
        hearth_audio.start(self, camp_pot.global_position)
    offering_stone = OfferingStone.new()
    offering_stone.position = Vector2(1190, 1080)
    offering_stone.offered = state.has("offering")
    world.add_child(offering_stone)
    station("offering",Vector2(1190,1115),"Look at Sava's offering" if offering_stone.offered else "Set a meal on Sava's stone")
    if not host:
        station("repair",Vector2(740,770),"Inspect the repaired axle" if state.has("repaired") else "Fit the wagon axle · 6 timber")
        station("provisions",Vector2(650,1050),"Take the family's cooking supplies")
        if state.chapter<4:
            for id in ["bramm","svala","gorund","dorrik","astrid"]:
                npc(id)
            var cook = preload("res://scripts/chapter/svala_work.gd").new()
            npcs.svala.add_child(cook)
            npcs.svala.camp_work = cook
            cook.begin(npcs.svala, camp_pot)
            var wheelwright := preload("res://scripts/chapter/bramm_work.gd").new()
            npcs.bramm.add_child(wheelwright)
            wheelwright.actor = npcs.bramm
            npcs.bramm.camp_work = wheelwright
            if not state.has("repaired"):
                wheelwright.begin_wheel()
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
    station("chest",Vector2(990,790),"Open the caravan chest")
    # Reuse the old settlement's timber buildings for the smaller peoples' fixed post.
    for i in range(3):
        var building=preload("res://scripts/building.gd").new();building.kind=i;building.settlement_scale=Scale.SETTLEMENT_SCALE;building.position=[Vector2(620,620),Vector2(1400,640),Vector2(1760,1080)][i];world.add_child(building)
    for x in range(350,1900,85):world_prop("wall",Vector2(x,470))
    wagon(Vector2(650,1080),0.5);build_pot(Vector2(1160,1040), "trade")
    npc("eydis",Vector2(1380,920));station("trade",Vector2(1520,1010),"Trade · meat and hides")
    world_label("BLACKSTONE EXCHANGE",Vector2(1370,810))
func build_resources() -> void:
    var cycle=int(state.clock/480)
    var wood_positions = [Vector2(400,850),Vector2(885,810),Vector2(1475,900),Vector2(1880,800),Vector2(500,1220),Vector2(960,1180),Vector2(1500,1260),Vector2(1940,1170)]
    if state.region == "crossing":
        # The first three bundles belong to the family's wagon yard.
        wood_positions[0] = Vector2(635,860)
        wood_positions[1] = Vector2(530,820)
        wood_positions[2] = Vector2(445,885)
    for i in wood_positions.size():
        var pos: Vector2 = wood_positions[i]
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
    var wolf=Wolf.new();wolf.ogre_world=true;wolf.position=at;wolf.alpha=alpha;wolf.game=self;wolf.target=player;wolf.loot_id=id;wolf.set_meta("id",id)
    wolf.strike.connect(enemy_strike);wolf.slain.connect(enemy_slain);world.add_child(wolf);wolf.hp=state.encounters.get(id,wolf.hp);enemies.append(wolf)
func add_raider(id: String,at: Vector2,kind: String) -> void:
    if id in state.defeated:
        if state.field_cuts.has(id):
            spawn_cut(id)
        return
    var foe=Raider.new();foe.ogre_world=true;foe.kind=kind;foe.position=at;foe.game=self;foe.target=player;foe.set_meta("id",id)
    foe.strike.connect(enemy_strike)
    foe.slain.connect(enemy_slain)
    world.add_child(foe)
    if kind == "goblin":
        foe.maximum = 28.0
    foe.hp = minf(foe.maximum, state.encounters.get(id, foe.maximum))
    enemies.append(foe)
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
        var spr=Sprite2D.new();b.add_child(spr);BeastArt.pose(spr,0,0,maxf(Scale.COMPANION_HEIGHT,273*factor))
    return b
func build_home() -> void:
    wagon(Vector2(1800,1230),0.46);build_pot(Vector2(1940,1260), "home");station("home",Vector2(1800,1310),"Your household · rest, improve, or take the road")
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
    if not region in NAMES:return
    if not forced:
        if state.chapter in [4,5]:say("Your clan is still fighting. Finish what you can here.");return
        if region in ["host","trade","pass"] and state.chapter<6:say("Stonebelly warriors hold that road. Your family needs you at Emberhide Crossing.");return
        if state.chapter==3 and state.has("ready") and state.region=="crossing":state.mark("departed")
        if region=="crossing" and state.chapter==3 and state.has("departed"):state.chapter=4;state.defense_left=100
    save_progress()
    state.hp=player.hp;state.region=region;state.player_position=spawn;rebuild();save_progress()
    say(NAMES[region].capitalize()+" · J opens your journal and the routes.")
    if region == "crossing" and state.has("hunt_won") and state.chapter == 2:
        say("Svala needs two cuts for the feast. Bramm can trade your amber or sew the hides into more pack slots at the wagon chest.")
    if state.chapter==4 and not state.has("burning_seen"):state.mark("burning_seen");dialogue("burning")
func road_arrival(routes: Dictionary,destination: String) -> Vector2:
    for road in routes[destination]:
        if road[0]==state.region:
            return {"north":Vector2(1080,280),"south":Vector2(1080,1150),"east":Vector2(1980,900),"west":Vector2(280,900)}[road[1]]
    return Vector2(1080,1090)
func interaction_available(entry: Dictionary) -> bool:
    match entry.kind:
        "field_find":return state.treasure.items.get(entry.id,{}).get("place","") == "field"
        "wood","ore":return not entry.id in state.collected
        "rescue":return state.chapter==4 and not state.has("saved_"+entry.id)
        "feast":return state.chapter==2 and not state.has("feast")
        "harvest":return not ("loot_"+entry.id) in state.collected
        "goblin_cut":return state.field_cuts.has(entry.id)
    return true
func update_nearest() -> void:
    nearest={};var best=125.0
    for entry in stations+supplies:
        if not interaction_available(entry):continue
        var distance=player.position.distance_to(entry.position)
        if distance<best:nearest=entry;best=distance
    for id in npcs:
        var actor=npcs[id]
        if actor.hostile or actor.hp<=0:continue
        var distance=player.position.distance_to(actor.position)
        if distance<best:nearest={"kind":"npc","id":id,"position":actor.position,"text":"E  Speak with "+cast[id].name};best=distance

func build_ui() -> void:
    var layer=CanvasLayer.new();add_child(layer)
    speech = preload("res://scripts/chapter/camp_speech.gd").new()
    layer.add_child(speech)
    var top=panel(Vector2(514,16),Vector2(746,84));layer.add_child(top)
    var box=VBoxContainer.new();box.add_theme_constant_override("separation",5);top.add_child(box)
    hud=helper.words("",18);box.add_child(hud);objective=helper.words("",17,"e3bb78");objective.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;box.add_child(objective)
    var bottom=panel(Vector2(20,688),Vector2(795,88));layer.add_child(bottom)
    var lines=VBoxContainer.new();bottom.add_child(lines);prompt=helper.words("",20);lines.add_child(prompt);notice=helper.words("",15,"ccb68f");notice.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;notice.custom_minimum_size.x=720;lines.add_child(notice)
    modal=Control.new();modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);layer.add_child(modal);modal.hide()
    modal.visibility_changed.connect(func():
        top.visible = not modal.visible
        bottom.visible = not modal.visible)
func _process(delta: float) -> void:
    if leaving:return
    objective.text=story.objective()
    hud.text = "%s   ·   Health %d / 160   ·   Meals %d" % [NAMES[state.region], int(player.hp), state.inventory.meals]
    if state.fed > 0:
        hud.text += "   ·   Well fed %ds" % int(state.fed)
    if dialog_mode:
        reveal+=delta*48;dialog_text.visible_characters=int(reveal)
        return
    if modal.visible:return
    state.clock+=delta;state.fed=maxf(0,state.fed-delta);state.hp=player.hp
    var aim := get_global_mouse_position() - player.position
    player.track_combat_aim(aim, nearby_threat())
    player.block(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT), aim)
    update_nearest()
    prompt.text = interaction_prompt("WASD move   ·   Shift run   ·   E interact   ·   J journal   ·   I belongings   ·   Esc menu")
    if state.chapter==4:
        state.defense_left=maxf(0,state.defense_left-delta)
        if state.defense_left<=0:finish_defense()
    if caravan_active:escort_tick(delta)
    if state.chapter==1 and state.has("eaten") and state.has("offering"):
        state.chapter=2;state.mark("axe");say("The first portion is given. Bramm has found signs of a great predator in the Northern Pines.");save_progress()
    save_clock+=delta
    if save_clock>25:save_clock=0;save_progress()
func _unhandled_input(event: InputEvent) -> void:
    if leaving:return
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
        KEY_F:
            use_food_shortcut(KEY_F)
        KEY_C:
            use_food_shortcut(KEY_C)
        KEY_SPACE:player.dodge(Input.get_vector("move_left","move_right","move_up","move_down"))
        KEY_Q:
            state.hp=player.hp
            if state.eat():player.hp=state.hp;say("A warm meal: +65 health, three minutes of strength (+6 weapon damage).");play_sound("success")
            else:say("No meals. Cook two meat and one timber at a hearth.")
            save_progress()
        KEY_F5:say("Chapter saved." if save_progress() else "Save unavailable; your previous save is preserved.")
        KEY_J:journal()
        KEY_I:belongings()
        KEY_B:
            if state.has("home_packed") and state.region in ["host","crossing","trade"]:
                state.camp_region=state.region;state.flags["home_packed"]=false;state.player_position=player.position;rebuild();save_progress();say("Your household is settled beside the road.")
func interact(entry: Dictionary) -> void:
    if not interaction_available(entry):return
    match entry.kind:
        "chest":
            loot_menu.message = ""
            loot_menu.show_menu(true)
        "field_find":
            if state.treasure.move(entry.id,"field","pack"):
                loot_menu.selected = entry.id
                entry.label.hide()
                say("Packed %s. Press I to compare." % state.treasure.name_of(state.treasure.items[entry.id]))
            else:
                say("Your gear slots are full. Make room at the wagon chest.")
        "npc":story.talk(entry.id)
        "road":
            travel(entry.id,road_arrival(ROADS,entry.id))
        "wood","ore":
            if state.collect(entry.id, entry.kind, 2):
                entry.node.data.state = "collected"
                entry.node.refresh()
                play_sound("gather")
                say("Two lengths of timber." if entry.kind == "wood" else "Two pieces of ore.")
                if state.chapter == 0 and entry.kind == "wood":
                    say("That's enough timber. Take it to the family wagon." if state.inventory.wood >= 6 else "Timber for Bramm: %d of 6." % state.inventory.wood)
        "provisions":
            if state.collect("family_provisions","meat",8):say("Eight cuts from the family stores. Svala expects you to make them useful.")
            else:say("The family provisions are already in your pack.")
        "repair":
            if state.has("repaired"):say("A sound rear axle. Your timber is part of the wagon now.")
            elif state.pay({"wood":6}):
                state.mark("repaired");state.chapter=1;state.change("bramm","admiration",2)
                if state.has("contest"):state.inventory.meals+=1;state.change("dorrik","friendship",2);state.mark("contest_won")
                if npcs.has("bramm"):
                    npcs.bramm.route = cast.bramm.route
                    if npcs.bramm.camp_work != null:
                        npcs.bramm.camp_work.finish_repair()
                var settle = family_wagon.create_tween().set_parallel(true)
                settle.tween_property(family_wagon, "rotation", 0.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
                settle.tween_property(family_wagon, "modulate", Color.WHITE, 0.55)
                for station_info in stations:
                    if station_info.kind == "repair":
                        station_info.text = "E  Inspect the repaired axle"
                play_sound("gather")
                family_line("bramm", "Hear that? No creak. Wash up, lad.")
                say("The axle holds. Svala is at the cookfire.")
            else:say("Bring six lengths of timber to fit the axle. Look just left of the wagon.")
        "hearth":
            if entry.has("node") and state.stew_cut(entry.id):
                var hand: Vector2 = entry.node.to_local(player.global_position) + Vector2.UP * player.height * 0.53
                entry.node.set_servings(state.pot_servings[entry.id], true, hand)
                svala_at_hearth("deposit", entry.node)
                play_sound("success")
                if entry.id == "crossing" and npcs.has("svala") and not state.has("svala_goblin_stew"):
                    family_line("svala", "Leave the bone in. Your father likes the marrow.")
                    state.mark("svala_goblin_stew")
                say("Two portions of goblin stew. Ladle one for the road or leave it for the hearth.")
            elif entry.has("node") and state.ladle_stew(entry.id):
                served_from_pot(entry)
            elif entry.id == "yard":
                say("The cookpot is empty. Carry a cut from the goblin and return here.")
            else:
                cook_provisions(entry.get("node"))
        "goblin_cut":
            take_field_cut(entry, false)
        "offering":
            if state.has("offering"):say("Sava has received the first portion. The fire is tended.")
            elif state.pay({"meals":1}):
                state.mark("offering")
                offering_stone.offered = true
                entry.text = "E  Look at Sava's offering"
                state.change("svala","loyalty",2)
                say("A portion for Sava. Svala presses a coal into the traveling ember-pot.")
            else:say("Cook a meal first. Sava's portion comes from the same pot as yours.")
        "track":
            state.mark("track_"+entry.id);say(["Deep claw marks above your head. Bramm points toward the blood on the next tree.","Fresh blood, thick gray fur. The trail turns north through the needles.","Heavy tracks enter Wolfscar Hollow. The predator is close; ready your axe."][int(entry.id)])
        "harvest":
            if state.collect("loot_"+entry.id,"meat",6):
                state.inventory.hide+=2
                if entry.id=="hollow_alpha":state.inventory.trophy+=1;state.mark("hunt_won");state.change("bramm","admiration",3);state.change("dorrik","admiration",2)
                var first: String = ""
                var alpha: bool = entry.id == "hollow_alpha"
                if not state.has("first_hunt_find"):
                    first = "ring_mantle" if state.equipment.head == "iron_helm" else "road_helm"
                    state.mark("first_hunt_find")
                var bead: bool = alpha or first != "" or state.treasure.rng.randf() < 0.3
                if bead:
                    state.inventory.amber += 1
                var found := grant_find(entry.id,"alpha" if alpha else "wolf",Vector2(entry.position) if entry.has("position") else player.position,first)
                var spoils := "Six cuts and two hides"
                if alpha: spoils += ", the wolf's trophy"
                if bead: spoils += ", a bead of amber"
                say(spoils + ". " + ("A torn hunter's pack lies beside the kill. " + found if found != "" else "Take the meat home."))
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
        if not stations.any(func(e):return e.kind=="feast"):station("feast",Vector2(990,1170),"Prepare the clan feast · 2 meat")
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
            BeastArt.pose(beast.get_child(0),0,int((caravan.position.x-430)/160.0*4)%4,273*0.55)
    if caravan.position.x>=1810:
        caravan_active=false;state.mark("caravan_moved");state.chapter=maxi(8,state.chapter);state.inventory.coin+=8;state.change("thyra","admiration",2);say("The wagon clears the pass. Eight coin earned. Eydis has paid work at Blackstone, east of the Host.");save_progress()
func has_line(from: Vector2,to: Vector2,_ignored=null) -> bool:
    var q=PhysicsRayQueryParameters2D.create(from,to,1);return get_world_2d().direct_space_state.intersect_ray(q).is_empty()
func route_direction(actor: Node2D,dest: Vector2) -> Vector2:
    var direct=(dest-actor.position).normalized()
    for angle in [0.0,0.6,-0.6,1.15,-1.15]:
        var trial=direct.rotated(angle)
        if Scale.clear_step(actor,trial*85):return trial
    return Vector2.ZERO
var last_attacker
func nearby_threat() -> bool:
    return enemies.any(func(foe): return is_instance_valid(foe) and foe.hp > 0 and player.position.distance_squared_to(foe.position) <= 350.0 * 350.0)

func in_strike_path(actor, offset: Vector2, radius: float) -> bool:
    if actor.equipped_weapon == "hunting_axe":
        return Actor.CleaverStroke.reaches(offset, actor.locked, radius)
    return offset.length() < 121.0 + radius and actor.locked.dot(offset.normalized()) > 0.15

func strike_scenery(_actor) -> bool:
    return false

func player_strike(actor) -> void:
    var hit=false
    var met_armor := false
    for foe in enemies:
        if not is_instance_valid(foe) or foe.hp<=0:continue
        var off=foe.position-actor.position
        if in_strike_path(actor, off, Scale.body_radius(foe)) and has_line(actor.position,foe.position):
            var protected_target: bool = foe is Raider and foe.kind == "orc"
            met_armor = met_armor or protected_target
            var contact_height := Scale.LARGE_HEIGHT * 0.55 if protected_target else Scale.SMALL_HEIGHT * 0.54
            var contact_point: Vector2 = foe.position - Vector2(0, contact_height) - off.normalized() * 10.0
            impact(contact_point, actor.locked, protected_target)
            var amount: float = actor.weapon_damage(state.has("honed_axe")) + int(state.treasure.totals().damage) + (6 if state.fed > 0 else 0)
            if foe is Raider:
                foe.receive_weapon_hit(amount, off.normalized(), actor.equipped_weapon == "hunting_axe")
            else:
                foe.receive_hit(amount, off.normalized())
            hit = true
    var hit_wood := strike_scenery(actor)
    if hit:
        var heavy: bool = actor.equipped_weapon == "iron_maul"
        actor.contact_hold = 0.065 if met_armor else 0.055 if heavy else 0.033
        play_sound("maul" if heavy else "block" if met_armor else "cleave")
    elif hit_wood:
        actor.contact_hold = 0.045
        play_sound("wood_hit")
    else:
        play_sound("swing")

func impact(at: Vector2, direction: Vector2, on_iron: bool) -> void:
    if not combat_effects_enabled:
        return
    var effect := preload("res://scripts/chapter/strike_impact.gd").new()
    effect.position = at
    effect.z_index = 2
    effect.direction = direction
    effect.on_iron = on_iron
    effect.restrained = not state.gore
    world.add_child(effect)

func enemy_strike(foe) -> void:
    var off=player.position-foe.position
    var reach=220 if foe is Actor else 115 if foe is Wolf else 120
    var direction=foe.locked if foe is Actor else foe.locked_direction
    if off.length()>reach or direction.dot(off.normalized())<0.1 or not has_line(foe.position,player.position):return
    last_attacker=foe;play_sound("hit");player.receive_hit(maxi(1, (42 if foe is Actor else 22 if foe is Wolf else 18) - int(state.treasure.totals().guard)),off.normalized(),foe is Actor);state.hp=player.hp
func parry(_actor) -> void:
    if is_instance_valid(last_attacker):last_attacker.parried()
    say("Parried — strike while the weapon is checked.");play_sound("block")
func enemy_slain(foe) -> void:
    var id=foe.get_meta("id","")
    if id=="duel":
        state.mark("duel_won");state.change("hrothgar","admiration",5);dialogue("victory");return
    if id in state.defeated:return
    state.defeated.append(id)
    if not str(id).begins_with("practice_"):
        state.treasure.xp += 3 if id == "hollow_alpha" else 1
    if foe is Wolf:station("harvest",foe.position,"Harvest meat, hide and trophy",id)
    elif foe is Raider and foe.kind == "goblin":
        if id.begins_with("cairn"):
            state.inventory.coin += 2
        if foe.cleaved:
            var at: Vector2 = foe.position.lerp(player.position, 0.35)
            state.field_cuts[id] = [clampf(at.x, 60, 2200), clampf(at.y, 60, 1330)]
            spawn_cut(id)
            say("Fresh goblin meat. Move close to carry the cut or eat it here.")
    if foe is Raider and not str(id).begins_with("practice_"):
        if not state.has("first_raider_spoils"):
            state.mark("first_raider_spoils")
            state.inventory.amber += 1
            say("Amber from the raider’s purse. Worth four coin at the wagon chest." + (" E carries the cut; F eats it." if foe.cleaved else ""))
        var found := grant_find(id,"raider",foe.position)
        if found != "":
            say(found + (" E carries the cut; F eats it." if foe.cleaved else ""))
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
func toast(text: String,_at: Vector2) -> void:say(text.replace("Staggered • F from the side","Staggered — follow through"))
func hearth_cue(kind: String, at: Vector2) -> void:
    if is_instance_valid(hearth_audio):
        hearth_audio.cue(kind, at)

func play_sound(kind: String) -> void:
    if not audio_output_enabled or (not combat_effects_enabled and kind in ["hit", "block", "swing", "cleave", "maul", "wood_hit"]):
        return
    var files={"wood_hit":"camp/wood","maul":"audio/combat/maul","cleave":"audio/combat/cleave","hit":"camp/hit","block":"camp/metal","gather":"camp/wood","step":"camp/step","swing":"opener/swing","growl":"opener/growl","success":"opener/success"}
    if not leaving and kind in files and is_instance_valid(sfx):sfx.stream=load("res://assets/"+files[kind]+".wav");sfx.play()
func sound(kind: String) -> void:play_sound(kind)
func freeze(value: bool) -> void:
    player.enabled=not value
    for actor in npcs.values():
        actor.enabled = not value
        if value and actor.camp_work != null and actor.camp_work.has_method("pause_work"):
            actor.camp_work.pause_work()
    for foe in enemies:
        if foe is Actor:foe.enabled=not value
        else:foe.active=not value
func clear_modal() -> void:
    if is_instance_valid(speech):speech.hide()
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
    # Everyday conversation at the wheel or cookfire holds its speaker.
    # The other parent can still be seen working across the clearing.
    if state.region == "crossing" and key in ["bramm_work", "bramm_timber", "bramm_repaired", "svala_food", "svala_hearth"]:
        var neighbor: String = "svala" if person == "bramm" else "bramm"
        if npcs.has(neighbor) and npcs[neighbor].camp_work != null:
            npcs[neighbor].enabled = true
    var shade=ColorRect.new();shade.color=Color(0.03,0.025,0.02,0.25);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var illustration=line.get("art",scene.art)
    if illustration>=0:shade.color=Color(0.03,0.025,0.02,0.82)
    if illustration>=0 and ResourceLoader.exists(cinematic_texture_path()):
        var art=TextureRect.new();var atlas=AtlasTexture.new();atlas.atlas=load(cinematic_texture_path())
        var width=atlas.atlas.get_width()/2.0;var height=atlas.atlas.get_height()/3.0;atlas.region=Rect2((int(illustration)%2)*width,int(illustration/2)*height,width,height)
        art.texture=atlas;art.position=Vector2(250,130);art.size=Vector2(780,350);art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;modal.add_child(art)
    var box=panel(Vector2(20,495),Vector2(1240,288));modal.add_child(box)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",22);box.add_child(row)
    var portrait=TextureRect.new();portrait.custom_minimum_size=Vector2(170,210);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture=portrait_texture(person,line.expression);row.add_child(portrait)
    var column=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",8);row.add_child(column)
    column.add_child(helper.words(cast[person].name.to_upper()+"  ·  "+cast[person].role,19,"efc580"))
    var spoken: String = line.get("brutal_text",line.text) if state.gore else line.text
    dialog_text=helper.words(spoken.format({"clan": state.profile.clan_name, "name": state.profile.ogre_name}),21);dialog_text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;dialog_text.custom_minimum_size=Vector2(960,112);dialog_text.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(dialog_text);reveal=0;dialog_text.visible_characters=0
    dialog_buttons=HBoxContainer.new();dialog_buttons.add_theme_constant_override("separation",10);column.add_child(dialog_buttons)
    if index<scene.lines.size()-1:helper.action("Continue  ·  Space",advance_dialogue,dialog_buttons)
    else:
        for choice in story.choices_for(key):
            var action=choice[1];var button=helper.action(choice[0],func():choose(action),dialog_buttons);button.add_theme_font_size_override("font_size",17)
    column.add_child(helper.words("Space / Enter reveal and advance · Esc skips to the choices · F5 saves this moment",13,"b5ad98"))
    if npcs.has(person):npcs[person].face(player.position-npcs[person].position);npcs[person].show_frame(0)
    save_progress()
func portrait_texture(person: String,expression: String="neutral") -> Texture2D:
    var atlas = AtlasTexture.new()
    if portrait_data.has(person):
        var entry: Dictionary = portrait_data[person]
        var rect: Array = entry.get(expression, entry.neutral)
        atlas.atlas = load(entry.texture)
        atlas.region = Rect2(rect[0], rect[1], rect[2], rect[3])
        return atlas
    var path = "res://resources/chapter/" + person + ".json"
    if not FileAccess.file_exists(path):
        return null
    var data = JSON.parse_string(FileAccess.get_file_as_string(path))
    var frame = data.frames[0][0]
    var texture_path = "res://assets/chapter/" + person + "_nordic.png"
    if not ResourceLoader.exists(texture_path):
        texture_path = "res://assets/chapter/" + person + ".png"
    atlas.atlas = load(texture_path)
    atlas.region = Rect2(frame[0], frame[1], frame[2], frame[3] * 0.48)
    return atlas
func advance_dialogue() -> void:
    if not dialog_mode:return
    if dialog_text.visible_characters>=0 and dialog_text.visible_characters<dialog_text.text.length():reveal=100000;dialog_text.visible_characters=-1;return
    var scene=story.scenes[state.scene.key]
    if state.scene.cursor<scene.lines.size()-1:state.scene.cursor+=1;dialogue(state.scene.key,true)
    else:
        var choices: Array = story.choices_for(state.scene.key)
        if choices.size() == 1:choose(choices[0][1])
func finish_dialogue() -> void:
    var scene=story.scenes[state.scene.key]
    state.scene.cursor=scene.lines.size()-1;dialogue(state.scene.key,true);reveal=100000;dialog_text.visible_characters=-1
func choose(action: String) -> void:
    state.scene={};close_modal();story.action(action);save_progress()
func save_progress() -> bool:
    if not is_instance_valid(player):return false
    state.player_position=Vector2(clampf(player.position.x,60,2200),clampf(player.position.y,60,1330));state.hp=player.hp
    for foe in enemies:
        if is_instance_valid(foe):state.encounters[foe.get_meta("id","")]=foe.hp
    return state.save_game()
func simple_menu(title: String,copy: String) -> VBoxContainer:
    clear_modal();var shade=ColorRect.new();shade.color=Color(0.03,0.03,0.02,0.7);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var box=panel(Vector2(150,145),Vector2(980,520));modal.add_child(box);var col=VBoxContainer.new();col.add_theme_constant_override("separation",12);box.add_child(col)
    col.add_child(helper.words(title,27));var label=helper.words(copy,18);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.custom_minimum_size.x=920;col.add_child(label);return col
func toggle_brutality() -> void:
    state.gore = not state.gore
    for entry in supplies:
        if entry.kind == "goblin_cut":
            entry.node.set_restrained(not state.gore)
    save_progress()
    pause_menu()

func pause_menu() -> void:
    var col=simple_menu("THE FIRE WE CARRY","Your journey saves automatically. Press F5 to save on the road.")
    helper.action("Return to the fire",close_modal,col)
    helper.action("Journal and routes",journal,col)
    helper.action("Brutality: "+("full" if state.gore else "restrained"),toggle_brutality,col)
    helper.action("Save and return to title" if not state.unreadable else "Leave this unsaved visit",return_to_menu,col)
    helper.action("Save and quit" if not state.unreadable else "Quit without changing unreadable save",quit_game,col)
func fitting_preview(parent: Control, width: int, height: int, candidate: Dictionary = {}) -> Node2D:
    var view := Control.new()
    view.custom_minimum_size = Vector2(width,height + 27)
    view.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(view)
    var preview := Actor.new()
    preview.name = "EquippedOgre"
    preview.position = Vector2(width * 0.47,height + 19)
    preview.height = height
    preview.enabled = false
    preview.controlled = false
    view.add_child(preview)
    preview.collision_layer = 0
    preview.collision_mask = 0
    preview.set_hair_palette(state.profile.hair)
    var look: Dictionary = state.equipment.duplicate()
    if not candidate.is_empty():
        var base: Dictionary = state.treasure.base_of(candidate)
        look[base.slot] = base.visual
    preview.equip_weapon(look.weapon)
    preview.face(FITTING_VIEWS[fitting_angle])
    preview.action_pose(0)
    preview.equip_body(look.body)
    preview.equip_head(look.head)
    fit_insignia(preview,candidate)
    return preview

func belongings() -> void:
    var supplies := PackedStringArray()
    for item in state.inventory:
        if state.inventory[item] > 0:
            supplies.append("%s  %d" % [item.capitalize(), state.inventory[item]])
    var col = simple_menu("BELONGINGS", "%s  ·  %s\n%s" % [state.profile.ogre_name, state.profile.clan_name, "     ".join(supplies)])
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 20)
    col.add_child(row)
    var preview = fitting_preview(row,250,178)
    var gear = VBoxContainer.new()
    gear.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    gear.add_theme_constant_override("separation", 7)
    row.add_child(gear)
    var weapon: Dictionary = Actor.WEAPONS.data[player.equipped_weapon]
    gear.add_child(helper.words(weapon.label, 24, "efc580"))
    gear.add_child(helper.words("%s  ·  %s" % [ChapterState.HEADGEAR[player.equipped_head], ChapterState.BODYGEAR[player.equipped_body]], 17))
    var bonuses: Dictionary = state.treasure.totals()
    gear.add_child(helper.words("%d damage  ·  %.2f s per swing  ·  %d armor" % [player.weapon_damage(state.has("honed_axe")) + bonuses.damage + (6 if state.fed > 0 else 0), weapon.swing_seconds, bonuses.guard], 17))
    gear.add_child(helper.words(weapon.description, 16))
    var next_id = "iron_maul" if player.equipped_weapon == "hunting_axe" else "hunting_axe"
    var choices := HBoxContainer.new()
    choices.add_theme_constant_override("separation", 10)
    gear.add_child(choices)
    var weapon_button = helper.action("Equip " + Actor.WEAPONS.data[next_id].label.to_lower(), func(): change_equipment("weapon", next_id), choices)
    helper.action("Turn Ogre", func():
        fitting_angle = (fitting_angle + 1) % FITTING_VIEWS.size()
        preview.face(FITTING_VIEWS[fitting_angle])
        preview.action_pose(0), choices)
    var armor := HBoxContainer.new()
    armor.add_theme_constant_override("separation", 10)
    gear.add_child(armor)
    var helmet: bool = player.equipped_head == "iron_helm"
    var head_button = helper.action("Remove iron helm" if helmet else "Equip iron helm",
        func(): change_equipment("head", "bare" if helmet else "iron_helm"), armor)
    var body_id := "scale_mantle" if player.equipped_body == "fur" else "fur"
    var body_button = helper.action("Equip " + ChapterState.BODYGEAR[body_id].to_lower(),
        func(): change_equipment("body", body_id), armor)
    if state.has("earn_hunt_armor"):
        head_button.visible = helmet
        body_button.visible = body_id == "fur"
    var locked := not can_change_equipment()
    for button: Button in [weapon_button, head_button, body_button]:
        button.disabled = locked
    if locked:
        gear.add_child(helper.words("Finish your current action to change equipment.", 15))
    if not state.treasure.items.is_empty() or state.has("first_hunt_find"):
        helper.action("Compare hunt spoils",func(): loot_menu.message = ""; loot_menu.show_menu(),col)
    else:
        col.add_child(helper.words("Hunt for equipment, provisions and valuables.",16))
    if state.inventory.get("goblin_meat", 0) > 0:
        helper.action("Eat a goblin cut (+25 health)", func(): eat_carried_cut(); belongings(), col)
    helper.action("Return", close_modal, col)

func can_change_equipment() -> bool:
    return player.hp > 0 and player.attack_time <= 0 and player.dodge_time <= 0 and player.stun <= 0

func change_equipment(slot: String, id: String) -> void:
    if not can_change_equipment():
        return
    if state.has("earn_hunt_armor") and slot in ["head","body"] and id != ChapterState.DEFAULT_EQUIPMENT[slot]:
        return
    var old: String = state.treasure.worn(slot)
    if old != "" and not state.treasure.move(old,"worn","pack"):
        say("Free a gear slot before removing that piece.")
        return
    apply_equipment(slot,id)
    if not save_progress():
        say("Equipment changed for this visit. Your previous save is preserved.")
    belongings()

func apply_equipment(slot: String, id: String) -> void:
    match slot:
        "weapon":
            player.equip_weapon(id)
            state.set_weapon(player.equipped_weapon)
            player.ready_time = 0.85
        "head":
            player.equip_head(id)
            state.equipment.head = player.equipped_head
        "body":
            player.equip_body(id)
            state.equipment.body = player.equipped_body
        _:
            return
    fit_insignia(player)

func hearth_access() -> bool:
    return (state.region == "crossing" and state.chapter < 4) or state.region in ["host","trade"] or (state.has("own_wagon") and not state.has("home_packed") and state.camp_region == state.region)

func grant_find(id: String, source: String, at: Vector2, first := "", promised := "") -> String:
    if state.treasure.award(id,source,state.region,at,first,promised) == "":
        return ""
    var item: Dictionary = state.treasure.items[id]
    var title: String = state.treasure.name_of(item)
    if item.place == "field":
        place_find(id)
        return "%s is on the ground. Your gear slots are full." % title
    loot_menu.selected = id
    return "%s · %s. Press I to compare." % [state.treasure.DATA.data.rarities[item.rarity].label,title]

func place_find(id: String) -> void:
    var item: Dictionary = state.treasure.items[id]
    var at := Vector2(item.at[0],item.at[1])
    var title: String = state.treasure.name_of(item)
    var label := world_label(title,at-Vector2(0,36),Color(state.treasure.DATA.data.rarities[item.rarity].color))
    stations.append({"kind":"field_find","id":id,"position":at,"text":"E  Take "+title,"label":label})

func fit_insignia(actor, candidate: Dictionary = {}) -> void:
    for slot in ["head","body"]:
        var layer = actor.head_gear if slot == "head" else actor.body_gear
        if layer == null: continue
        var id: String = state.treasure.worn(slot)
        var mark := ""
        var item: Dictionary = state.treasure.items.get(id,{})
        if not candidate.is_empty() and state.treasure.base_of(candidate).slot == slot:
            item = candidate
        if not item.is_empty():
            var special: String = item.special
            if special != "":
                mark = state.treasure.DATA.data.specials[special].mark
        layer.set_insignia(mark)

func journal() -> void:
    var text=story.objective()+"\n\nAdventure level %d  ·  %d XP" % [state.treasure.level(),state.treasure.xp]
    if state.treasure.level() < 3:
        text += "  ·  Next level at %d XP" % (3 if state.treasure.level()==1 else 8)
    text += "\n\nROADS FROM HERE\n"
    for road in ROADS[state.region]:text+="%s: %s     "%[road[1].capitalize(),NAMES[road[0]].capitalize()]
    text+="\n\nEmberhide → Pines → Wolfscar Hollow. Pines → Goblin Cairn.\nStonebelly Host → Sundered Pass / Blackstone. Blackstone → Goblin Cairn.\n\n"
    if state.chapter>=6:text+="Bramm: %s. Dorrik: %s. Svala and Astrid escaped. Gorund fell in single combat.\n"%["escaped" if state.has("saved_bramm") else "fell defending the crossing","escaped" if state.has("saved_dorrik") else "fell holding the eastern path"]
    for id in ["astrid","runa","eydis"]:
        var rel=state.relationships[id];text+="%s: %s · admiration %d · loyalty %d\n"%[cast[id].name,"courting" if rel.courting else "acquainted" if rel.met else "not yet met",rel.admiration,rel.loyalty]
    var col=simple_menu("JOURNAL · CHAPTER ONE",text);helper.action("Return to the road",close_modal,col)
func home_menu() -> void:
    var col=simple_menu("YOUR HOUSEHOLD","A wagon, a fire, and a claim on your own future. Rest restores health. Add dry provision racks for six timber. You may settle in another safe region after traveling there.")
    helper.action("Open the wagon chest",func(): loot_menu.show_menu(true),col)
    helper.action("Rest beside your hearth",func():player.hp=160;state.hp=160;close_modal();save_progress(),col)
    helper.action("Build the provision racks · 6 timber",func():
        if state.has("platform"):say("Your provision racks are already built.")
        elif state.pay({"wood":6}):state.mark("platform");state.inventory.meals+=3;say("Dry provision racks and dry stores fitted. Three meals stocked.")
        else:say("Six timber needed.")
        state.player_position=player.position;close_modal();rebuild();save_progress(),col)
    helper.action("Pack for the road",func():state.mark("home_packed");state.player_position=player.position;close_modal();rebuild();say("Your household is packed. Press B in a safe region to settle it there.");save_progress(),col)
    helper.action("Return",close_modal,col)

func prepare_exit() -> void:
    director.finish();freeze(true)
    leaving=true;player.enabled=false;set_process(false)
    if is_instance_valid(hearth_audio):
        hearth_audio.stop()
    # Reuse the legacy campaign's proven audio-mixer shutdown interval.
    for child in get_children():
        if child is AudioStreamPlayer:child.stop();child.stream=null

func cinematic_texture_path() -> String:
    return "res://assets/chapter/cinematics_brutal_nordic.png" if state.gore else "res://assets/chapter/cinematics_nordic.png"

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
    CampGround.add_shadow(body, region.size.x * size, maxf(30.0, collision.y * 1.4))
    var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=collision;col.shape=shape;col.position=offset;body.add_child(col);world.add_child(body)
func panel(at: Vector2,size: Vector2) -> PanelContainer:
    var p=PanelContainer.new();p.position=at;p.size=size;p.add_theme_stylebox_override("panel",helper.style("211e19ed","93734a"));return p
func family_line(person: String, words: String) -> void:
    if state.region == "crossing" and state.chapter < 4 and npcs.has(person) and is_instance_valid(speech):
        speech.speak(npcs[person], words, npcs.values() + [player])

func say(text: String) -> void:notice.text=text
func return_to_menu() -> void:
    if leaving:return
    if not state.unreadable and not save_progress():say("Could not save; staying here to preserve your progress.");close_modal();return
    prepare_exit()
    await get_tree().create_timer(0.15).timeout
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
func quit_game() -> void:
    if leaving:return
    if not state.unreadable and not save_progress():say("Could not save; staying here to preserve your progress.");close_modal();return
    prepare_exit()
    await get_tree().create_timer(0.15).timeout
    get_tree().quit()
func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(player):quit_game()
func _exit_tree() -> void:
    for child in get_children():
        if child is AudioStreamPlayer:child.stop();child.stream=null
    helper.free()
