# Iron maul footwork

The two transparent reference sheets were generated for Hearth and Hunger using the existing copper-haired Ogre's walking and iron-maul attack art. Both have four cels in each of three viewing angles (front, right, rear). The walk sheet supplies advance and retreat. The strafe sheet supplies separate wide and gathered lateral stances.

The game loads `assets/ogre/iron_maul_walk.png`, a lossless, guttered 992 × 1212 atlas. The top three rows are walking and the bottom three are sidestepping. Normalization uses one scale per authored row, keeping the small shift in height between contacts. The median head position in each cel and the grounded boot line define its registration in `resources/ogre/iron_maul_walk.json`. West uses the whole mirrored profile. A retreat plays the walk contacts in reverse.

The pose crops retain the character, grip, hammer and both boots in a single frame. Exact synchronization between a boot and uneven terrain is outside this version.
