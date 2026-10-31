extends RefCounted
static var cache: Dictionary={}
static func pose(sprite: Sprite2D,id: String,index: int,height: float,mirror: bool=false) -> void:
    if not cache.has(id):
        var path="res://resources/frontier/"+id+".json"
        if not FileAccess.file_exists(path):return
        cache[id]={"data":JSON.parse_string(FileAccess.get_file_as_string(path)),"texture":load("res://assets/frontier/"+id+".png")}
    var art=cache[id];var d=art.data;var r=d.frames[clampi(index,0,d.frames.size()-1)]
    var factor=height/float(d.height)
    sprite.texture=art.texture;sprite.region_enabled=true;sprite.region_rect=Rect2(r[0],r[1],r[2],r[3]);sprite.scale=Vector2.ONE*factor;sprite.flip_h=mirror
    sprite.position=Vector2((r[2]*0.5-r[4])*factor*(-1 if mirror else 1),(r[3]*0.5-r[5])*factor+3)
