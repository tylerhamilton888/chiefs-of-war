extends SceneTree
const State = preload("res://scripts/chapter/state.gd")
var failed := false
var contact_phases: Array[int] = []

func _initialize() -> void:
    run.call_deferred()

func verify(ok: bool, message: String) -> void:
    if not ok:
        failed = true
        push_error(message)

func press_equipment(game: Node, label: String) -> void:
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text == label and not button.disabled:
            button.pressed.emit()
            return
    verify(false, "Missing equipment action: " + label)

func write_save(data: Dictionary) -> void:
    var file := FileAccess.open(State.SAVE, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

func verify_legacy() -> void:
    for weapon in ["hunting_axe", "iron_maul"]:
        var legacy: Dictionary = State.new().pack()
        legacy.erase("equipment")
        legacy.flags["equipped_iron_maul"] = weapon == "iron_maul"
        legacy.inventory.ore = 7
        write_save(legacy)
        var loaded := State.new()
        verify(loaded.load_game(), "An existing chapter loadout is readable")
        verify(loaded.equipment == {"weapon": weapon, "head": "bare", "body": "fur"}, "Legacy weapon and bare head restored")
        verify(loaded.inventory.ore == 7 and loaded.save_game(), "Legacy progress survives re-save")
    var old_helmet_save := State.new().pack()
    old_helmet_save.equipment = {"weapon": "iron_maul", "head": "iron_helm"}
    write_save(old_helmet_save)
    var old_helmet := State.new()
    verify(old_helmet.load_game() and old_helmet.equipment == {"weapon": "iron_maul", "head": "iron_helm", "body": "fur"}, "Saves with just weapon and head keep both and start with fur")
    var invalid := State.new().pack()
    for gear in [[], {"weapon": "iron_maul"}, {"head": "iron_helm", "weapon": "unknown"}, {"head": "unknown", "weapon": "hunting_axe"}, {"head": "bare", "body": "unknown", "weapon": "iron_maul"}]:
        invalid.equipment = gear
        verify(not State.new().valid(invalid), "Malformed equipment cannot replace a loadout")
    write_save(invalid)
    var preserved := FileAccess.get_file_as_string(State.SAVE)
    var unreadable := State.new()
    verify(not unreadable.load_game() and not unreadable.save_game(), "Malformed loadout blocks overwriting its file")
    verify(FileAccess.get_file_as_string(State.SAVE) == preserved, "The failed load leaves the original bytes intact")
    DirAccess.remove_absolute(State.SAVE)

func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    verify_legacy()
    var game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    await physics_frame
    game.choose("work")
    verify(game.player.equipped_weapon == "hunting_axe", "Default loadout")
    game.state.profile.hair = "silver"
    game.player.set_hair_palette("silver")
    var open := InputEventKey.new()
    open.keycode = KEY_I
    open.pressed = true
    game._unhandled_input(open)
    var combinations := [
        ["", "hunting_axe", "bare", "fur"],
        ["Equip iron helm", "hunting_axe", "iron_helm", "fur"],
        ["Equip scale mantle", "hunting_axe", "iron_helm", "scale_mantle"],
        ["Remove iron helm", "hunting_axe", "bare", "scale_mantle"],
        ["Equip iron maul", "iron_maul", "bare", "scale_mantle"],
        ["Equip fur mantle", "iron_maul", "bare", "fur"],
        ["Equip iron helm", "iron_maul", "iron_helm", "fur"],
        ["Equip scale mantle", "iron_maul", "iron_helm", "scale_mantle"],
    ]
    for combination in combinations:
        if combination[0] != "":
            press_equipment(game, combination[0])
        var expected := {"weapon": combination[1], "head": combination[2], "body": combination[3]}
        var preview = game.modal.find_child("EquippedOgre", true, false)
        for actor in [preview, game.player]:
            verify(actor != null and actor.equipped_weapon == expected.weapon and actor.equipped_head == expected.head and actor.equipped_body == expected.body, "World and preview show " + str(expected))
        verify(preview.sprite.material.get_shader_parameter("palette") == game.player.sprite.material.get_shader_parameter("palette"), "The fitting preview retains the chosen hair palette")
        var saved := State.new()
        verify(saved.load_game() and saved.equipment == expected, "All three slots survive save/reload")
        verify(saved.has("equipped_iron_maul") == (expected.weapon == "iron_maul"), "Legacy weapon flag kept in sync")
    press_equipment(game, "Turn Ogre")
    var turned = game.modal.find_child("EquippedOgre", true, false)
    verify(turned.facing == 2 and turned.equipped_head == "iron_helm" and turned.equipped_body == "scale_mantle", "Inspect armored Ogre from the side")
    game.close_modal()
    game.rebuild()
    verify(game.player.equipped_weapon == "iron_maul" and game.player.equipped_head == "iron_helm" and game.player.equipped_body == "scale_mantle", "Rebuilt world restores all equipment slots")
    game.belongings()
    press_equipment(game, "Remove iron helm")
    verify(game.player.equipped_weapon == "iron_maul" and game.player.equipped_head == "bare" and game.player.equipped_body == "scale_mantle", "Removing the helm keeps the maul and scale mantle")
    game.close_modal()
    for facing in range(4):
        game.player.facing = facing
        for index in range(4):
            game.player.action_pose(index)
            verify(game.player.sprite.get_meta("registered_pose", "").contains("player_maul_nordic.png"), "Registered maul pose")
            verify(game.player.sprite.flip_h == (facing == 1), "Weapon follows the facing direction")
    verify(game.player.weapon_damage(true) == 42, "Honing applies to the axe only")
    verify(game.player.attack(Vector2.RIGHT) and is_equal_approx(game.player.attack_time, 0.88), "Maul attack timing")
    game.player.attack_time = 0
    game.player.struck.connect(func(actor): contact_phases.append(actor.swing_phase))
    for weapon in ["hunting_axe", "iron_maul"]:
        game.player.equip_weapon(weapon)
        for aim in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
            game.player.cooldown = 0
            contact_phases.clear()
            verify(game.player.attack(aim), "Strike starts")
            var phases: Array[int] = [game.player.swing_phase]
            var poses := {}
            while game.player.attack_time > 0:
                game.player.update_swing(1.0 / 60)
                if game.player.swing_phase != phases.back():
                    phases.append(game.player.swing_phase)
                poses[[game.player.sprite.texture.resource_path, game.player.sprite.region_rect]] = true
                verify(game.player.sprite.flip_h == (aim == Vector2.LEFT), "Pose holds swing direction")
            verify(phases == [0, 1, 2, 3, 4, 5], "All six authored beats play")
            verify(poses.size() >= 6, "Each beat supplies its own silhouette")
            verify(contact_phases == [3], "One damage event on the contacting drawing")
    game.prepare_exit()
    await create_timer(0.2).timeout
    game.queue_free()
    await process_frame
    print("Chapter equipment: ", "FAIL" if failed else "PASS")
    quit(1 if failed else 0)
