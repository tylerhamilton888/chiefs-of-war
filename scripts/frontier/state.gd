extends RefCounted
## A separate durable regional ledger. Never migrates or overwrites narrative saves.
const SAVE="user://ogre_frontier_v1.json"
const REGIONS=["hearth","forest","den","pass","blackstone","dunmere","ridge"]
var region="hearth"
var player_position=Vector2(1080,1050)
var hp=180.0
var fed=0.0
var ferocity=0.0
var clock=0.0
var day=1
var gore=true
var unreadable=false
var inventory={"wood":2,"meat":0,"meals":2,"hide":0,"ore":0,"bone":0,"trophy":0,"coin":12}
var flags: Dictionary={}
var encounters: Dictionary={}
var objects: Dictionary={}
var cargo: Dictionary={}
var contracts: Dictionary={}
var reputation={"blackstone":{"reliability":0,"strength":0,"brutality":0,"treachery":0},"dunmere":{"reliability":0,"strength":0,"brutality":0,"treachery":0},"stonebelly":{"reliability":0,"strength":0,"brutality":0,"treachery":0}}
var regional={"pass_safe":false,"trade":0,"dunmere_prosperity":60,"dunmere_control":"local","dunmere_resistance":0,"protection":"none","last_tribute":0}
var animal={"name":"Flint","trust":0,"fed":0.0,"tamed":false,"harness":false,"command":"follow","cargo":{}}
var camp_region="hearth"
var packed=false
var equipment="axe"
var player_name="Ogre"
var appearance="copper"
const APPEARANCES=["copper","dark","gold","silver"]
func has(id: String) -> bool:return bool(flags.get(id,false))
func mark(id: String) -> void:flags[id]=true
func pay(cost: Dictionary) -> bool:
    for item in cost:
        if not item in inventory or cost[item]<0 or inventory[item]<cost[item]:return false
    for item in cost:inventory[item]-=int(cost[item])
    return true
func grant(rewards: Dictionary) -> void:
    for item in rewards:
        if item in inventory:inventory[item]=mini(100000,inventory[item]+int(rewards[item]))
func rep(faction: String,axis: String,amount: int) -> void:
    if faction in reputation and axis in reputation[faction]:reputation[faction][axis]=clampi(int(reputation[faction][axis])+amount,-100,100)
func cook() -> bool:
    if not pay({"meat":4,"wood":1}):return false
    inventory.meals+=4 if has("smoker") else 3;mark("cooked");return true
func eat() -> bool:
    if not pay({"meals":1}):return false
    hp=minf(180,hp+65);fed=300;mark("feasted");return true
func deliver(load: Dictionary) -> void:
    if load.is_empty():return
    grant(load.get("yield",{}));mark("transported");load.clear()
func pack() -> Dictionary:
    return {"version":1,"region":region,"position":[player_position.x,player_position.y],"hp":hp,"fed":fed,"ferocity":ferocity,"clock":clock,"day":day,"gore":gore,"inventory":inventory,"flags":flags,"encounters":encounters,"objects":objects,"cargo":cargo,"contracts":contracts,"reputation":reputation,"regional":regional,"animal":animal,"camp_region":camp_region,"packed":packed,"equipment":equipment,"player_name":player_name,"appearance":appearance}
func save_game() -> bool:
    if unreadable:return false
    var file=FileAccess.open(SAVE+".tmp",FileAccess.WRITE)
    if not file:return false
    file.store_string(JSON.stringify(pack(),"\t"));file.flush();var error=file.get_error();file.close()
    if error!=OK:return false
    return DirAccess.rename_absolute(SAVE+".tmp",SAVE)==OK
func load_game() -> bool:
    if not FileAccess.file_exists(SAVE):return true
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(SAVE))!=OK or not valid(parser.data):unreadable=true;return false
    var d: Dictionary=parser.data
    region=d.region;player_position=Vector2(d.position[0],d.position[1]);hp=d.hp;fed=d.fed;ferocity=d.ferocity;clock=d.clock;day=int(d.day);gore=d.gore
    inventory=d.inventory;flags=d.flags;encounters=d.encounters;objects=d.objects;cargo=d.cargo;contracts=d.contracts;reputation=d.reputation;regional=d.regional;animal=d.animal;camp_region=d.camp_region;packed=d.packed;equipment=d.equipment
    player_name=d.get("player_name","Ogre");appearance=d.get("appearance","copper")
    return true
func number(v,lo: float,hi: float) -> bool:return (v is float or v is int) and is_finite(float(v)) and v>=lo and v<=hi
func point(v) -> bool:return v is Array and v.size()==2 and number(v[0],50,2210) and number(v[1],50,1340)
func valid_cargo(v) -> bool:
    if not v is Dictionary:return false
    if v.is_empty():return true
    if not v.get("id") is String or not v.get("kind") in ["log","spoils"] or not v.get("yield") is Dictionary:return false
    for key in v.yield:
        if not key in inventory or not number(v.yield[key],0,1000) or v.yield[key]!=int(v.yield[key]):return false
    return true
func valid(d) -> bool:
    if not d is Dictionary:return false
    for key in pack():
        if not d.has(key) and key not in ["player_name","appearance"]:return false
    if d.version!=1 or not d.region in REGIONS or not d.camp_region in REGIONS or not point(d.position):return false
    if not d.get("player_name","Ogre") is String or d.get("player_name","Ogre").strip_edges().is_empty() or d.get("player_name","Ogre").length()>24:return false
    if not d.get("appearance","copper") in APPEARANCES:return false
    if not d.equipment in ["axe","maul"] or not d.packed is bool or not d.gore is bool:return false
    if not number(d.hp,0,180) or not number(d.fed,0,300) or not number(d.ferocity,0,100) or not number(d.clock,0,100000000) or not number(d.day,1,100000):return false
    for key in ["inventory","flags","encounters","objects","contracts","reputation","regional","animal"]:
        if not d[key] is Dictionary or d[key].size()>5000:return false
    for key in inventory:
        if not number(d.inventory.get(key),0,100000) or d.inventory[key]!=int(d.inventory[key]):return false
    for val in d.flags.values():
        if not val is bool:return false
    for val in d.encounters.values():
        if not number(val,0,10000):return false
    for o in d.objects.values():
        if not o is Dictionary or not o.get("region") in REGIONS or not point(o.get("position")) or not number(o.get("hp"),0,10000) or not o.get("kind") in ["log","spoils","boulder","barricade","tree","barn"] or not o.get("taken") is bool:return false
        if not o.get("yield") is Dictionary:return false
        for item in o.yield:
            if not item in inventory or not number(o.yield[item],0,1000):return false
    if not valid_cargo(d.cargo):return false
    for c in d.contracts.values():
        if not c is Dictionary or not c.get("status") in ["active","paid","refused"] or not c.get("term") is String:return false
    for faction in reputation:
        if not d.reputation.get(faction) is Dictionary:return false
        for axis in reputation[faction]:
            if not number(d.reputation[faction].get(axis),-100,100):return false
    var r=d.regional
    if not r.get("pass_safe") is bool or not number(r.get("trade"),0,100) or not number(r.get("dunmere_prosperity"),0,100) or not number(r.get("dunmere_resistance"),0,100):return false
    if not r.get("dunmere_control") in ["local","ogre"] or not r.get("protection") in ["none","protection","tribute"] or not number(r.get("last_tribute"),0,100000):return false
    var a=d.animal
    return a.get("name") is String and a.name.length()<40 and number(a.get("trust"),0,100) and number(a.get("fed"),0,900) and a.get("tamed") is bool and a.get("harness") is bool and a.get("command") in ["follow","stay","haul"] and valid_cargo(a.get("cargo"))
