extends "res://scripts/ogre_actor.gd"
signal struck(actor)
signal felled(actor)
var identity="player"
var height=160.0
var art: Dictionary={}
var game
var camp_work: Node
var route: Array=[]
var route_index=0
var rest=2.0
var hp=160.0
var maximum=160.0
# Retained for the archived Frontier actor, which derives from this class.
var guard=100.0
var guarding=false
var guard_age=10.0
var attack_time=0.0
var attack_done=false
var contact_hold := 0.0
const DodgeStep = preload("res://scripts/chapter/dodge_step.gd")
var dodge_time=0.0
var dodge_drawing: Dictionary = {}
var dodge_texture: Texture2D
var stun=0.0
var hit_flash_enabled := true
var flash=0.0
var cooldown=0.0
var locked=Vector2.DOWN
var hostile=false
var companion=false
var ai_time=0.0
var target: Node2D
const GearVisual = preload("res://scripts/chapter/gear_visual.gd")
var equipped_head := "bare"
var head_gear: GearVisual
var equipped_body := "fur"
var body_gear: GearVisual
const WEAPONS = preload("res://resources/chapter/weapons.json")
const ORIGINAL_SWING_POSES := [0, 1, 1, 2, 2, 3]
var swing_drawings := {}
const CleaverStroke = preload("res://scripts/chapter/cleaver_stroke.gd")
var mirror_oblique := false
var swing_phase := 0
var equipped_weapon := "hunting_axe"
const ArmedGait = preload("res://scripts/chapter/armed_gait.gd")
const READY_SECONDS := 2.4
var ready_time := 0.0
var cursor_direction := Vector2.DOWN
var combat_art: Dictionary={}
var walking_art: Texture2D
var action_art: Texture2D
func motion_height() -> float:return height
func _ready() -> void:
    super._ready()
    var path="res://resources/chapter/"+identity+".json"
    if FileAccess.file_exists(path):
        art=JSON.parse_string(FileAccess.get_file_as_string(path));frames=art.frames
        var walking_texture="res://assets/chapter/"+identity+"_nordic.png"
        if not ResourceLoader.exists(walking_texture):walking_texture="res://assets/chapter/"+identity+".png"
        walking_art=load(walking_texture);sprite.texture=walking_art
    var action_path="res://resources/chapter/"+identity+"_combat.json"
    if FileAccess.file_exists(action_path):
        combat_art=JSON.parse_string(FileAccess.get_file_as_string(action_path))
        var action_texture="res://assets/chapter/"+identity+"_combat_nordic.png"
        if not ResourceLoader.exists(action_texture):action_texture="res://assets/chapter/"+identity+"_combat.png"
        action_art=load(action_texture)
    if identity == "player":
        equip_weapon(equipped_weapon)
    collision_layer=2;collision_mask=1
    show_frame(0)
    if equipped_body != "fur":
        equip_body(equipped_body)
    if equipped_head != "bare":
        equip_head(equipped_head)
func show_frame(index: int) -> void:
    if art.is_empty():super.show_frame(index);return
    frame_index=clampi(index,0,3)
    var row=0 if facing==0 else 2 if facing==3 else 1
    var r: Array=frames[row][frame_index]
    if FrameArt.pose(sprite,walking_art,row*4+frame_index,height,facing==1):return
    apply_region(r,walking_art,facing==1,height/float(art.height))
func apply_region(r: Array,texture: Texture2D,mirror: bool,factor: float) -> void:
    sprite.texture=texture;sprite.region_rect=Rect2(r[0],r[1],r[2],r[3]);sprite.flip_h=mirror
    sprite.scale=Vector2.ONE*factor;sprite.position=Vector2((r[4] if r.size()>4 else 0)*factor*(-1 if mirror else 1),-r[3]*factor/2.0+3)
func equip_weapon(id: String) -> void:
    if identity != "player" or not WEAPONS.data.has(id):
        return
    if equipped_weapon == id and not swing_drawings.is_empty():
        return
    equipped_weapon = id
    action_art = load(WEAPONS.data[id].texture)
    dodge_drawing = load(WEAPONS.data[id].dodge).data
    dodge_texture = load(dodge_drawing.texture)
    swing_drawings.clear()
    for view in WEAPONS.data[id].swing_views:
        var drawing: Dictionary = load(WEAPONS.data[id].swing_views[view]).data
        swing_drawings[view] = {"frames": drawing.frames, "texture": load(drawing.texture), "height": drawing.height}

func equip_head(id: String) -> void:
    if identity != "player" or not GearVisual.supports("head", id):
        return
    equipped_head = id
    head_gear = set_worn_piece(head_gear, "head", id)

func equip_body(id: String) -> void:
    if identity != "player" or not GearVisual.supports("body", id):
        return
    equipped_body = id
    body_gear = set_worn_piece(body_gear, "body", id)
    if body_gear != null and head_gear != null and body_gear.get_index() > head_gear.get_index():
        move_child(body_gear, head_gear.get_index())

func set_worn_piece(layer: GearVisual, slot: String, id: String) -> GearVisual:
    if sprite == null:
        return layer
    if layer == null:
        if id == GearVisual.SLOTS[slot].default:
            return null
        layer = GearVisual.new(slot)
        add_child(layer)
    layer.equip(id)
    layer.align_to(sprite, idle_breath)
    return layer

func align_worn_pieces() -> void:
    if body_gear != null:
        body_gear.align_to(sprite, idle_breath)
    if head_gear != null:
        head_gear.align_to(sprite, idle_breath)

func weapon_damage(honed_axe := false) -> float:
    var base_damage := float(WEAPONS.data[equipped_weapon].damage)
    return base_damage + (8.0 if honed_axe and equipped_weapon == "hunting_axe" else 0.0)

func action_pose(index: int) -> void:
    if combat_art.is_empty():show_frame(1 if index==1 else 0);return
    var row=0 if facing==0 else 2 if facing==3 else 1
    if FrameArt.pose(sprite,action_art,row*4+index,height,facing==1):return
    apply_region(combat_art.frames[row][index],action_art,facing==1,height/float(combat_art.height))
func show_swing(phase_index: int) -> void:
    swing_phase = phase_index
    var view := "front" if facing == 0 else "rear" if facing == 3 else "side"
    var drawing: Dictionary = swing_drawings.get(view, {})
    if drawing.is_empty() or drawing.frames[phase_index] == null:
        action_pose(ORIGINAL_SWING_POSES[phase_index])
        return
    FrameArt.cell(sprite, drawing.texture, drawing.frames[phase_index], height / float(drawing.height), facing == 1 or mirror_oblique)

func update_swing(delta: float) -> void:
    if contact_hold > 0.0:
        var held := minf(delta, contact_hold)
        contact_hold -= held
        delta -= held
        if delta <= 0.0:
            return
    var contact_remaining := 0.35 if hostile else float(WEAPONS.data[equipped_weapon].follow_through_seconds)
    var before: float = attack_time
    attack_time = maxf(0.0, attack_time - delta)
    if identity == "player" and not hostile and equipped_weapon == "hunting_axe":
        var duration := float(WEAPONS.data[equipped_weapon].swing_seconds)
        var travel := CleaverStroke.distance_at(duration - attack_time) - CleaverStroke.distance_at(duration - before)
        if travel > 0.0:
            # Bodies on the actor layer constrain a committed step, just like scenery.
            var old_mask := collision_mask
            collision_mask = old_mask | 2
            move_and_collide(locked * travel, false, 0.08, true)
            collision_mask = old_mask
    velocity = Vector2.ZERO
    if hostile:
        action_pose(1 if attack_time > contact_remaining else 2)
    elif attack_time > contact_remaining:
        var duration := float(WEAPONS.data[equipped_weapon].swing_seconds)
        var windup: float = (duration - attack_time) / (duration - contact_remaining)
        show_swing(0 if windup < 0.25 else 1 if windup < 0.69 else 2)
    else:
        var after_contact: float = 1.0 - attack_time / contact_remaining
        # Always show the contacting drawing on the tick that resolves the hit.
        show_swing(3 if not attack_done or after_contact < 0.27 else 4 if after_contact < 0.68 else 5)
    if attack_time <= contact_remaining and not attack_done:
        attack_done = true
        struck.emit(self)
    if attack_time <= 0.0:
        cooldown = 0.65 if hostile else 0.08
        if controlled:
            ready_time = READY_SECONDS

func direction() -> Vector2:return [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP][facing]
func attack(aim: Vector2) -> bool:
    if not enabled or hp<=0 or attack_time>0 or dodge_time>0 or stun>0 or cooldown>0:return false
    locked = aim.normalized() if aim.length_squared() > 0.001 else direction()
    face(locked)
    mirror_oblique = false
    if not hostile and equipped_weapon == "hunting_axe":
        var bearing := posmod(roundi(locked.angle() / (PI / 4.0)), 8)
        facing = [2, 0, 0, 0, 1, 3, 3, 3][bearing]
        mirror_oblique = bearing == 3 or bearing == 7
    attack_time = 1.15 if hostile else float(WEAPONS.data[equipped_weapon].swing_seconds)
    contact_hold = 0.0
    attack_done=false;guarding=false
    if not hostile:
        show_swing(0)
    return true
func dodge(aim: Vector2) -> bool:
    if not enabled or hp<=0 or dodge_time>0 or attack_time>0.35 or stun>0:return false
    locked = aim.normalized() if aim.length() > 0.1 else direction()
    # Front/back views can slip side-to-side while keeping the opponent in sight.
    if absf(locked.y) > absf(locked.x) or facing in [1, 2]:
        face(locked)
    dodge_time = DodgeStep.DURATION
    guarding = false
    attack_time = 0.0
    velocity = Vector2.ZERO
    ready_time = maxf(ready_time, DodgeStep.DURATION + 0.24)
    DodgeStep.pose(self, 0.0)
    return true

func update_dodge(delta: float) -> void:
    var before: float = DodgeStep.DURATION - dodge_time
    dodge_time = maxf(0.0, dodge_time - delta)
    var elapsed: float = DodgeStep.DURATION - dodge_time
    var travel := DodgeStep.distance_at(elapsed) - DodgeStep.distance_at(before)
    velocity = locked * travel / delta
    move_and_slide()
    DodgeStep.pose(self, elapsed)
    if before < DodgeStep.FIRST_CONTACT and elapsed >= DodgeStep.FIRST_CONTACT:
        stepped.emit()
func block(value: bool,aim: Vector2) -> void:
    if value and not guarding:guard_age=0
    guarding=value and enabled and hp>0 and stun<=0 and attack_time<=0 and dodge_time<=0
    if guarding:face(aim)
func receive_hit(amount: float,source_direction: Vector2,breaks_block: bool=false) -> void:
    if hp<=0 or dodge_time>0.07:return
    dodge_time = 0.0
    if guarding and direction().dot(-source_direction)>0.2:
        if guard_age<0.18:
            game.parry(self);return
        game.sound("block")
        if not breaks_block:return
        guarding=false;stun=0.7;game.say("Guard broken — move out and recover.")
    hp=maxf(0,hp-amount);flash=0.14;velocity=source_direction*180
    if not hostile:stun=maxf(stun,0.1)
    if hp<=0:attack_time=0;guarding=false;felled.emit(self)
func parried() -> void:
    attack_time=0;stun=1.15;cooldown=1.0;velocity=Vector2.ZERO
func _physics_process(delta: float) -> void:
    if not enabled:return
    flash=maxf(0,flash-delta);cooldown=maxf(0,cooldown-delta);guard_age+=delta;stun=maxf(0,stun-delta)
    sprite.modulate=Color(1.6,0.75,0.65) if flash>0 and hit_flash_enabled else Color.WHITE
    if hp<=0:velocity=Vector2.ZERO;action_pose(3);return
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
        update_dodge(delta)
    elif attack_time>0:
        update_swing(delta)
    elif guarding:velocity=Vector2.ZERO;action_pose(3)
    elif camp_work != null and camp_work.advance(delta):
        queue_redraw()
        return
    elif controlled and ready_time > 0.0:
        ready_time = maxf(0.0, ready_time - delta)
        armed_move(delta)
    else:
        super._physics_process(delta)
    queue_redraw()
func track_combat_aim(aim: Vector2, threat_nearby: bool) -> void:
    if aim.length_squared() > 0.0001:
        cursor_direction = aim.normalized()
    if threat_nearby or guarding or attack_time > 0.0:
        ready_time = READY_SECONDS

func armed_move(delta: float) -> void:
    face(cursor_direction)
    var intent := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var forward := direction().dot(intent)
    # A shorter backward or lateral step keeps the striking side presented.
    var speed := 145.0 if forward > 0.5 else 116.0 if forward < -0.5 else 128.0
    velocity = velocity.move_toward(intent * speed, 1450.0 * delta)
    var before := position
    move_and_slide()
    var movement := position - before
    var distance := movement.length()
    if distance < 0.04:
        phase = 0.0
        distance_since_step = 0.0
        action_pose(0)
        return
    phase = fposmod(phase + distance / ArmedGait.STRIDE, 1.0)
    distance_since_step += distance
    if distance_since_step >= ArmedGait.STRIDE * 0.5:
        distance_since_step -= ArmedGait.STRIDE * 0.5
        stepped.emit()
    ArmedGait.pose(self, movement.normalized(), phase)

func _draw() -> void:
    super._draw()
    draw_set_transform(Vector2.ZERO)
    if hostile and hp>0:
        draw_line(Vector2(-55,-height-14),Vector2(55,-height-14),Color("211c18"),7)
        draw_line(Vector2(-55,-height-14),Vector2(-55+110*hp/maximum,-height-14),Color("ce654a"),5)
        if attack_time>0.35:
            var a=locked.angle()
            draw_arc(Vector2.ZERO,205,a-0.55,a+0.55,20,Color("eeb668"),4)


func set_hair_palette(hair: String) -> void:
    var palette: int = preload("res://scripts/chapter/state.gd").HAIR.find(hair)
    if palette <= 0:
        sprite.material = null
        return
    var shader_material := ShaderMaterial.new()
    shader_material.shader = preload("res://shaders/ogre_palette.gdshader")
    shader_material.set_shader_parameter("palette", palette)
    sprite.material = shader_material

## Only the playable Ogre's steady exploration rest gets the subtle chest motion.
## Authored weapon, cinematic and moving poses own the complete drawing elsewhere.
var idle_breath: Polygon2D

func _process(delta: float) -> void:
    if identity != "player" or not is_instance_valid(sprite):
        return
    if not controlled:
        if is_instance_valid(idle_breath):
            idle_breath.stop(sprite)
        align_worn_pieces()
        return
    var resting: bool = enabled and hp > 0.0 and sprite.texture == MOTION_TEXTURE \
        and frame_index == 0 and velocity.length_squared() < 0.01 \
        and attack_time <= 0.0 and dodge_time <= 0.0 and stun <= 0.0 \
        and not guarding and ready_time <= 0.0
    if resting:
        if not is_instance_valid(idle_breath):
            idle_breath = preload("res://scripts/chapter/idle_breath.gd").new()
            add_child(idle_breath)
            move_child(idle_breath, sprite.get_index() + 1)
        idle_breath.breathe(sprite, delta)
    elif is_instance_valid(idle_breath):
        idle_breath.stop(sprite)
    align_worn_pieces()
