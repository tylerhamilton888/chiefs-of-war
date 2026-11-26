extends SceneTree
## Uses real scene interactions and disposable chapter saves.
const State = preload("res://scripts/chapter/state.gd")
const CHAPTER := "res://scenes/fire_we_carry.tscn"
var game
var checks := 0
var failures := 0

func _initialize() -> void:
    run.call_deferred()

func verify(ok: bool, label: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(label)

func settle(ticks := 4) -> void:
    for i in ticks:
        await physics_frame

func press(key: Key) -> void:
    var input := InputEventKey.new()
    input.keycode = key
    input.pressed = true
    game._unhandled_input(input)

func reload_chapter() -> void:
    change_scene_to_file(CHAPTER)
    await settle(6)
    game = current_scene

func reach(entry: Dictionary) -> void:
    game.player.position = entry.position
    game.update_nearest()

func cut_entry(id: String) -> Dictionary:
    for entry in game.supplies:
        if entry.kind == "goblin_cut" and entry.id == id:
            return entry
    return {}

func write_save(data: Dictionary) -> void:
    var file := FileAccess.open(State.SAVE, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

func run() -> void:
    var old = State.new().pack()
    old.erase("field_cuts")
    old.erase("pot_servings")
    old.inventory.erase("goblin_meat")
    old.profile.ogre_name = "Torg"
    old.region = "cairn"
    old.defeated = ["cairn_0"]
    old.flags.introduced = true
    old.inventory.meat = 7
    write_save(old)
    await reload_chapter()
    verify(game.state.profile.ogre_name == "Torg" and game.state.inventory.goblin_meat == 0 and game.state.inventory.meat == 7, "Legacy supplies and profile survive")
    verify(cut_entry("cairn_0").is_empty() and game.enemies.size() == 2, "Legacy kills do not generate a second reward")
    for foe in game.enemies:
        foe.active = false
    var first = game.enemies[0]
    var id: String = first.get_meta("id")
    game.player.position = first.position + Vector2(0, 80)
    game.player.attack(Vector2.UP)
    await settle(33)
    verify(first.hp == 0 and cut_entry(id).get("kind") == "goblin_cut", "Actual axe contact leaves a choice on the ground")
    if cut_entry(id).is_empty():
        quit(1)
        return
    var at: Vector2 = cut_entry(id).position
    game.enemy_slain(first)
    verify(game.state.field_cuts.size() == 1 and game.state.inventory.meat == 7 and game.state.inventory.coin == 2, "A second slain event duplicates neither meat nor coin")
    await reload_chapter()
    verify(cut_entry(id).get("position") == at and game.enemies.size() == 1, "Pending cut survives reload at its exact ground position")
    game.state.gore = false
    game.rebuild()
    await settle()
    verify(cut_entry(id).node.restrained, "Restrained palette displays the wrapped cut")
    reach(cut_entry(id))
    var stale := cut_entry(id)
    press(KEY_E)
    game.interact(stale)
    verify(game.state.inventory.goblin_meat == 1 and game.state.field_cuts.is_empty(), "Take and stale interaction grant just one cut")
    await reload_chapter()
    verify(cut_entry(id).is_empty() and game.state.inventory.goblin_meat == 1, "Gathered cut stays in the pack after a reload")
    press(KEY_Q)
    verify(game.state.inventory.goblin_meat == 1 and game.state.inventory.meals == 0, "Q reserves packed raw cuts for a deliberate choice")
    var second = game.enemies[0]
    game.player.position = second.position + Vector2(0, 85)
    second.receive_weapon_hit(99, Vector2.UP, true)
    reach(cut_entry(second.get_meta("id")))
    game.player.hp = 75
    press(KEY_F)
    verify(game.player.hp == 100 and game.state.inventory.goblin_meat == 1, "Eating directly from the ground heals without taking a carried cut")
    game.travel("crossing", Vector2(1050, 1100), true)
    await settle()
    var pot: Dictionary = game.stations.filter(func(entry):return entry.kind == "hearth")[0]
    reach(pot)
    press(KEY_E)
    verify(game.state.inventory.goblin_meat == 0 and game.camp_pot.servings == 2 and game.state.inventory.meals == 0, "One pot deposit becomes two visible portions, still in the pot")
    await reload_chapter()
    verify(game.camp_pot.servings == 2 and game.state.inventory.goblin_meat == 0, "Local pot and spent cut survive a reload")
    pot = game.stations.filter(func(entry):return entry.kind == "hearth")[0]
    reach(pot)
    press(KEY_E)
    press(KEY_E)
    press(KEY_E)
    verify(game.camp_pot.servings == 0 and game.state.inventory.meals == 2, "Two ladles empty the pot without an extra meal")
    game.player.hp = 65
    press(KEY_Q)
    verify(game.player.hp == 130 and game.state.inventory.meals == 1 and game.state.fed > 0, "Bowl is a real meal through normal eat input")
    game.state.inventory.goblin_meat = 1
    press(KEY_E)
    game.state.inventory.wood = 1
    press(KEY_C)
    verify(game.state.inventory.meals == 4 and game.camp_pot.servings == 2, "Ordinary hearth recipe remains available alongside goblin stew")
    game.travel("host", Vector2(1080,1000), true)
    verify(game.camp_pot.servings == 0, "Stew remains in the camp where it was made")
    game.state.inventory.goblin_meat = 1
    game.player.hp = 70
    press(KEY_I)
    var eat_button: Button
    for button in game.modal.find_children("*", "Button", true, false):
        if button.text.begins_with("Eat a goblin cut"):
            eat_button = button
    verify(eat_button != null, "Belongings offers the carried cut")
    if eat_button:
        eat_button.pressed.emit()
    verify(game.player.hp == 95 and game.state.inventory.goblin_meat == 0, "Eating the packed cut spends it and heals")
    var save := FileAccess.get_file_as_string(State.SAVE)
    change_scene_to_file("res://scenes/developer_arena.tscn")
    await settle(6)
    game = current_scene
    var goblin = game.enemies[0]
    goblin.receive_weapon_hit(99, Vector2.LEFT, false)
    verify(game.state.field_cuts.is_empty(), "Blunt defeat leaves no cleaved cut")
    press(KEY_R)
    await settle(6)
    game = current_scene
    goblin = game.enemies[0]
    goblin.receive_weapon_hit(99, Vector2.LEFT, true)
    reach(cut_entry(goblin.get_meta("id")))
    press(KEY_E)
    reach(game.stations[0])
    press(KEY_E)
    press(KEY_E)
    verify(game.state.inventory.meals == 1 and game.camp_pot.servings == 1, "Disposable yard uses the same gather, cook and ladle path")
    press(KEY_R)
    await settle(6)
    verify(current_scene.camp_pot.servings == 0 and FileAccess.get_file_as_string(State.SAVE) == save, "Reset clears the yard while preserving campaign bytes")
    var spoiled: Dictionary = JSON.parse_string(save)
    spoiled.pot_servings["crossing"] = -1
    write_save(spoiled)
    var damaged := State.new()
    var before := FileAccess.get_file_as_string(State.SAVE)
    verify(not damaged.load_game() and not damaged.save_game() and FileAccess.get_file_as_string(State.SAVE) == before, "Invalid kettle data is preserved on disk")
    print("Field kitchen: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
