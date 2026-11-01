extends SceneTree
const Atlas=preload("res://scripts/frontier/atlas.gd")
var game
var p
var board: CanvasLayer
var panel: Control
var output=OS.get_environment("CHIEFS_REVIEW_DIR")
func _initialize() -> void:run.call_deferred()
func page(title: String) -> void:
    if is_instance_valid(panel):panel.queue_free();await process_frame
    panel=Control.new();board.add_child(panel)
    var bg=ColorRect.new();bg.color=Color("46524c");bg.size=Vector2(1280,800);panel.add_child(bg)
    label(title,Vector2(20,10),22)
func label(text: String,at: Vector2,size: int=16) -> void:
    var item=Label.new();item.text=text;item.position=at;item.add_theme_font_size_override("font_size",size);panel.add_child(item)
func show_pose(sprite: Sprite2D,index: int,text: String,cols: int=4) -> void:
    var at=Vector2(160+index%cols*(1280.0/cols),240+int(index/cols)*245)
    var ground=ColorRect.new();ground.color=Color("a9d2a0");ground.position=at-Vector2(80,0);ground.size=Vector2(160,1);panel.add_child(ground)
    var copy=sprite.duplicate();copy.visible=true;copy.position+=at;panel.add_child(copy)
    label(text,at+Vector2(-145,12),15)
func shot(name: String) -> void:
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(output+"/animation-"+name+".png")
func run() -> void:
    DirAccess.make_dir_recursive_absolute(output)
    game=load("res://scenes/ogre_frontier.tscn").instantiate();root.add_child(game);current_scene=game
    await process_frame;await process_frame
    game.hide();game.set_process(false);game.set_physics_process(false)
    p=game.player;p.controlled=false;p.set_physics_process(false)
    for foe in game.enemies:foe.set_physics_process(false)
    board=CanvasLayer.new();root.add_child(board)
    await page("Walking after combat / carrying / work")
    var i=0
    for direction in [Vector2.DOWN,Vector2.RIGHT,Vector2.UP]:
        p.face(direction)
        for source in ["axe","carry_log","work","player_maul"]:
            if source=="axe":p.weapon_pose(1)
            else:p.full_pose(source,1)
            p.show_frame(1);show_pose(p.sprite,i,source+" -> walk");i+=1
    await shot("transitions")
    for sheet in ["walk","axe","maul","carry_log","carry_spoils","log_attack","work"]:
        await page(sheet+" | whole poses, shared foot line")
        for row in 3:
            p.face([Vector2.DOWN,Vector2.RIGHT,Vector2.UP][row])
            for frame in 4:
                if sheet=="walk":p.show_frame(frame)
                elif sheet in ["axe","maul"]:p.weapon=sheet;p.weapon_pose(frame)
                else:p.full_pose(sheet,row*4+frame)
                show_pose(p.sprite,row*4+frame,str(row)+" / "+str(frame))
        await shot(sheet)
    for sheet in ["overpower","clinch","devour","spearmen"]:
        await page(sheet+" | paired poses and enemy frames")
        var sprite=Sprite2D.new();panel.add_child(sprite);sprite.hide()
        for frame in 8:
            Atlas.pose(sprite,sheet,frame,145 if sheet=="clinch" else 170)
            show_pose(sprite,frame,str(frame))
        await shot(sheet)
    await page("Clan walking | complete right-facing bodies")
    i=0
    for id in ["astrid","bramm","dorrik","eydis","gorund","hrothgar","runa","svala","thyra"]:
        var actor=load("res://scripts/chapter/actor.gd").new();actor.identity=id;actor.controlled=false;actor.enabled=false
        root.add_child(actor);actor.face(Vector2.RIGHT);actor.show_frame(1);show_pose(actor.sprite,i,id);actor.queue_free();i+=1
    await shot("clan")
    await page("Flint | consistent stature, all authored directions")
    var beast_sprite=Sprite2D.new();panel.add_child(beast_sprite);beast_sprite.hide()
    for row in 3:
        for frame in 4:
            preload("res://scripts/beast_art.gd").pose(beast_sprite,row,frame,135)
            show_pose(beast_sprite,row*4+frame,str(row)+" / "+str(frame))
    await shot("flint")
    await page("Ridgeback | whole silhouettes, all twelve poses")
    var hunt_sprite=Sprite2D.new();panel.add_child(hunt_sprite);hunt_sprite.hide()
    for frame in 12:
        Atlas.pose(hunt_sprite,"great_beast",frame,165);show_pose(hunt_sprite,frame,str(frame))
    await shot("ridgeback")
    game.prepare_exit();game.queue_free();await process_frame;quit()
