extends RefCounted
## Geometry masks isolate whole authored poses whose atlas bounding boxes overlap.
## The source atlas and its UVs remain intact (including palette/finisher masks).
static var registrations: Dictionary={}
static var prepared: Dictionary={}
static func pose(sprite: Sprite2D,texture: Texture2D,index: int,height: float,mirror: bool) -> bool:
    sprite.rotation = 0.0
    if registrations.is_empty():registrations=JSON.parse_string(FileAccess.get_file_as_string("res://resources/ogre_frame_registration.json"))
    var path=texture.resource_path
    if not registrations.has(path):
        use_sprite_region(sprite)
        return false
    var data=registrations[path];var frame=data.frames[index];var r=frame.rect
    var rect=Rect2(r[0],r[1],r[2],r[3]);var anchor=Vector2(frame.anchor[0],frame.anchor[1])
    var factor=height/float(data.height)
    sprite.texture=texture;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true;sprite.region_rect=rect
    sprite.flip_h=mirror;sprite.scale=Vector2.ONE*factor
    sprite.position=(rect.size*0.5-anchor)*factor*Vector2(-1 if mirror else 1,1)+Vector2(0,3)
    # Only the built-in rectangle is hidden. Children inherit modulate/visibility,
    # not self_modulate, and use the same material and atlas coordinates.
    sprite.self_modulate=Color(1,1,1,0)
    var key=path+":"+str(index)+":"+str(mirror)
    if sprite.get_meta("registered_pose","")==key:return true
    if not prepared.has(key):
        var parts=[]
        for points in frame.polygons:
            var vertices=PackedVector2Array();var uv=PackedVector2Array()
            for point in points:
                var source=Vector2(point[0],point[1]);var local=source-rect.get_center()
                if mirror:local.x=-local.x
                vertices.append(local);uv.append(source)
            parts.append({"vertices":vertices,"uv":uv})
        prepared[key]=parts
    var parts: Array=prepared[key]
    while sprite.get_child_count()<parts.size():
        var polygon=Polygon2D.new();polygon.use_parent_material=true;sprite.add_child(polygon)
    for i in sprite.get_child_count():
        var polygon: Polygon2D=sprite.get_child(i)
        polygon.visible=i<parts.size()
        if polygon.visible:
            polygon.texture=texture;polygon.polygon=parts[i].vertices;polygon.uv=parts[i].uv
    sprite.set_meta("registered_pose",key)
    return true

static func use_sprite_region(sprite: Sprite2D) -> void:
    sprite.rotation = 0.0
    if not sprite.has_meta("registered_pose"):
        return
    sprite.self_modulate = Color.WHITE
    for child in sprite.get_children():
        if child is Polygon2D:
            child.hide()
    sprite.remove_meta("registered_pose")


## Rectangular full-body drawings with an explicit foot anchor in frame pixels.
static func cell(sprite: Sprite2D, texture: Texture2D, frame: Array, factor: float, mirror: bool) -> void:
    use_sprite_region(sprite)
    sprite.texture = texture
    sprite.region_enabled = true
    sprite.region_filter_clip_enabled = true
    sprite.region_rect = Rect2(frame[0], frame[1], frame[2], frame[3])
    sprite.flip_h = mirror
    sprite.scale = Vector2.ONE * factor
    var offset := (sprite.region_rect.size * 0.5 - Vector2(frame[4], frame[5])) * factor
    sprite.position = Vector2(-offset.x if mirror else offset.x, offset.y + 3.0)
