extends "res://scripts/ogre_actor.gd"
signal struck(actor)
signal felled(actor)
var identity="player"
var height=160.0
var art: Dictionary={}
var game
var route: Array=[]
var route_index=0
var rest=2.0
var hp=160.0
var maximum=160.0
var guard=100.0
var guarding=false
var guard_age=10.0
var attack_time=0.0
var attack_done=false
var dodge_time=0.0
var stun=0.0
var flash=0.0
var cooldown=0.0
var locked=Vector2.DOWN
var hostile=false
var companion=false
var ai_time=0.0
var target: Node2D
var combat_art: Dictionary={}
var walking_art: Texture2D
var action_art: Texture2D
func _ready() -> void:
    super._ready()
    var path="res://resources/chapter/"+identity+".json"
    if FileAccess.file_exists(path):
        art=JSON.parse_string(FileAccess.get_file_as_string(path));frames=art.frames
        walking_art=load("res://assets/chapter/"+identity+".png");sprite.texture=walking_art
    var action_path="res://resources/chapter/"+identity+"_combat.json"
    if FileAccess.file_exists(action_path):
        combat_art=JSON.parse_string(FileAccess.get_file_as_string(action_path))
        action_art=load("res://assets/chapter/"+identity+"_combat.png")
    collision_layer=2;collision_mask=1
    show_frame(0)
func show_frame(index: int) -> void:
    if art.is_empty():super.show_frame(index);return
    frame_index=clampi(index,0,3)
    var row=0 if facing==0 else 2 if facing==3 else 1
    var r: Array=frames[row][frame_index]
    apply_region(r,walking_art,facing==1,height/float(art.height))
func apply_region(r: Array,texture: Texture2D,mirror: bool,factor: float) -> void:
    sprite.texture=texture;sprite.region_rect=Rect2(r[0],r[1],r[2],r[3]);sprite.flip_h=mirror
    sprite.scale=Vector2.ONE*factor;sprite.position=Vector2((r[4] if r.size()>4 else 0)*factor*(-1 if mirror else 1),-r[3]*factor/2.0+3)
func action_pose(index: int) -> void:
    if combat_art.is_empty():show_frame(1 if index==1 else 0);return
    var row=0 if facing==0 else 2 if facing==3 else 1
    apply_region(combat_art.frames[row][index],action_art,facing==1,height/float(combat_art.height))
func direction() -> Vector2:return [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP][facing]
func attack(aim: Vector2) -> bool:
    if not enabled or hp<=0 or attack_time>0 or dodge_time>0 or stun>0 or cooldown>0:return false
    face(aim);locked=aim.normalized();attack_time=0.6 if not hostile else 1.15;attack_done=false;guarding=false;return true
func dodge(aim: Vector2) -> bool:
    if not enabled or hp<=0 or dodge_time>0 or attack_time>0.35 or guard<25 or stun>0:return false
    locked=aim.normalized() if aim.length()>0.1 else direction();dodge_time=0.3;guard-=25;guarding=false;attack_time=0;return true
func block(value: bool,aim: Vector2) -> void:
    if value and not guarding:guard_age=0
    guarding=value and enabled and hp>0 and stun<=0 and attack_time<=0 and dodge_time<=0 and guard>0
    if guarding:face(aim)
func receive_hit(amount: float,source_direction: Vector2) -> void:
    if hp<=0 or dodge_time>0.07:return
    if guarding and direction().dot(-source_direction)>0.2:
        if guard_age<0.18:
            game.parry(self);guard=minf(100,guard+12);return
        guard=maxf(0,guard-amount*1.2)
        game.sound("block")
        if guard>0:return
        guarding=false;stun=0.7;game.say("Guard broken — move out and recover.")
    hp=maxf(0,hp-amount);flash=0.14;velocity=source_direction*180
    if not hostile:stun=maxf(stun,0.1)
    if hp<=0:attack_time=0;guarding=false;felled.emit(self)
func parried() -> void:
    attack_time=0;stun=1.15;cooldown=1.0;velocity=Vector2.ZERO
func _physics_process(delta: float) -> void:
    if not enabled:return
    flash=maxf(0,flash-delta);cooldown=maxf(0,cooldown-delta);guard_age+=delta;stun=maxf(0,stun-delta)
    sprite.modulate=Color(1.6,0.75,0.65) if flash>0 else Color.WHITE
    if hp<=0:velocity=Vector2.ZERO;action_pose(3);return
    if not guarding and attack_time<=0 and dodge_time<=0:guard=minf(100,guard+22*delta)
    if hostile and is_instance_valid(target) and stun<=0:
        var off=target.position-position
        drive=off.normalized() if off.length()>145 else Vector2.ZERO
        if off.length()<200 and cooldown<=0 and attack_time<=0:attack(off)
    elif companion and is_instance_valid(target):
        var off=target.position-position
        drive=game.route_direction(self,target.position)*0.72 if off.length()>170 else Vector2.ZERO
        if off.length()<170:face(off)
    elif not controlled and not route.is_empty():
        rest-=delta
        if rest<=0:
            var dest=Vector2(route[route_index][0],route[route_index][1])
            drive=game.route_direction(self,dest)*0.35
            if position.distance_to(dest)<35:drive=Vector2.ZERO;rest=3.5;route_index=(route_index+1)%route.size()
    if stun>0:velocity=velocity.move_toward(Vector2.ZERO,1500*delta);move_and_slide();action_pose(3)
    elif dodge_time>0:
        dodge_time=maxf(0,dodge_time-delta);velocity=locked*590;move_and_slide();action_pose(3)
    elif attack_time>0:
        var before=attack_time;attack_time=maxf(0,attack_time-delta)
        var contact=0.32 if not hostile else 0.35
        velocity=Vector2.ZERO
        action_pose(1 if attack_time>contact else 2)
        if before>contact and attack_time<=contact and not attack_done:attack_done=true;struck.emit(self)
        if attack_time<=0:cooldown=0.08 if not hostile else 0.65
    elif guarding:velocity=Vector2.ZERO;action_pose(3)
    else:super._physics_process(delta)
    queue_redraw()
func _draw() -> void:
    super._draw()
    draw_set_transform(Vector2.ZERO)
    if hostile and hp>0:
        draw_line(Vector2(-55,-height-14),Vector2(55,-height-14),Color("211c18"),7)
        draw_line(Vector2(-55,-height-14),Vector2(-55+110*hp/maximum,-height-14),Color("ce654a"),5)
        if attack_time>0.35:
            var a=locked.angle()
            draw_arc(Vector2.ZERO,205,a-0.55,a+0.55,20,Color("eeb668"),4)
