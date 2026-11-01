# Hearth and Hunger 0.8.10 — A World of Goliaths

The Ogre scale standard now governs the playable chapter and frontier:

- Small humanoid footprints occupy one unit, Orcs/large humanoids two, and adult Ogres four in a 2×2 footprint. Movement remains continuous; there is no tile grid. Height and width retain the art's natural proportions.
- Collision bodies follow species and individual Ogre stature. Elders remain larger; the ridgeback grows to a 240px silhouette and a 128px body diameter. Flint has a consistent pack-beast stature.
- Small-peoples settlement buildings and their collisions are reduced together. Dunmere's reeve uses the smaller Orc model instead of Bramm's Ogre body. Ogre camps retain their broad caravan spaces.
- AI steering sweeps each creature's full collision body. Melee contact and thrown-body impacts use actual target radii.
- Existing saves, character art, complete-pose animations, log weapon and adult combat content are preserved.

Fresh local checks: scale 13, navigation 200 across all 14 regions, frontier systems 84, animation 90, chapter 94, chapter quality 17, brutality 31 and creator 22. All passed, as did 100 rendered layout checks and 18 release-tool checks. Reviewed native Godot OpenGL images of the scale lineup, camp, Dunmere, ridgeback den and champion region. Windows release validation additionally exercises the archived regressions, export and native startup.

This is a scale/clearance pass, not a replacement animation set or a new interior/demolition system. Buildings remain exterior obstacles; collision is deliberately simpler than the drawn silhouette. Human playfeel and balance testing remain pending.
