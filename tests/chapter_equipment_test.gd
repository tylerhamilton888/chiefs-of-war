extends SceneTree
const State = preload("res://scripts/chapter/state.gd")
var failed := false

func _initialize() -> void:
    run.call_deferred()

func verify(ok: bool, message: String) -> void:
    if not ok:
        failed = true
        push_error(message)

func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    await physics_frame
    game.choose("work")
    verify(game.player.equipped_weapon == "hunting_axe", "Default loadout")
    var open := InputEventKey.new()
    open.keycode = KEY_I
    open.pressed = true
    game._unhandled_input(open)
    var swap: Button
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text == "Equip iron maul":
            swap = button
    verify(swap != null and not swap.disabled, "Weapon choice available in belongings")
    if failed:
        quit(1)
        return
    swap.pressed.emit()
    verify(game.player.equipped_weapon == "iron_maul", "Equipped iron maul")
    var saved = State.new()
    verify(saved.load_game() and saved.has("equipped_iron_maul"), "Equipped weapon saved")
    game.close_modal()
    game.rebuild()
    verify(game.player.equipped_weapon == "iron_maul", "Rebuilt world restores equipment")
    for facing in range(4):
        game.player.facing = facing
        for index in range(4):
            game.player.action_pose(index)
            verify(game.player.sprite.get_meta("registered_pose", "").contains("player_maul_nordic.png"), "Registered maul pose")
            verify(game.player.sprite.flip_h == (facing == 1), "Weapon follows the facing direction")
    verify(game.player.weapon_damage(true) == 42, "Honing applies to the axe only")
    verify(game.player.attack(Vector2.RIGHT) and is_equal_approx(game.player.attack_time, 0.88), "Maul attack timing")
    game.prepare_exit()
    game.queue_free()
    await process_frame
    print("Chapter equipment: ", "FAIL" if failed else "PASS")
    quit(1 if failed else 0)
