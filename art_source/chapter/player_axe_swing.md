# Hunting axe swing

Each 1536 × 1024 RGBA source sheet was generated using the matching three-quarter front, back or side poses cropped from the active `assets/chapter/player_combat_nordic.png`. The three originals are named `player_axe_front_swing_master.png`, `player_axe_back_swing_master.png` and `player_axe_side_swing_master.png`. The Ogre's fur mantle, red hair and beard, bracers, front tabard and two-handed axe grip follow the campaign character.

The runtime sheets in `assets/chapter/` each have six full-body drawings arranged in two rows. Side and front are 1152 × 800 pixels. Back is 1152 × 832 to accommodate the overhead reach. The packing pass retained the silhouette and antialiased outline of each drawing, removed faint alpha residue and normalized scale to the chapter's 292-pixel height reference.

The matching files in `resources/chapter/` give each frame region and its ground anchor relative to the region's top left. The sequence runs from ready to overhead backswing, downswing, contact, low follow-through and recovery. The side drawing faces east and mirrors for west. The front view uses a foreshortened diagonal cut toward the camera. The rear view turns the shoulders away, transferring weight onto the forward boot.

These are authored-pose assets. Their extraction was checked for intersecting frame regions, orphan pixels and invalid foot anchors. Motion acceptance depends on the game actor, animation timing and the normal-speed gameplay review.
