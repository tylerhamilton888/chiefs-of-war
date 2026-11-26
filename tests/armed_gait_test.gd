extends SceneTree
const ACTOR = preload("res://scripts/chapter/actor.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
    run.call_deferred()

func verify(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func run() -> void:
    for action in ["move_up", "move_down", "move_left", "move_right"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
    var player = ACTOR.new()
    root.add_child(player)
    var actions := ["move_down", "move_left", "move_right", "move_up"]
    var vectors := [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]
    for weapon in player.WEAPONS.data:
        player.equip_weapon(weapon)
        var data: Dictionary = load("res://resources/ogre/%s_walk.json" % weapon).data
        var texture: Texture2D = load("res://assets/ogre/%s_walk.png" % weapon)
        for facing in 4:
            var aim: Vector2 = vectors[facing]
            var row := 0 if facing == 0 else 2 if facing == 3 else 1
            for move_index in 4:
                var action: String = actions[move_index]
                var lateral := aim.dot(vectors[move_index]) == 0.0
                var track: Array = data.strafe_rows[row] if lateral else data.rows[row]
                var cells := {}
                for f in track:
                    var rect := Rect2(f[0], f[1], f[2], f[3])
                    verify(Rect2(Vector2.ZERO, texture.get_size()).encloses(rect), "Cell inside texture")
                    cells[rect] = false
                player.position = Vector2.ZERO
                player.velocity = Vector2.ZERO
                Input.action_press(action)
                for tick in 72:
                    player.track_combat_aim(aim, true)
                    await physics_frame
                    if tick < 2:
                        continue
                    if player.facing != facing or player.sprite.texture != texture:
                        verify(false, "%s must face aim and show selected weapon while moving" % weapon)
                        break
                    if cells.has(player.sprite.region_rect):
                        cells[player.sprite.region_rect] = true
                Input.action_release(action)
                verify(player.position.dot(vectors[move_index]) > 100.0, "Ogre travels in the input direction")
                verify(cells.size() >= 2 and not false in cells.values(), "Every alternate foot-contact / passing pose was used")
        for tick in 12:
            player.track_combat_aim(Vector2.RIGHT, true)
            await physics_frame
        verify(player.sprite.texture == player.action_art, "Stopping returns to equipped ready stance")
    var shift := InputEventKey.new()
    shift.keycode = KEY_SHIFT
    shift.pressed = true
    Input.parse_input_event(shift)
    Input.flush_buffered_events()
    Input.action_press("move_right")
    for tick in 18:
        player.track_combat_aim(Vector2.RIGHT, true)
        await physics_frame
    verify(is_equal_approx(player.velocity.x, player.RUN_SPEED), "Forward run carries into engagement")
    verify(player.sprite.texture == player.ArmedGait.RUN_SHEETS[player.equipped_weapon], "Forward run shows the equipped sprint drawing")
    for tick in 18:
        player.track_combat_aim(Vector2.LEFT, true)
        await physics_frame
    verify(player.velocity.x < player.WALK_SPEED and player.facing == 1, "Retreat keeps its braced gait")
    Input.action_release("move_right")
    shift.pressed = false
    Input.parse_input_event(shift)
    Input.flush_buffered_events()
    for tick in 180:
        player.track_combat_aim(Vector2.RIGHT, false)
        await physics_frame
    verify(player.sprite.texture == player.MOTION_TEXTURE, "Leaving threat returns to exploration")
    player.queue_free()
    await process_frame
    print("Armed gait: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
