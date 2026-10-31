extends CharacterBody2D
var game
var sprite=Sprite2D.new()
var enabled=true
var phase=0.0
var facing=1
var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://resources/chapter/beast.json"))
var load_sprite: Node2D
func _ready() -> void:
    collision_layer=0;collision_mask=1
    var col=CollisionShape2D.new();var shape=CircleShape2D.new();shape.radius=32;col.shape=shape;add_child(col)
    sprite.texture=load("res://assets/chapter/beast.png");sprite.region_enabled=true;add_child(sprite)
    load_sprite=Sprite2D.new();load_sprite.texture=load("res://assets/ogre/traveling_camp.png");load_sprite.region_enabled=true;load_sprite.region_rect=Rect2(804,665,710,325);load_sprite.scale=Vector2.ONE*0.13;load_sprite.position=Vector2(-20,-120);add_child(load_sprite)
func _physics_process(delta: float) -> void:
    if not enabled:return
    var a=game.state.animal
    var dest=game.player.position+Vector2(-190,90)
    if a.command=="haul" and not a.cargo.is_empty() and game.state.region==game.state.camp_region and not game.state.packed:dest=Vector2(690,950)
    var off=dest-position
    velocity=Vector2.ZERO
    if a.tamed and a.command!="stay" and off.length()>80:
        velocity=game.route_direction(self,dest)*(140 if a.fed>0 else 100)
        if off.length()>600:velocity*=1.25
    var before=position;move_and_slide();phase=fposmod(phase+position.distance_to(before)/160,1)
    if velocity.length()>1:facing=0 if absf(velocity.x)>absf(velocity.y) else 1 if velocity.y>0 else 2
    var r=data.frames[facing][int(phase*4)];sprite.region_rect=Rect2(r[0],r[1],r[2],r[3]);sprite.scale=Vector2.ONE*0.48;sprite.position=Vector2(0,-r[3]*0.24);sprite.flip_h=velocity.x<0
    load_sprite.visible=not a.cargo.is_empty()
    if a.command=="haul" and not a.cargo.is_empty() and position.distance_to(dest)<100 and game.state.region==game.state.camp_region and not game.state.packed:
        game.state.deliver(a.cargo);a.trust=mini(100,a.trust+3);a.command="follow";game.say("Flint has brought the load to your wagon.");game.save_progress()
