extends RefCounted
## Emberhide's paths meet where the clan works. Only water cells block movement.
static func mark_crossing(terrain: Dictionary) -> void:
    var paths := [
        PackedVector2Array([Vector2(1060, 120), Vector2(1110, 480), Vector2(1030, 810), Vector2(950, 990), Vector2(1050, 1260)]),
        PackedVector2Array([Vector2(480, 840), Vector2(740, 770), Vector2(950, 865), Vector2(1280, 840), Vector2(1600, 900), Vector2(2120, 900)]),
        PackedVector2Array([Vector2(640, 1010), Vector2(805, 955), Vector2(1030, 1060), Vector2(1190, 1140)])
    ]
    var clearings := [
        Rect2(440, 530, 610, 375), # wagon and space to work at its wheels
        Rect2(1040, 545, 505, 300), # tent apron
        Rect2(810, 915, 490, 295), # hearth and serving area
        Rect2(550, 915, 240, 170) # provision bundles
    ]
    for x in range(3, 70):
        for y in range(2, 42):
            var point := Vector2(x + 0.5, y + 0.5) * 32.0
            var verge := sin(point.x * 0.031 + point.y * 0.013) * 7.0
            var worn := false
            for clearing: Rect2 in clearings:
                var offset := (point - clearing.get_center()) / (clearing.size * 0.5)
                if offset.length_squared() < 1.0 + verge * 0.009:
                    worn = true
                    break
            if not worn:
                for trail: PackedVector2Array in paths:
                    for i in range(1, trail.size()):
                        if point.distance_to(Geometry2D.get_closest_point_to_segment(point, trail[i-1], trail[i])) < 54.0 + verge:
                            worn = true
                            break
                    if worn:
                        break
            if worn:
                terrain["%d,%d" % [x, y]] = "earth"

static var shade: GradientTexture2D

static func add_shadow(body: Node2D, width: float, depth: float) -> void:
    if shade == null:
        var fade := Gradient.new()
        fade.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
        fade.colors = PackedColorArray([Color(0.13, 0.09, 0.06, 0.66), Color(0.16, 0.12, 0.08, 0.40), Color(0.16, 0.12, 0.08, 0.0)])
        shade = GradientTexture2D.new()
        shade.width = 128
        shade.height = 128
        shade.fill = GradientTexture2D.FILL_RADIAL
        shade.fill_from = Vector2(0.5, 0.5)
        shade.fill_to = Vector2(1.0, 0.5)
        shade.gradient = fade
    var shadow := Sprite2D.new()
    shadow.texture = shade
    shadow.scale = Vector2(width, depth) / 128.0
    shadow.position = Vector2(width * 0.025, -depth * 0.16)
    shadow.z_index = -1
    body.add_child(shadow)
