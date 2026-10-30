extends Node2D
const Actor=preload("res://scripts/camp_actor.gd")
const State=preload("res://scripts/world_state.gd")
const Prop=preload("res://scripts/camp_prop.gd")
const Terrain=preload("res://scripts/camp_terrain.gd")
const Building=preload("res://scripts/building.gd")
const Slots=preload("res://scripts/save_slots.gd")
const SAVE="user://first_hearth_v1.json"
const DOORS=[Vector2(550,350),Vector2(930,350),Vector2(710,740)]
const NAMES=["The Ash Hall","Harn's Forge","Timber Store"]
var state=State.new()
var outdoors=Node2D.new()
var actors=Node2D.new()
var interior=Node2D.new()
var props={}
var buildings=[]
var player
var worker
var enemies=[]
var camera=Camera2D.new()
var room:=-1
var return_pos:=Vector2(680,490)
var hp:=100.0
var ore:=0
var meat:=2
var stored:=0
var built:=0
var forged:=false
var worker_active:=false
var worker_target:=""
var worker_cargo:=0
var kills:=0
var trees_cut:=0
var collected:=0
var quest:=0
var elapsed:=0.0
var fire_clock:=0.0
var auto_clock:=0.0
var drill:=-1.0
var notice_time:=0.0
var hp_bar: ProgressBar
var info: Label
var journal: Label
var context: Label
var notice: Label
var location_label: Label
var modal: PanelContainer
var modal_box: VBoxContainer
var tint=CanvasModulate.new()
var particles=[]
var place_mode:=false
var day:=0.18
var ui_root: Control
var room_npc: Sprite2D
var floor_texture=preload("res://assets/camp/floor.png")
var sounds={}

func _ready() -> void:
    for action in {"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
            var key=InputEventKey.new()
            key.physical_keycode={"move_left":KEY_A,"move_right":KEY_D,"move_up":KEY_W,"move_down":KEY_S}[action]
            InputMap.action_add_event(action,key)
    outdoors.z_index=-2
    add_child(outdoors)
    var ground=Terrain.new()
    ground.state=state
    outdoors.add_child(ground)
    actors.y_sort_enabled=true
    outdoors.add_child(actors)
    seed_camp()
    player=Actor.new()
    player.position=return_pos
    actors.add_child(player)
    player.impact.connect(player_hit)
    player.add_child(camera)
    camera.offset=Vector2(145,-35)
    camera.position_smoothing_enabled=true
    camera.position_smoothing_speed=8
    worker=Actor.new()
    worker.controlled=false
    worker.position=Vector2(350,520)
    actors.add_child(worker)
    worker.modulate=Color(0.90,0.80,0.68)
    worker.impact.connect(worker_hit)
    for i in 3:
        var enemy=Actor.new()
        enemy.controlled=false
        enemy.position=Vector2(1180+i*100,780+(i%2)*90)
        actors.add_child(enemy)
        enemy.equip("iron")
        enemy.modulate=Color(1.0,0.65,0.55)
        enemy.impact.connect(enemy_hit.bind(i))
        enemies.append({"actor":enemy,"hp":100.0,"home":enemy.position,"cooldown":0.0,"windup":false})
    for i in 3:
        var b=Building.new()
        b.kind=i
        b.position=DOORS[i]
        actors.add_child(b)
        buildings.append(b)
    for rect in [Rect2(-40,-40,1616,40),Rect2(-40,1024,1616,40),Rect2(-40,0,40,1024),Rect2(1536,0,40,1024)]:
        boundary(outdoors,rect,1)
    add_child(interior)
    interior.hide()
    setup_interior()
    add_child(tint)
    create_ui()
    for name in ["wood","metal","hit","step"]:
        var p="res://assets/camp/"+name+".wav"
        if ResourceLoader.exists(p): sounds[name]=load(p)
    if not "--fresh" in OS.get_cmdline_user_args() and not Slots.fresh and not Slots.practice: load_game()
    sync_props()
    say("Ashfang Camp. Your axe, your hands, your future. Enter the hall or follow the journal.")

func boundary(parent: Node,rect: Rect2,layer: int) -> void:
    var body=StaticBody2D.new()
    body.collision_layer=layer
    body.position=rect.get_center()
    var col=CollisionShape2D.new()
    var shape=RectangleShape2D.new()
    shape.size=rect.size
    col.shape=shape
    body.add_child(col)
    parent.add_child(body)

func seed_camp() -> void:
    for i in 24:
        var side: int=i%2
        var pos=Vector2(140+side*1050+(i%3)*65,230+int(i/2)*57)
        state.add_object("tree",pos,"pine_%s"%i)
    for i in 5: state.add_object("rock",Vector2(950+i*95,530+(i%2)*65),"ore_%s"%i)
    state.add_object("hearth",Vector2(650,510),"hearth")
    for i in 2: add_modules(i)
    for y in range(10,27):
        for x in range(16,30):
            if y in range(13,17) or x in range(19,22): state.set_terrain(Vector2i(x,y),"earth")

func add_modules(index: int) -> void:
    for j in 3:
        state.add_object("wall",DOORS[index]+Vector2((j-1)*78,-55),"building_%s_%s"%[index,j])
    state.add_object("roof",DOORS[index]+Vector2(0,-100),"building_%s_roof"%index)

func sync_props() -> void:
    for id in state.objects:
        if id.begins_with("building_"): continue
        if not props.has(id):
            var p=Prop.new()
            p.data=state.objects[id]
            p.player=player
            actors.add_child(p)
            props[id]=p
        props[id].data=state.objects[id]
        props[id].refresh()
    for i in buildings.size():
        var health:=0.0
        var parts: Array[float]=[]
        for j in 3:
            var id="building_%s_%s"%[i,j]
            var part: float=state.objects[id].hp/150.0 if state.objects.has(id) else 0.0
            parts.append(part)
            health+=part/3.0
        buildings[i].integrity=health
        buildings[i].parts=parts
        buildings[i].visible=i<2 or built==3

func setup_interior() -> void:
    for rect in [Rect2(375,220,786,35),Rect2(375,220,35,480),Rect2(1126,220,35,480),Rect2(375,680,786,35)]: boundary(interior,rect,4)
    room_npc=Sprite2D.new()
    room_npc.texture=load("res://assets/camp/npcs.png")
    room_npc.region_enabled=true
    room_npc.position=Vector2(800,440)
    interior.add_child(room_npc)
    for i in 5:
        var wall=Sprite2D.new()
        wall.texture=load("res://assets/camp/props.png")
        wall.region_enabled=true
        wall.region_rect=Rect2(525,520,490,495)
        wall.scale=Vector2(0.30,0.17)
        wall.position=Vector2(460+i*145,250)
        interior.add_child(wall)
    for i in 3:
        var s=Sprite2D.new()
        s.texture=load("res://assets/camp/architecture.png")
        s.region_enabled=true
        var w: float=s.texture.get_width()/3.0
        var h: float=s.texture.get_height()/2.0
        s.region_rect=[Rect2(35,600,485,370),Rect2(555,560,485,410),Rect2(1090,570,435,400)][i]
        s.scale=Vector2.ONE*0.32
        s.position=Vector2(520+i*240,330)
        interior.add_child(s)
        boundary(interior,Rect2(s.position+Vector2(-60,5),Vector2(120,38)),4)

func _draw() -> void:
    if room>=0:
        draw_rect(Rect2(-2000,-2000,6000,6000),Color("111313"))
        draw_rect(Rect2(375,220,786,495),Color("241d18"))
        draw_texture_rect(floor_texture,Rect2(410,255,716,425),false,Color(0.85,0.85,0.85))
        draw_rect(Rect2(690,390,155,205),Color("5b2824"))
        draw_rect(Rect2(697,397,141,191),Color("957042"),false,2)
        for y in range(420,580,35):
            draw_polyline(PackedVector2Array([Vector2(712,y),Vector2(730,y-9),Vector2(748,y),Vector2(730,y+9),Vector2(712,y)]),Color("9d7950"),2)
        draw_rect(Rect2(735,660,65,22),Color("b58a51"))
    else:
        # Storehouse stakes communicate each of the three construction stages.
        if built<3:
            draw_rect(Rect2(590,620,240,120),Color(0.5,0.45,0.3,0.22),false,3)
            for i in 4: draw_line(Vector2(595+i*75,740),Vector2(595+i*75,705-built*30),Color("8c6f47"),7)
        if place_mode:
            var p=(get_global_mouse_position()/32).floor()*32+Vector2(16,16)
            draw_rect(Rect2(p-Vector2(42,10),Vector2(84,20)),Color(0.2,0.8,0.4,0.5) if can_build(p) else Color(0.9,0.2,0.2,0.5))
        for i in buildings.size():
            for j in 3:
                var id="building_%s_%s"%[i,j]
                if state.objects.has(id) and state.objects[id].burning:
                    var p=state.point(state.objects[id])
                    draw_circle(p-Vector2(0,35),18+sin(elapsed*9+j)*6,Color(1,0.4,0.03,0.8))
        for e in enemies:
            if e.hp<=0: continue
            var p: Vector2=e.actor.position
            draw_line(p+Vector2(-25,-100),p+Vector2(25,-100),Color("301a19"),5)
            draw_line(p+Vector2(-25,-100),p+Vector2(-25+e.hp*0.5,-100),Color("bd4d37"),5)
            if e.actor.attack_time>0.37:
                draw_arc(p,65,e.actor.attack_direction.angle()-0.7,e.actor.attack_direction.angle()+0.7,14,Color(1,0.4,0.2,0.8),3)
    for p in particles:
        draw_circle(p.pos,p.life*3,Color(p.color,clampf(p.life,0,1)))

func _process(delta: float) -> void:
    if not is_instance_valid(modal): return
    if modal.visible: return
    elapsed+=delta
    day=fposmod(day+delta/1500,1)
    tint.color=Color.WHITE.lerp(Color(0.60,0.67,0.82),maxf(0,sin(day*TAU))*0.3) if room<0 else Color.WHITE
    notice_time-=delta
    if notice_time<0: notice.text=""
    auto_clock+=delta
    if auto_clock>30:
        save_game()
        auto_clock=0
    fire_clock+=delta
    while fire_clock>=0.25:
        state.fire_tick(0.25)
        fire_clock-=0.25
    if drill>=0:
        drill-=delta
        notice.text="FIRE DRILL in %.0f seconds. G cancels. A checkpoint has been saved."%maxf(0,drill)
        if drill<=0:
            state.ignite("pine_1","disaster")
            drill=-1
            say("Fire on the eastern treeline. G: douse nearby fuel. F6: restore checkpoint.")
    sync_props()
    if room<0:
        worker_tick(delta)
        enemy_tick(delta)
        for o in state.objects.values():
            if o.burning and player.position.distance_to(state.point(o))<37: hurt(6*delta)
    for p in particles:
        p.life-=delta*2
        p.pos+=p.velocity*delta
    particles=particles.filter(func(p): return p.life>0)
    update_quest()
    update_ui()
    queue_redraw()
    if "--capture" in OS.get_cmdline_user_args() and elapsed>2:
        var path=OS.get_environment("CHIEFS_CAPTURE")
        if not path.is_empty(): get_viewport().get_texture().get_image().save_png(path)
        get_tree().quit()

func nearest(pos: Vector2,kinds: Array,radius: float) -> String:
    var found:=""
    for id in state.objects:
        var o=state.objects[id]
        if o.state!="intact" or not o.kind in kinds: continue
        var d: float=state.point(o).distance_to(pos)
        if d<radius:
            radius=d
            found=id
    return found

func player_hit(direction: Vector2) -> void:
    if room>=0: return
    var target:=""
    var distance:=83.0
    for e in enemies:
        var offset: Vector2=e.actor.position-player.position
        if e.hp>0 and offset.length()<distance and offset.normalized().dot(direction)>0.35:
            e.hp=maxf(0,e.hp-(40 if forged else 25))
            e.actor.hit_flash=0.18
            e.actor.attack_time=0
            e.cooldown=0.7
            burst(e.actor.position,Color("9f3d29"))
            sound("hit")
            if e.hp==0:
                kills+=1
                ore+=2
                meat+=1
                e.actor.dead=true
                e.actor.hide()
                say("Raider defeated. Recovered 2 iron ore and one ration.")
            return
    for id in state.objects:
        var o=state.objects[id]
        if o.state!="intact" or o.kind not in ["tree","rock","wall"]: continue
        var offset: Vector2=state.point(o)-player.position
        if offset.length()<distance and offset.normalized().dot(direction)>0.2:
            distance=offset.length()
            target=id
    if target.is_empty(): return
    var obj=state.objects[target]
    state.damage(target,35 if forged else 25)
    burst(state.point(obj),Color("aa8150"))
    sound("metal" if obj.kind=="rock" else "wood")
    if props.has(target):
        var s=props[target].sprite
        var tween=create_tween()
        tween.tween_property(s,"rotation",0.06,0.05)
        tween.tween_property(s,"rotation",-0.04,0.07)
        tween.tween_property(s,"rotation",0.0,0.08)
    if obj.state!="intact":
        if obj.kind=="tree":
            trees_cut+=1
            say("Tree felled. E collects the timber bundle (3 timber).")
        if obj.kind=="rock":
            ore+=3
            say("Iron-bearing stone broken. +3 ore.")

func enemy_tick(delta: float) -> void:
    for e in enemies:
        if e.hp<=0: continue
        e.cooldown=maxf(0,e.cooldown-delta)
        var a=e.actor
        var offset: Vector2=player.position-a.position
        a.drive=Vector2.ZERO
        if a.attack_time>0: continue
        if offset.length()<230 and player.position.y>590:
            if offset.length()>62: a.drive=offset.normalized()*0.62
            elif e.cooldown<=0:
                a.attack(offset)
                e.cooldown=1.5
        elif a.position.distance_to(e.home)>12: a.drive=(e.home-a.position).normalized()*0.5

func enemy_hit(direction: Vector2,index: int) -> void:
    var e=enemies[index]
    if room>=0 or e.hp<=0: return
    var offset: Vector2=player.position-e.actor.position
    if offset.length()<86 and offset.normalized().dot(direction)>0.25 and player.invulnerable<=0:
        hurt(12 if player.equipment=="iron" else 22)
        player.invulnerable=0.45

func hurt(amount: float) -> void:
    hp=maxf(0,hp-amount)
    player.hit_flash=0.18
    if hp<=0:
        hp=100
        player.position=Vector2(680,490)
        for e in enemies:
            e.actor.position=e.home
            e.actor.attack_time=0
        say("You staggered back to the hearth. Gear and resources kept; the raiders still hold the ridge.")

func worker_tick(_delta: float) -> void:
    worker.drive=Vector2.ZERO
    if not worker_active: return
    if worker_cargo>0:
        var dest=Vector2(710,780)
        if worker.position.distance_to(dest)>30: worker.drive=(dest-worker.position).normalized()*0.7
        else:
            stored+=worker_cargo
            worker_cargo=0
            worker_target=""
        return
    if worker_target.is_empty() or not state.objects.has(worker_target) or state.objects[worker_target].state!="intact":
        worker_target=nearest(worker.position,["tree"],1800)
    if worker_target.is_empty(): return
    var offset: Vector2=state.point(state.objects[worker_target])-worker.position
    if offset.length()>63: worker.drive=offset.normalized()*0.65
    elif worker.attack_time<=0: worker.attack(offset)

func worker_hit(_direction: Vector2) -> void:
    if worker_target.is_empty() or not state.objects.has(worker_target): return
    if worker.position.distance_to(state.point(state.objects[worker_target]))>85: return
    state.damage(worker_target,15)
    if state.objects[worker_target].state=="felled":
        var log_id=worker_target+"_timber"
        if state.objects.has(log_id) and state.objects[log_id].state=="intact":
            state.objects[log_id].state="collected"
            worker_cargo=3

func update_quest() -> void:
    if quest==0 and collected>=6: quest=1; say("Enough timber. Raise the storehouse at the stakes south of the hearth.")
    if quest==1 and built==3: quest=2; say("A roof over your labor. Enter the forge to make your iron harness.")
    if quest==2 and forged: quest=3; say("Iron earned. Three rival Orcs hold the southeastern ridge. Dodge their windups.")
    if quest==3 and kills>=3: quest=4; say("The ridge is yours. Return to the hall, or keep building your camp.")

func interact() -> void:
    if room>=0:
        if player.position.distance_to(Vector2(768,665))<85: leave_room(); return
        if room<2 and player.position.distance_to(Vector2(800,485))>150:
            say("Approach "+("Yrsa" if room==0 else "Harn")+" at the far end of the room, then press E.")
            return
        if room==0: hall_menu()
        elif room==1: forge_menu()
        else: store_menu()
        return
    var log_id=nearest(player.position,["log"],90)
    if not log_id.is_empty() and state.collect(log_id):
        var amount:=1 if log_id.ends_with("_salvage") else 3
        state.timber+=amount-1
        collected+=amount
        say("+%s timber"%amount)
        sound("wood")
        return
    for i in 3:
        if player.position.distance_to(DORS(i))<78:
            if i==2 and built<3: build_shed(); return
            if buildings[i].integrity<=0: repair(i); return
            enter_room(i)
            return
    if player.position.distance_to(worker.position)<85:
        dialogue("Bren • Timber hand",2,"Give me a storehouse and I will cut while you range beyond the camp. My timber goes into the chest.",[["Assign / stand down",toggle_worker]])
        return
    say("Approach a doorway, Bren, or a timber bundle and press E.")

func DORS(index: int) -> Vector2: return DOORS[index]+Vector2(0,30)

func enter_room(index: int) -> void:
    room=index
    place_mode=false
    room_npc.visible=index<2
    room_npc.region_rect=Rect2(575,0,415,1000) if index==0 else Rect2(0,0,570,1000)
    room_npc.scale=Vector2.ONE*0.10
    notice.text=""
    return_pos=DORS(index)+Vector2(0,45)
    outdoors.hide()
    interior.show()
    actors.remove_child(player)
    add_child(player)
    player.position=Vector2(768,610)
    player.collision_mask=4
    for e in enemies: e.actor.set_physics_process(false)
    worker.set_physics_process(false)
    camera.reset_smoothing()
    queue_redraw()

func leave_room() -> void:
    room=-1
    remove_child(player)
    actors.add_child(player)
    player.position=return_pos
    player.collision_mask=1
    outdoors.show()
    interior.hide()
    for e in enemies: e.actor.set_physics_process(true)
    worker.set_physics_process(true)
    camera.reset_smoothing()
    queue_redraw()

func hall_menu() -> void:
    dialogue("Yrsa • Keeper of the hearth",3,"This camp is small, but it is ours. Cut the western pines, raise a storehouse, then ask Harn about iron. Rival axes wait beyond the southeastern stones.\n\nRest here whenever you need. No daily obligations.",[["Rest • restore health",rest],["Cook / eat ration • restore 40 HP",eat],["Leave the hall",leave_and_close]])
func forge_menu() -> void:
    dialogue("Harn • Smith of the Ashfang",1,"Stone on the eastern ridge carries iron. Bring me four ore and two timber; I will make you an iron harness and edge your axe.\n\nA good blow is committed. Watch an enemy's shoulders, then get clear.",[["Forge iron kit • 4 ore + 2 timber",forge],["Change leather / iron",equip_owned],["Leave the forge",leave_and_close]])
func store_menu() -> void:
    dialogue("The timber store",2,"Bren deposits his timber here. Stored timber: %s.\nCarried timber: %s."%[stored,state.timber],[["Take all timber",withdraw],["Store all timber",deposit],["Assign / stand down Bren",toggle_worker],["Leave storehouse",leave_and_close]])
func rest() -> void:
    hp=100; day=0.18; close_modal(); say("Rested at the hearth. Health restored.")
func eat() -> void:
    if meat<=0: say("No rations left. Raiders carry provisions.")
    else: meat-=1; hp=minf(100,hp+40); say("A meal of smoked meat. +40 health.")
    close_modal()
func forge() -> void:
    if forged: close_modal(); say("Your iron kit is already forged. C changes your equipped outfit."); return
    if ore<4 or state.timber<2: close_modal(); say("Need 4 iron ore and 2 carried timber."); return
    ore-=4; state.timber-=2; forged=true; player.equip("iron"); close_modal(); sound("metal"); say("Iron harness equipped. Stronger axe strikes; incoming damage reduced.")
func equip_owned() -> void:
    if forged: player.equip("leather" if player.equipment=="iron" else "iron")
    else: say("Forge your iron kit first.")
    close_modal()
func withdraw() -> void:
    state.timber+=stored; stored=0; close_modal(); say("Timber withdrawn.")
func deposit() -> void:
    stored+=state.timber; state.timber=0; close_modal(); say("Timber stored.")
func toggle_worker() -> void:
    close_modal()
    if built<3: say("Bren needs the completed storehouse before he can work."); return
    worker_active=not worker_active
    say("Bren is cutting and depositing timber." if worker_active else "Bren has stood down.")
func leave_and_close() -> void: close_modal(); leave_room()
func build_shed() -> void:
    if state.timber<2: say("Each storehouse stage needs 2 timber. Three stages total."); return
    state.timber-=2
    built+=1
    sound("wood")
    if built==3: add_modules(2); say("Storehouse complete. E at its door to enter. Speak to Bren to assign work.")
    else: say("Storehouse: %s / 3 stages. E adds the next stage (2 timber)."%built)
func repair(index: int) -> void:
    if state.timber<4: say("Rebuild this structure for 4 timber. Gather or withdraw timber first."); return
    state.timber-=4; add_modules(index); say("Building rebuilt.")

func can_build(pos: Vector2) -> bool:
    if not Rect2(50,100,1436,874).has_point(pos) or pos.distance_to(player.position)>160 or pos.distance_to(player.position)<48: return false
    for d in DOORS:
        if pos.distance_to(d)<180: return false
    return nearest(pos,["tree","rock","wall","hearth"],80).is_empty()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_ESCAPE:
            if modal.visible: close_modal()
            elif place_mode: place_mode=false
            else: pause_menu()
            return
        if modal.visible: return
        match event.physical_keycode:
            KEY_E: interact()
            KEY_SPACE: player.dodge(Input.get_vector("move_left","move_right","move_up","move_down"))
            KEY_C: equip_owned()
            KEY_F5: say("Saved." if save_game() else "Save failed.")
            KEY_F6:
                if load_game("user://hearth_fire_checkpoint.json"): say("Fire checkpoint restored.")
                else: say("No fire checkpoint yet.")
            KEY_J: help_menu()
            KEY_B: place_mode=not place_mode
            KEY_G:
                drill=-1
                for id in state.objects:
                    if state.point(state.objects[id]).distance_to(player.position)<135: state.extinguish(id)
                say("Nearby fuel doused. Wet for 45 seconds; pending drill cancelled.")
            KEY_R:
                if room<0:
                    var p=get_global_mouse_position()
                    if p.distance_to(player.position)<150:
                        state.set_terrain(Vector2i((p/32).floor()),"earth")
                        say("Earth cleared. Bare ground blocks fire spread.")
            KEY_1: eat()
    if modal.visible or room>=0: return
    if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
        if place_mode:
            var p=(get_global_mouse_position()/32).floor()*32+Vector2(16,16)
            if can_build(p) and state.timber>=2: state.timber-=2; state.add_object("wall",p); sound("wood")
            else: say("Needs 2 timber and a clear spot nearby, away from entrances.")
        else: player.attack(get_global_mouse_position()-player.position)

func burst(pos: Vector2,color: Color) -> void:
    for i in 9: particles.append({"pos":pos-Vector2(0,20),"velocity":Vector2(randf_range(-65,65),randf_range(-80,15)),"life":1.0,"color":color})
func sound(name: String) -> void:
    if not sounds.has(name): return
    var a=AudioStreamPlayer.new()
    a.stream=sounds[name]
    a.volume_db=-13
    a.pitch_scale=randf_range(0.94,1.06)
    add_child(a)
    a.finished.connect(a.queue_free)
    a.play()
func say(message: String) -> void:
    if notice: notice.text=message
    notice_time=7

func save_game(path: String=SAVE) -> bool:
    var data=state.snapshot()
    data.camp_version=1
    data.progress={"hp":hp,"ore":ore,"meat":meat,"stored":stored,"built":built,"forged":forged,"worker_active":worker_active,"worker_cargo":worker_cargo,"kills":kills,"trees_cut":trees_cut,"collected":collected,"quest":quest,"day":day,"equipment":player.equipment}
    var pos: Vector2=player.position if room<0 else return_pos
    data.player=[pos.x,pos.y]
    data.worker=[worker.position.x,worker.position.y]
    data.enemies=[]
    for e in enemies: data.enemies.append(e.hp)
    var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
    if file==null: return false
    file.store_string(JSON.stringify(data)); file.close()
    return DirAccess.rename_absolute(path+".tmp",path)==OK
func load_game(path: String=SAVE) -> bool:
    if not FileAccess.file_exists(path): return false
    var data=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary or data.get("camp_version")!=1 or not data.get("progress") is Dictionary: return false
    if not data.get("player") is Array or data.player.size()!=2 or not data.get("enemies") is Array or data.enemies.size()!=3: return false
    var check=State.new()
    if not check.restore(data): return false
    if room>=0: leave_room()
    state.restore(data)
    var p=data.progress
    hp=clampf(float(p.get("hp",100)),1,100); ore=maxi(0,int(p.get("ore",0))); meat=maxi(0,int(p.get("meat",2)))
    stored=maxi(0,int(p.get("stored",0))); built=clampi(int(p.get("built",0)),0,3); forged=bool(p.get("forged",false))
    worker_active=bool(p.get("worker_active",false)); worker_cargo=clampi(int(p.get("worker_cargo",0)),0,3)
    kills=clampi(int(p.get("kills",0)),0,3); trees_cut=int(p.get("trees_cut",0)); collected=int(p.get("collected",0)); quest=clampi(int(p.get("quest",0)),0,4)
    day=float(p.get("day",0.18))
    player.equip("iron" if forged and p.get("equipment")=="iron" else "leather")
    player.position=Vector2(clampf(float(data.player[0]),40,1490),clampf(float(data.player[1]),60,990))
    if data.get("worker") is Array and data.worker.size()==2: worker.position=Vector2(data.worker[0],data.worker[1])
    for i in 3:
        enemies[i].hp=clampf(float(data.enemies[i]),0,100)
        enemies[i].actor.dead=enemies[i].hp<=0
        enemies[i].actor.visible=enemies[i].hp>0
        enemies[i].actor.position=enemies[i].home
        enemies[i].actor.attack_time=0
    for id in props.keys():
        props[id].queue_free()
    props.clear()
    worker_target=""
    drill=-1
    sync_props()
    return true
func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(player): save_game()

func panel_style(bg: Color,border: Color) -> StyleBoxFlat:
    var style=StyleBoxFlat.new()
    style.bg_color=bg; style.border_color=border; style.set_border_width_all(2)
    style.content_margin_left=16; style.content_margin_right=16; style.content_margin_top=12; style.content_margin_bottom=12
    return style
func label(text: String,size: int=18) -> Label:
    var l=Label.new()
    l.text=text; l.add_theme_font_size_override("font_size",size)
    l.add_theme_color_override("font_color",Color("d7c9a8"))
    l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    return l
func portrait(index: int,size: Vector2) -> TextureRect:
    var t=TextureRect.new()
    var a=AtlasTexture.new()
    a.atlas=load("res://assets/camp/portraits.png")
    var cell=Vector2(a.atlas.get_size())/2
    a.region=Rect2(Vector2(index%2,index/2)*cell,cell)
    t.texture=a; t.custom_minimum_size=size
    t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    return t
func button(text: String,call: Callable,parent: Node) -> Button:
    var b=Button.new()
    b.text=text; b.custom_minimum_size.y=37
    b.pressed.connect(call)
    parent.add_child(b)
    return b
func create_ui() -> void:
    var layer=CanvasLayer.new(); add_child(layer)
    ui_root=Control.new(); ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_root.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(ui_root)
    var theme=Theme.new(); theme.default_font_size=16
    theme.set_stylebox("panel","PanelContainer",panel_style(Color("181b19"),Color("796344")))
    theme.set_stylebox("normal","Button",panel_style(Color("302d25"),Color("65573e")))
    theme.set_stylebox("hover","Button",panel_style(Color("4a4230"),Color("b69961")))
    theme.set_stylebox("pressed","Button",panel_style(Color("614b32"),Color("d0ad73")))
    ui_root.theme=theme
    var side=PanelContainer.new(); side.position=Vector2(1005,0); side.size=Vector2(275,800); ui_root.add_child(side)
    var box=VBoxContainer.new(); box.add_theme_constant_override("separation",8); side.add_child(box)
    box.add_child(label("CHIEFS OF WAR",24)); box.add_child(label("T H E   F I R S T   H E A R T H",12))
    box.add_child(portrait(0,Vector2(230,130)))
    box.add_child(label("ASHFANG • AXEBEARER",16))
    hp_bar=ProgressBar.new(); hp_bar.custom_minimum_size.y=20; hp_bar.show_percentage=false
    hp_bar.add_theme_stylebox_override("fill",panel_style(Color("8e4538"),Color("9a6248")))
    hp_bar.add_theme_stylebox_override("background",panel_style(Color("302824"),Color("65573e")))
    box.add_child(hp_bar)
    info=label("",16); box.add_child(info)
    box.add_child(HSeparator.new())
    journal=label("",17); journal.custom_minimum_size.y=160; box.add_child(journal)
    button("Journal & controls  [J]",help_menu,box)
    button("Save  [F5]",func(): say("Saved." if save_game() else "Save failed."),box)
    button("Camp / pause  [Esc]",pause_menu,box)
    box.add_child(label("0.2.0 • PLAYABLE ART TRIAL",11))
    var top=PanelContainer.new(); top.position=Vector2(20,18); top.size=Vector2(400,55); ui_root.add_child(top)
    location_label=label("ASHFANG CAMP",20); top.add_child(location_label)
    var bottom=PanelContainer.new(); bottom.position=Vector2(20,704); bottom.size=Vector2(965,78); ui_root.add_child(bottom)
    var v=VBoxContainer.new(); bottom.add_child(v)
    context=label("",17); v.add_child(context)
    v.add_child(label("WASD  Move     LMB  Axe     Space  Dodge     E  Use     B  Build     G  Douse",14))
    notice=label("",19); notice.position=Vector2(24,100); notice.size=Vector2(720,85)
    notice.add_theme_color_override("font_shadow_color",Color.BLACK)
    notice.add_theme_constant_override("shadow_offset_x",2); notice.add_theme_constant_override("shadow_offset_y",2)
    ui_root.add_child(notice)
    modal=PanelContainer.new(); modal.position=Vector2(140,120); modal.size=Vector2(720,520); ui_root.add_child(modal)
    modal_box=VBoxContainer.new(); modal_box.add_theme_constant_override("separation",8); modal.add_child(modal_box); modal.hide()
func update_ui() -> void:
    hp_bar.value=hp
    info.text="Health  %s / 100\nTimber  %s     Ore  %s\nRations  %s     Stored  %s\nOutfit  %s"%[int(hp),state.timber,ore,meat,stored,player.equipment.capitalize()]
    var tasks=["HANDS OF THE CLAN\n\nFell the western pines.\nCollect 6 timber with E.\n\nTimber gathered: %s / 6"%mini(6,collected),"A ROOF FOR OUR LABOR\n\nFind the stakes south of the hearth. E builds each stage for 2 timber.\n\nStages: %s / 3"%built,"BLOOD & IRON\n\nBreak eastern stone with your axe. Enter the forge.\n\nIron kit: 4 ore + 2 timber.","HOLD THE RIDGE\n\nDefeat the three raiders southeast of camp. Dodge the red windup.\n\nRaiders: %s / 3"%kills,"THE FIRST HEARTH\n\nThe camp holds. Keep gathering, build palisades, and put Bren to work.\n\nYour next chapter is unwritten."]
    journal.text=tasks[quest]
    location_label.text=NAMES[room].to_upper() if room>=0 else "ASHFANG CAMP"
    context.text="E: use room facilities • E near the south threshold: leave" if room>=0 else "Aim at a nearby tree, stone, or raider and strike. E collects timber."
    if place_mode: context.text="PALISADE • 2 timber • click nearby clear ground • B / Esc cancels"
    if room<0:
        for i in 3:
            if player.position.distance_to(DORS(i))<78: context.text="E: "+("Build storehouse • 2 timber per stage" if i==2 and built<3 else "Enter "+NAMES[i])
        if player.position.distance_to(worker.position)<85: context.text="E: speak to Bren, the timber hand"
func clear_modal() -> void:
    for c in modal_box.get_children(): modal_box.remove_child(c); c.queue_free()
func pause_actors(paused: bool) -> void:
    player.set_physics_process(not paused)
    worker.set_physics_process(not paused and room<0)
    for e in enemies: e.actor.set_physics_process(not paused and room<0)
func dialogue(title: String,index: int,body: String,options: Array) -> void:
    clear_modal(); modal.show(); pause_actors(true)
    modal_box.add_child(label(title,26))
    var h=HBoxContainer.new(); h.add_theme_constant_override("separation",20); modal_box.add_child(h)
    h.add_child(portrait(index,Vector2(210,190)))
    var words=label(body,19); words.custom_minimum_size.x=440; words.size_flags_horizontal=Control.SIZE_EXPAND_FILL; h.add_child(words)
    for option in options: button(option[0],option[1],modal_box)
    button("Close  [Esc]",close_modal,modal_box)
func close_modal() -> void:
    modal.hide(); pause_actors(false)
func help_menu() -> void:
    dialogue("Your first hearth",0,"WASD moves. Aim and left-click for one committed axe strike. Space dodges; red arcs warn of enemy attacks.\nE collects timber, enters buildings, or uses their facilities. C changes owned armor. 1 eats a ration.\nB places palisades (2 timber); R clears nearby earth into a firebreak. G douses fuel. F5 saves. F6 restores the fire-drill checkpoint.\nNo random fires. The fire drill is optional, in the pause menu.",[])
func pause_menu() -> void:
    dialogue("Camp at your own pace",0,"Progress saves every 30 seconds and on exit. The optional fire drill gives eight seconds of warning and saves a recovery checkpoint. Ordinary hearths never spread fire.",[["Resume",close_modal],["Start optional fire drill",start_drill],["Toggle spread: "+("ON" if state.spread_enabled else "OFF"),toggle_spread],["Save and quit",quit_game]])
func toggle_spread() -> void:
    state.spread_enabled=not state.spread_enabled; pause_menu()
func start_drill() -> void:
    if room>=0: close_modal(); say("Go outside before starting the fire drill."); return
    if not save_game("user://hearth_fire_checkpoint.json"): close_modal(); say("Checkpoint failed; drill cancelled."); return
    close_modal(); drill=8
func quit_game() -> void:
    if save_game(): get_tree().quit()
    else: say("Save failed; staying in game.")
