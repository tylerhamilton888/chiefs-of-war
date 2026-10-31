extends SceneTree
var output=OS.get_environment("CHIEFS_REVIEW_DIR")
func _initialize():call_deferred("run")
func frames(n: int):
    for i in n:await process_frame
func capture(name: String):
    await frames(4);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output+"/"+name+".png")
func run():
    change_scene_to_file("res://scenes/main_menu.tscn");await frames(8)
    await capture("ogre-title")
    change_scene_to_file("res://scenes/wandering_hearth.tscn");await frames(12)
    var world=current_scene;world.player.controlled=false;world.player.position=Vector2(940,810);world.camera.reset_smoothing()
    await capture("ogre-hearth")
    world.player.set_physics_process(false)
    for direction in 4:
        for step in 4:
            world.player.facing=direction;world.player.show_frame(step)
            await capture("ogre-%d-%d"%[direction,step])
    world.pause_menu();await capture("ogre-pause")
    current_scene.queue_free();await frames(4);quit()
