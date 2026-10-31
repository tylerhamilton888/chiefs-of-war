# Active pivot — Hearth and Hunger 0.6.2

Published and verified: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.6.2

- Release source: 25e9b4bfcdbfa847a86a59b05a3d91aef0158b31 (tree 2273e4b630e298df6ede90d9ca28ad32b3625d4c).
- Successful run: 41152724848, including imports/regressions, actual Godot rendering, export/package, native Windows startup/clean exit and downloaded-release integrity verification.
- Windows ZIP: HearthAndHunger-Windows-0.6.2.zip, 110668478 bytes.
- SHA-256: f3de3c7e5265e361b6faf74da5d590e9b43a6974470cbc621a5f3464a22d4030.
- Extract All, launch HearthAndHunger.exe, choose Enter the wandering hearth.

The user explicitly pivots this same game to nomadic Ogres while retaining OUR established bright illustrated style. The new concept boards supply anatomy/cultural/architecture ideas only. Read docs/design/hearth-and-hunger.md, docs/engineering/ogre-pivot.md and the complete docs/source/HEARTH_AND_HUNGER_DIRECTIVE.txt. Older Orc design requirements describe preserved legacy campaigns, not the new species.

Verified archive: archive/chiefs-before-hearth-and-hunger at ebcbd9ed032c51516f089e4954c17f1f5fe08ceb. Current development: feature/hearth-and-hunger; the default warlord branch remains older. The local reconstructed commit hashes differ from connector commits; compare trees and preserve actual remote ancestry. This handoff is a documentation-only follow-up to the released source.

Implemented: distinct male Ogre body and directional whole-body idle/walk frames, collidable wagon/canvas campsite, woodland exploration, persistent finite timber/provision collection, cooking stored meals, separate validated save and title/menu return. Reuses original terrain, props, audio and UI style. New Ogre suite: 40 checks, including movement, collision, resource costs, pickup duplication, map-edge save/load, menu control and legacy/malformed-save preservation. The audio mixer is stopped/released before scene exit. Save directory remains godot/app_userdata/Chiefs of War; new file wandering_hearth_v1.json. Existing characters, appearance, combat, hunting and three slots remain accessible under Earlier campaigns.

This is an initial playable pivot, NOT the complete overhaul or a claim of final animation polish. User review of proportions, game-scale readability and four-frame/mirrored gait remains pending. New Ogre combat, equippable weapons/armor, traveling/deploying the camp, beasts and new male/female/family NPC systems are not delivered. Cooking currently grants stored meals; no eating animation or buff is implemented. Follow the explicit milestones: refine/accept the living Ogre, then a convincing combat encounter before expanding systems.

Native Windows headless normal/new-character/practice/Ogre launches, clean exits, path spaces, external working directories and campaign isolation passed. Actual graphical engine views were inspected on Linux; native Windows graphical playfeel and human fun/acceptance remain unverified. No new permission is needed to continue already requested development or releases.

Earlier attempts: 0.6.0 publication was blocked by intermittent active-audio exit leakage. 0.6.1 at d521c44a5238c7ff3b4c5c13d42ab81a8717078a passed its native run and published before the audio correction arrived; use 0.6.2 with BOTH the map-boundary and audio fixes. Run 41152314672 correctly refused to replace immutable 0.6.1 with another source. Do not retry that source under the published tag.

Current scratch runtime: /tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64; render helper /tmp/hearth-runtime/render.py. Recheck existence, isolate XDG_DATA_HOME, use the repository's suite-specific flags. Terminal Git push lacks authentication; GitHub connector blob/tree/commit/ref sync is proven. Do not replace upstream history.

---

## Historical handoff below (superseded where inconsistent)

# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Canonical state

Canonical development branch: `warlord`. The customization and recovered combat changes are merged there; do not reconstruct or re-merge them from old chats. The clear-launch source `2e0de70a05858ef94beb00f8a2113bfb947df4a8` and concurrent recovery checkpoint `2767978d3ccec559075f346cdd8fcca55942036a` are reconciled with both ancestries retained. Historical feature/recovery branches are retained for traceability. Local workspace paths below are optional runtime aids, not the source of truth. Preserve any surviving uncommitted work in older workspaces.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Verified delivery / next step

Published [v0.4.2](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.2), source `2e0de70a05858ef94beb00f8a2113bfb947df4a8`; run `41110249369` passed package, native Windows startup/exit and publication. ZIP `ChiefsOfWar-Windows-0.4.2.zip`: 78,945,015 bytes; SHA-256 `822b115c137d9f0d52e12cef64406c6330067e47a50016dc4fc5500a84121f09`. Native Windows normal and practice startup/exit, path spaces, external working directory and campaign isolation passed with clean game logs. Human graphical playfeel remains unverified.

The current download is Extract All → ChiefsOfWar.exe, with START HERE.txt at the root. No Godot installation is needed. Existing customization/combat and save location are preserved. Shutdown was repaired: audio stops before tree teardown; creator/practice quit without a campaign save; a failed campaign save keeps the game open. Local customization (73 checks), practice isolation and normal/practice startup passed.

Concurrent publication recovery from `2767978` is retained. The canonical reusable windows-release.yml now uses the clear package helper and native Windows job before its draft-first verified publication. release.json is 0.4.2 with package_layout clear-launch; release.py validates both old/new layouts. All 16 failure/retry/layout tests pass locally. The already-triggered one-version run delivered 0.4.2 before reconciliation; its workflow is removed on warlord. Never republish that tag from a new source. Future releases use the reusable runbook and a new version.

Next: gather user appearance/combat/gathering feedback; do not automatically expand scope. ChatGPT unknown-error internals remain unavailable; repository corruption was not established.

## Runtime

Current verified local Godot 4.4.1 executable: `/workspace/scratch/5065e2351aee/runtime/godot-complete`. The former Godot runtime under `/workspace/scratch/dcdfb20f8502/runtime` is no longer present. Do not assume a previous scratch runtime survives. The checked-in release workflows provision Godot 4.4.1 and matching export templates independently. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. All source/art changes are remotely committed. Verify actual branch heads for subsequent checkpoints. Never force-push or replace repository ancestry.

## Repository readiness audit — 2026-10-30

Confirmed default branch is warlord; feature/orc-customization was identical to its head at audit start. Release source is an ancestor of that head, with documentation-only follow-up changes. Release assets and successful CI were verified against GitHub. Original master-brief checksum and all 19 section assignments across eight shards verified. Current scene/script literal resource references resolve. No build executables, archives or .godot cache are tracked. Stale unmerged-combat notes were corrected. See engineering/validation-and-release.md for the proven Actions publication path and the empty historical v0.4.0 release. Gameplay code and published artifacts were not changed by this audit.

## Active 0.5.0 follow-up

User requested main menu/multiple saves, a large building-led art pass, tighter combat including block/parry and better animations, then clarified classic fantasy adult female clothing. Implemented on feature/hearth-menu-and-combat; tests and release preparation are in progress. Read engineering/hearth-and-steel.md for ownership and prompt provenance. Do not mistake 0.4.2 for this new work.

## WIP art overhaul after 0.5.0

Start from the remote `wip/orc-art-scale` branch (based on 0.5.0 commit 485491b), not stale default-branch status. The current pass introduces a candidate hunting-workstation decoration, greener clan NPC poses, and a brighter ground treatment. These are not the complete art overhaul. The workstation is decorative, not an implemented meat-processing interaction. Terrain and NPC candidates are generated illustrations; user acceptance and complete visual review remain pending. Existing hero, movement/combat, enemies, interiors, UI, doorway scale and portraits still require a coherent pass, and home placement/expansion is not implemented. Preserve 0.5.0 save and appearance compatibility. Consult the latest visual direction in state/decisions.md. A grass candidate with dense yellow foliage was rejected during in-engine inspection.

For local graphics in this environment, the Xvfb build cannot create Unix sockets; run Xvfb with `-nolisten unix -listen tcp` and Godot with `DISPLAY=127.0.0.1:95`. An extracted libXfont2 needs `LD_LIBRARY_PATH=/workspace/scratch/5065e2351aee/runtime/xfont/usr/lib/x86_64-linux-gnu`. Isolate XDG_DATA_HOME. Do not infer native Windows or human playfeel from this.

Further art WIP adds four static ambient Orc residents, including an expectant mother. They are not simulated families or interactive NPCs. Future equipment needs to support multiple weapons and armor while maintaining full-body visual coherence and existing appearance saves; present leather/iron swaps remain the existing prototype, not a modular equipment implementation. The complete art overhaul remains unfinished; see current.md for remaining work.

A further WIP pass adds green clan portraits and a restyled wolf atlas, maintaining existing atlas layouts. Opener test passed 48/48 after import; Linux rendered opener and wolf screenshot completed. Player rest/stride/strike restyle candidates are being generated but are not integrated yet; their frame and appearance registrations need verification before replacing any existing assets.

Player candidates are now preserved under `assets/motion/source/overhaul/`: rest, stride and strike in leather and iron. They are **not integrated**: all six are 1341×1173, whereas existing motion atlases are 2048×1792; independently generated poses differ in placement. Reauthor and visually validate every frame and head/foot registration, weapon grip, all appearance overlays, defense and finisher continuity before switching runtime references. Current player has not been overhauled. Source candidates are excluded from export by existing preset. The complete art overhaul is not finished.

The latest user feedback rejects the hunch in the six player motion candidates. `assets/motion/source/overhaul/rest_upright_candidate.png` is an exploratory replacement idle sheet, not integrated: the new upright side silhouette is closer, but outfit colors changed and walking, attacks, dodge, executions, appearance registration and equipment sets must be made consistent. Do not mix incompatible full-body sets in the shipped player.
