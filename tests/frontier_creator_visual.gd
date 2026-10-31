extends SceneTree
var game
var output="/tmp/frontier-creator-review"
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func shot(name: String) -> void:
    await frames(8);await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output+"/creator-"+name+".png")
func run() -> void:
    if OS.has_environment("CHIEFS_REVIEW_DIR"):output=OS.get_environment("CHIEFS_REVIEW_DIR")
    DirAccess.make_dir_recursive_absolute(output);DirAccess.remove_absolute("user://ogre_frontier_v1.json")
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(12)
    game.player.controlled=false;game.open_creator(true)
    for index in range(4):
        game.creator_style.select(index);game.update_creator_preview(index);await shot(str(index))
    game.creator_name.text="Hrogar";game.creator_style.select(1);game.commit_creator();await frames(3)
    game.player.position=Vector2(1500,1000);game.camera.reset_smoothing();game.player.enabled=false;game.set_process(false)
    game.state.cargo={"id":"visual","kind":"log","yield":{"wood":8}}
    game.player.face(Vector2.RIGHT);game.player.weapon_pose(2);await shot("dark-log")
    game.state.cargo.clear();game.player.enabled=true
    game.add_small("creator_goblin",game.player.position+Vector2(75,0),"knife",0)
    var foe=game.enemies.back();foe.active=false;foe.vulnerable=2;game.state.ferocity=100
    game.overpower(true,true);game.execution_tick(0.23);await shot("dark-swallow")
    game.finish_execution(false)
    for style in ["gold","silver"]:
        game.player.apply_appearance(style);foe.vulnerable=2;game.state.ferocity=100
        game.overpower(true,true);game.execution_tick(0.23);await shot(style+"-swallow");game.finish_execution(false)
    game.prepare_exit();game.queue_free();await frames(3);quit()
