extends SceneTree
const State=preload("res://scripts/frontier/state.gd")
var failures=0
func check(ok: bool,message: String) -> void:
    if not ok:failures+=1;push_error("FIRST START: "+message)
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);await frames(3)
    check(game.modal.visible and is_instance_valid(game.creator_name),"first visit opens creator")
    game.creator_name.text="Hrogar";game.creator_style.select(1);game.commit_creator()
    check(FileAccess.file_exists(State.SAVE),"creator saves first visit")
    game.prepare_exit();game.queue_free();await frames(5)
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);await frames(3)
    check(not game.modal.visible and game.state.player_name=="Hrogar" and game.state.appearance=="dark","continue restores character without forcing creator")
    game.prepare_exit();game.queue_free();await frames(5)
    print("FIRST START CREATOR: %s"%("PASS" if failures==0 else "FAIL"));quit(1 if failures else 0)
