extends SceneTree
var checks:=0
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
    checks+=1
    if not ok:failures+=1;push_error(message)
func frames(n: int):
    for i in n:await process_frame
func run():
    var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world);await frames(10)
    world.show_creator();await frames(10)
    check(world.creator.size.y<=740 and world.creator.position.y+world.creator.size.y<=800,"creator fits viewport")
    world.appearance={"version":1,"face":1,"hair":3,"beard":2,"mustache":1,"hair_color":3};world.complexion=5;world.cloth=3
    for key in world.creator_selectors:world.creator_selectors[key].selected=world.complexion if key=="complexion" else world.cloth if key=="cloth" else world.appearance[key]
    world.apply_look();world.update_preview()
    check(world.player.look_material.get_shader_parameter("face_id")==1,"world appearance receives face")
    check(world.portrait_shader.get_shader_parameter("hair_id")==2,"portrait receives chosen hair")
    await frames(8)
    if DisplayServer.get_name()!="headless":
        await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png(OS.get_environment("CHIEFS_REVIEW_DIR").path_join("creator.png"))
    world.name_input.text="Thorgar";world.begin_character();await frames(4)
    var pos: Vector2=world.player.position;world.ore=7;world.meat=4
    check(world.save_game("user://custom_test.json"),"appearance save writes")
    world.appearance.face=0;world.complexion=0;world.cloth=0
    check(world.load_game("user://custom_test.json"),"appearance save reloads")
    check(world.appearance.face==1 and world.appearance.hair==3 and world.appearance.beard==2 and world.appearance.mustache==1 and world.appearance.hair_color==3 and world.complexion==5 and world.cloth==3,"all appearance fields round trip")
    world.edit_appearance();world.randomize_appearance();world.cancel_appearance()
    check(world.appearance.face==1 and world.complexion==5 and world.cloth==3,"cancel restores prior appearance")
    check(world.player.position==pos and world.ore==7 and world.meat==4,"editing does not reset campaign")
    var data=JSON.parse_string(FileAccess.get_file_as_string("user://custom_test.json"));data.opener.erase("appearance");data.opener.complexion=2;data.opener.cloth=2
    var f=FileAccess.open("user://legacy.json",FileAccess.WRITE);f.store_string(JSON.stringify(data));f.close()
    check(world.load_game("user://legacy.json") and world.appearance.version==0 and world.complexion==2 and world.cloth==2,"old saves keep legacy head and palettes")
    data.opener.appearance={"face":999,"hair":-5,"beard":"bad","mustache":99,"hair_color":99};data.opener.complexion=999;data.opener.cloth=-100
    f=FileAccess.open("user://bad_look.json",FileAccess.WRITE);f.store_string(JSON.stringify(data));f.close()
    check(world.load_game("user://bad_look.json") and world.appearance.face==2 and world.appearance.hair==0 and world.complexion==11 and world.cloth==0,"out-of-range and malformed customization is sanitized")
    world.appearance=world.Appearance.defaults();world.appearance.hair=3;world.apply_look()
    for outfit in ["leather","iron"]:
        world.player.equip(outfit)
        for direction in 4:
            world.player.facing=direction
            for i in 4:
                world.player.phase=i;world.player.show_locomotion(true)
                check(world.player.look_material.get_shader_parameter("head_direction")==direction,"walking head follows facing")
                world.player.show_attack(i)
                check(world.player.look_material.get_shader_parameter("head_direction")==direction,"attack head follows facing")
    print("CUSTOMIZATION CHECKS: %s; FAILURES: %s"%[checks,failures])
    world.queue_free();await frames(3);quit(1 if failures else 0)
