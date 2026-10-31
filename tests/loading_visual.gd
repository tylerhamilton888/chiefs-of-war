extends SceneTree
const Loading=preload("res://scripts/loading/loading.gd")
var output=OS.get_environment("CHIEFS_REVIEW_DIR")
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await process_frame
func run() -> void:
    DirAccess.make_dir_recursive_absolute(output)
    for entry in [["frontier",0],["story",1],["frontier",2]]:
        var kind: String=entry[0];Loading.next_art=entry[1]
        Loading.context=kind;Loading.destination=Loading.VALID[kind]
        var screen=load("res://scenes/loading.tscn").instantiate();root.add_child(screen);screen.set_process(false)
        await frames(6);await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(output+"/loading-"+str(entry[1])+".png")
        while ResourceLoader.load_threaded_get_status(Loading.destination)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            await process_frame;OS.delay_msec(5)
        if ResourceLoader.load_threaded_get_status(Loading.destination)==ResourceLoader.THREAD_LOAD_LOADED:
            ResourceLoader.load_threaded_get(Loading.destination)
        screen.queue_free();await frames(3)
    quit()
