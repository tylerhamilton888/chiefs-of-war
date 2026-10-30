# Chiefs of War — current handoff

Published 0.3.1 Iron Stride: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.3.1
Release source: 6317ff0ee1c96e6e0aa9dff5b3c42eca830ad43e; tree 8fff79253cda10c5ba6db72bc4881d7aa560ca38.

User direction: original hulking Orcs with Garrosh-like mass, broad tusked beastly faces, near-neckless shoulders, enormous forearms/hands and short thick legs. Earlier sprites were too human and their forearm pumping overwhelmed the leg movement. Do not return to those proportions. Preserve the rugged hand-inked 2D direction and square-aligned architecture. The new assets are generated illustrations, not human-drawn.

Implemented: matched leather/iron stride, planted idle and axe poses; updated player portrait and male interior figures. Fixed shared ground/pelvis anchors, slower distance-based cycle, no sped-up walk during dodge. Main scene scenes/opener.tscn. Existing 0.3 saves preserved. Female NPC art was not changed.

Verification: 127 gameplay checks plus 20 motion/import checks passed. Exported Windows PCK passed 20 motion and 48 complete-opening checks under Linux Godot. Actual OpenGL motion, creator and village/interior views reviewed. Native Windows hardware and human playfeel not tested. Four-keyframe cycles still have pose/detail continuity limits; don't describe the animation as final.

Published Windows ZIP: 68,396,119 bytes; SHA256 ab63c813947ac3786745e6989a47822ca92db71bb1a1273b9f04f4c4d0d43406. Motion preview: 441,246 bytes; SHA256 d6093a9afb03a162297ba66a478f5a171be9122ad05398139db20afb44378d05. Both GitHub asset digests matched local files. Release tag points to the source above. Release includes SHA256SUMS.txt.

Local project from this session: /workspace/scratch/4589cb0adcd5/chiefs-of-war. Local git 176b548 has the same release tree but a separate parent history from GitHub; use the canonical GitHub main when continuing. Do not force-push local history. Art source atlases and deterministic packing tool are committed. Source atlas RGB matte is under transparent alpha; preserve alpha when inspecting.
