extends "res://scripts/opener.gd"
const Clan=preload("res://scripts/clan_art.gd")
const Doorway=preload("res://scripts/doorway.gd")
var portals=[]
var room_exit: Sprite2D
var room_props=[]
var torch_lights=[]
var transition: ColorRect
var transition_tween: Tween
var npc_time:=0.0
var sheet_kind:=""
var npc_hint: Label
var return_trophy: Sprite2D

func _ready() -> void:
    super._ready()
    worker.modulate=Color.WHITE;hunter.modulate=Color.WHITE
    for b in buildings:
        var door=Doorway.new();door.target=player;door.open_front=buildings.find(b)==1;b.add_child(door);portals.append(door)
    for spec in [[3,Vector2(1080,390),62],[5,Vector2(800,815),58],[6,Vector2(850,835),55],[4,Vector2(1100,810),82],[8,Vector2(410,345),40],[10,Vector2(1220,620),82]]:
        var s=Clan.prop(spec[0],spec[1],spec[2]);actors.add_child(s)
    # A hunting work area gives the camp a visible meat-and-hide economy.
    # Decorative for now: do not imply a processing interaction exists yet.
    var hunt_station=Sprite2D.new()
    hunt_station.texture=load("res://assets/overhaul/hunt_workstation.png")
    hunt_station.scale=Vector2.ONE*(190.0/1536.0)
    hunt_station.position=Vector2(1150,920-1024.0*hunt_station.scale.y*0.5)
    actors.add_child(hunt_station)
    transition=ColorRect.new();transition.color=Color(0.025,0.02,0.015,0);transition.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);transition.mouse_filter=Control.MOUSE_FILTER_IGNORE;ui_root.add_child(transition)

func _process(delta: float) -> void:
    super._process(delta)
    if not ready_opener:return
    if not modal.visible and not is_instance_valid(creator):npc_time+=delta
    var alternate:=fmod(npc_time,9.0)>6.5
    if is_instance_valid(hunter):Clan.idle(hunter.sprite,0,alternate)
    if worker.attack_time<=0 and worker.velocity.length()<2:Clan.idle(worker.sprite,2,alternate)
    if room>=0:
        Clan.idle(room_npc,3 if room==0 else 1,alternate,92 if room==0 else 98)
        room_npc.position+=Vector2(800,480)
        if return_trophy:return_trophy.visible=room==0 and rewarded
    for i in portals.size():portals[i].enabled=buildings[i].visible and buildings[i].parts[1]>0
    for pair in torch_lights:
        pair[0].modulate=Color(1.0,0.96+sin(npc_time*5.3+pair[1])*0.03,0.88+sin(npc_time*7.1)*0.03)
    if npc_hint:
        npc_hint.visible=false
        if room<0 and not modal.visible and not is_instance_valid(creator):
            var who=worker if player.position.distance_to(worker.position)<100 else hunter if player.position.distance_to(hunter.position)<100 else null
            if who:
                var screen: Vector2=get_global_transform_with_canvas()*who.position
                npc_hint.position=screen+Vector2(-80,-124);npc_hint.text=("Bren" if who==worker else "Torren")+"  ·  [E]";npc_hint.show()

func setup_interior() -> void:
    for r in [Rect2(375,220,786,35),Rect2(375,220,35,480),Rect2(1126,220,35,480),Rect2(375,680,360,35),Rect2(805,680,356,35),Rect2(735,704,70,18)]:boundary(interior,r,4)
    room_npc=Sprite2D.new();interior.add_child(room_npc)
    # Each room has a clear central route from the threshold to its NPC/service.
    room_prop(0,0,Vector2(770,325),165,Vector2(140,30))
    room_prop(0,1,Vector2(535,430),185,Vector2(150,32))
    room_prop(0,2,Vector2(535,490),155,Vector2(145,18))
    room_prop(0,3,Vector2(1040,350),74,Vector2(60,28))
    room_prop(0,8,Vector2(550,315),43)
    room_prop(0,8,Vector2(970,315),43)
    return_trophy=room_prop(0,10,Vector2(1030,515),88)
    room_prop(1,0,Vector2(540,342),175,Vector2(150,40))
    room_prop(1,7,Vector2(555,470),105,Vector2(80,30))
    room_prop(1,4,Vector2(1020,360),120,Vector2(100,28))
    room_prop(1,5,Vector2(1030,540),80,Vector2(65,28))
    room_prop(1,3,Vector2(460,560),65,Vector2(58,25))
    for p in [Vector2(485,355),Vector2(600,355),Vector2(1000,355),Vector2(1065,470)]:room_prop(2,5,p,90,Vector2(75,30))
    room_prop(2,6,Vector2(505,530),110,Vector2(90,30))
    room_prop(2,3,Vector2(995,560),90,Vector2(75,30))
    for which in 3:
        for x in [430,1100]:
            var s=room_prop(which,9,Vector2(x,360),28);torch_lights.append([s,float(x)])
    room_exit=Clan.prop(11,Vector2(768,703),100);interior.add_child(room_exit)

func room_prop(which: int,index: int,pos: Vector2,width: float,collision: Vector2=Vector2.ZERO) -> Sprite2D:
    var s=Clan.prop(index,pos,width);s.set_meta("furnishing",which);interior.add_child(s);room_props.append(s)
    if collision!=Vector2.ZERO:
        boundary(interior,Rect2(pos-Vector2(collision.x*0.5,collision.y),collision),4)
        interior.get_child(-1).set_meta("furnishing",which)
    return s

func _draw() -> void:
    if room<0:super._draw();return
    draw_rect(Rect2(-2000,-2000,6000,6000),Color("0e100e"))
    draw_rect(Rect2(375,220,786,495),Color("28221b"))
    var area=Rect2(410,255,716,425)
    for y in range(0,425,150):
        for x in range(0,716,190):
            var sz=Vector2(mini(190,716-x),mini(150,425-y))
            draw_texture_rect_region(floor_texture,Rect2(area.position+Vector2(x,y),sz),Rect2(Vector2.ZERO,Vector2(floor_texture.get_size())*sz/Vector2(190,150)),Color(0.63,0.62,0.56) if room==1 else Color(0.83,0.78,0.68))
    # Timber wall caps, corner posts and stone foundation stay square to the floor.
    for r in [Rect2(390,235,755,24),Rect2(390,250,20,440),Rect2(1125,250,20,440)]:
        draw_rect(r,Color("413020"));draw_rect(r,Color("796044"),false,2)
    for x in [395,585,950,1135]:
        draw_rect(Rect2(x-8,235,16,45),Color("34271d"));draw_circle(Vector2(x,248),3,Color("1b1c19"))
    if room==0:
        draw_rect(Rect2(706,352,140,255),Color("572e29"));draw_rect(Rect2(712,358,128,243),Color("a27d4c"),false,2)
        for y in [380,560]:draw_polyline(PackedVector2Array([Vector2(735,y),Vector2(775,y-13),Vector2(815,y),Vector2(775,y+13),Vector2(735,y)]),Color("ae8a55"),2)
    elif room==1:
        draw_rect(Rect2(440,285,210,240),Color(0.17,0.17,0.16,0.75))
        for y in range(300,525,30):draw_line(Vector2(440,y),Vector2(650,y),Color("44403a"),1)
    else:
        for x in [455,950]:draw_rect(Rect2(x,300,150,290),Color(0.14,0.11,0.08,0.25))
    draw_rect(Rect2(735,675,70,30),Color("9b8665"))
    draw_line(Vector2(735,703),Vector2(805,703),Color("d4bb8a"),3)

func enter_room(index: int) -> void:
    super.enter_room(index)
    Clan.idle(room_npc,3 if index==0 else 1,false,92 if index==0 else 98)
    room_npc.position+=Vector2(800,480)
    room_exit.modulate=Color(1,1,1,0.72)
    fade_threshold()
func leave_room() -> void:
    super.leave_room();fade_threshold()
func fade_threshold() -> void:
    if not is_instance_valid(transition):return
    if transition_tween and transition_tween.is_running():transition_tween.kill()
    transition.color.a=0.55;transition_tween=create_tween();transition_tween.tween_property(transition,"color:a",0.0,0.2)
func interact() -> void:
    if room<0:
        for i in 3:
            if player.position.distance_to(DORS(i))<80 and player.position.y<DORS(i).y-15:
                say("Approach the doorway from the path.");return
    super.interact()

func create_ui() -> void:
    super.create_ui()
    var t=ui_root.theme
    t.set_stylebox("focus","Button",panel_style(Color(0,0,0,0),Color("edcb85")))
    t.set_stylebox("disabled","Button",panel_style(Color("23251f"),Color("424638")))
    t.set_color("font_disabled_color","Button",Color("777c6d"))
    for control in ["LineEdit","OptionButton"]:
        t.set_stylebox("normal",control,panel_style(Color("1c211b"),Color("746143")))
        t.set_stylebox("focus",control,panel_style(Color("252c22"),Color("d1b275")))
        t.set_color("font_color",control,Color("efdfbc"))
    npc_hint=label("",16);npc_hint.size=Vector2(160,28);npc_hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;npc_hint.mouse_filter=Control.MOUSE_FILTER_IGNORE
    npc_hint.add_theme_color_override("font_shadow_color",Color.BLACK);npc_hint.add_theme_constant_override("shadow_offset_y",2);ui_root.add_child(npc_hint)
    ui_root.move_child(npc_hint,ui_root.get_child_count()-3)
func panel_style(bg: Color,border: Color) -> StyleBoxFlat:
    var s=super.panel_style(bg,border);s.set_corner_radius_all(4);s.border_width_top=2;s.border_width_bottom=3
    s.shadow_color=Color(0,0,0,0.33);s.shadow_size=5;s.shadow_offset=Vector2(0,3);return s
func button(text: String,call: Callable,parent: Node) -> Button:
    var b=super.button(text,call,parent);b.custom_minimum_size.y=44;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;return b
func portrait(index: int,size: Vector2) -> TextureRect:
    if index==4:return super.portrait(0,size)
    var t=TextureRect.new();var a=AtlasTexture.new();a.atlas=Clan.PORTRAITS
    var cell=Vector2(Clan.PORTRAITS.get_size())/2
    a.region=Rect2(Vector2(index%2,index/2)*cell,cell);t.texture=a;t.custom_minimum_size=size;t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;return t
func update_ui() -> void:
    super.update_ui()
    if is_instance_valid(avatar):
        # Player avatar remains tied to the chosen player, not Torren's portrait.
        if not avatar.has_meta("player_avatar"):
            var player_portrait=super.portrait(0,Vector2(70,78));avatar.texture=player_portrait.texture;player_portrait.free();avatar.set_meta("player_avatar",true)
func begin_sheet(title: String,subtitle: String,kind: String) -> void:
    clear_modal();sheet_kind=kind;modal.show();veil.show();visitor.hide();pause_actors(true)
    modal_box.add_child(label(title,28))
    var sub=label(subtitle,15);sub.add_theme_color_override("font_color",Color("b6a17b"));modal_box.add_child(sub)
    modal_box.add_child(HSeparator.new())
func finish_sheet() -> void:
    modal.size=Vector2(820,0);modal.position=Vector2(230,100);call_deferred("center_modal");call_deferred("focus_sheet")
func focus_sheet() -> void:
    for b in modal.find_children("*","Button",true,false):
        if not b.disabled:b.grab_focus();return
func card(title: String,value: String,parent: Node) -> void:
    var p=PanelContainer.new();p.size_flags_horizontal=Control.SIZE_EXPAND_FILL;p.custom_minimum_size=Vector2(235,85);parent.add_child(p)
    var v=VBoxContainer.new();p.add_child(v);var l=label(title.to_upper(),13);l.add_theme_color_override("font_color",Color("b6a17b"));v.add_child(l);v.add_child(label(value,23))
func inventory_menu() -> void:
    begin_sheet("Your belongings","Provisions, materials, and the kit you carry.","inventory")
    var grid=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);modal_box.add_child(grid)
    card("Timber",str(state.timber),grid);card("Stored timber",str(stored),grid);card("Iron billets",str(ore),grid)
    card("Provisions",str(meat),grid);card("Outfit",player.equipment.capitalize(),grid);card("Greytooth pelt","Given to clan" if rewarded else "Carried" if trophy else "Not found",grid)
    modal_box.add_child(label("Iron kit: stronger axe strikes and reduced incoming damage. Provisions restore up to 40 health.",16))
    var actions=GridContainer.new();actions.columns=2;modal_box.add_child(actions)
    var eat_button=button("Eat provision  ·  +40 health",eat,actions);eat_button.disabled=meat<=0 or hp>=100
    var outfit=button("Change to "+("leather" if player.equipment=="iron" else "iron"),equip_owned,actions);outfit.disabled=not forged
    button("Return  [Esc]",close_modal,modal_box);finish_sheet()
func help_menu() -> void:
    begin_sheet("Your journal",objective_text,"journal")
    var current=PanelContainer.new();modal_box.add_child(current);current.add_child(label(objective_sub,19))
    var items=[[introduced,"Meet Yrsa in the Ash Hall"],[built==3,"Help Bren finish the timber store"],[training_hits>=3 and training_dodges>=1,"Practice your axe and dodge"],[trophy and returned,"Bring Torren home and claim the Greytooth pelt"],[forged,"Return to Yrsa, then earn Harn's iron kit"]]
    for item in items:
        var l=label(("✓  " if item[0] else "○  ")+item[1],17);l.add_theme_color_override("font_color",Color("839b72") if item[0] else Color("ded0b0"));modal_box.add_child(l)
    modal_box.add_child(HSeparator.new());modal_box.add_child(label("WASD move  •  Hold LMB axe  •  RMB block / timed parry  •  Space dodge  •  E interact\nI belongings  •  B palisade  •  F5 save\nExplore at your own pace; the journal suggests your next step.",15))
    button("Return to the hearth  [Esc]",close_modal,modal_box);finish_sheet()
func pause_menu() -> void:
    begin_sheet("CHIEFS OF WAR","THE ANCESTRAL HEARTH  ·  GAME PAUSED","pause")
    modal_box.add_child(label(objective_text,21));modal_box.add_child(label(objective_sub,17))
    var actions=GridContainer.new();actions.columns=2;actions.add_theme_constant_override("h_separation",12);actions.add_theme_constant_override("v_separation",8);modal_box.add_child(actions)
    for spec in [["Resume  [Esc]",close_modal],["Save progress",manual_save],["Sound: "+("On" if audio_enabled else "Off"),toggle_audio],["Camera impact: "+("On" if accessibility_flash else "Off"),toggle_impact],["Fire & recovery",fire_menu],["Main menu / characters",return_to_menu],["Save and quit",quit_game]]:
        var b=button(spec[0],spec[1],actions);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.custom_minimum_size.x=370
    modal_box.add_child(label("Autosaves every 30 seconds and at major milestones. No daily deadlines.",14));finish_sheet()
func dialogue(title: String,index: int,body: String,options: Array) -> void:
    var bits=title.split(" • ");begin_sheet(bits[0],bits[1] if bits.size()>1 else "ASHFANG CLAN","dialogue")
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",22);modal_box.add_child(row)
    var frame=PanelContainer.new();frame.add_child(portrait(index,Vector2(174,174)));row.add_child(frame)
    var words=label(body,18);words.custom_minimum_size.x=505;words.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(words)
    var actions=VBoxContainer.new();actions.add_theme_constant_override("separation",7);modal_box.add_child(actions)
    for option in options:button(option[0],option[1],actions)
    button("Farewell  [Esc]" if index!=4 else "Return  [Esc]",close_modal,actions);finish_sheet()

func store_menu() -> void:
    begin_sheet("The timber store","Bren keeps the clan supplied from here.","storage")
    var grid=GridContainer.new();grid.columns=2;modal_box.add_child(grid)
    card("Stored timber",str(stored),grid);card("Carried timber",str(state.timber),grid)
    button("Take all timber",withdraw,modal_box).disabled=stored<=0
    button("Store all timber",deposit,modal_box).disabled=state.timber<=0
    button("Assign / stand down Bren",toggle_worker,modal_box)
    button("Leave storehouse",leave_and_close,modal_box)
    button("Return  [Esc]",close_modal,modal_box);finish_sheet()
func fire_menu() -> void:
    begin_sheet("Fire & recovery","Optional woodland drill", "fire")
    modal_box.add_child(label("Contained hearths are safe. A drill saves a recovery checkpoint, then starts a woodland fire after an eight-second warning. Damage and resource loss persist until you restore that checkpoint.",17))
    modal_box.add_child(label("G douses nearby fuel and cancels the warning. R clears earth to stop the spread.",17))
    button("Start warned fire drill" if room<0 else "Go outside to start a drill",start_drill,modal_box).disabled=room>=0
    button("Fire spread: "+("On" if state.spread_enabled else "Off"),toggle_spread,modal_box)
    button("Restore fire checkpoint",restore_fire,modal_box).disabled=not FileAccess.file_exists("user://hearth_fire_checkpoint.json")
    button("Return  [Esc]",close_modal,modal_box);finish_sheet()
