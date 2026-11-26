extends Node2D
## Every wearable has three illustrated views. Body animation supplies the
## attachment and foreground boundaries, shared by the items in the slot.
const SLOTS := {
    "head": {"default": "bare", "rig": "res://resources/equipment/head_sockets.json",
        "items": {"iron_helm": "res://resources/equipment/iron_helm.json"}},
    "body": {"default": "fur", "rig": "res://resources/equipment/shoulder_sockets.json",
        "items": {"scale_mantle": "res://resources/equipment/scale_mantle.json"}}
}
const SHOULDER_MASK := "res://assets/equipment/shoulder_coverage_%d.png"
static var socket_tables := {}
static var mask_sheets := {}
var slot: String
var item_id: String
var views: Dictionary = {}
var mounts: Dictionary = {}
var sockets: Dictionary = {}
var piece := Sprite2D.new()
var foreground: Array[Polygon2D] = []
var last_texture: Texture2D
var last_region := Rect2()
var last_mirror := false
var socket: Array = []
var breath_height := 0.0
var coverage_material: ShaderMaterial

func _init(slot_name := "head") -> void:
    slot = slot_name
    item_id = SLOTS[slot].default

func _ready() -> void:
    piece.region_enabled = true
    piece.region_filter_clip_enabled = true
    if slot == "head":
        # The fitted helm usually occupies 26–29 screen pixels at gameplay zoom.
        piece.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    add_child(piece)
    if slot == "body":
        coverage_material = ShaderMaterial.new()
        coverage_material.shader = preload("res://shaders/ogre_mantle.gdshader")
        piece.material = coverage_material
    hide()

static func supports(slot_name: String, id: String) -> bool:
    return id == SLOTS[slot_name].default or SLOTS[slot_name].items.has(id)

func equip(id: String) -> void:
    if id == item_id or not supports(slot, id):
        return
    item_id = id
    last_texture = null
    socket = []
    hide()
    if id == SLOTS[slot].default:
        return
    if not socket_tables.has(slot):
        socket_tables[slot] = load(SLOTS[slot].rig).data
    sockets = socket_tables[slot]
    var item: Dictionary = load(SLOTS[slot].items[id]).data
    views = item.views
    mounts = item.get("mounts", {})
    piece.texture = load(item.texture)

func align_to(body: Sprite2D, breath: Polygon2D = null) -> void:
    if item_id == SLOTS[slot].default or body.texture == null:
        hide()
        return
    if body.texture != last_texture or body.region_rect != last_region or body.flip_h != last_mirror:
        bind_pose(body)
    if socket.is_empty():
        hide()
        return
    transform = body.transform
    if breath != null and breath.visible:
        position += transform.y * breath.lift_at(breath_height / last_region.size.y)
    modulate = body.modulate
    for part in foreground:
        part.material = body.material
    visible = body.visible or (breath != null and breath.visible)

func bind_pose(body: Sprite2D) -> void:
    last_texture = body.texture
    last_region = body.region_rect
    last_mirror = body.flip_h
    var sheet: Dictionary = sockets.get(body.texture.resource_path, {})
    var key := "%d,%d" % [last_region.position.x, last_region.position.y]
    socket = sheet.get(key, [])
    for part in foreground:
        part.hide()
    if socket.is_empty():
        return
    var side := -1.0 if last_mirror else 1.0
    var cell: Array = views[socket[4]]
    piece.region_rect = Rect2(cell[0], cell[1], cell[2], cell[3])
    piece.flip_h = last_mirror
    if slot == "body":
        bind_covered_panel(side)
    else:
        bind_fitted_piece(body, side)

func bind_covered_panel(side: float) -> void:
    var size_px := Vector2(socket[2], socket[3])
    var center := Vector2(socket[0], socket[1]) + size_px * 0.5
    breath_height = center.y
    piece.position = (center - last_region.size * 0.5) * Vector2(side, 1)
    piece.scale = size_px / piece.region_rect.size
    var page := int(socket[5])
    if not mask_sheets.has(page):
        mask_sheets[page] = load(SHOULDER_MASK % page)
    var mask: Texture2D = mask_sheets[page]
    var patch := Rect2(socket[6], socket[7], socket[8], socket[9])
    coverage_material.set_shader_parameter("coverage", mask)
    coverage_material.set_shader_parameter("coverage_region", normalized_region(patch, mask))
    coverage_material.set_shader_parameter("item_region", normalized_region(piece.region_rect, piece.texture))

static func normalized_region(rect: Rect2, texture: Texture2D) -> Vector4:
    var origin := rect.position / texture.get_size()
    var extent := rect.size / texture.get_size()
    return Vector4(origin.x, origin.y, extent.x, extent.y)

func bind_fitted_piece(body: Sprite2D, side: float) -> void:
    var mount: Array = mounts[socket[4]]
    breath_height = float(socket[1])
    piece.position = (Vector2(socket[0], socket[1]) - last_region.size * 0.5) * Vector2(side, 1)
    piece.rotation = deg_to_rad(float(socket[3])) * side
    # Register the skull band independently of the visible crest or brim.
    piece.offset = (piece.region_rect.size * 0.5 - Vector2(mount[0], mount[1])) * Vector2(side, 1)
    piece.scale = Vector2.ONE * (float(socket[2]) / float(mount[2]))
    if socket.size() > 5:
        show_foreground(body, socket[5], side)

func show_foreground(body: Sprite2D, contours: Array, side: float) -> void:
    for i in contours.size():
        if i == foreground.size():
            var new_part := Polygon2D.new()
            add_child(new_part)
            foreground.append(new_part)
        var part := foreground[i]
        var vertices := PackedVector2Array()
        var uv := PackedVector2Array()
        for point in contours[i]:
            var source := Vector2(point[0], point[1])
            vertices.append((source - last_region.size * 0.5) * Vector2(side, 1))
            uv.append(source + last_region.position)
        part.texture = body.texture
        part.polygon = vertices
        part.uv = uv
        part.show()

# Only named pieces receive heraldry. Ordinary qualities share the original fitted sheet.
const BADGES = {"watch":preload("res://assets/equipment/cairnwatch_badge.svg"),"hart":preload("res://assets/equipment/red_hart_badge.svg")}
static var marked_sheets := {}

func set_insignia(mark: String) -> void:
    if item_id == SLOTS[slot].default:
        return
    var definition: Dictionary = load(SLOTS[slot].items[item_id]).data
    var plain: Texture2D = load(definition.texture)
    if mark.is_empty():
        piece.texture = plain
        return
    var key := item_id + "/" + mark
    if not marked_sheets.has(key):
        var image := plain.get_image()
        if image.is_compressed(): image.decompress()
        image.convert(Image.FORMAT_RGBA8)
        if image.has_mipmaps(): image.clear_mipmaps()
        var original: Image = BADGES[mark].get_image()
        original.convert(Image.FORMAT_RGBA8)
        for view in definition.views:
            var r: Array = definition.views[view]
            var width := 32 if slot == "head" else 38
            var badge := original.duplicate() as Image
            badge.resize(width,roundi(float(width)*original.get_height()/original.get_width()),Image.INTERPOLATE_LANCZOS)
            var anchors := [Vector2(.5,.56)]
            if slot == "body":
                anchors = {"front":[Vector2(.19,.26),Vector2(.81,.26)],"side":[Vector2(.67,.23)],"rear":[Vector2(.50,.48)]}[view]
            for anchor in anchors:
                var center := Vector2(r[0],r[1])+Vector2(r[2],r[3])*Vector2(anchor)
                image.blend_rect(badge,Rect2i(Vector2i.ZERO,badge.get_size()),Vector2i(center)-badge.get_size()/2)
        if slot == "head": image.generate_mipmaps()
        marked_sheets[key] = ImageTexture.create_from_image(image)
    piece.texture = marked_sheets[key]
