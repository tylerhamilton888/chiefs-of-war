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
    check(actions.size() == 4 and actions.has("Practice Yard") and actions.has("Begin Journey"), "Title offers one campaign and a practice yard")
    if actions.has("Practice Yard"):
        actions["Practice Yard"].pressed.emit()
        if not await wait_for_scene("res://scenes/developer_arena.tscn"):
            push_error("Practice Yard failed to open")
            quit(1)
            return
        var back := InputEventKey.new()
        back.keycode = KEY_ESCAPE
        back.pressed = true
        current_scene._unhandled_input(back)
        await wait_for_scene(MENU)
        check(not FileAccess.file_exists(State.SAVE), "Trying the practice yard before starting preserves the empty slot")
        actions = buttons()
    if not actions.has("Begin Journey"):
        quit(1)
        return
    actions["Begin Journey"].pressed.emit()
    var creator = current_scene.content.get_child(0)
    check(not FileAccess.file_exists(State.SAVE), "Opening the creator does not claim a save")
    creator.cancelled.emit()
    await process_frame
    check(buttons().has("Begin Journey"), "Cancel restores the title")
    buttons()["Begin Journey"].pressed.emit()
    creator = current_scene.content.get_child(0)
    creator.name_edit.text = "   "
    creator.refresh()
    check(creator.start.disabled, "A blank name cannot start a journey")
    creator.name_edit.text = "Tore"
    creator.clan_edit.text = "Frostgate"
    creator.hair_select.select(3)
    creator.hair_select.item_selected.emit(3)
    creator.background_select.select(2)
    creator.refresh()
    check(creator.preview.sprite.material.get_shader_parameter("palette") == 3, "The live Ogre receives the selected color")
    creator.start.pressed.emit()
    if not await wait_for_scene("res://scenes/fire_we_carry.tscn"):
        push_error("Campaign did not launch from the menu")
        quit(1)
        return
    var expected := {"ogre_name": "Tore", "clan_name": "Frostgate", "hair": "silver", "background": "smith"}
    check(current_scene.state.profile == expected and current_scene.state.inventory.ore == 2, "Identity and smith supplies enter the game")
    check(current_scene.player.sprite.material != null and current_scene.player.sprite.material.get_shader_parameter("palette") == 3, "The campaign matches the preview")
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
    check(current_scene.state.profile == expected and current_scene.state.inventory.ore == 2, "Continue preserves the Ogre and grants starting supplies once")
    current_scene.home_menu()
    check(buttons().has("Pack for the road") and buttons().size() == 4, "Wagon offers only household actions")
    current_scene.return_to_menu()
    await wait_for_scene(MENU)
    var legacy = JSON.parse_string(FileAccess.get_file_as_string(State.SAVE))
    legacy.erase("profile")
    var file := FileAccess.open(State.SAVE, FileAccess.WRITE)
    file.store_string(JSON.stringify(legacy))
    file.close()
    var restored := State.new()
    check(restored.load_game() and restored.profile == State.DEFAULT_PROFILE and restored.inventory.meat == 37, "Pre-creator saves retain progress and receive the original appearance")
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
