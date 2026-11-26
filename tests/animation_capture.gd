extends SceneTree
## Record with Godot --write-movie at 30 fps. Use a fresh temporary XDG_DATA_HOME.
## The campaign walk and arena use their regular physics, camera and hit resolution.
var game
var capture_combat := false
var hit_targets := true

func _initialize() -> void:
    run.call_deferred()

func frames(count: int) -> void:
    for frame in count:
        await process_frame

func run() -> void:
    var args := OS.get_cmdline_user_args()
    if "--animation-capture" not in args or FileAccess.file_exists("user://fire_we_carry_v1.json"):
        push_error("Animation capture requires --animation-capture and a fresh data directory.")
        quit(1)
        return
    capture_combat = "--combat" in args
    var scene := "developer_arena" if capture_combat else "fire_we_carry"
    game = load("res://scenes/%s.tscn" % scene).instantiate()
    root.add_child(game)
    current_scene = game
    if capture_combat:
        await combat()
    else:
        await travel()
    game.queue_free()
    await process_frame
    quit(0 if hit_targets else 1)

func move(action: String, count: int) -> void:
    Input.action_press(action)
    await frames(count)
    Input.action_release(action)

func shift(pressed: bool) -> void:
    var key := InputEventKey.new()
    key.keycode = KEY_SHIFT
    key.physical_keycode = KEY_SHIFT
    key.pressed = pressed
    Input.parse_input_event(key)
    Input.flush_buffered_events()

func travel() -> void:
    game.choose("work")
    game.player.position = Vector2(820, 1110)
    game.camera.reset_smoothing()
    await frames(120)
    await move("move_down", 15)
    await move("move_right", 48)
    await frames(8)
    shift(true)
    var run_start: Vector2 = game.player.position
    await move("move_right", 48)
    print("Running distance in 1.6 seconds: ", game.player.position.distance_to(run_start))
    await move("move_left", 24)
    await move("move_up", 14)
    await move("move_down", 21)
    shift(false)
    await frames(10)
    game.prepare_exit()

func aim_at(point: Vector2) -> void:
    root.warp_mouse(game.player.get_canvas_transform() * point)

func strike(point: Vector2) -> void:
    aim_at(point)
    await frames(2)
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    click.pressed = true
    game._unhandled_input(click)
    print("Attack ", game.player.equipped_weapon, " aim ", game.player.locked)
    await frames(32)

func combat() -> void:
    # Stationary sparring targets keep weapon contact visible. Their hit reactions,
    # collision and health are live. The two builds use the same scenario.
    var goblin = game.enemies[0]
    var raider = game.enemies[1]
    goblin.position = game.player.position + Vector2(110, -16)
    raider.position = game.player.position + Vector2(-102, -12)
    goblin.target = null
    raider.target = null
    aim_at(goblin.position)
    await frames(10)
    await move("move_down", 14)
    await strike(game.player.position + Vector2(0, 160))
    print("HP after miss: ", goblin.hp, ", ", raider.hp)
    hit_targets = goblin.hp == goblin.maximum and raider.hp == raider.maximum
    aim_at(goblin.position)
    await move("move_up", 14)
    await move("move_left", 10)
    await move("move_right", 13)
    await strike(goblin.position)
    print("Goblin HP after axe: ", goblin.hp)
    var tab := InputEventKey.new()
    tab.keycode = KEY_TAB
    tab.pressed = true
    game._unhandled_input(tab)
    aim_at(raider.position)
    await frames(18)
    # Restore the raider's live recovery and pursuit on the impact tick.
    game.player.struck.connect(func(_actor): raider.target = game.player, CONNECT_ONE_SHOT)
    await strike(raider.position)
    print("Raider HP after maul: ", raider.hp)
    hit_targets = hit_targets and goblin.hp <= 0 and raider.hp < raider.maximum
    await frames(12)
