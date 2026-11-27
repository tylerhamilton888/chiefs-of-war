extends Node2D
## Each armed drawing supplies the haft socket and a stencil over its painted iron.
## The item's head is drawn at the walk sheet's scale, even on larger combat atlases.
const SOCKETS = preload("res://resources/equipment/weapon_head_sockets.json")
const RUN_SOCKETS = preload("res://resources/equipment/run_weapon_sockets.json")
const BODY_VIEWS = preload("res://resources/equipment/head_sockets.json")
const CELL := Vector2(96, 104)
const MOUNT := Vector2(20, 51)
const PATCHES = preload("res://assets/equipment/weapon_body_patches.png")
const WALK_HEIGHT := 192.0
var iron := Sprite2D.new()
var last_texture: Texture2D
var last_region := Rect2()
var socket: Array = []
var view := ""

func _ready() -> void:
    iron.centered = false
    iron.offset = -MOUNT
    iron.region_enabled = true
    iron.region_filter_clip_enabled = true
    add_child(iron)
    hide()

func equip(texture: Texture2D) -> void:
    iron.texture = texture

func align_to(body: Sprite2D) -> void:
    var material: ShaderMaterial = body.material
    if body.texture != last_texture or body.region_rect != last_region:
        last_texture = body.texture
        last_region = body.region_rect
        var path := body.texture.resource_path
        var key := "%d,%d" % [last_region.position.x, last_region.position.y]
        var sheet: Dictionary = SOCKETS.data.get(path, RUN_SOCKETS.data.get(path, {}))
        socket = sheet.get(key, [])
        if not socket.is_empty():
            view = BODY_VIEWS.data[path][key][4]
            # In the rear view the torso and mantle obscure the weapon.
            var behind := view == "rear"
            if behind != (get_index() < body.get_index()):
                get_parent().move_child(self, body.get_index())
        set_stencil(material)
    visible = body.visible and not socket.is_empty()
    if not visible:
        return
    transform = body.transform
    modulate = body.modulate
    var side := -1.0 if body.flip_h else 1.0
    var column := 0
    if view == "side":
        column = 3 if body.flip_h else 1
    elif view == "rear":
        column = 2
    iron.region_rect = Rect2(Vector2(column * CELL.x, 0), CELL)
    var mount := Vector2(socket[0], socket[1]) - last_region.size * 0.5
    iron.position = mount * Vector2(side, 1.0)
    iron.rotation = deg_to_rad(socket[2]) * side
    iron.scale = Vector2(side, 1.0) * (float(socket[3]) / WALK_HEIGHT)

func set_stencil(material: ShaderMaterial) -> void:
    # Run artwork contains the shaft and hands only.
    var repaired := socket.size() > 4
    material.set_shader_parameter("has_iron_patch", repaired)
    if not repaired:
        return
    var source := last_region.position + Vector2(socket[4], socket[5])
    var extent := Vector2(socket[6], socket[7])
    var offset := Vector2(socket[8], socket[9])
    material.set_shader_parameter("body_source", source)
    material.set_shader_parameter("patch_size", extent)
    material.set_shader_parameter("patch_origin", offset)
    material.set_shader_parameter("body_patches", PATCHES)
