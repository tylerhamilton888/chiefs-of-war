extends Node
## Bramm fits the near wheel until the player brings the axle timber. His boots
## stay on the ground while his upper body and the mallet move through the tap.
const FrameArt = preload("res://scripts/ogre_frame_art.gd")
const ATLAS := preload("res://assets/chapter/bramm_work.png")
const ART := preload("res://resources/chapter/bramm_work.json")
const WORK_SPOT := Vector2(564, 707)
const CONTACT := Vector2(88, -74)
enum Task { FREE, WHEEL, THANKS, BOWL }

const STAND := 0
const SIGHT := 1
const RAISE := 2
const TAP := 3
const TAKE_BOWL := 4
const SIP := 5
const WHEEL_POSES: Array[int] = [SIGHT, RAISE, TAP, SIGHT, RAISE, TAP, SIGHT, STAND]
const DURATIONS: Array[float] = [0.90, 0.36, 0.16, 0.44, 0.28, 0.20, 0.70, 1.50]

var actor
var task := Task.FREE
var beat := 0
var clock := 0.0
var cycles := 0

func begin_wheel() -> void:
    task = Task.WHEEL
    actor.position = WORK_SPOT
    actor.route = []
    actor.drive = Vector2.ZERO
    actor.velocity = Vector2.ZERO
    actor.face(Vector2.RIGHT)
    pose(SIGHT)

func finish_repair() -> void:
    task = Task.THANKS
    clock = 0.0
    actor.velocity = Vector2.ZERO
    actor.drive = Vector2.ZERO
    actor.face(actor.game.player.position - actor.position)
    actor.show_frame(0)

func accept_bowl() -> void:
    task = Task.BOWL
    clock = 0.0
    actor.velocity = Vector2.ZERO
    actor.drive = Vector2.ZERO
    actor.face(actor.game.player.position - actor.position)
    pose(TAKE_BOWL)

func pause_work() -> void:
    if task == Task.WHEEL:
        beat = 0
        clock = 0.0
    actor.show_frame(0)

func advance(delta: float) -> bool:
    if task == Task.FREE:
        return false
    actor.drive = Vector2.ZERO
    actor.velocity = Vector2.ZERO
    clock += delta
    match task:
        Task.WHEEL:
            var duration := DURATIONS[beat]
            if beat == WHEEL_POSES.size() - 1:
                duration += [0.0, 1.37, 0.58][cycles % 3]
            if clock >= duration:
                clock -= duration
                beat = (beat + 1) % WHEEL_POSES.size()
                if beat == 0:
                    cycles += 1
                elif WHEEL_POSES[beat] == TAP:
                    actor.game.hearth_cue("hammer", actor.global_position + CONTACT)
            actor.face(Vector2.RIGHT)
            pose(WHEEL_POSES[beat])
        Task.THANKS:
            if clock < 1.35:
                actor.show_frame(0)
            else:
                task = Task.FREE
        Task.BOWL:
            if clock < 3.25:
                pose(SIP if clock >= 0.72 and clock < 2.32 else TAKE_BOWL)
            else:
                task = Task.FREE
                actor.show_frame(0)
    return true

func pose(index: int) -> void:
    var mirror: bool = task == Task.BOWL and actor.facing == 1
    FrameArt.cell(actor.sprite, ATLAS, ART.data.frames[index], actor.height / ART.data.height, mirror)
