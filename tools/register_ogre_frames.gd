extends SceneTree
## Register existing whole-body artwork. Writes geometry/anchors only; never edits pixels.
func area(poly: PackedVector2Array) -> float:
    var sum=0.0
    for i in poly.size():sum+=poly[i].cross(poly[(i+1)%poly.size()])
    return absf(sum)*0.5
func box_polygon(r: Rect2) -> PackedVector2Array:
    return PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)])
func _initialize() -> void:
    var entries={}
    register(entries,"res://assets/ogre/hearthlord_motion_nordic.png","res://resources/ogre_motion.json","motion")
    for name in ["astrid","bramm","dorrik","eydis","gorund","hrothgar","runa","svala","thyra","player_combat","hrothgar_combat"]:
        register(entries,"res://assets/chapter/"+name+"_nordic.png","res://resources/chapter/"+name+".json","chapter")
    for name in ["carry_log","carry_spoils","work","log_attack","player_maul","overpower","clinch","spearmen"]:
        var path="res://assets/frontier/"+name+"_nordic.png"
        if not FileAccess.file_exists(path):path="res://assets/frontier/"+name+".png"
        register(entries,path,"res://resources/frontier/"+name+".json","frontier")
    if entries.size()!=20:quit(1);return
    var file=FileAccess.open("res://resources/ogre_frame_registration.json",FileAccess.WRITE)
    file.store_string(JSON.stringify(entries)+"\n")
    print("Registered ",entries.size()," existing atlases without changing their artwork")
    quit()
func register(entries: Dictionary,path: String,metadata: String,kind: String) -> void:
    var data=JSON.parse_string(FileAccess.get_file_as_string(metadata))
    var frames: Array=[]
    var source: Array=data if kind=="motion" else data.frames
    if kind=="frontier":frames=source
    else:
        for row in source:frames.append_array(row)
    var source_image=Image.load_from_file(ProjectSettings.globalize_path(path))
    var bitmap=BitMap.new();bitmap.create_from_image_alpha(source_image,0.38)
    var outlines=bitmap.opaque_to_polygons(Rect2i(Vector2i.ZERO,source_image.get_size()),2.0)
    var groups: Array=[]
    for i in frames.size():groups.append([])
    for outline in outlines:
        if area(outline)<500:continue
        var best=-1;var overlap=0.0
        for i in frames.size():
            var r=frames[i];var clipped=Geometry2D.intersect_polygons(outline,box_polygon(Rect2(r[0],r[1],r[2],r[3])))
            var covered=0.0
            for poly in clipped:covered+=area(poly)
            if covered>overlap:overlap=covered;best=i
        # Low-alpha background debris outside every authored frame is not a figure.
        if best<0:continue
        # A small geometric margin retains the original antialiased outline.
        for expanded in Geometry2D.offset_polygon(outline,1.5):
            for clipped in Geometry2D.intersect_polygons(expanded,box_polygon(Rect2(Vector2.ZERO,source_image.get_size()))):
                if area(clipped)>500:groups[best].append(clean_polygon(clipped))
    var result=[]
    for i in frames.size():
        assert(not groups[i].is_empty(),path+" missing pose "+str(i))
        var r=frames[i]
        var anchor=Vector2(r[0]+r[2]*0.5,r[1]+r[3])
        if kind=="chapter" and r.size()>4:anchor.x-=r[4]
        if kind=="frontier":anchor=Vector2(r[0]+r[4],r[1]+r[5])
        var bounds=Rect2(groups[i][0][0],Vector2.ZERO);var polygons=[]
        for poly in groups[i]:
            if Geometry2D.triangulate_polygon(poly).is_empty():
                push_error("Invalid outline "+path+" pose "+str(i));quit(1);return
            var points=[]
            for point in poly:
                bounds=bounds.expand(point);points.append([snappedf(point.x,0.01),snappedf(point.y,0.01)])
            polygons.append(points)
        var start=bounds.position.floor();var end=bounds.end.ceil()
        result.append({"rect":[start.x,start.y,end.x-start.x,end.y-start.y],"anchor":[anchor.x-start.x,anchor.y-start.y],"polygons":polygons})
    var stature=280.0 if kind=="motion" else float(data.height)
    if path.ends_with("log_attack_nordic.png"):stature=275.0
    entries[path]={"height":stature,"size":[source_image.get_width(),source_image.get_height()],"source_sha256":FileAccess.get_sha256(path),"frames":result}

func clean_polygon(poly: PackedVector2Array) -> PackedVector2Array:
    var result=PackedVector2Array()
    for point in poly:
        var snapped=point.round()
        if result.is_empty() or result[-1]!=snapped:result.append(snapped)
    if result.size()>1 and result[0]==result[-1]:result.remove_at(result.size()-1)
    var changed=true
    while changed and result.size()>3:
        changed=false
        for i in result.size():
            var a=result[(i+result.size()-1)%result.size()];var b=result[i];var c=result[(i+1)%result.size()]
            if absf((b-a).cross(c-b))<0.1:
                result.remove_at(i);changed=true;break
    return result
