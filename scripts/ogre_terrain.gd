extends "res://scripts/opener_terrain.gd"
## Scenic margin for the HUD-aware Ogre camera; collision bounds stay unchanged.
func _draw() -> void:
    draw_texture_rect(texture,Rect2(-512,-512,4608,2432),true)
