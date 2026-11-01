extends RefCounted
## Continuous world units: area 1 : 2 : 4, never a movement grid.
const UNIT=32.0
const SMALL_HEIGHT=80.0
const LARGE_HEIGHT=113.137085
const OGRE_HEIGHT=160.0
const RIDGEBACK_HEIGHT=240.0
const RIDGEBACK_RADIUS=64.0
const COMPANION_HEIGHT=149.0
const COMPANION_RADIUS=40.0
const SETTLEMENT_SCALE=0.72
static func radius(species: String,stature: float=1.0) -> float:
    return UNIT*0.5*sqrt(2.0 if species=="orc" else 4.0 if species=="ogre" else 1.0)*stature
static func body_radius(actor: Node2D) -> float:
    for child in actor.get_children():
        if child is CollisionShape2D and child.shape is CircleShape2D:return child.shape.radius
    return 16.0
static func clear_step(actor: Node2D,step: Vector2) -> bool:
    var shape=CircleShape2D.new();shape.radius=body_radius(actor)+2.0
    var query=PhysicsShapeQueryParameters2D.new();query.shape=shape
    query.collision_mask=1;query.transform=Transform2D(0,actor.global_position);query.motion=step
    var space=actor.get_world_2d().direct_space_state
    # cast_motion ignores initial overlaps; allow an already obstructed save to escape.
    var result=space.cast_motion(query)
    return result[0]>=0.99
