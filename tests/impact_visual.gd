extends SceneTree
var world
var number:=0
var folder:=OS.get_environment("CHIEFS_REVIEW")
func _initialize():call_deferred("run")
func frames(n: int):
 for i in n:await process_frame
func record(n: int):
 for i in n:
  await frames(2);await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder+"/frame-%04d.png"%number);number+=1
func run():
 world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(8)
 world.created=true;world.forged=true;world.player.controlled=false;world.player.position=Vector2(870,970);world.camera.reset_smoothing()
 for w in world.wolves:w.set_physics_process(false)
 for r in world.raiders:r.set_physics_process(false);r.position=Vector2(3400,1300)
 world.tip_shown.raiders=true;world.say("Combat review: ordinary strikes, stagger, optional finisher.")
 var r=world.raiders[0];r.position=Vector2(950,970);r.home=r.position;r.cooldown=10;r.active=true;r.set_physics_process(true)
 await record(12)
 world.player.request_attack(Vector2.RIGHT);await record(20)
 world.player.request_attack(Vector2.RIGHT);await record(16)
 # Follow the physical recoil to reach the supported finisher range.
 world.player.position=r.position-Vector2(80,0)
 world.begin_execution(true);await record(30)
 world.player.equip("iron");world.player.position=Vector2(950,970)
 r=world.raiders[2];r.position=Vector2(870,970);r.home=r.position;r.cooldown=10;r.hp=60;r.vulnerable=1.65;r.active=true;r.set_physics_process(true)
 world.say("Iron outfit: mirrored rival-Orc execution and return to control.")
 await record(8);world.begin_execution();await record(30)
 for enemy in world.raiders:enemy.set_physics_process(false);enemy.visible=false
 world.forged=false;world.player.equip("leather");world.player.position=Vector2(870,970)
 var id=world.state.add_object("tree",Vector2(950,970));world.sync_props();await frames(3)
 world.say("Gathering review: contact, wood chips, tree fall, collectible timber.")
 for i in 4:
  world.player.request_attack(Vector2.RIGHT);await record(20)
 await record(25)
 world.queue_free();await frames(3);quit()
