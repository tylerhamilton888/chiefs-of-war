extends SceneTree
var game
var p
var output=OS.get_environment("CHIEFS_REVIEW_DIR")
var frame_number=0
var caption: Label
func _initialize() -> void:run.call_deferred()
func hold(seconds: float,text: String) -> void:
    caption.text=text
    for i in int(seconds*60):
        await physics_frame
        if i%6==0:
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png(output+"/sequence-%04d.png"%frame_number)
            frame_number+=1
func run() -> void:
    DirAccess.make_dir_recursive_absolute(output)
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game
    await process_frame;await process_frame
    p=game.player;p.controlled=false;p.position=Vector2(1350,1000)
    for foe in game.enemies:foe.set_physics_process(false)
    var layer=CanvasLayer.new();root.add_child(layer)
    caption=Label.new();caption.position=Vector2(360,130);caption.add_theme_font_size_override("font_size",22);layer.add_child(caption)
    p.drive=Vector2.LEFT;await hold(0.8,"Walk west")
    p.drive=Vector2.RIGHT;await hold(0.8,"Walk east")
    p.drive=Vector2.UP;await hold(0.6,"Walk north")
    p.drive=Vector2.DOWN;await hold(0.6,"Walk south")
    p.drive=Vector2.ZERO;p.request("heavy",Vector2.RIGHT);await hold(0.9,"Axe strike")
    p.drive=Vector2.LEFT;await hold(0.7,"Attack -> walk")
    p.drive=Vector2.ZERO;await hold(0.2,"Stop")
    p.start_action("lift",0.7,func():game.state.cargo={"id":"review","kind":"log","yield":{"wood":8}})
    await hold(0.8,"Lift whole trunk")
    p.drive=Vector2.RIGHT;await hold(0.7,"Carry trunk")
    p.drive=Vector2.ZERO;p.guard=100;p.request("heavy",Vector2.LEFT);await hold(1.2,"Full trunk swing")
    p.drive=Vector2.DOWN;await hold(0.6,"Swing -> carry")
    game.state.cargo.clear();p.drive=Vector2.LEFT;await hold(0.6,"Drop -> walk")
    p.drive=Vector2.ZERO;p.weapon="maul";p.guard=100;p.request("heavy",Vector2.RIGHT);await hold(1.1,"Maul strike")
    p.drive=Vector2.RIGHT;await hold(0.6,"Maul -> walk")
    game.set_process(false);p.drive=Vector2.ZERO;p.set_block(true,Vector2.LEFT);await hold(0.5,"Block west");game.set_process(true)
    p.set_block(false,Vector2.LEFT);p.guard=100;p.request("dodge",Vector2.LEFT);await hold(0.4,"Dodge")
    p.drive=Vector2.RIGHT;await hold(0.5,"Dodge -> walk")
    p.drive=Vector2.ZERO;await hold(0.2,"Stop")
    p.start_action("eat",0.8,func():pass);await hold(0.9,"Meal action")
    p.drive=Vector2.UP;await hold(0.5,"Eat -> walk")
    p.drive=Vector2.ZERO;p.weapon="axe";p.position=Vector2(1300,1000)
    game.add_small("animation_meal",p.position+Vector2(75,0),"knife",0)
    var foe=game.enemies.back();foe.active=false;foe.vulnerable=2;game.state.ferocity=100
    game.overpower(true,true);await hold(1.0,"Whole-goblin finisher")
    p.drive=Vector2.LEFT;await hold(0.5,"Finisher -> walk")
    game.prepare_exit();game.queue_free();await process_frame;quit()
