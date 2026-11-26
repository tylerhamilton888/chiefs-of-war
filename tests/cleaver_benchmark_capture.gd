extends SceneTree
## Run at 30 fps with a real display and -- --test --cleaver-benchmark [--effects-off].
## Both passes use the regular yard, controls, camera and autonomous opponents.
var yard
var goblin
var raider
var tick := 0
var failures := 0
var actions := ["move_left", "move_right", "move_up", "move_down"]

func _initialize() -> void:
    run.call_deferred()

func frames(count: int) -> void:
    for i in count:
        await process_frame
        tick += 1

func key(code: Key, down := true) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = down
    Input.parse_input_event(event)
    Input.flush_buffered_events()

func mouse(button: MouseButton, down: bool) -> void:
    var event := InputEventMouseButton.new()
    event.button_index = button
    event.pressed = down
    event.position = root.get_mouse_position()
    Input.parse_input_event(event)
    Input.flush_buffered_events()

func aim(point: Vector2) -> void:
    root.warp_mouse(yard.player.get_canvas_transform() * point)

func swing(point: Vector2) -> void:
    aim(point)
    await frames(2)
    mouse(MOUSE_BUTTON_LEFT, true)
    await frames(1)
    mouse(MOUSE_BUTTON_LEFT, false)
    await frames(23)

func walk_toward(offset: Vector2) -> void:
    for i in actions.size():
        var component: float = [-offset.x, offset.x, -offset.y, offset.y][i]
        if component > 5.0:
            Input.action_press(actions[i])
        else:
            Input.action_release(actions[i])

func walk_to(point: Vector2, stop_distance: float, limit: int, moving_target: Node2D = null) -> void:
    for i in limit:
        if moving_target != null:
            point = moving_target.position
        var offset: Vector2 = point - yard.player.position
        if offset.length() <= stop_distance:
            break
        aim(point)
        walk_toward(offset)
        await frames(1)
    walk_toward(Vector2.ZERO)

func check(value: bool, beat: String) -> void:
    print("Frame %d  %s  %s  Ogre %s, goblin %.0f, raider %.0f" % [tick, beat, value, yard.player.position.round(), goblin.hp, raider.hp])
    if not value:
        failures += 1
        push_error(beat)

func run() -> void:
    if not "--cleaver-benchmark" in OS.get_cmdline_user_args():
        quit(1)
        return
    yard = load("res://scenes/developer_arena.tscn").instantiate()
    root.add_child(yard)
    current_scene = yard
    goblin = yard.enemies[0]
    raider = yard.enemies[1]
    await frames(2)
    if "--effects-off" in OS.get_cmdline_user_args():
        key(KEY_V)
        key(KEY_V, false)
    key(KEY_F2)
    key(KEY_F2, false)
    await frames(6)
    await swing(yard.player.position + Vector2(170, 140))
    check(goblin.hp == goblin.maximum and raider.hp == raider.maximum and yard.player.attack_done, "Miss")
    await walk_to(goblin.position, 92, 28, goblin)
    await swing(goblin.position)
    check(goblin.cleaved, "Clean cut")
    await frames(12)
    key(KEY_E)
    key(KEY_E, false)
    await frames(7)
    check(yard.state.inventory.goblin_meat == 1, "Carry cut")
    await walk_to(raider.position, 94, 105, raider)
    await swing(raider.position)
    check(raider.hp > 0 and raider.hp < raider.maximum, "Armor holds")
    aim(raider.position)
    var before_guard: float = yard.player.hp
    var guarded_contact := false
    mouse(MOUSE_BUTTON_RIGHT, true)
    for i in 56:
        await frames(1)
        if raider.state == "attack" and yard.player.guarding:
            guarded_contact = true
    check(guarded_contact and yard.player.hp == before_guard, "Guard catches counter")
    mouse(MOUSE_BUTTON_RIGHT, false)
    walk_toward(Vector2(0, 100))
    key(KEY_SPACE)
    key(KEY_SPACE, false)
    await frames(2)
    check(yard.player.dodge_time > 0, "Dodge leaves the line")
    await frames(16)
    walk_toward(Vector2.ZERO)
    for i in 5:
        if raider.hp <= 0:
            break
        await walk_to(raider.position, 82, 34, raider)
        await swing(raider.position)
    if raider.hp > 0:
        await walk_to(raider.position, 82, 34, raider)
        await swing(raider.position)
    check(raider.hp <= 0 and yard.player.hp > 0, "Raider defeated")
    var sapling = yard.practice_trees.back()
    await walk_to(sapling.position + Vector2(65, 58), 15, 145)
    await swing(sapling.position)
    check(sapling.data.state == "felled", "Sapling felled")
    await walk_to(yard.camp_pot.position + Vector2(48, 66), 14, 130)
    key(KEY_E)
    key(KEY_E, false)
    await frames(14)
    check(yard.camp_pot.servings == 2, "Cook two portions")
    key(KEY_E)
    key(KEY_E, false)
    await frames(10)
    key(KEY_Q)
    key(KEY_Q, false)
    await frames(12)
    check(yard.state.fed > 0, "Eat stew")
    await walk_to(Vector2(852, 825), 16, 80)
    key(KEY_SHIFT)
    await walk_to(Vector2(600, 722), 22, 75)
    key(KEY_SHIFT, false)
    await walk_to(Vector2(520, 709), 18, 40)
    await frames(24)
    await walk_to(Vector2(493, 648), 16, 45)
    await swing(Vector2(562, 630))
    await walk_to(Vector2(568, 722), 18, 65)
    await walk_to(Vector2(740, 719), 18, 68)
    check(tick < 900, "Sequence fits 30 seconds")
    await frames(maxi(1, 900 - tick))
    yard.queue_free()
    await process_frame
    quit(1 if failures else 0)
