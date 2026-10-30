extends "res://scripts/terrain.gd"
func _draw() -> void:
    draw_texture_rect(texture,Rect2(0,0,1536,1024),true,Color(0.50,0.51,0.39))
    for key in state.terrain:
        var xy: PackedStringArray=key.split(",")
        var p=Vector2(float(xy[0])*32,float(xy[1])*32)
        if state.terrain[key]=="earth":
            draw_circle(p+Vector2(16,16),24,Color("4b432f"))
        else: draw_rect(Rect2(p,Vector2(32,32)),Color("314348"))
    draw_texture_rect(texture,Rect2(0,0,1536,1024),true,Color(0.55,0.49,0.36,0.18))
    # Ground marks only: rocks and trees remain independent objects.
    for i in 100:
        var p=Vector2(40+posmod(i*173,1450),100+posmod(i*317,880))
        if state.terrain_at(Vector2i(p/32))=="grass":
            draw_line(p,p+Vector2(-4,-8),Color(0.15,0.20,0.10,0.45),1)
            draw_line(p,p+Vector2(3,-10),Color(0.33,0.35,0.16,0.5),1)
