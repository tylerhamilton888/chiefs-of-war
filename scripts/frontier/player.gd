extends "res://scripts/chapter/actor.gd"
const Atlas=preload("res://scripts/frontier/atlas.gd")
var weapons: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://resources/frontier/weapons.json"))
var weapon="axe"
var mode="idle"
var elapsed=0.0
var duration=0.0
var hit_done=false
var buffered=""
var buffer_left=0.0
var buffer_aim=Vector2.RIGHT
var desired_block=false
var aim=Vector2.RIGHT
var action_kind=""
var action_callback: Callable
var action_committed=false
var action_contact=0.6
var hit_pause=0.0
var combat_idle=0.0
var combo=0
func _ready() -> void:
    super._ready();maximum=180;hp=game.state.hp;height=170;weapon=game.state.equipment
func combat_weapon() -> String:
    return "log" if carrying() and game.state.cargo.kind=="log" else weapon
func stats(kind: String) -> Dictionary:return weapons[combat_weapon()][kind]
func carrying() -> bool:return not game.state.cargo.is_empty()
func can_cancel() -> bool:
    if mode not in ["light","heavy"]:return mode=="idle"
    var spec=stats(mode)
    return elapsed<0.08 or elapsed>=spec.windup+spec.active+(0.06 if mode=="light" else 0.12)
func request(kind: String,toward: Vector2) -> bool:
    if not enabled or hp<=0:return false
    if kind in ["light","heavy","dodge"] and carrying() and game.state.cargo.kind!="log":game.say("Set the spoils down with X before fighting.");return false
    if mode=="idle" or (kind in ["dodge","block"] and can_cancel()):return begin(kind,toward)
    if mode in ["light","heavy","dodge","stun"]:
        buffered=kind;buffer_left=0.24;buffer_aim=toward;return true
    return false
func begin(kind: String,toward: Vector2) -> bool:
    var cost=stats(kind).guard if kind in ["light","heavy"] else 22 if kind=="dodge" else 0
    if guard<cost:return false
    guard-=cost;locked=toward.normalized() if toward.length()>0.01 else direction();face(locked)
    mode=kind;elapsed=0;hit_done=false;guarding=false;combat_idle=0
    if kind in ["light","heavy"]:
        var spec=stats(kind);duration=spec.windup+spec.active+spec.recovery;combo=(combo+1)%2;game.sound("swing")
    elif kind=="dodge":duration=0.27
    elif kind=="block":mode="idle";set_block(true,toward)
    return true
func attack(toward: Vector2) -> bool:return request("light",toward)
func dodge(toward: Vector2) -> bool:return request("dodge",toward)
func block(value: bool,toward: Vector2) -> void:set_block(value,toward)
func set_block(value: bool,toward: Vector2) -> void:
    desired_block=value;aim=toward
    if value and not guarding and mode=="idle" and guard>0:guard_age=0
    guarding=value and mode=="idle" and guard>0 and not carrying()
    if guarding:face(toward)
func start_action(kind: String,seconds: float,callback: Callable,contact: float=0.6) -> bool:
    if mode!="idle" or not enabled or hp<=0:return false
    mode="action";action_kind=kind;elapsed=0;duration=seconds;action_callback=callback;action_committed=false;action_contact=contact;guarding=false;buffered="";face(Vector2.RIGHT);return true
func interrupt_action() -> void:
    action_callback=Callable();action_kind="";action_committed=false
func receive_hit(amount: float,source_direction: Vector2) -> void:
    if hp<=0 or game.execution_busy:return
    if mode=="dodge" and elapsed<0.20:return
    if guarding and direction().dot(-source_direction)>0.25:
        if guard_age<0.16:
            guard=minf(100,guard+14);game.parry(self);return
        guard=maxf(0,guard-amount*1.6);game.sound("block")
        if guard>0:return
        guarding=false;mode="stun";duration=0.65;elapsed=0;game.say("Guard broken. Make room to recover.")
    else:
        mode="stun";duration=0.11 if game.state.fed>0 else 0.19;elapsed=0
    interrupt_action();hp=maxf(0,hp-amount);flash=0.13;velocity=source_direction*210
    game.state.ferocity=maxf(0,game.state.ferocity-8)
    if hp<=0:felled.emit(self)
func full_pose(id: String,index: int,mirror: bool=false) -> void:Atlas.pose(sprite,id,index,height,mirror)
func weapon_pose(index: int) -> void:
    if combat_weapon()=="log":
        var row=0 if facing==0 else 2 if facing==3 else 1
        var has_attack_art=FileAccess.file_exists("res://resources/frontier/log_attack.json")
        var pose_index=[3,0,2,3][index] if has_attack_art else index
        full_pose("log_attack" if has_attack_art else "carry_log",row*4+pose_index,facing==1)
    elif weapon=="maul" and FileAccess.file_exists("res://resources/frontier/player_maul.json"):
        var row=0 if facing==0 else 2 if facing==3 else 1
        full_pose("player_maul",row*4+index,facing==1)
    else:action_pose(index)
func _physics_process(delta: float) -> void:
    if not enabled or hp<=0:return
    if hit_pause>0:hit_pause=maxf(0,hit_pause-delta);return
    flash=maxf(0,flash-delta);sprite.modulate=Color(1.5,0.78,0.65) if flash>0 else Color.WHITE
    guard_age+=delta;combat_idle+=delta;buffer_left=maxf(0,buffer_left-delta)
    if buffer_left<=0:buffered=""
    if game.execution_busy:velocity=Vector2.ZERO;return
    elapsed+=delta
    if mode=="action":
        velocity=Vector2.ZERO
        var row=0 if action_kind=="lift" else 2 if action_kind=="eat" else 1
        full_pose("work",row*4+mini(3,int(elapsed/duration*4)))
        if not action_committed and elapsed>=duration*action_contact:
            action_committed=true
            if action_callback.is_valid():action_callback.call()
        if elapsed>=duration:mode="idle";interrupt_action()
    elif mode in ["light","heavy"]:
        var spec=stats(mode)
        var windup=elapsed<spec.windup
        velocity=locked*(75 if windup else 150 if elapsed<spec.windup+spec.active else 15);move_and_slide()
        weapon_pose(1 if windup else 2 if elapsed<spec.windup+spec.active+0.10 else 0)
        if not hit_done and elapsed>=spec.windup:
            hit_done=true;game.player_contact(mode,spec)
        if desired_block and can_cancel() and elapsed>=spec.windup+spec.active+0.1:
            mode="idle";set_block(true,aim)
        elif elapsed>=duration:mode="idle"
    elif mode=="dodge":
        velocity=locked*570;move_and_slide();weapon_pose(3)
        if elapsed>=duration:mode="idle"
    elif mode=="stun":
        velocity=velocity.move_toward(Vector2.ZERO,1200*delta);move_and_slide();weapon_pose(3)
        if elapsed>=duration:mode="idle"
    else:
        var input=Input.get_vector("move_left","move_right","move_up","move_down") if controlled else drive
        var speed=165 if carrying() else 105 if guarding else 240
        velocity=velocity.move_toward(input*speed,2200*delta)
        var before=position;move_and_slide();var distance=position.distance_to(before)
        if not guarding and input.length()>0.01:face(input)
        if distance>0.05:
            phase=fposmod(phase+distance/92,1);distance_since_step+=distance
            if distance_since_step>46:distance_since_step=0;stepped.emit()
        else:phase=0
        if carrying():
            var row=0 if facing==0 else 2 if facing==3 else 1
            full_pose("carry_log" if game.state.cargo.kind=="log" else "carry_spoils",row*4+int(phase*4),facing==1)
        elif guarding:weapon_pose(3)
        elif distance>0.05:show_frame([1,2,3,0][int(phase*4)])
        elif combat_idle<4:weapon_pose(0)
        else:show_frame(0)
        if not guarding:guard=minf(100,guard+delta*(30 if game.state.fed>0 else 24))
    attack_time=maxf(0,duration-elapsed) if mode in ["light","heavy"] else 0
    dodge_time=maxf(0,duration-elapsed) if mode=="dodge" else 0
    if mode=="idle" and buffered!="":
        var next=buffered;buffered="";begin(next,buffer_aim)
    if combat_idle>5:game.state.ferocity=maxf(0,game.state.ferocity-delta*2)
