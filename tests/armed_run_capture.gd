extends "res://tests/cleaver_benchmark_capture.gd"
## Render at 30 fps with -- --test --armed-run. All opponents use the yard AI.

func run() -> void:
    if not "--armed-run" in OS.get_cmdline_user_args():
        quit(1)
        return
    yard = load("res://scenes/developer_arena.tscn").instantiate()
    root.add_child(yard)
    current_scene = yard
    goblin = yard.enemies[0]
    raider = yard.enemies[1]
    await frames(2)
    for code in [KEY_V, KEY_F2, KEY_H, KEY_B]:
        key(code)
        key(code, false)
    await frames(12)
    key(KEY_SHIFT)
    await walk_to(Vector2(1060, 1120), 12, 25)
    await walk_to(Vector2(1190, 1120), 12, 34)
    await walk_to(goblin.position, 102, 50, goblin)
    await running_swing(goblin)
    check(goblin.cleaved, "Running cleaver meets the goblin")
    await frames(10)
    await walk_to(Vector2(1100, 1020), 14, 55)
    await walk_to(raider.position, 105, 95, raider)
    await running_swing(raider)
    check(raider.hp > 0 and raider.hp < raider.maximum, "Armored contact")
    key(KEY_SHIFT, false)
    aim(raider.position)
    mouse(MOUSE_BUTTON_RIGHT, true)
    await frames(27)
    mouse(MOUSE_BUTTON_RIGHT, false)
    await frames(3)
    key(KEY_TAB)
    key(KEY_TAB, false)
    key(KEY_SHIFT)
    await walk_to(Vector2(1230, 1130), 15, 65)
    await walk_to(Vector2(1010, 1120), 15, 65)
    check(yard.player.equipped_weapon == "iron_maul", "Maul in the return run")
    key(KEY_SHIFT, false)
    await frames(15)
    yard.queue_free()
    await process_frame
    quit(1 if failures else 0)

func running_swing(target) -> void:
    aim(target.position)
    await frames(1)
    mouse(MOUSE_BUTTON_LEFT, true)
    await frames(1)
    check(yard.player.running_cut, "Approach feeds the cut")
    mouse(MOUSE_BUTTON_LEFT, false)
    await frames(22)
