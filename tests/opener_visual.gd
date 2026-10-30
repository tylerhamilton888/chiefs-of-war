extends SceneTree
var world
func _initialize(): call_deferred("run")
func frames(n):
    for i in n: await process_frame
func capture(n):
    await frames(6)
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("CHIEFS_CAPTURE_DIR")+"/Chiefs-of-War-"+n+".png")
func run():
    world=load("res://scenes/opener.tscn").instantiate(); root.add_child(world)
    await frames(30)
    await capture("Creator")
    world.begin_character()
    await frames(60)
    await capture("Ancestral-Hearth")
    world.enter_room(0); await frames(30)
    await capture("Ash-Hall")
    world.hall_menu(); await capture("Yrsa")
    world.close_modal(); world.leave_room()
    world.player.position=Vector2(2930,800); world.camera.reset_smoothing()
    await frames(20); world.pause_actors(true)
    await capture("Greytooth")
    world.pause_menu(); await capture("Pause")
    world.queue_free(); await frames(4); quit()
