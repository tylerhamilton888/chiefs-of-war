extends SceneTree

const State = preload("res://scripts/chapter/state.gd")
const Treasure = preload("res://scripts/chapter/treasure.gd")
var game
var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)

func press(label: String) -> void:
    for button in game.modal.find_children("*","Button",true,false):
        if button.text == label and button.is_visible_in_tree() and not button.disabled:
            button.pressed.emit()
            return
    check(false,"Missing action " + label)

func interact(kind: String, id := "") -> void:
    for entry in game.stations:
        if entry.kind == kind and (id == "" or entry.id == id):
            game.interact(entry)
            return
    check(false,"Missing station " + kind)

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    var roll := Treasure.new()
    roll.rng.seed = 19
    var tiers := {}
    var qualities := {}
    var skipped := 0
    for i in 2500:
        var item := roll.roll("raider")
        if item.is_empty():
            skipped += 1
        else:
            tiers[item.rarity] = true
            qualities[item.quality] = true
    check(tiers.size() == 5 and qualities.size() == 2 and skipped > 1250,"Random pool includes specials, both qualities and predominantly supply-only encounters")
    var legacy: Dictionary = State.new().pack()
    legacy.erase("treasure")
    legacy.inventory.erase("amber")
    check(State.new().valid(legacy),"Existing saves may omit loot and amber")
    DirAccess.remove_absolute(State.SAVE)
    check(State.new().create_journey(State.DEFAULT_PROFILE),"Start through the new-character save path")
    game = load("res://scenes/fire_we_carry.tscn").instantiate()
    root.add_child(game)
    current_scene = game
    await physics_frame
    game.choose("work")
    game.state.chapter = 2
    game.travel("pines")
    var wolf = game.enemies[0]
    var id: String = wolf.get_meta("id")
    wolf.receive_hit(500,Vector2.DOWN)
    interact("harvest",id)
    var loot = game.state.treasure
    var first: Dictionary = loot.items[id].duplicate(true)
    check(first.level == 1 and loot.stats(first).guard > 0 and game.state.inventory.amber == 1,"First harvest guarantees an eligible improvement and amber")
    check(game.state.inventory.meat >= 6 and game.state.inventory.hide == 2,"Quarry also supplies the feast and pack upgrade")
    interact("harvest",id)
    check(loot.items.size() == 1 and game.state.inventory.amber == 1,"Duplicate harvest cannot generate another reward")
    game.belongings()
    press("Compare hunt spoils")
    press("Equip")
    var preview = game.modal.find_child("EquippedOgre",true,false)
    check(game.player.equipped_head == "iron_helm" and preview.equipped_head == "iron_helm","Player and fitting preview visibly equip the find")
    var saved := State.new()
    check(saved.load_game() and saved.treasure.items[id].quality == first.quality and saved.treasure.worn("head") == id,"Saved quality, identity and worn state survive reload")
    var broken: Dictionary = saved.pack().duplicate(true)
    broken.treasure.items[id].quality = -7
    check(not saved.valid(broken),"Reject invalid rolled stat")
    game.close_modal()
    game.travel("crossing")
    interact("chest")
    press("Sew pack · 2 hides")
    check(loot.capacity("pack")==12 and game.state.inventory.hide==0,"Pack expansion consumes harvested hides")
    press("Sell amber · 4 coin each")
    check(game.state.inventory.amber==0 and game.state.inventory.coin==4,"Amber produces spendable coin")
    press("Supply stacks")
    game.loot_menu.move_stack("meat",true)
    check(game.state.inventory.meat == 0 and loot.stores.meat >= 6,"Store provisions")
    game.loot_menu.move_stack("meat",false)
    check(game.state.inventory.meat >= 6,"Retrieve provisions for the feast")
    game.close_modal()
    game.grant_find("test_crown","raider",game.player.position,"","red_hart")
    check(not loot.equip("test_crown"),"Legendary has a real level requirement")
    loot.xp = 8
    for special in ["watch_helm","watch_mantle"]:
        game.grant_find(special,"raider",game.player.position,"",special)
        game.loot_menu.selected = special
        game.loot_menu.wear()
    var expected: int = loot.stats(loot.items.watch_helm).guard + loot.stats(loot.items.watch_mantle).guard
    check(loot.totals().set_count == 2 and loot.totals().guard == expected + 2,"Two-piece set adds armor")
    check(game.player.head_gear.piece.texture is ImageTexture and game.player.body_gear.piece.texture is ImageTexture,"Set uses two marked fitted sheets")
    game.loot_menu.selected = "test_crown"
    game.loot_menu.wear()
    check(loot.totals().set_count==1 and loot.worn("head")=="test_crown","Legendary replaces head piece and removes set bonus")
    game.close_modal()
    interact("chest")
    game.loot_menu.selected = "watch_helm"
    game.loot_menu.transfer("pack","chest")
    check(loot.items.watch_helm.place=="chest","Store an individual roll")
    game.loot_menu.exchange(true)
    check(not loot.items.has("watch_helm") and game.state.inventory.ore == 1,"Salvage consumes the stored instance exactly once")
    game.close_modal()
    for i in loot.capacity("pack") - loot.count("pack"):
        game.grant_find("fill_%d"%i,"wolf",game.player.position,"road_helm")
    game.grant_find("overflow","wolf",game.player.position,"road_helm")
    var overflow: Dictionary = loot.items.overflow.duplicate(true)
    check(overflow.place=="field","Full pack keeps a world find")
    game.rebuild()
    interact("field_find","overflow")
    check(loot.items.overflow == overflow,"Failed pickup preserves the roll")
    interact("chest")
    game.loot_menu.selected = "fill_0"
    game.loot_menu.transfer("pack","chest")
    game.close_modal()
    interact("field_find","overflow")
    check(loot.items.overflow.place=="pack" and loot.items.overflow.quality==overflow.quality,"Revisited field find retains its identity and can be picked up")
    check(saved.load_game() and saved.treasure.count("pack")==12 and saved.treasure.count("chest")==1,"All storage locations reload together")
    game.prepare_exit()
    await create_timer(.2).timeout
    game.queue_free()
    await process_frame
    print("CHAPTER LOOT: %d checks, %d failures" % [checks,failures])
    quit(1 if failures else 0)
