extends SceneTree
const OldSlots=preload("res://scripts/save_slots.gd")
const OgreSlots=preload("res://scripts/frontier/slots.gd")
const FrontierState=preload("res://scripts/frontier/state.gd")
var failures:=0
func _initialize():call_deferred("run")
func frames(n):
    for i in n:await process_frame
func wait_for_scene(method: String) -> bool:
    for i in 600:
        if is_instance_valid(current_scene) and current_scene.has_method(method):return true
        await process_frame
    return false
func check(ok: bool,message: String):
    if not ok:failures+=1;push_error(message)
func button_texts() -> String:
    var result=""
    for node in current_scene.find_children("*","Button",true,false):result+=node.text+"\n"
    return result
func run():
    # Isolated XDG_DATA_HOME; a legacy Orc save must never show or change.
    for i in OgreSlots.COUNT:DirAccess.remove_absolute(OgreSlots.path(i))
    var legacy=FileAccess.open(OldSlots.LEGACY,FileAccess.WRITE);legacy.store_string("old-orc-sentinel");legacy.close()
    OgreSlots.choose(0)
    var old=FrontierState.new();old.player_name="Old Ogre";old.inventory.wood=37
    OgreSlots.choose(1)
    check(old.save_game() and FileAccess.file_exists(OgreSlots.path(0)) and not FileAccess.file_exists(OgreSlots.path(1)),"frontier ledger remains bound to its original slot")
    OgreSlots.choose(0)
    OldSlots.booted=true
    change_scene_to_file("res://scenes/main_menu.tscn");await frames(6)
    check(current_scene.has_method("launch_frontier"),"main menu exposes Ogre frontier")
    var labels=button_texts()
    check("Create Ogre" in labels and "Orc" not in labels and "Practice" not in labels and not current_scene.has_method("launch"),"only Ogre routes appear in playable menu")
    check(OgreSlots.info(0).name=="Old Ogre" and OgreSlots.info(1).empty,"original frontier is preserved and second slot is empty")
    current_scene.launch_frontier(0,true);await frames(2)
    check(current_scene.has_method("launch_frontier"),"creating in an occupied slot is rejected")
    current_scene.launch_frontier(1,true);check(await wait_for_scene("open_creator"),"frontier finished loading")
    var world=current_scene
    check(world.has_method("open_creator") and world.modal.visible and is_instance_valid(world.creator_name),"new Ogre slot opens Ogre creator")
    world.creator_name.text="Torv";world.creator_style.select(1);world.commit_creator()
    check(OgreSlots.info(1).name=="Torv" and OgreSlots.info(0).name=="Old Ogre","new Ogre uses its own save")
    world.return_to_menu();await create_timer(0.3).timeout;await frames(6)
    current_scene.launch_frontier(2,true);check(await wait_for_scene("open_creator"),"second frontier finished loading")
    world=current_scene;check(world.has_method("open_creator") and world.modal.visible,"third slot opens Ogre creator")
    world.creator_name.text="Sven";world.commit_creator()
    check(OgreSlots.info(1).name=="Torv" and OgreSlots.info(2).name=="Sven","two new Ogres remain separate")
    world.return_to_menu();await create_timer(0.3).timeout;await frames(6)
    current_scene.launch_frontier(0,false);check(await wait_for_scene("open_creator"),"existing frontier finished loading")
    check(current_scene.state.player_name=="Old Ogre" and current_scene.state.inventory.wood==37,"original Ogre progress loads")
    check(not current_scene.modal.visible,"continuing does not force a new creator")
    check(FileAccess.get_file_as_string(OldSlots.LEGACY)=="old-orc-sentinel","legacy Orc save bytes remain untouched")
    current_scene.return_to_menu();await create_timer(0.3).timeout;await frames(6)
    var broken=FileAccess.open(OgreSlots.path(2),FileAccess.WRITE);broken.store_string("damaged save sentinel");broken.close()
    check(not OgreSlots.info(2).valid,"unreadable Ogre save is identified")
    current_scene.launch_frontier(2,true);await frames(2)
    check(current_scene.has_method("launch_frontier") and FileAccess.get_file_as_string(OgreSlots.path(2))=="damaged save sentinel","unreadable save cannot be replaced")
    var current=current_scene;current.queue_free();await frames(6)
    print("OGRE MENU / THREE FRONTIERS / LEGACY PRESERVATION: ","PASS" if failures==0 else "FAIL")
    quit(1 if failures else 0)
