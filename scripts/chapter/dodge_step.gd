extends RefCounted
## One collision-driven step. The lead boot catches the Ogre before control returns.
const DURATION := 0.30
const DISTANCE := 149.0
const PUSH_OFF := 0.055
const FIRST_CONTACT := 0.17
const PLANTED := 0.245
const BODY = preload("res://scripts/ogre_frame_art.gd")
static func distance_at(elapsed: float) -> float:
    # Cumulative distance makes both the burst and the stationary plant independent
    # of physics step size. move_and_slide still resolves terrain at every tick.
    return DISTANCE * smoothstep(0.0, PLANTED, elapsed)

static func pose(actor, elapsed: float) -> void:
    var view := 0 if actor.facing == 0 else 2 if actor.facing == 3 else 1
    var mirror: bool = actor.facing == 1 if view == 1 else actor.locked.x < -0.1
    var index := 0 if elapsed < PUSH_OFF else 1 if elapsed < FIRST_CONTACT else 2
    if index == 1 and view != 1 and absf(actor.locked.y) > absf(actor.locked.x):
        index = 3 # Toward/away from the camera, the lead boot is foreshortened.
    if actor.dodge_drawing.is_empty():
        actor.action_pose(3)
        return
    var data: Dictionary = actor.dodge_drawing
    BODY.cell(actor.sprite, actor.dodge_texture, data.rows[view][index], actor.height / float(data.height), mirror)
