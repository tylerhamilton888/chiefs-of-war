extends SceneTree
func _initialize():call_deferred("run")
func run():
    var bg=ColorRect.new();bg.color=Color("414639");bg.size=Vector2(1280,800);root.add_child(bg)
    var hero=load("res://scripts/opener_actor.gd").new();root.add_child(hero);hero.set_physics_process(false)
    var look=preload("res://scripts/appearance.gd")
    for row in 4:
        for col in 4:
            hero.equip("leather" if col<2 else "iron");hero.facing=row
            look.apply(hero.look_material,look.defaults(),0,0)
            hero.show_defense(0 if col%2==0 else 3)
            var s=hero.sprite.duplicate();s.material=hero.look_material.duplicate();s.scale*=1.5;s.position=s.position*1.5+Vector2(160+col*320,190+row*200);root.add_child(s)
    hero.hide()
    for i in 8:await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(OS.get_environment("CHIEFS_REVIEW_DIR")+"/defense-grid.png")
    quit()
