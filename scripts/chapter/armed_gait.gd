extends RefCounted
## Whole, armed poses. The texture contains an advance and a lateral step for
## each viewing angle. Reversing footfall order lets the Ogre back away on guard.
const STRIDE := 110.0
const DATA_PATH := "res://resources/ogre/%s_walk.json"
const ART_PATH := "res://assets/ogre/%s_walk.png"
const RUN_SHEETS := {
    "hunting_axe": preload("res://assets/ogre/hunting_axe_run.png"),
    "iron_maul": preload("res://assets/ogre/iron_maul_run.png"),
}

static func run_pose(actor, facing: int, phase: float) -> void:
    var row := 0 if facing == 0 else 2 if facing == 3 else 1
    var index := floori(fposmod(phase, 1.0) * 4.0)
    var frame := [index * 480, row * 304, 480, 304, 240, 282]
    preload("res://scripts/ogre_frame_art.gd").cell(actor.sprite, RUN_SHEETS[actor.equipped_weapon], frame, actor.height / 280.0, facing == 1)

static var definitions: Dictionary = {}
static var textures: Dictionary = {}

static func pose(actor, move_direction: Vector2, cycle: float) -> void:
    var weapon: String = actor.equipped_weapon
    if not definitions.has(weapon):
        definitions[weapon] = load(DATA_PATH % weapon).data
        textures[weapon] = load(ART_PATH % weapon)
    var data: Dictionary = definitions[weapon]
    var facing: Vector2 = actor.direction()
    var fore := facing.dot(move_direction)
    var side := Vector2(facing.y, -facing.x).dot(move_direction)
    var lateral := absf(side) > absf(fore)
    var row := 0 if actor.facing == 0 else 2 if actor.facing == 3 else 1
    var frames: Array = data.strafe_rows[row] if lateral else data.rows[row]
    # Profile sidesteps were painted toward the viewer; mirroring east to
    # west preserves that travel direction on screen.
    var shuffle_direction := move_direction.y if actor.facing in [1, 2] else side
    var reverse := (shuffle_direction if lateral else fore) < 0.0
    var phase := fposmod(-cycle if reverse else cycle, 1.0)
    var index := mini(frames.size()-1, floori(phase * frames.size()))
    var frame: Array = frames[index]
    var factor: float = actor.height / data.height
    # The rear maul walk was drawn with the iron on the opposite side of its ready pose.
    var mirror: bool = actor.facing == 1 or (row == 2 and weapon == "iron_maul")
    preload("res://scripts/ogre_frame_art.gd").cell(actor.sprite, textures[weapon], frame, factor, mirror)
