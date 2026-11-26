# Unarmed Ogre run

The approved in-game Hearthlord walk atlas supplied the character reference. The two PNGs in this folder are the original generated drawing studies. The four-by-three sheet supplied the running cycle. The separate right-facing contact supplies the opposite leg extension and opposing near-arm swing in profile.

The playable file is `assets/ogre/hearthlord_run.png`. Its three rows face the camera, right, and away. West mirrors right. Each 320 × 288 cell has its ground line at y=282 and its center at x=160. Columns follow contact, gather, opposite contact, opposite gather. Passing poses sit slightly above the ground line. Front and rear use whole-pose mirrors for the opposite contact. Transparent background speckle was removed before packing. The rendered height reference remains 280 pixels, as on the walk atlas.

To check the transition and contact order, run `tests/hearth_walk_test.gd` in Godot 4.4.1 with an isolated user-data directory. In the campaign, walk using WASD and hold Shift on clear ground. Inspect horizontal travel from both sides, then run toward and away from the camera.
