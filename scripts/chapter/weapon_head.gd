extends Node2D
## Each armed drawing supplies the haft socket and a stencil over its painted iron.
## The item's head is drawn at the walk sheet's scale, even on larger combat atlases.
const SOCKETS = preload("res://resources/equipment/weapon_head_sockets.json")
const PATCHES = preload("res://assets/equipment/weapon_body_patches.png")
const WALK_HEIGHT := 192.0
var iron := Sprite2D.new()
var last_texture: Texture2D
var last_region := Rect2()
var socket: Array = []

func _ready() -> void:
    iron.centered = false
    iron.offset = Vector2(0, -43)
    add_child(iron)
    hide()

func equip(texture: Texture2D) -> void:
    iron.texture = texture

func align_to(body: Sprite2D) -> void:
    var material: ShaderMaterial = body.material
    if body.texture != last_texture or body.region_rect != last_region:
        last_texture = body.texture
        last_region = body.region_rect
        var sheet: Dictionary = SOCKETS.data.get(body.texture.resource_path, {})
        socket = sheet.get("%d,%d" % [last_region.position.x, last_region.position.y], [])
        set_stencil(material)
    visible = body.visible and not socket.is_empty()
    if not visible:
        return
    transform = body.transform
    modulate = body.modulate
    var side := -1.0 if body.flip_h else 1.0
    var mount := Vector2(socket[0], socket[1]) - last_region.size * 0.5
    iron.position = mount * Vector2(side, 1.0)
    iron.rotation = deg_to_rad(socket[2]) * side
    iron.scale = Vector2(side, 1.0) * (float(socket[3]) / WALK_HEIGHT)

func set_stencil(material: ShaderMaterial) -> void:
    material.set_shader_parameter("has_iron_patch", not socket.is_empty())
    if socket.is_empty():
        return
    var source := last_region.position + Vector2(socket[4], socket[5])
    var extent := Vector2(socket[6], socket[7])
    var offset := Vector2(socket[8], socket[9])
    material.set_shader_parameter("body_source", source)
    material.set_shader_parameter("patch_size", extent)
    material.set_shader_parameter("patch_origin", offset)
    material.set_shader_parameter("body_patches", PATCHES)
