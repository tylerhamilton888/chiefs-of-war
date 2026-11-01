extends Camera2D
## Keep the whole actor between the HUD panels, including at world boundaries.
var gameplay_zoom=0.77
func _ready() -> void:
    position_smoothing_enabled=true;position_smoothing_speed=10
    reset_gameplay()
func reset_gameplay() -> void:
    position=Vector2(0,-95);offset=Vector2.ZERO;zoom=Vector2.ONE*gameplay_zoom
    limit_left=-180;limit_right=2440;limit_top=-320;limit_bottom=1580
func allow_dialogue_pan() -> void:
    # Speakers stand above the dialogue panel, even in the southern camp.
    limit_left=-512;limit_right=2772;limit_top=-512;limit_bottom=1920
