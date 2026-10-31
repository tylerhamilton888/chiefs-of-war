extends SceneTree
const Loading=preload("res://scripts/loading/loading.gd")
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok: bool,message: String) -> void:
    if not ok:failures+=1;push_error("LOADING: "+message)
func run() -> void:
    check(not Loading.start(self,"bad-destination"),"invalid destination is rejected")
    check(Loading.ARTWORK.size()==3 and Loading.ARTWORK[0].ends_with("tracking.png") and Loading.ARTWORK[1].ends_with("feast.png"),"tracking and clan feast are included in the rotation")
    for path in Loading.ARTWORK:check(ResourceLoader.exists(path),"loading art exists: "+path)
    Loading.next_art=0
    Loading.destination="res://missing-journey.tscn";Loading.context="story"
    var broken=load("res://scenes/loading.tscn").instantiate();root.add_child(broken)
    await process_frame
    check("could not" in broken.status_label.text,"invalid path presents a recoverable error")
    check(broken.displayed_art.ends_with("tracking.png") and Loading.next_art==1,"first loading screen shows tracking")
    check(broken.find_children("*","Button",true,false).size()>0,"failure provides a way back to title")
    broken.queue_free();await process_frame
    check(Loading.start(self,"story"),"story loading transition starts")
    var arrived=false
    for i in 2400:
        await process_frame
        OS.delay_msec(5)
        if is_instance_valid(current_scene) and current_scene.has_method("cinematic_texture_path"):
            arrived=true;break
    check(arrived,"story scene opens after loading")
    if arrived:current_scene.prepare_exit();current_scene.queue_free()
    for i in 4:await process_frame
    print("OGRE LOADING TRANSITIONS: ","PASS" if failures==0 else "FAIL")
    quit(1 if failures else 0)
