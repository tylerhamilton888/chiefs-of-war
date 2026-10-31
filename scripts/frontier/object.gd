extends StaticBody2D
const Atlas=preload("res://scripts/frontier/atlas.gd")
var game
var id=""
var data: Dictionary={}
var sprite=Sprite2D.new()
var col=CollisionShape2D.new()
var flash=0.0
func _ready() -> void:
    position=Vector2(data.position[0],data.position[1]);collision_layer=1;collision_mask=0
    var shape=RectangleShape2D.new();shape.size=Vector2(100,40) if data.kind in ["log","barricade","barn"] else Vector2(80,60);col.shape=shape;col.position.y=-10;add_child(col);add_child(sprite);refresh()
func refresh() -> void:
    visible=not data.taken
    var broken=data.hp<=0 and data.kind in ["boulder","barricade","barn"]
    col.set_deferred("disabled",data.taken or broken or data.kind in ["log","spoils"])
    if data.kind=="spoils":Atlas.pose(sprite,"great_beast",11,105);return
    var rects={"log":Rect2(1060,170,450,360),"tree":Rect2(4,0,505,562),"boulder":Rect2(32,585,480,390),"barricade":Rect2(553,550,465,420),"barn":Rect2(553,550,465,420)}
    var sizes={"log":0.34,"tree":0.50,"boulder":0.34,"barricade":0.40,"barn":0.62}
    sprite.texture=load("res://assets/overhaul/props.png");sprite.region_enabled=true;sprite.region_rect=rects[data.kind];sprite.scale=Vector2.ONE*sizes[data.kind]
    sprite.position=Vector2(0,-sprite.region_rect.size.y*sprite.scale.y*0.5+8)
    if broken:sprite.scale.y*=0.28;sprite.position.y=-15;sprite.modulate=Color("8a7664")
func damage(amount: float) -> void:
    if data.taken or data.hp<=0 or data.kind in ["log","spoils"]:return
    data.hp=maxf(0,data.hp-amount);flash=0.12;game.sound("gather")
    if data.hp<=0:
        if data.kind=="tree":
            data.kind="log";data.hp=1;data.yield={"wood":8};game.say("A whole trunk. E to shoulder it; X to set it down.")
        else:game.state.grant(data.yield);game.contracts.event(id+"_broken");game.object_broken(id)
        refresh();game.save_progress()
func _process(delta: float) -> void:
    flash=maxf(0,flash-delta)
    if flash>0:sprite.modulate=Color(1.4,1.15,0.8)
    elif data.hp>0:sprite.modulate=Color.WHITE
