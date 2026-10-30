extends "res://scripts/polished_opener.gd"
const Raider=preload("res://scripts/raider.gd")
const FINISHER_ART=preload("res://assets/executions/hero-spaced.png")
const CONTACT:=0.32
const DURATION:=0.78
var raiders: Array=[]
var executing=null
var execution_running:=false
var execution_clock:=0.0
var execution_contact:=false
var execution_cleave:=false
var execution_sign:=1.0
var execution_count:=0
var blood_enabled:=true
var dismember_enabled:=true
var combat_ready:=false
var execution_hint: Label
var selected_raider=null
var practice_mode:=Slots.practice or "--combat-yard" in OS.get_cmdline_user_args()
const HERO_RECTS=[Rect2(50,0,280,370),Rect2(420,0,275,370),Rect2(760,0,270,370),Rect2(1115,0,335,370),Rect2(1485,0,320,370),Rect2(1905,0,245,370)]
const HERO_ANCHORS=[174,565,905,1230,1603,2027]
func _ready() -> void:
 super._ready()
 for i in 3:
  var r=Raider.new();r.kind="orc" if i==2 else "goblin"
  r.position=[Vector2(1460,1240),Vector2(1830,1355),Vector2(2110,1355)][i];r.target=player;r.game=self
  actors.add_child(r);r.strike.connect(raider_strike);r.slain.connect(raider_slain);raiders.append(r)
 execution_hint=label("",16);execution_hint.position=Vector2(310,610);execution_hint.size=Vector2(660,36);execution_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 execution_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui_root.add_child(execution_hint)
 combat_ready=true;restore_combat(initial_save)
 if practice_mode:call_deferred("start_practice")
func start_practice() -> void:
 if creator:
  creator.hide();creator.queue_free();creator=null
 created=true;forged=true;introduced=true;bren_met=true;rewarded=true;returned=true;trophy=true;hunter_found=true
 player.equip("iron");apply_look();player.position=Vector2(850,970);camera.reset_smoothing()
 for i in raiders.size():
  raiders[i].position=[Vector2(1080,970),Vector2(1330,1200),Vector2(1660,1240)][i];raiders[i].home=raiders[i].position
 tip_shown.raiders=true
 close_modal();pause_actors(false)
 begin_sheet("Combat & gathering practice","UNSAVED PRACTICE SESSION","practice")
 modal_box.add_child(label("Your campaign is untouched. Raider targets are east and southeast; the training dummy is north. Chop nearby pines, collect timber with E, and compare leather/iron with C.\n\nWASD move · hold left mouse to swing · Space dodge. Two hits stagger a raider: move alongside and press F, or Shift+F for the goblin cleave.\n\nEsc opens combat options and Reset practice. Restart as often as you like.",17))
 button("Enter the yard",close_modal,modal_box);finish_sheet()
func update_quest() -> void:
 super.update_quest()
 if practice_mode:
  objective_text="Practice: axe and timber";objective_sub="Raiders east and southeast. Chop pines, collect timber. Esc to reset.";objective_pos=Vector2.ZERO
func manual_save() -> void:
 if practice_mode:say("Practice is unsaved; your campaign has not been changed.");return
 super.manual_save()
func _process(delta: float) -> void:
 raiders=raiders.filter(func(r):return is_instance_valid(r))
 super._process(delta)
 if not combat_ready:return
 var allowed:=room<0 and not modal.visible and not (creator and creator.visible)
 for r in raiders:
  r.active=allowed and forged;r.visible=room<0 and forged
  r.collision_layer=2 if r.hp>0 and r.active else 0
 execution_hint.visible=allowed and forged
 if not allowed:
  if execution_running:end_execution()
  return
 if forged and not tip_shown.has("raiders"):
  tip_shown.raiders=true;say("Raiders prowl the southern borderwood. Ordinary axe blows stagger them; F finishes a vulnerable foe from the side. The practice dummy is always available.")
 if execution_running:
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
# Cursor selection follows the visible torso, while damage still checks range and terrain.
func choose_target() -> void:
 super.choose_target()
 selected_raider=null
 var pointer=get_global_mouse_position()
 var best:=90.0
 for r in raiders:
  if not r.active or r.hp<=0 or player.position.distance_to(r.position)>125:continue
  var score: float=pointer.distance_to(r.position-Vector2(0,40))
  if score<best and has_line(player.position,r.position,null):selected_raider=r;best=score
 if selected_raider:
  selected_wolf=null;selected_id=""
func aim_direction() -> Vector2:
 if is_instance_valid(selected_raider) and selected_raider.hp>0:
  return (selected_raider.position-player.position).normalized()
 return super.aim_direction()
func _draw() -> void:
 super._draw()
 if room<0 and is_instance_valid(selected_raider) and selected_raider.hp>0:
  draw_arc(selected_raider.position,25,0,TAU,28,Color("d89056"),2)
func _notification(what: int) -> void:
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and combat_ready:
  held_attack=false;player.cancel_action()
  if execution_running:end_execution()
  if not modal.visible and not (creator and creator.visible):pause_menu()
func impact_feedback(pos: Vector2,kind: String,color: Color,word: String) -> void:
 # The blood option also covers the original wolf encounter.
 super.impact_feedback(pos,kind,Color("b9a16c") if kind=="hit" and not blood_enabled else color,word)
func enter_room(index: int) -> void:
 if execution_running:end_execution()
 super.enter_room(index)
func execution_target():
 if not combat_ready or room>=0 or modal.visible or work_time>0 or place_mode:return null
 var nearest=null;var distance:=96.0
 for r in raiders:
  var off: Vector2=r.position-player.position
  if r.eligible() and absf(off.y)<22 and absf(off.x)>=60 and off.length()<distance and has_line(player.position,r.position,null):
   nearest=r;distance=off.length()
 return nearest
func begin_execution(cleave: bool=false) -> bool:
 if execution_running or player.dodge_time>0 or player.attack_time>0.18 or player.action_locked:return false
 var r=execution_target()
 if r==null:return false
 executing=r;execution_running=true;execution_clock=0;execution_contact=false;execution_cleave=cleave and dismember_enabled and r.kind=="goblin"
 execution_sign=1.0 if r.position.x>player.position.x else -1.0
 held_attack=false;player.cancel_action();player.action_locked=true;player.recoil=Vector2.ZERO
 r.held=true;r.velocity=Vector2.ZERO;r.sprite.flip_h=execution_sign<0;r.pose(3)
 sound("swing");show_finisher();return true
func show_finisher() -> void:
 var index:=0 if execution_clock<0.06 else 1 if execution_clock<0.17 else 2 if execution_clock<CONTACT else 3 if execution_clock<0.46 else 4 if execution_clock<0.61 else 5
 var rect: Rect2=HERO_RECTS[index]
 if player.equipment=="iron":rect.position.y=370;rect.size.y=354
 var s: Sprite2D=player.sprite;s.texture=FINISHER_ART;s.region_rect=rect;s.scale=Vector2.ONE*0.42;s.flip_h=execution_sign<0
 Appearance.frame(player.look_material,FINISHER_ART,rect,2,"finisher",index)
 s.position=Vector2((rect.get_center().x-HERO_ANCHORS[index])*0.42*execution_sign,(rect.size.y*0.5-(341 if player.equipment=="iron" else 365))*0.42+4)
func end_execution() -> void:
 if is_instance_valid(executing) and executing.hp>0:
  executing.held=false;executing.vulnerable=maxf(executing.vulnerable,0.25)
 executing=null;execution_running=false;player.action_locked=false;player.sprite.flip_h=false;player.face(Vector2(execution_sign,0));player.show_locomotion(false)
 held_attack=false
func _unhandled_input(event: InputEvent) -> void:
 if execution_running:
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
 if room>=0 or work_time>0 or execution_running:return
 var nearest=null;var distance:=112.0
 for r in raiders:
  var off: Vector2=r.position-player.position
  if r.active and r.hp>0 and off.length()<distance and off.normalized().dot(direction)>0.38 and has_line(player.position,r.position,null):nearest=r;distance=off.length()
 if nearest:
  nearest.receive_hit(45 if forged else 32,direction)
  impact_feedback(nearest.position-Vector2(0,15),"hit",Color("743a32"),"")
  return
 super.player_hit(direction)
func raider_strike(r) -> void:
 if room>=0 or modal.visible:return
 var off: Vector2=player.position-r.position
 if off.length()<100 and off.normalized().dot(r.locked_direction)>0.4 and player.invulnerable<=0 and has_line(r.position,player.position,null):
  hurt((26 if r.kind=="orc" else 15)*(0.6 if player.equipment=="iron" else 1.0));player.invulnerable=0.45;player.recoil=r.locked_direction*130;shake=3.2;sound("hit")
func raider_slain(r) -> void:
 for f in floating:
  if f.pos.distance_to(r.position-Vector2(0,65))<120:f.time=0
 toast("Rival felled" if r.kind=="orc" else "Raider felled",r.position-Vector2(0,60))
func hurt(amount: float) -> void:
 if execution_running:end_execution()
 super.hurt(amount)
 if modal.visible:
  for r in raiders:
   if r.hp>0:r.position=r.home;r.state="idle";r.cooldown=1;r.vulnerable=0
func pause_actors(paused: bool) -> void:
 if paused and execution_running:end_execution()
 super.pause_actors(paused)
 for r in raiders:r.active=not paused and room<0 and forged
func pause_menu() -> void:
 super.pause_menu()
 var extras=HBoxContainer.new();extras.add_theme_constant_override("separation",8);modal_box.add_child(extras)
 button("Appearance",edit_appearance,extras).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button("Combat & brutality",combat_menu,extras).size_flags_horizontal=Control.SIZE_EXPAND_FILL
 if practice_mode:
  button("Reset practice",func():get_tree().reload_current_scene(),extras).size_flags_horizontal=Control.SIZE_EXPAND_FILL
  for child in modal_box.get_children():
   if child is Label and child.text.begins_with("Autosaves"):child.text="Unsaved practice. Your campaign is untouched."
 finish_sheet()
func combat_menu() -> void:
 begin_sheet("Axe and Iron","OPTIONAL FINISHERS  ·  0.4.0","combat")
 modal_box.add_child(label("Once you have earned the iron kit, raiders threaten the southern borderwood. Wound or stagger them with ordinary attacks. Move alongside a vulnerable enemy, then press F.\n\nFinishers are optional. Space cancels before contact; normal attacks can still kill. Shift+F requests the goblin cleave. Rival Orcs remain intact.",17))
 button("Blood: "+("On" if blood_enabled else "Off"),func():blood_enabled=not blood_enabled;combat_menu(),modal_box)
 button("Dismemberment: "+("On" if dismember_enabled else "Off"),func():dismember_enabled=not dismember_enabled;combat_menu(),modal_box)
 button("Return",pause_menu,modal_box);finish_sheet()
func save_game(path: String=OPENER_SAVE) -> bool:
 path=Slots.resolve(path)
 if practice_mode:return false
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
 path=Slots.resolve(path)
 if practice_mode:return false
 if not super.load_game(path):return false
 if combat_ready:
  if execution_running:end_execution()
  restore_combat(initial_save)
 return true
func restore_combat(data: Dictionary) -> void:
 # Loading a legacy save must not inherit this session's corpses or held targets.
 for r in raiders:
  r.hp=r.maximum;r.held=false;r.vulnerable=0;r.vulnerable_cooldown=0;r.posture=0
  r.state="idle";r.clock=0;r.cooldown=0.8;r.cleaved=false;r.death_clock=0
  r.position=r.home;r.velocity=Vector2.ZERO;r.recoil=Vector2.ZERO;r.fear=0;r.flash=0
 var c=data.get("combat",{})
 if not c is Dictionary:c={}
 blood_enabled=c.get("blood",true) if c.get("blood",true) is bool else true
 dismember_enabled=c.get("dismember",true) if c.get("dismember",true) is bool else true
 execution_count=maxi(0,int(c.get("executions",0))) if numeric(c.get("executions",0)) else 0
 var saved=c.get("raiders",[])
 if not saved is Array:return
 for i in mini(saved.size(),raiders.size()):
  if not saved[i] is Dictionary or not numeric(saved[i].get("hp")):continue
  var r=raiders[i];r.hp=clampf(float(saved[i].hp),0,r.maximum);r.held=false;r.vulnerable=0;r.state="dead" if r.hp<=0 else "idle"
  r.cleaved=bool(saved[i].get("cleaved",false)) and r.kind=="goblin";r.death_clock=1
