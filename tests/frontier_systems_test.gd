extends SceneTree
const State=preload("res://scripts/frontier/state.gd")
const Contracts=preload("res://scripts/frontier/contracts.gd")
var game
var checks=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(value: bool,message: String) -> void:
    checks+=1
    if not value:failures+=1;push_error("FRONTIER SYSTEMS: "+message)
func frames(n: int) -> void:
    for i in n:await physics_frame
func button(prefix: String) -> void:
    for b in game.modal.find_children("*","Button",true,false):
        if b.text.begins_with(prefix):b.pressed.emit();return
    check(false,"missing menu action "+prefix)
func travel(region: String,at: Vector2=Vector2(1080,1090)) -> void:
    game.travel(region,at,true);await frames(3);game.player.controlled=false
func strike(foe,object=false) -> void:
    if not object:foe.active=false
    var count=0
    while (foe.data.hp if object else foe.hp)>0 and count<18:
        game.player.position=foe.position+Vector2(0,110);game.player.velocity=Vector2.ZERO
        check(game.player.request("heavy",Vector2.UP),"heavy attack accepted")
        await frames(105);count+=1
    check((foe.data.hp if object else foe.hp)<=0,"actual weapon contacts defeat "+str(foe.get_meta("id",foe.name)))
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    game.player.controlled=false;game.player.position=Vector2(440,1080)
    check(game.lift_cargo("first_log"),"begin lifting the initial trunk");await frames(60)
    check(game.state.cargo.get("id")=="first_log","lift commits the actual trunk")
    game.player.position=Vector2(690,940);check(game.unload(false),"deposit trunk at the wagon")
    check(game.state.inventory.wood==10 and game.state.has("transported"),"wood reaches household stores")
    await travel("forest",Vector2(700,850))
    game.interact({"kind":"ore","id":"mineral_1"});await frames(80)
    check(game.state.inventory.ore==4,"mineral work grants four ore")
    game.animal_menu();button("Offer mineral feed")
    check(game.state.animal.tamed and game.state.inventory.ore==2,"taming consumes mineral feed")
    await travel("blackstone",Vector2(1580,960));game.market_menu();button("Buy 2 hides")
    check(game.state.inventory.hide==2 and game.state.inventory.coin==4,"market terms match actual costs")
    game.animal_menu();button("Fit a hauling harness")
    check(game.state.animal.harness and game.state.inventory.wood==6,"Flint's harness consumes four timber and two hides")
    await travel("hearth",Vector2(1290,1130))
    game.state.cargo={"id":"haul_fixture","kind":"spoils","yield":{"meat":12,"hide":2}}
    game.animal_menu();button("Load what you are carrying")
    check(game.state.cargo.is_empty() and not game.state.animal.cargo.is_empty(),"loading transfers cargo without duplication")
    game.pet.position=Vector2(1300,1160);game.animal_menu();button("Haul to")
    await frames(900)
    check(game.state.animal.cargo.is_empty() and game.state.inventory.meat==12,"Flint physically reaches the wagon and unloads")
    game.interact({"kind":"hearth"});await frames(110)
    check(game.state.inventory.meat==8 and game.state.inventory.meals==5,"cooking spends ingredients and creates three meals")
    game.player.hp=80;check(game.eat_meal(),"eat action starts");await frames(70)
    check(game.player.hp==145 and game.state.fed>298 and game.state.inventory.meals==4,"meal heals, nourishes and is consumed once")
    game.state.inventory.wood=20;game.state.inventory.ore=20;game.state.inventory.hide=8
    game.build_upgrade("smoker",{"wood":6,"hide":2});await frames(110)
    check(game.state.has("smoker") and game.state.inventory.wood==14,"crafting completes once and spends materials")
    game.interact({"kind":"hearth"});await frames(110)
    check(game.state.inventory.meals==8,"smoke rack increases pot yield to four meals")
    # A charge has a real windup, can be snared, then exposes the flank.
    await travel("den",Vector2(900,1100))
    var beast=game.enemies[0];beast.position=Vector2(1300,1100);beast.cooldown=0
    await frames(2);check(beast.stage=="windup","distant beast telegraphs before charging")
    game.trap_position=beast.position+Vector2(-110,0);await frames(65)
    check(game.state.has("snared_beast") and beast.stage=="stunned","charging beast trips a physical snare")
    await strike(beast)
    check(beast.sprite.modulate==Color.WHITE,"dead ridgeback does not retain its hit flash")
    check(game.state.has("hunt_won") and game.state.encounters["ridgeback_1"]==0,"hunt victory is recorded")
    game.player.position=beast.position+Vector2(0,110);check(game.harvest("ridgeback_1"),"butchering the defeated beast begins");await frames(140)
    check(game.objects.has("spoils_ridgeback_1") and not game.harvest("ridgeback_1"),"hunt creates one transportable prize")
    var prize=game.objects["spoils_ridgeback_1"];game.player.position=prize.position+Vector2(0,50)
    check(game.lift_cargo(prize.id),"lift bound hunt spoils");await frames(60)
    await travel("hearth");game.unload(false)
    check(game.state.inventory.trophy==1 and game.state.inventory.meat>=32,"hunt rewards arrive through hauling")
    game.start_duel();button("Step into the circle");await frames(3)
    var champion=game.enemies.back();champion.enabled=false;champion.parried()
    game.player.position=champion.position+Vector2(-100,0)
    check(game.begin_clinch(champion),"staggered champion enters a contested clinch")
    check(not champion.visible and not game.player.visible,"clinch hides original bodies and telegraphs")
    game.execution_tick(0.9);game.clinch_input();game.finish_execution(true)
    check(game.state.has("clinch_won") and champion.hp==565 and champion.visible and game.player.visible,"timed clinch resolves once and restores both actors")
    check(game.begin_clinch(champion),"second clinch begins after recovery")
    var hp=game.player.hp;game.execution_tick(0.2);game.clinch_input();game.finish_execution(true)
    check(game.player.hp==hp-28 and not game.execution_busy,"mistimed clinch harms the player and returns control")
    await frames(30)
    check(game.contracts.accept("pass","rights"),"negotiate hunting rights")
    await travel("pass")
    for foe in game.enemies:foe.active=false
    for foe in game.enemies:await strike(foe)
    await strike(game.objects.rockfall,true)
    check(game.state.regional.pass_safe and game.contracts.ready("pass"),"real enemies and rockfall control pass safety")
    check(game.contracts.claim("pass") and game.state.has("hunting_rights"),"agreed rights are awarded")
    check(not game.contracts.claim("pass"),"completed contract cannot pay again")
    await travel("blackstone");check(game.trade_wagons.size()==2,"open road brings physical trade wagons")
    check(game.contracts.accept("bargain","license"),"baron's bargain unlocks after safe passage")
    await travel("ridge")
    for foe in game.enemies:foe.active=false
    for foe in game.enemies:await strike(foe)
    await strike(game.objects.tollgate,true)
    check(game.contracts.claim("bargain") and game.state.has("raid_license"),"tollhold victory enables the agreed license")
    await travel("dunmere");game.dunmere_menu();button("Negotiate protection")
    check(game.state.regional.protection=="protection" and game.enemies.size()==2,"protection creates real defenders' work")
    for foe in game.enemies:foe.active=false
    for foe in game.enemies:await strike(foe)
    game.state.day+=1
    check(game.contracts.tribute() and not game.contracts.tribute(),"fulfilled protection pays once per expedition")
    await travel("hearth");game.home_menu();button("Pack the household")
    check(game.state.packed and is_instance_valid(game.caravan),"packed household appears in the world")
    game.pet.position=game.player.position+Vector2(-150,80);await travel("blackstone")
    check(game.deploy_camp() and game.state.camp_region=="blackstone" and not game.state.packed,"household can settle at a new safe region")
    game.save_progress();var restored=State.new()
    check(restored.load_game() and restored.animal.harness and restored.has("hunt_won") and restored.camp_region=="blackstone","reload preserves home, companion and hunt")
    check(restored.contracts.bargain.status=="paid" and restored.regional.protection=="protection","reload preserves bargains and regional consequences")
    for choice in ["spare","tribute","raid","occupy"]:
        var s=State.new();s.mark("raid_license");var book=Contracts.new(s)
        if choice in ["raid","occupy"]:
            check(not book.settle(choice),choice+" requires defeating the actual defenders");s.mark("raid_won")
        check(book.settle(choice) and not book.settle(choice),choice+" has a durable single resolution")
    game.prepare_exit();game.queue_free();await frames(3)
    print("FRONTIER SYSTEMS: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
