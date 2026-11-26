extends RefCounted
## One saved roll per encounter, keyed by the chapter's stable encounter ID.
const DATA = preload("res://resources/chapter/loot.json")
const REGIONS = ["crossing","pines","hollow","cairn","pass","host","trade"]
var items: Dictionary = {}
const SUPPLIES = ["wood","meat","meals","hide","ore","trophy","goblin_meat","amber"]
var stores: Dictionary = {}
var xp := 0
var pack_upgrade := false
var chest_upgrade := false
var rng := RandomNumberGenerator.new()

func level() -> int:
    return 1 + int(xp >= 3) + int(xp >= 8)

func capacity(place: String) -> int:
    if place == "pack":
        return 12 if pack_upgrade else 6
    return 32 if chest_upgrade else 16

func count(place: String) -> int:
    var total := 0
    for item in items.values():
        if item.place == place:
            total += 1
    return total

func roll(source: String, first_visual: String = "", promised: String = "") -> Dictionary:
    var table: Dictionary = DATA.data.tables[source]
    var special := promised
    var base: String = first_visual
    var rarity := "fine"
    if special == "" and base == "":
        if rng.randf() >= float(table.gear_chance):
            return {}
        var r := rng.randf()
        if r < 0.025:
            special = "red_hart"
        elif r < 0.16:
            special = ["watch_helm","watch_mantle"][rng.randi_range(0,1)]
        else:
            base = table.bases[rng.randi_range(0,table.bases.size()-1)]
            rarity = "rare" if r < 0.30 else ("fine" if r < 0.70 else "common")
    var required := 1
    if special != "":
        var identity: Dictionary = DATA.data.specials[special]
        base = identity.base
        rarity = identity.rarity
        required = int(identity.level)
    elif rarity == "rare":
        required = 2
    var affix := ""
    if rarity != "common":
        affix = ["stout","keen"][rng.randi_range(0,1)]
    return {"base":base,"rarity":rarity,"quality":rng.randi_range(1,2),"affix":affix,
        "value":rng.randi_range(1,2) if affix != "" else 0,"level":required,"special":special}

func award(id: String, source: String, region: String, at: Vector2, first_visual := "", promised := "") -> String:
    if items.has(id):
        return ""
    var item := roll(source, first_visual, promised)
    if item.is_empty():
        return ""
    item.place = "pack" if count("pack") < capacity("pack") else "field"
    item.region = region
    item.at = [clampf(at.x,60,2200),clampf(at.y,60,1330)]
    items[id] = item
    return id

func base_of(item: Dictionary) -> Dictionary:
    return DATA.data.bases[item.base]

func name_of(item: Dictionary) -> String:
    if item.special != "":
        return DATA.data.specials[item.special].label
    var prefix := ""
    if item.affix != "":
        prefix = DATA.data.affixes[item.affix].label + " "
    return prefix + str(base_of(item).label)

func stats(item: Dictionary) -> Dictionary:
    var result := {"damage":0,"guard":0}
    var base := base_of(item)
    result[base.stat] = int(base.base) + int(item.quality)
    if item.affix != "":
        var stat: String = DATA.data.affixes[item.affix].stat
        result[stat] += int(item.value)
    if item.special == "red_hart":
        result.damage += 3
    return result

func worn(slot: String) -> String:
    for id in items:
        if items[id].place == "worn" and base_of(items[id]).slot == slot:
            return id
    return ""

func totals(replace_slot := "", candidate: Dictionary = {}) -> Dictionary:
    var result := {"damage":0,"guard":0,"set_count":0}
    for slot in ["weapon","head","body"]:
        var item: Dictionary = candidate if slot == replace_slot else items.get(worn(slot), {})
        if item.is_empty():
            continue
        var bonuses := stats(item)
        result.damage += bonuses.damage
        result.guard += bonuses.guard
        if item.special in ["watch_helm","watch_mantle"]:
            result.set_count += 1
    if result.set_count == 2:
        result.guard += 2
    return result

func equip(id: String) -> bool:
    var item: Dictionary = items.get(id,{})
    if item.is_empty() or item.place != "pack" or level() < int(item.level):
        return false
    var old := worn(base_of(item).slot)
    if old != "":
        items[old].place = "pack"
    item.place = "worn"
    return true

func move(id: String, origin: String, target: String) -> bool:
    if not items.has(id) or items[id].place != origin or target not in ["pack","chest"] or count(target) >= capacity(target):
        return false
    items[id].place = target
    return true

func pack() -> Dictionary:
    return {"stores":stores,"xp":xp,"pack_upgrade":pack_upgrade,"chest_upgrade":chest_upgrade,"items":items}

func restore(data: Dictionary) -> void:
    stores = data.get("stores",{}).duplicate()
    xp = int(data.xp)
    pack_upgrade = data.pack_upgrade
    chest_upgrade = data.chest_upgrade
    items = data.items.duplicate(true)

static func integer(v: Variant, low: int, high: int) -> bool:
    return (v is int or v is float) and v >= low and v <= high and v == int(v)

static func valid(data: Variant, equipment: Dictionary) -> bool:
    if not data is Dictionary or not integer(data.get("xp"),0,1000000) or not data.get("pack_upgrade") is bool or not data.get("chest_upgrade") is bool:
        return false
    if not data.get("items") is Dictionary or data.items.size() > 2100:
        return false
    if not data.get("stores",{}) is Dictionary:
        return false
    for kind in data.get("stores",{}):
        if kind not in SUPPLIES or not integer(data.stores[kind],0,100000):
            return false
    var slots := {}
    var amounts := {"pack":0,"chest":0}
    for id in data.items:
        var item = data.items[id]
        if not id is String or id.is_empty() or not item is Dictionary:
            return false
        if not DATA.data.bases.has(item.get("base")) or not DATA.data.rarities.has(item.get("rarity")):
            return false
        if not integer(item.get("quality"),1,2) or not integer(item.get("value"),0,2) or not integer(item.get("level"),1,3):
            return false
        if not item.get("affix") in ["","stout","keen"] or not item.get("special") in ["","red_hart","watch_helm","watch_mantle"]:
            return false
        if (item.affix == "") != (item.value == 0) or (item.rarity == "common") != (item.affix == ""):
            return false
        if item.special != "":
            var definition: Dictionary = DATA.data.specials[item.special]
            if definition.base != item.base or definition.rarity != item.rarity or definition.level != item.level:
                return false
        elif item.rarity in ["set","legendary"] or item.level != (2 if item.rarity == "rare" else 1):
            return false
        if not item.get("place") in ["worn","pack","field","chest"] or not item.get("region") in REGIONS:
            return false
        var at = item.get("at")
        if not at is Array or at.size()!=2 or not (at[0] is float or at[0] is int) or not (at[1] is float or at[1] is int):
            return false
        if not Rect2(59,59,2142,1272).has_point(Vector2(at[0],at[1])):
            return false
        if amounts.has(item.place):
            amounts[item.place] += 1
        if item.place == "worn":
            var base: Dictionary = DATA.data.bases[item.base]
            if slots.has(base.slot) or equipment.get(base.slot) != base.visual or item.level > 1 + int(data.xp>=3) + int(data.xp>=8):
                return false
            slots[base.slot] = true
    return amounts.pack <= (12 if data.pack_upgrade else 6) and amounts.chest <= (32 if data.chest_upgrade else 16)
