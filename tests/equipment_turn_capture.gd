extends "res://tests/cleaver_benchmark_capture.gd"
## A stationary cursor orbit, a guard pivot and moving turns. Render with --turns [--maul].
func run() -> void:
    if not "--turns" in OS.get_cmdline_user_args():
        quit(1)
        return
    yard = load("res://scenes/developer_arena.tscn").instantiate()
    root.add_child(yard)
    current_scene = yard
    goblin = yard.enemies[0]
    raider = yard.enemies[1]
    for opponent in yard.enemies:
        opponent.active = false
    await frames(2)
    for code in [KEY_V, KEY_F2, KEY_H, KEY_B]:
        key(code)
        key(code, false)
    if "--maul" in OS.get_cmdline_user_args():
        key(KEY_TAB)
        key(KEY_TAB, false)
    await orbit(18)
    mouse(MOUSE_BUTTON_RIGHT, true)
    await orbit(12)
    mouse(MOUSE_BUTTON_RIGHT, false)
    Input.action_press("move_right")
    await orbit(12)
    Input.action_release("move_right")
    key(KEY_SHIFT)
    for bearing in [Vector2.UP, Vector2.LEFT]:
        var action := "move_up" if bearing == Vector2.UP else "move_left"
        Input.action_press(action)
        for i in 18:
            aim(yard.player.position + bearing * 180.0)
            await frames(1)
        Input.action_release(action)
    key(KEY_SHIFT, false)
    aim(yard.player.position + Vector2.UP * 170)
    await frames(3)
    mouse(MOUSE_BUTTON_LEFT, true)
    await frames(1)
    mouse(MOUSE_BUTTON_LEFT, false)
    await frames(33)
    yard.queue_free()
    await process_frame
    quit(1 if failures else 0)

func orbit(hold_frames: int) -> void:
    for bearing in [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]:
        for i in hold_frames:
            aim(yard.player.position + bearing * 180.0)
            await frames(1)
        check(yard.player.direction() == bearing, "Body faces %s" % bearing)
