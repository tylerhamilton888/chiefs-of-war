extends PanelContainer
## A short line spoken over the work. Does not take input or stop the scene.
var speaker: Node2D
var line := Label.new()
var remaining := 0.0
var lift := 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style := StyleBoxFlat.new()
    style.bg_color = Color("241e19ed")
    style.border_color = Color("9a7752")
    style.border_width_bottom = 2
    style.set_corner_radius_all(4)
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 6
    style.content_margin_bottom = 5
    add_theme_stylebox_override("panel", style)
    line.mouse_filter = Control.MOUSE_FILTER_IGNORE
    line.add_theme_font_size_override("font_size", 19)
    line.add_theme_color_override("font_color", Color("fff1d7"))
    line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    add_child(line)
    hide()

func speak(actor: Node2D, words: String, listeners: Array) -> void:
    speaker = actor
    line.text = words
    reset_size()
    remaining = clampf(1.4 + words.length() * 0.058, 3.4, 5.8)
    modulate.a = 1.0
    show()
    lift = 0.0
    place_above_speaker()
    # Keep the caption off other faces in a crowded conversation. Choose the
    # height once so the line stays steady if someone walks past afterward.
    for person in listeners:
        if person == actor or not is_instance_valid(person):
            continue
        var head: Vector2 = person.get_global_transform_with_canvas() * Vector2(0, -person.height * 0.9)
        var face := Rect2(head - Vector2(24, 19), Vector2(48, 38))
        if get_rect().intersects(face):
            lift = maxf(lift, position.y + size.y - face.position.y + 6.0)
    place_above_speaker()

func place_above_speaker() -> void:
    var top: Vector2 = speaker.get_global_transform_with_canvas() * Vector2(0, -speaker.height - 8.0)
    var bounds := get_viewport_rect().size
    position = Vector2(clampf(top.x - size.x * 0.5, 12.0, bounds.x - size.x - 12.0),
        clampf(top.y - size.y - lift, 103.0, bounds.y - size.y - 115.0)).round()

func _process(delta: float) -> void:
    if not visible:
        return
    remaining -= delta
    if not is_instance_valid(speaker) or not speaker.is_inside_tree() or remaining <= 0.0:
        hide()
        return
    place_above_speaker()
    modulate.a = minf(1.0, remaining / 0.28)
