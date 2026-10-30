extends Node2D
var kind:=0
var integrity:=1.0
var parts: Array[float]=[1.0,1.0,1.0]
var panels=[]
var body:=StaticBody2D.new()
func _ready() -> void:
    var texture=load("res://assets/camp/architecture.png")
    var region: Rect2=[Rect2(0,0,600,550),Rect2(605,0,495,550),Rect2(1120,0,416,550)][kind]
    var factor:=0.56 if kind==0 else 0.60
    add_child(body)
    for i in 3:
        var sprite=Sprite2D.new()
        sprite.texture=texture
        sprite.region_enabled=true
        sprite.region_rect=Rect2(region.position+Vector2(i*region.size.x/3,0),Vector2(region.size.x/3,region.size.y))
        sprite.scale=Vector2.ONE*factor
        sprite.position=Vector2((i-1)*region.size.x/3*factor,-region.size.y*factor*0.5+20)
        add_child(sprite)
        panels.append(sprite)
        var c=CollisionShape2D.new()
        var s=RectangleShape2D.new()
        s.size=Vector2(78,120)
        c.shape=s
        c.position=Vector2((i-1)*78,-65)
        body.add_child(c)
func _process(_delta: float) -> void:
    for i in 3:
        panels[i].modulate=Color.WHITE.lerp(Color(0.38,0.30,0.25),1-parts[i])
        panels[i].visible=parts[i]>0
        body.get_child(i).disabled=parts[i]<=0
    queue_redraw()
func _draw() -> void:
    for i in 3:
        if parts[i]>0: continue
        var x=(i-1)*78
        draw_rect(Rect2(x-38,-90,76,105),Color("39332a"))
        for j in 3: draw_line(Vector2(x-30+j*21,-80),Vector2(x-10+j*18,8),Color("65503a"),6)
