# Ogre pivot implementation

Base: remote wip/orc-art-scale ebcbd9ed032c51516f089e4954c17f1f5fe08ceb, preserved and verified on archive/chiefs-before-hearth-and-hunger. Local feature/hearth-and-hunger branches from the equivalent local tree. Never replace remote ancestry with the local reconstructed hashes.

New entry: scenes/wandering_hearth.tscn, accessible from the existing title screen or --ogre-hearth. The existing campaign scenes, player and save-slot code are preserved. Terrain, ground shader, props, collision idiom, sound assets and UI styling are reused. No incompatible Ogre head overlays are applied to Orc poses.

scripts/ogre_actor.gd uses a complete-body atlas and resources/ogre_motion.json measured alpha bounds. Directions use front/profile/rear frames; west mirrors the whole east figure; front/rear opposite foot contacts mirror the whole pose. Distance-driven cadence, acceleration and foot collision are separate from sprite presentation. Four-frame stylization and remaining gait quality are explicit review limits. No skeletal deformation, body-part warping or separate hand/tool overlays.

scripts/wandering_hearth_state.gd has a versioned, validated separate save. Temporary-write/rename avoids partial replacement. Malformed saves enter a clearly identified unsaved visit and are never overwritten. The project uses a custom directory matching its old godot/app_userdata/Chiefs of War location on Linux and case-insensitive Windows. Keep both platform paths compatible.

The camp reuses the old world terrain/prop classes. Provisions and timber have persistent pickup IDs; cooking atomically consumes 2 meat + 1 timber and grants 3 stored meals. There is no food buff, eating pose, hunger simulation, rest mechanic or wagon relocation. Camp sprite polygons are UV boundaries to exclude neighbor silhouettes in the source atlas, not body deformation.

Validation: tests/ogre_hearth_test.gd covers movement, idle, collision, pose dimensions, single-use pickups, cooking costs, persistence, menu return, malformed saves and legacy isolation. tests/ogre_hearth_visual.gd captures title, camp, all sixteen direction/pose combinations and pause screen using actual Godot rendering. Native Windows smoke includes --ogre-hearth and checks the old campaign sentinel after Ogre startup.

Release 0.6.2 uses HearthAndHunger.exe and HearthAndHunger-Windows-0.6.2.zip. release.py/package_windows.py read the new manifest names with legacy defaults so historical release audits still work.
