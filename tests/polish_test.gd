extends SceneTree
var world
var checks:=0
var failures:=0
func _initialize():call_deferred("run")
func frames(n):
    for i in n:await physics_frame
func check(ok: bool,message: String):
    checks+=1
    if not ok:failures+=1;push_error(message)
func menu_fits():
    await frames(5)
    check(world.modal.size.y<=760 and world.modal.position.y>=0,"menu fits the 1280x800 viewport: "+world.sheet_kind+str(world.modal.size))
func run():
    world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(5)
    world.player.controlled=false;world.created=true;world.built=3;world.add_modules(2)
    for i in 3:
        world.enter_room(i);await frames(5)
        var correct=true
        for node in world.interior.get_children():
            if node is StaticBody2D and node.has_meta("furnishing"):
                correct=correct and ((node.collision_layer!=0)==(node.get_meta("furnishing")==i))
        check(correct,"only current room furniture collides")
        world.player.drive=Vector2.UP;await frames(40);world.player.drive=Vector2.ZERO
        check(world.player.position.y<530,"central route reaches service in room "+str(i))
        world.fire_menu();await menu_fits()
        var start=world.modal.find_children("*","Button",true,false)[0]
        check(start.disabled,"indoor fire drill is visibly disabled")
        world.close_modal();world.leave_room()
    world.player.position=world.DORS(0)+Vector2(0,45);await frames(30)
    check(world.portals[0].openness>0.95,"front approach opens hall leaves")
    var approach=Node2D.new();world.add_child(approach);approach.global_position=world.portals[0].global_position+Vector2(0,-30);world.portals[0].target=approach;await frames(30)
    check(world.portals[0].openness<0.05,"back approach does not open hall")
    check(not world.portals[1].leaves[0].visible,"open forge frontage is not covered by doors")
    world.inventory_menu();await menu_fits()
    check(world.modal.find_children("*","Button",true,false)[0].disabled,"full-health provision action is disabled")
    world.close_modal();world.help_menu();await menu_fits();world.close_modal()
    world.pause_menu();await menu_fits();world.close_modal()
    world.enter_room(2);world.stored=5;world.state.timber=2;world.store_menu();await menu_fits()
    world.withdraw();check(world.state.timber==7 and world.stored==0,"polished store retains timber transfer")
    world.leave_room();world.enter_room(0);world.rewarded=false;await frames(3)
    check(not world.return_trophy.visible,"unearned trophy is hidden")
    world.rewarded=true;await frames(3);check(world.return_trophy.visible,"earned trophy appears in hall")
    world.queue_free();await frames(3)
    print("POLISH CHECKS: %s; FAILURES: %s"%[checks,failures]);quit(1 if failures else 0)
