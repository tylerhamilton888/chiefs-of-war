extends RefCounted
## Travel is sampled from the swing clock so a contact hold freezes the step too.
const STEP := 32.0
const REACH := 96.0
const EDGE_WIDTH := 24.0

static func distance_at(elapsed: float, from_run := false) -> float:
    if from_run:
        # Carry approach speed into the plant and brake through contact.
        var t := clampf(elapsed / 0.25, 0.0, 1.0)
        return STEP * t * (2.0 - t)
    return STEP * smoothstep(0.105, 0.235, elapsed)

static func reaches(offset: Vector2, aim: Vector2, radius: float) -> bool:
    var forward := offset.dot(aim)
    if forward <= 0.0:
        return false
    var nearest := aim * clampf(forward, 16.0, REACH)
    return offset.distance_squared_to(nearest) <= (EDGE_WIDTH + radius) ** 2
