extends Node
## Svala's work belongs to the family cookpot at Emberhide Crossing.
const FRAME_ART = preload("res://scripts/ogre_frame_art.gd")
const SHEET = preload("res://assets/chapter/household/svala_ladle.png")
const STANCE := Vector2(-68, -63)
const CELL := Vector2i(280, 300)
const FOOT := Vector2(90, 288)
const ART_HEIGHT := 280.0

enum Pose { NEAR, FAR, TASTE, OFFER, SWEEP, LIFT }
const STIR := [Pose.NEAR, Pose.SWEEP, Pose.FAR, Pose.SWEEP, Pose.NEAR]
const STIR_HOLD := [0.57, 0.18, 0.43, 0.19, 0.81]
const CHECK_STOCK := [Pose.LIFT, Pose.TASTE, Pose.LIFT]
const CHECK_HOLD := [0.38, 0.93, 0.31]
const SERVE := [Pose.SWEEP, Pose.FAR, Pose.LIFT, Pose.OFFER, Pose.LIFT]
const SERVE_HOLD := [0.2, 0.38, 0.37, 1.1, 0.34]

# These are just the distal ends of the painted ladles. Draw them against the
# inside lip even though Svala stands behind the pot. The far rim hides her hands.
const DISTAL := {
    Pose.NEAR: Rect2(151, 145, 42, 51),
    Pose.FAR: Rect2(185, 150, 69, 47),
    Pose.SWEEP: Rect2(164, 136, 50, 44)
}
const BOWL_POINTS := {Pose.NEAR: Vector2(175, 193), Pose.FAR: Vector2(234, 194)}

var actor
var pot
var ladle_at_lip := Sprite2D.new()
var painted_pose := -1
var sequence: Array = STIR
var holds: Array = STIR_HOLD
var step := 0
var elapsed := 0.0
var cycles := 0
var returning := 0.0
var reaction := false

func begin(worker, kettle) -> void:
    actor = worker
    pot = kettle
    actor.route.clear()
    actor.position = pot.position + STANCE
    actor.velocity = Vector2.ZERO
    actor.facing = 2
    ladle_at_lip.texture = SHEET
    ladle_at_lip.region_enabled = true
    ladle_at_lip.region_filter_clip_enabled = true
    ladle_at_lip.centered = false
    pot.add_child(ladle_at_lip)
    pot.set_tended(true)
    paint(Pose.NEAR)

func pause_work() -> void:
    ladle_at_lip.hide()
    painted_pose = -1
    actor.face(actor.game.player.position - actor.position)
    actor.show_frame(0)

func respond_to_meal(kind: String) -> void:
    if kind == "cook":
        pot.finish_family_dish()
    reaction = true
    cycles = 0
    if kind == "deposit":
        start_sequence(CHECK_STOCK, CHECK_HOLD)
    else:
        start_sequence(SERVE, SERVE_HOLD)

func advance(delta: float) -> bool:
    var to_pot: Vector2 = pot.position + STANCE - actor.position
    # An authored feast can move her. Let her walk back after staging ends.
    if to_pot.length_squared() > 9.0:
        ladle_at_lip.hide()
        painted_pose = -1
        actor.face(to_pot)
        actor.velocity = actor.game.route_direction(actor, pot.position + STANCE) * minf(88.0, to_pot.length() / delta)
        var before: Vector2 = actor.position
        actor.move_and_slide()
        returning += before.distance_to(actor.position)
        actor.show_frame(floori(returning / 20.0) % 4)
        return true
    actor.velocity = Vector2.ZERO
    actor.facing = 2
    if painted_pose == -1:
        paint(sequence[step])
    elapsed += delta
    if elapsed >= float(holds[step]):
        step += 1
        elapsed = 0.0
        if step == sequence.size():
            if reaction or sequence == CHECK_STOCK:
                reaction = false
                start_sequence(STIR, STIR_HOLD)
            else:
                cycles += 1
                if cycles % 3 == 0:
                    start_sequence(CHECK_STOCK, CHECK_HOLD)
                else:
                    start_sequence(STIR, STIR_HOLD)
        else:
            paint(sequence[step])
            var phase: int = sequence[step]
            if BOWL_POINTS.has(phase):
                var tip: Vector2 = actor.position - pot.position + (BOWL_POINTS[phase] - FOOT) * (float(actor.height) / ART_HEIGHT) + Vector2.DOWN * 3.0
                pot.touch_water(tip)
                if phase == Pose.FAR:
                    actor.game.hearth_cue("stir", pot.global_position)
            if reaction and phase == Pose.OFFER:
                actor.game.hearth_cue("serve", pot.global_position)
    return true

func start_sequence(poses: Array, timings: Array) -> void:
    sequence = poses
    holds = timings
    step = 0
    elapsed = 0.0
    if actor.enabled:
        paint(sequence[0])

func paint(pose: int) -> void:
    painted_pose = pose
    var scale_factor: float = actor.height / ART_HEIGHT
    var left := pose * CELL.x
    FRAME_ART.cell(actor.sprite, SHEET, [left, 0, CELL.x, CELL.y, FOOT.x, FOOT.y], scale_factor, false)
    if not DISTAL.has(pose):
        ladle_at_lip.hide()
        return
    var piece: Rect2 = DISTAL[pose]
    ladle_at_lip.scale = Vector2.ONE * scale_factor
    ladle_at_lip.position = actor.position - pot.position + (piece.position - FOOT) * scale_factor + Vector2.DOWN * 3.0
    ladle_at_lip.region_rect = Rect2(piece.position + Vector2(left, 0), piece.size)
    ladle_at_lip.show()
