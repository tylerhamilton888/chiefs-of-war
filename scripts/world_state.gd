extends RefCounted
## Authoritative simulation data; graphics and collision are derived from this state.
const CELL := 32
const SIZE := Vector2i(112,44)
const MAX_HP := {"tree":100.0,"stump":35.0,"log":35.0,"rock":140.0,"wall":150.0,"roof":95.0,"hearth":999.0}
const FUEL := {"tree":70.0,"stump":15.0,"log":25.0,"rock":0.0,"wall":100.0,"roof":65.0,"hearth":0.0}
var objects: Dictionary = {}
var terrain: Dictionary = {}
var next_id := 0
var timber := 0
var spread_enabled := true
var wind := Vector2(1,0)
var revision := 0

func add_object(kind: String, pos: Vector2, id: String = "") -> String:
    if not MAX_HP.has(kind):
        return ""
    if id.is_empty():
        next_id += 1
        id = "placed_%s" % next_id
    objects[id] = {"id":id,"kind":kind,"x":pos.x,"y":pos.y,"hp":MAX_HP[kind],"fuel":FUEL[kind],"state":"intact","burning":false,"heat":0.0,"wet":0.0,"contained":kind=="hearth"}
    revision += 1
    return id

func point(o: Dictionary) -> Vector2:
    return Vector2(o.x,o.y)

func terrain_at(cell: Vector2i) -> String:
    return terrain.get("%s,%s" % [cell.x,cell.y],"grass")

func set_terrain(cell: Vector2i, material: String) -> bool:
    if cell.x<0 or cell.y<0 or cell.x>=SIZE.x or cell.y>=SIZE.y or not material in ["grass","earth","water"]:
        return false
    var key := "%s,%s" % [cell.x,cell.y]
    if material == "grass":
        terrain.erase(key)
    else:
        terrain[key] = material
    revision += 1
    return true

func clear_fire_path(a: Vector2,b: Vector2) -> bool:
    var count := maxi(1,ceili(a.distance_to(b)/8.0))
    for i in range(count+1):
        var cell := Vector2i((a.lerp(b,float(i)/count)/CELL).floor())
        if terrain_at(cell) in ["water","earth"]:
            return false
    return true

func ignite(id: String, cause: String) -> bool:
    # No ambient random ignition and no spreading fire from contained hearths.
    if not cause in ["raid","disaster","deliberate","spread"] or not objects.has(id):
        return false
    var o: Dictionary = objects[id]
    if o.contained or o.kind=="rock" or o.state!="intact" or o.fuel<=0 or o.wet>0:
        return false
    if cause=="spread" and not spread_enabled:
        return false
    o.burning = true
    o.heat = 1.0
    revision += 1
    return true

func extinguish(id: String) -> void:
    if not objects.has(id):
        return
    objects[id].burning = false
    objects[id].heat = 0.0
    objects[id].wet = 45.0
    revision += 1

func damage(id: String, amount: float, fire_damage := false) -> void:
    if not objects.has(id) or amount<=0:
        return
    var o: Dictionary = objects[id]
    if o.state!="intact" or o.contained:
        return
    o.hp = maxf(0.0,o.hp-amount)
    if o.hp==0:
        o.burning = false
        o.state = "charred" if fire_damage else "destroyed"
        if o.kind=="tree" and not fire_damage:
            # Fixed child identity prevents duplicate timber after reload or repeated damage.
            o.state = "felled"
            add_object("log",point(o)+Vector2(42,16),id+"_timber")
        elif o.kind=="wall" and not fire_damage:
            add_object("log",point(o)+Vector2(0,18),id+"_salvage")
    revision += 1

func collect(id: String) -> bool:
    if not objects.has(id):
        return false
    var o: Dictionary = objects[id]
    if o.kind!="log" or o.state!="intact" or o.burning:
        return false
    o.state="collected"
    timber+=1
    revision+=1
    return true

func fire_tick(delta: float) -> void:
    var burning: Array[String] = []
    var warming: Dictionary = {}
    for id in objects:
        var o: Dictionary = objects[id]
        o.wet = maxf(0.0,o.wet-delta)
        if o.burning and o.state=="intact" and not o.contained:
            burning.append(id)
    # Snapshot sources: new ignitions cannot cascade through the map in one tick.
    for id in burning:
        var source: Dictionary = objects[id]
        source.fuel = maxf(0.0,source.fuel-delta)
        damage(id,delta*3.0,true)
        if source.fuel<=0:
            source.burning=false
        if not spread_enabled:
            continue
        for target_id in objects:
            var target: Dictionary = objects[target_id]
            if target_id==id or target.burning or target.contained or target.state!="intact" or target.fuel<=0 or target.wet>0:
                continue
            var offset := point(target)-point(source)
            var distance := offset.length()
            if distance>112 or not clear_fire_path(point(source),point(target)):
                continue
            var wind_factor := 1.0+0.35*offset.normalized().dot(wind.normalized())
            warming[target_id] = warming.get(target_id,0.0)+delta*0.12*wind_factor*(1.0-distance/140.0)
    for id in objects:
        var o: Dictionary = objects[id]
        if not o.burning:
            o.heat = clampf(o.heat+warming.get(id,-delta*0.08),0,1)
            if o.heat>=1.0:
                ignite(id,"spread")

func snapshot() -> Dictionary:
    return {"version":2,"objects":objects.duplicate(true),"terrain":terrain.duplicate(true),"next_id":next_id,"timber":timber,"spread_enabled":spread_enabled}

func restore(data: Dictionary) -> bool:
    if data.get("version")!=2 or not data.get("objects") is Dictionary or not data.get("terrain") is Dictionary:
        return false
    # Validate before replacing live state.
    for id in data.objects:
        var o = data.objects[id]
        if not o is Dictionary or not MAX_HP.has(o.get("kind")):
            return false
        for key in ["x","y","hp","fuel","heat","wet"]:
            if not (o.get(key) is float or o.get(key) is int) or not is_finite(float(o[key])):
                return false
        if not o.get("state") in ["intact","felled","destroyed","charred","collected"]:
            return false
        if not o.get("burning") is bool or not o.get("contained") is bool:
            return false
    for key in data.terrain:
        var parts := str(key).split(",")
        if parts.size()!=2 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not data.terrain[key] in ["grass","earth","water"]:
            return false
    objects=data.objects.duplicate(true)
    terrain=data.terrain.duplicate(true)
    next_id=maxi(int(data.get("next_id",0)),0)
    timber=maxi(int(data.get("timber",0)),0)
    spread_enabled=bool(data.get("spread_enabled",true))
    revision+=1
    return true
