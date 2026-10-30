extends RefCounted
# Indices 0..2 retain the original skin/cloth save meanings.
const SKINS=["Sun-olive","Forest green","Ash-olive","Moss green","Deep pine","Jade","Sage","Pale ash","Slate","Ochre","Copper","Dark umber"]
const SKIN_TINTS=[Vector3.ONE,Vector3(0.70,0.95,0.78),Vector3(0.84,0.90,1.12),Vector3(0.67,0.83,0.57),Vector3(0.40,0.61,0.52),Vector3(0.55,1.02,0.91),Vector3(0.84,1.08,0.96),Vector3(1.12,1.19,1.47),Vector3(0.67,0.83,1.15),Vector3(1.12,0.90,0.63),Vector3(1.05,0.65,0.47),Vector3(0.54,0.46,0.37)]
const CLOTHS=["Storm blue","Deep teal","Muted violet","Blood red","Burgundy","Ochre gold","Bone linen","Charcoal","Forest green","Rust","Royal blue","Plum"]
const CLOTH_COLORS=[Color("536b88"),Color("367e76"),Color("795e82"),Color("a3322c"),Color("642731"),Color("c39942"),Color("cfbf99"),Color("383c42"),Color("3e6546"),Color("a95e39"),Color("3658a5"),Color("693f68")]
const HAIR_COLORS=[Color("272522"),Color("513529"),Color("866044"),Color("a64e2d"),Color("c39c58"),Color("96928b"),Color("d5d0bc"),Color("454b51")]
const HAIR_NAMES=["Raven black","Dark brown","Chestnut","Copper red","Flaxen","Iron grey","Bone white","Blue black"]
const FACES=["Broadjaw","Scarred veteran","Longtusk"]
const HAIRS=["Shaved","Loose mane","Swept warrior braid","Twin braids"]
const BEARDS=["Clean shaven","Short beard","Forked braids"]
const MUSTACHES=["None","Walrus","Braided"]
const FACES_ART=preload("res://assets/customization/faces.png")
const HAIR_ART=preload("res://assets/customization/hair.png")
const FACIAL_ART=preload("res://assets/customization/facial-hair.png")
static func defaults() -> Dictionary:
    return {"version":1,"face":0,"hair":2,"beard":1,"mustache":0,"hair_color":0}
static func clean(value: Variant) -> Dictionary:
    var out=defaults()
    if not value is Dictionary: return out
    for key in out:
        var v=value.get(key,out[key])
        var cap={"version":1,"face":2,"hair":3,"beard":2,"mustache":2,"hair_color":7}[key]
        if (v is int or v is float) and is_finite(float(v)): out[key]=clampi(int(v),0,cap)
    return out
static func apply(material: ShaderMaterial, look: Dictionary, skin: int, cloth: int) -> void:
    material.set_shader_parameter("skin_tint",SKIN_TINTS[clampi(skin,0,SKINS.size()-1)])
    material.set_shader_parameter("cloth_color",CLOTH_COLORS[clampi(cloth,0,CLOTHS.size()-1)])
    material.set_shader_parameter("custom_head",look.version==1)
    material.set_shader_parameter("legacy_cloth_tint",[Vector3.ONE,Vector3(0.7,1.4,1.05),Vector3(1.4,0.9,1.2)][mini(cloth,2)])
    material.set_shader_parameter("face_id",look.face)
    material.set_shader_parameter("hair_id",look.hair-1)
    material.set_shader_parameter("beard_id",look.beard-1)
    material.set_shader_parameter("mustache_id",look.mustache-1)
    material.set_shader_parameter("hair_color",HAIR_COLORS[look.hair_color])
    material.set_shader_parameter("faces_art",FACES_ART)
    material.set_shader_parameter("hair_art",HAIR_ART)
    material.set_shader_parameter("facial_art",FACIAL_ART)
static func frame(material: ShaderMaterial, texture: Texture2D, rect: Rect2, direction: int, action: String="rest", index: int=0) -> void:
    if material==null or texture==null:return
    var origin=Vector2(214,110)
    if direction==1:origin=Vector2(158,110)
    elif direction==2:origin=Vector2(270,110)
    elif direction==3:origin=Vector2(210,108)
    if action=="stride":
        if direction==0:origin.x+=8
        elif direction==1:origin.x-=[0,8,10,0][index]
        elif direction==2:origin.x+=[0,8,10,0][index]
        origin.y+=[0,2,0,2][index]
    elif action=="strike":
        if direction==0:origin=Vector2([228,218,248,226][index],[112,110,142,116][index])
        elif direction==1:origin=Vector2([174,132,132,140][index],[122,116,150,130][index])
        elif direction==2:origin=Vector2([248,288,304,292][index],[122,116,150,130][index])
        else:origin=Vector2([194,210,226,226][index],[108,110,126,120][index])
    var box=Vector4(rect.position.x+origin.x,rect.position.y+origin.y,84,100)
    if action=="finisher":
        # Artwork is right-facing. Sprite mirroring handles the opposite side.
        var heads=[Vector2(160,117),Vector2(570,133),Vector2(904,130),Vector2(1235,144),Vector2(1595,158),Vector2(1967,98)]
        var p: Vector2=heads[index]+Vector2(8 if rect.position.y>0 else 0,rect.position.y-32 if rect.position.y>0 else 0)
        box=Vector4(p.x,p.y,84,100)
        direction=2
    material.set_shader_parameter("head_box",box)
    material.set_shader_parameter("body_size",Vector2(texture.get_width(),texture.get_height()))
    material.set_shader_parameter("head_direction",direction)
    material.set_shader_parameter("iron_cloth",texture.resource_path.contains("iron"))
