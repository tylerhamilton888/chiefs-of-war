extends SceneTree
const State = preload("res://scripts/chapter/state.gd")
var failed := false

func _initialize() -> void:
    run.call_deferred()

func verify(condition: bool, message: String) -> void:
    if not condition:
        failed = true
        push_error(message)

func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var state := State.new()
    var identity := State.DEFAULT_PROFILE.duplicate()
    identity.ogre_name = "Orm"
    verify(state.create_journey(identity), "Created the named Ogre")
    var game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    await process_frame
    verify("Orm" in game.dialog_text.text and not "{name}" in game.dialog_text.text, "Father uses the chosen name")
    verify(game.npcs.svala.enabled and not game.npcs.bramm.enabled, "Mother works in view while Father gives the job")
    game.choose("work")
    for cut in game.supplies.duplicate():
        if cut.kind == "wood" and game.state.inventory.wood < 6:
            game.interact(cut)
    game.interact({"kind": "repair"})
    verify(game.state.has("repaired") and game.speech.visible, "Father responds to the actual repair")
    game.state.inventory.meals = 1
    game.story.talk("bramm")
    verify(not game.story.can_share_with_bramm(), "Keeps the first portion for Sava")
    game.choose("close")
    game.state.inventory.meat = 2
    game.state.inventory.wood = 1
    game.cook_provisions()
    verify(game.speech.speaker == game.npcs.svala and game.speech.visible, "Mother speaks from the fire")
    game.story.talk("bramm")
    verify(not game.speech.visible, "Spoken caption yields to conversation")
    var gift: Button
    for button in game.dialog_buttons.get_children():
        if button.text == "Take a bowl, Father.":
            gift = button
    verify(gift != null, "Meeting Bramm with spare food offers the meal")
    if gift:
        gift.pressed.emit()
    verify(game.state.inventory.meals == 3 and game.state.has("fed_bramm"), "One packed meal shared")
    verify(game.speech.speaker == game.npcs.bramm and game.state.relationships.bramm.friendship == 1, "Father responds in the world")
    game.story.action("feed_bramm")
    verify(game.state.inventory.meals == 3, "No duplicate gift")
    var loaded := State.new()
    verify(loaded.load_game() and loaded.has("fed_bramm") and loaded.inventory.meals == 3, "Gift persists on reload")
    game.prepare_exit()
    game.queue_free()
    await process_frame
    print("Family supper: ", "FAIL" if failed else "PASS")
    quit(1 if failed else 0)
