# Hearth and Hunger — Chapter One handoff

Read `docs/state/current.md`, `docs/design/chapter-one.md`, and `docs/engineering/chapter-one.md`. The latest user attachment is preserved verbatim in `docs/source/FIRE_WE_CARRY_DIRECTIVE.txt`; it requests actual Godot implementation of The Fire We Carry, not a documentation-only plan. The user's established illustrated art style remains governing.

The ten-step chapter is implemented and locally traversed through real gathering, cooking, combat, rescues, duel, caravan escort, contract and personal wagon. Nine distinct Ogres and expression portraits are integrated. Six cinematic illustrations support actual Godot staging/dialogue. The chapter remains a first playable release candidate with human art/playfeel judgment pending; do not label generated frames human-drawn or claim unimplemented family/equipment systems.

Current development: `feature/hearth-and-hunger`; pre-change safety branch `archive/before-fire-we-carry`. A synced WIP exists at 023d676fc2aaaaa606897ddd7c65e35a51763d27. Preserve actual upstream ancestry: local reconstructed SHAs differ from connector commits even when trees match.

Current deliverable target: 0.7.0 prerelease, release.json, notes docs/RELEASE_0_7_0.md. Fresh local twelve-suite regression pass, 92 Chapter One checks, 17 release-tool tests, actual Linux rendered scene/UI review and normal active-audio chapter exit. Next: sync tested candidate, create release/v0.7.0 at exact remote source, inspect workflow and published ZIP/checksum before claiming release completion. If interrupted, query GitHub first; a tool error does not mean publication failed. No new user permission is needed for requested implementation/build delivery.

Launch: `--chapter-one`; save: `user://fire_we_carry_v1.json`. Earlier Ogre and legacy slots remain independent. Runtime: `/tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64`. Isolate XDG_DATA_HOME. New test: `--headless --fixed-fps 60 --script tests/chapter_test.gd -- --test` (no --fresh). `tests/chapter_visual.gd` captures actual frames. Graphics helper `/tmp/hearth-runtime/render_chapter.py` uses Xvfb TCP because Unix sockets are unavailable here.

Do not change The Stellar Holds or overwrite unrelated work on `warlord`. The default branch remains older. Previous verified Windows build is v0.6.2; current.md records exact source/run/checksum. Future equipment must retain whole-body pose coherence rather than floating tools or skeletal deformation.

Latest steering during release preparation: portraits looked too similar; user wants more adult brutality rather than an animated-Hobbit tone. New portrait and full-brutality cinematic variants are being integrated before publication. Current synced pre-revision source: 4ef9960d7fcd780ad296a1e60b29067bd7742621. Do not publish that earlier source in place of the requested revision.
