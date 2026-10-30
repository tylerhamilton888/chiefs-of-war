extends SceneTree
var checks:=0
var failures:=0
var impacts:=0
func _initialize():call_deferred("run")
func frames(n: int):
 for i in n:await physics_frame
func check(ok: bool,message: String):
 checks+=1
 if ok:print("PASS: "+message)
 else:failures+=1;push_error("FAIL: "+message)
func run():
 var actor=load("res://scripts/opener_actor.gd").new();actor.controlled=false;root.add_child(actor)
 actor.impact.connect(func(_direction):impacts+=1)
 await frames(3)
 actor.request_attack(Vector2.RIGHT);await frames(10)
 check(impacts==0,"axe windup cannot damage before visible contact")
 await frames(6)
 check(impacts==1,"axe contact arrives within a quarter second")
 await frames(30)
 check(impacts==1 and actor.attack_time==0,"one swing has one impact and a bounded recovery")
 actor.request_attack(Vector2.RIGHT);await frames(5);actor.dodge(Vector2.DOWN);await frames(40)
 check(impacts==1,"dodge cancels windup without ghost damage")
 actor.cancel_action();actor.dodge_cooldown=0;actor.dodge(Vector2.RIGHT);await frames(7)
 actor.request_attack(Vector2.LEFT);await frames(25)
 check(impacts==2 and actor.attack_direction==Vector2.LEFT,"click during late dodge queues the aimed follow-up")
 actor.cancel_action();actor.action_locked=true;actor.request_attack(Vector2.RIGHT);await frames(20)
 check(impacts==2 and actor.buffered==0,"menus and work locks do not accumulate delayed swings")
 actor.action_locked=false;actor.hit_stop=0.1;actor.cancel_action()
 check(actor.hit_stop==0,"cancellation clears impact freeze immediately")
 actor.queue_free();await frames(3)
 var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(5)
 world.created=true;world.player.controlled=false;world.player.position=Vector2(870,970)
 var tree=world.state.add_object("tree",Vector2(950,970));world.sync_props();await frames(12)
 check(world.props[tree].sprite.modulate.a<0.5,"nearby canopy reveals the player and axe during side-on chopping")
 world.player.request_attack(Vector2.RIGHT);await frames(10)
 check(world.state.objects[tree].hp==100,"gathering damage waits for axe contact")
 await frames(8)
 check(world.state.objects[tree].hp==75,"one visible axe impact removes exactly one wood damage step")
 world.queue_free();await frames(3)
 print("FEEL CHECKS: %s; FAILURES: %s"%[checks,failures]);quit(1 if failures else 0)
