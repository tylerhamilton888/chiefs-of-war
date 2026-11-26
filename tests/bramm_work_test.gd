extends SceneTree

const Work = preload("res://scripts/chapter/bramm_work.gd")
const State = preload("res://scripts/chapter/state.gd")
var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func wait_ticks(count: int) -> void:
    for i in count:
        await physics_frame

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    if FileAccess.file_exists(State.SAVE):
        push_error("Use a disposable save directory for Bramm's work test")
        quit(1)
        return
    var game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    await wait_ticks(3)
    game.choose("work")
    var bramm = game.npcs.bramm
    var work = bramm.camp_work
    check(work.task == Work.Task.WHEEL, "The damaged wheel has its wheelwright")
    var at: Vector2 = bramm.position
    var poses := {}
    for i in 220:
        await physics_frame
        if bramm.sprite.texture == Work.ATLAS:
            poses[bramm.sprite.region_rect] = true
    check(poses.size() == 4, "Four whole-body work drawings reach the screen")
    check(bramm.position == at, "Bramm's foot origin stays planted while working")

    game.freeze(true)
    var paused_clock: float = work.clock
    await wait_ticks(40)
    check(work.clock == paused_clock and bramm.sprite.texture != Work.ATLAS, "Frozen dialogue controls the speaker pose")
    game.freeze(false)
    game.state.inventory.wood = 6
    game.interact({"kind": "repair"})
    await wait_ticks(6)
    check(work.task == Work.Task.THANKS and bramm.sprite.texture != Work.ATLAS, "Repair puts down the mallet")
    check(bramm.facing == 2 or bramm.facing == 0, "Bramm turns toward the player after repair")
    work.accept_bowl()
    await wait_ticks(5)
    var received: Rect2 = bramm.sprite.region_rect
    await wait_ticks(52)
    check(bramm.sprite.texture == Work.ATLAS and bramm.sprite.region_rect != received, "Two bowl poses show the first mouthful")
    await wait_ticks(165)
    check(work.task == Work.Task.FREE and bramm.sprite.texture != Work.ATLAS, "Bramm returns to his ordinary route")
    game.rebuild()
    await wait_ticks(4)
    check(game.npcs.bramm.camp_work.task == Work.Task.FREE, "Revisiting a repaired wheel keeps work finished")
    game.prepare_exit()
    await create_timer(0.2).timeout
    game.queue_free()
    await process_frame
    print("Bramm's wagon and bowl: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
