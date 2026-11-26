extends RefCounted
## Chapter saves are independent of both original campaigns and the 0.6 Ogre visit.
const SAVE="user://fire_we_carry_v1.json"
const REGIONS=["crossing","pines","hollow","cairn","pass","host","trade"]
const PEOPLE=["bramm","svala","gorund","dorrik","astrid","hrothgar","thyra","runa","eydis"]
const AXES=["friendship","admiration","rivalry","loyalty","interest"]
const WEAPONS = preload("res://resources/chapter/weapons.json")
const HEADGEAR = {"bare": "Bare head", "iron_helm": "Iron helm"}
const BODYGEAR = {"fur": "Fur mantle", "scale_mantle": "Scale mantle"}
const DEFAULT_EQUIPMENT = {"weapon": "hunting_axe", "head": "bare", "body": "fur"}
const HAIR = ["copper", "umber", "gold", "silver"]
const BACKGROUNDS = {
    "hunter": {"label": "Hunter", "item": "meat", "amount": 2},
    "drover": {"label": "Drover", "item": "hide", "amount": 2},
    "smith": {"label": "Smith", "item": "ore", "amount": 2},
}
const DEFAULT_PROFILE = {"ogre_name": "Hald", "clan_name": "Emberhide", "background": "hunter", "hair": "copper"}
const Treasure = preload("res://scripts/chapter/treasure.gd")
var treasure := Treasure.new()
var equipment: Dictionary = DEFAULT_EQUIPMENT.duplicate()
var profile: Dictionary = DEFAULT_PROFILE.duplicate()
var region="crossing"
var player_position=Vector2(960,920)
var chapter=0
var flags: Dictionary={}
var inventory={"wood":0,"meat":0,"meals":0,"hide":0,"ore":0,"coin":0,"trophy":0,"goblin_meat":0,"amber":0}
var relationships: Dictionary={}
var scene: Dictionary={}
var encounters: Dictionary={}
# Pending cuts store the ground position, so revisiting a kill never re-rolls its reward.
var field_cuts: Dictionary = {}
var pot_servings: Dictionary = {}
const RAW_CUT_HEAL := 25
const PORTIONS_PER_CUT := 2
var escort_x=430.0
var collected: Array=[]
var defeated: Array=[]
var hp=160.0
var fed=0.0
var clock=0.0
var defense_left=100.0
var unreadable=false
var gore=true
var camp_region="host"
func _init() -> void:
    for id in PEOPLE:
        relationships[id]={"met":false,"friendship":0,"admiration":0,"rivalry":0,"loyalty":0,"interest":0,"courting":false}
func has(id: String) -> bool:return bool(flags.get(id,false))
func mark(id: String) -> void:flags[id]=true
func set_weapon(id: String) -> void:
    if WEAPONS.data.has(id):
        equipment.weapon = id
        flags["equipped_iron_maul"] = id == "iron_maul"

func change(id: String,axis: String,amount: int) -> void:
    if id in relationships and axis in AXES:relationships[id][axis]=clampi(int(relationships[id][axis])+amount,-100,100)
func pay(cost: Dictionary) -> bool:
    for item in cost:
        if inventory.get(item,0)<cost[item]:return false
    for item in cost:inventory[item]-=cost[item]
    return true
func collect(id: String,item: String,amount: int) -> bool:
    if id in collected or not item in inventory:return false
    inventory[item]+=amount;collected.append(id);return true
func cook() -> bool:
    if not pay({"meat":2,"wood":1}):return false
    inventory.meals+=3;mark("cooked");return true
func eat() -> bool:
    if not pay({"meals":1}):return false
    hp=minf(160,hp+65);fed=180.0;mark("eaten");return true
func eligible(id: String) -> bool:
    return id in ["astrid","runa","eydis"] and has(id+"_activity") and relationships[id].admiration>=2
func pack() -> Dictionary:
    return {"treasure":treasure.pack(),"version":1,"profile":profile,"equipment":equipment,"region":region,"position":[player_position.x,player_position.y],"chapter":chapter,"flags":flags,"inventory":inventory,"relationships":relationships,"scene":scene,"collected":collected,"defeated":defeated,"hp":hp,"fed":fed,"clock":clock,"defense_left":defense_left,"gore":gore,"camp_region":camp_region,"encounters":encounters,"escort_x":escort_x,"field_cuts":field_cuts,"pot_servings":pot_servings}
func save_game() -> bool:
    if unreadable:return false
    var f=FileAccess.open(SAVE+".tmp",FileAccess.WRITE)
    if not f:return false
    f.store_string(JSON.stringify(pack(),"\t"));f.flush();var error=f.get_error();f.close()
    if error!=OK:return false
    return DirAccess.rename_absolute(SAVE+".tmp",SAVE)==OK
func load_game() -> bool:
    if not FileAccess.file_exists(SAVE):return true
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(SAVE))!=OK:unreadable=true;return false
    var d=parser.data
    if not valid(d):unreadable=true;return false
    profile = d.get("profile", DEFAULT_PROFILE).duplicate()
    region=d.region;player_position=Vector2(d.position[0],d.position[1]);chapter=int(d.chapter)
    flags=d.flags;inventory=d.inventory;relationships=d.relationships;scene=d.scene
    inventory.goblin_meat = int(inventory.get("goblin_meat", 0))
    inventory.amber = int(inventory.get("amber", 0))
    if d.has("treasure"):
        treasure.restore(d.treasure)
    field_cuts = d.get("field_cuts", {})
    pot_servings = d.get("pot_servings", {})
    if d.has("equipment"):
        equipment = DEFAULT_EQUIPMENT.duplicate()
        equipment.merge(d.equipment, true)
        set_weapon(equipment.weapon)
    else:
        equipment = DEFAULT_EQUIPMENT.duplicate()
        set_weapon("iron_maul" if has("equipped_iron_maul") else "hunting_axe")
    collected=d.collected;defeated=d.defeated;hp=d.hp;fed=d.fed;clock=d.clock;defense_left=d.defense_left;gore=d.gore;camp_region=d.camp_region;encounters=d.encounters;escort_x=d.escort_x
    return true
func number(value,low: float,high: float) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and value>=low and value<=high
func valid(d) -> bool:
    if not d is Dictionary:return false
    for key in pack():
        if key not in ["profile", "equipment", "field_cuts", "pot_servings", "treasure"] and not d.has(key):return false
    if d.has("equipment"):
        var gear = d.equipment
        if not gear is Dictionary or not WEAPONS.data.has(gear.get("weapon")) or not HEADGEAR.has(gear.get("head")):
            return false
        if not BODYGEAR.has(gear.get("body", DEFAULT_EQUIPMENT.body)):
            return false
    if d.has("treasure") and not Treasure.valid(d.treasure, d.get("equipment", DEFAULT_EQUIPMENT)):return false
    if d.has("profile") and not valid_profile(d.profile):return false
    if d.version!=1 or not d.region in REGIONS or not d.camp_region in REGIONS or not number(d.chapter,0,10) or d.chapter!=int(d.chapter):return false
    if not d.position is Array or d.position.size()!=2 or not number(d.position[0],60,2200) or not number(d.position[1],60,1330):return false
    if not d.inventory is Dictionary or not d.flags is Dictionary or not d.relationships is Dictionary or not d.scene is Dictionary:return false
    for item in inventory:
        if item in ["goblin_meat","amber"] and not d.inventory.has(item):continue
        if not d.inventory.has(item) or not number(d.inventory[item],0,100000) or d.inventory[item]!=int(d.inventory[item]):return false
    if not d.encounters is Dictionary or d.encounters.size()>200 or not number(d.escort_x,430,1810):return false
    for key in d.encounters:
        if not key is String or not number(d.encounters[key],0,10000):return false
    for value in d.flags.values():
        if not value is bool:return false
    for id in PEOPLE:
        if not d.relationships.has(id) or not d.relationships[id] is Dictionary:return false
        var rel=d.relationships[id]
        if not rel.get("met",null) is bool or not rel.get("courting",null) is bool:return false
        for axis in AXES:
            if not rel.has(axis) or not number(rel[axis],-100,100):return false
    for list in [d.collected,d.defeated]:
        if not list is Array or list.size()>2000:return false
        for item in list:
            if not item is String:return false
    if not valid_food_stores(d):return false
    if not d.scene.is_empty():
        if not d.scene.get("key",null) is String or not number(d.scene.get("cursor",-1),0,20):return false
    return number(d.hp,0,160) and number(d.fed,0,180) and number(d.clock,0,10000000) and number(d.defense_left,0,100) and d.gore is bool


static func valid_profile(value: Variant) -> bool:
    if not value is Dictionary:
        return false
    for key in ["ogre_name", "clan_name"]:
        var label = value.get(key)
        if not label is String or label.is_empty() or label.length() > 28 or label != label.strip_edges():
            return false
        for index in label.length():
            if label.unicode_at(index) < 32:
                return false
    return value.get("hair") in HAIR and value.get("background") in BACKGROUNDS

func create_journey(identity: Dictionary) -> bool:
    if FileAccess.file_exists(SAVE) or not valid_profile(identity):
        return false
    profile = identity.duplicate()
    mark("earn_hunt_armor")
    var gift: Dictionary = BACKGROUNDS[profile.background]
    inventory[gift.item] += gift.amount
    return save_game()

func valid_food_stores(d: Dictionary) -> bool:
    var cuts = d.get("field_cuts", {})
    if not cuts is Dictionary or cuts.size() > 200:
        return false
    for id in cuts:
        var at = cuts[id]
        if id not in d.defeated or not at is Array or at.size() != 2:
            return false
        if not number(at[0], 60, 2200) or not number(at[1], 60, 1330):
            return false
    var pots = d.get("pot_servings", {})
    if not pots is Dictionary:
        return false
    for site in pots:
        var amount = pots[site]
        if site not in ["crossing", "host", "trade", "home", "yard"] or not number(amount, 0, 100000) or int(amount) != amount:
            return false
    return true

func take_cut(id: String, eat_now: bool) -> bool:
    if not field_cuts.erase(id):
        return false
    if eat_now:
        hp = minf(160.0, hp + RAW_CUT_HEAL)
    else:
        inventory.goblin_meat += 1
    return true

func stew_cut(site: String) -> bool:
    if not pay({"goblin_meat": 1}):
        return false
    pot_servings[site] = pot_servings.get(site, 0) + PORTIONS_PER_CUT
    return true

func ladle_stew(site: String) -> bool:
    var portions := int(pot_servings.get(site, 0))
    if portions == 0:
        return false
    pot_servings[site] = portions - 1
    inventory.meals += 1
    return true
