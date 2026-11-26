extends Node2D
## Short contact fragments inherit the direction and material of the hit.
var direction := Vector2.RIGHT
var on_iron := false
var restrained := false
var age := 0.0
const LIFE := 0.25
const ANGLES: Array[float] = [-0.86, -0.44, -0.10, 0.25, 0.65]
const SPEEDS: Array[float] = [110.0, 185.0, 150.0, 200.0, 95.0]

func _process(delta: float) -> void:
    age += delta
    if age >= LIFE:
        queue_free()
        return
    queue_redraw()

func _draw() -> void:
    var t := age / LIFE
    var shade := Color("f2c884") if on_iron else Color("d6bb90") if restrained else Color("863b2e")
    shade.a = 1.0 - t
    for i in ANGLES.size():
        var drift := direction.rotated(ANGLES[i]) * SPEEDS[i]
        var start := drift * age + Vector2(0, -24.0 * age + 145.0 * age * age)
        var tail := drift.normalized() * lerpf(8.0, 2.0, t)
        draw_line(start, start - tail, shade, 2.6 if on_iron else 3.2, true)
    if on_iron and age < 0.048:
        var light := Color(1.0, 0.91, 0.7, (1.0 - age / 0.048) * 0.85)
        draw_line(-direction * 5.0, direction * 8.0, light, 3.5, true)
