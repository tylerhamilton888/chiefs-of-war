extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
    exercise.call_deferred()

func verify(value: bool, detail: String) -> void:
    checks += 1
    if not value:
        failures += 1
        push_error(detail)

func exercise() -> void:
    var game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    game.choose("work")
    var cook = game.npcs.svala
    var work = cook.camp_work
    var kettle = work.pot
    verify(kettle.tended and kettle.servings == 0, "Family stock heats without granting a ration")
    verify(cook.position == kettle.position + work.STANCE, "Svala is within ladle reach")
    var feet = cook.position
    var poses := {}
    var water: Array[Vector2] = []
    for i in 540:
        await physics_frame
        poses[work.painted_pose] = true
        if kettle.ladle_ripple < 0.055 and not Vector2(kettle.ladle_at).is_zero_approx():
            water.append(kettle.ladle_at)
    verify(cook.position == feet, "Boots remain planted while cooking")
    verify(poses.has(work.Pose.NEAR) and poses.has(work.Pose.FAR) and poses.has(work.Pose.SWEEP), "Three different strokes pass through the steaming pot")
    verify(poses.has(work.Pose.TASTE), "She checks her stock between stirring cycles")
    verify(water.any(func(t): return t.x < -5.0) and water.any(func(t): return t.x > 5.0), "The ladle makes distinct near and far water contact")

    game.dialogue("svala_food")
    await physics_frame
    verify(not cook.enabled and work.painted_pose == -1 and not work.ladle_at_lip.visible, "Her spoon comes out of the scene while she speaks")
    game.close_modal()
    await physics_frame
    await physics_frame
    verify(cook.enabled and work.painted_pose >= 0, "She resumes her work after conversation")

    var station: Dictionary = game.stations.filter(func(entry): return entry.kind == "hearth" and entry.id == "crossing")[0]
    game.state.inventory.wood = 2
    game.state.inventory.meat = 2
    game.interact(station)
    verify(game.state.inventory.meals == 3 and kettle.family_dish > 0.0, "Ordinary cooking shows the dish without altering the three packed meals")
    poses.clear()
    for i in 150:
        await physics_frame
        poses[work.painted_pose] = true
    verify(poses.has(work.Pose.OFFER), "Svala offers the completed meal")
    game.state.inventory.goblin_meat = 1
    game.interact(station)
    verify(work.reaction and work.sequence == work.CHECK_STOCK and kettle.servings == 2, "Svala tastes the newly contributed ingredient")
    game.interact(station)
    verify(work.sequence == work.SERVE and kettle.servings == 1, "Taking a portion cues her serving gesture")

    game.state.region = "host"
    game.state.chapter = 6
    game.rebuild()
    verify(game.npcs.svala.camp_work == null and not game.camp_pot.tended, "The surviving family has different work in the Stonebelly Host")
    game.prepare_exit()
    game.queue_free()
    await process_frame
    print("Svala at the fire: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
