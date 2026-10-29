extends CharacterBody2D
## Whole-frame animation only. No skeleton, body-part rotation or sprite deformation.
const SPEED := 145.0
var facing := 0
var equipment := "leather"
var phase := 0.0
var inspect_mode := false
var manual_frame := 0
var sprite := Sprite2D.new()
var frame_rects: Array = []
var walked := 0.0
var last_frame := -1
var last_facing := -1

func _ready() -> void:
    collision_layer = 2
    collision_mask = 1
    var shape := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 13.0
    shape.shape = circle
    add_child(shape)
    frame_rects = JSON.parse_string(FileAccess.get_file_as_string("res://resources/orc_walk_candidate.json"))
    sprite.texture = load("res://assets/characters/orc_walk_candidate.png")
    sprite.region_enabled = true
    sprite.scale = Vector2.ONE * 0.37
    add_child(sprite)
    update_frame(1)

func _physics_process(delta: float) -> void:
    if inspect_mode:
        velocity = Vector2.ZERO
        update_frame(manual_frame)
        return
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = direction * SPEED
    if direction.length_squared() > 0.01:
        if absf(direction.x) > absf(direction.y):
            facing = 1 if direction.x < 0 else 2
        else:
            facing = 3 if direction.y < 0 else 0
    var before := position
    move_and_slide()
    var distance := position.distance_to(before)
    walked += distance
    if distance > 0.02:
        phase += distance / 18.0
        update_frame(int(phase) % 4)
    else:
        phase = 0.0
        update_frame(1)
    queue_redraw()

func update_frame(index: int) -> void:
    if last_frame == index and last_facing == facing:
        return
    var r: Array = frame_rects[facing][index]
    sprite.region_rect = Rect2(r[0], r[1], r[2], r[3])
    # Align all full-body illustrations to a shared foot anchor.
    sprite.position = Vector2(0, -float(r[3]) * 0.185 + 4)
    last_frame = index
    last_facing = facing

func _draw() -> void:
    draw_set_transform(Vector2(0, 0), 0, Vector2(1, 0.38))
    draw_circle(Vector2.ZERO, 20, Color(0.05, 0.07, 0.04, 0.36))

func equip(set_name: String) -> void:
    if not set_name in ["leather", "iron"]:
        return
    equipment = set_name
    var asset := "orc_iron_candidate" if equipment == "iron" else "orc_walk_candidate"
    frame_rects = JSON.parse_string(FileAccess.get_file_as_string("res://resources/" + asset + ".json"))
    sprite.texture = load("res://assets/characters/" + asset + ".png")
    last_frame = -1
    update_frame(1)
