extends "res://scripts/camp_actor.gd"
const Appearance=preload("res://scripts/appearance.gd")
signal stepped
signal swung
var speed:=190.0
var swing_duration:=0.56
var contact_time:=0.22
var buffered:=0.0
var buffered_direction:=Vector2.DOWN
var foot_distance:=0.0
var recoil:=Vector2.ZERO
var hit_stop:=0.0
var action_locked:=false
var look_material: ShaderMaterial
var guarding:=false
var guard_direction:=Vector2.DOWN
var guard:=100.0
var guard_break:=0.0
var parry_time:=0.0
var parry_cooldown:=0.0
var block_flash:=0.0
var defense_texture: Texture2D
var defense_frames: Array=[]
const DEFENSE_SCALE:=0.55
const DEFENSE_HEADS=[
 [Vector2(131,87),Vector2(389,88),Vector2(629,94),Vector2(882,109),Vector2(1135,92),Vector2(1373,80)],
 [Vector2(111,332),Vector2(385,336),Vector2(569,355),Vector2(818,364),Vector2(1081,361),Vector2(1371,333)],
 [Vector2(143,571),Vector2(368,574),Vector2(638,594),Vector2(932,607),Vector2(1181,601),Vector2(1404,577)],
 [Vector2(129,790),Vector2(363,790),Vector2(605,805),Vector2(895,813),Vector2(1125,812),Vector2(1375,790)]
]
func equip(set_name: String) -> void:
    super.equip(set_name)
    var outfit="iron" if set_name=="iron" else "leather"
    defense_texture=load("res://assets/overhaul/defense_"+outfit+".png")
    defense_frames=JSON.parse_string(FileAccess.get_file_as_string("res://resources/defense_"+outfit+".json"))
func begin_guard(direction: Vector2) -> bool:
    if dead or action_locked or guard_break>0 or dodge_time>0 or attack_time>0.18 or guard<=0:return false
    if guarding:return true
    attack_time=0;buffered=0;guarding=true
    guard_direction=direction.normalized() if direction.length()>0.01 else Vector2.DOWN
    face(guard_direction)
    if parry_cooldown<=0:parry_time=0.18;parry_cooldown=0.55
    return true
func end_guard() -> void:
    guarding=false;parry_time=0
func defend(attacker_direction: Vector2,cost: float) -> String:
    if not guarding or guard_break>0 or guard_direction.dot(attacker_direction.normalized())<0.35:return "hit"
    block_flash=0.16
    if parry_time>0:
        parry_time=0;guard=minf(100,guard+12);hit_stop=0.06;return "parry"
    guard=maxf(0,guard-cost)
    if guard<=0:
        end_guard();guard_break=0.65;buffered=0;return "break"
    hit_stop=0.035;return "block"
func show_defense(index: int) -> void:
    if defense_texture==null or defense_frames.is_empty():return
    var r: Array=defense_frames[facing][index]
    sprite.texture=defense_texture;sprite.region_rect=Rect2(r[0],r[1],r[2],r[3]);sprite.scale=Vector2.ONE*DEFENSE_SCALE
    sprite.position=(sprite.region_rect.get_center()-Vector2(r[4],r[5]))*DEFENSE_SCALE+Vector2(0,4)
    if look_material:
        look_material.set_shader_parameter("head_clear_up",-0.62)
        var head: Vector2=DEFENSE_HEADS[facing][index]
        look_material.set_shader_parameter("body_size",Vector2(defense_texture.get_width(),defense_texture.get_height()))
        look_material.set_shader_parameter("head_direction",facing)
        look_material.set_shader_parameter("head_box",Vector4(head.x,head.y,46,54))
        look_material.set_shader_parameter("iron_cloth",equipment=="iron")


func _ready() -> void:
    super._ready()
    look_material=ShaderMaterial.new()
    look_material.shader=load("res://scripts/orc_palette.gdshader")
    sprite.material=look_material

func request_attack(direction: Vector2) -> void:
    if dead or action_locked or guarding or guard_break>0: return
    if attack_time<=0 and dodge_time<=0: attack(direction)
    elif attack_time<0.18 and dodge_time<0.18:
        buffered=0.18
        buffered_direction=direction

func attack(direction: Vector2) -> bool:
    if attack_time>0 or dodge_time>0 or dead or action_locked or guarding or guard_break>0: return false
    attack_direction=direction.normalized() if direction.length()>0.01 else Vector2.DOWN
    face(attack_direction)
    attack_time=swing_duration
    did_hit=false
    swung.emit()
    return true

func cancel_action() -> void:
    end_guard()
    attack_time=0; buffered=0; dodge_time=0; hit_stop=0; velocity=Vector2.ZERO; drive=Vector2.ZERO

func dodge(direction: Vector2) -> void:
    if dodge_cooldown>0 or dead or action_locked: return
    end_guard()
    buffered=0
    super.dodge(direction)
    dodge_time=0.22; dodge_cooldown=0.62; invulnerable=0.25

func _physics_process(delta: float) -> void:
    guard_break=maxf(0,guard_break-delta);parry_time=maxf(0,parry_time-delta);parry_cooldown=maxf(0,parry_cooldown-delta);block_flash=maxf(0,block_flash-delta)
    if not guarding and guard_break<=0:guard=minf(100,guard+delta*30)
    if guarding and controlled:
        var aim=get_global_mouse_position()-global_position
        if aim.length()>8:guard_direction=aim.normalized();face(guard_direction)
    invulnerable=maxf(0,invulnerable-delta)
    dodge_cooldown=maxf(0,dodge_cooldown-delta)
    hit_flash=maxf(0,hit_flash-delta)
    sprite.modulate=Color(1.7,0.72,0.6) if hit_flash>0 else Color.WHITE
    if dead or action_locked: return
    if hit_stop>0:
        hit_stop-=delta
        return
    if attack_time<=0 and dodge_time<=0 and buffered>0:
        buffered=0
        attack(buffered_direction)
    buffered=maxf(0,buffered-delta)
    var direction:=Input.get_vector("move_left","move_right","move_up","move_down") if controlled else drive
    var desired:=direction*speed
    if guarding:desired*=0.38
    if guard_break>0:desired*=0.25
    if attack_time>0: desired*=0.45 if did_hit else 0.65
    if dodge_time>0:
        dodge_time=maxf(0,dodge_time-delta)
        velocity=drive*480
    else: velocity=velocity.move_toward(desired,delta*2300)
    velocity+=recoil
    recoil=recoil.move_toward(Vector2.ZERO,delta*2100)
    var before:=position
    move_and_slide()
    var traveled:=before.distance_to(position)
    if attack_time>0:
        var previous:=attack_time
        attack_time=maxf(0,attack_time-delta)
        if not did_hit and attack_time<=swing_duration-contact_time:
            did_hit=true
            impact.emit(attack_direction)
        var t: float=swing_duration-attack_time
        var idx:=0 if t<0.07 else 1 if t<contact_time else 2 if t<contact_time+0.13 else 3
        show_attack(idx)
        if attack_time<=0 and buffered>0:
            buffered=0
            attack(buffered_direction)
        return
    if dodge_time>0:
        show_defense(2 if dodge_time>0.18 else 3 if dodge_time>0.09 else 4 if dodge_time>0.03 else 5)
        queue_redraw();return
    if guarding:
        show_defense(1 if block_flash>0 else 0);queue_redraw();return
    if traveled>0.1:
        face(velocity)
        if dodge_time<=0:
            phase=fposmod(phase+traveled*4.0/STRIDE_DISTANCE,4.0)
            foot_distance+=traveled
            if foot_distance>=STRIDE_DISTANCE*0.5:
                foot_distance-=STRIDE_DISTANCE*0.5
                stepped.emit()
    else:
        phase=0.0
        foot_distance=0.0
    show_locomotion(traveled>0.1 and dodge_time<=0)
    queue_redraw()

func show_attack(index: int) -> void:
    if attack_texture==null: return
    sprite.texture=attack_texture
    var r: Array=attack_rects[facing][index]
    sprite.region_rect=Rect2(r[0],r[1],r[2],r[3])
    sprite.scale=Vector2.ONE*0.33
    sprite.position=Vector2(0,(float(r[3])*0.5-float(r[4]))*0.33+4)
    Appearance.frame(look_material,sprite.texture,sprite.region_rect,facing,"strike",index)

func show_locomotion(moving: bool) -> void:
    super.show_locomotion(moving)
    if look_material:Appearance.frame(look_material,sprite.texture,sprite.region_rect,facing,"stride" if moving else "rest",int(phase)%4 if moving else 0)
func refresh_appearance_frame() -> void:
    if not look_material:return
    var action="strike" if sprite.texture==attack_texture else "stride" if sprite.texture==walk_texture else "rest"
    var index=clampi(int(sprite.region_rect.position.x/512),0,3)
    Appearance.frame(look_material,sprite.texture,sprite.region_rect,facing,action,index)

func _draw() -> void:
    if guarding or guard<99 or guard_break>0:
        draw_line(Vector2(-23,13),Vector2(23,13),Color("30271e"),4)
        draw_line(Vector2(-23,13),Vector2(-23+46*guard/100,13),Color("cfaa66") if guard_break<=0 else Color("b44f3b"),4)
    if guarding:
        var a=guard_direction.angle()
        draw_arc(Vector2.ZERO,29,a-1.18,a+1.18,20,Color("e9d49b") if parry_time>0 else Color("8f9f9a"),2)
