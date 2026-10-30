extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var world=load("res://scenes/camp.tscn").instantiate()
    root.add_child(world)
    await process_frame
    world.state.timber=6
    for i in 3: world.build_shed()
    world.toggle_worker()
    Engine.time_scale=4
    for i in 900:
        await physics_frame
        if world.stored>=3: break
    Engine.time_scale=1
    print("WORKER stored=",world.stored," position=",world.worker.position," target=",world.worker_target)
    var good=world.stored>=3
    if not good: push_error("Worker failed actual gather/return/deposit route")
    world.queue_free()
    await process_frame
    quit(0 if good else 1)
