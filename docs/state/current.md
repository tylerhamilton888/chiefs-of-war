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

# Current implementation state

Updated 2026-10-30. Default branch: `warlord`. Customization and recovered combat are merged into canonical `warlord`. Feature/recovery branches are retained historical checkpoints; new development starts from warlord.

## Implemented on warlord

Existing village/hunting/gathering opener and recovered combat feel changes; independent face/hair/beard/mustache selectors, 8 hair colors, 12 skin tones, 12 cloth colors, color swatches, pose/direction/outfit preview, randomization, and Pause → Appearance for existing campaigns. Old save identity remains intact until explicitly edited. Cancel restores identity and edits do not reset progression. See engineering/customization.md.

Recovered spaced hero/enemy finisher art and gathering transparency fixes are carried forward. The new cosmetic choices use the existing full-body action frames. This is not a new directional combat-animation set or a finished full prologue.

## Validation and delivery

Customization: 73 headless / 74 rendered checks passed. Fresh opener 48, edges 17, motion 20, feel 10 and execution 28 passed; rendered practice isolation/menu passed. Front/left/right/back, both outfits, axe frames and mirrored finisher frames have been rendered for inspection. Published [v0.4.2](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.2), source `2e0de70a05858ef94beb00f8a2113bfb947df4a8`; run `41110249369` passed package, native Windows startup/exit and publication. ZIP `ChiefsOfWar-Windows-0.4.2.zip`: 78,945,015 bytes; SHA-256 `822b115c137d9f0d52e12cef64406c6330067e47a50016dc4fc5500a84121f09`. Native Windows normal and practice startup/exit, path spaces, external working directory and campaign isolation passed with clean game logs. Human graphical playfeel remains unverified.

Packaging follow-up preserves customization/combat, gives the player one root ChiefsOfWar.exe and START HERE.txt, and moves optional practice/technical files to Extras/Support. Ambient audio loops natively and is stopped before graceful exit. Creator and practice sessions can quit without attempting a campaign save. Local customization (73 checks) and practice isolation passed again.

The concurrent reusable publication recovery work is preserved and integrated with this format and the native Windows gate. All 16 release boundary tests pass locally; the canonical workflow is windows-release.yml plus release.json. The historical one-version workflow is retired.

## Remaining broader scope

Publication repair (2026-10-30): reusable GitHub Actions build/release workflow, draft-first verified uploads, safe retries, source-version conflict checks, and retained build/log artifacts replace the one-version publishing setup. Verified source `4e070a985b4b14103d03ebe1e8edaa87791e4ae8`; [run 41108614385](https://github.com/tylerhamilton888/chiefs-of-war/actions/runs/41108614385) passed all 14 publication failure/retry tests, game regressions, rendered UI, Windows export, packaged smoke, ZIP integrity, existing published-download verification, and artifact/log retention. That earlier repair published no game release; 0.4.2 was subsequently delivered by the packaging follow-up above. See engineering/validation-and-release.md for evidence and recovery instructions; ChatGPT's internal error cause is not established.

Block/parry/heavy combat; richer social schedules/family; full invasion/chieftain duel/adoption prologue; expanded world and industry. Male Orc player scope remains; female NPCs remain important characters.

## Later visual overhaul checkpoint (WIP branch only)

The post-0.5.0 art overhaul is incomplete. `wip/orc-art-scale` builds on release source 485491b and includes the experimental hunting station, greener clan idle atlas and lighter grass shading; it is not the published release or a finished overhaul. Godot 4.4.1 import and rendered world/menu/interior/defense review ran in Linux; the original dense new grass candidate was rejected after review. Fresh headless customization: 73 checks, 0 failures; defense timing and 48 pose checks: pass. Earlier unchanged workstation integration passed the 48-check opener suite. A full game-wide art pass, player/animation continuity, portraits, building scale, and native Windows review remain pending.

The latest WIP adds four static ambient Orc residents, including an expectant adult woman, as visual character variety. No pregnancy, birth, or population mechanics are implemented by this art. Equipment remains the existing whole-outfit leather/iron swap; independent armor and weapons are future work. This is not a completed overhaul.
