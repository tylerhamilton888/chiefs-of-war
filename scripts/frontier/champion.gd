extends "res://scripts/chapter/actor.gd"
var stance="guard"
var clock=0.0
var cycle=0
var hit_pause=0.0
var vulnerable=0.0
var grapple_cooldown=5.0
func _ready() -> void:
    identity="hrothgar";height=235;hostile=true;controlled=false
    super._ready();maximum=650;hp=maximum
func receive_hit(amount: float,source_direction: Vector2) -> void:
    if hp<=0:return
    var front=direction().dot(-source_direction)>0.3
    if stance=="guard" and front:
        guard=maxf(0,guard-amount*(1.6 if game.contact_kind=="heavy" else 0.7));game.sound("block")
        if guard>0:return
        parried();game.say("The champion's guard broke. F to clinch while he is open.")
    hp=maxf(0,hp-amount);flash=0.13
    if hp<=0:felled.emit(self)
func parried() -> void:
    stance="stagger";clock=0;vulnerable=1.8;attack_time=0;velocity=Vector2.ZERO
func _physics_process(delta: float) -> void:
    if not enabled:return
    if hit_pause>0:hit_pause=maxf(0,hit_pause-delta);return
    if hp<=0:action_pose(3);return
    clock+=delta;flash=maxf(0,flash-delta);grapple_cooldown=maxf(0,grapple_cooldown-delta)
    sprite.modulate=Color(1.5,0.75,0.6) if flash>0 else Color.WHITE
    var off=target.position-position
    if game.execution_busy:return
    if stance=="stagger":
        vulnerable=maxf(0,vulnerable-delta);action_pose(3)
        if vulnerable<=0:stance="guard";clock=0;guard=50
    elif stance=="windup":
        action_pose(1);attack_time=0.8-clock
        if clock>0.72 if cycle%2==0 else clock>0.46:
            stance="strike";clock=0;struck.emit(self)
    elif stance=="strike":
        action_pose(2);velocity=locked*180;move_and_slide()
        if clock>0.15:stance="recover";clock=0;attack_time=0
    elif stance=="recover":
        action_pose(0)
        if clock>0.6:stance="guard";clock=0;cycle+=1
    else:
        face(off);guard=minf(100,guard+18*delta)
        if off.length()<120 and target.guarding and target.guard_age>1.3 and grapple_cooldown<=0:
            grapple_cooldown=8;game.begin_clinch(self)
        elif off.length()<205 and clock>0.55:
            locked=off.normalized();stance="windup";clock=0
        elif off.length()>175:
            velocity=game.route_direction(self,target.position)*140;move_and_slide();phase=fposmod(phase+delta*1.6,1);show_frame(int(phase*4))
        else:action_pose(3)
    queue_redraw()
func _draw() -> void:
    super._draw()
    if stance=="windup":draw_arc(Vector2.ZERO,225,locked.angle()-0.7,locked.angle()+0.7,24,Color("e3ac51"),4)
    if vulnerable>0:draw_arc(Vector2.ZERO,48,0,TAU,28,Color("edce7a"),3)
