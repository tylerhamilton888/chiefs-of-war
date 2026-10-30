extends CharacterBody2D
# Whole-body poses; the execution coordinator owns the shared contact clock.
signal strike(raider)
signal slain(raider)
var kind := "goblin"
var hp := 110.0
var maximum := 110.0
var posture := 0
var vulnerable := 0.0
var vulnerable_cooldown := 0.0
var state := "idle"
var clock := 0.0
var cooldown := 0.8
var active := true
var home := Vector2.ZERO
var target: Node2D
var game
var locked_direction := Vector2.LEFT
var sprite := Sprite2D.new()
var flash := 0.0
var recoil := Vector2.ZERO
var death_clock := 0.0
var cleaved := false
var held := false
var fear := 0.0
const ART = preload("res://assets/executions/enemies.png")
# Rectangles are authored around each full silhouette, with fixed foot anchors.
const RECTS = [
 [Rect2(25,30,220,275),Rect2(295,30,215,275),Rect2(506,30,341,275),Rect2(870,30,265,275),Rect2(1217,30,230,275),Rect2(1470,30,287,275)],
 [Rect2(50,310,200,242),Rect2(305,310,195,242),Rect2(555,310,310,242),Rect2(875,310,272,242),Rect2(1153,310,305,242),Rect2(1458,310,310,242)],
 [Rect2(4,552,260,325),Rect2(280,552,252,325),Rect2(520,552,382,325),Rect2(925,552,258,325),Rect2(1195,552,228,325),Rect2(1425,552,345,325)]
]
const ANCHORS = [[135,405,730,1030,1340,1600],[145,410,665,990,1280,1590],[150,430,760,1050,1320,1600]]
func _ready() -> void:
 home=position
 maximum=180.0 if kind=="orc" else 110.0
 hp=maximum
 collision_layer=2; collision_mask=1
 var c=CollisionShape2D.new();var shape=CircleShape2D.new();shape.radius=19 if kind=="orc" else 14;c.shape=shape;add_child(c)
 sprite.texture=ART;sprite.region_enabled=true;add_child(sprite);pose(0)
func pose(index: int,cleave_row: bool=false) -> void:
 var row:=2 if kind=="orc" else 1 if cleave_row else 0
 var rect: Rect2=RECTS[row][clampi(index,0,5)]
 var scale_factor:=0.37 if kind=="orc" else 0.28
 var anchor:=Vector2(ANCHORS[row][clampi(index,0,5)],870 if row==2 else 545 if row==1 else 295)
 sprite.region_rect=rect;sprite.scale=Vector2.ONE*scale_factor
 var offset: Vector2=(rect.position+rect.size*0.5-anchor)*scale_factor
 if sprite.flip_h: offset.x=-offset.x
 sprite.position=offset
func eligible() -> bool:
 return hp>0 and vulnerable>0 and not held and active
func receive_hit(amount: float,direction: Vector2) -> void:
 if hp<=0 or held:return
 hp=maxf(0,hp-amount);flash=0.12;posture+=1;recoil=direction*100
 if hp<=0: die(false);return
 state="recover";clock=0;cooldown=0.65
 if vulnerable_cooldown<=0 and (posture>=2 or hp<=maximum*0.35):
  vulnerable=1.65;posture=0;state="vulnerable";game.toast("Staggered • F from the side",position-Vector2(0,65))
func die(dismember: bool) -> void:
 if state=="dead":return
 hp=0;state="dead";cleaved=dismember and kind=="goblin";death_clock=0;velocity=Vector2.ZERO
 collision_layer=0;slain.emit(self)
func _physics_process(delta: float) -> void:
 if not active:return
 flash=maxf(0,flash-delta);cooldown=maxf(0,cooldown-delta);fear=maxf(0,fear-delta)
 sprite.modulate=Color(1.6,0.8,0.7) if flash>0 else Color.WHITE
 if held:return
 if hp<=0:
  death_clock+=delta
  var show_cleave: bool=cleaved and game.dismember_enabled
  pose((2 if death_clock<0.08 else 3 if death_clock<0.18 else 4 if death_clock<0.35 else 5) if show_cleave else (4 if death_clock<0.22 else 5),show_cleave)
  queue_redraw();return
 vulnerable_cooldown=maxf(0,vulnerable_cooldown-delta)
 if vulnerable>0:
  vulnerable=maxf(0,vulnerable-delta);velocity=recoil;recoil=recoil.move_toward(Vector2.ZERO,delta*1000);move_and_slide();pose(3)
  if vulnerable<=0:state="recover";clock=0;posture=0;vulnerable_cooldown=2.0
  queue_redraw();return
 if not is_instance_valid(target):return
 var off: Vector2=target.position-position
 clock+=delta
 if fear>0:velocity=Vector2.ZERO;pose(3)
 elif state=="windup":
  velocity=Vector2.ZERO;pose(1)
  if clock>=0.65:
   state="attack";clock=0;pose(2);strike.emit(self)
 elif state=="attack":
  velocity=Vector2.ZERO;pose(2)
  if clock>=0.18:state="recover";clock=0;cooldown=0.8
 elif state=="recover":
  velocity=recoil;recoil=recoil.move_toward(Vector2.ZERO,delta*1000);pose(0)
  if clock>=0.45:state="idle";clock=0
 else:
  var chase:=off.length()<260 and target.position.distance_to(home)<430
  var dest: Vector2=target.position if chase else home
  var distance: Vector2=dest-position
  velocity=Vector2.ZERO
  if chase and off.length()<88 and cooldown<=0 and game.has_line(position,target.position,null):
   locked_direction=off.normalized();state="windup";clock=0
  elif distance.length()>22:
   velocity=game.route_direction(self,dest)*(90 if kind=="orc" else 115)
  sprite.flip_h=distance.x>0
  pose(1 if velocity.length()>1 and fmod(clock,0.5)<0.25 else 0)
 move_and_slide();queue_redraw()
func _draw() -> void:
 if hp<=0:return
 if hp<maximum or state=="windup":
  draw_line(Vector2(-24,-105),Vector2(24,-105),Color("291e19"),4)
  draw_line(Vector2(-24,-105),Vector2(-24+48*hp/maximum,-105),Color("b95e43"),4)
 if vulnerable>0:
  draw_arc(Vector2.ZERO,25,-PI*0.5,-PI*0.5+TAU*vulnerable/1.65,24,Color("e8cb76"),2)
 if state=="windup":
  var a:=locked_direction.angle()
  draw_arc(Vector2.ZERO,90,a-0.42,a+0.42,14,Color("efae56"),3)
