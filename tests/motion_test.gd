extends SceneTree
var checks:=0
var failures:=0
func _initialize(): call_deferred("run")
func check(ok: bool,msg: String):
    checks+=1
    if not ok: failures+=1; push_error(msg)
func frames(n):
    for i in n: await physics_frame
func run():
    var a=load("res://scripts/opener_actor.gd").new();a.controlled=false;root.add_child(a)
    for outfit in ["leather","iron"]:
        a.equip(outfit)
        check(a.walk_texture!=null and a.idle_texture!=null and a.attack_texture!=null,outfit+" imports every motion texture")
        for d in 4:
            a.facing=d;a.phase=0;a.show_locomotion(false)
            check(a.sprite.texture==a.idle_texture and is_equal_approx(a.sprite.position.y+(400-224)*a.sprite.scale.y,4.0),outfit+" idle remains at ground anchor")
        a.drive=Vector2.RIGHT;await frames(30)
        check(a.sprite.texture==a.walk_texture and a.phase>0,outfit+" movement selects advancing stride")
        a.drive=Vector2.ZERO;await frames(20)
        check(a.sprite.texture==a.idle_texture and a.phase==0,outfit+" stopping plants feet")
        var old_phase: float=a.phase;a.dodge(Vector2.RIGHT);await frames(6)
        check(a.phase==old_phase,outfit+" dodge does not accelerate walking")
        await frames(40);a.drive=Vector2.ZERO;a.attack(Vector2.LEFT);await frames(5)
        check(a.sprite.texture==a.attack_texture and a.facing==1,outfit+" attack changes to matched left-facing body")
        await frames(50)
        check(a.sprite.texture==a.idle_texture,outfit+" recovery returns to matching idle")
    print("MOTION CHECKS: %s; FAILURES: %s"%[checks,failures]);a.queue_free();await frames(2);quit(1 if failures else 0)
