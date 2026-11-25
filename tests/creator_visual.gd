extends SceneTree

const Preview = preload("res://tools/art_preview.gd")
const State = preload("res://scripts/chapter/state.gd")

func _initialize() -> void:
    run.call_deferred()

func run() -> void:
    var output := OS.get_environment("CHIEFS_REVIEW_DIR")
    if output.is_empty() or FileAccess.file_exists(State.SAVE):
        push_error("Creator capture needs CHIEFS_REVIEW_DIR and an empty test save directory")
        quit(1)
        return
    DirAccess.make_dir_recursive_absolute(output)
    change_scene_to_file("res://scenes/main_menu.tscn")
    for i in 3:
        await process_frame
    current_scene.launch_campaign()
    var creator = current_scene.content.get_child(0)
    creator.set_process(false)
    creator.preview.show_frame(1)
    var bounds := Rect2(Vector2.ZERO, root.size)
    for control in [creator.name_edit, creator.clan_edit, creator.hair_select, creator.background_select, creator.start]:
        if not bounds.encloses(control.get_global_rect()):
            push_error("Creator control falls outside viewport: " + control.name)
            quit(1)
            return
    await RenderingServer.frame_post_draw
    var first := root.get_texture().get_image()
    var frame: Rect2i = Rect2i(creator.preview.get_parent().get_global_rect())
    creator.hair_select.select(3)
    creator.hair_select.item_selected.emit(3)
    await process_frame
    await RenderingServer.frame_post_draw
    var recolored := root.get_texture().get_image()
    if recolored.get_region(frame).get_data() == first.get_region(frame).get_data():
        push_error("The palette choice did not change the rendered Ogre")
        quit(1)
        return
    if Preview.save(recolored, output.path_join("creator.webp")) != OK:
        quit(1)
        return
    print("Creator layout and visible Ogre palette change: passed")
    quit()
