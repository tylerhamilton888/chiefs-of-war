extends SceneTree
func _initialize():call_deferred("run")
func run():
 var file=FileAccess.open("user://ancestral_hearth_v1.json",FileAccess.WRITE);file.store_string("campaign sentinel");file.close()
 var world=load("res://scenes/opener.tscn").instantiate();root.add_child(world)
 for i in 12:await process_frame
 var ok=world.practice_mode and world.created and world.forged and world.modal.visible and world.player.position.distance_to(Vector2(850,970))<1
 ok=ok and not world.save_game() and not world.load_game()
 ok=ok and FileAccess.get_file_as_string("user://ancestral_hearth_v1.json")=="campaign sentinel"
 world.close_modal();world.pause_menu()
 for i in 5:await process_frame
 if DisplayServer.get_name()!="headless":ok=ok and world.modal.size.y<=760
 if not ok:push_error("practice entry, campaign isolation or menu layout failed")
 print("PRACTICE ISOLATION / ENTRY / MENU: ","PASS" if ok else "FAIL")
 world.queue_free()
 for i in 3:await process_frame
 quit(0 if ok else 1)
