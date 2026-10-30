extends SceneTree
var world
func _initialize():call_deferred("run")
func frames(n):
    for i in n:await process_frame
func capture(name):
    await frames(8);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/chiefs032-visual/"+name+".png")
func run():
    world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(30)
    await capture("Creator");world.begin_character();await frames(40)
    await capture("Village")
    world.player.position=Vector2(550,420);world.camera.reset_smoothing();await frames(40);await capture("Door")
    world.enter_room(0);await frames(40);await capture("Hall")
    world.player.position=Vector2(768,495);world.hall_menu();await capture("Yrsa");world.close_modal()
    world.leave_room();world.enter_room(1);await frames(40);await capture("Forge")
    world.player.position=Vector2(768,495);world.forge_menu();await capture("Harn");world.close_modal()
    world.leave_room();world.built=3;world.add_modules(2);world.enter_room(2);await frames(40);await capture("Storehouse");world.store_menu();await capture("Storage");world.close_modal();world.leave_room()
    world.fire_menu();await capture("Fire");world.close_modal()
    world.inventory_menu();await capture("Inventory");world.close_modal()
    world.help_menu();await capture("Journal");world.close_modal()
    world.pause_menu();await capture("Pause");world.close_modal()
    world.player.position=world.worker.position+Vector2(50,40);world.interact();await capture("Bren")
    world.queue_free();await frames(4);quit()
