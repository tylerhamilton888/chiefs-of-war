extends "res://scripts/camp_actor.gd"
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

func _ready() -> void:
    super._ready()
    look_material=ShaderMaterial.new()
    look_material.shader=load("res://scripts/orc_palette.gdshader")
    sprite.material=look_material

func request_attack(direction: Vector2) -> void:
    if dead or action_locked: return
    if attack_time<=0 and dodge_time<=0: attack(direction)
    elif attack_time<0.18 and dodge_time<0.18:
        buffered=0.18
        buffered_direction=direction

func attack(direction: Vector2) -> bool:
    if attack_time>0 or dodge_time>0 or dead or action_locked: return false
    attack_direction=direction.normalized() if direction.length()>0.01 else Vector2.DOWN
    face(attack_direction)
    attack_time=swing_duration
    did_hit=false
    swung.emit()
    return true

func cancel_action() -> void:
    attack_time=0; buffered=0; dodge_time=0; hit_stop=0; velocity=Vector2.ZERO; drive=Vector2.ZERO

func dodge(direction: Vector2) -> void:
    if dodge_cooldown>0 or dead or action_locked: return
    buffered=0
    super.dodge(direction)
    dodge_time=0.22; dodge_cooldown=0.62; invulnerable=0.25

func _physics_process(delta: float) -> void:
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
