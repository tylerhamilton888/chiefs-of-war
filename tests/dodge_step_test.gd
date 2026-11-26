extends SceneTree

const Actor = preload("res://scripts/chapter/actor.gd")
const Step = preload("res://scripts/chapter/dodge_step.gd")

var checks := 0
var failures := 0

func _initialize() -> void:
    run.call_deferred()

func check(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(label)

func run() -> void:
    for action in ["move_up", "move_down", "move_left", "move_right"]:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
    var player := Actor.new()
    root.add_child(player)
    await physics_frame
    for weapon in player.WEAPONS.data:
        player.equip_weapon(weapon)
        for aim in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
            player.face(aim)
            var origin := player.position
            check(player.dodge(aim), "Dodge accepted while ready")
            check(not player.attack(aim) and not player.dodge(aim), "Dodge cannot overlap a swing or second dodge")
            player.receive_hit(10, -aim)
            check(player.hp == 160, "Burst evades contact")
            var frames := {}
            var planted := Vector2.ZERO
            var ticks := 0
            while player.dodge_time > 0.0 and ticks < 26:
                frames[player.sprite.region_rect] = true
                check(player.sprite.texture == player.dodge_texture, "The selected weapon stays in both hands")
                if player.dodge_time < Step.DURATION - Step.PLANTED:
                    if planted == Vector2.ZERO:
                        planted = player.position
                    else:
                        check(planted.is_equal_approx(player.position), "No slide after the foot plants")
                await physics_frame
                ticks += 1
            var travel := player.position - origin
            check(frames.size() == 3, "Compression, drive and catch are different drawings")
            if aim.y != 0:
                var row := 0 if aim.y > 0 else 2
                var cell: Array = player.dodge_drawing.rows[row][3]
                check(frames.has(Rect2(cell[0], cell[1], cell[2], cell[3])), "The boot foreshortens in a depth step")
            check(travel.is_equal_approx(aim * Step.DISTANCE), "Dodge covers registered distance along the chosen input")
            check(player.dodge_time == 0 and player.velocity.length() < 0.01, "Dodge ends planted")
        player.face(Vector2.DOWN)
        check(player.dodge(Vector2.LEFT), "Cross-step starts while facing the viewer")
        check(player.facing == 0 and player.sprite.flip_h, "Cross-step keeps the threat in view and pushes toward input")
        for tick in 24:
            await physics_frame
    var wall := StaticBody2D.new()
    var collider := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(16, 220)
    collider.shape = shape
    wall.add_child(collider)
    wall.position = Vector2(80, 0)
    root.add_child(wall)
    player.position = Vector2.ZERO
    await physics_frame
    player.face(Vector2.RIGHT)
    player.dodge(Vector2.ZERO)
    for tick in 26:
        await physics_frame
    check(player.position.x > 1 and player.position.x < 72, "Fallback facing moves toward wall without crossing it")
    player.dodge(Vector2.LEFT)
    while player.dodge_time > 0.065:
        await physics_frame
    player.receive_hit(10, Vector2.RIGHT)
    check(player.hp == 150 and player.dodge_time == 0, "Recovery can take a hit and cancels the leftover dodge")
    player.queue_free()
    wall.queue_free()
    await process_frame
    print("Dodge step: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
