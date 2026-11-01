extends SceneTree
const State=preload("res://scripts/frontier/state.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error(label)
func frames(n: int) -> void:
    for i in n:await physics_frame
func _initialize() -> void:run.call_deferred()
func advance(actor,seconds: float) -> void:
    for i in int(ceil(seconds*60)):actor._physics_process(1.0/60.0)
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var game=load("res://scenes/ogre_frontier.tscn").instantiate()
    root.add_child(game);current_scene=game;await frames(3)
    game.set_process(false)
    var p=game.player;p.controlled=false;p.set_physics_process(false)
    for foe in game.enemies:foe.set_physics_process(false)
    for direction in [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
        p.face(direction)
        for source in ["axe","maul","carry_log","carry_spoils","log_attack","work"]:
            if source in ["axe","maul"]:
                p.weapon=source;p.weapon_pose(1)
            else:p.full_pose(source,1)
            p.show_frame(1)
            check(p.sprite.texture.resource_path.ends_with("/hearthlord_motion_nordic.png"),source+" restores walking sheet, facing "+str(p.facing))
    p.weapon="axe";p.face(Vector2.RIGHT);p.show_frame(0)
    var walk_height=p.sprite.region_rect.size.y*p.sprite.scale.y
    p.weapon_pose(0)
    var combat_height=p.sprite.region_rect.size.y*p.sprite.scale.y
    check(absf(walk_height-combat_height)<8,"walking and ready stance keep the same body scale")
    p.mode="idle";p.combat_idle=6;p.drive=Vector2.RIGHT;p.position=Vector2(1250,1150)
    p.weapon_pose(1);p._physics_process(1.0/60.0)
    check(p.sprite.texture.resource_path.ends_with("/hearthlord_motion_nordic.png"),"physics movement restores motion art after attack")
    p.drive=Vector2.ZERO;p.velocity=Vector2.ZERO
    for weapon in ["axe","maul","log"]:
        p.mode="idle";p.guard=100;p.weapon=weapon if weapon!="log" else "axe"
        if weapon=="log":game.state.cargo={"id":"animation_log","kind":"log","yield":{"wood":8}}
        check(p.request("heavy",Vector2.RIGHT),weapon+" heavy starts")
        advance(p,1.3)
        check(p.mode=="idle",weapon+" heavy returns control")
        game.state.cargo.clear();p.drive=Vector2.LEFT;advance(p,0.1)
        check(p.sprite.texture==p.MOTION_TEXTURE and p.sprite.flip_h,weapon+" heavy can return to mirrored walking")
        p.drive=Vector2.ZERO;p.velocity=Vector2.ZERO
    for action in ["lift","butcher","eat"]:
        p.mode="idle"
        p.start_action(action,0.5,func():pass)
        advance(p,0.6);p.drive=Vector2.UP;advance(p,0.1)
        check(p.mode=="idle" and p.sprite.texture==p.MOTION_TEXTURE,action+" returns to north walking")
        p.drive=Vector2.ZERO;p.velocity=Vector2.ZERO
    p.guard=100;p.mode="idle";p.request("dodge",Vector2.LEFT);advance(p,0.4)
    p.drive=Vector2.LEFT;advance(p,0.1)
    check(p.sprite.texture==p.MOTION_TEXTURE,"dodge returns to walking")
    p.drive=Vector2.ZERO;p.set_block(true,Vector2.RIGHT);advance(p,0.1)
    check(p.sprite.texture!=p.MOTION_TEXTURE,"blocking displays the weapon guard")
    p.set_block(false,Vector2.RIGHT);p.drive=Vector2.DOWN;advance(p,0.1)
    check(p.sprite.texture==p.MOTION_TEXTURE,"releasing block returns to walking")
    # Every source revision must have matching complete-pose geometry, not old crops.
    var registrations=p.FrameArt.registrations
    check(registrations.size()==22,"all twenty-two active Ogre/enemy/beast sheets are registered")
    for path in registrations:
        var entry=registrations[path];var texture=load(path)
        check(FileAccess.get_sha256(path)==entry.source_sha256,"frame registration matches exact source: "+path)
        var complete=true
        for frame in entry.frames:
            var r=frame.rect
            complete=complete and Rect2(Vector2.ZERO,texture.get_size()).encloses(Rect2(r[0],r[1],r[2],r[3]))
            for points in frame.polygons:
                var polygon=PackedVector2Array()
                for point in points:polygon.append(Vector2(point[0],point[1]))
                complete=complete and not Geometry2D.triangulate_polygon(polygon).is_empty()
        check(complete,"all poses have valid bounded geometry: "+path)
    # Moving from geometry-clipped art back to the untouched bloody sheet must
    # restore the normal Sprite2D draw and hide the previous geometry.
    var paired=Sprite2D.new();root.add_child(paired)
    p.Atlas.pose(paired,"clinch",0,170)
    var both_figures=true
    for foot in [Vector2(43,458),Vector2(395,466)]:
        var included=false
        for part in paired.get_children():included=included or Geometry2D.is_point_in_polygon(foot,part.uv)
        both_figures=both_figures and included
    check(paired.self_modulate.a==0 and both_figures,"both figures in the first clinch frame render")
    p.Atlas.pose(paired,"devour",0,170)
    var no_ghosts=true
    for child in paired.get_children():no_ghosts=no_ghosts and not child.visible
    check(paired.self_modulate.a==1 and no_ghosts,"bloody finisher restores normal rendering without stale figures")
    paired.queue_free()
    if not is_instance_valid(game.pet):game.add_pet(Vector2(900,1000))
    game.pet.set_physics_process(false);game.state.animal.command="stay"
    game.pet.facing=0;game.pet.sprite.flip_h=true;game.pet.phase=0.6;game.pet._physics_process(1.0/60.0)
    check(game.pet.sprite.flip_h and game.pet.phase==0,"Flint stops in idle without reversing direction")
    var statures=[]
    for row in 3:
        preload("res://scripts/beast_art.gd").pose(game.pet.sprite,row,0,131)
        statures.append(game.pet.sprite.region_rect.size.y*game.pet.sprite.scale.y)
    check(statures.max()-statures.min()<8,"Flint keeps the same stature while turning")
    print("OGRE ANIMATION: %d checks, %d failures"%[checks,failures])
    game.prepare_exit();game.queue_free();await frames(3);quit(1 if failures else 0)
