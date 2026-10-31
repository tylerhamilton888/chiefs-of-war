extends RefCounted
## The first Ogre slot preserves the original frontier path. Orc saves are separate.
const COUNT=3
const LEGACY="user://ogre_frontier_v1.json"
const SETTINGS="user://ogre_frontier_menu.cfg"
static var selected:=0
static func path(index: int=-1) -> String:
    var slot=selected if index<0 else clampi(index,0,COUNT-1)
    return LEGACY if slot==0 else "user://ogre_frontier_slot_%d.json"%(slot+1)
static func choose(index: int) -> void:
    selected=clampi(index,0,COUNT-1)
    var config=ConfigFile.new();config.set_value("frontier","slot",selected);config.save(SETTINGS)
static func restore() -> void:
    var config=ConfigFile.new()
    if config.load(SETTINGS)==OK:selected=clampi(int(config.get_value("frontier","slot",0)),0,COUNT-1)
static func info(index: int) -> Dictionary:
    var file=path(index)
    if not FileAccess.file_exists(file):return {"empty":true,"valid":true,"name":"Empty hearth"}
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(file))!=OK or not parser.data is Dictionary:
        return {"empty":false,"valid":false,"name":"Save unavailable"}
    var data: Dictionary=parser.data
    var verifier=load("res://scripts/frontier/state.gd").new()
    if not verifier.valid(data):return {"empty":false,"valid":false,"name":"Save unavailable"}
    return {"empty":false,"valid":true,"name":data.get("player_name","Ogre"),"day":int(data.day),"region":str(data.region)}
