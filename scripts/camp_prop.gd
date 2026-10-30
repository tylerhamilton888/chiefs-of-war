extends "res://scripts/world_prop.gd"
var previous:=""
const CELLS={"tree":Rect2(4,0,505,562),"stump":Rect2(570,218,445,305),"log":Rect2(1060,170,450,360),"rock":Rect2(32,585,480,390),"wall":Rect2(553,550,465,420),"hearth":Rect2(1062,575,445,390)}
const SCALE={"tree":0.44,"stump":0.13,"log":0.15,"rock":0.21,"wall":0.20,"hearth":0.17}
func refresh() -> void:
    if sprite==null: return
    if previous=="intact" and data.state=="felled":
        var pivot=Node2D.new()
        var falling=Sprite2D.new()
        falling.texture=sprite.texture
        falling.region_enabled=true
        falling.region_rect=sprite.region_rect
        falling.scale=sprite.scale
        falling.position=sprite.position
        pivot.add_child(falling)
        add_child(pivot)
        var t=create_tween()
        t.tween_property(pivot,"rotation",1.5,0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
        t.tween_property(pivot,"modulate:a",0.0,0.3)
        t.tween_callback(pivot.queue_free)
    previous=data.state
    super.refresh()
    var kind: String="stump" if data.kind=="tree" and data.state!="intact" else data.kind
    if CELLS.has(kind):
        sprite.visible=true
        sprite.texture=load("res://assets/overhaul/props.png")
        sprite.region_rect=CELLS[kind]
        sprite.scale=Vector2.ONE*SCALE[kind]
        sprite.position=Vector2(0,-CELLS[kind].size.y*SCALE[kind]*0.5+7)
        sprite.modulate=Color(0.25,0.24,0.22) if data.state=="charred" else Color.WHITE
        if data.kind=="rock" and data.state=="destroyed":
            sprite.scale*=0.38
            sprite.position.y=-12
            sprite.modulate=Color(0.52,0.50,0.46)
func _draw() -> void:
    if data.burning:
        for i in 5:
            var x:=float(i-2)*6
            var flicker:=sin(flame_time*7+i*1.7)*6
            draw_colored_polygon(PackedVector2Array([Vector2(x-7,-4),Vector2(x+7,-4),Vector2(x+flicker,-31-absf(flicker)*2)]),Color(1,0.28+float(i)*0.07,0.04,0.88))
