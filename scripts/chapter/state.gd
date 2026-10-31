extends RefCounted
## Chapter saves are independent of both original campaigns and the 0.6 Ogre visit.
const SAVE="user://fire_we_carry_v1.json"
const REGIONS=["crossing","pines","hollow","cairn","pass","host","trade"]
const PEOPLE=["bramm","svala","gorund","dorrik","astrid","hrothgar","thyra","runa","eydis"]
const AXES=["friendship","admiration","rivalry","loyalty","interest"]
var region="crossing"
var player_position=Vector2(960,920)
var chapter=0
var flags: Dictionary={}
var inventory={"wood":0,"meat":0,"meals":0,"hide":0,"ore":0,"coin":0,"trophy":0}
var relationships: Dictionary={}
var scene: Dictionary={}
var collected: Array=[]
var defeated: Array=[]
var hp=160.0
var fed=0.0
var clock=0.0
var defense_left=100.0
var unreadable=false
var gore=false
var camp_region="host"
func _init() -> void:
    for id in PEOPLE:
        relationships[id]={"met":false,"friendship":0,"admiration":0,"rivalry":0,"loyalty":0,"interest":0,"courting":false}
func has(id: String) -> bool:return bool(flags.get(id,false))
func mark(id: String) -> void:flags[id]=true
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
    return {"version":1,"region":region,"position":[player_position.x,player_position.y],"chapter":chapter,"flags":flags,"inventory":inventory,"relationships":relationships,"scene":scene,"collected":collected,"defeated":defeated,"hp":hp,"fed":fed,"clock":clock,"defense_left":defense_left,"gore":gore,"camp_region":camp_region}
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
    region=d.region;player_position=Vector2(d.position[0],d.position[1]);chapter=int(d.chapter)
    flags=d.flags;inventory=d.inventory;relationships=d.relationships;scene=d.scene
    collected=d.collected;defeated=d.defeated;hp=d.hp;fed=d.fed;clock=d.clock;defense_left=d.defense_left;gore=d.gore;camp_region=d.camp_region
    return true
func number(value,low: float,high: float) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and value>=low and value<=high
func valid(d) -> bool:
    if not d is Dictionary:return false
    for key in pack():
        if not d.has(key):return false
    if d.version!=1 or not d.region in REGIONS or not d.camp_region in REGIONS or not number(d.chapter,0,10) or d.chapter!=int(d.chapter):return false
    if not d.position is Array or d.position.size()!=2 or not number(d.position[0],60,2200) or not number(d.position[1],60,1330):return false
    if not d.inventory is Dictionary or not d.flags is Dictionary or not d.relationships is Dictionary or not d.scene is Dictionary:return false
    for item in inventory:
        if not d.inventory.has(item) or not number(d.inventory[item],0,100000) or d.inventory[item]!=int(d.inventory[item]):return false
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
    if not d.scene.is_empty():
        if not d.scene.get("key",null) is String or not number(d.scene.get("cursor",-1),0,20):return false
    return number(d.hp,0,160) and number(d.fed,0,180) and number(d.clock,0,10000000) and number(d.defense_left,0,100) and d.gore is bool
