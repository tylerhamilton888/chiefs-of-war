extends RefCounted
# Slot one keeps the original path: no migration or destructive replacement.
const COUNT=3
const LEGACY="user://ancestral_hearth_v1.json"
static var booted:=false
static var selected:=0
static var fresh:=false
static var practice:=false
static var load_failed:=false
static func path(slot: int=-1) -> String:
    var index=selected if slot<0 else clampi(slot,0,COUNT-1)
    return LEGACY if index==0 else "user://ancestral_hearth_slot_%d.json"%(index+1)
static func resolve(original: String) -> String:
    if original==LEGACY: return path()
    if original in ["user://hearth_fire_checkpoint.json","user://opener_expedition_checkpoint.json"]:
        return original if selected==0 else original.trim_suffix(".json")+"_slot_%d.json"%(selected+1)
    return original
static func info(slot: int) -> Dictionary:
    var file=path(slot)
    if not FileAccess.file_exists(file): return {"empty":true,"valid":true,"name":"New character"}
    var parser=JSON.new()
    var parsed=parser.parse(FileAccess.get_file_as_string(file))
    var data=parser.data if parsed==OK else null
    if not data is Dictionary or data.get("opener_version")!=1 or not data.get("opener") is Dictionary or not data.opener.get("name") is String:
        return {"empty":false,"valid":false,"name":"Save unavailable"}
    return {"empty":false,"valid":true,"name":data.opener.name,"day":int(data.get("progress",{}).get("day",1)),"modified":FileAccess.get_modified_time(file),"outfit":data.get("progress",{}).get("equipment","leather")}
static func choose(slot: int,new_character: bool=false) -> void:
    selected=clampi(slot,0,COUNT-1);fresh=new_character;practice=false;load_failed=false
    var config=ConfigFile.new();config.set_value("campaign","slot",selected);config.save("user://menu.cfg")
static func restore_selection() -> void:
    var config=ConfigFile.new()
    if config.load("user://menu.cfg")==OK: selected=clampi(int(config.get_value("campaign","slot",0)),0,COUNT-1)
