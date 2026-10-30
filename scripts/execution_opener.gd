extends "res://scripts/polished_opener.gd"
const Raider=preload("res://scripts/raider.gd")
const FINISHER_ART=preload("res://assets/executions/hero.png")
const CONTACT:=0.32
const DURATION:=0.78
var raiders: Array=[]
var executing=null
var execution_clock:=0.0
var execution_contact:=false
var execution_cleave:=false
var execution_sign:=1.0
var execution_count:=0
var blood_enabled:=true
var dismember_enabled:=true
var combat_ready:=false
var execution_hint: Label
const HERO_RECTS=[Rect2(30,0,280,444),Rect2(303,0,278,444),Rect2(582,0,280,444),Rect2(880,0,355,444),Rect2(1210,0,324,444),Rect2(1535,0,235,444)]
const HERO_ANCHORS=[160,450,735,1000,1330,1650]
func _ready() -> void:
 super._ready()
 for i in 3:
  var r=Raider.new();r.kind="orc" if i==2 else "goblin"
  r.position=[Vector2(1460,1240),Vector2(1830,1355),Vector2(2110,1355)][i];r.target=player;r.game=self
  actors.add_child(r);r.strike.connect(raider_strike);r.slain.connect(raider_slain);raiders.append(r)
 execution_hint=label("",16);execution_hint.position=Vector2(310,690);execution_hint.size=Vector2(660,36);execution_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 execution_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui_root.add_child(execution_hint)
 combat_ready=true;restore_combat(initial_save)
func _process(delta: float) -> void:
 super._process(delta)
 if not combat_ready:return
 var allowed:=room<0 and not modal.visible and not (creator and creator.visible)
 for r in raiders:
  r.active=allowed and forged;r.visible=room<0 and forged
  r.collision_layer=2 if r.hp>0 and r.active else 0
 execution_hint.visible=allowed and forged
 if not allowed:return
 if executing!=null:
  if not is_instance_valid(executing):end_execution();return
  execution_clock+=delta
  if not execution_contact and execution_clock>=CONTACT:
   if executing.hp<=0 or not has_line(player.position,executing.position,null):end_execution();return
   execution_contact=true;executing.held=false;executing.die(execution_cleave)
   execution_count+=1;sound("metal" if executing.kind=="orc" else "hit");shake=3.2
   player.invulnerable=maxf(player.invulnerable,0.15)
   if blood_enabled:burst(executing.position-Vector2(0,40),Color("743a32"))
   for r in raiders:
    if r!=executing and r.hp>0 and r.position.distance_to(executing.position)<170:r.fear=0.45
  show_finisher()
  execution_hint.text="Space cancels before contact" if not execution_contact else ""
  if execution_clock>=DURATION:end_execution()
 else:
  var r=execution_target()
  execution_hint.text=("F  •  Finish"+("     Shift+F  •  Cleave" if dismember_enabled and r.kind=="goblin" else "")) if r else ""
func execution_target():
 if not combat_ready or room>=0 or modal.visible or work_time>0 or place_mode:return null
 var nearest=null;var distance:=106.0
 for r in raiders:
  var off: Vector2=r.position-player.position
  if r.eligible() and absf(off.y)<26 and absf(off.x)>=45 and off.length()<distance and has_line(player.position,r.position,null):
   nearest=r;distance=off.length()
 return nearest
func begin_execution(cleave: bool=false) -> bool:
 if executing!=null or player.dodge_time>0 or player.attack_time>0.18 or player.action_locked:return false
 var r=execution_target()
 if r==null:return false
 executing=r;execution_clock=0;execution_contact=false;execution_cleave=cleave and dismember_enabled and r.kind=="goblin"
 execution_sign=1.0 if r.position.x>player.position.x else -1.0
 held_attack=false;player.cancel_action();player.action_locked=true;player.recoil=Vector2.ZERO
 r.held=true;r.velocity=Vector2.ZERO;r.sprite.flip_h=execution_sign<0;r.pose(3)
 sound("swing");show_finisher();return true
func show_finisher() -> void:
 var index:=0 if execution_clock<0.06 else 1 if execution_clock<0.17 else 2 if execution_clock<CONTACT else 3 if execution_clock<0.46 else 4 if execution_clock<0.61 else 5
 var rect: Rect2=HERO_RECTS[index]
 if player.equipment=="iron":rect.position.y=444;rect.size.y=443
 var s: Sprite2D=player.sprite;s.texture=FINISHER_ART;s.region_rect=rect;s.scale=Vector2.ONE*0.37;s.flip_h=execution_sign<0
 s.position=Vector2((rect.get_center().x-HERO_ANCHORS[index])*0.37*execution_sign,(rect.size.y*0.5-438)*0.37+4)
func end_execution() -> void:
 if is_instance_valid(executing) and executing.hp>0:
  executing.held=false;executing.vulnerable=maxf(executing.vulnerable,0.25)
 executing=null;player.action_locked=false;player.sprite.flip_h=false;player.face(Vector2(execution_sign,0));player.show_locomotion(false)
 held_attack=false
func _unhandled_input(event: InputEvent) -> void:
 if executing!=null:
  if event is InputEventKey and event.pressed and not event.echo:
   if event.physical_keycode==KEY_SPACE and not execution_contact:
    end_execution();player.dodge(Input.get_vector("move_left","move_right","move_up","move_down"))
   elif event.physical_keycode==KEY_ESCAPE:
    end_execution();pause_menu()
  return
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F:
  begin_execution(event.shift_pressed);return
 super._unhandled_input(event)
func player_hit(direction: Vector2) -> void:
 if room>=0 or work_time>0 or executing!=null:return
 var nearest=null;var distance:=112.0
 for r in raiders:
  var off: Vector2=r.position-player.position
  if r.active and r.hp>0 and off.length()<distance and off.normalized().dot(direction)>0.38 and has_line(player.position,r.position,null):nearest=r;distance=off.length()
 if nearest:
  nearest.receive_hit(45 if forged else 32,direction);sound("hit");player.hit_stop=0.035;shake=2.3
  if blood_enabled:burst(nearest.position-Vector2(0,35),Color("743a32"))
  return
 super.player_hit(direction)
func raider_strike(r) -> void:
 if room>=0 or modal.visible:return
 var off: Vector2=player.position-r.position
 if off.length()<100 and off.normalized().dot(r.locked_direction)>0.4 and player.invulnerable<=0 and has_line(r.position,player.position,null):
  hurt((26 if r.kind=="orc" else 15)*(0.6 if player.equipment=="iron" else 1.0));player.invulnerable=0.45;sound("hit")
func raider_slain(r) -> void:
 toast("Rival felled" if r.kind=="orc" else "Raider felled",r.position-Vector2(0,60))
func hurt(amount: float) -> void:
 if executing!=null:end_execution()
 super.hurt(amount)
 if modal.visible:
  for r in raiders:
   if r.hp>0:r.position=r.home;r.state="idle";r.cooldown=1;r.vulnerable=0
func pause_actors(paused: bool) -> void:
 if paused and executing!=null:end_execution()
 super.pause_actors(paused)
 for r in raiders:r.active=not paused and room<0 and forged
func pause_menu() -> void:
 super.pause_menu()
 var b=button("Combat & brutality",combat_menu,modal_box);modal_box.move_child(b,modal_box.get_child_count()-1);finish_sheet()
func combat_menu() -> void:
 begin_sheet("Axe and Iron","OPTIONAL FINISHERS  ·  0.4.0","combat")
 modal_box.add_child(label("Once you have earned the iron kit, raiders threaten the southern borderwood. Wound or stagger them with ordinary attacks. Move alongside a vulnerable enemy, then press F.\n\nFinishers are optional. Space cancels before contact; normal attacks can still kill. Shift+F requests the goblin cleave. Rival Orcs remain intact.",17))
 button("Blood: "+("On" if blood_enabled else "Off"),func():blood_enabled=not blood_enabled;combat_menu(),modal_box)
 button("Dismemberment: "+("On" if dismember_enabled else "Off"),func():dismember_enabled=not dismember_enabled;combat_menu(),modal_box)
 button("Return",pause_menu,modal_box);finish_sheet()
func save_game(path: String=OPENER_SAVE) -> bool:
 if not super.save_game(path):return false
 if not combat_ready:return true
 var data=JSON.parse_string(FileAccess.get_file_as_string(path))
 data.combat={"blood":blood_enabled,"dismember":dismember_enabled,"executions":execution_count,"raiders":[]}
 for r in raiders:data.combat.raiders.append({"hp":r.hp,"cleaved":r.cleaved})
 var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
 if file==null:return false
 file.store_string(JSON.stringify(data));file.close()
 return DirAccess.rename_absolute(path+".tmp",path)==OK
func load_game(path: String=OPENER_SAVE) -> bool:
 if not super.load_game(path):return false
 if combat_ready:
  if executing!=null:end_execution()
  restore_combat(initial_save)
 return true
func restore_combat(data: Dictionary) -> void:
 var c=data.get("combat",{})
 if not c is Dictionary:return
 blood_enabled=c.get("blood",true) if c.get("blood",true) is bool else true
 dismember_enabled=c.get("dismember",true) if c.get("dismember",true) is bool else true
 execution_count=maxi(0,int(c.get("executions",0))) if numeric(c.get("executions",0)) else 0
 var saved=c.get("raiders",[])
 if not saved is Array:return
 for i in mini(saved.size(),raiders.size()):
  if not saved[i] is Dictionary or not numeric(saved[i].get("hp")):continue
  var r=raiders[i];r.hp=clampf(float(saved[i].hp),0,r.maximum);r.held=false;r.vulnerable=0;r.state="dead" if r.hp<=0 else "idle"
  r.cleaved=bool(saved[i].get("cleaved",false)) and r.kind=="goblin" and dismember_enabled;r.death_clock=1
