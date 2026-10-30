extends SceneTree
var actors: Array=[]
var tick:=0
func _initialize(): call_deferred("run")
func run():
    var bg=ColorRect.new(); bg.color=Color("292d24"); bg.size=Vector2(1280,800); root.add_child(bg)
    for outfit in 2:
        for d in 4:
            var a=load("res://scripts/opener_actor.gd").new(); a.controlled=false
            root.add_child(a); a.equip("leather" if outfit==0 else "iron"); a.position=Vector2(180+d*300,270+outfit*350); a.facing=d; a.speed=95
            actors.append(a)
            var l=Label.new(); l.text=("LEATHER" if outfit==0 else "IRON")+" / "+["FRONT","LEFT","RIGHT","BACK"][d]; l.position=a.position+Vector2(-75,95); root.add_child(l)
    var title=Label.new(); title.text="CHIEFS OF WAR 0.3.1  |  ACTUAL ENGINE MOTION REVIEW";title.position=Vector2(220,25);title.add_theme_font_size_override("font_size",24);root.add_child(title)
    for i in 240:
        for n in actors.size():
            var a=actors[n];var d=n%4;var direction=[Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP][d]
            if i<120:
                a.drive=direction
                if i%60==0:a.position=Vector2(180+d*300,220+(n/4)*350)
            elif i==120:a.drive=Vector2.ZERO
            elif i==150 or i==185:a.request_attack(direction)
            elif i==220:a.dodge(direction)
        await physics_frame
        if i==30 or i==125 or i==165:
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png("/tmp/chiefs031-visual/motion-%s.png"%i)
    quit()
