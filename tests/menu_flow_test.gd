extends SceneTree
const Slots=preload("res://scripts/save_slots.gd")
var failures:=0
func _initialize():call_deferred("run")
func frames(n):
    for i in n:await process_frame
func check(ok: bool,message: String):
    if not ok:failures+=1;push_error(message)
func run():
    Slots.booted=true
    change_scene_to_file("res://scenes/main_menu.tscn");await frames(4)
    check(current_scene.has_method("launch"),"Boot opens main menu")
    current_scene.launch(0,true);await frames(12)
    var world=current_scene
    check(world.creator!=null and world.creator.visible,"New slot opens creator")
    world.name_input.text="Torv";world.begin_character()
    check(Slots.info(0).name=="Torv","Begin character saves selected slot")
    world.return_to_menu();await create_timer(0.3).timeout;await frames(5)
    check(current_scene.has_method("launch"),"Pause return opens main menu")
    current_scene.launch(1,true);await frames(12)
    world=current_scene;check(world.creator!=null,"Second slot opens a separate creator")
    world.name_input.text="Sven";world.begin_character()
    check(Slots.info(0).name=="Torv" and Slots.info(1).name=="Sven","Two characters remain separate through menu")
    world.return_to_menu();await create_timer(0.3).timeout;await frames(5)
    current_scene.launch(0,false);await frames(12)
    check(current_scene.character_name=="Torv" and current_scene.created,"Play restores first character")
    current_scene.return_to_menu();await create_timer(0.3).timeout;await frames(5)
    current_scene.practice();await frames(12)
    check(current_scene.practice_mode,"Menu opens unsaved practice")
    current_scene.return_to_menu();await create_timer(0.3).timeout;await frames(5)
    check(current_scene.has_method("launch"),"Practice can return to menu")
    check(Slots.info(0).name=="Torv" and Slots.info(1).name=="Sven","Practice preserves both campaigns")
    print("MAIN MENU / TWO CHARACTERS / CONTINUE / PRACTICE RETURN: ","PASS" if failures==0 else "FAIL")
    current_scene.queue_free();await frames(4);quit(1 if failures else 0)
