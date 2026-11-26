extends Polygon2D

## A continuous warp of the registered resting drawing. The belt, hem and feet
## use their authored positions. The three clear rest cells contain one Ogre.
const LEVELS := [0.0, 0.14, 0.30, 0.44, 0.58, 0.68, 1.0]
const LIFT := [0.54, 0.70, 1.0, 0.56, 0.0, 0.0, 0.0]
const PERIOD := 3.5
const SETTLE_TIME := 0.28
var elapsed := 0.0
var active_rect := Rect2()
var mirrored := false
var rest_vertices := PackedVector2Array()

func _ready() -> void:
    hide()

func stop(source: Sprite2D) -> void:
    if visible:
        hide()
        source.show()
    elapsed = 0.0

func breathe(source: Sprite2D, delta: float) -> void:
    elapsed += delta
    if elapsed <= SETTLE_TIME:
        return
    var rect := source.region_rect
    if rect != active_rect or source.flip_h != mirrored:
        active_rect = rect
        mirrored = source.flip_h
        prepare_mesh(rect)
    # Render with the same transform, tint, atlas and chosen hair palette.
    transform = source.transform
    material = source.material
    texture = source.texture
    modulate = source.modulate
    var amplitude := 0.5 - 0.5 * cos((elapsed - SETTLE_TIME) * TAU / PERIOD)
    var vertices := rest_vertices.duplicate()
    for i in LEVELS.size():
        var rise: float = 3.2 * LIFT[i] * amplitude
        vertices[2*i].y -= rise
        vertices[2*i+1].y -= rise
    polygon = vertices
    source.hide()
    show()

func prepare_mesh(rect: Rect2) -> void:
    var tex_coords := PackedVector2Array()
    var strips: Array[PackedInt32Array] = []
    rest_vertices.clear()
    for i in LEVELS.size():
        var t: float = LEVELS[i]
        var y := rect.size.y * (t - 0.5)
        rest_vertices.append(Vector2(-0.5 * rect.size.x, y))
        rest_vertices.append(Vector2(0.5 * rect.size.x, y))
        var v := rect.position.y + t * rect.size.y
        tex_coords.append(Vector2(rect.end.x if mirrored else rect.position.x, v))
        tex_coords.append(Vector2(rect.position.x if mirrored else rect.end.x, v))
        if i > 0:
            var p := 2 * i
            strips.append(PackedInt32Array([p-2, p-1, p+1, p]))
    polygon = rest_vertices
    uv = tex_coords
    polygons = strips
