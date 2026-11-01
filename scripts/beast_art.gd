extends RefCounted
## Whole stone-eater poses, with one visual stature and a grounded foot anchor.
const FrameArt=preload("res://scripts/ogre_frame_art.gd")
const TEXTURE=preload("res://assets/chapter/beast.png")
const ROW_HEIGHTS=[273.0,376.0,381.0]
static func pose(sprite: Sprite2D,row: int,frame: int,height: float,mirror=false) -> void:
    FrameArt.pose(sprite,TEXTURE,row*4+clampi(frame,0,3),height*273.0/ROW_HEIGHTS[row],mirror)
