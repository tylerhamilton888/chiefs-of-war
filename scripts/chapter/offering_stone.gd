extends StaticBody2D
## The family's offering stone and shallow bronze dish beside the cookfire.
const STONE = preload("res://assets/environment/props.png")
const CAMP = preload("res://assets/ogre/traveling_camp.png")

var offered := false:
    set(value):
        offered = value
        queue_redraw()

func _ready() -> void:
    var obstacle := CollisionShape2D.new()
    var stone_base := RectangleShape2D.new()
    stone_base.size = Vector2(50, 18)
    obstacle.position = Vector2(0, -8)
    obstacle.shape = stone_base
    add_child(obstacle)

func _draw() -> void:
    draw_texture_rect_region(STONE, Rect2(-38, -44, 76, 46), Rect2(45, 590, 440, 405))
    draw_set_transform(Vector2(0, -31), 0, Vector2(1, 0.4))
    draw_circle(Vector2(0, 3), 20, Color("30271e"), true, -1, true)
    draw_circle(Vector2.ZERO, 19, Color("c29952"), true, -1, true)
    draw_circle(Vector2.ZERO, 16, Color("664a2f"), true, -1, true)
    draw_set_transform(Vector2.ZERO)
    if offered:
        # Cut the serving from the existing cookfire illustration using its painted outline.
        var pixels := PackedVector2Array([Vector2(530,810), Vector2(535,789), Vector2(532,781),
            Vector2(536,775), Vector2(544,777), Vector2(546,785), Vector2(580,789),
            Vector2(600,798), Vector2(605,810), Vector2(589,829), Vector2(573,835),
            Vector2(549,831), Vector2(534,824)])
        var vertices := PackedVector2Array()
        var uv := PackedVector2Array()
        for point in pixels:
            vertices.append((point - Vector2(568, 827)) * 0.36 + Vector2(0, -31))
            uv.append(point / CAMP.get_size())
        draw_polygon(vertices, PackedColorArray([Color.WHITE]), uv, CAMP)
