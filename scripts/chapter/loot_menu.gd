extends RefCounted
## Item comparisons are computed from the same loadout totals used by combat.
var game
var chest := false
var by_name := false
var selected := ""
var message := ""

func _init(owner) -> void:
    game = owner

func show_menu(at_chest := false) -> void:
    chest = at_chest and game.hearth_access()
    var loot = game.state.treasure
    var intro := "Level %d  ·  %d adventure XP     |     Gear slots %d / %d" % [loot.level(),loot.xp,loot.count("pack"),loot.capacity("pack")]
    if chest:
        intro += "     |     Chest %d / %d" % [loot.count("chest"),loot.capacity("chest")]
    var col: VBoxContainer = game.simple_menu("HEARTH CHEST" if chest else "HUNT SPOILS",intro)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation",20)
    col.add_child(row)
    var left := VBoxContainer.new()
    left.custom_minimum_size.x = 390
    row.add_child(left)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(390,222)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    left.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    var ids := []
    for id in loot.items:
        var place = loot.items[id].place
        if place in ["pack","worn"] or (chest and place == "chest"):
            ids.append(id)
    ids.sort_custom(func(a,b):
        var x: Dictionary = loot.items[a]; var y: Dictionary = loot.items[b]
        if not by_name and x.rarity != y.rarity:
            return loot.DATA.data.rarities[x.rarity].rank > loot.DATA.data.rarities[y.rarity].rank
        var nx: String = loot.name_of(x); var ny: String = loot.name_of(y)
        return a < b if nx == ny else nx < ny)
    if not selected in ids:
        selected = ids.front() if not ids.is_empty() else ""
    var focus_button: Button
    for id in ids:
        var item: Dictionary = loot.items[id]
        var button: Button = game.helper.action("%s  ·  %s" % [loot.name_of(item),str(item.place).capitalize()],func(): select(id),list)
        button.add_theme_color_override("font_color",Color(loot.DATA.data.rarities[item.rarity].color))
        if id == selected:
            focus_button = button
    if focus_button != null:
        scroll.ensure_control_visible.call_deferred(focus_button)
    else:
        list.add_child(game.helper.words("Your first hunt can yield wearable gear.",17))
    game.helper.action("Sort by rarity" if by_name else "Sort by name",func(): by_name = not by_name; show_menu(chest),left)
    var detail := VBoxContainer.new()
    detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(detail)
    if selected != "":
        var item: Dictionary = loot.items[selected]
        var info: Dictionary = loot.DATA.data.rarities[item.rarity]
        var base: Dictionary = loot.base_of(item)
        detail.add_child(game.helper.words(loot.name_of(item),23,info.color))
        detail.add_child(game.helper.words("%s  ·  Level %d  ·  %s" % [info.label,item.level,base.label],17))
        var bonus: Dictionary = loot.stats(item)
        var old: String = loot.worn(base.slot)
        var old_label: String = str(game.state.equipment[base.slot]).replace("_"," ").capitalize()
        if base.slot == "head":
            old_label = game.state.HEADGEAR[game.player.equipped_head]
        elif base.slot == "body":
            old_label = game.state.BODYGEAR[game.player.equipped_body]
        if old != "": old_label = loot.name_of(loot.items[old])
        detail.add_child(game.helper.words("Equipped · " + old_label,16))
        detail.add_child(game.helper.words("Item bonuses   +%d strike   +%d armor" % [bonus.damage,bonus.guard],16))
        var current: Dictionary = loot.totals()
        var next: Dictionary = loot.totals(base.slot,item)
        var weapon_base: float = game.player.weapon_damage(game.state.has("honed_axe"))
        var after_weapon := weapon_base
        if base.slot == "weapon":
            after_weapon = float(game.player.WEAPONS.data[base.visual].damage)
            if base.visual == "hunting_axe" and game.state.has("honed_axe"):
                after_weapon += 8
        var meal_bonus := 6 if game.state.fed > 0 else 0
        var old_damage := int(weapon_base) + int(current.damage) + meal_bonus
        var new_damage := int(after_weapon) + int(next.damage) + meal_bonus
        detail.add_child(game.helper.words("Strike %d → %d   ·   Armor %d → %d" % [old_damage,new_damage,current.guard,next.guard],19))
        if base.slot == "weapon":
            detail.add_child(game.helper.words("Swing %.2f s → %.2f s" % [game.player.WEAPONS.data[game.player.equipped_weapon].swing_seconds,game.player.WEAPONS.data[base.visual].swing_seconds],16))
        if not chest:
            game.fitting_preview(row,138,142,item)
        if item.rarity == "set":
            detail.add_child(game.helper.words("Cairnwatch  %d/2 if worn  ·  +2 armor at 2/2." % next.set_count,16))
        elif item.special == "red_hart":
            detail.add_child(game.helper.words("The Hart's antlers grant +3 strike.",17))
        var actions := HBoxContainer.new()
        detail.add_child(actions)
        if item.place == "pack":
            var equip: Button = game.helper.action("Equip" if loot.level() >= item.level else "Requires level %d" % item.level,wear,actions)
            equip.disabled = loot.level() < item.level or not game.can_change_equipment()
            if chest:
                game.helper.action("Store",func(): transfer("pack","chest"),actions)
        elif item.place == "chest":
            game.helper.action("Take",func(): transfer("chest","pack"),actions)
        if chest and item.place != "worn":
            var dispose := HBoxContainer.new()
            detail.add_child(dispose)
            game.helper.action("Sell · %d coin" % price(item),func(): exchange(false),dispose)
            game.helper.action("Salvage · 1 ore",func(): exchange(true),dispose)
    if message != "":
        col.add_child(game.helper.words(message,16))
    if chest:
        var options := HBoxContainer.new()
        col.add_child(options)
        game.helper.action("Supply stacks",show_stores,options)
        if not loot.pack_upgrade:
            game.helper.action("Sew pack · 2 hides",func(): expand(true),options)
        if not loot.chest_upgrade:
            game.helper.action("Expand chest · 4 timber",func(): expand(false),options)
        if game.state.inventory.amber > 0:
            game.helper.action("Sell amber · 4 coin each",sell_amber,options)
    game.helper.action("Return",game.close_modal if chest else game.belongings,col)

func select(id: String) -> void:
    selected = id
    message = ""
    show_menu(chest)

func wear() -> void:
    if not game.can_change_equipment():
        return
    var loot = game.state.treasure
    if loot.equip(selected):
        var base: Dictionary = loot.base_of(loot.items[selected])
        game.apply_equipment(base.slot,base.visual)
        game.save_progress()
        game.belongings()

func transfer(origin: String, target: String) -> void:
    if not chest or not game.hearth_access():
        return
    message = "Moved to %s." % target if game.state.treasure.move(selected,origin,target) else "No free slots."
    game.save_progress()
    show_menu(true)

func price(item: Dictionary) -> int:
    return 2 + int(game.state.treasure.DATA.data.rarities[item.rarity].rank) * 2 + int(item.quality)

func exchange(salvage: bool) -> void:
    if not chest or not game.hearth_access():
        return
    var loot = game.state.treasure
    var item: Dictionary = loot.items.get(selected,{})
    if item.get("place","") not in ["pack","chest"]:
        return
    if salvage:
        game.state.inventory.ore += 1
    else:
        game.state.inventory.coin += price(item)
    loot.items.erase(selected)
    selected = ""
    message = "Recovered one ore." if salvage else "Coin added to your purse."
    game.save_progress()
    show_menu(true)

func expand(pack: bool) -> void:
    if not chest or not game.hearth_access():
        return
    var loot = game.state.treasure
    if pack and not loot.pack_upgrade and game.state.pay({"hide":2}):
        loot.pack_upgrade = true
        message = "Six more gear slots in your pack."
    elif not pack and not loot.chest_upgrade and game.state.pay({"wood":4}):
        loot.chest_upgrade = true
        message = "Sixteen more gear slots at the Hearth."
    else:
        message = "You need two hides." if pack else "You need four timber."
    game.save_progress()
    show_menu(true)

func sell_amber() -> void:
    if chest and game.hearth_access() and game.state.pay({"amber":1}):
        game.state.inventory.coin += 4
        message = "Sold one bead of amber for four coin."
        game.save_progress()
        show_menu(true)


func show_stores() -> void:
    if not game.hearth_access():
        return
    var loot = game.state.treasure
    var col: VBoxContainer = game.simple_menu("HEARTH STORES","Each supply has its own stack. Move a stack between the wagon and your pack.")
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size.y = 295
    col.add_child(scroll)
    var rows := VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(rows)
    for kind in loot.SUPPLIES:
        var carried := int(game.state.inventory.get(kind,0))
        var stored := int(loot.stores.get(kind,0))
        if carried == 0 and stored == 0: continue
        var row := HBoxContainer.new()
        rows.add_child(row)
        var label: Label = game.helper.words("%s    Pack %d  ·  Chest %d" % [str(kind).replace("_"," ").capitalize(),carried,stored],18)
        label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(label)
        if carried > 0: game.helper.action("Store stack",func(): move_stack(kind,true),row)
        if stored > 0: game.helper.action("Take stack",func(): move_stack(kind,false),row)
    if rows.get_child_count() == 0:
        rows.add_child(game.helper.words("The supply bins are empty.",17))
    game.helper.action("Back to gear",func(): show_menu(true),col)

func move_stack(kind: String, deposit: bool) -> void:
    var loot = game.state.treasure
    if not game.hearth_access() or kind not in loot.SUPPLIES: return
    var source: Dictionary = game.state.inventory if deposit else loot.stores
    var target: Dictionary = loot.stores if deposit else game.state.inventory
    var amount := mini(int(source.get(kind,0)),100000-int(target.get(kind,0)))
    if amount <= 0: return
    source[kind] -= amount
    target[kind] = int(target.get(kind,0)) + amount
    game.save_progress()
    show_stores()
