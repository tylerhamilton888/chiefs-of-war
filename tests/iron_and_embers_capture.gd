extends "res://tests/live_yard_capture.gd"
## Replay using the stock enemies, camera and inputs. Capture at 30 fps.
## Pass --iron-and-embers-capture and a fresh XDG_DATA_HOME.

const MOVES := ["move_right", "move_left", "move_down", "move_up"]
const TRAVEL := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]

func tap(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.physical_keycode = code
    event.pressed = true
    game._unhandled_input(event)

func walk_vector(direction: Vector2) -> void:
    for i in MOVES.size():
        if direction.dot(TRAVEL[i]) > 0.15:
            Input.action_press(MOVES[i])
        else:
            Input.action_release(MOVES[i])

func approach(point: Vector2, radius: float, limit: int, target: Node2D = null) -> bool:
    for tick in limit:
        var offset: Vector2 = point - game.player.position
        if offset.length() <= radius:
            walk_vector(Vector2.ZERO)
            return true
        walk_vector(offset.normalized())
        aim_at(target.position if is_instance_valid(target) else point)
        await frames(1)
    walk_vector(Vector2.ZERO)
    return false

func run() -> void:
    if not verify("--iron-and-embers-capture" in OS.get_cmdline_user_args() and not FileAccess.file_exists("user://fire_we_carry_v1.json"), "use the capture flag and fresh user data"):
        return
    if "--loadout" in OS.get_cmdline_user_args():
        await loadout()
        return
    change_scene_to_file("res://scenes/main_menu.tscn")
    await frames(3)
    var yard_button: Button
    for button in current_scene.find_children("*", "Button", true, false):
        if button.text == "Practice Yard":
            yard_button = button
    if not verify(is_instance_valid(yard_button), "Practice Yard must be accessible from the title"):
        return
    yard_button.pressed.emit()
    await frames(3)
    game = current_scene
    goblin = game.enemies[0]
    raider = game.enemies[1]
    aim_at(game.player.position + Vector2.DOWN * 160)
    await frames(5)
    tap(KEY_H)
    await frames(8)
    tap(KEY_B)
    await frames(8)
    if not verify(game.player.equipped_head == "iron_helm" and game.player.equipped_body == "scale_mantle", "both armor slots equip independently"):
        return
    aim_at(goblin.position)
    await frames(3)
    if not await approach(goblin.position, 100.0, 60, goblin):
        verify(false, "goblin must be within normal axe reach")
        return
    await swing(goblin.position)
    await frames(20)
    if not verify(goblin.hp <= 0 and not game.state.field_cuts.is_empty(), "a clean cut left field meat"):
        return
    var coordinates: Array = game.state.field_cuts.values()[0]
    var pickup := Vector2(coordinates[0], coordinates[1])
    await approach(pickup, 90.0, 35)
    await frames(24)
    tap(KEY_E)
    await frames(10)
    if not verify(game.state.inventory.goblin_meat == 1, "E carried the goblin meat"):
        return
    tap(KEY_TAB)
    await frames(5)
    if not verify(game.player.equipped_weapon == "iron_maul" and game.player.equipped_head == "iron_helm" and game.player.equipped_body == "scale_mantle", "the maul and both armor choices coexist"):
        return

    await approach(raider.position, 130, 150, raider)
    for tick in 75:
        aim_at(raider.position)
        if game.player.position.distance_to(raider.position) <= 110:
            break
        await frames(1)
    await swing(raider.position)
    await frames(29)
    if not verify(raider.hp < raider.maximum and raider.hp > 0, "the maul met a live opponent"):
        return
    aim_at(raider.position)
    var to_pot: Vector2 = (game.camp_pot.position - game.player.position).normalized()
    walk_vector(to_pot)
    var before: Vector2 = game.player.position
    tap(KEY_SPACE)
    await frames(16)
    walk_vector(Vector2.ZERO)
    if not verify(game.player.position.distance_to(before) > 45.0, "dodge carries the Ogre out of reach"):
        return
    var pot: Vector2 = game.camp_pot.position
    if not await approach(pot + Vector2(105, 45), 10, 170, raider):
        verify(false, "pot approach was blocked")
        return
    aim_at(pot)
    await frames(8)
    tap(KEY_E)
    await frames(36)
    if not verify(game.state.inventory.goblin_meat == 0 and game.state.pot_servings.get("yard", 0) == 2, "the carried cut made two servings in the pot"):
        return
    var meals: int = game.state.inventory.meals
    tap(KEY_E)
    await frames(25)
    if not verify(game.state.inventory.meals == meals + 1, "E ladled a serving"):
        return
    print("YARD FEAST: ", pending_frames, " frames. Raider ", raider.hp, "/", raider.maximum,
        ", Ogre ", game.player.hp, ", meals ", game.state.inventory.meals)
    game.queue_free()
    await process_frame
    quit()


func click_equipment(label: String) -> bool:
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text == label and button.is_visible_in_tree() and not button.disabled:
            button.pressed.emit()
            return true
    return false

func loadout() -> void:
    change_scene_to_file("res://scenes/fire_we_carry.tscn")
    await frames(3)
    game = current_scene
    game.choose("work")
    tap(KEY_I)
    await frames(25)
    # One equipment button changes at a time, so the other two choices
    # remain visible on the same preview as the eight combinations cycle.
    var changes := [
        ["Equip iron helm", "hunting_axe", "iron_helm", "fur"],
        ["Equip scale mantle", "hunting_axe", "iron_helm", "scale_mantle"],
        ["Remove iron helm", "hunting_axe", "bare", "scale_mantle"],
        ["Equip iron maul", "iron_maul", "bare", "scale_mantle"],
        ["Equip iron helm", "iron_maul", "iron_helm", "scale_mantle"],
        ["Equip fur mantle", "iron_maul", "iron_helm", "fur"],
        ["Remove iron helm", "iron_maul", "bare", "fur"]
    ]
    for change in changes:
        if not verify(click_equipment(change[0]), "Belongings button " + change[0]):
            return
        await frames(26)
        if not verify(game.player.equipped_weapon == change[1] and game.player.equipped_head == change[2] and game.player.equipped_body == change[3], "independent equipment for " + change[0]):
            return
        if change[1] == "iron_maul" and change[2] == "iron_helm" and change[3] == "scale_mantle":
            for turn in 4:
                if not verify(click_equipment("Turn Ogre"), "rotate the equipped preview"):
                    return
                await frames(14)
    game.prepare_exit()
    game.queue_free()
    await process_frame
    print("BELONGINGS: all eight armor and weapon combinations")
    quit()
