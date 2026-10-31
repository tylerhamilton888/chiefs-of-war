extends CharacterBody2D
## Whole-body atlas frames. No skeletal deformation or independent floating equipment.
signal stepped
const SPECIES="ogre"
const WALK_SPEED=205.0
const STRIDE=92.0
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
    var circle=CircleShape2D.new();circle.radius=22;shape.shape=circle;add_child(shape)
    sprite=Sprite2D.new();sprite.texture=preload("res://assets/ogre/hearthlord_motion.png")
    sprite.region_enabled=true;add_child(sprite)
    show_frame(0)
func face(direction: Vector2) -> void:
    if direction.length_squared()<0.001:return
    facing=(2 if direction.x>0 else 1) if absf(direction.x)>absf(direction.y) else (0 if direction.y>0 else 3)
func show_frame(index: int) -> void:
    frame_index=clampi(index,0,3)
    # The reviewed side view faces east. Mirror the complete illustrated body for west.
    var row=2 if facing==1 else facing
    # Front/rear silhouette has a symmetric outfit. Mirror the complete contact
    # pose for the second footfall; keep each pose whole, never deform limbs.
    var mirror_contact=facing in [0,3] and frame_index==3
    var r: Array=frames[row][1 if mirror_contact else frame_index]
    sprite.region_rect=Rect2(r[0]-2,r[1]-2,r[2]+4,r[3]+4)
    sprite.flip_h=facing==1 or mirror_contact
    sprite.scale=Vector2.ONE*0.55
    sprite.position=Vector2(0,-float(r[3])*0.55*0.5+3)
func _physics_process(delta: float) -> void:
    if not enabled:velocity=Vector2.ZERO;return
    var direction=Input.get_vector("move_left","move_right","move_up","move_down") if controlled else drive.limit_length()
    velocity=velocity.move_toward(direction*WALK_SPEED,1900*delta)
    var before=position
    move_and_slide()
    var traveled=position.distance_to(before)
    if traveled>0.04:
        face(velocity)
        phase=fposmod(phase+traveled/STRIDE,1.0)
        distance_since_step+=traveled
        if distance_since_step>STRIDE*0.5:
            distance_since_step-=STRIDE*0.5;stepped.emit()
        show_frame([1,2,3,0][mini(3,int(phase*4))])
    else:
        phase=0.0;distance_since_step=0;show_frame(0)
func _draw() -> void:
    draw_set_transform(Vector2(0,4),0,Vector2(1,0.38))
    draw_circle(Vector2.ZERO,32,Color(0.08,0.09,0.06,0.25))
