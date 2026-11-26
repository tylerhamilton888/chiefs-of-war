extends SceneTree
## A short contact and cadence regression for the campaign player's shared body.
const Actor = preload("res://scripts/chapter/actor.gd")
var failures := 0
var footfalls := 0

func _initialize() -> void:
    run.call_deferred()

func check(ok: bool, reason: String) -> void:
    if not ok:
        failures += 1
        push_error(reason)

func run() -> void:
    var player := Actor.new()
    for action in ["move_left", "move_right", "move_up", "move_down"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
    root.add_child(player)
    player.stepped.connect(func(): footfalls += 1)
    player.face(Vector2.RIGHT)
    player.show_frame(1)
    var first := player.sprite.region_rect
    player.show_frame(3)
    var second := player.sprite.region_rect
    check(first.position.y > second.end.y, "Profile contacts should alternate opposite lead-foot drawings")
    for direction in [Vector2.DOWN, Vector2.UP]:
        player.face(direction)
        player.show_frame(1)
        var contact := player.sprite.region_rect
        check(not player.sprite.flip_h, "First contact uses the illustrated facing")
        player.show_frame(3)
        check(contact == player.sprite.region_rect and player.sprite.flip_h, "Opposite foot uses the mirrored whole-body contact")
    var start := player.position
    Input.action_press("move_left")
    for tick in 120:
        await physics_frame
    Input.action_release("move_left")
    check(player.facing == 1 and player.sprite.flip_h, "Left movement mirrors the entire profile")
    var distance := start.distance_to(player.position)
    check(distance > 295 and distance < 315, "Two seconds of walking should cover approximately 310 world units")
    check(footfalls == 4, "Two seconds of ordinary walking should yield four distinct footfalls")
    for tick in 15:
        await physics_frame
    check(player.frame_index == 0 and player.velocity.is_zero_approx(), "Releasing movement returns to a stationary pose")
    Input.action_press("move_left")
    Input.action_press("move_up")
    var steady := true
    for tick in 45:
        await physics_frame
        steady = steady and player.facing == 1
    Input.action_release("move_left")
    Input.action_release("move_up")
    check(steady, "An even diagonal should hold the last viewing angle throughout the step")
    for tick in 12:
        await physics_frame
    var shift := InputEventKey.new()
    shift.keycode = KEY_SHIFT
    shift.physical_keycode = KEY_SHIFT
    shift.pressed = true
    Input.parse_input_event(shift)
    for action in ["move_right", "move_down", "move_left", "move_up"]:
        Input.action_press(action)
        var poses := {}
        start = player.position
        for tick in 60:
            await physics_frame
            if player.sprite.texture == player.RUN_TEXTURE:
                poses[player.sprite.region_rect.position] = true
        check(poses.size() == 4, action + " plays all four authored running poses")
        check(start.distance_to(player.position) > 220, action + " moves at run speed")
        check(player.sprite.flip_h == (action == "move_left"), "Mirror the side atlas only for west")
        check(player.sprite.self_modulate.a == 1, "Run sprite visible after registered walk")
        for polygon in player.sprite.get_children():
            check(not polygon.visible, "No previous walk polygons over the running figure")
        Input.action_release(action)
        for tick in 12:
            await physics_frame
    shift.pressed = false
    Input.parse_input_event(shift)
    check(player.sprite.texture == player.MOTION_TEXTURE and player.frame_index == 0, "Run settles into normal idle")
    print("HEARTH WALK: %d failures" % failures)
    player.queue_free()
    await process_frame
    quit(1 if failures else 0)
