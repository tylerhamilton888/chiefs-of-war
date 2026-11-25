extends SceneTree
const State = preload("res://scripts/chapter/state.gd")
const MENU = "res://scenes/main_menu.tscn"
const RETIRED_SAVES = ["user://ancestral_hearth_v1.json", "user://ogre_frontier_v1.json", "user://ogre_frontier_slot_2.json", "user://ogre_frontier_slot_3.json", "user://wandering_hearth_v1.json"]
var failures := 0

func _initialize() -> void:
    run.call_deferred()

func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func wait_for_scene(path: String) -> bool:
    for frame in 600:
        if is_instance_valid(current_scene) and current_scene.scene_file_path == path:
            return true
        await process_frame
        OS.delay_msec(5)
    return false

func buttons() -> Dictionary:
    var found := {}
    for button in current_scene.find_children("*", "Button", true, false):
        found[button.text] = button
    return found

func run() -> void:
    # This suite runs with a disposable XDG_DATA_HOME.
    DirAccess.remove_absolute(State.SAVE)
    for path in RETIRED_SAVES:
        var file := FileAccess.open(path, FileAccess.WRITE)
        file.store_string(path)
        file.close()
    change_scene_to_file(MENU)
    await wait_for_scene(MENU)
    var actions := buttons()
    check(actions.keys().size() == 3 and actions.has("Begin Journey"), "Only one campaign can start")
    if not actions.has("Begin Journey"):
        quit(1)
        return
    actions["Begin Journey"].pressed.emit()
    if not await wait_for_scene("res://scenes/fire_we_carry.tscn"):
        push_error("Campaign did not launch from the menu")
        quit(1)
        return
    current_scene.choose("work")
    current_scene.state.inventory.meat = 37
    current_scene.return_to_menu()
    await wait_for_scene(MENU)
    actions = buttons()
    check(actions.has("Continue"), "A saved journey offers Continue")
    if not actions.has("Continue"):
        quit(1)
        return
    actions["Continue"].pressed.emit()
    if not await wait_for_scene("res://scenes/fire_we_carry.tscn"):
        quit(1)
        return
    check(current_scene.state.inventory.meat == 37, "Continue resumes the same inventory")
    current_scene.home_menu()
    check(buttons().has("Pack for the road") and buttons().size() == 4, "Wagon offers only household actions")
    current_scene.return_to_menu()
    await wait_for_scene(MENU)
    var corrupt := FileAccess.open(State.SAVE, FileAccess.WRITE)
    corrupt.store_string("damaged")
    corrupt.close()
    change_scene_to_file(MENU)
    await process_frame
    await wait_for_scene(MENU)
    check(buttons()["Continue"].disabled, "An unreadable save cannot be overwritten from the title")
    check(FileAccess.get_file_as_string(State.SAVE) == "damaged", "Damaged file preserved")
    for path in RETIRED_SAVES:
        check(FileAccess.get_file_as_string(path) == path, "Preserved " + path)
    print("Single-campaign menu and save isolation: %d failures" % failures)
    quit(1 if failures else 0)
