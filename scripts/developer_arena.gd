extends "res://scripts/chapter/chapter.gd"
## The chapter owns attack contact, movement, damage, parries and enemy AI.
## The yard supplies actors, disposable state and its own small set of controls.
class PracticeState extends ChapterState:
    func load_game() -> bool:
        return false

    func save_game() -> bool:
        return false

class Clearing extends OgreTerrain:
    func _ready() -> void:
        super._ready()
        # Soft verges between the cart track, trampled center and surrounding grass.
        mask_image = Image.create(224, 88, false, Image.FORMAT_RGB8)
        for x in mask_image.get_width():
            var path_y := 29.0 + 2.5 * sin(x * 0.085)
            for y in mask_image.get_height():
                var tile := Vector2(x, y) * 0.5
                var clearing := (tile - Vector2(33, 27)) / Vector2(15, 6)
                var verge := 0.08 * sin(tile.x * 0.74) + 0.06 * cos(tile.y * 1.16)
                var earth := 1.0 - smoothstep(0.73, 1.12, clearing.length() + verge)
                var track := 1.0 - smoothstep(0.6, 2.2, absf(tile.y - path_y) + verge)
                mask_image.set_pixel(x, y, Color(maxf(earth, track * 0.76), 0, 0))
        mask_texture = ImageTexture.create_from_image(mask_image)
        material.set_shader_parameter("terrain_mask", mask_texture)
        last_revision = state.revision

const START := Vector2(1060, 990)

var practice_trees: Array[Node2D] = []
var practice_hud: CanvasLayer

func _ready() -> void:
    state = PracticeState.new()
    configure_movement()
    var turf := Clearing.new()
    turf.state = GroundState.new()
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
    var treeline := [Vector2(240,670), Vector2(380,614), Vector2(562,630), Vector2(785,450),
        Vector2(930,540), Vector2(1190,494), Vector2(1350,475), Vector2(1580,600),
        Vector2(1770,696), Vector2(1840,875), Vector2(1990,1010), Vector2(1770,1320),
        Vector2(1570,1380), Vector2(690,1410), Vector2(468,1375), Vector2(275,1135)]
    var foliage := [Color("ceb588"), Color("e2c293"), Color("a7b28b")]
    for i in treeline.size():
        var tree := world_prop("tree", treeline[i])
        tree.modulate = foliage[i % foliage.size()]
        tree.scale = Vector2.ONE * (0.9 + 0.12 * (i % 4))
        practice_trees.append(tree)
    var sapling := world_prop("tree", Vector2(1215, 690))
    sapling.scale = Vector2.ONE * 0.69
    sapling.modulate = Color("e4c59b")
    practice_trees.append(sapling)
    world_prop("log", Vector2(1260, 685))
    sfx = AudioStreamPlayer.new()
    sfx.volume_db = -16
    add_child(sfx)
    add_raider("practice_goblin", START + Vector2(-203, -25), "goblin")
    add_raider("practice_raider", START + Vector2(330, -120), "orc")
    practice_hud = CanvasLayer.new()
    add_child(practice_hud)
    var box := panel(Vector2(22, 18), Vector2(1180, 132))
    practice_hud.add_child(box)
    var lines := VBoxContainer.new()
    box.add_child(lines)
    hud = helper.words("", 20)
    lines.add_child(hud)
    lines.add_child(helper.words("WASD move   LMB strike   RMB guard   Space dodge   Tab weapon   H/B armor   V effects   F2 HUD   R reset   Esc title", 16))
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
    player.track_combat_aim(aim, nearby_threat())
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
        KEY_V:
            combat_effects_enabled = not combat_effects_enabled
            player.hit_flash_enabled = combat_effects_enabled
            for foe in enemies:
                foe.hit_flash_enabled = combat_effects_enabled
            say("Combat effects on." if combat_effects_enabled else "Combat effects off.")
        KEY_F2:
            practice_hud.visible = not practice_hud.visible
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

func strike_scenery(actor) -> bool:
    if actor.equipped_weapon != "hunting_axe":
        return false
    var hit := false
    for tree in practice_trees:
        var offset: Vector2 = tree.position - actor.position
        if tree.data.state != "intact" or not in_strike_path(actor, offset, 14.0):
            continue
        var ray := PhysicsRayQueryParameters2D.create(actor.position, tree.position, 1)
        ray.exclude = [tree.body.get_rid()]
        if get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
            tree.data.state = "felled"
            tree.refresh()
            hit = true
    return hit

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
