extends SceneTree
const Slots=preload("res://scripts/save_slots.gd")
var failures:=0
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
    if not ok:failures+=1;push_error(message)
func run():
    var original="legacy sentinel"
    var f=FileAccess.open(Slots.LEGACY,FileAccess.WRITE);f.store_string(original);f.close()
    check(not Slots.info(0).valid,"Corrupt existing slot must not become a new slot")
    Slots.choose(1,true)
    var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
    for i in 4:await process_frame
    world.created=true;world.character_name="Second hearth";world.state.timber=31
    check(world.save_game(),"Slot two saves")
    check(FileAccess.get_file_as_string(Slots.LEGACY)==original,"Creating slot two preserves legacy bytes")
    check(Slots.info(1).name=="Second hearth","Slot two summary matches identity")
    check(world.save_game("user://hearth_fire_checkpoint.json"),"Slot checkpoint saves")
    check(FileAccess.file_exists("user://hearth_fire_checkpoint_slot_2.json"),"Checkpoint is slot specific")
    world.queue_free()
    for i in 4:await process_frame
    Slots.choose(2,true)
    world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
    for i in 4:await process_frame
    world.created=true;world.character_name="Third hearth";world.state.timber=9
    check(world.save_game(),"Slot three saves")
    check(Slots.info(1).name=="Second hearth","Third character preserves second character")
    world.queue_free()
    for i in 4:await process_frame
    Slots.choose(1,false)
    world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
    for i in 4:await process_frame
    check(world.character_name=="Second hearth" and world.state.timber==31,"Loading second slot restores its own world and identity")
    check(FileAccess.get_file_as_string(Slots.LEGACY)==original,"All operations preserved legacy save")
    world.queue_free()
    for i in 4:await process_frame
    print("SAVE SLOTS / CHECKPOINTS / LEGACY PRESERVATION: ","PASS" if failures==0 else "FAIL")
    quit(1 if failures else 0)
