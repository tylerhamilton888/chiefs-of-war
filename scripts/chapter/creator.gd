extends VBoxContainer

signal created
signal cancelled

const State = preload("res://scripts/chapter/state.gd")
const Actor = preload("res://scripts/chapter/actor.gd")
const DIRECTIONS = [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]

var preview: Actor
var name_edit: LineEdit
var clan_edit: LineEdit
var background_select: OptionButton
var hair_select: OptionButton
var note: Label
var start: Button
var turn := 0
var phase := 0.0

func _ready() -> void:
    add_theme_constant_override("separation", 14)
    var title := Label.new()
    title.text = "Create your Ogre"
    title.add_theme_font_size_override("font_size", 31)
    title.add_theme_color_override("font_color", Color("f2d29b"))
    add_child(title)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 24)
    add_child(row)
    var portrait := VBoxContainer.new()
    row.add_child(portrait)
    var frame := ColorRect.new()
    frame.color = Color("29251f")
    frame.custom_minimum_size = Vector2(206, 244)
    frame.clip_contents = true
    portrait.add_child(frame)
    preview = Actor.new()
    preview.position = Vector2(103, 219)
    preview.height = 177
    preview.enabled = false
    preview.controlled = false
    frame.add_child(preview)
    preview.collision_layer = 0
    preview.collision_mask = 0
    var rotate := make_button("Turn Ogre", func():
        turn = (turn + 1) % DIRECTIONS.size()
        preview.face(DIRECTIONS[turn]))
    portrait.add_child(rotate)

    var fields := VBoxContainer.new()
    fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(fields)
    name_edit = name_field(fields, "Ogre name", State.DEFAULT_PROFILE.ogre_name)
    clan_edit = name_field(fields, "Clan name", State.DEFAULT_PROFILE.clan_name)
    hair_select = selector(fields, "Hair and beard")
    for hair: String in State.HAIR:
        hair_select.add_item(hair.capitalize())
    hair_select.item_selected.connect(func(index: int): preview.set_hair_palette(State.HAIR[index]))
    background_select = selector(fields, "Background")
    for id: String in State.BACKGROUNDS:
        background_select.add_item(State.BACKGROUNDS[id].label)
        background_select.set_item_metadata(background_select.item_count - 1, id)
    background_select.item_selected.connect(func(_index: int): refresh())

    note = Label.new()
    note.add_theme_font_size_override("font_size", 17)
    note.add_theme_color_override("font_color", Color("ebd9b6"))
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(note)
    var actions := HBoxContainer.new()
    add_child(actions)
    var back := make_button("Back", func(): cancelled.emit())
    actions.add_child(back)
    start = make_button("Enter Emberhide Crossing", create)
    start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    actions.add_child(start)
    refresh()
    name_edit.grab_focus()
    name_edit.select_all()

func _process(delta: float) -> void:
    phase = fposmod(phase + delta * 155.0 / preview.STRIDE, 1.0)
    preview.show_frame([1, 2, 3, 0][int(phase * 4)])

func label_field(fields: VBoxContainer, caption: String) -> void:
    var label := Label.new()
    label.text = caption
    label.add_theme_color_override("font_color", Color("e4c595"))
    fields.add_child(label)

func name_field(fields: VBoxContainer, caption: String, initial: String) -> LineEdit:
    label_field(fields, caption)
    var edit := LineEdit.new()
    edit.max_length = 28
    edit.text = initial
    edit.custom_minimum_size.y = 36
    edit.text_changed.connect(func(_text: String): refresh())
    fields.add_child(edit)
    return edit

func selector(fields: VBoxContainer, caption: String) -> OptionButton:
    label_field(fields, caption)
    var select := OptionButton.new()
    select.custom_minimum_size.y = 36
    fields.add_child(select)
    return select

func make_button(caption: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(94, 40)
    button.pressed.connect(callback)
    return button

func identity() -> Dictionary:
    return {
        "ogre_name": name_edit.text.strip_edges(),
        "clan_name": clan_edit.text.strip_edges(),
        "background": background_select.get_selected_metadata(),
        "hair": State.HAIR[hair_select.selected],
    }

func refresh() -> void:
    if not is_instance_valid(start):
        return
    var chosen := identity()
    var supplies: Dictionary = State.BACKGROUNDS[chosen.background]
    note.text = "Starting supplies: %d %s." % [supplies.amount, supplies.item]
    start.disabled = not State.valid_profile(chosen)
    if start.disabled:
        note.text = "Enter an Ogre name and a clan name."

func create() -> void:
    if start.disabled:
        return
    if not State.new().create_journey(identity()):
        note.text = "The journey could not be saved. Return to the title to check your save."
        return
    start.disabled = true
    created.emit()
