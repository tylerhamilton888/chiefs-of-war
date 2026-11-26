extends Node2D
## A settled field drop. The flash of the glint marks it as usable.
const MEAT := preload("res://assets/chapter/field_kitchen/goblin_cut.png")
const WRAPPED := preload("res://assets/chapter/field_kitchen/wrapped_cut.png")
var restrained := false
var elapsed := 0.0

func set_restrained(value: bool) -> void:
    restrained = value
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _draw() -> void:
    var height := 29.0 if restrained else 32.0
    var size := Vector2(34.0 if restrained else 49.0, height)
    var hop := 0.0
    if elapsed < 0.32:
        hop = sin(elapsed / 0.32 * PI) * 15.0
    draw_set_transform(Vector2(0, -1), 0.0, Vector2(1.0, 0.27))
    draw_circle(Vector2.ZERO, size.x * 0.46, Color(0.10, 0.08, 0.05, 0.40), true, -1.0, true)
    draw_set_transform(Vector2.ZERO)
    draw_texture_rect(WRAPPED if restrained else MEAT, Rect2(Vector2(-size.x * 0.5, -height - hop + 2), size), false)
    var glint := maxf(0.0, 1.0 - absf(fposmod(elapsed + 0.3, 2.8) - 0.40) / 0.28)
    if glint > 0.01:
        var at := Vector2(size.x * 0.25, -height + 3.0 - hop)
        var color := Color(1.0, 0.88, 0.56, 0.80 * glint)
        draw_line(at + Vector2.LEFT * 4.0 * glint, at + Vector2.RIGHT * 4.0 * glint, color, 1.4, true)
        draw_line(at + Vector2.UP * 5.0 * glint, at + Vector2.DOWN * 5.0 * glint, color, 1.4, true)
