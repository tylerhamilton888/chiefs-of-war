extends SceneTree
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
    if not ok:failures+=1;push_error(message)
func run():
    var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
    for i in 6:await process_frame
    world.close_modal();world.pause_actors(true)
    var hero=world.player
    hero.action_locked=false;hero.controlled=false;hero.cancel_action()
    check(hero.begin_guard(Vector2.RIGHT),"Guard begins immediately from rest")
    check(hero.defend(Vector2.LEFT,25)=="hit","Back attacks bypass frontal guard")
    check(hero.defend(Vector2.RIGHT,25)=="parry","Timed frontal guard parries")
    check(hero.defend(Vector2.RIGHT,25)=="block","One press cannot parry twice")
    check(hero.guard==75,"Block consumes guard")
    hero.end_guard();hero.begin_guard(Vector2.RIGHT)
    check(hero.parry_time==0,"Rapid guard tapping cannot rearm parry")
    hero.guard=10
    check(hero.defend(Vector2.RIGHT,25)=="break" and not hero.guarding,"Guard exhaustion breaks defense")
    check(not hero.begin_guard(Vector2.RIGHT),"Broken guard cannot immediately restart")
    hero.guard_break=0;hero.guard=100;hero.parry_cooldown=0;hero.begin_guard(Vector2.RIGHT)
    hero.dodge_cooldown=0;hero.dodge(Vector2.DOWN)
    check(not hero.guarding and hero.dodge_time>0,"Dodge cancels guard")
    hero.cancel_action();hero.attack_time=hero.swing_duration
    check(not hero.begin_guard(Vector2.RIGHT),"Committed attack windup cannot be canceled into guard")
    hero.attack_time=0.1;check(hero.begin_guard(Vector2.RIGHT),"Late recovery may cancel into guard")
    hero.cancel_action();check(not hero.guarding and hero.parry_time==0,"Pause and action cancellation clear guard")
    hero.parry_cooldown=0;hero.begin_guard(Vector2.RIGHT)
    var wolf=world.wolves[0];wolf.position=hero.position+Vector2(30,0);wolf.locked_direction=Vector2.LEFT
    var hp=world.hp
    check(world.defend_strike(wolf,26,18),"World resolves guarded strike")
    check(world.hp==hp and wolf.stagger>0,"Parry prevents damage and staggers attacker")
    for outfit in ["leather","iron"]:
        hero.equip(outfit)
        for facing in 4:
            hero.facing=facing
            for pose in 6:
                hero.show_defense(pose)
                check(hero.sprite.region_rect.has_area(),"Defensive pose has a full-body frame")
    world.queue_free()
    for i in 4:await process_frame
    print("DIRECTIONAL BLOCK / PARRY / BREAK / CANCEL / 48 POSES: ","PASS" if failures==0 else "FAIL")
    quit(1 if failures else 0)
