extends "res://scripts/raider.gd"
const Atlas=preload("res://scripts/frontier/atlas.gd")
var swallowed=false
var role="knife"
var hit_pause=0.0
var throw_time=0.0
var thrown_hits: Array=[]
var formation=false
var id=""
func _ready() -> void:
    super._ready();maximum=70 if role=="spear" else 115 if role=="orc" else 58;hp=maximum
func pose(index: int,cleave_row: bool=false) -> void:
    if role=="spear":
        var mapping=[0,4,5,6,6,7]
        Atlas.pose(sprite,"spearmen",mapping[clampi(index,0,5)],90,locked_direction.x<0)
    else:super.pose(index,cleave_row)
func receive_hit(amount: float,direction: Vector2) -> void:
    if hp<=0 or held:return
    var frontal=locked_direction.dot(-direction)>0.55
    if role=="spear" and formation and frontal and game.contact_kind=="light":
        amount*=0.4;game.say("Braced spears. Break their line with a heavy strike or flank them.")
    hp=maxf(0,hp-amount);flash=0.12;posture+=1;recoil=direction*(440 if game.contact_kind=="heavy" else 230)
    if hp<=0:die(false);return
    if game.contact_kind=="heavy" or posture>=2 or hp<=maximum*0.4:
        vulnerable=1.8;state="vulnerable";posture=0;formation=false
    else:state="recover";clock=0;cooldown=0.42
func launch(direction: Vector2) -> void:
    held=false;throw_time=0.52;recoil=direction*680;state="thrown";thrown_hits.clear();formation=false
func _physics_process(delta: float) -> void:
    if not active or swallowed:return
    if hit_pause>0:hit_pause=maxf(0,hit_pause-delta);return
    if held:return
    if hp<=0:super._physics_process(delta);return
    if throw_time>0:
        var previous=position;throw_time=maxf(0,throw_time-delta)
        var collision=move_and_collide(recoil*delta)
        pose(4)
        for other in game.enemies:
            if other==self or not is_instance_valid(other) or other.hp<=0 or other in thrown_hits:continue
            if Geometry2D.get_closest_point_to_segment(other.position,previous,position).distance_to(other.position)<48:
                thrown_hits.append(other);other.receive_hit(45,recoil.normalized());game.impact(other.position);game.sound("hit")
        if collision or throw_time<=0:
            throw_time=0;game.contact_kind="heavy";receive_hit(24,recoil.normalized());vulnerable=1.5;game.impact(position)
        return
    flash=maxf(0,flash-delta);cooldown=maxf(0,cooldown-delta);fear=maxf(0,fear-delta);clock+=delta
    sprite.modulate=Color(1.5,0.7,0.6) if flash>0 else Color.WHITE
    if vulnerable>0:
        vulnerable=maxf(0,vulnerable-delta);velocity=recoil;recoil=recoil.move_toward(Vector2.ZERO,1500*delta);move_and_slide();pose(3)
        if vulnerable<=0:state="recover";clock=0;cooldown=0.5
        queue_redraw();return
    if not is_instance_valid(target):return
    var off=target.position-position
    var spear=role=="spear"
    if state=="windup":
        velocity=Vector2.ZERO;pose(1)
        if clock>=0.68 if spear else clock>=0.46:
            state="attack";clock=0;strike.emit(self)
    elif state=="attack":
        velocity=locked_direction*(105 if spear else 190);move_and_slide();pose(2)
        if clock>0.15:state="recover";clock=0;cooldown=0.85
    elif state=="recover":
        velocity=recoil;recoil=recoil.move_toward(Vector2.ZERO,1200*delta);move_and_slide();pose(0)
        if clock>0.38:state="idle";clock=0
    elif fear>0:pose(3)
    elif off.length()<650 and target.position.distance_to(home)<850:
        locked_direction=off.normalized();sprite.flip_h=off.x>0
        formation=false
        if spear:
            for other in game.enemies:
                if other!=self and is_instance_valid(other) and other.get_script()==get_script() and other.role=="spear" and other.hp>0 and other.vulnerable<=0 and other.position.distance_to(position)<210:formation=true
        var reach=185 if spear else 90
        if off.length()<reach and cooldown<=0 and game.can_enemy_attack(self) and game.has_line(position,target.position):state="windup";clock=0;pose(1)
        else:
            var flank=Vector2(0,80 if int(get_meta("slot",0))%2==0 else -80) if not spear else Vector2.ZERO
            var dest=target.position-off.normalized()*(145 if spear else 65)+flank
            velocity=game.route_direction(self,dest)*125 if position.distance_to(dest)>25 else Vector2.ZERO
            for other in game.enemies:
                if other!=self and is_instance_valid(other) and other.hp>0 and position.distance_to(other.position)<52:velocity+=(position-other.position).normalized()*85
            move_and_slide()
            if spear:Atlas.pose(sprite,"spearmen",3 if formation else 1+int(fmod(clock,0.5)>0.25),90,off.x<0)
            else:pose(1 if fmod(clock,0.5)<0.25 else 0)
    else:
        var back=home-position;velocity=game.route_direction(self,home)*75 if back.length()>30 else Vector2.ZERO;move_and_slide();pose(0)
    queue_redraw()
func _draw() -> void:
    if hp<=0:return
    draw_line(Vector2(-25,-105),Vector2(25,-105),Color("201a16"),5)
    draw_line(Vector2(-25,-105),Vector2(-25+50*hp/maximum,-105),Color("be6341"),3)
    if vulnerable>0:draw_arc(Vector2.ZERO,30,0,TAU,24,Color("e7c272"),3)
    if state=="windup":
        var length=200 if role=="spear" else 110
        draw_line(Vector2.ZERO,locked_direction*length,Color("e4af52"),5)
        draw_arc(Vector2.ZERO,length,locked_direction.angle()-0.28,locked_direction.angle()+0.28,16,Color("e4af52"),3)
