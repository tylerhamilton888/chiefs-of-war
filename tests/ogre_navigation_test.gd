extends SceneTree
## Physics-backed reachability plus a real walked opening task; no campaign saves.
var game
var grid: AStarGrid2D
var checks=0
var failures=0
func _initialize() -> void:run.call_deferred()
func check(value: bool,message: String) -> void:
    checks+=1
    if not value:failures+=1;push_error("OGRE NAVIGATION: "+message)
func frames(n: int) -> void:
    for i in n:await physics_frame
func build_grid() -> void:
    grid=AStarGrid2D.new();grid.region=Rect2i(0,0,54,32);grid.cell_size=Vector2(40,40);grid.offset=Vector2(80,80)
    grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER;grid.update()
    var shape=CircleShape2D.new();shape.radius=preload("res://scripts/ogre_scale.gd").body_radius(game.player)+3
    var query=PhysicsShapeQueryParameters2D.new();query.shape=shape;query.collision_mask=1
    for x in 54:
        for y in 32:
            var id=Vector2i(x,y);query.transform=Transform2D(0,grid.get_point_position(id))
            grid.set_point_solid(id,not game.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty())
func nearest_cell(at: Vector2) -> Vector2i:
    var best=Vector2i(-1,-1);var distance=INF
    for x in 54:
        for y in 32:
            var id=Vector2i(x,y)
            if grid.is_point_solid(id):continue
            var d=at.distance_squared_to(grid.get_point_position(id))
            if d<distance:best=id;distance=d
    return best
func accessible(at: Vector2,from: Vector2) -> bool:
    var start=nearest_cell(from);var goal=nearest_cell(at)
    return grid.get_point_position(goal).distance_to(at)<110 and not grid.get_id_path(start,goal).is_empty()
func walk(at: Vector2) -> bool:
    game.player.controlled=false;build_grid()
    var path=grid.get_point_path(nearest_cell(game.player.position),nearest_cell(at))
    if path.is_empty():return false
    for point in path:
        var budget=100
        while game.player.position.distance_to(point)>8 and budget>0:
            game.player.drive=(point-game.player.position).normalized();budget-=1;await physics_frame
        if budget<=0:game.player.drive=Vector2.ZERO;return false
    game.player.drive=Vector2.ZERO;await frames(8);return true
func press_e() -> void:
    var e=InputEventKey.new();e.keycode=KEY_E;e.pressed=true;game._unhandled_input(e)
func audit_region(name: String) -> void:
    await frames(3);game.freeze(true);build_grid()
    var origin=game.player.position
    check(grid.get_point_position(nearest_cell(origin)).distance_to(origin)<65,name+" arrival has walkable ground")
    for entry in game.stations+game.supplies:
        check(accessible(entry.position,origin),name+" reachable "+entry.kind+" "+entry.get("id",""))
    for id in game.npcs:
        check(accessible(game.npcs[id].position,origin),name+" reachable "+id)
func run() -> void:
    DirAccess.remove_absolute("user://fire_we_carry_v1.json")
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3);game.choose("work")
    for i in 3:
        var entry=game.supplies[i]
        check(await walk(entry.position),"walk to timber "+str(i))
        check(game.nearest.get("id","")==entry.id,"timber prompt selected by actual proximity")
        press_e()
    check(game.state.inventory.wood==6,"three walked E interactions gather six timber")
    check(await walk(Vector2(740,770)),"walk to damaged wagon")
    check(game.nearest.get("kind","")=="repair","repair prompt is reachable without teleporting")
    press_e();await frames(3)
    check(game.state.has("repaired") and game.state.inventory.wood==0,"walked opening task repairs the axle and spends resources")
    game.state.chapter=2;game.state.mark("hunt_won");game.travel("crossing",Vector2(1080,1000),true)
    await audit_region("chapter/crossing")
    game.state.chapter=10;game.state.mark("own_wagon");game.state.mark("saved_bramm");game.state.mark("saved_dorrik")
    for region in ["pines","hollow","cairn","pass","host","trade"]:
        game.travel(region,Vector2(1080,1100),true);await audit_region("chapter/"+region)
    for region in game.ROADS:
        for road in game.ROADS[region]:
            game.travel(region,Vector2(1080,1100),true)
            game.interact({"kind":"road","id":road[0]});await frames(2)
            check(game.state.region==road[0],region+" road reaches "+road[0])
            var linked=game.stations.filter(func(e):return e.kind=="road" and e.id==region)
            check(linked.size()==1 and game.player.position.distance_to(linked[0].position)<=110,"arrival is beside the return road from "+road[0])
    game.prepare_exit();game.queue_free();await frames(3)
    DirAccess.remove_absolute("user://ogre_frontier_v1.json")
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    for region in game.TITLES:
        game.player.mode="idle";game.travel(region,Vector2(1080,1090),true);await audit_region("frontier/"+region)
    game.prepare_exit();game.queue_free();await frames(3)
    print("OGRE NAVIGATION: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
