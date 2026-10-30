extends SceneTree
var world
var failures:=0
var checks:=0
func _initialize(): call_deferred("run")
func check(ok: bool,msg: String):
    checks+=1
    if ok: print("PASS: "+msg)
    else: failures+=1; push_error("FAIL: "+msg)
func frames(n: int):
    for i in n: await physics_frame
func key(code: Key):
    var e=InputEventKey.new(); e.physical_keycode=code; e.pressed=true; world._unhandled_input(e)
func walk_to(dest: Vector2,radius: float=35) -> bool:
    for i in 2400:
        if world.player.position.distance_to(dest)<radius:
            world.player.drive=Vector2.ZERO; await frames(3); return true
        world.player.drive=world.route_direction(world.player,dest)
        await physics_frame
    world.player.drive=Vector2.ZERO
    push_error("Walk stalled at %s heading to %s"%[world.player.position,dest])
    return false
func strike_at(pos: Vector2):
    world.player.request_attack(pos-world.player.position)
    await frames(45)
func run():
    world=load("res://scenes/opener.tscn").instantiate(); root.add_child(world)
    await frames(4)
    world.show_creator(); world.name_input.text="  Rokhan  "; world.complexion=1; world.cloth=1; world.begin_character()
    world.player.controlled=false
    check(world.created and world.character_name=="Rokhan" and world.player.is_physics_processing(),"creator commits identity and releases control")
    check(await walk_to(world.DORS(0),35),"hall door is reachable from spawn")
    key(KEY_E); await frames(2)
    check(world.room==0,"door interaction enters hall")
    world.player.drive=Vector2.UP; await frames(30); world.player.drive=Vector2.ZERO
    key(KEY_E); await frames(2)
    check(world.introduced and world.modal.visible,"walking to Yrsa starts opening conversation")
    key(KEY_ESCAPE)
    check(await walk_to(Vector2(768,655),28),"interior exit reachable")
    key(KEY_E); await frames(2)
    check(world.room==-1,"same doorway returns to village")
    check(await walk_to(world.worker.position,70),"Bren reachable around hall collision")
    key(KEY_E); await frames(2); check(world.bren_met,"Bren introduces building and practice"); key(KEY_ESCAPE)
    for id in ["pine_0","pine_1"]:
        var p: Vector2=world.state.point(world.state.objects[id])
        check(await walk_to(p+Vector2(0,70),20),"approach "+id)
        var before: float=world.state.objects[id].hp
        world.player.request_attack(p-world.player.position); await frames(10)
        check(world.state.objects[id].hp==before,"axe windup cannot damage early")
        await frames(35)
        for i in 3: await strike_at(p)
        check(world.state.objects[id].state=="felled","four actual swings fell "+id)
        key(KEY_E); await frames(3)
    check(world.state.timber==6 and world.collected==6,"two physical bundles supply six timber")
    check(await walk_to(world.DORS(2),50),"construction site is reachable")
    key(KEY_E); await frames(20); key(KEY_ESCAPE); await frames(3)
    check(world.built==0 and world.state.timber==6 and not world.player.action_locked,"cancelled construction preserves materials and control")
    for i in 3: key(KEY_E); await frames(60)
    check(world.built==3 and world.state.timber==0,"three completed work actions build storehouse")
    check(await walk_to(world.DUMMY+Vector2(0,70),15),"practice yard reachable")
    for i in 3: await strike_at(world.DUMMY)
    key(KEY_SPACE); await frames(45); world.player.drive=Vector2.ZERO
    check(world.training_hits==3 and world.training_dodges==1,"training accepts contact frames and dodge input")
    check(await walk_to(world.HUNTER_HOME+Vector2(-60,40),25),"eastern trail leads to hunter through live collisions")
    key(KEY_E); await frames(2)
    check(world.hunter_found,"hunter conversation enables expedition goal"); key(KEY_ESCAPE)
    var frozen: Vector2=world.wolves[0].position
    world.pause_menu(); await frames(60)
    check(world.wolves[0].position==frozen and not world.player.is_physics_processing(),"pause freezes both sides of encounter")
    key(KEY_ESCAPE)
    for w in world.wolves:
        if not await walk_to(w.home+Vector2(-220,100),30): failures+=1; break
        var windups:=0
        for tick in 2400:
            if w.hp<=0: break
            if world.modal.visible: world.close_modal()
            var off: Vector2=w.position-world.player.position
            if world.player.dodge_time>0: pass
            elif w.stage=="windup":
                windups+=1
                world.player.drive=w.locked_direction.orthogonal()
                if w.clock>0.28: world.player.dodge(w.locked_direction.orthogonal())
            elif off.length()>80: world.player.drive=world.route_direction(world.player,w.position)
            else:
                world.player.drive=Vector2.ZERO
                world.player.request_attack(off)
            if world.hp<55 and world.meat>0: key(KEY_1)
            await physics_frame
        world.player.drive=Vector2.ZERO
        check(w.hp<=0 and windups>0,"live combat defeats %s after telegraphed charges"%w.loot_id)
        check(await walk_to(w.position,60),"carcass reachable")
        key(KEY_E); await frames(3)
        check(w.harvested,"one interaction harvests carcass")
    check(world.trophy,"pack leader awards quest pelt")
    check(await walk_to(Vector2(1300,650),40),"return trail is navigable")
    await frames(3); check(world.returned,"returning with pelt brings Torren home")
    check(await walk_to(world.DORS(0),35),"hall remains accessible after expedition")
    key(KEY_E); await frames(2); world.player.drive=Vector2.UP; await frames(30); world.player.drive=Vector2.ZERO
    key(KEY_E); await frames(2); world.claim_reward()
    check(world.rewarded and world.ore>=4 and world.state.timber>=2,"Yrsa grants material reward")
    var ore_before: int=world.ore; world.claim_reward()
    check(world.ore==ore_before,"reward cannot duplicate")
    world.leave_and_close()
    check(await walk_to(world.DORS(1),35),"forge door is reachable")
    key(KEY_E); await frames(2); world.player.drive=Vector2.UP; await frames(30); world.player.drive=Vector2.ZERO
    key(KEY_E); await frames(2); world.forge(); await frames(2)
    check(world.forged and world.player.equipment=="iron" and world.modal.visible,"forge equips earned iron and closes opening with dialogue")
    world.leave_and_close(); world.update_quest()
    check(world.objective_text=="Your place at the hearth","journal reaches completed opener")
    check(world.save_game("user://opener_test.json"),"opening save writes")
    world.rewarded=false; world.character_name="wrong"; world.wolves[3].hp=180
    check(world.load_game("user://opener_test.json"),"opening save reloads")
    check(world.rewarded and world.character_name=="Rokhan" and world.wolves[3].hp==0 and world.wolves[3].harvested,"identity, reward, depletion and encounter state survive reload")
    world.worker_active=true
    for i in 2400:
        if world.stored>=3: break
        await physics_frame
    check(world.stored>=3,"assigned worker navigates, cuts and deposits actual timber")
    print("OPENER CHECKS: %s; FAILURES: %s; RECOVERIES: %s"%[checks,failures,world.recovered_count])
    world.queue_free(); await frames(3); quit(1 if failures else 0)
