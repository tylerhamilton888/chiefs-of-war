extends SceneTree
const State=preload("res://scripts/frontier/state.gd")
var game
var checks=0
var failures=0
func check(ok: bool, message: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("CREATOR: "+message)
func frames(n: int) -> void:
    for i in n:await process_frame
func _initialize() -> void:run.call_deferred()
func run() -> void:
    DirAccess.remove_absolute(State.SAVE)
    var legacy=State.new();legacy.inventory.wood=19;legacy.region="forest"
    var old=legacy.pack();old.erase("player_name");old.erase("appearance")
    var file=FileAccess.open(State.SAVE,FileAccess.WRITE);file.store_string(JSON.stringify(old));file.close()
    var migrated=State.new();check(migrated.load_game(),"original frontier save loads")
    check(migrated.player_name=="Ogre" and migrated.appearance=="copper" and migrated.inventory.wood==19,"legacy save retains its world and default appearance")
    var invalid=migrated.pack();invalid.appearance="does-not-exist"
    check(not migrated.valid(invalid),"unknown styles are rejected")
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game;await frames(3)
    game.player.controlled=false;var old_wood=game.state.inventory.wood;var old_region=game.state.region
    game.open_creator(false)
    check(game.modal.visible and not game.player.enabled,"creator opens and pauses the world")
    check(game.creator_style.item_count==4,"four explicit appearance choices")
    game.creator_name.text="  Borgrim  ";game.creator_style.select(2);game.update_creator_preview(2)
    check(game.state.appearance=="copper" and game.state.player_name=="Ogre","preview does not edit current character")
    check(game.creator_preview.material.get_shader_parameter("palette")==2,"preview uses selected color")
    game.commit_creator()
    check(not game.modal.visible and game.player.enabled,"confirm restores control")
    check(game.state.player_name=="Borgrim" and game.state.appearance=="gold","name and selected style are applied")
    check(game.player.sprite.material.get_shader_parameter("palette")==2,"gameplay sprite uses chosen palette")
    check(game.state.region==old_region and game.state.inventory.wood==old_wood,"appearance edit preserves progress")
    var reloaded=State.new();check(reloaded.load_game() and reloaded.player_name=="Borgrim" and reloaded.appearance=="gold","identity survives save and reload")
    game.open_creator(false);game.creator_name.text="Different";game.creator_style.select(1);game.update_creator_preview(1);game.close_modal()
    check(game.state.player_name=="Borgrim" and game.state.appearance=="gold","cancel leaves identity unchanged")
    game.open_creator(false);game.creator_name.text="   ";game.commit_creator()
    check(game.modal.visible and game.state.player_name=="Borgrim","empty name is rejected without closing")
    game.close_modal();game.state.unreadable=true;game.open_creator(false);game.creator_name.text="Failed";game.creator_style.select(3);game.commit_creator()
    check(game.state.player_name=="Borgrim" and game.state.appearance=="gold" and game.modal.visible,"failed save rolls back identity")
    game.state.unreadable=false;game.close_modal()
    game.player.position=Vector2(1200,1100);game.state.ferocity=100
    game.add_small("appearance_foe",game.player.position+Vector2(75,0),"knife",0)
    var foe=game.enemies.back();foe.active=false;foe.vulnerable=2
    check(game.overpower(true),"feeding finisher starts")
    check(game.execution_sprite.material!=game.player.sprite.material and game.execution_sprite.material.get_shader_parameter("palette")==2,"paired animation carries an independent copy of selected look")
    game.execution_tick(0.23)
    check(game.execution_sprite.material.get_shader_parameter("hair_region")!=Vector4.ZERO,"paired art targets the Ogre’s head")
    game.finish_execution(false)
    game.player.weapon_pose(1);check(game.player.sprite.material.get_shader_parameter("palette")==2,"combat keeps chosen palette")
    print("FRONTIER CREATOR: %d checks, %d failures"%[checks,failures])
    game.prepare_exit();game.queue_free();await frames(4);quit(1 if failures else 0)
