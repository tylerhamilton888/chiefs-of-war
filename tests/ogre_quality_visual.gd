extends SceneTree
var game
var output=OS.get_environment("CHIEFS_REVIEW_DIR")
var checks=0
var failures=0
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func check(value: bool,message: String) -> void:
    checks+=1
    if not value:failures+=1;push_error("OGRE VISUAL: "+message)
func shot(name: String) -> void:
    await frames(5);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output+"/quality-"+name+".png")
func run() -> void:
    DirAccess.make_dir_recursive_absolute(output)
    DirAccess.remove_absolute("user://fire_we_carry_v1.json")
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(50)
    game.reveal=10000;await shot("opening-dialogue");game.choose("work")
    game.state.chapter=10;game.state.mark("own_wagon");game.state.mark("saved_bramm");game.state.mark("saved_dorrik")
    game.travel("host",Vector2(1800,1300),true);game.freeze(true);game.camera.reset_smoothing();await shot("southern-hearth")
    game.travel("pines",Vector2(1080,180),true);game.freeze(true);game.camera.reset_smoothing();await shot("north-exit")
    game.travel("host",Vector2(1060,1080),true);game.freeze(true);game.camera.reset_smoothing();await shot("host")
    for key in game.story.scenes:
        game.dialogue(key);game.finish_dialogue();await frames(3)
        for button in game.dialog_buttons.get_children():
            check(Rect2(20,495,1240,288).encloses(button.get_global_rect()),key+" choice fits: "+button.text)
        check(game.dialog_text.get_line_count()*game.dialog_text.get_theme_font("font").get_height(21)<=game.dialog_text.size.y+4,key+" dialogue text fits")
    game.dialogue("gorund_feast");game.finish_dialogue();await frames(50);await shot("long-choices")
    game.choose("close");game.dialogue("challenge");game.reveal=10000;await frames(50);await shot("challenge")
    game.choose("close");game.journal();await shot("journal");game.close_modal()
    game.state.chapter=7;game.travel("pass",Vector2(1180,1090),true);game.freeze(true);game.camera.reset_smoothing();await shot("caravan")
    game.prepare_exit();game.queue_free();await frames(3)
    DirAccess.remove_absolute("user://ogre_frontier_v1.json")
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    game.travel("den",Vector2(1060,1040),true);game.freeze(true);game.camera.reset_smoothing();await shot("ridgeback")
    game.travel("forest",Vector2(730,900),true);await frames(5);game.freeze(true);game.camera.reset_smoothing();await shot("flint")
    game.state.animal.tamed=true;game.state.animal.harness=true;game.animal_menu();await shot("flint-menu");game.close_modal()
    game.travel("hearth",Vector2(1730,1300),true);game.freeze(true);game.camera.reset_smoothing();await shot("frontier-south")
    game.journal();await shot("frontier-journal");game.close_modal()
    game.prepare_exit();game.queue_free();await frames(3)
    print("OGRE VISUAL: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
