# Hearth and Hunger 0.8.1 — Choose Your Ogre, published and verified

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.1
Windows: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.1/HearthAndHunger-Windows-0.8.1.zip
Exact source d5210694d81ab763a4496ef33c07ac3a83aa7f58 (tree 576ecb535113df823060782b7cc425bd20af7f51); successful release workflow 41210251235. ZIP size 155413386 bytes; SHA-256 d31077e3c750399a1c606db94fd18b4dbf7c5473045a213464f76e0826077530. GitHub confirms an uploaded ZIP and checksum on the public prerelease. The workflow checked the downloaded assets and native Windows startup, including the frontier entry.

The user requested a character creator with a few styles. A first visit to Sundered Frontier opens a name field and a live preview with copper, dark, golden and silver hair/beard palettes. These are color presets of the existing illustrated body and hairstyle, not independently authored hair/face shapes; some red accents can be recolored. Returning players can choose Esc → Change your Ogre’s name and look without losing progress. Old 0.8.0 frontier saves load with the original default and gain optional identity fields; Chapter One uses its own protagonist/save. Name and palette follow movement, combat, hauling and paired finishers; hand-authored shader regions improve palette consistency in devour poses.

Validation: 19 creator tests including legacy save, cancel, validation, rollback and reload; a separate first-start/continue test; 29 existing frontier combat checks; complete release regressions; actual Godot renders of all presets and log/feeding poses inspected; native Windows launch and publication verification passed. This is still an early playtest; additional independently drawn hairstyles, faces, body types and Chapter One creator support are not implemented. User playtest and art acceptance remain pending.

Development branch feature/hearth-and-hunger and release/v0.8.1 preserve upstream ancestry; local reconstructed commit SHAs differ. The source release is an empty release commit on top of feature source with the same tree. Respond to user feedback or continue the Ogre Experience directive when asked.

---

# Hearth and Hunger 0.8.0 — Sundered Frontier playtest, published and verified

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.0
Windows: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.0/HearthAndHunger-Windows-0.8.0.zip
Source 7e15412fa57eedbabb573b51b14c9e67fe8e64b6; release workflow 41208280590 completed successfully; Windows ZIP 155411499 bytes, SHA-256 8797d9dcc60f300eb36aa4b45ba3419736229f3e988e967606e92ed2bc9c6299. GitHub reports a public prerelease with ZIP and checksum. The workflow verifies the downloaded release assets and native Windows startup/clean exit including the frontier, path spaces and isolated saves.

The user requested more adult Ogre feeding, including biting off limbs and swallowing small goblins whole, and the trunk used as a weapon. In Sundered Frontier: lift the trunk with E, then LMB or R / Shift+LMB for light/heavy log attacks; X sets it down and the wagon accepts it as cargo. Earn Ferocity by connecting or parrying, stagger or critically wound a goblin, then G bites an arm or Shift+G swallows the goblin. F throws a staggered goblin or enters a champion clinch. New generated whole-body art is integrated; full blood defaults on with a restrained option. Sources and prompts: docs/BRUTALITY_ART_PROMPTS.md. Earlier Chapter One and campaign saves remain separate.

Verification: 29 frontier gameplay, animation-anchor, save, throw-collision, interrupted-lift and contract checks; all release regressions; inspected actual Godot gameplay captures, including log, bite and swallow; Windows package and checksum, exported frontier entry, native Windows launch and release upload/download verified. A visual capture exposed a previously misplaced finisher sprite, fixed before this release. This is an early playtest: human judgment of feel and art, balance, and additional tests of the wider frontier systems remain pending. It does not claim the whole long-term Ogre-world directive is complete. No new user feedback on 0.8.0 has yet been received.

Development branch feature/hearth-and-hunger; immutable release/v0.8.0 and tag preserve the released source. GitHub SHA differs from local reconstructed history; compare trees and preserve upstream ancestry. The next step is to respond to the user's 0.8.0 playtest, or continue the remaining Ogre Experience work from docs/design/ogre-experience.md if directed.

---

# Hearth and Hunger — verified Chapter One delivery

**v0.7.0 is published and verified.** Source c4f401f5b91b7653a31fbc13ab39391d72ed6de8; tree e8afa9a0e9aed49ed12643ee3ea476d447113173; successful workflow 41160548157. Download https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.7.0/HearthAndHunger-Windows-0.7.0.zip (140637873 bytes), SHA256 af71b8d52ddda9a081d63a895f068e1a3399b6532c274a7ebb9f42eba3f63252.

Read `docs/state/current.md`, `docs/design/chapter-one.md`, `docs/engineering/chapter-one.md`, and the user's preserved `docs/source/FIRE_WE_CARRY_DIRECTIVE.txt`. The requested playable chapter and later portrait/brutality revision are integrated in this release. The chapter reaches a personal hearth through actual work, hunting, combat, rescue consequences, a duel with alternate outcomes, the larger host, physical caravan movement and paid contracts.

Latest user feedback: portraits looked too similar; cutscenes felt like an animated Hobbit rather than a game for adults. Three portrait sheets were revised with distinct facial structures, age, scars and expressions. Full-brutality cinematic artwork adds bloody aftermath and Gorund's severed head, with mature proportions/expressions and matching dialogue; the restrained option remains available. Default for new chapters is full. A generated caravan continuity error was corrected before integration. See `docs/CHAPTER_ART_REVISION.json` for prompts and source images.

Validation: twelve regression suites, 92 chapter checks, 17 release-tool tests, inspected actual engine renders, exact-package smoke, native Windows startup/clean exit for all modes, and verified publication/download. Human playfeel and final art acceptance remain pending. Broad weapon/armor wardrobes, tactical party AI and generational family simulation are not delivered; do not claim otherwise.

Current feature branch `feature/hearth-and-hunger`; safety archive `archive/before-fire-we-carry`. Published source is local 18201cad41250e009f073dc45bf4d4b09263f811, remote c4f401f5b91b7653a31fbc13ab39391d72ed6de8; trees match. This handoff is a documentation-only follow-up. Never force reconstructed history onto upstream or mutate the published tag. Do not touch The Stellar Holds or unrelated default-branch work.

Launch `--chapter-one`; independent save `user://fire_we_carry_v1.json`. Earlier Ogre and campaign slots remain intact. Tests use isolated XDG_DATA_HOME. New suite command: `--headless --fixed-fps 60 --script tests/chapter_test.gd -- --test`, no --fresh. Local runtime `/tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64`; graphics helper `/tmp/hearth-runtime/render_chapter.py` uses Xvfb TCP because Unix sockets are unavailable here. `tests/chapter_visual.gd` captures the real game, revised portraits and both gore treatments.

Next action: respond to the user's playtest/art feedback against this actual build. Any new implementation should receive a fresh version and the existing release workflow; source-only delivery is insufficient. If interrupted during future publication, inspect actual GitHub run/release state before retrying. No additional user permission is needed for already requested development and build delivery.
