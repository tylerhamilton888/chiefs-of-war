extends SceneTree
const Stroke = preload("res://scripts/chapter/cleaver_stroke.gd")
var errors := 0
var checks := 0

func _initialize() -> void:
    run.call_deferred()

func check(value: bool, message: String) -> void:
    checks += 1
    if not value:
        errors += 1
        push_error(message)

func run() -> void:
    var yard = load("res://scenes/developer_arena.tscn").instantiate()
    root.add_child(yard)
    current_scene = yard
    var player = yard.player
    var raider = yard.enemies[1]
    var goblin = yard.enemies[0]
    for foe in yard.enemies:
        foe.active = false
    player.set_physics_process(false)
    await physics_frame
    var origin := Vector2(925, 1100)
    for sector in 8:
        var aim := Vector2.RIGHT.rotated(sector * PI / 4.0)
        var view: String = ["side","front","front","front","side","rear","rear","rear"][sector]
        player.position = origin
        player.cooldown = 0.0
        check(player.attack(aim), "Attack accepted")
        check(player.sprite.texture == player.swing_drawings[view].texture and player.sprite.flip_h == (sector in [3,4,7]), "Edge points into sector %d" % sector)
        check(Stroke.reaches(aim * 96, aim, 16), "Target at edge")
        check(not Stroke.reaches(aim * -12, aim, 16), "Target behind Ogre")
        check(not Stroke.reaches(aim * 72 + aim.orthogonal() * 45, aim, 16), "Target outside sweep")
        check(not Stroke.reaches(aim * 150, aim, 16), "Target out of reach")
        player.update_swing(0.15)
        check(player.position.is_equal_approx(origin), "Feet planted in anticipation")
        player.update_swing(0.18)
        var finish: Vector2 = player.position
        check(finish.distance_to(origin + aim * Stroke.STEP) < 0.1, "One committed step")
        player.update_swing(0.28)
        check(player.position.is_equal_approx(finish), "Feet settle during recovery")
    # Add solid scenery inside the step, then repeat against a living body.
    var wall := StaticBody2D.new()
    var wall_shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = Vector2(10, 150)
    wall_shape.shape = rectangle
    wall.add_child(wall_shape)
    wall.position = origin + Vector2(52, 0)
    yard.world.add_child(wall)
    for target in [wall, raider]:
        if target == raider:
            wall.queue_free()
            raider.position = origin + Vector2(70, 0)
        player.position = origin
        player.cooldown = 0
        await physics_frame
        await physics_frame
        player.attack(Vector2.RIGHT)
        player.update_swing(0.33)
        check(player.position.x > origin.x and player.position.x < origin.x + 19.0, "Solid contact shortens the step")
        player.update_swing(1.0)
    raider.hp = raider.maximum
    raider.posture = 0
    raider.state = "windup"
    raider.receive_weapon_hit(28, Vector2.RIGHT, true)
    check(raider.brace_time > 0 and raider.state == "windup", "Armor keeps a committed counter")
    raider.receive_weapon_hit(28, Vector2.RIGHT, true)
    check(raider.vulnerable > 0, "Repeated hits break posture")
    var place: Vector2 = goblin.position
    goblin.receive_weapon_hit(28, Vector2.LEFT, true)
    goblin.active = true
    for i in 32:
        await physics_frame
    check(goblin.cleaved and place.x - goblin.position.x > 20 and place.x - goblin.position.x < 32, "Goblin falls along the stroke")
    check(yard.state.field_cuts.size() == 1, "Moving body leaves one harvestable cut")
    var toggle := InputEventKey.new()
    toggle.keycode = KEY_V
    toggle.pressed = true
    yard._unhandled_input(toggle)
    var count: int = yard.world.get_child_count()
    yard.impact(origin, Vector2.RIGHT, true)
    check(not player.hit_flash_enabled and not goblin.hit_flash_enabled and yard.world.get_child_count() == count, "Effects off removes hit flash and fragments")
    print("Cleaver stroke: %d checks, %d failures" % [checks, errors])
    quit(1 if errors else 0)
