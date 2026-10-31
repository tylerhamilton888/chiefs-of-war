extends SceneTree
const State=preload("res://scripts/wandering_hearth_state.gd")
const Slots=preload("res://scripts/save_slots.gd")
var failures=0
var checks=0
func _initialize():call_deferred("run")
func frames(n: int):
    for i in n:await physics_frame
func check(ok: bool,message: String):
    checks+=1
    if not ok:failures+=1;push_error(message)
func run():
    var legacy=FileAccess.open(Slots.LEGACY,FileAccess.WRITE);legacy.store_string("legacy campaign sentinel");legacy.close()
    check(ProjectSettings.globalize_path("user://").to_lower().contains("godot/app_userdata/chiefs of war"),"Renamed game must use original save directory")
    if FileAccess.file_exists(State.SAVE):DirAccess.remove_absolute(ProjectSettings.globalize_path(State.SAVE))
    change_scene_to_file("res://scenes/wandering_hearth.tscn");await frames(8)
    var world=current_scene
    var player=world.player
    check(player.SPECIES=="ogre","New scene has distinct Ogre actor")
    player.controlled=false;player.drive=Vector2.RIGHT
    var start=player.position
    await frames(30)
    check(player.position.x>start.x+70,"Ogre responds to movement")
    check(player.facing==2,"East travel faces east")
    player.drive=Vector2.ZERO;await frames(12)
    check(player.velocity.length()<1,"Movement stops without sliding")
    check(player.frame_index==0,"Idle returns to grounded standing pose")
    for edge in [Vector2(1000,90),Vector2(1000,1310)]:
        player.position=edge;player.drive=Vector2.UP if edge.y<100 else Vector2.DOWN
        await frames(40)
        player.drive=Vector2.ZERO;await frames(8)
        check(world.save_progress(),"Map-edge position saves")
        var at_edge=State.new()
        check(at_edge.load_game() and at_edge.player_position.distance_to(player.position)<0.1,"Reachable northern/southern boundary survives reload")
    player.position=Vector2(790,800);player.drive=Vector2.UP;await frames(70)
    check(player.position.y>660,"Wagon footprint blocks walking through its hull")
    player.drive=Vector2.ZERO;player.position=Vector2(940,790);await frames(8)
    for facing in 4:
        player.facing=facing
        for frame in 4:
            player.show_frame(frame)
            check(player.sprite.region_rect.size.y>260 and player.sprite.region_rect.size.y<300,"Full-body frame has consistent height")
    world.interact(world.supplies[0]);world.interact(world.supplies[0])
    check(world.state.inventory.wood==2,"Collected timber cannot duplicate")
    world.interact(world.stations[3]);world.interact(world.stations[3])
    check(world.state.inventory.meat==6,"Starting provisions cannot duplicate")
    world.interact(world.stations[0])
    check(world.state.inventory.meals==3 and world.state.inventory.wood==1 and world.state.inventory.meat==4,"Cooking consumes exact resources and grants meals")
    check(world.save_progress(),"New progress saves")
    var saved=State.new();check(saved.load_game(),"Ogre save loads")
    check(saved.inventory==world.state.inventory and saved.collected==world.state.collected,"Save round trip preserves food and collected resources")
    world.show_panel("A test","Movement pauses during conversation.")
    check(not player.enabled,"Menu locks movement")
    world.close_modal();check(player.enabled,"Closing menu returns control")
    world.return_to_menu();await create_timer(0.2).timeout;await frames(8)
    check(current_scene.has_method("ogre_hearth"),"Return reaches renamed title")
    current_scene.ogre_hearth();await frames(8)
    check(current_scene.state.inventory.meals==3,"Title entry resumes Ogre progress")
    check(FileAccess.get_file_as_string(Slots.LEGACY)=="legacy campaign sentinel","Ogre play never touches legacy campaign")
    var bad=FileAccess.open(State.SAVE,FileAccess.WRITE);bad.store_string("broken save sentinel");bad.close()
    var invalid=State.new();check(not invalid.load_game(),"Malformed save rejected")
    check(not invalid.save_game() and FileAccess.get_file_as_string(State.SAVE)=="broken save sentinel","Malformed save protected from automatic overwrite")
    current_scene.queue_free();await frames(3)
    print("OGRE HEARTH: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
