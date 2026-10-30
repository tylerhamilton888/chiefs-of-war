extends SceneTree
var world
func _initialize():call_deferred("run")
func frames(n: int):
 for i in n:await process_frame
func shot(name: String):
 await frames(2);await RenderingServer.frame_post_draw
 get_root().get_texture().get_image().save_png(OS.get_environment("CHIEFS_REVIEW")+"/"+name+".png")
func run():
 world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(8)
 world.created=true;world.forged=true;world.player.controlled=false;world.player.position=Vector2(870,970);world.camera.reset_smoothing()
 for w in world.wolves:w.set_physics_process(false)
 for r in world.raiders:r.set_physics_process(false);r.position=Vector2(3400,1300)
 var r=world.raiders[0];r.position=Vector2(950,970);r.active=true;r.vulnerable=1.65;r.pose(3)
 await frames(8)
 await shot("00-ready")
 world.begin_execution();world.set_process(false)
 for outfit in ["leather","iron"]:
  world.player.equip(outfit)
  for i in 6:
   world.execution_clock=[0.01,0.1,0.23,0.35,0.52,0.69][i];world.show_finisher()
   r.pose(3 if i<3 else 4 if i<5 else 5)
   await shot(outfit+"-"+str(i))
 world.end_execution();world.set_process(true);world.pause_menu();await shot("pause-menu")
 world.combat_menu();await shot("combat-menu")
 world.queue_free();await frames(3);quit()
