extends "res://tests/iron_and_embers_capture.gd"
## Begin a new campaign from the title and play Bramm's opening job using input.
## Film at 30 fps with --write-movie, --crossing-capture and fresh user data.
## The frame cues locate the wagon, fire and family meal in the continuous recording.

func cue(label: String) -> void:
    print("CROSSING CUE ", pending_frames, " ", label)

func press_button(label: String) -> bool:
    for button in current_scene.find_children("*", "Button", true, false):
        if button.text == label and button.is_visible_in_tree() and not button.disabled:
            button.pressed.emit()
            return true
    return false

func use_near(kind: String, id := "") -> bool:
    await frames(2)
    if game.nearest.get("kind", "") != kind or (id != "" and game.nearest.get("id", "") != id):
        return verify(false, "expected %s/%s, found %s at %s" % [kind, id, str(game.nearest), str(game.player.position)])
    tap(KEY_E)
    await frames(3)
    return true

func walk_to(point: Vector2, range_to_stop := 22.0) -> bool:
    if not await approach(point, range_to_stop, 250):
        return verify(false, "could not walk to %s from %s" % [point, game.player.position])
    return true

func run() -> void:
    if not verify("--crossing-capture" in OS.get_cmdline_user_args() and not FileAccess.file_exists("user://fire_we_carry_v1.json"), "use --crossing-capture with fresh user data"):
        return
    change_scene_to_file("res://scenes/main_menu.tscn")
    await frames(5)
    if not verify(press_button("Begin Journey"), "Begin Journey on the title"):
        return
    await frames(5)
    if not verify(press_button("Enter Emberhide Crossing"), "Enter from the character creator"):
        return
    for tick in 400:
        await frames(1)
        if DisplayServer.get_name() == "headless":
            OS.delay_msec(4)
        if is_instance_valid(current_scene) and current_scene.scene_file_path.ends_with("fire_we_carry.tscn"):
            break
    game = current_scene
    if not verify(game.scene_file_path.ends_with("fire_we_carry.tscn") and game.dialog_mode, "opening conversation at Emberhide"):
        return
    await frames(5)
    tap(KEY_SPACE)
    await frames(3)
    if not verify(press_button("Where did you stack the timber?"), "ask Bramm for directions"):
        return
    await frames(4)
    tap(KEY_SPACE)
    await frames(3)
    if not verify(press_button("I see them."), "accept the timber task"):
        return
    await frames(4)
    tap(KEY_I)
    await frames(4)
    if not verify(press_button("Equip iron helm"), "fit the iron helm in Belongings"):
        return
    await frames(4)
    if not verify(press_button("Return"), "leave Belongings"):
        return
    if not verify(game.player.equipped_head == "iron_helm", "helmet remained equipped in the world"):
        return
    cue("Walk to the wagon")
    await frames(7)
    var wood: Array = game.supplies.duplicate()
    for i in 3:
        var bundle: Dictionary = wood[i]
        if not await walk_to(bundle.position + Vector2(16, 16), 27.0):
            return
        if i == 0:
            cue("Bramm working")
            await frames(95)
        if not await use_near("wood", bundle.id):
            return
    if not verify(game.state.inventory.wood == 6, "all three family bundles collected"):
        return
    cue("Wagon approach")
    if not await walk_to(Vector2(719, 800)):
        return
    cue("Fit axle")
    if not await use_near("repair"):
        return
    await frames(60)
    if not verify(game.state.has("repaired") and is_zero_approx(game.family_wagon.rotation), "the wheel takes the weight"):
        return
    cue("Family supplies")
    if not await walk_to(Vector2(834, 858)):
        return
    if not await walk_to(Vector2(834, 1068)):
        return
    if not await walk_to(Vector2(702, 1050)):
        return
    if not await use_near("provisions"):
        return
    # A spare length of timber for the cookfire is southeast of the family stores.
    var firewood: Dictionary = wood[5]
    if not await walk_to(Vector2(810, 1108)):
        return
    if not await walk_to(firewood.position + Vector2(-17, 8), 22):
        return
    if not await use_near("wood", firewood.id):
        return
    cue("Walk into the cookfire")
    if not await walk_to(game.camp_pot.position + Vector2(72, 90), 14):
        return
    cue("Svala working")
    await frames(76)
    var before: int = game.state.inventory.meals
    if not await use_near("hearth"):
        return
    cue("Family supper")
    await frames(74)
    if not verify(game.state.inventory.meals == before + 3, "food and timber make three meals"):
        return
    cue("Return to Bramm")
    # Leave the solid cookpot along its southern edge, then approach Bramm.
    if not await walk_to(game.camp_pot.position + Vector2(-155, 115), 22):
        return
    if not await walk_to(Vector2(468, 1155)):
        return
    for tick in 280:
        var separation: Vector2 = game.player.position - game.npcs.bramm.position
        if game.nearest.get("kind", "") == "npc" and game.nearest.id == "bramm" and separation.x < -74 and separation.length() <= 118:
            break
        var beside_father: Vector2 = game.npcs.bramm.position + Vector2(-96, 20)
        walk_vector((beside_father - game.player.position).normalized())
        await frames(1)
    walk_vector(Vector2.ZERO)
    if not await use_near("npc", "bramm"):
        return
    await frames(4)
    tap(KEY_SPACE)
    await frames(8)
    cue("A bowl for Bramm")
    if not verify(press_button("Take a bowl, Father."), "Bramm can be offered a spare meal"):
        return
    await frames(105)
    if not verify(game.state.has("fed_bramm") and game.state.inventory.meals == before + 2, "one of the three cooked meals went to Bramm"):
        return
    print("CROSSING FINISHED ", pending_frames, " ", game.state.inventory)
    game.prepare_exit()
    game.queue_free()
    await process_frame
    quit()
