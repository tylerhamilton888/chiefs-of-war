extends SceneTree
var game
var output="/tmp/hearth-review"
func _initialize() -> void:run.call_deferred()
func frames(count: int) -> void:
    for i in count:await process_frame
func shot(name: String) -> void:
    await frames(8);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output+"/chapter-"+name+".png")
func run() -> void:
    if OS.has_environment("CHIEFS_REVIEW_DIR"):output=OS.get_environment("CHIEFS_REVIEW_DIR")
    DirAccess.make_dir_recursive_absolute(output)
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game
    await frames(20);game.reveal=10000;await shot("dialogue")
    game.choose("work");await frames(5);await shot("crossing")
    game.player.position=Vector2(1400,980);game.camera.reset_smoothing();await shot("gorund")
    game.state.chapter=6;game.state.mark("saved_bramm");game.state.mark("saved_dorrik");game.travel("host",Vector2(1060,1080),true);await frames(20);await shot("host")
    game.dialogue("host_arrival");game.reveal=10000;await shot("host-dialogue");game.choose("close")
    game.state.chapter=5;game.travel("crossing",Vector2(1100,1050),true);game.freeze(true);await shot("duel")
    game.player.face(Vector2.RIGHT);game.player.action_pose(2);game.npcs.hrothgar.face(Vector2.LEFT);game.npcs.hrothgar.action_pose(1);await shot("strike")
    game.journal();await shot("journal");game.close_modal()
    game.prepare_exit();await create_timer(0.2).timeout;game.queue_free();await frames(3);quit()
