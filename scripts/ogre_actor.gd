extends CharacterBody2D
## Whole-body atlas frames. No skeletal deformation or independent floating equipment.
signal stepped
const FrameArt=preload("res://scripts/ogre_frame_art.gd")
const MOTION_TEXTURE=preload("res://assets/ogre/hearthlord_motion_nordic.png")
const RUN_TEXTURE = preload("res://assets/ogre/hearthlord_run.png")
const Scale=preload("res://scripts/ogre_scale.gd")
const SPECIES="ogre"
const WALK_SPEED := 155.0
const NPC_SPEED := 205.0
const RUN_SPEED := 255.0
const RUN_STRIDE := 168.0
const STRIDE := 142.0
# Profile row 2 has the near arm forward. Row 1 has the opposite contact.
const PROFILE_POSES := [8, 9, 10, 7]
var controlled=true
var drive=Vector2.ZERO
var facing=0
var phase=0.0
var distance_since_step=0.0
var sprite: Sprite2D
var frames: Array=[]
var frame_index=0
var enabled=true
func _ready() -> void:
    frames=JSON.parse_string(FileAccess.get_file_as_string("res://resources/ogre_motion.json"))
    var shape=CollisionShape2D.new()
    var circle=CircleShape2D.new();circle.radius=Scale.radius("ogre",motion_height()/Scale.OGRE_HEIGHT);shape.shape=circle;add_child(shape)
    sprite=Sprite2D.new();sprite.texture=MOTION_TEXTURE
    sprite.region_enabled=true;add_child(sprite)
    show_frame(0)
func face(direction: Vector2) -> void:
    if direction.length_squared()<0.001:return
    facing=(2 if direction.x>0 else 1) if absf(direction.x)>absf(direction.y) else (0 if direction.y>0 else 3)
func motion_height() -> float:return 155.0
func show_frame(index: int) -> void:
    frame_index=clampi(index,0,3)
    var pose: int
    var mirror: bool = facing == 1
    if facing in [1, 2]:
        pose = PROFILE_POSES[frame_index]
    else:
        # Front and back contacts use a whole mirrored pose to alternate feet.
        var contact: bool = frame_index == 3
        pose = (12 if facing == 3 else 0) + (1 if contact else frame_index)
        mirror = contact
    if FrameArt.pose(sprite, MOTION_TEXTURE, pose, motion_height(), mirror):
        return
    var r: Array = frames[floori(pose / 4.0)][pose % 4]
    sprite.texture = MOTION_TEXTURE
    sprite.region_rect = Rect2(r[0]-2, r[1]-2, r[2]+4, r[3]+4)
    sprite.flip_h = mirror
    sprite.scale=Vector2.ONE*motion_height()/280.0
    sprite.position=Vector2(0,-float(r[3])*sprite.scale.y*0.5+3)
func show_run_frame(index: int) -> void:
    frame_index = clampi(index, 0, 3)
    var row := 1
    if facing == 0:
        row = 0
    elif facing == 3:
        row = 2
    # Every drawing has a centered ground anchor at (160, 282).
    var frame := [frame_index * 320, row * 288, 320, 288, 160, 282]
    FrameArt.cell(sprite, RUN_TEXTURE, frame, motion_height() / 280.0, facing == 1)

func _physics_process(delta: float) -> void:
    if not enabled:velocity=Vector2.ZERO;return
    var direction=Input.get_vector("move_left","move_right","move_up","move_down") if controlled else drive.limit_length()
    var running: bool = controlled and Input.is_key_pressed(KEY_SHIFT) and not direction.is_zero_approx()
    var speed := WALK_SPEED if controlled else NPC_SPEED
    if running:
        speed = RUN_SPEED
    velocity=velocity.move_toward(direction*speed,1900*delta)
    var before := position
    move_and_slide()
    var movement := position - before
    var traveled := movement.length()
    if traveled>0.04:
        # When the diagonal is equally strong on both axes, keep the previous
        # viewing angle. Tiny slide/rounding changes should never spin the body.
        if absf(absf(movement.x) - absf(movement.y)) < traveled * 0.08:
            if facing in [1, 2]:
                movement.y = 0.0
            else:
                movement.x = 0.0
        face(movement)
        var stride := RUN_STRIDE if running else STRIDE
        phase=fposmod(phase+traveled/stride,1.0)
        distance_since_step+=traveled
        if distance_since_step>stride*0.5:
            distance_since_step-=stride*0.5;stepped.emit()
        var step := mini(3, int(phase * 4))
        if running:
            show_run_frame(step)
        else:
            show_frame([1, 2, 3, 0][step])
    else:
        phase=0.0;distance_since_step=0;show_frame(0)
func _draw() -> void:
    draw_set_transform(Vector2(0,4),0,Vector2(1,0.38))
    draw_circle(Vector2.ZERO,Scale.radius("ogre",motion_height()/Scale.OGRE_HEIGHT),Color(0.08,0.09,0.06,0.25))
