extends RefCounted
## New Ogre progress is deliberately separate from all pre-pivot campaign slots.
const SAVE="user://wandering_hearth_v1.json"
var inventory={"wood":0,"meat":0,"meals":0}
var collected: Array=[]
var cooked=0
var player_position=Vector2(940,770)
var unreadable=false
func collect(id: String,kind: String,amount: int) -> bool:
    if id in collected or kind not in inventory or amount<=0:return false
    collected.append(id);inventory[kind]+=amount;return true
func cook() -> bool:
    if inventory.wood<1 or inventory.meat<2:return false
    inventory.wood-=1;inventory.meat-=2;inventory.meals+=3;cooked+=1;return true
func save_game() -> bool:
    if unreadable:return false
    var data={"version":1,"species":"ogre","inventory":inventory,"collected":collected,"cooked":cooked,"position":[player_position.x,player_position.y]}
    var file=FileAccess.open(SAVE+".tmp",FileAccess.WRITE)
    if file==null:return false
    file.store_string(JSON.stringify(data));file.flush()
    var error=file.get_error();file.close()
    if error!=OK:return false
    return DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE+".tmp"),ProjectSettings.globalize_path(SAVE))==OK
func load_game() -> bool:
    if not FileAccess.file_exists(SAVE):return true
    var parser=JSON.new()
    if parser.parse(FileAccess.get_file_as_string(SAVE))!=OK:unreadable=true;return false
    var data=parser.data
    if not valid(data):unreadable=true;return false
    for key in inventory:inventory[key]=int(data.inventory[key])
    collected=data.collected.duplicate()
    cooked=int(data.cooked);player_position=Vector2(data.position[0],data.position[1]);return true
func valid(data: Variant) -> bool:
    if not data is Dictionary or data.get("version")!=1 or data.get("species")!="ogre":return false
    if not data.get("inventory") is Dictionary or not data.get("collected") is Array:return false
    for key in ["wood","meat","meals"]:
        var n=data.inventory.get(key)
        if not (n is float or n is int) or not is_finite(n) or n<0 or n>100000 or n!=floor(n):return false
    for id in data.collected:
        if not id is String or id.length()>80:return false
    if not data.get("cooked") is float and not data.get("cooked") is int:return false
    if data.cooked<0 or data.cooked>100000:return false
    if not data.get("position") is Array or data.position.size()!=2:return false
    for n in data.position:
        if not (n is float or n is int) or not is_finite(n):return false
    return data.position[0]>=60 and data.position[0]<=2200 and data.position[1]>=40 and data.position[1]<=1360
