extends Node2D
## Region-local sounds at the crossing. The work animations cue one-shots
## at contact; the cooking fire is the only continuous layer.
const FIRE := preload("res://assets/audio/hearth/small_fire.ogg")
const HAMMERS := [
    preload("res://assets/audio/hearth/axle_strike.wav"),
    preload("res://assets/audio/hearth/axle_strike_low.wav")
]
const SPOON := preload("res://assets/audio/hearth/stir.wav")
const LADLE := preload("res://assets/audio/hearth/serve.wav")

var chapter
var fire: AudioStreamPlayer2D
var wagon: AudioStreamPlayer2D
var pot: AudioStreamPlayer2D
var next_strike := 0
var suspended := false

func start(game, fire_position: Vector2) -> void:
    chapter = game
    fire = source(800.0, -14.0)
    fire.global_position = fire_position
    fire.stream = FIRE
    fire.play()
    wagon = source(1000.0, -11.0)
    pot = source(650.0, -13.0)

func source(reach: float, level: float) -> AudioStreamPlayer2D:
    var player := AudioStreamPlayer2D.new()
    player.max_distance = reach
    player.attenuation = 1.35
    player.volume_db = level
    add_child(player)
    return player

func _process(delta: float) -> void:
    if not is_instance_valid(fire) or not is_instance_valid(chapter.modal):
        return
    var menu_open: bool = chapter.modal.visible and not chapter.dialog_mode
    if menu_open != suspended:
        suspended = menu_open
        fire.stream_paused = suspended
        if suspended:
            wagon.stop()
            pot.stop()
    var target := -21.0 if chapter.dialog_mode else -14.0
    fire.volume_db = move_toward(fire.volume_db, target, delta * 30.0)

func cue(kind: String, at: Vector2) -> void:
    if suspended or chapter.leaving or (is_instance_valid(chapter.modal) and chapter.modal.visible and not chapter.dialog_mode):
        return
    var voice: AudioStreamPlayer2D
    match kind:
        "hammer":
            voice = wagon
            voice.stream = HAMMERS[next_strike]
            next_strike = (next_strike + 1) % HAMMERS.size()
        "stir":
            voice = pot
            voice.stream = SPOON
        "serve":
            voice = pot
            voice.stream = LADLE
        _:
            return
    voice.volume_db = (-11.0 if voice == wagon else -13.0) - (6.0 if chapter.dialog_mode else 0.0)
    voice.global_position = at
    voice.play()

func stop() -> void:
    set_process(false)
    for voice in [fire, wagon, pot]:
        if is_instance_valid(voice):
            voice.stop()
            voice.stream = null

func _exit_tree() -> void:
    stop()
