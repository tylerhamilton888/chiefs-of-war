extends SceneTree
const Scale=preload("res://scripts/ogre_scale.gd")
var game
var checks=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(ok: bool,message: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("OGRE SCALE: "+message)
func frames(n: int) -> void:
    for i in n:await physics_frame
func run() -> void:
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(4)
    game.freeze(true)
    check(is_equal_approx(Scale.body_radius(game.player),Scale.radius("ogre")*game.player.height/160.0),"player footprint reflects stature")
    game.add_raider("scale_goblin",Vector2(1000,1000),"goblin")
    game.add_raider("scale_orc",Vector2(1200,1000),"orc")
    var small=game.enemies[-2];var large=game.enemies[-1];small.active=false;large.active=false
    check(is_equal_approx(pow(Scale.body_radius(large)/Scale.body_radius(small),2),2),"large humanoid occupies twice the small humanoid area")
    check(is_equal_approx(pow(Scale.radius("ogre")/Scale.body_radius(small),2),4),"adult ogre occupies four small humanoid areas")
    # A real 48px doorway admits a small body but blocks an Ogre. An 80px
    # caravan passage admits our Ogre. Obstacles live outside the authored map.
    var wall=StaticBody2D.new();root.add_child(wall)
    for x in [-1,1]:
        var col=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(200,80)
        col.shape=shape;col.position=Vector2(5000+x*124,5000);wall.add_child(col)
    await frames(3)
    small.position=Vector2(5000,4900);game.player.position=small.position
    check(Scale.clear_step(small,Vector2(0,200)),"small humanoid can cross small doorway")
    check(not Scale.clear_step(game.player,Vector2(0,200)),"Ogre cannot fit through small doorway")
    for col in wall.get_children():col.position.x+=16*signf(col.position.x-5000)
    await frames(3)
    check(Scale.clear_step(game.player,Vector2(0,200)),"Ogre caravan passage clears full body")
    wall.queue_free()
    game.travel("trade",Vector2(1080,1090),true);await frames(4);game.freeze(true)
    var buildings=0
    for node in game.world.get_children():
        if node.get_script()==load("res://scripts/building.gd"):
            buildings+=1
            check(is_equal_approx(node.panels[0].scale.x,0.72*(0.56 if node.kind==0 else 0.6)),"small settlement art uses its own scale")
            check(is_equal_approx(node.body.get_child(0).shape.size.x,78*0.72),"settlement collision matches art")
    check(buildings==3,"all trade post buildings checked")
    game.prepare_exit();game.queue_free();await frames(3)
    print("OGRE SCALE: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
