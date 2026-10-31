extends SceneTree
const State=preload("res://scripts/chapter/state.gd")
var game
var checks=0
var failures=0
func check(value: bool,message: String) -> void:
    checks+=1
    if not value:failures+=1;push_error("CHAPTER CHECK: "+message)
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await physics_frame
func interact(kind: String,id: String="") -> void:
    for entry in game.stations+game.supplies:
        if entry.kind==kind and (id=="" or entry.get("id","")==id):game.interact(entry);return
    check(false,"Missing interaction "+kind+" "+id)
func kill(foe) -> void:
    foe.active=false
    while foe.hp>0:
        game.player.position=foe.position+Vector2(0,95);game.player.cooldown=0;game.player.attack_time=0
        game.player.attack(Vector2.UP);await frames(40)
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var legacy=FileAccess.open("user://wandering_hearth_v1.json",FileAccess.WRITE);legacy.store_string("preserve prior Ogre visit");legacy.close()
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    check(game.dialog_mode,"opening dialogue")
    check(game.state.gore and game.cinematic_texture_path().ends_with("cinematics_brutal.png"),"adult cinematic treatment is the default")
    game.state.gore=false;check(game.cinematic_texture_path().ends_with("/cinematics.png"),"restrained treatment selects separate artwork")
    game.state.gore=true
    check(game.npcs.size()==5,"five birth-clan characters")
    check(game.npcs.gorund.height>game.npcs.bramm.height,"ancient Ogre more imposing")
    game.finish_dialogue();game.choose("work");check(game.player.enabled,"skip restores control")
    check(game.state.chapter==0,"intro does not skip work")
    var start=game.player.position;game.player.controlled=false;game.player.drive=Vector2.RIGHT;await frames(12);game.player.drive=Vector2.ZERO;await frames(5)
    check(game.player.position.x>start.x+20,"physical movement")
    game.story.action("contest")
    for i in 3:game.interact(game.supplies[i])
    check(game.state.inventory.wood==6,"actual finite resources")
    game.interact(game.supplies[0]);check(game.state.inventory.wood==6,"no duplicate collection")
    interact("repair");check(game.state.chapter==1 and game.state.inventory.wood==0,"repair consumes timber and advances")
    check(game.state.has("contest_won") and game.state.inventory.meals==1,"contest pays once")
    interact("repair");check(game.state.inventory.meals==1,"repair not farmable")
    interact("provisions");check(game.state.inventory.meat==8,"family provisions")
    game.interact(game.supplies[0]);interact("hearth");check(game.state.inventory.meals==4,"cooked usable food")
    game.player.hp=90;game.state.hp=90;check(game.state.eat(),"can eat");game.player.hp=game.state.hp
    check(game.player.hp==155 and game.state.fed>0,"food heals and buffs")
    interact("offering");await frames(2);check(game.state.chapter==2,"first portion advances")
    game.story.action("hunt");game.travel("pines");await frames(2)
    check(game.npcs.has("dorrik"),"companion comes to hunt")
    for i in 3:interact("track",str(i))
    game.travel("hollow");await frames(2);check(game.enemies.size()==1,"tracks reveal alpha")
    var wolf=game.enemies[0];var health=wolf.hp
    wolf.active=false;game.player.position=wolf.position+Vector2(0,95);game.player.attack(Vector2.UP)
    await frames(6);check(wolf.hp==health,"strike has anticipation")
    await frames(15);check(wolf.hp<health,"strike connects at authored contact")
    var damaged=wolf.hp;await frames(20);check(wolf.hp==damaged,"one contact per swing")
    game.save_progress();var battle_save=State.new();battle_save.load_game();check(battle_save.encounters.hollow_alpha==damaged,"enemy health persists mid-combat")
    await kill(wolf);check("hollow_alpha" in game.state.defeated,"real combat kills wolf")
    interact("harvest","hollow_alpha");check(game.state.inventory.hide==2 and game.state.inventory.trophy==1,"harvest hide and trophy")
    var meat=game.state.inventory.meat;interact("harvest","hollow_alpha");check(game.state.inventory.meat==meat,"no duplicate harvest")
    game.travel("crossing");await frames(2);interact("feast");check(game.state.chapter==3,"earned feast")
    game.finish_dialogue();game.choose("close");game.story.talk("gorund");game.choose("ready");check(game.state.chapter==3,"attack waits for departure")
    game.travel("pines");game.travel("crossing");await frames(2);check(game.state.chapter==4 and game.dialog_mode,"return reveals burning camp")
    var left=game.state.defense_left;await frames(10);check(game.state.defense_left==left,"battle clock freezes during dialogue")
    game.choose("close")
    for foe in game.enemies:foe.active=false
    for foe in game.enemies:
        if foe.get_meta("id") in ["defense_0","defense_2"]:await kill(foe)
    interact("rescue","bramm");check(game.state.has("saved_bramm"),"Bramm saved by cleared rescue path")
    game.state.defense_left=0;await frames(2);check(game.state.chapter==5,"battle resolves")
    check(not game.state.has("saved_dorrik"),"unrescued Dorrik has different fate")
    game.finish_dialogue();check(game.dialog_text.text==game.story.scenes.challenge.lines[-1].brutal_text,"adult cinematic dialogue selected")
    game.choose("duel");await frames(2)
    var boss=game.npcs.hrothgar;boss.enabled=false;game.player.position=boss.position+Vector2(0,100);game.player.attack(Vector2.UP);await frames(40)
    check(boss.hp<620,"Hrothgar takes valid hits")
    game.player.receive_hit(1000,Vector2.DOWN);await frames(3);check(game.state.scene.key=="mercy","loss resolves through mercy")
    game.finish_dialogue();game.choose("join");check(game.state.chapter==6 and game.state.region=="host","join preserves story")
    game.choose("close");check(game.npcs.has("bramm") and not game.npcs.has("dorrik"),"rescues change later cast")
    check(game.npcs.has("runa") and game.npcs.has("thyra"),"new host cast")
    game.story.action("thyra");game.story.action("road");game.travel("pass");await frames(2)
    for i in 3:interact("rubble",str(i))
    check(game.state.inventory.ore==6,"real road clearing resources")
    interact("beast");check(game.state.has("beast_fed") and game.state.inventory.ore==3,"feed costs minerals")
    interact("escort");check(game.caravan_active,"physical caravan starts")
    var oldx=game.caravan.position.x;game.player.position=Vector2(2000,100);await frames(10);check(game.caravan.position.x==oldx,"escort waits for player")
    for i in range(120):game.player.position=game.caravan.position+Vector2(0,120);await physics_frame
    game.save_progress();var road_save=State.new();road_save.load_game();check(road_save.escort_x>430 and road_save.escort_x<1810,"partial caravan position persists")
    for i in range(830):game.player.position=game.caravan.position+Vector2(0,120);await physics_frame
    check(game.state.has("caravan_moved") and game.state.chapter==8,"physical wagon crosses pass")
    game.travel("trade");game.story.talk("eydis");game.choose("bargain");check(game.state.has("bargained"),"contract negotiation persists")
    game.travel("cairn");await frames(2)
    for foe in game.enemies:foe.active=false
    for foe in game.enemies:await kill(foe)
    check(game.contract_done(),"three actual goblin combats")
    game.travel("trade");game.story.action("payment");check(game.state.chapter==9,"contract paid")
    game.choose("close");var coins=game.state.inventory.coin;game.story.action("payment");check(game.state.inventory.coin==coins,"payment idempotent")
    for i in range(4):game.interact(game.supplies[i])
    game.story.action("wagon");check(game.state.chapter==10 and game.state.has("own_wagon"),"earned personal wagon opens sandbox")
    game.choose("close")
    game.travel("crossing");interact("pendant");game.travel("host");game.story.action("pendant");game.choose("close")
    check(game.state.eligible("astrid"),"Astrid activity opens optional courtship")
    check(not game.state.relationships.astrid.courting,"romance never automatic")
    game.story.action("court_astrid");check(game.state.relationships.astrid.courting,"explicit courtship choice")
    game.story.action("friend_astrid");check(not game.state.relationships.astrid.courting,"friendship choice respected")
    var interest=game.state.relationships.astrid.interest;game.story.action("court_astrid");check(game.state.relationships.astrid.interest==interest,"repeating courtship cannot farm interest")
    game.story.action("friend_astrid")
    game.dialogue("host_arrival");game.state.scene.cursor=1;check(game.save_progress(),"save mid-scene")
    var restored=State.new();check(restored.load_game(),"load chapter");check(restored.scene.cursor==1 and restored.chapter==10,"resume cursor and progress")
    check(restored.relationships.astrid.admiration>=3 and restored.has("saved_bramm"),"relationship and fate persistence")
    check(FileAccess.get_file_as_string("user://wandering_hearth_v1.json")=="preserve prior Ogre visit","old save untouched")
    game.choose("close")
    # Independent defense edge cases: front timed parry, sustained block, back hit, dodge.
    var actor=game.player;actor.position=Vector2(1080,1200);actor.hp=160;actor.attack_time=0;actor.cooldown=0;actor.stun=0
    actor.block(true,Vector2.RIGHT);actor.receive_hit(30,Vector2.LEFT);check(actor.hp==160,"timed front parry")
    actor.guard_age=0.5;actor.receive_hit(30,Vector2.LEFT);check(actor.hp==160 and actor.guard<100,"held block spends guard")
    actor.receive_hit(30,Vector2.RIGHT);check(actor.hp==130,"rear hit bypasses block")
    actor.block(false,Vector2.RIGHT);actor.stun=0;actor.dodge(Vector2.RIGHT);actor.receive_hit(30,Vector2.LEFT);check(actor.hp==130,"dodge avoids contact")
    # Valid exceptional victory follows the alternate scene, never invulnerable story armor.
    game.state.chapter=5;game.travel("crossing",Vector2(1100,950),true);await frames(2)
    boss=game.npcs.hrothgar;boss.enabled=false;boss.receive_hit(620,Vector2.RIGHT);check(game.state.has("duel_won") and game.state.scene.key=="victory","alternate victory resolution")
    game.finish_dialogue();game.choose("join");game.choose("close")
    var bad=FileAccess.open(State.SAVE,FileAccess.WRITE);bad.store_string("invalid chapter save");bad.close()
    var broken=State.new();check(not broken.load_game() and broken.unreadable,"malformed save detected");check(not broken.save_game(),"malformed save never overwritten")
    check(FileAccess.get_file_as_string(State.SAVE)=="invalid chapter save","malformed bytes preserved")
    var valid=restored.pack();check(restored.valid(valid),"valid save schema")
    var corrupt=valid.duplicate(true);corrupt.encounters.duel=-10;check(not restored.valid(corrupt),"negative enemy health rejected")
    corrupt=valid.duplicate(true);corrupt.relationships.astrid.interest="bad";check(not restored.valid(corrupt),"invalid relationship type rejected")
    corrupt=valid.duplicate(true);corrupt.region="missing";check(not restored.valid(corrupt),"invalid geography rejected")
    corrupt=valid.duplicate(true);corrupt.escort_x=9000;check(not restored.valid(corrupt),"invalid caravan position rejected")
    for id in game.cast:
        var art=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/"+id+".json"));check(art.frames.size()==3 and art.frames[0].size()==4,"directional cast frames: "+id)
        check(game.portrait_texture(id,"angry")!=null,"expression portrait: "+id)
    game.prepare_exit();await create_timer(0.2).timeout;game.queue_free();await frames(3)
    print("CHAPTER: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
