extends RefCounted
const IDLE=preload("res://assets/overhaul/clan_idle.png")
const PORTRAITS=preload("res://assets/polish/clan_portraits.png")
const DECOR=preload("res://assets/polish/decor.png")
const DECOR_RECTS=[Rect2(10,34,312,266),Rect2(324,100,466,205),Rect2(790,153,320,146),Rect2(1113,67,322,240),Rect2(10,318,360,352),Rect2(424,375,285,300),Rect2(738,388,365,296),Rect2(1112,381,324,292),Rect2(34,680,272,375),Rect2(409,661,187,379),Rect2(698,681,353,366),Rect2(1067,679,371,365)]
static func idle(sprite: Sprite2D, who: int, alternate: bool=false, height: float=94.0) -> void:
    var xs=[0,410,790,1170,1536]
    var row:=1 if alternate else 0
    var rect=Rect2(xs[who],row*512,xs[who+1]-xs[who],512)
    sprite.texture=IDLE;sprite.region_enabled=true;sprite.region_rect=rect
    sprite.scale=Vector2.ONE*(height/500.0)
    sprite.offset=Vector2.ZERO
    sprite.position=Vector2(0,(256-506)*height/500.0+4)
static func prop(index: int,pos: Vector2,width: float) -> Sprite2D:
    var s=Sprite2D.new();s.texture=DECOR;s.region_enabled=true;s.region_rect=DECOR_RECTS[index]
    s.scale=Vector2.ONE*(width/s.region_rect.size.x)
    s.position=pos-Vector2(0,s.region_rect.size.y*s.scale.y*0.5)
    return s
