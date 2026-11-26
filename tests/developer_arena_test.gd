extends SceneTree
const ARENA := "res://scenes/developer_arena.tscn"
const SLOT = preload("res://scripts/chapter/state.gd").SAVE
var failures := 0
var checks := 0

func _initialize() -> void:
    run.call_deferred()

func check(condition: bool, message: String) -> void:
    checks += 1
    if not condition:
        failures += 1
        push_error(message)

func settle(count: int) -> void:
    for i in count:
        await physics_frame

func key(code: Key) -> void:
    var event := InputEventKey.new()
    event.keycode = code
    event.pressed = true
    current_scene._unhandled_input(event)

func run() -> void:
    # The release suites run with a disposable user-data directory.
    DirAccess.remove_absolute(SLOT)
    change_scene_to_file(ARENA)
    await settle(8)
    if not is_instance_valid(current_scene) or not current_scene.has_method("player_strike"):
        push_error("Practice scene failed to start")
        quit(1)
        return
    var yard = current_scene
    check(not FileAccess.file_exists(SLOT), "First practice entry did not create a campaign")
    check(yard.player.get_script() == preload("res://scripts/chapter/actor.gd"), "Arena uses campaign player")
    check(yard.enemies.size() == 2, "Two opponents enter the yard")
    var sentinel := FileAccess.open(SLOT, FileAccess.WRITE)
    sentinel.store_string("existing campaign sentinel")
    sentinel.close()
    for foe in yard.enemies:
        foe.active = false
    yard.player.position = yard.enemies[0].position + Vector2(80, 0)
    check(yard.player.attack(Vector2.LEFT), "Campaign attack accepted")
    check(yard.player.sprite.texture.resource_path == "res://assets/chapter/player_axe_side_swing.png", "First arena strike uses authored axe drawings before any weapon swap")
    await settle(50)
    check(yard.enemies[0].hp == 0, "One clean axe strike fells exposed target")
    var goblin = yard.enemies[0]
    check(goblin.cleaved and goblin.sprite.region_rect == goblin.RECTS[1][2], "A clean axe hit selects the illustrated split at contact")
    goblin.active = true
    await settle(25)
    check(goblin.sprite.region_rect == goblin.RECTS[1][5], "The severed target finishes its fall")
    yard.state.gore = false
    await settle(2)
    check(goblin.sprite.region_rect == goblin.RECTS[0][5], "Restrained presentation uses the intact fall")
    check(yard.enemies[1].hp == yard.enemies[1].maximum, "Distant target untouched")
    key(KEY_TAB)
    check(yard.player.equipped_weapon == "iron_maul", "Practice loadout swaps to the campaign maul")
    yard.player.position = yard.enemies[1].position - Vector2(80, 0)
    check(yard.player.attack(Vector2.RIGHT), "Maul attack accepted")
    await settle(60)
    check(yard.enemies[1].hp == yard.enemies[1].maximum - yard.player.weapon_damage(), "Raider survives one clean maul strike")
    check(not yard.state.save_game() and not yard.state.load_game(), "Practice state refuses disk access")
    for i in 2:
        key(KEY_R)
        await settle(8)
        yard = current_scene
        check(yard.player.position == yard.START and yard.enemies.size() == 2, "Reset restores encounter")
        check(yard.player.equipped_weapon == "hunting_axe" and yard.enemies[0].hp == 28 and yard.enemies[1].hp == yard.enemies[1].maximum, "Reset restores loadout and foes")
    yard.enemies[0].active = false
    yard.player.position = yard.enemies[0].position + Vector2(80, 0)
    key(KEY_TAB)
    check(yard.player.attack(Vector2.LEFT), "Maul swing at the unarmored target starts")
    await settle(60)
    check(yard.enemies[0].hp <= 0 and not yard.enemies[0].cleaved, "Blunt contact uses the intact fall")
    key(KEY_ESCAPE)
    await settle(8)
    check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Exit returns to title")
    check(FileAccess.get_file_as_string(SLOT) == "existing campaign sentinel", "Campaign bytes survived practice, resets and exit")
    print("Developer Arena: %d checks, %d failures" % [checks, failures])
    quit(1 if failures else 0)
