extends CharacterBody2D
signal strike(foe)
signal slain(foe)
const Atlas=preload("res://scripts/frontier/atlas.gd")
var game
var target
var hp=480.0
var maximum=480.0
var active=true
var stage="idle"
var clock=0.0
var cooldown=1.0
var locked_direction=Vector2.RIGHT
var sprite=Sprite2D.new()
var home=Vector2.ZERO
var hits: Dictionary={}
var armor=2
var flash=0.0
var vulnerable=0.0
var hit_pause=0.0
var charges=0
func _ready() -> void:
    home=position;collision_layer=2;collision_mask=1
    var col=CollisionShape2D.new();var shape=CircleShape2D.new();shape.radius=52;col.shape=shape;add_child(col);add_child(sprite);pose(0)
func pose(index: int) -> void:Atlas.pose(sprite,"great_beast",index,205,locked_direction.x<0)
func receive_hit(amount: float,direction: Vector2) -> void:
    if hp<=0:return
    var frontal=locked_direction.dot(-direction)>0.55
    if frontal and armor>0 and stage!="stunned":
        if game.contact_kind=="heavy" and game.player.combat_weapon()=="maul":armor-=1;game.say("Stone plates cracked. One more heavy maul blow breaks the brow.")
        amount*=0.25
    elif stage=="stunned":amount*=1.65
    else:amount*=1.2
    hp=maxf(0,hp-amount);flash=0.14
    if hp<=0:stage="dead";velocity=Vector2.ZERO;slain.emit(self)
func parried() -> void:
    if stage=="sweep":stage="stunned";clock=0;vulnerable=2
func _physics_process(delta: float) -> void:
    if not active:return
    if hit_pause>0:hit_pause=maxf(0,hit_pause-delta);return
    if hp<=0:pose(11);return
    clock+=delta;cooldown=maxf(0,cooldown-delta);flash=maxf(0,flash-delta)
    sprite.modulate=Color(1.7,0.8,0.6) if flash>0 else Color.WHITE
    var off: Vector2=target.position-position
    if stage=="windup":
        pose(5);velocity=Vector2.ZERO
        if clock>0.95:stage="charge";clock=0;hits.clear();game.sound("growl")
    elif stage=="charge":
        pose(6);velocity=locked_direction*670;move_and_slide()
        if off.length()<135 and not hits.has("player"):hits.player=true;strike.emit(self)
        if get_slide_collision_count()>0 or game.trip_beast(self):
            stage="stunned";clock=0;vulnerable=2.7;game.impact(position);game.sound("hit");game.say("Its weight betrayed it. Strike the exposed flank!")
        elif clock>0.85:stage="recover";clock=0;cooldown=1.6
    elif stage=="stunned":
        pose(8 if clock<0.4 else 9);velocity=Vector2.ZERO;vulnerable=maxf(0,vulnerable-delta)
        if vulnerable<=0:stage="recover";clock=0;cooldown=1.0
    elif stage=="sweep":
        pose(4 if clock<0.7 else 7)
        if clock>=0.7 and not hits.has("player"):hits.player=true;strike.emit(self)
        if clock>0.95:stage="recover";clock=0;cooldown=1.2
    elif stage=="recover":
        pose(0)
        if clock>0.8:stage="idle";clock=0
    elif off.length()<700:
        if off.length()>210 and cooldown<=0:
            locked_direction=off.normalized();stage="windup";clock=0;charges+=1
        elif off.length()<210 and cooldown<=0:
            locked_direction=off.normalized();stage="sweep";clock=0;hits.clear()
        else:
            velocity=game.route_direction(self,target.position)*60 if off.length()>180 else Vector2.ZERO;move_and_slide();pose(1+int(fmod(clock*5,3)))
    else:pose(0)
    queue_redraw()
func _draw() -> void:
    if hp<=0:return
    draw_line(Vector2(-90,-223),Vector2(90,-223),Color("211d18"),8)
    draw_line(Vector2(-90,-223),Vector2(-90+180*hp/maximum,-223),Color("bb623e"),5)
    if stage=="windup":
        var end=locked_direction*580;draw_line(Vector2.ZERO,end,Color(0.8,0.3,0.12,0.26),85);draw_line(Vector2.ZERO,end,Color("e5ae54"),3)
    elif stage=="sweep" and clock<0.7:draw_arc(Vector2.ZERO,225,locked_direction.angle()-1.2,locked_direction.angle()+1.2,28,Color("e5ae54"),4)
    if stage=="stunned":draw_arc(Vector2.ZERO,85,0,TAU,32,Color("d7ca81"),3)
