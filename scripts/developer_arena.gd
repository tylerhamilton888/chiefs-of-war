extends "res://scripts/chapter/chapter.gd"
## The chapter owns attack contact, movement, damage, parries and enemy AI.
## The yard supplies actors, disposable state and its own small set of controls.
class PracticeState extends ChapterState:
    func load_game() -> bool:
        return false

    func save_game() -> bool:
        return false

const START := Vector2(1060, 990)

func _ready() -> void:
    state = PracticeState.new()
    configure_movement()
    var ground := GroundState.new()
    for x in range(14, 54):
        for y in range(18, 38):
            ground.terrain["%d,%d" % [x, y]] = "earth"
    var turf := OgreTerrain.new()
    turf.state = ground
    turf.z_index = -2
    add_child(turf)
    world = Node2D.new()
    world.y_sort_enabled = true
    add_child(world)
    player = Actor.new()
    player.position = START
    player.game = self
    player.struck.connect(player_strike)
    player.felled.connect(player_felled)
    player.stepped.connect(func(): play_sound("step"))
    world.add_child(player)
    camera = OgreCamera.new()
    player.add_child(camera)
    wagon(Vector2(640, 557), 0.55)
    tent(Vector2(1470, 551), 0.48)
    build_pot(Vector2(1040, 790), "yard")
    for at in [Vector2(430, 817), Vector2(1710, 1110), Vector2(450, 1150)]:
        world_prop("rock", at)
    sfx = AudioStreamPlayer.new()
    sfx.volume_db = -16
    add_child(sfx)
    add_raider("practice_goblin", START + Vector2(-203, -25), "goblin")
    add_raider("practice_raider", START + Vector2(330, -120), "orc")
    var layer := CanvasLayer.new()
    add_child(layer)
    var box := panel(Vector2(22, 18), Vector2(1180, 132))
    layer.add_child(box)
    var lines := VBoxContainer.new()
    box.add_child(lines)
    hud = helper.words("", 20)
    lines.add_child(hud)
    lines.add_child(helper.words("WASD move    LMB strike    RMB guard    Space dodge    Tab weapon    H helm    B mantle    R reset    Esc title", 16))
    prompt = helper.words("", 17, "efcc88")
    lines.add_child(prompt)
    notice = helper.words("The goblin approaches from the left. One clean axe hit leaves a cut for the cookpot.", 15, "e3bb78")
    lines.add_child(notice)
    if "--startup-smoke" in OS.get_cmdline_user_args():
        get_tree().create_timer(2.0).timeout.connect(quit_game)

func _process(delta: float) -> void:
    state.fed = maxf(0.0, state.fed - delta)
    update_nearest()
    if player.hp <= 0:
        prompt.text = ""
    else:
        var fallback := "Carry a cut to the cookpot north of the starting spot." if state.inventory.goblin_meat else ""
        prompt.text = interaction_prompt(fallback)

    hud.text = "Practice Yard   ·   %s   ·   %s   ·   %s   ·   Health %d / 160" % [Actor.WEAPONS.data[player.equipped_weapon].label, ChapterState.HEADGEAR[player.equipped_head], ChapterState.BODYGEAR[player.equipped_body], ceili(player.hp)]
    if state.inventory.goblin_meat or state.inventory.meals:
        hud.text += "   ·   Cuts %d   ·   Meals %d" % [state.inventory.goblin_meat, state.inventory.meals]
    var aim := get_global_mouse_position() - player.position
    player.track_combat_aim(aim, true)
    player.block(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT), aim)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        player.attack(get_global_mouse_position() - player.position)
    if not event is InputEventKey or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_E:
            if player.hp > 0 and not nearest.is_empty():
                interact(nearest)
        KEY_F, KEY_C:
            use_food_shortcut(event.keycode)
        KEY_Q:
            if player.hp > 0:
                state.hp = player.hp
                if state.eat():
                    player.hp = state.hp
                    say("Goblin stew restores up to 65 health. Well fed for three minutes.")
                else:
                    say("Ladle a portion from the cookpot first.")
        KEY_R:
            get_tree().reload_current_scene()
        KEY_ESCAPE:
            get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        KEY_SPACE:
            player.dodge(Input.get_vector("move_left", "move_right", "move_up", "move_down"))
        KEY_B:
            if can_change_equipment():
                player.equip_body("scale_mantle" if player.equipped_body == "fur" else "fur")
        KEY_H:
            if can_change_equipment():
                player.equip_head("iron_helm" if player.equipped_head == "bare" else "bare")
        KEY_TAB:
            if can_change_equipment():
                player.equip_weapon("iron_maul" if player.equipped_weapon == "hunting_axe" else "hunting_axe")

func enemy_slain(foe) -> void:
    super.enemy_slain(foe)
    if foe is Raider and foe.cleaved:
        return
    if enemies.all(func(enemy): return enemy.hp <= 0):
        say("Yard cleared. Press R for a fresh encounter.")
    else:
        say("One opponent remains.")

func player_felled(_actor) -> void:
    for foe in enemies:
        foe.active = false
    say("Downed. Press R to reset the yard.")

func quit_game() -> void:
    get_tree().quit()
