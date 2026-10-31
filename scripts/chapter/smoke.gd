extends Node2D
var clock=0.0
func _process(delta: float) -> void:clock+=delta;queue_redraw()
func _draw() -> void:
    for i in range(9):
        var rise=fposmod(clock*26+i*24,220)
        draw_circle(Vector2(sin(i*2.7+clock*.3)*25+rise*.2,-rise),18+rise*.18,Color(.15,.13,.12,(1.0-rise/220)*.27))
    for i in range(5):
        var x=(i-2)*12;var tip=80+sin(clock*7+i)*24
        draw_colored_polygon(PackedVector2Array([Vector2(x-17,5),Vector2(x+14,3),Vector2(x+sin(i+clock)*15,-tip)]),Color(1,.35+i*.06,.05,.9))
