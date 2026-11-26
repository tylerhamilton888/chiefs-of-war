extends SceneTree
## Live 30 fps demonstration with the stock arena spawns, shared combat and default AI.
## Set XDG_DATA_HOME to a temporary directory. Pass -- --test --live-yard-capture.

var game
var goblin
var raider
var pending_frames := 0

func _initialize() -> void:
    run.call_deferred()

func frames(count: int) -> void:
    for frame in count:
        await process_frame
        pending_frames += 1

func aim_at(point: Vector2) -> void:
    root.warp_mouse(game.player.get_canvas_transform() * point)

func swing(point: Vector2) -> void:
    aim_at(point)
    await frames(2)
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    game._unhandled_input(click)

func move(action: String, ticks: int) -> void:
    Input.action_press(action)
    await frames(ticks)
    Input.action_release(action)

func verify(ok: bool, message: String) -> bool:
    if not ok:
        push_error("Live yard capture: " + message)
        quit(1)
    return ok

func run() -> void:
    if not verify("--live-yard-capture" in OS.get_cmdline_user_args(), "opt-in argument required"):
        return
    game = load("res://scenes/developer_arena.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    goblin = game.enemies[0]
    raider = game.enemies[1]
    var goblin_start: Vector2 = goblin.position
    var raider_start: Vector2 = raider.position
    var start_health: float = game.player.hp
    await frames(8)
    # An early swing away from the approaching goblin shows the committed miss.
    await swing(game.player.position + Vector2(100, 100))
    await frames(23)
    if not verify(goblin.hp == goblin.maximum and goblin.position.distance_to(goblin_start) > 10.0, "miss and pursuit"):
        return
    await move("move_left", 7)
    await swing(goblin.position)
    await frames(25)
    if not verify(goblin.hp <= 0, "axe cut must meet the pursuing goblin"):
        return

    var swap := InputEventKey.new()
    swap.keycode = KEY_TAB
    swap.pressed = true
    game._unhandled_input(swap)
    # Advance until the raider gives chase. The threat determines when we turn to face him.
    Input.action_press("move_right")
    for tick in 70:
        aim_at(raider.position)
        await frames(1)
        if game.player.position.distance_to(raider.position) < 152.0:
            break
    Input.action_release("move_right")
    for tick in 85:
        aim_at(raider.position)
        await frames(1)
        if game.player.hp < start_health:
            break
    if not verify(game.player.hp < start_health and raider.position.distance_to(raider_start) > 10.0, "raider must pursue and land a real strike"):
        return
    await frames(14)
    await swing(raider.position)
    await frames(27)
    if not verify(raider.hp > 0 and raider.hp < raider.maximum, "maul counter must hit the surviving raider"):
        return
    aim_at(raider.position)
    await move("move_left", 17)
    aim_at(raider.position)
    await frames(12)
    print("LIVE YARD: ", pending_frames, " frames. Goblin ", goblin.hp, "/", goblin.maximum,
        ", raider ", raider.hp, "/", raider.maximum, ", Ogre ", game.player.hp, "/", start_health)
    game.queue_free()
    await process_frame
    quit()
