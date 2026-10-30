extends CharacterBody2D
signal strike(wolf: Node2D)
signal slain(wolf: Node2D)
var hp:=75.0
var maximum:=75.0
var alpha:=false
var home:=Vector2.ZERO
var target: Node2D
var sprite:=Sprite2D.new()
var stage:="idle"
var clock:=0.0
var cooldown:=0.6
var locked_direction:=Vector2.RIGHT
var phase:=0.0
var flash:=0.0
var stagger:=0.0
var harvested:=false
var loot_id:=""
var offset_recoil:=Vector2.ZERO
var game
var rects: Array
var active:=true
func _ready() -> void:
    home=position
    collision_layer=2; collision_mask=1
    var c=CollisionShape2D.new(); var s=CircleShape2D.new(); s.radius=19; c.shape=s; add_child(c)
    sprite.texture=load("res://assets/opener/wolf.png")
    sprite.region_enabled=true
    rects=JSON.parse_string(FileAccess.get_file_as_string("res://resources/wolf.json"))
    sprite.scale=Vector2.ONE*(0.32 if alpha else 0.25)
    add_child(sprite)
    if alpha: hp=180; maximum=180
    show_pose(0)
func show_pose(index: int) -> void:
    var r: Array=rects[index]
    sprite.region_rect=Rect2(r[0],r[1],r[2],r[3])
    sprite.position=Vector2(0,-float(r[3])*sprite.scale.y*0.40+6)
func _physics_process(delta: float) -> void:
    if not active: return
    flash=maxf(0,flash-delta); cooldown=maxf(0,cooldown-delta); stagger=maxf(0,stagger-delta)
    sprite.modulate=Color(1.8,0.7,0.6) if flash>0 else Color(0.88,0.75,0.60) if alpha else Color.WHITE
    if hp<=0: show_pose(7); return
    if not is_instance_valid(target): return
    var to_player:=target.position-position
    clock+=delta
    if stage=="windup":
        velocity=Vector2.ZERO
        show_pose(4)
        if clock>(0.72 if alpha else 0.62):
            stage="lunge"; clock=0
    elif stage=="lunge":
        velocity=locked_direction*(530 if alpha else 400)
        show_pose(5)
        if clock>0.15:
            strike.emit(self)
            stage="recover"; clock=0; cooldown=1.2 if alpha else 1.0
    elif stage=="recover":
        velocity=Vector2.ZERO; show_pose(0)
        if clock>0.60: stage="idle"; clock=0
    elif stagger>0:
        velocity=offset_recoil; offset_recoil=offset_recoil.move_toward(Vector2.ZERO,delta*1700); show_pose(6)
    else:
        var dest:=target.position if to_player.length()<390 else home
        var offset:=dest-position
        velocity=Vector2.ZERO
        if to_player.length()<150 and cooldown<=0 and game.has_line(position,target.position,null):
            locked_direction=to_player.normalized()
            stage="windup"; clock=0; show_pose(4)
            game.sound("growl")
        elif offset.length()>20:
            velocity=game.route_direction(self,dest)* (105 if alpha else 135)
            phase+=delta*8
            show_pose(int(phase)%4)
        else: show_pose(0)
        if absf(offset.x)>8: sprite.flip_h=offset.x<0
    move_and_slide()
    queue_redraw()
func receive_hit(amount: float,direction: Vector2) -> void:
    if hp<=0: return
    hp=maxf(0,hp-amount); flash=0.13
    if not alpha and stage!="lunge":
        stage="idle"; stagger=0.22; cooldown=maxf(cooldown,0.3); offset_recoil=direction*180
    if hp<=0:
        velocity=Vector2.ZERO; stage="dead"; slain.emit(self)
    queue_redraw()
func _draw() -> void:
    if hp>0 and (hp<maximum or stage!="idle"):
        draw_line(Vector2(-25,-72),Vector2(25,-72),Color("241a15"),5)
        draw_line(Vector2(-25,-72),Vector2(-25+50*hp/maximum,-72),Color("af4937"),5)
    if stage=="windup":
        var reach:=170 if alpha else 145
        var a:=locked_direction.angle()
        draw_colored_polygon(PackedVector2Array([Vector2.ZERO,Vector2.from_angle(a-0.25)*reach,Vector2.from_angle(a+0.25)*reach]),Color(0.9,0.35,0.15,0.18))
        draw_arc(Vector2.ZERO,reach,a-0.25,a+0.25,14,Color(1,0.54,0.26),2)
