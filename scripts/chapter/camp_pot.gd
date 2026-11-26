extends Node2D
## Ground origin sits on the lowest stone. The painted lip frames the broth.
const POT := preload("res://assets/chapter/field_kitchen/hearth_pot.png")
const CUT := preload("res://assets/chapter/field_kitchen/goblin_cut.png")
const POT_RECT := Rect2(-72, -140, 144, 144)
const MOUTH := Vector2(0, -117)
const TOSS_TIME := 0.48
var servings := 0
var elapsed := 0.0
var toss := TOSS_TIME
var already_simmering := false
var toss_from := Vector2.ZERO
var ripple := 1.0

func set_servings(count: int, animate := false, hand_local := Vector2.ZERO) -> void:
    var next := maxi(0, count)
    if animate:
        if next > servings:
            toss_from = hand_local
            already_simmering = servings > 0
            toss = 0.0
        ripple = 0.0
    servings = next
    queue_redraw()

func _process(delta: float) -> void:
    elapsed = fmod(elapsed + delta, 120.0)
    if toss < TOSS_TIME:
        toss += delta
        if toss >= TOSS_TIME:
            ripple = 0.0
    ripple = minf(ripple + delta, 1.0)
    queue_redraw()

func _draw() -> void:
    draw_texture_rect(POT, POT_RECT, false)
    if servings > 0 and (toss >= TOSS_TIME or already_simmering):
        # The surface, oil and ingredients share the opening's foreshortening.
        draw_set_transform(MOUTH, 0.0, Vector2(1.0, 0.28))
        draw_circle(Vector2.ZERO, 39.0, Color("572a16"), true, -1.0, true)
        draw_circle(Vector2(0, 1.5), 35.0, Color("a94e20"), true, -1.0, true)
        draw_arc(Vector2(-3, 3), 28.0, 0.35, 2.65, 20, Color("e69f42"), 2.8, true)
        for i in mini(6, servings + 2):
            var angle := i * 2.38 + elapsed * 0.19
            var center := Vector2(cos(angle) * (17.0 + (i % 2) * 10.0), sin(angle) * 19.0)
            draw_circle(center, 4.2 if i % 2 == 0 else 2.8, Color("69351e") if i % 2 == 0 else Color("c4a752"), true, -1.0, true)
        if ripple < 0.65:
            draw_arc(Vector2.ZERO, 6.0 + 43.0 * ripple, 0.0, TAU, 28, Color(1.0, 0.76, 0.43, 0.8 - ripple), 2.8, true)
        draw_set_transform(Vector2.ZERO)
        draw_steam()
    if toss < TOSS_TIME:
        var t := toss / TOSS_TIME
        var center := toss_from.lerp(MOUTH, t) + Vector2.UP * (sin(t * PI) * 46.0)
        draw_set_transform(center, -0.6 + t * 1.2, Vector2.ONE)
        draw_texture_rect(CUT, Rect2(-13, -9, 26, 18), false)
        draw_set_transform(Vector2.ZERO)

func draw_steam() -> void:
    for i in 3:
        var phase := fposmod(elapsed * 0.41 + float(i) / 3.0, 1.0)
        var base := MOUTH + Vector2((i - 1) * 14.0, -48.0 * phase)
        var points := PackedVector2Array()
        for j in 6:
            var height_offset := j * 2.6
            points.append(base + Vector2(sin(phase * TAU + i + j * 0.49) * (2.5 + phase * 3.0), -height_offset))
        draw_polyline(points, Color(1.0, 0.89, 0.73, 0.55 * sin(phase * PI)), 2.2, true)
