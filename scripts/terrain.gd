extends Node2D
var state: RefCounted
var last_revision := -1
var water_bodies: Dictionary = {}
var texture := preload("res://assets/environment/grass.png")
func _process(_delta: float) -> void:
    if last_revision!=state.revision:
        last_revision=state.revision
        rebuild_water()
        queue_redraw()
func rebuild_water() -> void:
    for key in water_bodies.keys():
        if state.terrain.get(key)!="water":
            remove_child(water_bodies[key])
            water_bodies[key].queue_free()
            water_bodies.erase(key)
    for key in state.terrain:
        if state.terrain[key]!="water" or water_bodies.has(key):
            continue
        var xy: PackedStringArray=key.split(",")
        var body:=StaticBody2D.new()
        body.position=Vector2(float(xy[0])*32+16,float(xy[1])*32+16)
        var col:=CollisionShape2D.new()
        var rect:=RectangleShape2D.new()
        rect.size=Vector2(32,32)
        col.shape=rect
        body.add_child(col)
        add_child(body)
        water_bodies[key]=body
func _draw() -> void:
    draw_texture_rect(texture,Rect2(0,0,1536,1024),true,Color(0.50,0.55,0.45))
    for key in state.terrain:
        var xy: PackedStringArray=key.split(",")
        var rect:=Rect2(float(xy[0])*32,float(xy[1])*32,32,32)
        var color:=Color("493f32") if state.terrain[key]=="earth" else Color("283f44")
        draw_rect(rect,color)
        if state.terrain[key]=="earth":
            draw_texture_rect_region(texture,rect,Rect2(rect.position,rect.size),Color(0.31,0.23,0.15,0.58))
        else:
            draw_line(rect.position+Vector2(5,13),rect.position+Vector2(22,13),Color(0.35,0.48,0.48,0.3),1)
