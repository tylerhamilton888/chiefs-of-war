extends Control
const Slots=preload("res://scripts/save_slots.gd")
var content: VBoxContainer
var status: Label
func _ready() -> void:
    get_tree().auto_accept_quit=true
    var first_boot=not Slots.booted
    Slots.booted=true
    if first_boot and "--ogre-hearth" in OS.get_cmdline_user_args():
        get_tree().change_scene_to_file.call_deferred("res://scenes/wandering_hearth.tscn");return
    if first_boot and ("--combat-yard" in OS.get_cmdline_user_args() or "--fresh" in OS.get_cmdline_user_args()):
        Slots.practice="--combat-yard" in OS.get_cmdline_user_args();Slots.fresh=true
        get_tree().change_scene_to_file.call_deferred("res://scenes/opener.tscn");return
    Slots.restore_selection();Slots.practice=false;Slots.fresh=false
    build()
    if "--startup-smoke" in OS.get_cmdline_user_args(): get_tree().create_timer(2.0).timeout.connect(get_tree().quit)
func style(bg: String,border: String) -> StyleBoxFlat:
    var s=StyleBoxFlat.new();s.bg_color=Color(bg);s.border_color=Color(border);s.set_border_width_all(2);s.set_corner_radius_all(5)
    s.content_margin_left=22;s.content_margin_right=22;s.content_margin_top=13;s.content_margin_bottom=13
    return s
func words(text: String,size: int,color: String="ead9b9") -> Label:
    var l=Label.new();l.text=text;l.add_theme_font_size_override("font_size",size);l.add_theme_color_override("font_color",Color(color));return l
func action(text: String,callback: Callable,parent: Node) -> Button:
    var b=Button.new();b.text=text;b.custom_minimum_size.y=49;b.add_theme_font_size_override("font_size",20)
    b.add_theme_stylebox_override("normal",style("352920","8c6944"));b.add_theme_stylebox_override("hover",style("59402a","e1b66b"));b.add_theme_stylebox_override("focus",style("59402a","e1b66b"));b.add_theme_stylebox_override("pressed",style("241d18","c89550"));b.pressed.connect(callback);parent.add_child(b);return b
func build() -> void:
    for child in get_children():child.queue_free()
    var bg=ColorRect.new();bg.color=Color("171b18");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
    var art=TextureRect.new();art.texture=load("res://assets/ogre/menu_camp.png");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);art.modulate=Color.WHITE;add_child(art)
    var shade=ColorRect.new();shade.color=Color(0.055,0.065,0.055,0.12);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
    var center=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);center.offset_left=32;center.offset_right=-500;add_child(center)
    var panel=PanelContainer.new();panel.custom_minimum_size=Vector2(720,0);panel.add_theme_stylebox_override("panel",style("211e19ec","90734d"));center.add_child(panel)
    content=VBoxContainer.new();content.add_theme_constant_override("separation",10);panel.add_child(content)
    var title=words("HEARTH AND HUNGER",40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;content.add_child(title)
    var sub=words("A NOMADIC OGRE SANDBOX",16,"b99a66");sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;content.add_child(sub)
    action("Enter the wandering hearth",ogre_hearth,content)
    content.add_child(words("First Ogre prototype • movement, camp and provisions",15,"b5ac98"))
    content.add_child(HSeparator.new())
    var current=Slots.info(Slots.selected)
    var resume=action("Continue • "+current.name if not current.empty else "Continue • no character yet",func():launch(Slots.selected,false),content);resume.disabled=current.empty or not current.valid
    content.add_child(words("EARLIER CAMPAIGNS • CHIEFS OF WAR",16,"b99a66"))
    for i in Slots.COUNT:
        var info=Slots.info(i);var row=HBoxContainer.new();row.add_theme_constant_override("separation",16);content.add_child(row)
        var label_text="%d   %s"%[i+1,info.name]
        if not info.empty and info.valid:label_text+="   •   Day %d   •   %s"%[info.day,info.outfit.capitalize()]
        var l=words(label_text,17);l.clip_text=true;l.custom_minimum_size.x=420;l.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(l)
        var index=i;var empty=info.empty
        var b=action("New character" if empty else "Play",func():launch(index,empty),row);b.custom_minimum_size.x=190;b.disabled=not info.valid
    status=words("Each character has its own world, progress and checkpoints.",15,"b5ac98");content.add_child(status)
    if Slots.load_failed:status.text="That save could not be loaded. It has been preserved; choose another slot."
    var extras=HBoxContainer.new();extras.add_theme_constant_override("separation",12);content.add_child(extras)
    for spec in [["Practice",practice],["Controls",controls],["Quit",func():get_tree().quit()]]:
        var b=action(spec[0],spec[1],extras);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    content.get_child(2).grab_focus()
func ogre_hearth() -> void:
    get_tree().change_scene_to_file("res://scenes/wandering_hearth.tscn")
func launch(index: int,new_character: bool) -> void:
    var info=Slots.info(index)
    if not info.valid or (new_character and not info.empty):status.text="This slot already contains a character. Choose an empty slot.";return
    Slots.choose(index,new_character)
    get_tree().change_scene_to_file("res://scenes/opener.tscn")
func practice() -> void:
    Slots.practice=true;Slots.fresh=true;Slots.load_failed=false
    get_tree().change_scene_to_file("res://scenes/opener.tscn")
func controls() -> void:
    status.text="WASD move • LMB axe • RMB hold block / timed parry • Space dodge\nE interact • I belongings • J journal • Esc pause • F5 save"
