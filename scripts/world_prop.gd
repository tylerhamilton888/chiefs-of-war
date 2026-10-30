extends Node2D
## A separately rendered, separately colliding instance linked to a persistent ID.
var data: Dictionary
var body: StaticBody2D
var sprite: Sprite2D
var flame_time := 0.0
var collision_state := ""
var player: Node2D
var canopy_alpha:=1.0
const RECTS := {"tree":Rect2(45,0,440,558),"stump":Rect2(590,190,360,345),"log":Rect2(1045,95,455,435),"rock":Rect2(45,590,440,405),"wall":Rect2(555,570,420,385),"roof":Rect2(1030,555,475,435)}
const SCALES := {"tree":0.53,"stump":0.14,"log":0.16,"rock":0.25,"wall":0.22,"roof":0.39}

func _ready() -> void:
    position=Vector2(data.x,data.y)
    body=StaticBody2D.new()
    add_child(body)
    sprite=Sprite2D.new()
    sprite.texture=load("res://assets/environment/props.png")
    sprite.region_enabled=true
    add_child(sprite)
    refresh()

func refresh() -> void:
    var kind: String=data.kind
    var state: String=data.state
    if state=="collected" or (state in ["destroyed","charred"] and kind not in ["tree","rock"]):
        visible=false
    else:
        visible=true
    if kind=="tree" and state!="intact":
        kind="stump"
    sprite.visible=kind!="hearth"
    if RECTS.has(kind):
        sprite.region_rect=RECTS[kind]
        sprite.scale=Vector2.ONE*SCALES[kind]
        sprite.position=Vector2(0,-RECTS[kind].size.y*SCALES[kind]*0.5+7)
        sprite.modulate=Color(0.25,0.24,0.22) if state=="charred" else Color(0.81,0.83,0.79)
    if collision_state!=state:
        collision_state=state
        for c in body.get_children():
            body.remove_child(c)
            c.queue_free()
        if state=="intact" and data.kind in ["tree","rock","wall","hearth"]:
            var col:=CollisionShape2D.new()
            if data.kind=="wall":
                var shape:=RectangleShape2D.new()
                shape.size=Vector2(84,20)
                col.shape=shape
            else:
                var shape:=CircleShape2D.new()
                shape.radius=30 if data.kind=="rock" else 18
                col.shape=shape
            body.add_child(col)
    queue_redraw()

func _process(delta: float) -> void:
    flame_time+=delta
    refresh()
    if is_instance_valid(player) and data.kind in ["tree","roof"] and data.state=="intact":
        var relative:=player.global_position-global_position
        var obscures: bool=relative.y<(70 if data.kind=="tree" else 0) and relative.y> -240 and absf(relative.x)<(120 if data.kind=="tree" else 100)
        canopy_alpha=move_toward(canopy_alpha,0.35 if obscures else 1.0,delta*5)
        sprite.modulate.a=canopy_alpha

func _draw() -> void:
    if data.kind=="hearth":
        draw_circle(Vector2.ZERO,24,Color("353535"))
        for i in 9:
            var a:=float(i)/9*TAU
            draw_circle(Vector2(cos(a)*23,sin(a)*13),6,Color("64615b"))
    if data.burning or data.kind=="hearth":
        for i in 5:
            var x:=float(i-2)*6
            var flicker:=sin(flame_time*7+i*1.7)*6
            draw_colored_polygon(PackedVector2Array([Vector2(x-7,-4),Vector2(x+7,-4),Vector2(x+flicker,-31-absf(flicker)*2)]),Color(1,0.28+float(i)*0.07,0.04,0.88))
        draw_circle(Vector2(0,-8),8,Color(1,0.75,0.2,0.9))
    elif data.heat>0.2:
        draw_arc(Vector2(0,-8),22,-PI, -PI+PI*float(data.heat),16,Color(0.95,0.55,0.2),2)
    if data.hp<100 and data.state=="intact" and data.kind!="hearth":
        draw_line(Vector2(-10,-17),Vector2(8,-4),Color(0.1,0.07,0.04),3)
