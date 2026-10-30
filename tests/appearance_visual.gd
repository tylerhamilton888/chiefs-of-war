extends SceneTree
const Appearance=preload("res://scripts/appearance.gd")
func _initialize():call_deferred("run")
func run():
    root.size=Vector2i(1280,800)
    var bg=ColorRect.new();bg.color=Color("252820");bg.size=Vector2(1280,800);root.add_child(bg)
    for row in 4:
        for col in 6:
            var outfit="leather" if row<2 else "iron"
            var action="rest" if col==0 else "stride" if col==1 else "strike"
            var index=maxi(0,col-2)
            var direction=row%2+2
            var texture: Texture2D=load("res://assets/motion/"+action+"_"+outfit+".png")
            var s=Sprite2D.new();s.texture=texture;s.region_enabled=true;s.region_rect=Rect2((0 if col<2 else index)*512,direction*448,512,448);s.scale=Vector2.ONE*0.65;s.position=Vector2(100+col*210,90+row*195);root.add_child(s)
            var m=ShaderMaterial.new();m.shader=load("res://scripts/orc_palette.gdshader");s.material=m
            var look=Appearance.defaults();look.hair=col%4;look.beard=col%3;look.mustache=col%3;look.hair_color=col;look.face=col%3
            Appearance.apply(m,look,row*3,col)
            Appearance.frame(m,texture,s.region_rect,direction,action,0 if col<2 else index)
    for i in 8:await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("CHIEFS_REVIEW_DIR").path_join("appearance-back-grid.png"))
    quit()
