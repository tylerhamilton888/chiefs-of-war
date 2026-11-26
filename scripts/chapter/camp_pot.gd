extends Node2D
## Ground origin sits on the lowest stone. The painted lip frames the broth.
const POT := preload("res://assets/chapter/field_kitchen/hearth_pot.png")
const CUT := preload("res://assets/chapter/field_kitchen/goblin_cut.png")
const POT_RECT := Rect2(-72, -140, 144, 144)
const COOKFIRE := preload("res://shaders/cookfire.gdshader")
const MOUTH := Vector2(0, -117)
const TOSS_TIME := 0.48
static var falloff: GradientTexture2D
var fire_material := ShaderMaterial.new()
var light_pool := Sprite2D.new()
var steam_burst := 0.0
var wood_smoke: Array[Sprite2D] = []
var tended := false
var ladle_ripple := 1.0
var ladle_at := Vector2.ZERO
var family_dish := 0.0
var servings := 0
var elapsed := 0.0
var toss := TOSS_TIME
var already_simmering := false
var toss_from := Vector2.ZERO
var ripple := 1.0

func _ready() -> void:
    if falloff == null:
        var colors := Gradient.new()
        colors.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
        colors.colors = PackedColorArray([Color.WHITE, Color(1, 1, 1, 0.32), Color(1, 1, 1, 0)])
        falloff = GradientTexture2D.new()
        falloff.width = 96
        falloff.height = 96
        falloff.gradient = colors
        falloff.fill = GradientTexture2D.FILL_RADIAL
        falloff.fill_from = Vector2(0.5, 0.5)
        falloff.fill_to = Vector2(1.0, 0.5)
    light_pool.texture = falloff
    light_pool.scale = Vector2(237, 89) / 96.0
    light_pool.position = Vector2(0, -10)
    light_pool.show_behind_parent = true
    add_child(light_pool)
    for i in 5:
        var puff := Sprite2D.new()
        puff.texture = falloff
        puff.show_behind_parent = true
        puff.modulate.a = 0.0
        add_child(puff)
        wood_smoke.append(puff)
    var kettle := Sprite2D.new()
    kettle.texture = POT
    kettle.scale = POT_RECT.size / Vector2(POT.get_size())
    kettle.position = POT_RECT.get_center()
    kettle.show_behind_parent = true
    fire_material.shader = COOKFIRE
    kettle.material = fire_material
    add_child(kettle)

func set_tended(value: bool) -> void:
    tended = value
    queue_redraw()

func finish_family_dish() -> void:
    # The ordinary recipe immediately packs its servings. Let the finished
    # dish show for one serving gesture, without creating stored pot stock.
    family_dish = 1.65
    steam_burst = 1.0
    ripple = 0.0
    queue_redraw()

func touch_water(at: Vector2) -> void:
    if tended or servings > 0:
        ladle_at = Vector2(clampf(at.x - MOUTH.x, -21.0, 21.0), clampf(at.y - MOUTH.y, -3.5, 3.5))
        ladle_ripple = 0.0

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
    var ember := 0.57 + 0.18 * sin(elapsed * 6.6) + 0.13 * sin(elapsed * 10.2 + 0.8) + 0.10 * sin(elapsed * 2.1)
    fire_material.set_shader_parameter("fire_clock", elapsed)
    fire_material.set_shader_parameter("ember", ember)
    light_pool.modulate = Color(0.96, 0.44, 0.12, 0.11 + 0.13 * ember)
    for i in wood_smoke.size():
        var t := fposmod(elapsed * 0.40 + float(i) / wood_smoke.size(), 1.0)
        var puff := wood_smoke[i]
        puff.position = Vector2(-38.0 - t * 39.0 - sin(t * PI) * 12.0 + 3.0 * sin(t * 9.0 + elapsed), -22.0 - 115.0 * t)
        puff.scale = Vector2(9.0 + t * 26.0, 15.0 + t * 27.0) / 96.0
        puff.modulate = Color(0.82, 0.77, 0.68, 0.18 * sin(t * PI))
    family_dish = maxf(0.0, family_dish - delta)
    ladle_ripple = minf(1.0, ladle_ripple + delta * 1.7)
    steam_burst = maxf(0.0, steam_burst - delta * 1.25)
    if toss < TOSS_TIME:
        toss += delta
        if toss >= TOSS_TIME:
            ripple = 0.0
            steam_burst = 1.0
    ripple = minf(ripple + delta, 1.0)
    queue_redraw()

func _draw() -> void:
    draw_cinders()
    if family_dish > 0.0 or (servings > 0 and (toss >= TOSS_TIME or already_simmering)):
        # The surface, oil and ingredients share the opening's foreshortening.
        draw_set_transform(MOUTH, 0.0, Vector2(1.0, 0.28))
        draw_circle(Vector2.ZERO, 39.0, Color("572a16"), true, -1.0, true)
        draw_circle(Vector2(0, 1.5), 35.0, Color("a94e20"), true, -1.0, true)
        draw_texture_rect(falloff, Rect2(-31, -17, 47, 49), false, Color("db8f3ab8"))
        draw_arc(Vector2(-3, 3), 28.0, 0.35, 2.65, 20, Color("d68f3c"), 2.0, true)
        for i in mini(6, servings + 2):
            var angle := i * 2.38 + elapsed * 0.19
            var center := Vector2(cos(angle) * (17.0 + (i % 2) * 10.0), sin(angle) * 19.0)
            if i % 2 == 0:
                draw_texture_rect(CUT, Rect2(center - Vector2(6, 6), Vector2(12, 14)), false, Color("e6af80"))
            else:
                draw_circle(center, 2.8, Color("b7a451"), true, -1.0, true)
        if ripple < 0.65:
            draw_arc(Vector2.ZERO, 6.0 + 43.0 * ripple, 0.0, TAU, 28, Color(1.0, 0.76, 0.43, 0.8 - ripple), 2.8, true)
        draw_set_transform(Vector2.ZERO)
        draw_steam()
    elif tended:
        # Clear water catching firelight; only cooked stew has an amber surface
        # and meat. The camp pot can be tended before the player brings food.
        draw_set_transform(MOUTH + Vector2(0, 3), 0.0, Vector2(1.0, 0.23))
        draw_circle(Vector2.ZERO, 33.0, Color("272527"), true, -1.0, true)
        var sheen := Color(0.54, 0.48, 0.40, 0.38 + 0.10 * sin(elapsed * 1.7))
        draw_arc(Vector2.ZERO, 28.0, 0.47, 1.9, 16, sheen, 2.4, true)
        draw_set_transform(Vector2.ZERO)
        draw_steam(0.19)
    if ladle_ripple < 1.0:
        draw_set_transform(MOUTH + ladle_at, 0.0, Vector2(1.0, 0.27))
        var light := Color(0.94, 0.78, 0.49, (1.0 - ladle_ripple) * 0.74)
        draw_arc(Vector2.ZERO, lerpf(2.5, 14.0, ladle_ripple), 0.0, TAU, 20, light, 2.4, true)
        draw_set_transform(Vector2.ZERO)
    if toss < TOSS_TIME:
        var t := toss / TOSS_TIME
        var center := toss_from.lerp(MOUTH, t) + Vector2.UP * (sin(t * PI) * 46.0)
        draw_set_transform(center, -0.6 + t * 1.2, Vector2.ONE)
        draw_texture_rect(CUT, Rect2(-13, -9, 26, 18), false)
        draw_set_transform(Vector2.ZERO)

func draw_cinders() -> void:
    # An occasional coal lifts from the edge of the stone ring and cools.
    for i in 2:
        var phase := fposmod(elapsed + i * 1.64, 2.9)
        if phase >= 0.75:
            continue
        var t := phase / 0.75
        var side := -1.0 if i == 0 else 1.0
        var at := Vector2(side * (26.0 + 16.0 * t) + sin(8.0 * t + i) * 2.8, -20.0 - t * 30.0)
        var glow := sin(t * PI)
        draw_line(at + Vector2(0.7 * side, -1.8), at, Color(1, 0.57, 0.19, glow * 0.82), 1.65, true)

func draw_steam(strength := 1.0) -> void:
    # Overlapping soft wisps keep the edges feathered as each curl separates.
    for i in 3:
        var phase := fposmod(elapsed * 0.39 + float(i) / 3.0, 1.0)
        var base := MOUTH + Vector2((i - 1) * 13.0, -(42.0 + 17.0 * steam_burst) * phase)
        for j in 7:
            var lift := j * 2.8
            var drift := sin(phase * TAU + i * 0.8 + j * 0.39) * (3.7 + phase * 5.0)
            var width := 5.0 + j * 0.6 + phase * 7.0
            var size := Vector2(width, width * 1.22)
            var center := base + Vector2(drift, -lift)
            var opacity := 0.38 * sin(phase * PI) * sin((j + 1) * PI / 8) * strength * (1.0 + 0.36 * steam_burst)
            draw_texture_rect(falloff, Rect2(center - size * 0.5, size), false, Color(0.98, 0.91, 0.78, opacity))
