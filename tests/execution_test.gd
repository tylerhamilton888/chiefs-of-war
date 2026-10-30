extends SceneTree
var world
var checks:=0
var failures:=0
func _initialize():call_deferred("run")
func frames(n: int):
 for i in n:await physics_frame
func check(ok: bool,msg: String):
 checks+=1
 if ok:print("PASS: "+msg)
 else:failures+=1;push_error("FAIL: "+msg)
func reset_enemy(kind: String="goblin"):
 if world.executing!=null:world.end_execution()
 world.close_modal();world.room=-1;world.forged=true;world.player.controlled=false;world.player.cancel_action();world.player.action_locked=false;world.player.recoil=Vector2.ZERO
 world.player.position=Vector2(870,970);world.player.dodge_cooldown=0;world.player.invulnerable=0
 for r in world.raiders:r.set_physics_process(false);r.position=Vector2(3400,1300)
 var r=world.raiders[0];r.position=Vector2(950,970);r.kind=kind;r.maximum=180 if kind=="orc" else 110;r.hp=r.maximum;r.posture=0;r.vulnerable=0;r.vulnerable_cooldown=0;r.state="idle";r.held=false;r.active=true;r.cleaved=false;r.death_clock=0
 return r
func key(code: Key):
 var e=InputEventKey.new();e.physical_keycode=code;e.pressed=true;world._unhandled_input(e)
func run():
 world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(5)
 world.created=true
 var r=reset_enemy();await frames(2)
 check(not world.begin_execution(),"unearned target refuses execution")
 r.receive_hit(32,Vector2.RIGHT);r.receive_hit(32,Vector2.RIGHT)
 check(r.vulnerable>0 and r.hp==46,"two valid hits earn a window without forced death")
 world.player.position.y-=60;check(not world.begin_execution(),"vertical approach requires supported side-on alignment")
 world.player.position=Vector2(810,970);check(not world.begin_execution(),"execution rejects excessive range")
 world.player.position=Vector2(870,970)
 world.boundary(world.outdoors,Rect2(908,950,8,40),1);var wall=world.outdoors.get_child(-1);await frames(2)
 check(not world.begin_execution(),"blocking terrain rejects finisher")
 wall.queue_free();await frames(2)
 check(world.begin_execution(),"earned clear side-on execution begins")
 check(r.held and world.player.action_locked,"only participating actors are held")
 await frames(9);key(KEY_SPACE)
 check(world.executing==null and not r.held and not world.player.action_locked and r.hp==46,"Space before impact cancels without damage or stuck actors")
 r=reset_enemy();r.receive_hit(32,Vector2.RIGHT);r.receive_hit(32,Vector2.RIGHT);await frames(2)
 world.begin_execution();world.pause_menu();await frames(2)
 check(world.executing==null and not r.held and not world.player.action_locked and r.hp==46,"pause releases both actors before impact")
 r=reset_enemy();r.vulnerable=1.65;world.begin_execution();world.hurt(1)
 check(world.executing==null and not r.held and r.hp>0,"incoming damage interrupts before contact")
 r=reset_enemy();r.vulnerable=1.65;world.dismember_enabled=true
 var before: int=world.execution_count
 check(world.begin_execution(true),"requested goblin cleave starts")
 await frames(14);check(r.hp>0 and world.execution_count==before,"damage waits for shared contact time")
 await frames(10);check(r.hp==0 and r.cleaved and world.execution_count==before+1,"contact kills once and selects goblin cleave")
 key(KEY_SPACE);check(world.executing!=null,"post-contact recovery is a short commitment")
 await frames(30);check(world.executing==null and not world.player.action_locked,"control recovers after bounded finisher duration")
 check(world.execution_count==before+1,"holding through recovery cannot duplicate execution reward")
 r=reset_enemy();r.vulnerable=1.65;world.dismember_enabled=false;world.begin_execution(true);await frames(50)
 check(r.hp==0 and not r.cleaved,"disabled dismemberment uses intact kill even when cleave requested")
 r=reset_enemy("orc");r.vulnerable=1.65;world.dismember_enabled=true;world.player.position=Vector2(1030,970)
 check(world.begin_execution(true) and world.player.sprite.flip_h,"opposite-side iron/leather sequence mirrors the whole character")
 await frames(50);check(r.hp==0 and not r.cleaved and not world.player.sprite.flip_h,"rival Orc remains intact and actor mirroring resets")
 r=reset_enemy();r.receive_hit(200,Vector2.RIGHT)
 check(r.hp==0 and not world.begin_execution(),"ordinary attacks remain lethal and corpses cannot execute")
 r=reset_enemy();r.vulnerable=1.65;world.begin_execution();r.hp=0;await frames(30)
 check(world.executing==null and not world.player.action_locked,"unexpected target death releases player")
 r=reset_enemy();r.hp=23;world.blood_enabled=false;world.dismember_enabled=false
 check(world.save_game("user://execution_test.json"),"extended campaign save writes")
 r.hp=100;world.blood_enabled=true;world.dismember_enabled=true
 check(world.load_game("user://execution_test.json") and r.hp==23 and not world.blood_enabled and not world.dismember_enabled,"combat health and independent options survive reload")
 var data=JSON.parse_string(FileAccess.get_file_as_string("user://execution_test.json"));data.erase("combat")
 var file=FileAccess.open("user://legacy_execution_test.json",FileAccess.WRITE);file.store_string(JSON.stringify(data));file.close()
 check(world.load_game("user://legacy_execution_test.json") and r.hp==r.maximum and not r.cleaved,"legacy save resets combat instead of inheriting another campaign")
 r=reset_enemy();r.cleaved=true;r.hp=0;r.state="dead";r.death_clock=1
 world.dismember_enabled=false;r._physics_process(0.01)
 check(r.sprite.region_rect==r.RECTS[0][5] and r.cleaved,"turning dismemberment off immediately shows an intact existing corpse")
 world.dismember_enabled=true;r._physics_process(0.01)
 check(r.sprite.region_rect==r.RECTS[1][5],"corpse presentation toggles without overwriting saved outcome")
 r=reset_enemy();r.vulnerable=1.65;world.begin_execution();world.enter_room(0)
 check(world.executing==null and not r.held and not world.player.action_locked,"room transition releases finisher participants")
 r=reset_enemy();r.vulnerable=1.65;world.begin_execution();r.queue_free();await frames(3)
 check(world.executing==null and not world.player.action_locked,"removed target releases control without invalid-object access")
 world.queue_free();await frames(3)
 print("EXECUTION CHECKS: %s; FAILURES: %s"%[checks,failures]);quit(1 if failures else 0)
