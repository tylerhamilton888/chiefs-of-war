extends Node2D
const Art=preload("res://scripts/clan_art.gd")
var target: Node2D
var enabled:=true
var open_front:=false
var openness:=0.0
var leaves=[]
var clock:=0.0
func _ready() -> void:
    for side in 2:
        var s=Sprite2D.new();s.texture=Art.DECOR;s.region_enabled=true
        # Only the wooden leaves; existing building art supplies the outer jamb.
        s.region_rect=Rect2(1120+side*132,753,132,247)
        s.centered=false;s.scale=Vector2(0.18,0.24);s.position=Vector2(-24+side*24,-61)
        add_child(s);leaves.append(s)
func _process(delta: float) -> void:
    clock+=delta
    var nearby:=enabled and is_instance_valid(target) and target.global_position.distance_to(global_position)<90 and target.global_position.y>global_position.y-15
    openness=move_toward(openness,1.0 if nearby else 0.0,delta*5)
    for i in 2:
        leaves[i].visible=not open_front
        leaves[i].scale.x=0.18*(1.0-openness*0.91)
        leaves[i].position.x=-24 if i==0 else 24-132*leaves[i].scale.x
    visible=enabled
    queue_redraw()
func _draw() -> void:
    if not enabled:return
    if not open_front:draw_rect(Rect2(-25,-62,50,64),Color("1b1712"))
    draw_rect(Rect2(-31,0,62,6),Color("82705a"))
    draw_line(Vector2(-31,0),Vector2(31,0),Color("b5a07a"),2)
    if openness>0.15:
        if not open_front:draw_rect(Rect2(-24,-56,48,54),Color(0.72,0.39,0.13,0.12*openness))
        draw_colored_polygon(PackedVector2Array([Vector2(-22,4),Vector2(22,4),Vector2(36,25),Vector2(-36,25)]),Color(0.8,0.49,0.19,0.13*openness))
