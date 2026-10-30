extends SceneTree
const Appearance=preload("res://scripts/appearance.gd")
const Game=preload("res://scripts/execution_opener.gd")
func _initialize():call_deferred("run")
func run():
    root.size=Vector2i(1280,800)
    var bg=ColorRect.new();bg.color=Color("252820");bg.size=Vector2(1280,800);root.add_child(bg)
    for row in 4:
        for index in 6:
            var rect: Rect2=Game.HERO_RECTS[index]
            if row>=2:rect.position.y=370;rect.size.y=354
            var s=Sprite2D.new();s.texture=Game.FINISHER_ART;s.region_enabled=true;s.region_rect=rect;s.scale=Vector2.ONE*0.5;s.position=Vector2(100+index*210,90+row*195);s.flip_h=row%2==1;root.add_child(s)
            var m=ShaderMaterial.new();m.shader=load("res://scripts/orc_palette.gdshader");s.material=m
            var look=Appearance.defaults();look.hair=index%4;look.beard=index%3;look.mustache=index%3;look.hair_color=index;look.face=index%3
            Appearance.apply(m,look,row*2,index)
            Appearance.frame(m,s.texture,rect,2,"finisher",index)
    for i in 8:await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("CHIEFS_REVIEW_DIR").path_join("finisher-grid.png"))
    quit()
