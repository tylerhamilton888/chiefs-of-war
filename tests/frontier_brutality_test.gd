extends SceneTree
const State=preload("res://scripts/frontier/state.gd")
var game
var checks=0
var failures=0
func check(ok: bool, label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error(label)
func frames(n: int) -> void:
    for i in n:await physics_frame
func _initialize() -> void:run.call_deferred()
func spawn_foe(id: String, offset: Vector2):
    game.add_small(id,game.player.position+offset,"knife",0)
    var foe=game.enemies.back();foe.active=false;return foe
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    game.player.controlled=false;game.player.position=Vector2(1250,1150)
    game.state.cargo={"id":"test_trunk","kind":"log","yield":{"wood":8}}
    var foe=spawn_foe("log_target",Vector2(170,0));var health=foe.hp
    check(game.player.combat_weapon()=="log","carried trunk selects log statistics")
    check(game.player.request("light",Vector2.RIGHT),"swing while carrying trunk")
    await frames(8);check(foe.hp==health,"log windup precedes impact")
    await frames(18);check(foe.hp<health,"log hits at its longer reach")
    var hit=foe.hp;await frames(40);check(foe.hp==hit,"one hit per trunk swing")
    check(game.state.cargo.get("id")=="test_trunk","swing preserves the physical trunk")
    check(game.drop_cargo(),"can put the same trunk down after fighting")
    check(game.state.cargo.is_empty() and game.state.objects.test_trunk.kind=="log","drop returns the trunk to world")
    foe.queue_free();game.enemies.erase(foe);await frames(2)
    var bite=spawn_foe("bite_target",Vector2(75,0));game.state.ferocity=100;game.player.hp=90
    check(not game.overpower(true),"healthy alert goblin cannot be eaten")
    bite.vulnerable=2;game.state.ferocity=0
    check(not game.overpower(true),"feeding requires earned Ferocity")
    game.state.ferocity=100
    check(game.overpower(true),"bite finisher starts on staggered goblin")
    game.execution_tick(0.23)
    check(game.execution_sprite.position.distance_to(game.player.position)<180,"feeding artwork is anchored at the actual player location")
    game.finish_execution(true)
    check(bite.hp==0 and game.player.hp==128,"bite defeats prey and restores health")
    check(game.state.encounters.get("bite_target",1)==0,"bite records defeat")
    bite.queue_free();game.enemies.erase(bite);await frames(2)
    var meal=spawn_foe("swallow_target",Vector2(75,0));meal.vulnerable=2;game.state.ferocity=100
    check(game.overpower(true,true),"whole swallow starts on staggered goblin")
    game.finish_execution(true)
    check(meal.hp==0 and meal.swallowed and not meal.visible,"swallowed goblin leaves no corpse")
    check(game.state.encounters.get("swallow_target",1)==0,"swallow records defeat")
    var saved=State.new();check(saved.load_game(),"load frontier save")
    check(saved.encounters.get("swallow_target",1)==0 and saved.objects.has("test_trunk"),"save retains defeat and dropped trunk")
    game.state.cargo={"id":"prize","kind":"spoils","yield":{"meat":10}}
    check(not game.player.request("light",Vector2.RIGHT),"animal spoils cannot be used as a trunk")
    game.state.cargo.clear()
    game.player.position=game.objects.test_trunk.position+Vector2(-30,0)
    check(game.lift_cargo("test_trunk"),"can begin lifting a dropped trunk")
    game.player.receive_hit(5,Vector2.LEFT);await frames(70)
    check(game.state.cargo.is_empty() and not game.state.objects.test_trunk.taken,"interrupted lift neither duplicates nor consumes cargo")
    game.player.mode="idle";game.player.position=Vector2(1250,1150);game.state.ferocity=100
    var thrown=spawn_foe("thrown_target",Vector2(75,0));thrown.vulnerable=2
    var struck=spawn_foe("throw_victim",Vector2(245,0));var victim_hp=struck.hp
    check(game.overpower(false),"throw starts on staggered goblin")
    game.execution_tick(0.61);thrown.active=true
    await frames(35)
    check(struck.hp<victim_hp,"thrown goblin collides with another enemy")
    check(not game.execution_busy,"throw releases control after recovery")
    var contract_state=State.new();var book=load("res://scripts/frontier/contracts.gd").new(contract_state)
    check(book.accept("pass","coin"),"accept pass contract")
    check(not book.claim("pass"),"cannot claim an unfinished contract")
    book.event("pass_cleared");book.event("rockfall_cleared")
    var coins=contract_state.inventory.coin
    check(contract_state.regional.pass_safe and book.claim("pass"),"actual road clearance enables payment")
    check(contract_state.inventory.coin>coins and not book.claim("pass"),"contract cannot pay twice")
    print("FRONTIER BRUTALITY: %d checks, %d failures"%[checks,failures])
    game.prepare_exit();game.queue_free();await frames(3)
    quit(1 if failures else 0)
