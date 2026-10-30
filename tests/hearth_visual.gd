extends SceneTree
var out=OS.get_environment("CHIEFS_REVIEW_DIR")
func _initialize():call_deferred("run")
func frames(n):
    for i in n:await process_frame
func capture(name):
    await frames(5);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/"+name+".png")
func run():
    var menu=load("res://scenes/main_menu.tscn").instantiate();root.add_child(menu)
    await capture("hearth-menu")
    menu.queue_free();await frames(3)
    var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
    await frames(10)
    world.created=true
    if world.creator:world.dismiss_creator()
    world.player.position=Vector2(620,430);world.camera.reset_smoothing()
    await capture("hearth-world")
    world.pause_actors(true);world.player.cancel_action()
    for outfit in ["leather","iron"]:
        world.player.equip(outfit);world.apply_look()
        for direction in [0,1,2,3]:
            world.player.facing=direction;world.player.show_defense(0)
            await capture("guard-"+outfit+"-"+str(direction))
        world.player.facing=2;world.player.show_defense(3)
        await capture("dodge-"+outfit)
    world.enter_room(0);world.close_modal();world.pause_actors(true)
    await capture("hearth-yrsa")
    world.queue_free();await frames(4);quit()
