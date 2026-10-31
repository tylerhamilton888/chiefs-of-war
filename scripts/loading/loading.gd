extends Control
## Scene changes load in a background thread while the player sees Ogre art and tips.
static var destination=""
static var context="frontier"
# Cycle across visits so the hunter, feast and battle each get their turn.
static var next_art=0
const ARTWORK=["res://assets/loading/tracking.png","res://assets/loading/feast.png","res://assets/loading/frontier.png"]
const SCREEN="res://scenes/loading.tscn"
const VALID={"frontier":"res://scenes/ogre_frontier.tscn","story":"res://scenes/fire_we_carry.tscn"}
const TIPS={
    "frontier":[
        "A whole trunk is a weapon as well as cargo. Lift it with E, then swing with your attack controls.",
        "A well-timed block can parry an attack and create an opening for a counter.",
        "Earn Ferocity through hits and parries. A staggered goblin can become a meal—or a thrown weapon.",
        "Flint eats minerals. A fed and harnessed beast can carry a load to your wagon.",
        "The ridgeback commits its weight to a charge. Lure it into an obstacle or a snare.",
        "A hot meal restores health and helps you recover your guard for the next fight.",
        "Choose the terms of a contract before accepting it. Provisions and rights can be worth more than coin."
    ],
    "story":[
        "Block toward an attack, then time your guard for a parry and an opening to strike.",
        "Meals restore health and help keep your Ogre strong on the road.",
        "Talk to your kin at the hearth. Their skills and choices matter to the journey.",
        "A hearth is more than a place to rest: it is the beginning of a household.",
        "There is room to hunt, work and explore between the bigger moments of your story."
    ]
}
var displayed_art=""
var progress_bar: ProgressBar
var status_label: Label
var elapsed=0.0
var requested=false
var completed=false
static func start(tree: SceneTree,kind: String) -> bool:
    if not kind in VALID:return false
    destination=VALID[kind];context=kind
    return tree.change_scene_to_file(SCREEN)==OK
func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg=TextureRect.new();bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    displayed_art=ARTWORK[posmod(next_art,ARTWORK.size())];next_art+=1
    bg.texture=load(displayed_art) if ResourceLoader.exists(displayed_art) else load("res://assets/ogre/menu_camp.png")
    bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;add_child(bg)
    var overlay=ColorRect.new();overlay.color=Color(0.035,0.035,0.025,0.18);overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(overlay)
    var panel=PanelContainer.new();panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    panel.offset_left=36;panel.offset_right=-36;panel.offset_top=-225;panel.offset_bottom=-35
    var style=StyleBoxFlat.new();style.bg_color=Color("1b1916ed");style.border_color=Color("b98b56");style.set_border_width_all(2);style.set_corner_radius_all(7)
    style.content_margin_left=24;style.content_margin_right=24;style.content_margin_top=15;style.content_margin_bottom=14;panel.add_theme_stylebox_override("panel",style);add_child(panel)
    var col=VBoxContainer.new();col.add_theme_constant_override("separation",8);panel.add_child(col)
    var title=Label.new();title.text="THE FIRE WE CARRY" if context=="story" else "SUNDERED FRONTIER";title.add_theme_font_size_override("font_size",27);title.add_theme_color_override("font_color",Color("f2d29b"));col.add_child(title)
    var tip=Label.new();tip.name="Tip";var choices: Array=TIPS.get(context,TIPS.frontier)
    tip.text=choices[int(Time.get_ticks_msec())%choices.size()];tip.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;tip.add_theme_font_size_override("font_size",20);tip.add_theme_color_override("font_color",Color("f2e2c4"));tip.custom_minimum_size.y=52;col.add_child(tip)
    var footer=HBoxContainer.new();col.add_child(footer)
    status_label=Label.new();status_label.text="Preparing your journey…";status_label.add_theme_font_size_override("font_size",15);status_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;footer.add_child(status_label)
    progress_bar=ProgressBar.new();progress_bar.custom_minimum_size=Vector2(300,16);progress_bar.show_percentage=false;progress_bar.max_value=100
    var track=StyleBoxFlat.new();track.bg_color=Color("31271f");track.border_color=Color("836544");track.set_border_width_all(1);track.set_corner_radius_all(4)
    var fill=StyleBoxFlat.new();fill.bg_color=Color("d2a560");fill.set_corner_radius_all(4)
    progress_bar.add_theme_stylebox_override("background",track);progress_bar.add_theme_stylebox_override("fill",fill);footer.add_child(progress_bar)
    if destination not in VALID.values():fail("The destination could not be found.");return
    var error=ResourceLoader.load_threaded_request(destination)
    if error!=OK:fail("The journey could not be prepared.");return
    requested=true
func _process(delta: float) -> void:
    if not requested or completed:return
    elapsed+=delta;var progress=[];var state=ResourceLoader.load_threaded_get_status(destination,progress)
    if not progress.is_empty():progress_bar.value=clampf(float(progress[0])*100,0,100)
    if state==ResourceLoader.THREAD_LOAD_FAILED or state==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
        fail("The journey could not be loaded.");return
    var minimum=0.0 if "--test" in OS.get_cmdline_user_args() else 1.1
    if state==ResourceLoader.THREAD_LOAD_LOADED and elapsed>=minimum:
        completed=true;progress_bar.value=100;status_label.text="Ready."
        var scene=ResourceLoader.load_threaded_get(destination)
        if not scene is PackedScene or get_tree().change_scene_to_packed(scene)!=OK:fail("The journey could not be opened.")
func fail(message: String) -> void:
    requested=false;completed=false;status_label.text=message+" Return to the title and try again."
    var button=Button.new();button.text="Return to title";button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    button.offset_left=-240;button.offset_right=-40;button.offset_top=-95;button.offset_bottom=-50
    button.pressed.connect(func():get_tree().change_scene_to_file("res://scenes/main_menu.tscn"));add_child(button)
