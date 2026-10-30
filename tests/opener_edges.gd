extends SceneTree
var world
var checks:=0
var failures:=0
func _initialize(): call_deferred("run")
func check(ok: bool,msg: String):
    checks+=1
    if ok: print("PASS: "+msg)
    else: failures+=1; push_error("FAIL: "+msg)
func frames(n: int):
    for i in n: await physics_frame
func key(code):
    var e=InputEventKey.new(); e.physical_keycode=code; e.pressed=true; world._unhandled_input(e)
func run():
    world=load("res://scenes/opener.tscn").instantiate(); root.add_child(world); await frames(4)
    world.created=true
    var rations: int=world.meat
    key(KEY_1); check(world.meat==rations,"full health cannot waste provisions")
    world.player.position=Vector2(2000,800); world.hp=66; world.character_name="Ash"
    check(world.save_game("user://edge_test.json"),"field save writes beyond old camp bounds")
    world.player.position=Vector2(600,500); world.hp=1
    check(world.load_game("user://edge_test.json") and world.player.position.x==2000 and world.hp==66,"field location and health restore without old-map clamping")
    var bad=JSON.parse_string(FileAccess.get_file_as_string("user://edge_test.json")); bad.opener.complexion=[]
    var f=FileAccess.open("user://bad_save.json",FileAccess.WRITE); f.store_string(JSON.stringify(bad)); f.close()
    check(not world.load_game("user://bad_save.json") and world.hp==66 and world.character_name=="Ash","malformed identity rejects save before any mutation")
    world.player.position=Vector2(990,850)
    world.player.request_attack(Vector2.UP); await frames(7); world.player.dodge(Vector2.RIGHT); await frames(45)
    check(world.training_hits==0,"dodge cancels uncommitted attack without late damage")
    world.player.position=Vector2(990,850); world.player.request_attack(Vector2.UP); await frames(8)
    world.pause_menu(); var attack: float=world.player.attack_time; await frames(40)
    check(world.player.attack_time==attack and world.training_hits==0,"pause freezes attack before contact")
    key(KEY_ESCAPE); await frames(40)
    check(world.training_hits==1,"resumed swing contacts once")
    world.held_attack=true; world.inventory_menu(); key(KEY_ESCAPE)
    check(not world.held_attack,"opening inventory clears held attack")
    world.enter_room(0); await frames(3)
    var active_furniture:=0
    for n in world.interior.get_children():
        if n is StaticBody2D and n.has_meta("furnishing") and n.collision_layer!=0: active_furniture+=1
    check(active_furniture==4,"hall furnishings have only their intended active collisions")
    world.leave_room()
    world.player.position=Vector2(200,650); world.start_drill(); await frames(3)
    check(world.drill>7 and FileAccess.file_exists("user://hearth_fire_checkpoint.json"),"fire drill checkpoints before its warning")
    key(KEY_G); await frames(510)
    check(world.drill<0 and not world.state.objects.pine_1.burning,"dousing cancels pending ignition")
    world.start_drill(); var target: String=world.drill_target; await frames(500)
    check(world.state.objects[target].burning,"warned intentional fire can ignite woodland")
    world.restore_fire(); await frames(4)
    check(not world.state.objects[target].burning and world.drill<0,"fire checkpoint restores pre-damage woodland")
    world.player.position=Vector2(2980,800); world.hp=1; world.hurt(28); await frames(4)
    check(world.hp==100 and world.player.position.x<1000 and world.modal.visible,"defeat returns safely with recovery explanation")
    check(world.character_name=="Ash" and world.meat==rations,"recovery preserves identity and provisions")
    key(KEY_ESCAPE)
    world.trophy=true; world.returned=false; world.claim_reward()
    check(not world.rewarded,"pelt cannot claim hunter-return reward before reunion")
    for w in world.wolves: w.active=false
    world.player.position=Vector2(2000,800); world.player.request_attack(Vector2.RIGHT); await frames(30); world.player.request_attack(Vector2.RIGHT); await frames(55)
    check(world.player.attack_time<=0,"buffered follow-up finishes without stuck attack state")
    print("OPENER EDGE CHECKS: %s; FAILURES: %s"%[checks,failures])
    world.queue_free(); await frames(4); quit(1 if failures else 0)
