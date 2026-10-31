extends "res://scripts/chapter/chapter.gd"
## Sundered Frontier: the existing Ogre world, with a dedicated physical gameplay loop.
const FrontierState=preload("res://scripts/frontier/state.gd")
const Fighter=preload("res://scripts/frontier/player.gd")
const SmallFoe=preload("res://scripts/frontier/enemy.gd")
const GreatBeast=preload("res://scripts/frontier/monster.gd")
const Champion=preload("res://scripts/frontier/champion.gd")
const HeavyObject=preload("res://scripts/frontier/object.gd")
const Companion=preload("res://scripts/frontier/companion.gd")
const Atlas=preload("res://scripts/frontier/atlas.gd")
const TITLES={"hearth":"THE WANDERING HEARTH","forest":"ASHEN PINES","den":"RIDGEBACK HOLLOW","pass":"SUNDERED PASS","blackstone":"BLACKSTONE","dunmere":"DUNMERE","ridge":"THE TOLLHOLD"}
const PATHS={"hearth":[["forest","north"],["pass","east"],["blackstone","south"]],"forest":[["hearth","south"],["den","north"],["pass","east"]],"den":[["forest","south"]],"pass":[["forest","west"],["dunmere","east"],["ridge","north"],["blackstone","south"]],"blackstone":[["hearth","west"],["pass","north"],["dunmere","east"]],"dunmere":[["pass","west"],["blackstone","south"]],"ridge":[["pass","south"]]}
var contracts
var objects: Dictionary={}
var pet
var trade_wagons: Array=[]
var trap_position=Vector2.ZERO
var trap_node: Node2D
var contact_kind="light"
var execution_busy=false
var execution_kind=""
var execution_clock=0.0
var execution_target
var execution_sprite: Sprite2D
var execution_direction=Vector2.RIGHT
var execution_contact=false
var clinch_result=0
var restore_at=Vector2.ZERO
var defeat_lock=false
var feedback_clock=0.0
var shake=0.0
var route_labels: Array=[]
func _ready() -> void:
    get_tree().auto_accept_quit=false
    for key in {"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}:
        if not InputMap.has_action(key):
            InputMap.add_action(key);var event=InputEventKey.new();event.physical_keycode={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}[key];InputMap.action_add_event(key,event)
    state=FrontierState.new();var loaded=state.load_game();contracts=preload("res://scripts/frontier/contracts.gd").new(state)
    cast=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/cast.json"))
    seed_world();build_world();build_ui()
    sfx=AudioStreamPlayer.new();sfx.volume_db=-15;add_child(sfx);ambient=AudioStreamPlayer.new();ambient.stream=load("res://assets/opener/ambient.wav");ambient.volume_db=-25;add_child(ambient)
    if not "--test" in OS.get_cmdline_user_args():ambient.play()
    say("Your axe, two meals and a hearth. A whole trunk lies west of camp. Shoulder it and bring it to the wagon.")
    if not loaded:say("The frontier save is unreadable and has been preserved. This visit cannot overwrite it.")
    if "--startup-smoke" in OS.get_cmdline_user_args():get_tree().create_timer(2.0).timeout.connect(quit_game)
func seed_object(id: String,kind: String,region: String,at: Vector2,hp: float,rewards: Dictionary) -> void:
    if not id in state.objects:state.objects[id]={"kind":kind,"region":region,"position":[at.x,at.y],"hp":hp,"yield":rewards,"taken":false}
func seed_world() -> void:
    seed_object("first_log","log","hearth",Vector2(440,1030),1,{"wood":8})
    for i in range(3):seed_object("timber_%d_%d"%[state.day,i],"tree","forest",Vector2(490+i*430,980-i*135),85,{"wood":8})
    seed_object("rockfall","boulder","pass",Vector2(720,900),150,{"ore":6})
    seed_object("palisade","barricade","pass",Vector2(1420,890),100,{"wood":4})
    seed_object("tollgate","barricade","ridge",Vector2(1070,780),180,{"wood":6})
    seed_object("dunmere_store_a","barn","dunmere",Vector2(780,800),140,{})
    seed_object("dunmere_store_b","barn","dunmere",Vector2(1480,800),140,{})
func build_world() -> void:
    stations.clear();supplies.clear();npcs.clear();enemies.clear();objects.clear();trade_wagons.clear();route_labels.clear();pet=null;caravan=null
    region_root=Node2D.new();add_child(region_root);ground_state=WorldState.new();ground_state.terrain.clear()
    for x in range(2,71):
        for y in range(26,30):ground_state.terrain["%d,%d"%[x,y]]="earth"
    for x in range(31,36):
        for y in range(3,42):ground_state.terrain["%d,%d"%[x,y]]="earth"
    if state.region in ["hearth","blackstone","dunmere"]:
        for x in range(15,56):
            for y in range(20,37):ground_state.terrain["%d,%d"%[x,y]]="earth"
    ground_state.revision+=1
    var terrain=Terrain.new();terrain.state=ground_state;region_root.add_child(terrain);world=Node2D.new();world.y_sort_enabled=true;region_root.add_child(world)
    player=Fighter.new();player.game=self;player.position=state.player_position;player.felled.connect(player_felled);player.stepped.connect(func():sound("step"));world.add_child(player)
    camera=Camera2D.new();camera.zoom=Vector2.ONE*0.78;camera.offset=Vector2(0,-140);camera.position_smoothing_enabled=true;camera.position_smoothing_speed=10;camera.limit_left=0;camera.limit_top=0;camera.limit_right=2260;camera.limit_bottom=1408;player.add_child(camera)
    for rect in [Rect2(-40,-40,2340,100),Rect2(-40,1340,2340,100),Rect2(-40,0,100,1408),Rect2(2200,0,100,1408)]:
        var body=StaticBody2D.new();body.position=rect.get_center();var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=rect.size;col.shape=shape;body.add_child(col);region_root.add_child(body)
    for road in PATHS[state.region]:
        var at={"north":Vector2(1080,180),"south":Vector2(1080,1250),"east":Vector2(2080,900),"west":Vector2(180,900)}[road[1]]
        station("road",at,"Travel to "+TITLES[road[0]].capitalize(),road[0]);world_label(TITLES[road[0]],at-Vector2(0,70))
    for i in range(16):
        var x=190+(i%8)*275;var y=350+(i/8)*850
        if i%8 in [3,4]:continue
        world_prop("tree" if state.region in ["hearth","forest","den"] else "rock",Vector2(x+sin(i)*55,y))
    for id in state.objects:
        var d=state.objects[id]
        if d.region!=state.region or d.taken:continue
        var obj=HeavyObject.new();obj.id=id;obj.game=self;obj.data=d;objects[id]=obj;world.add_child(obj)
    if not state.packed and state.camp_region==state.region:build_frontier_camp()
    elif state.packed:
        caravan=wagon(player.position+Vector2(-330,110),0.52);caravan.collision_layer=0
    match state.region:
        "hearth":
            npc("runa",Vector2(1430,960));station("champion",Vector2(1770,850),"Challenge the Stonebelly champion")
            var champ=npc("hrothgar",Vector2(1770,800));champ.route=[]
        "forest":
            for i in range(3):
                var at=Vector2(900+i*260,1080-i*210);world_prop("rock",at-Vector2(75,0));station("track",at,"Read ridgeback sign %d / 3"%(i+1),str(i))
                world_label(["GOUGED BARK","SPLIT STONES","FRESH TUSK FURROWS"][i],at-Vector2(0,80),Color("bdb293"))
            if not state.animal.tamed:add_pet(Vector2(650,700))
            station("ore",Vector2(700,780),"Gather mineral feed", "mineral_%d"%state.day);world_prop("rock",Vector2(640,760))
            add_small("forest_goblin_%d"%state.day,Vector2(1700,1000),"knife",0)
        "den":
            world_prop("rock",Vector2(780,700));world_prop("rock",Vector2(1490,1020));world_label("THE RIDGEBACK'S GROUND",Vector2(1200,520))
            var b=GreatBeast.new();b.game=self;b.target=player;b.position=Vector2(1300,820);b.set_meta("id","ridgeback_%d"%state.day);b.strike.connect(enemy_strike);b.slain.connect(enemy_slain);world.add_child(b);enemies.append(b);b.hp=state.encounters.get(b.get_meta("id"),b.maximum)
            if b.hp<=0:b.stage="dead";add_harvest_station(b)
        "pass":
            for i in range(4):add_small("pass_%d"%i,Vector2(1120+(i%2)*180,760+(i/2)*180),"spear" if i<2 else "knife",i)
            if state.regional.pass_safe:build_trade_traffic()
            world_label("SAFE PASSAGE · CARAVANS RETURN" if state.regional.pass_safe else "BROKEN TRACK · GOBLIN SPEAR LINE",Vector2(1050,580))
        "blackstone":build_settlement(false)
        "dunmere":build_settlement(true)
        "ridge":
            for i in range(3):add_small("toll_%d"%i,Vector2(820+i*240,660),"orc",i)
            tent(Vector2(600,540),0.50);tent(Vector2(1550,530),0.50);world_label("THE RIVAL TOLLHOLD",Vector2(1100,430))
    if state.animal.tamed:add_pet(player.position+Vector2(-200,150))
    if not trap_position.is_zero_approx():draw_trap()
func npc(id: String,at: Vector2=Vector2.ZERO) -> Node2D:
    var actor=Actor.new();actor.identity=id;actor.game=self;actor.controlled=false;actor.height=cast[id].height;actor.position=at;actor.route=[];world.add_child(actor);npcs[id]=actor;return actor
func build_frontier_camp() -> void:
    wagon(Vector2(690,740),0.62);tent(Vector2(1290,700),0.50);hearth(Vector2(1030,1040))
    station("depot",Vector2(690,940),"Unload cargo / household stores")
    station("hearth",Vector2(1030,1100),"Cook at the hearth · 4 meat + 1 timber")
    station("home",Vector2(800,850),"Rest, improve and pack your hearth")
    if state.has("smoker"):camp_item("provisions",Vector2(1460,1030),Rect2(804,665,710,325),0.28,Vector2(90,35),Vector2(0,-10))
    if state.has("workbench"):world_prop("log",Vector2(1510,780));world_label("FORGE & HIDE BENCH",Vector2(1500,700))
func add_pet(at: Vector2) -> void:
    pet=Companion.new();pet.game=self;pet.position=at;world.add_child(pet)
func add_small(id: String,at: Vector2,role: String,slot: int) -> void:
    if state.encounters.get(id,1)<=0:return
    var foe=SmallFoe.new();foe.role=role;foe.kind="orc" if role=="orc" else "goblin";foe.game=self;foe.target=player;foe.position=at;foe.set_meta("id",id);foe.set_meta("slot",slot);foe.strike.connect(enemy_strike);foe.slain.connect(enemy_slain);world.add_child(foe);enemies.append(foe);foe.hp=state.encounters.get(id,foe.maximum)
func build_settlement(dunmere: bool) -> void:
    var Building=load("res://scripts/building.gd")
    for i in range(2):
        var b=Building.new();b.kind=i;b.position=Vector2(650+i*900,650);world.add_child(b)
    if dunmere:
        npc("bramm",Vector2(1120,850));station("dunmere",Vector2(1120,940),"Speak with Dunmere's reeve")
        var line="Stores burned. Doorways barred." if state.has("dunmere_raid") else "Ogre banners over the storehouses." if state.regional.dunmere_control=="ogre" else "The trade carts have returned." if state.regional.pass_safe else "Empty wheel tracks. The pass is shut."
        world_label(line,Vector2(1100,600));world_label("Prosperity %d · Resistance %d"%[state.regional.dunmere_prosperity,state.regional.dunmere_resistance],Vector2(1100,640))
        if state.has("raid_started") and not state.has("raid_won"):
            add_small("dunmere_guard_0",Vector2(910,1010),"orc",0);add_small("dunmere_guard_1",Vector2(1390,970),"orc",1)
        if state.regional.protection=="protection" and not state.has("protected_dunmere"):
            for i in range(2):add_small("protection_%d_%d"%[state.day,i],Vector2(1700,930+i*150),"knife",i)
        if state.has("dunmere_raid"):
            fire_column(Vector2(780,790));fire_column(Vector2(1480,790))
    else:
        npc("eydis",Vector2(1120,800));station("contracts",Vector2(1120,900),"Read contracts and negotiate payment")
        station("timber_yard",Vector2(500,1030),"Deliver whole timber to the sawyers")
        station("market",Vector2(1580,960),"Trade meat, hides and iron")
        world_label("BUSY MARKET · PASS OPEN" if state.regional.pass_safe else "CARAVANS OVERDUE",Vector2(1120,580))
    if state.regional.pass_safe:build_trade_traffic()
func build_trade_traffic() -> void:
    var cart=wagon(Vector2(350,1130),0.36);cart.collision_layer=0;trade_wagons.append(cart)
    var cart2=wagon(Vector2(1650,1130),0.36);cart2.collision_layer=0;trade_wagons.append(cart2)
func build_ui() -> void:
    super.build_ui()
    var controls=objective.get_parent().get_child(2)
    controls.text="WASD move   LMB cut   R / Shift+LMB heavy   RMB parry   Space dodge   F throw / clinch   G feed   E interact   Q meal   J journal"
func objective_text() -> String:
    if execution_busy and execution_kind=="clinch":return "CLINCH · F once when the ring turns gold · Timing beats mashing"
    if not state.has("transported"):return "SHOULDER THE LOAD · E at the trunk west of camp → carry it to the wagon → E to unload"
    if not state.has("hunt_won"):return "THE GREAT HUNT · Read signs in Ashen Pines → hunt Ridgeback Hollow → harvest and haul your prize"
    if not state.regional.pass_safe:return "THE TROUBLED PASS · Blackstone offers work. Break the rockfall and defeat the existing goblin spear line."
    if not state.has("dunmere_resolved"):return "A NAME ON THE FRONTIER · The route is open. Improve your kit, train Flint, or hear the baron's bargain."
    return "HUNT · FIGHT · FEAST · PROSPER · ROAM · Rest for another expedition; your regional decisions endure."
func _process(delta: float) -> void:
    if leaving:return
    hud.text="%s   HP %d / 180   Guard %d   Ferocity %d   Meals %d   %s"%[TITLES[state.region],player.hp,player.guard,state.ferocity,state.inventory.meals,"Nourished %ds"%int(state.fed) if state.fed>0 else "Appetite sharp"]
    objective.text=objective_text()
    if modal.visible:return
    state.clock+=delta;state.fed=maxf(0,state.fed-delta);state.animal.fed=maxf(0,state.animal.fed-delta);state.hp=player.hp
    if execution_busy:execution_tick(delta);return
    player.set_block(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT),get_global_mouse_position()-player.position)
    shake=maxf(0,shake-delta*25);camera.offset=Vector2(sin(state.clock*85)*shake,-140+cos(state.clock*70)*shake*0.5)
    nearest={};var best=130.0
    for entry in stations:
        var distance=player.position.distance_to(entry.position)
        if distance<best:nearest=entry;best=distance
    for id in objects:
        var obj=objects[id]
        if obj.data.taken or obj.data.kind not in ["log","spoils"]:continue
        var distance=player.position.distance_to(obj.position)
        if distance<best:nearest={"kind":"cargo","id":id,"position":obj.position,"text":"E  Shoulder "+("the whole trunk" if obj.data.kind=="log" else "the butchered prize")};best=distance
    if is_instance_valid(pet) and player.position.distance_to(pet.position)<best:nearest={"kind":"animal","position":pet.position,"text":"E  Flint · feed, train, command or load"}
    prompt.text=nearest.get("text","X set cargo down · T set snare · B deploy packed hearth · I equipment · J routes, contracts and deeds")
    if not state.cargo.is_empty():prompt.text+="   [CARRYING %s]"%state.cargo.kind.to_upper()
    for cart in trade_wagons:cart.position.x=320+fposmod(cart.position.x-320+delta*45,1650)
    if is_instance_valid(caravan):
        var dest=player.position+Vector2(-330,110)
        if caravan.position.distance_to(dest)>80 and is_instance_valid(pet) and pet.position.distance_to(player.position)<500:caravan.position=caravan.position.move_toward(dest,delta*105)
    save_clock+=delta
    if save_clock>25:save_clock=0;save_progress()
func _unhandled_input(event: InputEvent) -> void:
    if leaving:return
    if event is InputEventKey and event.pressed and not event.echo:
        if execution_busy:
            if execution_kind=="clinch" and event.keycode==KEY_F:clinch_input()
            return
        if event.keycode==KEY_ESCAPE:
            if modal.visible:close_modal()
            else:pause_menu()
            return
        if modal.visible:return
        match event.keycode:
            KEY_R:player.request("heavy",get_global_mouse_position()-player.position)
            KEY_SPACE:player.request("dodge",Input.get_vector("move_left","move_right","move_up","move_down"))
            KEY_F:overpower(false)
            KEY_G:overpower(true)
            KEY_E:
                if player.mode=="idle" and not nearest.is_empty():interact(nearest)
            KEY_Q:eat_meal()
            KEY_X:drop_cargo()
            KEY_T:place_trap()
            KEY_B:deploy_camp()
            KEY_J:journal()
            KEY_I:belongings()
            KEY_F5:say("Frontier saved." if save_progress() else "Could not save; prior file preserved.")
    elif event is InputEventMouseButton and event.pressed and not modal.visible and not execution_busy:
        if event.button_index==MOUSE_BUTTON_LEFT:player.request("heavy" if event.shift_pressed else "light",get_global_mouse_position()-player.position)
func freeze(value: bool) -> void:
    player.enabled=not value
    for actor in npcs.values():actor.enabled=not value
    for foe in enemies:
        if is_instance_valid(foe):
            if foe is Actor:foe.enabled=not value
            else:foe.active=not value
    if is_instance_valid(pet):pet.enabled=not value
func close_modal() -> void:modal.hide();dialog_mode=false;freeze(false)
func rebuild() -> void:
    if execution_busy:return
    trap_position=Vector2.ZERO
    if is_instance_valid(region_root):remove_child(region_root);region_root.queue_free()
    build_world()
func travel(region: String,spawn: Vector2=Vector2(1080,1090),forced: bool=false) -> void:
    if not region in TITLES or execution_busy or player.mode!="idle":return
    if not forced and danger_near(280):say("Make room before taking the road.");return
    if state.packed and (not is_instance_valid(pet) or pet.position.distance_to(player.position)>500):say("Wait for Flint and the wagon.");return
    save_progress();state.region=region;state.player_position=spawn;rebuild();save_progress();say("%s. Your household's ledger remembers what happened here."%TITLES[region].capitalize())
func danger_near(radius: float) -> bool:
    for foe in enemies:
        if is_instance_valid(foe) and foe.hp>0 and player.position.distance_to(foe.position)<radius:return true
    return false
func save_progress() -> bool:
    if not is_instance_valid(player):return false
    if execution_busy:return false
    state.hp=player.hp;state.player_position=Vector2(clampf(player.position.x,60,2200),clampf(player.position.y,60,1330))
    for foe in enemies:
        if is_instance_valid(foe) and not foe is Champion:state.encounters[foe.get_meta("id","")]=foe.hp
    return state.save_game()
func prepare_exit() -> void:
    if execution_busy:finish_execution(false)
    freeze(true);leaving=true;set_process(false)
    for child in get_children():
        if child is AudioStreamPlayer:child.stop();child.stream=null
func interact(entry: Dictionary) -> void:
    match entry.kind:
        "road":travel(entry.id)
        "cargo":lift_cargo(entry.id)
        "depot":unload(false)
        "timber_yard":unload(true)
        "home":home_menu()
        "hearth":
            if state.inventory.meat<4 or state.inventory.wood<1:say("The pot needs four meat and one timber. Unload your hunt at the wagon.");return
            player.start_action("cook",1.5,func():
                if state.cook():say("A pot of rich meat. %d meals ready."%(4 if state.has("smoker") else 3));sound("success");save_progress())
        "harvest":harvest(entry.id)
        "track":
            state.mark("track_"+entry.id);sound("gather")
            var clues=["Freshly torn bark: a ridgeback rubs its armored brow here. A frontal cut will glance off.","Its tracks bite deep. It commits its full weight to a charge. Dodge across its path; rocks can stop it.","The furrows turn north. A snare can trip a charge; the pale flank is exposed when it stumbles."]
            say(clues[int(entry.id)]);save_progress()
        "ore":
            if not state.has(entry.id):
                player.start_action("harvest",1.1,func():state.mark(entry.id);state.grant({"ore":4});say("Four mineral chunks. Flint eats stone; your family eats meat.");save_progress())
            else:say("This outcrop is worked. More mineral feed becomes available on the next expedition.")
        "animal":animal_menu()
        "contracts":contract_board()
        "market":market_menu()
        "dunmere":dunmere_menu()
        "champion":start_duel()
func lift_cargo(id: String) -> bool:
    if not id in objects or not state.cargo.is_empty() or player.mode!="idle":return false
    var obj=objects[id]
    if obj.data.taken or player.position.distance_to(obj.position)>140:return false
    var kind=obj.data.kind
    return player.start_action("lift" if kind=="log" else "harvest",0.8,func():
        if not is_instance_valid(obj) or obj.data.taken:return
        state.cargo={"id":id,"kind":kind,"yield":obj.data.yield.duplicate()};obj.data.taken=true;obj.refresh();sound("gather");say("Weight in your hands. Carry it to your wagon or load Flint. X sets it down.");save_progress(),0.7)
func drop_cargo() -> bool:
    if state.cargo.is_empty() or player.mode!="idle" or execution_busy:return false
    var at=player.position+player.direction()*75
    if not has_line(player.position,at):say("There is no room to set the load down there.");return false
    var c=state.cargo;var id=c.id
    state.objects[id]={"kind":c.kind,"region":state.region,"position":[clampf(at.x,80,2180),clampf(at.y,80,1310)],"hp":1,"taken":false,"yield":c.yield.duplicate()};state.cargo={}
    if objects.has(id):objects[id].queue_free()
    var obj=HeavyObject.new();obj.id=id;obj.game=self;obj.data=state.objects[id];objects[id]=obj;world.add_child(obj);save_progress();return true
func unload(timber_yard: bool) -> bool:
    if state.cargo.is_empty():
        if not timber_yard:belongings()
        else:say("Bring an intact trunk here. The timber contract pays for the heavy work.")
        return false
    if timber_yard:
        if state.cargo.kind!="log":say("The sawyers need whole timber, not meat.");return false
        contracts.event("timber_delivered");state.cargo.clear();say("The sawyers take the trunk. Your labor contract can now be claimed.")
    else:state.deliver(state.cargo);say("The load is in your household stores. Cook, craft, or trade it.")
    sound("gather");save_progress();return true
func add_harvest_station(foe) -> void:
    var id=foe.get_meta("id")
    if not state.has("harvested_"+id):station("harvest",foe.position,"Butcher ridgeback · bind the spoils for transport",id)
func harvest(id: String) -> bool:
    if state.has("harvested_"+id) or player.mode!="idle":return false
    if not state.encounters.get(id,1)<=0:return false
    return player.start_action("harvest",2.0,func():
        if state.has("harvested_"+id):return
        state.mark("harvested_"+id)
        var at=player.position+Vector2(85,0)
        seed_object("spoils_"+id,"spoils",state.region,at,1,{"meat":32,"hide":6,"bone":4,"trophy":1})
        var obj=HeavyObject.new();obj.id="spoils_"+id;obj.game=self;obj.data=state.objects[obj.id];objects[obj.id]=obj;world.add_child(obj)
        say("Thirty-two meat, six hides, bones and a trophy. E to shoulder the bound prize; Flint can haul it.");sound("gather");save_progress(),0.8)
func eat_meal() -> bool:
    if state.inventory.meals<=0 or not state.cargo.is_empty() or player.mode!="idle":return false
    return player.start_action("eat",0.95,func():
        state.hp=player.hp
        if state.eat():player.hp=state.hp;say("Fed: +65 health, +6 damage, faster guard recovery and steadier footing for five minutes.");sound("success");save_progress(),0.65)
func object_broken(id: String) -> void:
    if id=="rockfall":contracts.event("rockfall_cleared");say("The wheel track is open. Six chunks of ore pried loose.")
    if id=="tollgate":check_encounters()
    if id.begins_with("dunmere_store"):check_encounters()
func place_trap() -> bool:
    if player.mode!="idle" or not trap_position.is_zero_approx() or not state.cargo.is_empty():return false
    if not state.pay({"wood":2,"hide":1}):say("A heavy snare needs two timber and one hide. Eydis sells hides at Blackstone.");return false
    trap_position=player.position;draw_trap();say("Heavy snare set. Lure the ridgeback's charge across it.");save_progress();return true
func draw_trap() -> void:
    trap_node=Node2D.new();trap_node.position=trap_position;world.add_child(trap_node)
    var ring=Line2D.new();ring.width=4;ring.default_color=Color("b89559")
    for i in range(25):ring.add_point(Vector2.from_angle(TAU*i/24)*Vector2(60,30))
    trap_node.add_child(ring);world_label("HEAVY SNARE",trap_position-Vector2(0,70))
func trip_beast(foe) -> bool:
    if trap_position.is_zero_approx() or foe.position.distance_to(trap_position)>115:return false
    trap_position=Vector2.ZERO
    if is_instance_valid(trap_node):trap_node.queue_free()
    state.mark("snared_beast");return true
func player_contact(kind: String,spec: Dictionary) -> void:
    contact_kind=kind;var connected=false
    var amount=spec.damage+(6 if state.fed>0 else 0)+(5 if state.has("honed") else 0)
    for foe in enemies:
        if not is_instance_valid(foe) or foe.hp<=0:continue
        var off=foe.position-player.position
        var radius=52 if foe is GreatBeast else 28
        if off.length()<=spec.reach+radius and player.locked.dot(off.normalized())>0.12 and has_line(player.position,foe.position):
            foe.receive_hit(amount,off.normalized());impact(foe.position);connected=true
            if "hit_pause" in foe:foe.hit_pause=0.065 if kind=="heavy" else 0.035
    for id in objects:
        var obj=objects[id];var off=obj.position-player.position
        if obj.data.kind in ["log","spoils"] or obj.data.taken or obj.data.hp<=0:continue
        if obj.data.kind=="barn" and not state.has("raid_started"):continue
        if off.length()<spec.reach+40 and player.locked.dot(off.normalized())>0.15:
            # Contact point sits on the near surface, so the object's own collider doesn't occlude it.
            var near=player.position+off.normalized()*maxf(0,off.length()-75)
            if has_line(player.position,near):obj.damage(amount if kind=="heavy" else amount*0.25);connected=true
    if connected:
        player.hit_pause=0.065 if kind=="heavy" else 0.035;shake=5 if kind=="heavy" else 2.5;sound("hit")
        state.ferocity=minf(100,state.ferocity+(11 if kind=="heavy" else 7))
func can_enemy_attack(foe) -> bool:
    var count=0
    for other in enemies:
        if other!=foe and is_instance_valid(other) and other is SmallFoe and other.hp>0 and other.state in ["windup","attack"]:count+=1
    return count<2
func enemy_strike(foe) -> void:
    var off=player.position-foe.position
    var reach=235 if foe is Champion else 230 if foe is GreatBeast else 210 if foe.role=="spear" else 120
    var dir=foe.locked if foe is Champion else foe.locked_direction
    if off.length()>reach or dir.dot(off.normalized())<(-0.2 if foe is GreatBeast else 0.15) or not has_line(foe.position,player.position):return
    var damage=40 if foe is Champion else 46 if foe is GreatBeast and foe.stage=="charge" else 30 if foe is GreatBeast else 21 if foe.role=="spear" and foe.formation else 16
    last_attacker=foe;player.receive_hit(damage,off.normalized());sound("hit");state.hp=player.hp
func parry(_actor) -> void:
    if is_instance_valid(last_attacker):last_attacker.parried()
    state.ferocity=minf(100,state.ferocity+18);player.hit_pause=0.05;shake=3;sound("block");say("Perfect parry. F throws a staggered goblin; G feeds. Counter the champion with a heavy blow or clinch.")
func enemy_slain(foe) -> void:
    if foe is Champion:
        state.mark("champion_won");state.rep("stonebelly","strength",8);say("The champion yields. He grants you the name Bonehand, and iron for the next hunt.")
        if not state.has("champion_paid"):state.mark("champion_paid");state.grant({"ore":8,"coin":25})
        save_progress();return
    var id=foe.get_meta("id","");state.encounters[id]=0
    if foe is GreatBeast:state.mark("hunt_won");state.rep("stonebelly","strength",5);add_harvest_station(foe);say("The ridgeback is down. Harvest it, then bring the weight home.")
    else:
        if not state.has("loot_"+id):state.mark("loot_"+id);state.grant({"coin":2})
    check_encounters();save_progress()
func all_down(ids: Array) -> bool:
    for id in ids:
        if state.encounters.get(id,1)>0:return false
    return true
func check_encounters() -> void:
    if all_down(["pass_0","pass_1","pass_2","pass_3"]):contracts.event("pass_cleared")
    if all_down(["toll_0","toll_1","toll_2"]) and state.has("tollgate_broken"):contracts.event("tollhold_broken")
    if state.has("raid_started") and all_down(["dunmere_guard_0","dunmere_guard_1"]) and state.has("dunmere_store_a_broken") and state.has("dunmere_store_b_broken"):
        state.mark("raid_won");say("The defenders and storehouses are broken. Return to the reeve to take plunder or occupy Dunmere.")
    if all_down(["protection_%d_0"%state.day,"protection_%d_1"%state.day]):state.mark("protected_dunmere")
func start_duel() -> void:
    if danger_near(100) or execution_busy:return
    var col=simple_menu("THE STONEBELLY CHAMPION","He is ancient, enormous, and at the height of his strength. Block his blows, parry the committed strike, and break his guard. F during a stagger begins a contested clinch. Press F once when its ring turns gold.")
    helper.action("Step into the circle",func():
        close_modal()
        if npcs.has("hrothgar"):npcs.hrothgar.queue_free();npcs.erase("hrothgar")
        var foe=Champion.new();foe.game=self;foe.target=player;foe.position=Vector2(1720,870);foe.set_meta("id","champion");foe.struck.connect(enemy_strike);foe.felled.connect(enemy_slain);world.add_child(foe);enemies.append(foe);player.position=Vector2(1510,1000);player.hp=180;player.guard=100;say("The old Ogre waits for your first mistake."),col)
    helper.action("Another day",close_modal,col)
func player_felled(_actor) -> void:
    if defeat_lock:return
    defeat_lock=true;recover_defeat.call_deferred()
func recover_defeat() -> void:
    if execution_busy:finish_execution(false)
    if not state.cargo.is_empty():player.mode="idle";drop_cargo()
    save_progress();state.hp=120;state.ferocity=0;state.region=state.camp_region;state.player_position=Vector2(1060,1140);state.packed=false;rebuild();save_progress();say("You limp home. Your dropped load remains where you fell. Eat, prepare, and return.");defeat_lock=false
func overpower(feed: bool) -> bool:
    if player.mode!="idle" or execution_busy or not state.cargo.is_empty():return false
    var best=125.0;var target_foe=null
    for foe in enemies:
        if not is_instance_valid(foe) or foe.hp<=0:continue
        var distance=player.position.distance_to(foe.position)
        if distance<best and has_line(player.position,foe.position):target_foe=foe;best=distance
    if target_foe==null:return false
    if target_foe is Champion:
        if not feed and (target_foe.vulnerable>0 or state.ferocity>=45):return begin_clinch(target_foe)
        return false
    if not target_foe is SmallFoe or target_foe.role=="orc":say("That opponent is too large for this hold.");return false
    if target_foe.vulnerable<=0 and target_foe.hp>target_foe.maximum*0.35:say("Stagger him with a heavy blow or parry first.");return false
    var cost=25 if feed else 15
    if state.ferocity<cost:say("Build %d Ferocity through hits and counters."%cost);return false
    # Paired drawings use a side contact. Find a clear stance beside the real target.
    var sign=1 if target_foe.position.x>=player.position.x else -1
    var stance=target_foe.position-Vector2(sign*76,0)
    if not has_line(player.position,stance) or not has_line(stance,target_foe.position):return false
    state.ferocity-=cost;player.position=stance;execution_direction=Vector2(sign,0);execution_kind="feed" if feed else "throw";execution_target=target_foe;execution_clock=0;execution_contact=false;execution_busy=true;target_foe.held=true;target_foe.sprite.hide();player.sprite.hide()
    execution_sprite=Sprite2D.new();world.add_child(execution_sprite);execution_sprite.position=player.position
    return true
func begin_clinch(foe) -> bool:
    if execution_busy or foe.hp<=0 or player.hp<=0 or not state.cargo.is_empty():return false
    var sign=1 if foe.position.x>=player.position.x else -1
    var at=foe.position-Vector2(sign*110,0)
    if not has_line(player.position,at):return false
    player.position=at;execution_direction=Vector2(sign,0);execution_kind="clinch";execution_target=foe;execution_clock=0;execution_busy=true;execution_contact=false;clinch_result=0;player.sprite.hide();foe.sprite.hide()
    execution_sprite=Sprite2D.new();execution_sprite.position=player.position;world.add_child(execution_sprite)
    say("Hold your weight. F once when the ring turns gold.");return true
func clinch_input() -> void:
    if not execution_busy or execution_kind!="clinch" or clinch_result!=0:return
    clinch_result=1 if execution_clock>=0.82 and execution_clock<=1.14 else -1
    sound("block" if clinch_result==1 else "hit")
func execution_tick(delta: float) -> void:
    execution_clock+=delta
    if not is_instance_valid(execution_target):finish_execution(false);return
    var mirror=execution_direction.x<0
    if execution_kind=="clinch":
        var index=mini(3,int(execution_clock/0.32))
        if execution_clock>1.18:
            if clinch_result==0:clinch_result=-1
            index=(4 if execution_clock<1.43 else 5) if clinch_result==1 else (6 if execution_clock<1.43 else 7)
        Atlas.pose(execution_sprite,"clinch",index,170,mirror)
        var gold=execution_clock>=0.82 and execution_clock<=1.14
        prompt.text="F  DRIVE THROUGH NOW" if gold else "Wait for the gold opening…" if clinch_result==0 else "You turn his weight." if clinch_result==1 else "He has your balance."
        prompt.modulate=Color("ffd37c") if gold else Color.WHITE
        if execution_clock>1.65:finish_execution(true)
    else:
        var frame=mini(3,int(execution_clock/0.20));Atlas.pose(execution_sprite,"overpower",frame+(4 if execution_kind=="feed" else 0),170,mirror)
        if execution_kind=="throw" and execution_clock>=0.60 and not execution_contact:
            execution_contact=true;execution_target.position=player.position+execution_direction*105;execution_target.sprite.show();execution_target.launch(execution_direction);sound("hit");shake=5;state.mark("thrown")
        if execution_clock>=0.82:finish_execution(true)
func finish_execution(resolve: bool) -> void:
    var foe=execution_target;var kind=execution_kind
    execution_busy=false;execution_kind="";player.sprite.show();player.mode="idle";player.guarding=false
    if is_instance_valid(execution_sprite):execution_sprite.queue_free()
    prompt.modulate=Color.WHITE
    if is_instance_valid(foe):
        foe.sprite.show()
        if foe is SmallFoe:foe.held=false
        if resolve:
            contact_kind="heavy"
            if kind=="feed":
                foe.die(false);player.hp=minf(180,player.hp+38);state.ferocity=minf(100,state.ferocity+15);state.mark("battle_fed");sound("hit")
                for other in enemies:
                    if other is SmallFoe and other!=foe and other.hp>0 and other.position.distance_to(foe.position)<300:other.fear=1.1
                say("A short, savage mouthful. +38 health; nearby goblins recoil.")
            elif kind=="clinch":
                if clinch_result==1:
                    foe.parried();foe.receive_hit(85,execution_direction);state.ferocity=minf(100,state.ferocity+20);state.mark("clinch_won");say("You turned an elder's weight against him. Now strike.")
                else:player.receive_hit(28,-execution_direction);foe.stance="recover";foe.clock=0;say("He stole your footing. Recover before the maul follows.")
        elif foe is SmallFoe and foe.hp>0:foe.vulnerable=0.5
    execution_target=null;save_progress()
func simple_menu(title: String,copy: String) -> VBoxContainer:
    clear_modal();var shade=ColorRect.new();shade.color=Color(0.03,0.03,0.02,0.78);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);modal.add_child(shade)
    var box=panel(Vector2(100,115),Vector2(1080,550));modal.add_child(box)
    var scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;box.add_child(scroll)
    var col=VBoxContainer.new();col.size_flags_horizontal=Control.SIZE_EXPAND_FILL;col.add_theme_constant_override("separation",10);scroll.add_child(col)
    col.add_child(helper.words(title,27));var label=helper.words(copy,18);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.custom_minimum_size.x=1000;col.add_child(label);return col
func pause_menu() -> void:
    var col=simple_menu("BY THE WANDERING HEARTH","Sundered Frontier · Day %d\nYour frontier, narrative chapter and earlier campaigns keep separate saves."%state.day)
    helper.action("Return to the road",close_modal,col)
    helper.action("Journal, routes and contracts",journal,col)
    helper.action("Blood effects: "+("full" if state.gore else "restrained"),func():state.gore=not state.gore;save_progress();pause_menu(),col)
    helper.action("Save and return to title" if not state.unreadable else "Leave this unsaved visit",return_to_menu,col)
    helper.action("Save and quit" if not state.unreadable else "Quit without changing unreadable save",quit_game,col)
func belongings() -> void:
    var text=""
    for item in state.inventory:text+="%s %d    "%[item.capitalize(),state.inventory[item]]
    text+="\n\n%s · Nourishment adds 6 damage and guard recovery.\nCut: %.2fs windup / %d reach. Heavy: %.2fs windup / %d reach.\nF throws a staggered goblin (15 Ferocity); G feeds (25). Attacks that miss grant no Ferocity.\nT makes a heavy snare from 2 timber + 1 hide. X sets carried loads down."%[player.weapons[player.weapon].name,player.stats("light").windup,player.stats("light").reach,player.stats("heavy").windup,player.stats("heavy").reach]
    var col=simple_menu("BELONGINGS & EQUIPMENT",text)
    if state.has("maul"):
        helper.action("Equip "+("stonebreaker maul" if player.weapon=="axe" else "hunting axe"),func():player.weapon="maul" if player.weapon=="axe" else "axe";state.equipment=player.weapon;player.mode="idle";player.weapon_pose(0);save_progress();belongings(),col)
    helper.action("Return",close_modal,col)
func journal() -> void:
    var text=objective_text()+"\n\nROADS FROM HERE\n"
    for road in PATHS[state.region]:text+="%s: %s   "%[road[1].capitalize(),TITLES[road[0]].capitalize()]
    text+="\n\nCamp → Ashen Pines → Ridgeback Hollow. Camp → Blackstone → Sundered Pass → Dunmere.\nPass north → rival tollhold. Hrothgar's champion waits east of the original camp.\n\nCONTRACTS\n"
    for id in contracts.definitions:
        var c=state.contracts.get(id,{"status":"unsigned","term":"—"});text+="%s: %s · %s%s\n"%[contracts.definitions[id].title,c.status,c.term," · ready to claim" if contracts.ready(id) else ""]
    text+="\nREGION: trade %d · Dunmere prosperity %d · resistance %d · control %s\n"%[state.regional.trade,state.regional.dunmere_prosperity,state.regional.dunmere_resistance,state.regional.dunmere_control]
    for faction in state.reputation:
        var r=state.reputation[faction];text+="%s: reliability %d, strength %d, brutality %d, treachery %d\n"%[faction.capitalize(),r.reliability,r.strength,r.brutality,r.treachery]
    text+="\nRIDGEBACK: bait its charge into stone or a snare. Strike the flank after it stumbles. A maul can crack the brow.\nFLINT: mineral-fed pack companion; feed, harness, load, then command haul in your camp's region."
    var col=simple_menu("DEEDS, ROADS & BARGAINS",text);helper.action("Return",close_modal,col)
func home_menu() -> void:
    var col=simple_menu("A HEARTH THAT TRAVELS","Unload whole trunks and butchered prizes at the wagon. Rest after an expedition to renew wilderness resources; your contracts and political outcomes endure.\nRest costs one meal. Flint and a harness are needed to pack the wagon.")
    helper.action("Rest for the next expedition · 1 meal",func():
        if danger_near(400):say("Danger is too close to rest.");close_modal();return
        if not state.pay({"meals":1}):say("Cook a meal before resting for the next expedition.");close_modal();return
        state.day+=1;state.hp=180;player.hp=180;player.guard=100;state.fed=300;seed_world();close_modal();state.player_position=player.position;rebuild();save_progress();say("A new expedition. Fresh tracks in the forest; the frontier still bears your decisions."),col)
    if not state.has("smoker"):helper.action("Build a smoke rack · 6 timber + 2 hides",func():build_upgrade("smoker",{"wood":6,"hide":2}),col)
    if not state.has("workbench"):helper.action("Build the ironwork bench · 6 timber + 4 ore",func():build_upgrade("workbench",{"wood":6,"ore":4}),col)
    if state.has("workbench"):
        if not state.has("maul"):helper.action("Forge a stonebreaker maul · 8 ore + 2 hides",func():build_upgrade("maul",{"ore":8,"hide":2}),col)
        if not state.has("honed"):helper.action("Hone weapon edges · 3 ore + 2 timber",func():build_upgrade("honed",{"ore":3,"wood":2}),col)
    helper.action("Pack the household for the road",func():
        if not state.animal.tamed or not state.animal.harness:say("Flint needs to trust you and wear a hauling harness.");close_modal();return
        if danger_near(400):say("Clear the immediate ground before packing.");close_modal();return
        state.packed=true;state.animal.command="follow";state.player_position=player.position;close_modal();rebuild();save_progress();say("The household is packed. Flint draws the wagon behind you. B settles it in safe ground."),col)
    helper.action("Return",close_modal,col)
func build_upgrade(id: String,cost: Dictionary) -> void:
    close_modal()
    if state.has(id) or player.mode!="idle":return
    for item in cost:
        if state.inventory[item]<cost[item]:say("More materials needed: "+JSON.stringify(cost));return
    player.start_action("craft",1.6,func():
        if state.has(id) or not state.pay(cost):return
        state.mark(id);say("Built: "+id.replace("_"," ")+". Your work is part of the household.");sound("success");save_progress()
        if id in ["smoker","workbench"]:refresh_camp.call_deferred(),0.8)
func refresh_camp() -> void:
    player.mode="idle";state.player_position=player.position;rebuild()
func deploy_camp() -> bool:
    if not state.packed or player.mode!="idle" or execution_busy:return false
    if not state.region in ["hearth","forest","blackstone","dunmere","pass"] or danger_near(650):say("The household needs safe ground.");return false
    if state.region=="pass" and not state.regional.pass_safe:return false
    state.camp_region=state.region;state.packed=false;state.player_position=Vector2(1060,1140);rebuild();save_progress();say("Canvas raised. Fire lit. Your home is here now.");return true
func animal_menu() -> void:
    var a=state.animal
    var col=simple_menu("FLINT · STONE-EATER","A patient young pack beast with an iron-grey brow. He eats the minerals your household cannot.\nTrust %d / 100 · %s · %s\nHe can follow, wait, carry a whole prize, and haul it to a deployed wagon in this region."%[a.trust,"fed" if a.fed>0 else "ready for mineral feed","harness fitted" if a.harness else "no hauling harness"])
    if not a.tamed:
        helper.action("Offer mineral feed · 2 ore",func():
            if state.pay({"ore":2}):a.tamed=true;a.trust=25;a.fed=600;a.command="follow";save_progress();close_modal();say("Flint accepts your scent and falls in beside you.")
            else:say("Gather mineral feed at the outcrop beside him.");close_modal(),col)
    else:
        helper.action("Feed and build trust · 1 ore",func():
            if a.fed>600:say("He has had enough for now.");close_modal();return
            if state.pay({"ore":1}):a.fed=900;a.trust=mini(100,a.trust+10);save_progress()
            close_modal(),col)
        if not a.harness:helper.action("Fit a hauling harness · 4 timber + 2 hides",func():
            if a.trust>=20 and state.pay({"wood":4,"hide":2}):a.harness=true;state.mark("trained_flint");save_progress();say("He takes the harness calmly. Flint can now carry your spoils and draw the wagon.")
            else:say("Trust 20, four timber and two hides needed.")
            close_modal(),col)
        if a.harness:
            helper.action("Load what you are carrying",func():
                if a.cargo.is_empty() and not state.cargo.is_empty():a.cargo=state.cargo.duplicate(true);state.cargo.clear();save_progress();say("Flint takes the load. Your hands are free.")
                close_modal(),col)
            helper.action("Take Flint's load",func():
                if state.cargo.is_empty() and not a.cargo.is_empty():state.cargo=a.cargo.duplicate(true);a.cargo.clear();save_progress()
                close_modal(),col)
        for command in ["follow","stay","haul"]:
            helper.action(command.capitalize()+(" to this region's camp" if command=="haul" else ""),func():a.command=command;save_progress();close_modal(),col)
    helper.action("Return",close_modal,col)
func contract_board() -> void:
    var reaction="A strong back is worth coin. A reliable name is worth credit."
    if state.reputation.blackstone.reliability>=10:reaction="Your word opened the pass. You can demand coin where strangers get promises."
    if state.reputation.blackstone.treachery>10:reaction="The baron heard whose banner flies over Dunmere. No more favorable credit."
    var col=simple_menu("BLACKSTONE · CONTRACTS",reaction)
    for id in contracts.definitions:
        if id=="bargain" and not state.regional.pass_safe:continue
        helper.action(contracts.definitions[id].title+" · "+state.contracts.get(id,{"status":"available"}).status,func():contract_detail(id),col)
    helper.action("Return",close_modal,col)
func contract_detail(id: String) -> void:
    var def=contracts.definitions[id];var text=def.description
    if id in state.contracts:text+="\n\nSigned terms: "+state.contracts[id].term+". Status: "+state.contracts[id].status
    var col=simple_menu(def.title.to_upper(),text)
    if not id in state.contracts:
        for term in def.terms:
            var title=term.capitalize()+" · "+JSON.stringify(def.terms[term])
            if term=="license":title="15 coin + written noninterference at Dunmere"
            if term=="rights":title="Hunting rights + 20 coin + 4 hides"
            if id=="bargain" and term=="coin" and state.reputation.blackstone.reliability<10:continue
            helper.action(title,func():
                if contracts.accept(id,term):save_progress();contract_detail(id),col)
        helper.action("Refuse this contract",func():contracts.refuse(id);save_progress();contract_board(),col)
    elif contracts.ready(id):helper.action("Claim the agreed payment",func():
        if contracts.claim(id):sound("success");save_progress();say("The bargain is honored. Your payment is in the stores.")
        contract_detail(id),col)
    helper.action("Back to contracts",contract_board,col)
func market_menu() -> void:
    var price=14 if state.reputation.blackstone.treachery>10 else 10
    var col=simple_menu("BLACKSTONE · EXCHANGE","The road feeds this market. With safe passage, the butcher pays more for meat.\nA trophy earns 20 coin; ore and hides equip your camp and Flint.")
    helper.action("Sell 4 meat · %d coin"%(8 if state.regional.pass_safe else 4),func():
        if state.pay({"meat":4}):state.grant({"coin":8 if state.regional.pass_safe else 4});save_progress();say("Meat sold.")
        close_modal(),col)
    helper.action("Sell a trophy · 20 coin",func():
        if state.pay({"trophy":1}):state.grant({"coin":20});save_progress()
        close_modal(),col)
    helper.action("Buy 4 ore · %d coin"%price,func():
        if state.pay({"coin":price}):state.grant({"ore":4});save_progress()
        close_modal(),col)
    helper.action("Buy 2 hides · 8 coin",func():
        if state.pay({"coin":8}):state.grant({"hide":2});save_progress()
        close_modal(),col)
    helper.action("Return",close_modal,col)
func dunmere_menu() -> void:
    var text="The reeve sizes up your hands before he looks at your face. 'The baron's seal is his. These storehouses are ours.'\n"
    text+="'The carts are moving again. That is work we can pay for.'" if state.regional.pass_safe else "'The pass has taken our trade. We cannot pay from empty stores.'"
    text+="\nProsperity %d · Resistance %d · %s control"%[state.regional.dunmere_prosperity,state.regional.dunmere_resistance,state.regional.dunmere_control]
    var col=simple_menu("DUNMERE · THE PRICE OF STRENGTH",text)
    if state.has("raid_license") and not state.has("dunmere_resolved"):
        if state.has("raid_won"):
            helper.action("Collect the plunder and depart",func():resolve_dunmere("raid"),col)
            helper.action("Occupy the storehouses under your banner",func():resolve_dunmere("occupy"),col)
        else:
            helper.action("Demand tribute · food and coin; resistance will grow",func():resolve_dunmere("tribute"),col)
            helper.action("Negotiate protection · earn payment by defending Dunmere",func():resolve_dunmere("protection"),col)
            helper.action("Renounce the license and leave their stores intact",func():resolve_dunmere("spare"),col)
            helper.action("Take payment by force · defenders will resist",func():
                state.mark("raid_started");close_modal();state.player_position=player.position;rebuild();save_progress();say("Dunmere bars its doors. Defeat the defenders and break both marked storehouses."),col)
    if state.regional.protection!="none":helper.action("Collect this expedition's payment",func():
        if contracts.tribute():save_progress();say("The agreed payment is delivered.")
        else:say("No payment: a new day, safe passage and fulfilled protection are required. High resistance can end tribute.")
        close_modal(),col)
    helper.action("Return",close_modal,col)
func resolve_dunmere(choice: String) -> void:
    if contracts.settle(choice):close_modal();state.player_position=player.position;rebuild();save_progress();say("Dunmere remembers the terms. Its people and its economy will live with them.")
