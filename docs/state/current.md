# Active pivot — Hearth and Hunger 0.6.1

The user explicitly pivots this same game to nomadic Ogres while retaining OUR established bright illustrated game style. See design/hearth-and-hunger.md, engineering/ogre-pivot.md and source/HEARTH_AND_HUNGER_DIRECTIVE.txt (relative to docs). Old Orc design requirements remain relevant to preserved legacy content, not the new species.

Verified remote archive: archive/chiefs-before-hearth-and-hunger at ebcbd9ed032c51516f089e4954c17f1f5fe08ceb. New work is on feature/hearth-and-hunger. Existing campaigns, appearance, combat and slots remain. New Ogre scene reuses terrain/props/UI/audio and adds a distinct actor, campsite, finite timber/provision collection, cooking and separate validated save. This is an initial playable pivot; Ogre combat, modular equipment, traveling/deploying the camp, beasts and family mechanics are NOT delivered. Do not claim the full overhaul or milestone 1 polish is complete.

0.6.0 source is verified at 571f1b554e8327f372651271f5037351f71be753 (run 41151630352). A final boundary-save correction follows as 0.6.1: physically reachable map edges now survive save/load. The new Ogre suite passes 40 checks. 0.6.1 source/release verification is in progress. Read actual GitHub run/release state before claiming publication. New executable: HearthAndHunger.exe. Save directory remains godot/app_userdata/Chiefs of War; new file wandering_hearth_v1.json leaves prior slots intact. Runtime in this workspace: /tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64; display helper /tmp/hearth-runtime/render.py. Recheck that scratch helpers exist.

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
