extends "res://scripts/orc.gd"
signal impact(direction: Vector2)
var controlled := true
var drive := Vector2.ZERO
var attack_time := 0.0
var attack_direction := Vector2.DOWN
var did_hit := false
var dodge_time := 0.0
var dodge_cooldown := 0.0
var invulnerable := 0.0
var hit_flash := 0.0
var attack_texture: Texture2D
var attack_rects: Array
var walk_texture: Texture2D
var walk_rects: Array
var dead := false

func _ready() -> void:
    super._ready()
    sprite.scale=Vector2.ONE*0.31
    load_walk()
    load_attack()

func load_walk() -> void:
    var suffix:="iron" if equipment=="iron" else "leather"
    walk_texture=load("res://assets/camp/walk_"+suffix+".png")
    walk_rects=JSON.parse_string(FileAccess.get_file_as_string("res://resources/walk_"+suffix+".json"))
    frame_rects=walk_rects
    sprite.texture=walk_texture

func load_attack() -> void:
    var suffix:="iron" if equipment=="iron" else "leather"
    var path:="res://assets/camp/attack_"+suffix+".png"
    if ResourceLoader.exists(path):
        attack_texture=load(path)
        attack_rects=JSON.parse_string(FileAccess.get_file_as_string("res://resources/attack_"+suffix+".json"))

func equip(set_name: String) -> void:
    super.equip(set_name)
    load_walk()
    load_attack()

func face(direction: Vector2) -> void:
    if absf(direction.x)>absf(direction.y): facing=1 if direction.x<0 else 2
    else: facing=3 if direction.y<0 else 0

func attack(direction: Vector2) -> bool:
    if attack_time>0 or dodge_time>0 or dead: return false
    attack_direction=direction.normalized()
    if attack_direction==Vector2.ZERO: attack_direction=Vector2.DOWN
    face(attack_direction)
    attack_time=0.8
    did_hit=false
    last_frame=-1
    return true

func dodge(direction: Vector2) -> void:
    if dodge_cooldown>0 or dead: return
    drive=direction.normalized() if direction.length()>0 else attack_direction
    dodge_time=0.23
    dodge_cooldown=0.9
    invulnerable=0.28
    attack_time=0

func _physics_process(delta: float) -> void:
    invulnerable=maxf(0,invulnerable-delta)
    hit_flash=maxf(0,hit_flash-delta)
    dodge_cooldown=maxf(0,dodge_cooldown-delta)
    sprite.modulate=Color(1.7,0.6,0.5) if hit_flash>0 else Color.WHITE
    if dead: return
    var direction:=Input.get_vector("move_left","move_right","move_up","move_down") if controlled else drive
    if dodge_time>0:
        dodge_time-=delta
        velocity=drive*430
    else:
        velocity=direction*145*(0.2 if attack_time>0 else 1.0)
    move_and_slide()
    if attack_time>0:
        attack_time=maxf(0,attack_time-delta)
        if attack_time<=0.37 and not did_hit:
            did_hit=true
            impact.emit(attack_direction)
        if attack_texture!=null:
            sprite.texture=attack_texture
            var idx:=mini(3,int((0.8-attack_time)/0.2))
            var r: Array=attack_rects[facing][idx]
            sprite.region_rect=Rect2(r[0],r[1],r[2],r[3])
            sprite.scale=Vector2.ONE*0.31
            sprite.position=Vector2(0,(float(r[3])*0.5-float(r[4]))*0.31+4)
            return
    sprite.texture=walk_texture
    frame_rects=walk_rects
    if direction.length()>0.01:
        face(direction)
        phase+=velocity.length()*delta/18.0
    else: phase=1
    last_frame=-1
    update_frame(int(phase)%4)
    var r: Array=frame_rects[facing][int(phase)%4]
    sprite.scale=Vector2.ONE*0.31
    sprite.position=Vector2(0,-float(r[3])*0.155+4)
    queue_redraw()
