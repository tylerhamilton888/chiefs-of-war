extends Node
## In-engine staging; narrative effects belong to Story, so skip and resume are safe.
var game
var camera_tween: Tween
var actors: Array=[]
func stage(person: String,key: String) -> void:
    finish(false)
    if not is_instance_valid(game.camera):return
    var focal=game.player.position
    if game.npcs.has(person):focal=game.npcs[person].position
    camera_tween=create_tween().set_parallel(true)
    camera_tween.tween_property(game.camera,"offset",focal-game.player.position+Vector2(0,-190),0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    camera_tween.tween_property(game.camera,"zoom",Vector2.ONE*(0.68 if key in ["feast","host_arrival"] else 0.85),0.65)
    if key=="feast":
        for id in ["bramm","svala","astrid"]:
            if game.npcs.has(id):walk(game.npcs[id],Vector2(900+actors.size()*145,1000))
    elif key=="host_arrival" and game.npcs.has("thyra"):walk(game.npcs.thyra,Vector2(1350,1020))
func walk(actor: Node2D,dest: Vector2) -> void:
    actor.enabled=false
    actors.append({"actor":actor,"destination":dest,"phase":0.0})
func _physics_process(delta: float) -> void:
    for entry in actors:
        var actor=entry.actor
        if not is_instance_valid(actor):continue
        var off=entry.destination-actor.position
        if off.length()<5:actor.show_frame(0);continue
        actor.face(off);actor.velocity=off.normalized()*75;actor.move_and_slide()
        entry.phase+=delta*5;actor.show_frame(int(entry.phase)%4)
func finish(reset_camera=true) -> void:
    if is_instance_valid(camera_tween):camera_tween.kill()
    for entry in actors:
        if is_instance_valid(entry.actor):entry.actor.velocity=Vector2.ZERO;entry.actor.show_frame(0)
    actors.clear()
    if reset_camera and is_instance_valid(game.camera):
        game.camera.offset=Vector2(0,-170);game.camera.zoom=Vector2.ONE*0.77
