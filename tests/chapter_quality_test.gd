extends SceneTree
## Regression checks for revisits, interrupted story beats and player-facing framing.
const State=preload("res://scripts/chapter/state.gd")
var game
var checks=0
var failures=0
func check(value: bool,message: String) -> void:
    checks+=1
    if not value:failures+=1;push_error("CHAPTER QUALITY: "+message)
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
    for i in n:await physics_frame
func settle() -> void:
    game.player.controlled=false;game.player.drive=Vector2.ZERO
    game.camera.reset_smoothing();await frames(3);game.camera.force_update_scroll()
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    game.choose("work")
    # A second visit must not consume another feast or rewind the chapter.
    game.state.chapter=2;game.state.mark("hunt_won");game.state.inventory.meat=10
    game.story.action("feast");game.choose("close")
    var meat=game.state.inventory.meat
    game.story.action("feast")
    check(game.state.inventory.meat==meat,"feast cannot charge twice")
    if game.dialog_mode:game.choose("close")
    game.state.chapter=9;game.story.action("feast")
    check(game.state.chapter==9,"stale feast cannot rewind progress")
    if game.dialog_mode:game.choose("close")
    # Rescue markers can remain nearby after a rescue; repeated E is harmless.
    game.state.chapter=4;game.travel("crossing",Vector2(1000,1050),true);await frames(2)
    game.choose("close")
    game.state.defeated.append_array(["defense_0","defense_2"])
    var rescue={"kind":"rescue","id":"bramm"}
    game.interact(rescue);var loyalty=game.state.relationships.bramm.loyalty
    game.interact(rescue)
    check(game.state.relationships.bramm.loyalty==loyalty,"rescue relationship credit is awarded once")
    game.finish_defense();game.choose("duel");await frames(3)
    game.player.hp=17;game.dialogue("mercy");game.finish_dialogue();game.choose("join")
    check(game.state.region=="host" and game.player.hp==160,"arrival recovery survives travel and save")
    game.choose("close")
    game.story.action("thyra");loyalty=game.state.relationships.thyra.loyalty
    game.story.action("thyra")
    check(game.state.relationships.thyra.loyalty==loyalty,"welcome cannot farm loyalty")
    game.state.chapter=8;game.story.action("bargain")
    var admiration=game.state.relationships.eydis.admiration
    game.story.action("bargain")
    check(game.state.relationships.eydis.admiration==admiration,"negotiation cannot farm admiration")
    game.story.action("contract")
    check(game.state.has("bargained"),"agreed terms remain fixed")
    # A local rebuild may not teleport the player back to the previous autosave.
    game.state.chapter=9;game.state.inventory.wood=8;game.state.inventory.hide=2;game.state.inventory.coin=25
    game.player.position=Vector2(1700,1130);var before=game.player.position
    game.story.action("wagon")
    check(game.player.position.distance_to(before)<1,"buying a wagon preserves the player's current position")
    game.choose("close")
    # Save/resume through the actual scene, not just parsing a state object.
    game.dialogue("host_arrival");game.state.scene.cursor=1;game.save_progress()
    game.prepare_exit();game.queue_free();await frames(3)
    game=load("res://scenes/fire_we_carry.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    check(game.dialog_mode and game.state.scene.key=="host_arrival" and game.state.scene.cursor==1,"reload resumes the dialogue cursor")
    check(not game.player.enabled,"resumed dialogue freezes gameplay")
    game.choose("close");check(game.player.enabled,"closing resumed dialogue restores control")
    # Check body framing at every world corner, above both HUD panels.
    for at in [Vector2(90,90),Vector2(2170,90),Vector2(90,1310),Vector2(2170,1310)]:
        game.player.position=at;await settle()
        var feet=game.player.get_global_transform_with_canvas()*Vector2.ZERO
        var head=game.player.get_global_transform_with_canvas()*Vector2(0,-160)
        check(feet.y<688 and head.y>134 and feet.x>70 and feet.x<1210,"HUD-safe body at "+str(at))
    # Road entrances follow the destination's connecting road, including bends.
    game.travel("cairn",Vector2(1080,180),true);await frames(2)
    for entry in game.stations:
        if entry.kind=="road" and entry.id=="pass":game.interact(entry);break
    check(game.state.region=="pass" and game.player.position.distance_to(Vector2(1980,900))<1,"bent route arrives at the connecting east entrance")
    # Dead bodies must no longer retain a live threat state.
    game.state.chapter=5;game.travel("crossing",Vector2(1100,1040),true);await frames(3)
    var boss=game.npcs.hrothgar;boss.enabled=false;boss.receive_hit(620,Vector2.RIGHT)
    check(game.state.scene.key=="victory","victory still resolves after the quality fixes")
    game.choose("join");game.choose("close")
    game.prepare_exit();game.queue_free();await frames(3)
    print("CHAPTER QUALITY: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
