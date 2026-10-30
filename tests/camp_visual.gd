extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
    for i in n: await process_frame
func run() -> void:
    var world=load("res://scenes/camp.tscn").instantiate()
    root.add_child(world)
    await frames(20)
    world.enter_room(0)
    await frames(25)
    get_root().get_texture().get_image().save_png(OS.get_environment("CHIEFS_CAPTURE_DIR")+"/Chiefs-of-War-Hall.png")
    world.hall_menu()
    await frames(5)
    get_root().get_texture().get_image().save_png(OS.get_environment("CHIEFS_CAPTURE_DIR")+"/Chiefs-of-War-Dialogue.png")
    world.close_modal(); world.leave_room()
    world.player.position=Vector2(540,550)
    world.player.attack(Vector2.RIGHT)
    await create_timer(0.48).timeout
    get_root().get_texture().get_image().save_png(OS.get_environment("CHIEFS_CAPTURE_DIR")+"/Chiefs-of-War-Strike.png")
    quit()
