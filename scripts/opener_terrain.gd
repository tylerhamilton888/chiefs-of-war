extends "res://scripts/terrain.gd"
var mask_image: Image
var mask_texture: ImageTexture
func _ready() -> void:
    texture=load("res://assets/overhaul/ground.png")
    mask_image=Image.create(112,44,false,Image.FORMAT_RGB8)
    mask_texture=ImageTexture.create_from_image(mask_image)
    var paint=ShaderMaterial.new(); paint.shader=load("res://scripts/ground_blend.gdshader")
    paint.set_shader_parameter("earth_texture",load("res://assets/opener/earth.png"))
    paint.set_shader_parameter("terrain_mask",mask_texture); material=paint
func _process(delta: float) -> void:
    if last_revision!=state.revision:
        mask_image.fill(Color.BLACK)
        for key in state.terrain:
            var xy=key.split(","); var x=int(xy[0]); var y=int(xy[1])
            if x>=0 and y>=0 and x<112 and y<44: mask_image.set_pixel(x,y,Color.RED if state.terrain[key]=="earth" else Color.GREEN if state.terrain[key]=="water" else Color.BLACK)
        mask_texture.update(mask_image)
    super._process(delta)
func _draw() -> void:
    draw_texture_rect(texture,Rect2(0,0,3584,1408),true)
