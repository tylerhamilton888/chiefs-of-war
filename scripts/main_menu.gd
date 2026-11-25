extends Control

const CampaignState = preload("res://scripts/chapter/state.gd")
const Creator = preload("res://scripts/chapter/creator.gd")
const Loading = preload("res://scripts/loading/loading.gd")
static var booted := false
var content: VBoxContainer
var status: Label

func _ready() -> void:
    get_tree().auto_accept_quit = true
    var direct_launch := not booted and "--chapter-one" in OS.get_cmdline_user_args()
    var arena_launch := not booted and "--developer-arena" in OS.get_cmdline_user_args()
    booted = true
    if arena_launch:
        get_tree().change_scene_to_file.call_deferred("res://scenes/developer_arena.tscn")
        return
    if direct_launch:
        get_tree().change_scene_to_file.call_deferred("res://scenes/fire_we_carry.tscn")
        return
    build()
    if "--startup-smoke" in OS.get_cmdline_user_args():
        get_tree().create_timer(2.0).timeout.connect(get_tree().quit)

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
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var bg=ColorRect.new();bg.color=Color("171b18");bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
    var art=TextureRect.new();art.texture=load("res://assets/ogre/menu_camp.png");art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);art.modulate=Color.WHITE;add_child(art)
    var shade=ColorRect.new();shade.color=Color(0.055,0.065,0.055,0.12);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
    var center=CenterContainer.new();center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);center.offset_left=32;center.offset_right=-500;add_child(center)
    var panel=PanelContainer.new();panel.custom_minimum_size=Vector2(720,0);panel.add_theme_stylebox_override("panel",style("211e19ec","90734d"));center.add_child(panel)
    content=VBoxContainer.new();content.add_theme_constant_override("separation",10);panel.add_child(content)
    var title=words("HEARTH AND HUNGER",40);title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;content.add_child(title)
    var subtitle = words("The Fire We Carry", 23, "d6b176")
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(subtitle)
    var saved := FileAccess.file_exists(CampaignState.SAVE)
    var play = action("Continue" if saved else "Begin Journey", launch_campaign, content)
    status = words("", 16, "ead9b9")
    status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(status)
    status.hide()
    if saved and not CampaignState.new().load_game():
        play.disabled = true
        status.show()
        status.text = "Your campaign save could not be read. Your progress has been preserved."
    var controls_button = action("Controls", controls, content)
    action("Quit", get_tree().quit, content)
    if play.disabled:
        controls_button.grab_focus()
    else:
        play.grab_focus()

func launch_campaign() -> void:
    if FileAccess.file_exists(CampaignState.SAVE):
        Loading.start(get_tree(), "story")
        return
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    var creator := Creator.new()
    creator.cancelled.connect(build)
    creator.created.connect(func(): Loading.start(get_tree(), "story"))
    content.add_child(creator)

func controls() -> void:
    status.show()
    status.text = "WASD move · Shift stride · LMB attack · RMB block or parry · Space dodge\nE interact · Q eat · J journal · I belongings · F5 save · Esc pause"
