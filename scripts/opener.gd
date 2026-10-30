extends "res://scripts/camp.gd"
const Appearance=preload("res://scripts/appearance.gd")
const Hero=preload("res://scripts/opener_actor.gd")
const Wolf=preload("res://scripts/direwolf.gd")
const OPENER_SAVE="user://ancestral_hearth_v1.json"
const DUMMY=Vector2(990,780)
const HUNTER_HOME=Vector2(1950,575)
var character_name:="Garruk"
var complexion:=0
var cloth:=0
var appearance: Dictionary=Appearance.defaults()
var appearance_before: Dictionary={}
var creator_editing:=false
var creator_selectors: Dictionary={}
var preview_direction:=0
var preview_action:="rest"
var preview_outfit:="leather"
var preview_material: ShaderMaterial
var face_preview: TextureRect
var created:=false
var introduced:=false
var bren_met:=false
var training_hits:=0
var training_dodges:=0
var hunter_found:=false
var trophy:=false
var returned:=false
var rewarded:=false
var wolves=[]
var hunter
var dummy
var detail_sprites=[]
var held_attack:=false
var selected_id:=""
var selected_wolf
var floating=[]
var shake:=0.0
var work_time:=0.0
var work_duration:=0.85
var busy_kind:=""
var journal_open:=false
var creator: PanelContainer
var name_input: LineEdit
var preview: Sprite2D
var preview_time:=0.0
var avatar: TextureRect
var goal_label: Label
var goal_detail: Label
var inventory_label: Label
var objective_pos:=Vector2.ZERO
var objective_text:=""
var objective_sub:=""
var map: AStarGrid2D
var nav_revision:=-1
var ready_opener:=false
var initial_save: Dictionary={}
var save_status:=""
var audio_enabled:=not "--test" in OS.get_cmdline_user_args()
var accessibility_flash:=true
var step_clock:=0.0
var recovered_count:=0
var encounter_checkpoint:=false
var field_name:="ASHFANG • YOUR ANCESTRAL HEARTH"
var visitor: Label
var tip_shown:={}
var portrait_shader: ShaderMaterial
var scenery_root:=Node2D.new()
var veil: ColorRect
var drill_target:=""
var shutting_down:=false

func _ready() -> void:
    super._ready()
    get_tree().auto_accept_quit=false
    if "--startup-smoke" in OS.get_cmdline_user_args():
        get_tree().create_timer(3.0).timeout.connect(quit_game)
    for e in enemies:
        e.hp=0; e.actor.dead=true; e.actor.hide()
    var old_player=player
    var old_pos: Vector2=old_player.position
    old_player.remove_child(camera)
    actors.remove_child(old_player)
    old_player.queue_free()
    player=Hero.new(); player.position=old_pos
    actors.add_child(player); player.add_child(camera)
    player.impact.connect(player_hit)
    player.stepped.connect(func(): sound("step"))
    player.swung.connect(func(): sound("swing"))
    player.equip("iron" if forged else "leather")
    for p in props.values(): p.player=player
    camera.offset=Vector2(0,-30)
    camera.limit_left=0; camera.limit_top=0; camera.limit_right=3584; camera.limit_bottom=1408
    camera.position_smoothing_speed=12
    for c in outdoors.get_children():
        if c is StaticBody2D: outdoors.remove_child(c); c.queue_free()
    for r in [Rect2(-40,-40,3664,40),Rect2(-40,1408,3664,40),Rect2(-40,0,40,1408),Rect2(3584,0,40,1408)]: boundary(outdoors,r,1)
    var old_ground=outdoors.get_child(0)
    outdoors.remove_child(old_ground); old_ground.queue_free()
    var ground=load("res://scripts/opener_terrain.gd").new()
    ground.state=state; outdoors.add_child(ground); outdoors.move_child(ground,0)
    actors.add_child(scenery_root)
    setup_details()
    hunter=Actor.new(); hunter.controlled=false; hunter.position=HUNTER_HOME
    actors.add_child(hunter); hunter.equip("iron"); hunter.modulate=Color(0.85,0.90,0.8)
    hunter.set_physics_process(false)
    for i in 4:
        var w=Wolf.new()
        w.position=[Vector2(2230,660),Vector2(2520,950),Vector2(2700,480),Vector2(3000,730)][i]
        w.alpha=i==3; w.loot_id="wolf_%s"%i; w.target=player; w.game=self
        actors.add_child(w)
        w.strike.connect(wolf_strike); w.slain.connect(wolf_slain)
        wolves.append(w)
    for n in ["swing","success","growl","ambient"]:
        var path="res://assets/opener/"+n+".wav"
        if ResourceLoader.exists(path): sounds[n]=load(path)
    if sounds.has("ambient") and not "--test" in OS.get_cmdline_user_args():
        var ambient_stream: AudioStreamWAV=sounds.ambient.duplicate()
        ambient_stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
        ambient_stream.loop_begin=0
        ambient_stream.loop_end=int(ambient_stream.get_length()*ambient_stream.mix_rate)
        var ambience=AudioStreamPlayer.new(); ambience.stream=ambient_stream; ambience.volume_db=-26; ambience.name="Ambience"; add_child(ambience); ambience.play()
    ready_opener=true
    restore_extra(initial_save)
    apply_look()
    update_quest(); update_ui()
    if not created and not "--test" in OS.get_cmdline_user_args(): show_creator()
    else:
        say("Welcome home, "+character_name+". Your journal marks the next step.")
        if room<0: player.set_physics_process(true)

func seed_camp() -> void:
    var positions=[Vector2(220,440),Vector2(290,610),Vector2(185,760),Vector2(390,870),Vector2(165,980),Vector2(350,300),Vector2(160,280),Vector2(200,1180),Vector2(450,1120),Vector2(850,1170),Vector2(1200,1110),Vector2(1400,280),Vector2(1340,980),Vector2(1170,240)]
    for i in positions.size(): state.add_object("tree",positions[i],"pine_%s"%i)
    for i in 112:
        var p=Vector2(1610+(i%14)*136+posmod(i*37,45),190+int(i/14)*148+posmod(i*71,55))
        var trail_y=650.0 if p.x<2000 else 700.0 if p.x<2450 else 740.0
        if p.distance_to(Vector2(3000,730))<230 or absf(p.y-trail_y)<145 or p.distance_to(HUNTER_HOME)<125: continue
        state.add_object("tree",p,"wildpine_%s"%i)
    for i in 5: state.add_object("rock",Vector2(1070+i*75,455+(i%2)*45),"ore_%s"%i)
    for i in 5: state.add_object("rock",Vector2(1710+i*90,300+(i%2)*50),"crag_%s"%i)
    state.add_object("hearth",Vector2(655,540),"hearth")
    for i in 2: add_modules(i)
    var points=[Vector2(550,380),Vector2(680,540),Vector2(710,780),Vector2(930,380),Vector2(1040,650),Vector2(1550,650),Vector2(1950,650),Vector2(2400,750),Vector2(3020,730)]
    for a in [0,1,3,4,5,6,7]:
        var from: Vector2=points[a]; var to: Vector2=points[a+1]
        var steps:=maxi(1,int(from.distance_to(to)/18))
        for j in range(steps+1):
            var cell=Vector2i(from.lerp(to,float(j)/steps)/32)
            for off in [Vector2i.ZERO,Vector2i(1,0),Vector2i(0,1)]: state.set_terrain(cell+off,"earth")

func detail(index: int,pos: Vector2,factor: float) -> Sprite2D:
    var s=Sprite2D.new(); s.texture=load("res://assets/opener/details.png"); s.region_enabled=true
    var rects=JSON.parse_string(FileAccess.get_file_as_string("res://resources/details.json"))
    var r=rects[index]; s.region_rect=Rect2(r[0],r[1],r[2],r[3])
    s.scale=Vector2.ONE*factor; s.position=pos-Vector2(0,float(r[3])*factor*0.5)
    actors.add_child(s); detail_sprites.append(s); return s
func setup_details() -> void:
    dummy=detail(0,DUMMY,0.24)
    detail(1,Vector2(1450,640),0.23)
    detail(2,HUNTER_HOME+Vector2(-45,30),0.19)
    detail(3,Vector2(430,390),0.28)
    detail(3,Vector2(1050,400),0.28)
    detail(4,Vector2(730,570),0.19)


func _process(delta: float) -> void:
    if not ready_opener: return
    if creator and creator.visible:
        preview_time+=delta
        update_preview()
        return
    if modal.visible: return
    var warning: float=drill
    drill=-1
    super._process(delta)
    drill=warning
    if drill>=0:
        drill-=delta
        notice.text="FIRE DRILL in %.0f seconds • marked tree • G cancels • checkpoint saved"%maxf(0,drill)
        if drill<=0:
            var lit: bool=state.ignite(drill_target,"disaster")
            drill=-1
            say("Woodland fire. G douses nearby fuel; F6 restores the checkpoint." if lit else "Ignition stopped: the marked tree was felled or doused.")
    if work_time>0:
        work_time=maxf(0,work_time-delta)
        if work_time<=0: finish_work()
    if room<0:
        choose_target()
        if held_attack and not place_mode and work_time<=0:
            player.request_attack(aim_direction())
    shake=maxf(0,shake-delta*22)
    camera.offset=Vector2(0,-30)+Vector2(sin(elapsed*97),cos(elapsed*83))*shake if accessibility_flash else Vector2(0,-30)
    for f in floating:
        f.time-=delta; f.pos.y-=delta*23
        if is_instance_valid(f.node): f.node.position=f.pos; f.node.modulate.a=clampf(f.time,0,1)
    for f in floating.filter(func(x): return x.time<=0): f.node.queue_free()
    floating=floating.filter(func(x): return x.time>0)
    field_name="THE GREYTOOTH DEN" if player.position.x>2700 else "THE BORDERWOOD • EASTERN TRAIL" if player.position.x>1550 else "ASHFANG • YOUR ANCESTRAL HEARTH"
    if not encounter_checkpoint and player.position.x>1850:
        if save_game("user://opener_expedition_checkpoint.json"): encounter_checkpoint=true
    if player.position.x>1750 and not tip_shown.has("hunt"):
        tip_shown.hunt=true; say("Greytooths commit to their charge. Step aside after the amber warning, then strike during recovery.")
    if player.position.x<1350 and trophy and hunter_found and not returned:
        returned=true; hunter.position=Vector2(805,600); sound("success"); say("Home with Torren's trail cleared and the pack leader's pelt. Bring the news to Yrsa.")
    hunter.visible=room<0
    for w in wolves: w.active=room<0

func _draw() -> void:
    super._draw()
    if not ready_opener or room>=0: return
    if selected_wolf and selected_wolf.hp>0:
        draw_arc(selected_wolf.position,30,0,TAU,32,Color("d89056"),2)
    elif not selected_id.is_empty() and state.objects.has(selected_id):
        var o=state.objects[selected_id]; var p: Vector2=state.point(o)
        draw_arc(p,24,0,TAU,28,Color("c2b077"),2)
        if o.hp<state.MAX_HP[o.kind]:
            draw_line(p+Vector2(-25,15),p+Vector2(25,15),Color("211e15"),4)
            draw_line(p+Vector2(-25,15),p+Vector2(-25+50*o.hp/state.MAX_HP[o.kind],15),Color("b8a36f"),4)
    if drill>=0 and state.objects.has(drill_target):
        draw_arc(state.point(state.objects[drill_target]),35,0,TAU,32,Color("e3a157"),3)
    if training_hits<3 and bren_met:
        draw_arc(DUMMY,28,0,TAU,24,Color(0.7,0.6,0.4,0.6),1)
    if work_time>0:
        draw_line(player.position+Vector2(-30,18),player.position+Vector2(30,18),Color("25211b"),6)
        draw_line(player.position+Vector2(-30,18),player.position+Vector2(-30+60*(1-work_time/work_duration),18),Color("d3b879"),6)

func choose_target() -> void:
    selected_id=""; selected_wolf=null
    var mouse=get_global_mouse_position(); var score:=125.0
    for w in wolves:
        if w.hp<=0: continue
        var dist: float=player.position.distance_to(w.position)
        var pointer: float=mouse.distance_to(w.position-Vector2(0,30))
        if dist<125 and pointer<score:
            selected_wolf=w; score=pointer
    if selected_wolf: return
    for id in state.objects:
        var o=state.objects[id]
        if o.state!="intact" or not o.kind in ["tree","log","rock","wall"]: continue
        if id.begins_with("building_"): continue
        var p: Vector2=state.point(o)
        if p.distance_to(player.position)>115: continue
        var rect=Rect2(p-Vector2(55,190 if o.kind=="tree" else 65),Vector2(110,205 if o.kind=="tree" else 80))
        var pointer: float=mouse.distance_to(p-Vector2(0,40))
        if rect.has_point(mouse): pointer=0
        if pointer<score: selected_id=id; score=pointer
func aim_direction() -> Vector2:
    if selected_wolf: return (selected_wolf.position-player.position).normalized()
    if not selected_id.is_empty(): return (state.point(state.objects[selected_id])-player.position).normalized()
    if player.position.distance_to(DUMMY)<115 and get_global_mouse_position().distance_to(DUMMY-Vector2(0,45))<90: return (DUMMY-player.position).normalized()
    return (get_global_mouse_position()-player.position).normalized()
func has_line(from: Vector2,to: Vector2,allowed) -> bool:
    var q=PhysicsRayQueryParameters2D.create(from,to,1)
    var result=get_world_2d().direct_space_state.intersect_ray(q)
    return result.is_empty() or (allowed!=null and result.get("collider")==allowed)

func player_hit(direction: Vector2) -> void:
    if room>=0 or work_time>0: return
    var candidates=[]
    for w in wolves:
        var off: Vector2=w.position-player.position
        if w.hp>0 and off.length()<112 and off.normalized().dot(direction)>0.38 and has_line(player.position,w.position,null): candidates.append(w)
    candidates.sort_custom(func(a,b): return a.position.distance_to(player.position)<b.position.distance_to(player.position))
    if not candidates.is_empty():
        var w=candidates[0]
        w.receive_hit(45 if forged else 32,direction)
        impact_feedback(w.position,"hit",Color("b1543c"),"45" if forged else "32")
        return
    var offset=DUMMY-player.position
    if offset.length()<105 and offset.normalized().dot(direction)>0.35 and has_line(player.position,DUMMY,null):
        training_hits=mini(3,training_hits+1)
        impact_feedback(DUMMY,"wood",Color("b9a16c"),"Good contact")
        var t=create_tween(); t.tween_property(dummy,"rotation",0.06,0.06); t.tween_property(dummy,"rotation",0.0,0.12)
        return
    var id:=""; var nearest_distance:=106.0
    for key in state.objects:
        var o=state.objects[key]
        if o.state!="intact" or not o.kind in ["tree","wall"] or key.begins_with("building_"): continue
        var off: Vector2=state.point(o)-player.position
        if off.length()<nearest_distance and off.normalized().dot(direction)>0.35 and has_line(player.position,state.point(o),props[key].body if props.has(key) else null):
            nearest_distance=off.length(); id=key
    if id.is_empty(): return
    var obj=state.objects[id]
    state.damage(id,35 if forged else 25)
    impact_feedback(state.point(obj),"wood",Color("b9a16c"),"")
    if props.has(id):
        var t=create_tween(); t.tween_property(props[id].sprite,"rotation",0.035,0.04); t.tween_property(props[id].sprite,"rotation",0.0,0.12)
    if obj.state=="felled": trees_cut+=1; toast("Tree felled • +3 timber to collect",state.point(obj))
func impact_feedback(pos: Vector2,kind: String,color: Color,word: String) -> void:
    burst(pos,color); sound(kind)
    player.hit_stop=0.035; shake=2.3
    if not word.is_empty(): toast(word,pos-Vector2(0,55))
func toast(text: String,pos: Vector2) -> void:
    var l=label(text,17); l.autowrap_mode=TextServer.AUTOWRAP_OFF; l.position=pos-Vector2(40,20); l.z_index=10
    l.add_theme_color_override("font_shadow_color",Color.BLACK); l.add_theme_constant_override("shadow_offset_y",2)
    add_child(l); floating.append({"node":l,"pos":l.position,"time":1.2})

func enemy_tick(_delta: float) -> void: pass
func wolf_strike(w) -> void:
    if room>=0 or modal.visible: return
    var off: Vector2=player.position-w.position
    if off.length()<80 and off.normalized().dot(w.locked_direction)>-0.15 and player.invulnerable<=0 and has_line(w.position,player.position,null):
        hurt((28 if w.alpha else 18)*(0.6 if player.equipment=="iron" else 1.0))
        player.invulnerable=0.55; player.recoil=w.locked_direction*170
        sound("hit"); shake=4
func wolf_slain(w) -> void:
    kills+=1; sound("hit"); toast("Pack leader down" if w.alpha else "Greytooth down",w.position)
    if w.alpha: say("The pack leader is dead. Approach it and press E to take the pelt.")
func hurt(amount: float) -> void:
    hp=maxf(0,hp-amount); player.hit_flash=0.16
    if hp>0: return
    recovered_count+=1
    hp=100; player.cancel_action(); player.position=Vector2(680,490)
    camera.reset_smoothing(); held_attack=false
    for w in wolves:
        if w.hp>0: w.position=w.home; w.stage="idle"; w.cooldown=1
    dialogue("Yrsa • Back on your feet",3,"You made it back. I bound what I could. Keep your eyes on the beast when it lowers its shoulders; its charge cannot follow a sidestep.\n\nYour belongings are safe. The trail remains open.",[["Try the trail again",close_modal]])

func update_quest() -> void:
    if not introduced:
        objective_text="A morning among your own"; objective_sub="Enter the Ash Hall and speak with Yrsa."; objective_pos=Vector2(550,385)
    elif not bren_met:
        objective_text="Hands before glory"; objective_sub="Speak to Bren west of the central hearth."; objective_pos=worker.position if is_instance_valid(worker) else Vector2(350,520)
    elif built<3:
        objective_text="A roof for our labor"
        objective_sub="Fell two pines; collect timber with E. Raise the storehouse: %s / 3 stages."%built
        objective_pos=Vector2(710,770) if state.timber>=2 else Vector2(220,440)
    elif training_hits<3 or training_dodges<1:
        objective_text="An axe you can trust"; objective_sub="Practice in the southern yard: %s / 3 hits; %s / 1 dodge (Space)."%[training_hits,training_dodges]; objective_pos=DUMMY
    elif not hunter_found:
        objective_text="The overdue hunter"; objective_sub="Follow the eastern trail. Find Torren beyond the waypost."; objective_pos=HUNTER_HOME
    elif not trophy:
        objective_text="Break the Greytooth pack"; objective_sub="Defeat the pack leader at the eastern den. E takes its pelt."; objective_pos=Vector2(3000,730)
    elif not rewarded:
        objective_text="A hunter returns"; objective_sub="Bring the pelt and the news to Yrsa in the Ash Hall."; objective_pos=Vector2(550,385)
    elif not forged:
        objective_text="Earned in the Borderwood"; objective_sub="Take your reward to Harn. Forge your iron kit at the smithy."; objective_pos=Vector2(930,385)
    else:
        objective_text="Your place at the hearth"; objective_sub="Opening complete. Put Bren to work, build defenses, or explore at your pace."; objective_pos=Vector2.ZERO

func interact() -> void:
    if work_time>0: return
    if room>=0: super.interact(); return
    for w in wolves:
        if w.hp<=0 and not w.harvested and player.position.distance_to(w.position)<90:
            w.harvested=true; meat+=2
            if w.alpha: trophy=true; toast("Greytooth pelt • 2 raw meat",w.position); sound("success")
            else: toast("2 raw meat",w.position)
            return
    if player.position.distance_to(hunter.position)<100 and returned:
        dialogue("Torren • Home again",0,"That pelt belongs on the hall wall. I'll let Yrsa decide whether your courage outweighs your stubbornness.\n\nThank you. Next time we take the trail together.",[])
        return
    if player.position.distance_to(hunter.position)<100 and not returned:
        hunter_found=true
        dialogue("Torren • Hunter of your clan",0,"A pack caught me at the stream. Their leader tore through my leg guard. I'll make for home; you finish what I started.\n\nIt waits east, beyond the split stones. Let it charge, step aside, then put that axe to work. Bring the pelt to Yrsa. She'll know I didn't spend the morning sleeping.",[["I'll clear the den",close_modal]])
        return
    if player.position.distance_to(worker.position)<95:
        bren_met=true
        dialogue("Bren • An old friend",2,"There you are. Two good pines will roof that timber store. Swing through the trunk, let it fall, then take the bundle. Six timber, three stages.\n\nOnce it's standing, I can keep it stocked while you're out. Harn left a practice dummy southeast of the fire. Use it before you try your luck on the trail.",[["I'll raise the store",close_modal],["Assign / stand down",toggle_worker]])
        return
    if player.position.distance_to(DORS(2))<90 and built<3:
        if state.timber<2: say("Each stage needs 2 timber. Cut a pine and collect its bundle with E."); return
        start_work("build"); return
    var ore_id=nearest(player.position,["rock"],80)
    if not ore_id.is_empty():
        selected_id=ore_id; start_work("ore:"+ore_id); return
    super.interact()
func start_work(kind: String) -> void:
    busy_kind=kind; work_time=work_duration
    held_attack=false; player.cancel_action(); player.action_locked=true
    sound("metal" if kind.begins_with("ore:") else "wood")
func finish_work() -> void:
    player.action_locked=false
    if busy_kind=="build":
        build_shed()
        if built==3: sound("success"); say("The store is ready. Bren can work here. Try Harn's practice dummy before taking the eastern trail.")
    elif busy_kind.begins_with("ore:"):
        var id=busy_kind.substr(4)
        if state.objects.has(id) and state.objects[id].state=="intact":
            var pos: Vector2=state.point(state.objects[id])
            state.damage(id,1000); ore+=3
            impact_feedback(pos,"metal",Color("c2b8a0"),"3 surface ore")
    busy_kind=""
func hall_menu() -> void:
    if not introduced:
        introduced=true
        dialogue("Yrsa • Keeper of your ancestral hearth",3,character_name+", before you disappear into the trees: Bren needs a hand, and Torren is late. Again.\n\nHelp finish the timber store, then follow the eastern hunting trail. If he has found trouble, bring him out of it. This is your home. We look after our own.",[["I'll speak with Bren",close_modal],["Rest first",rest]])
    elif trophy and returned and not rewarded:
        dialogue("Yrsa • A place earned",3,"Torren told me what happened. I see you brought proof. We'll smoke the meat and hang that pelt where every young fool can see what preparation buys him.\n\nTake these iron billets to Harn. You've earned more than a borrowed edge. And Bren has work waiting whenever you want it.",[["Hand over the pelt • claim iron billets",claim_reward]])
    else:
        dialogue("Yrsa • Keeper of the hearth",3,"There's food by the fire and a bed here when you need one. Torren knows these woods, but even he can underestimate their teeth.\n\n"+("The pelt hangs with the clan's trophies. You did well." if rewarded else "Bren is by the timber yard. The eastern waypost points toward Torren's trail."),[["Rest • restore health",rest],["Eat a ration • restore 40",eat],["Leave hall",leave_and_close]])
func claim_reward() -> void:
    if not trophy or not returned or rewarded: close_modal(); return
    rewarded=true; ore+=4; state.timber+=2; meat+=2
    close_modal(); sound("success"); say("Clan reward: 4 iron billets, 2 timber, and provisions. Harn can forge your iron kit.")
    save_game()
func forge_menu() -> void:
    dialogue("Harn • Smith of the Ashfang",1,"An axe is a promise. Make sure your hands can keep it. The practice dummy stands southeast of the hearth: three clean blows, then a sidestep.\n\n"+("Yrsa sent the billets? Good. Let's make something that will keep you alive." if rewarded else "Bring four ore and two timber for an iron kit. Yrsa will see you supplied if you clear Torren's trail."),[["Forge iron kit • 4 ore + 2 timber",forge],["Change owned outfit",equip_owned],["Leave forge",leave_and_close]])
func forge() -> void:
    var already=forged
    super.forge()
    if forged and not already:
        apply_look(); sound("success")
        dialogue("Harn • Carry it well",1,"That fits. Keep the joints oiled and the edge dry.\n\nYou've built something the clan needs, brought a hunter home, and earned your first iron. There's room here for a craftsman, a hunter, or a man with bigger ambitions. What you do next is yours.",[["Return to the village",leave_and_close]])
        save_game()
func equip_owned() -> void:
    super.equip_owned()
    if ready_opener: apply_look()
func rest() -> void:
    super.rest()
    player.cancel_action(); held_attack=false

func route_direction(a: Node2D,dest: Vector2) -> Vector2:
    if map==null or nav_revision!=state.revision: rebuild_nav()
    var goal=Vector2i(dest/32); goal.x=clampi(goal.x,1,110); goal.y=clampi(goal.y,1,42)
    if map.is_point_solid(goal):
        var options=[Vector2i(0,2),Vector2i(2,0),Vector2i(-2,0),Vector2i(0,-2)]
        for off in options:
            if map.is_in_boundsv(goal+off) and not map.is_point_solid(goal+off): goal+=off; break
    var start=Vector2i(a.position/32)
    if not map.is_in_boundsv(start): return Vector2.ZERO
    var start_solid: bool=map.is_point_solid(start)
    if start_solid: map.set_point_solid(start,false)
    var path: Array[Vector2i]=map.get_id_path(start,goal,true)
    if start_solid: map.set_point_solid(start,true)
    if path.size()<2: return (dest-a.position).normalized() if a.position.distance_to(dest)>12 else Vector2.ZERO
    return (Vector2(path[1])*32+Vector2(16,16)-a.position).normalized()
func rebuild_nav() -> void:
    map=AStarGrid2D.new(); map.region=Rect2i(0,0,112,44); map.cell_size=Vector2(32,32); map.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES; map.update()
    for o in state.objects.values():
        if o.state!="intact" or not o.kind in ["tree","rock","wall","hearth"]: continue
        var c=Vector2i(state.point(o)/32)
        var rx:=1 if o.kind in ["rock","wall"] else 0
        for x in range(-rx,rx+1):
            for y in range(-1,1):
                if map.is_in_boundsv(c+Vector2i(x,y)): map.set_point_solid(c+Vector2i(x,y),true)
    for i in buildings.size():
        for j in 3:
            if buildings[i].parts[j]<=0: continue
            var center: Vector2=DOORS[i]+Vector2((j-1)*78,-65)
            var area=Rect2(center-Vector2(51,73),Vector2(102,146))
            for x in range(int(area.position.x/32),int(area.end.x/32)+1):
                for y in range(int(area.position.y/32),int(area.end.y/32)+1): map.set_point_solid(Vector2i(x,y),true)
    nav_revision=state.revision
func worker_tick(_delta: float) -> void:
    worker.drive=Vector2.ZERO
    if not worker_active: return
    if worker_cargo>0:
        var dest=Vector2(710,790)
        if worker.position.distance_to(dest)>35: worker.drive=route_direction(worker,dest)*0.85
        else: stored+=worker_cargo; worker_cargo=0; worker_target=""
        return
    if worker_target.is_empty() or not state.objects.has(worker_target) or state.objects[worker_target].state!="intact":
        worker_target=""
        var distance:=2000.0
        for id in state.objects:
            var o=state.objects[id]
            if o.kind=="tree" and o.state=="intact" and o.x<1450:
                var d: float=worker.position.distance_to(state.point(o))
                if d<distance: distance=d; worker_target=id
    if worker_target.is_empty(): return
    var p: Vector2=state.point(state.objects[worker_target])
    if worker.position.distance_to(p)>78: worker.drive=route_direction(worker,p+Vector2(0,60))*0.85
    elif worker.attack_time<=0: worker.attack(p-worker.position)

func create_ui() -> void:
    var layer=CanvasLayer.new(); add_child(layer)
    ui_root=Control.new(); ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui_root.mouse_filter=Control.MOUSE_FILTER_IGNORE; layer.add_child(ui_root)
    var theme=Theme.new(); theme.default_font_size=17
    theme.set_stylebox("panel","PanelContainer",panel_style(Color(0.065,0.075,0.065,0.95),Color("80704d")))
    theme.set_stylebox("normal","Button",panel_style(Color("302e25"),Color("766244")))
    theme.set_stylebox("hover","Button",panel_style(Color("514632"),Color("c7a569")))
    theme.set_stylebox("pressed","Button",panel_style(Color("635036"),Color("e0bd79")))
    theme.set_color("font_color","Button",Color("e2d3b4")); ui_root.theme=theme
    var player_panel=PanelContainer.new(); player_panel.position=Vector2(18,18); player_panel.size=Vector2(300,105); ui_root.add_child(player_panel)
    var h=HBoxContainer.new(); h.add_theme_constant_override("separation",12); player_panel.add_child(h)
    avatar=portrait(0,Vector2(70,78)); h.add_child(avatar)
    var v=VBoxContainer.new(); v.custom_minimum_size.x=178; h.add_child(v)
    info=label(character_name,22); v.add_child(info)
    hp_bar=ProgressBar.new(); hp_bar.custom_minimum_size.y=14; hp_bar.show_percentage=false
    hp_bar.add_theme_stylebox_override("fill",panel_style(Color("9b4936"),Color("a86c4e")))
    hp_bar.add_theme_stylebox_override("background",panel_style(Color("29241e"),Color("65573e"))); v.add_child(hp_bar)
    inventory_label=label("",13); v.add_child(inventory_label)
    var objective=PanelContainer.new(); objective.position=Vector2(880,18); objective.size=Vector2(380,136); ui_root.add_child(objective)
    var q=VBoxContainer.new(); q.add_theme_constant_override("separation",7); objective.add_child(q)
    goal_label=label("",20); q.add_child(goal_label)
    goal_detail=label("",16); q.add_child(goal_detail)
    location_label=label("",15); location_label.position=Vector2(365,24); location_label.size=Vector2(470,40); location_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; ui_root.add_child(location_label)
    location_label.add_theme_color_override("font_shadow_color",Color.BLACK); location_label.add_theme_constant_override("shadow_offset_y",2)
    var controls=PanelContainer.new(); controls.position=Vector2(18,714); controls.size=Vector2(900,70); ui_root.add_child(controls)
    var c=VBoxContainer.new(); controls.add_child(c)
    context=label("",17); c.add_child(context)
    c.add_child(label("WASD  Move    Hold LMB  Axe    Space  Dodge    E  Use    1  Eat    I  Inventory    J  Journal",14))
    var b=VBoxContainer.new(); b.position=Vector2(950,685); b.size=Vector2(310,98); ui_root.add_child(b)
    button("Journal  [J]",help_menu,b); button("Pause / save  [Esc]",pause_menu,b)
    notice=label("",19); notice.position=Vector2(230,650); notice.size=Vector2(800,55); notice.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    notice.add_theme_color_override("font_shadow_color",Color.BLACK); notice.add_theme_constant_override("shadow_offset_y",2); ui_root.add_child(notice)
    visitor=label("",15); visitor.autowrap_mode=TextServer.AUTOWRAP_OFF; visitor.size=Vector2(90,24); visitor.mouse_filter=Control.MOUSE_FILTER_IGNORE; ui_root.add_child(visitor)
    veil=ColorRect.new(); veil.color=Color(0.015,0.025,0.02,0.65); veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); ui_root.add_child(veil); veil.hide()
    modal=PanelContainer.new(); modal.position=Vector2(230,140); modal.size=Vector2(820,510); ui_root.add_child(modal)
    modal_box=VBoxContainer.new(); modal_box.add_theme_constant_override("separation",12); modal.add_child(modal_box); modal.hide()

func update_ui() -> void:
    if not is_instance_valid(info): return
    info.text=character_name
    hp_bar.value=hp
    inventory_label.text="%s HP   %s timber   %s rations"%[int(hp),state.timber,meat]
    goal_label.text=objective_text; goal_detail.text=objective_sub
    location_label.text=NAMES[room].to_upper() if room>=0 else field_name
    context.text=context_text()
    if work_time>0: context.text="Working…  Esc cancels"
    if objective_pos!=Vector2.ZERO and room<0 and created and not modal.visible:
        var screen: Vector2=get_global_transform_with_canvas()*objective_pos
        var distance: float=player.position.distance_to(objective_pos)
        screen.x=clampf(screen.x,35,1210); screen.y=clampf(screen.y,175,620)
        visitor.position=screen; visitor.text="◆ %s m"%maxi(1,int(distance/32)); visitor.visible=distance>130
    else: visitor.hide()
func context_text() -> String:
    if room>=0:
        if player.position.distance_to(Vector2(768,665))<85: return "E  Leave "+NAMES[room]
        return "E  Speak to "+("Yrsa" if room==0 else "Harn") if room<2 else "E  Open the timber store"
    for w in wolves:
        if w.hp<=0 and not w.harvested and player.position.distance_to(w.position)<90: return "E  Take the Greytooth pelt and meat" if w.alpha else "E  Harvest meat"
    for i in 3:
        if player.position.distance_to(DORS(i))<80: return "E  Build storehouse stage • 2 timber" if i==2 and built<3 else "E  Enter "+NAMES[i]
    if is_instance_valid(hunter) and player.position.distance_to(hunter.position)<100: return "E  Speak to Torren"
    if is_instance_valid(worker) and player.position.distance_to(worker.position)<95: return "E  Speak to Bren"
    if not nearest(player.position,["log"],90).is_empty(): return "E  Collect timber bundle"
    if not nearest(player.position,["rock"],80).is_empty(): return "E  Gather loose surface ore"
    if player.position.distance_to(DUMMY)<130: return "LMB  Practice a committed strike    Space  Dodge"
    if selected_wolf: return "GREYTOOTH • dodge its charge, punish its recovery"
    if not selected_id.is_empty(): return "Hold LMB  Work this tree" if state.objects[selected_id].kind=="tree" else "E  Collect / use"
    if place_mode: return "PALISADE • 2 timber • click clear ground • B cancels"
    return "Follow the eastern path or work at your own pace."

func appearance_snapshot() -> Dictionary:
    return {"appearance":appearance.duplicate(),"complexion":complexion,"cloth":cloth,"name":character_name}
func edit_appearance() -> void:
    close_modal()
    show_creator()
func show_creator() -> void:
    if is_instance_valid(creator): return
    creator_editing=created
    appearance_before=appearance_snapshot()
    # Existing saves keep their original illustrated head until explicitly edited.
    if appearance.version==0: appearance=Appearance.defaults()
    pause_actors(true); held_attack=false; player.cancel_action(); veil.show()
    creator_selectors.clear()
    creator=PanelContainer.new(); creator.position=Vector2(100,40); creator.size=Vector2(1080,720); ui_root.add_child(creator)
    var margin=MarginContainer.new()
    for side in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,20)
    creator.add_child(margin)
    var box=VBoxContainer.new();box.add_theme_constant_override("separation",12);margin.add_child(box)
    box.add_child(label("YOUR ASHFANG",30))
    box.add_child(label("A face of your own. A place to earn.",17))
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",24);row.size_flags_vertical=Control.SIZE_EXPAND_FILL;box.add_child(row)
    var left=VBoxContainer.new();left.custom_minimum_size.x=350;row.add_child(left)
    var canvas=Control.new();canvas.custom_minimum_size=Vector2(350,240);left.add_child(canvas)
    preview=Sprite2D.new();preview.region_enabled=true;preview.position=Vector2(175,115);canvas.add_child(preview)
    preview_material=ShaderMaterial.new();preview_material.shader=load("res://scripts/orc_palette.gdshader");preview.material=preview_material
    var view_row=HBoxContainer.new();left.add_child(view_row)
    for view in [["Front",0],["Left",1],["Right",2],["Back",3]]:
        button(view[0],func():preview_direction=view[1];update_preview(),view_row).size_flags_horizontal=Control.SIZE_EXPAND_FILL
    var anim=OptionButton.new()
    for title in ["Stand","Walk","Swing axe"]:anim.add_item(title)
    anim.item_selected.connect(func(i):preview_action=["rest","stride","strike"][i];preview_time=0;update_preview());left.add_child(anim)
    var outfit=OptionButton.new();outfit.add_item("Preview: leather");outfit.add_item("Preview: iron")
    outfit.item_selected.connect(func(i):preview_outfit="leather" if i==0 else "iron";update_preview());left.add_child(outfit)
    left.add_child(label("Outfit preview only; iron is earned in play.",14))
    face_preview=portrait(0,Vector2(108,80));face_preview.size_flags_horizontal=Control.SIZE_SHRINK_CENTER;left.add_child(face_preview)
    var right=VBoxContainer.new();right.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(right)
    right.add_child(label("Name",16));name_input=LineEdit.new();name_input.text=character_name;name_input.max_length=24;name_input.custom_minimum_size.y=38;right.add_child(name_input)
    var scroll=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;right.add_child(scroll)
    var fields=VBoxContainer.new();fields.size_flags_horizontal=Control.SIZE_EXPAND_FILL;fields.add_theme_constant_override("separation",8);scroll.add_child(fields)
    creator_option(fields,"Face","face",Appearance.FACES,appearance.face)
    creator_option(fields,"Hair","hair",Appearance.HAIRS,appearance.hair)
    creator_option(fields,"Beard","beard",Appearance.BEARDS,appearance.beard)
    creator_option(fields,"Mustache","mustache",Appearance.MUSTACHES,appearance.mustache)
    creator_option(fields,"Hair color","hair_color",Appearance.HAIR_NAMES,appearance.hair_color)
    creator_option(fields,"Skin tone","complexion",Appearance.SKINS,complexion)
    creator_option(fields,"Clan cloth","cloth",Appearance.CLOTHS,cloth)
    var actions=HBoxContainer.new();box.add_child(actions)
    button("Randomize look",randomize_appearance,actions).size_flags_horizontal=Control.SIZE_EXPAND_FILL
    if creator_editing:button("Cancel",cancel_appearance,actions).size_flags_horizontal=Control.SIZE_EXPAND_FILL
    button("Save appearance" if creator_editing else "Begin at the ancestral hearth",begin_character,actions).size_flags_horizontal=Control.SIZE_EXPAND_FILL
    name_input.grab_focus();apply_look();update_preview()
func creator_option(parent: Node,title: String,key: String,options: Array,selected: int) -> void:
    var row=HBoxContainer.new();parent.add_child(row)
    var caption=label(title,17);caption.custom_minimum_size.x=120;row.add_child(caption)
    var choice=OptionButton.new();choice.custom_minimum_size.y=42;choice.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    for i in options.size():
        if key in ["complexion","cloth","hair_color"]:
            var swatch=Image.create(18,18,false,Image.FORMAT_RGBA8)
            var color=Color.WHITE
            if key=="cloth":color=Appearance.CLOTH_COLORS[i]
            elif key=="hair_color":color=Appearance.HAIR_COLORS[i]
            else:
                var tint: Vector3=Appearance.SKIN_TINTS[i];color=Color(0.66*tint.x,0.58*tint.y,0.31*tint.z)
            swatch.fill(color);choice.add_icon_item(ImageTexture.create_from_image(swatch),options[i])
        else:choice.add_item(options[i])
    choice.selected=selected;row.add_child(choice);creator_selectors[key]=choice
    choice.item_selected.connect(func(i):
        if key=="complexion":complexion=i
        elif key=="cloth":cloth=i
        else:appearance[key]=i
        apply_look();update_preview())
func randomize_appearance() -> void:
    appearance=Appearance.defaults()
    for key in ["face","hair","beard","mustache","hair_color"]:appearance[key]=randi_range(0,creator_selectors[key].item_count-1)
    complexion=randi_range(0,Appearance.SKINS.size()-1);cloth=randi_range(0,Appearance.CLOTHS.size()-1)
    for key in creator_selectors:creator_selectors[key].selected=complexion if key=="complexion" else cloth if key=="cloth" else appearance[key]
    apply_look();update_preview()
func update_preview() -> void:
    if not is_instance_valid(preview): return
    var index=int(preview_time*5)%4 if preview_action!="rest" else 0
    var path="res://assets/motion/"+preview_action+"_"+preview_outfit+".png"
    var texture: Texture2D=load(path)
    var rect=Rect2(index*512,preview_direction*448,512,448)
    preview.texture=texture;preview.region_rect=rect;preview.scale=Vector2.ONE*0.72
    Appearance.apply(preview_material,appearance,complexion,cloth)
    Appearance.frame(preview_material,texture,rect,preview_direction,preview_action,index)
func dismiss_creator() -> void:
    creator.hide();creator.queue_free();creator=null;preview=null;face_preview=null;creator_selectors.clear();veil.hide();pause_actors(false)
func cancel_appearance() -> void:
    appearance=appearance_before.appearance.duplicate();complexion=appearance_before.complexion;cloth=appearance_before.cloth
    character_name=appearance_before.name;apply_look();dismiss_creator()
func begin_character() -> void:
    var chosen=name_input.text.strip_edges()
    if chosen.is_empty():name_input.placeholder_text="Give your Orc a name";name_input.grab_focus();return
    character_name=chosen;created=true
    var editing=creator_editing
    dismiss_creator()
    if not editing:
        player.position=Vector2(620,430);camera.reset_smoothing()
        say("Morning at your ancestral hearth. Yrsa is in the hall just north of you.")
    else:say("Appearance updated, "+character_name+".")
    apply_look();update_ui()
    if not save_game():say("Practice look updated; your campaign is untouched." if "--combat-yard" in OS.get_cmdline_user_args() else "Appearance applied for this session; saving was unavailable.")
func apply_look() -> void:
    if not ready_opener: return
    Appearance.apply(player.look_material,appearance,complexion,cloth)
    player.refresh_appearance_frame()
    if portrait_shader==null:
        portrait_shader=ShaderMaterial.new();portrait_shader.shader=load("res://scripts/orc_palette.gdshader");avatar.material=portrait_shader
    var portrait_atlas=AtlasTexture.new();portrait_atlas.atlas=load("res://assets/motion/rest_leather.png");portrait_atlas.region=Rect2(190,90,132,145)
    avatar.texture=portrait_atlas
    Appearance.apply(portrait_shader,appearance,complexion,cloth)
    Appearance.frame(portrait_shader,load("res://assets/motion/rest_leather.png"),Rect2(0,0,512,448),0)
    if is_instance_valid(face_preview):face_preview.texture=avatar.texture;face_preview.material=portrait_shader

func pause_actors(paused: bool) -> void:
    super.pause_actors(paused)
    for w in wolves: w.active=not paused and room<0
    if is_instance_valid(hunter): hunter.set_physics_process(false)
    held_attack=false
func close_modal() -> void:
    super.close_modal()
    if veil: veil.hide()
    if creator and creator.visible: pause_actors(true); veil.show()
func dialogue(title: String,index: int,body: String,options: Array) -> void:
    clear_modal(); modal.show(); veil.show(); visitor.hide(); pause_actors(true)
    modal_box.add_child(label(title,26))
    var row=HBoxContainer.new(); row.add_theme_constant_override("separation",20); modal_box.add_child(row)
    row.add_child(portrait(index,Vector2(190,190)))
    var words=label(body,19); words.custom_minimum_size.x=530; words.size_flags_horizontal=Control.SIZE_EXPAND_FILL; row.add_child(words)
    var grid=GridContainer.new(); grid.columns=2; grid.add_theme_constant_override("h_separation",10); grid.add_theme_constant_override("v_separation",8); modal_box.add_child(grid)
    for option in options:
        var b=button(option[0],option[1],grid); b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    var close_button=button("Close  [Esc]",close_modal,grid); close_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    modal.size=Vector2(820,0); modal.position=Vector2(230,170)
    call_deferred("center_modal")
    held_attack=false
func center_modal() -> void:
    await get_tree().process_frame
    if not is_instance_valid(modal): return
    modal.reset_size(); modal.size.x=820
    await get_tree().process_frame
    if is_instance_valid(modal): modal.position.y=maxf(40,(800-modal.size.y)*0.5)
func help_menu() -> void:
    dialogue("Your journal • "+objective_text,0,objective_sub+"\n\nAxe: aim anywhere on a nearby target and hold LMB. Space dodges. Greytooths lower their shoulders before committing to a charge. Strike as they recover.\n\nE interacts. I opens your pack. B builds palisades; R clears earth firebreaks; G douses nearby fuel. You can explore and complete work ahead of the journal.",[])
func inventory_menu() -> void:
    dialogue(character_name+" • Your belongings",0,"Timber: %s    Stored: %s\nIron ore / billets: %s\nRations and recovered meat: %s\nOutfit: %s\nGreytooth pelt: %s\n\nIron reduces incoming damage and upgrades your axe. The storehouse holds Bren's timber."%[state.timber,stored,ore,meat,player.equipment.capitalize(),"Given to the clan" if rewarded else "In your pack" if trophy else "Not yet claimed"],[["Eat • restore 40 health",eat],["Change owned armor",equip_owned]])
func pause_menu() -> void:
    dialogue("The Ancestral Hearth",0,"Progress saves as you play. Your current goal:\n\n"+objective_sub+"\n\nNo daily deadlines. No accidental hearth fires.",[["Resume",close_modal],["Save now",manual_save],["Sound: "+("ON" if audio_enabled else "OFF"),toggle_audio],["Camera impact: "+("ON" if accessibility_flash else "OFF"),toggle_impact],["Fire controls",fire_menu],["Save and quit",quit_game]])
func fire_menu() -> void:
    dialogue("Fire and recovery",0,"Contained hearths are safe. The optional drill starts a real woodland fire after eight seconds and saves a recovery checkpoint first.

G douses nearby fuel and cancels the warning. R clears nearby earth to stop spread. Damage and resource loss persist unless you restore the checkpoint.",[["Start warned fire drill",start_drill],["Spread: "+("ON" if state.spread_enabled else "OFF"),toggle_spread],["Restore fire checkpoint",restore_fire]])
func start_drill() -> void:
    if room>=0: close_modal(); say("Go outside before starting the fire drill."); return
    drill_target=""
    var distance:=900.0
    for id in state.objects:
        var o=state.objects[id]
        if o.kind!="tree" or o.state!="intact" or o.wet>0 or o.burning: continue
        var d: float=state.point(o).distance_to(player.position)
        if d<distance: distance=d; drill_target=id
    if drill_target.is_empty(): close_modal(); say("No dry standing tree nearby. Doused trees stay protected for 45 seconds."); return
    if not save_game("user://hearth_fire_checkpoint.json"): close_modal(); say("Checkpoint failed; fire drill cancelled."); return
    close_modal(); drill=8
func restore_fire() -> void:
    if room>=0: leave_room()
    var ok=load_game("user://hearth_fire_checkpoint.json")
    drill=-1; close_modal(); say("Before-fire checkpoint restored." if ok else "No fire checkpoint yet.")
func toggle_spread() -> void:
    state.spread_enabled=not state.spread_enabled; fire_menu()
func eat() -> void:
    if hp>=100: close_modal(); say("Already at full health. Keep your provisions for the trail."); return
    if meat<=0: close_modal(); say("No provisions left. Harvest a Greytooth or rest at the hall."); return
    super.eat()
func manual_save() -> void:
    var ok=save_game(); close_modal(); say("Progress saved." if ok else "Could not save progress.")
func toggle_audio() -> void:
    audio_enabled=not audio_enabled
    AudioServer.set_bus_mute(0,not audio_enabled); pause_menu()
func toggle_impact() -> void:
    accessibility_flash=not accessibility_flash; pause_menu()
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton and not event.pressed and event.button_index==MOUSE_BUTTON_LEFT: held_attack=false
func _unhandled_input(event: InputEvent) -> void:
    if not ready_opener or (creator and creator.visible): return
    if event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode==KEY_ESCAPE:
            if work_time>0:
                work_time=0; busy_kind=""; player.action_locked=false; say("Work cancelled.")
            elif modal.visible: close_modal()
            elif place_mode: place_mode=false
            else: pause_menu()
            return
        if modal.visible: return
        match event.physical_keycode:
            KEY_E: interact()
            KEY_SPACE:
                var can: bool=player.dodge_cooldown<=0 and work_time<=0
                player.dodge(Input.get_vector("move_left","move_right","move_up","move_down"))
                if can and player.position.distance_to(DUMMY)<180: training_dodges=1
            KEY_I: inventory_menu()
            KEY_J: help_menu()
            KEY_C: equip_owned()
            KEY_F5: manual_save()
            KEY_F6: restore_fire()
            KEY_B: place_mode=not place_mode; held_attack=false
            KEY_1: eat()
            KEY_G:
                drill=-1
                for id in state.objects:
                    if state.point(state.objects[id]).distance_to(player.position)<135: state.extinguish(id)
                say("Nearby fuel doused and protected for 45 seconds.")
            KEY_R:
                if room<0 and get_global_mouse_position().distance_to(player.position)<150: state.set_terrain(Vector2i(get_global_mouse_position()/32),"earth")
    if modal.visible or room>=0 or work_time>0: return
    if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
        if place_mode:
            var pos=(get_global_mouse_position()/32).floor()*32+Vector2(16,16)
            if state.timber>=2 and can_build(pos): state.timber-=2; state.add_object("wall",pos); sound("wood")
            else: say("Needs 2 timber and clear ground near you, away from doors and the hunting trail.")
        else:
            held_attack=true; choose_target(); player.request_attack(aim_direction())
func can_build(pos: Vector2) -> bool:
    if pos.x>1450 or pos.y>1150: return false
    if pos.distance_to(DUMMY)<150 or pos.distance_to(Vector2(1450,650))<170: return false
    return super.can_build(pos)
func setup_interior() -> void:
    for rect in [Rect2(375,220,786,35),Rect2(375,220,35,480),Rect2(1126,220,35,480),Rect2(375,680,786,35)]: boundary(interior,rect,4)
    room_npc=Sprite2D.new(); room_npc.texture=load("res://assets/camp/npcs.png")
    room_npc.region_enabled=true; room_npc.position=Vector2(800,440); interior.add_child(room_npc)
    var regions=[Rect2(26,663,522,290),Rect2(595,598,421,385),Rect2(1090,655,409,315)]
    for i in 3:
        var s=Sprite2D.new(); s.texture=load("res://assets/opener/architecture_aligned.png"); s.region_enabled=true; s.region_rect=regions[i]
        s.scale=Vector2.ONE*0.38; s.position=Vector2(540,350); s.set_meta("furnishing",[1,0,2][i]); interior.add_child(s)
        boundary(interior,Rect2(s.position+Vector2(-65,0),Vector2(130,40)),4)
        interior.get_child(-1).set_meta("furnishing",[1,0,2][i])

func enter_room(index: int) -> void:
    held_attack=false
    if ready_opener: player.cancel_action()
    super.enter_room(index)
    if index==0:
        room_npc.texture=load("res://assets/camp/npcs.png")
        room_npc.scale=Vector2.ONE*0.115
        room_npc.position=Vector2(800,440)
    else:
        room_npc.texture=load("res://assets/motion/rest_iron.png" if index==1 else "res://assets/motion/rest_leather.png")
        room_npc.region_rect=Rect2(0,0,512,448)
        room_npc.scale=Vector2.ONE*0.33
        room_npc.position=Vector2(800,427)
    if ready_opener:
        for w in wolves: w.active=false
        hunter.hide()
        camera.limit_left=-100000; camera.limit_top=-100000; camera.limit_right=100000; camera.limit_bottom=100000
        for c in interior.get_children():
            if c.has_meta("furnishing"):
                var used: bool=c.get_meta("furnishing")==index
                if c is Sprite2D: c.visible=used
                elif c is StaticBody2D: c.collision_layer=4 if used else 0
    camera.reset_smoothing()
func leave_room() -> void:
    super.leave_room()
    camera.limit_left=0; camera.limit_top=0; camera.limit_right=3584; camera.limit_bottom=1408
    if ready_opener:
        hunter.show()
        for w in wolves: w.active=true
    camera.reset_smoothing()

func save_game(path: String=OPENER_SAVE) -> bool:
    if not created and not "--test" in OS.get_cmdline_user_args(): return false
    var data=state.snapshot(); data.camp_version=1; data.opener_version=1
    data.progress={"hp":hp,"ore":ore,"meat":meat,"stored":stored,"built":built,"forged":forged,"worker_active":worker_active,"worker_cargo":worker_cargo,"kills":kills,"trees_cut":trees_cut,"collected":collected,"quest":quest,"day":day,"equipment":player.equipment}
    var pos: Vector2=player.position if room<0 else return_pos
    data.player=[pos.x,pos.y]; data.worker=[worker.position.x,worker.position.y]; data.enemies=[0,0,0]
    data.opener={"name":character_name,"appearance":appearance,"complexion":complexion,"cloth":cloth,"created":created,"introduced":introduced,"bren_met":bren_met,"training_hits":training_hits,"training_dodges":training_dodges,"hunter_found":hunter_found,"trophy":trophy,"returned":returned,"rewarded":rewarded,"recovered_count":recovered_count,"audio":audio_enabled,"impact":accessibility_flash}
    data.wolves=[]
    for w in wolves: data.wolves.append({"hp":w.hp,"harvested":w.harvested})
    var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
    if file==null: return false
    file.store_string(JSON.stringify(data)); file.close()
    return DirAccess.rename_absolute(path+".tmp",path)==OK
func load_game(path: String=OPENER_SAVE) -> bool:
    if not FileAccess.file_exists(path): return false
    var data=JSON.parse_string(FileAccess.get_file_as_string(path))
    if not data is Dictionary or data.get("opener_version")!=1 or not data.get("opener") is Dictionary or not data.get("wolves") is Array or data.wolves.size()!=4: return false
    if not data.get("player") is Array or data.player.size()!=2: return false
    for v in data.player:
        if not (v is int or v is float) or not is_finite(v): return false
    for w in data.wolves:
        if not w is Dictionary or not (w.get("hp") is int or w.get("hp") is float) or not w.get("harvested") is bool: return false
    var identity: Dictionary=data.opener
    if not identity.get("name") is String: return false
    for key in ["complexion","cloth","training_hits","training_dodges","recovered_count"]:
        if not numeric(identity.get(key)): return false
    for key in ["created","introduced","bren_met","hunter_found","trophy","returned","rewarded","audio","impact"]:
        if not identity.get(key) is bool: return false
    if not data.get("progress") is Dictionary: return false
    for key in ["hp","ore","meat","stored","built","worker_cargo","kills","trees_cut","collected","quest","day"]:
        if not numeric(data.progress.get(key)): return false
    if not data.get("worker") is Array or data.worker.size()!=2: return false
    for v in data.worker:
        if not numeric(v): return false
    if not data.get("enemies") is Array or data.enemies.size()!=3: return false
    for v in data.enemies:
        if not numeric(v): return false
    if not super.load_game(path): return false
    player.position=Vector2(clampf(data.player[0],40,3540),clampf(data.player[1],60,1370))
    kills=clampi(int(data.progress.kills),0,4)
    initial_save=data
    if ready_opener: restore_extra(data); apply_look()
    return true
func restore_extra(data: Dictionary) -> void:
    if data.is_empty(): return
    var o: Dictionary=data.get("opener",{})
    character_name=str(o.get("name","Garruk")).left(24); complexion=clampi(int(o.get("complexion",0)),0,Appearance.SKINS.size()-1); cloth=clampi(int(o.get("cloth",0)),0,Appearance.CLOTHS.size()-1)
    appearance=Appearance.clean(o.get("appearance",{}))
    if not o.has("appearance"):appearance.version=0
    created=bool(o.get("created",false)); introduced=bool(o.get("introduced",false)); bren_met=bool(o.get("bren_met",false))
    training_hits=clampi(int(o.get("training_hits",0)),0,3); training_dodges=clampi(int(o.get("training_dodges",0)),0,1)
    hunter_found=bool(o.get("hunter_found",false)); trophy=bool(o.get("trophy",false)); returned=bool(o.get("returned",false)); rewarded=bool(o.get("rewarded",false))
    recovered_count=int(o.get("recovered_count",0)); audio_enabled=bool(o.get("audio",true)); accessibility_flash=bool(o.get("impact",true))
    AudioServer.set_bus_mute(0,not audio_enabled)
    for i in mini(wolves.size(),data.get("wolves",[]).size()):
        wolves[i].hp=clampf(float(data.wolves[i].hp),0,wolves[i].maximum); wolves[i].harvested=bool(data.wolves[i].harvested)
        wolves[i].stage="dead" if wolves[i].hp<=0 else "idle"
    if returned: hunter.position=Vector2(805,600)
func sound(name: String) -> void:
    if audio_enabled and not shutting_down: super.sound(name)

func numeric(value) -> bool:
    return (value is int or value is float) and is_finite(float(value))
func _notification(what: int) -> void:
    if what==NOTIFICATION_WM_CLOSE_REQUEST: quit_game()

func quit_game() -> void:
    if shutting_down: return
    if created and not "--combat-yard" in OS.get_cmdline_user_args() and not save_game():
        say("Save failed; staying in game.")
        return
    shutting_down=true
    set_process(false)
    set_physics_process(false)
    for child in get_children():
        if child is AudioStreamPlayer:
            child.stop()
            child.stream=null
    # Let the audio mixer release stopped playback before destroying the tree.
    await get_tree().create_timer(0.15).timeout
    get_tree().quit()

func _exit_tree() -> void:
    for child in get_children():
        if child is AudioStreamPlayer: child.stop(); child.stream=null

func portrait(index: int,size: Vector2) -> TextureRect:
    var t=super.portrait(index,size)
    if index==0:
        var a=AtlasTexture.new()
        a.atlas=load("res://assets/motion/rest_leather.png")
        a.region=Rect2(165,115,182,165)
        t.texture=a
    return t
