# Ogre creator — work in progress

The user requested a player character creator with a few styles. The new Sundered Frontier creator asks for a name and offers four beard-color presets on the existing complete-body illustrated animation frames. First visit opens it; existing saves keep their progress and may open it via Esc → Change your Ogre’s name and look. Old frontier saves without appearance keys migrate to the original look; Chapter One has a separate protagonist/save. This is palette customization, not independently authored facial or hairstyle shapes. See tests/frontier_creator_test.gd and tests/frontier_first_start_test.gd. The saved character’s palette is shared with the paired execution sprite; inspect all presets, including finishing moves, and check if this unintentionally recolors other actors.

Local first-start and 19 creator checks pass. Actual Godot renders of all four presets and selected log/feeding actions were inspected; full release workflow and a new Windows release are pending; do not claim 0.8.1 is published. Prior 0.8.0 remains the current published playtest.

---

# Hearth and Hunger 0.8.0 — Sundered Frontier playtest, published and verified

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.0
Windows: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.0/HearthAndHunger-Windows-0.8.0.zip
Source 7e15412fa57eedbabb573b51b14c9e67fe8e64b6; release workflow 41208280590 completed successfully; Windows ZIP 155411499 bytes, SHA-256 8797d9dcc60f300eb36aa4b45ba3419736229f3e988e967606e92ed2bc9c6299. GitHub reports a public prerelease with ZIP and checksum. The workflow verifies the downloaded release assets and native Windows startup/clean exit including the frontier, path spaces and isolated saves.

The user requested more adult Ogre feeding, including biting off limbs and swallowing small goblins whole, and the trunk used as a weapon. In Sundered Frontier: lift the trunk with E, then LMB or R / Shift+LMB for light/heavy log attacks; X sets it down and the wagon accepts it as cargo. Earn Ferocity by connecting or parrying, stagger or critically wound a goblin, then G bites an arm or Shift+G swallows the goblin. F throws a staggered goblin or enters a champion clinch. New generated whole-body art is integrated; full blood defaults on with a restrained option. Sources and prompts: docs/BRUTALITY_ART_PROMPTS.md. Earlier Chapter One and campaign saves remain separate.

Verification: 29 frontier gameplay, animation-anchor, save, throw-collision, interrupted-lift and contract checks; all release regressions; inspected actual Godot gameplay captures, including log, bite and swallow; Windows package and checksum, exported frontier entry, native Windows launch and release upload/download verified. A visual capture exposed a previously misplaced finisher sprite, fixed before this release. This is an early playtest: human judgment of feel and art, balance, and additional tests of the wider frontier systems remain pending. It does not claim the whole long-term Ogre-world directive is complete. No new user feedback on 0.8.0 has yet been received.

Development branch feature/hearth-and-hunger; immutable release/v0.8.0 and tag preserve the released source. GitHub SHA differs from local reconstructed history; compare trees and preserve upstream ancestry. The next step is to respond to the user's 0.8.0 playtest, or continue the remaining Ogre Experience work from docs/design/ogre-experience.md if directed.

---

# Hearth and Hunger 0.7.0 — published and verified

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.7.0

- Exact source: c4f401f5b91b7653a31fbc13ab39391d72ed6de8; tree e8afa9a0e9aed49ed12643ee3ea476d447113173.
- Successful workflow: 41160548157, https://github.com/tylerhamilton888/chiefs-of-war/actions/runs/41160548157.
- Windows ZIP: HearthAndHunger-Windows-0.7.0.zip, 140637873 bytes.
- SHA256: af71b8d52ddda9a081d63a895f068e1a3399b6532c274a7ebb9f42eba3f63252.
- Extract All, run HearthAndHunger.exe, choose The Fire We Carry · Chapter One.

## Governing direction

Read `docs/source/FIRE_WE_CARRY_DIRECTIVE.txt`, `docs/design/chapter-one.md` and `docs/engineering/chapter-one.md`. Continue this existing Godot 4.4.1 project. Retain our bright, chunky, inked illustrated style. Ogres of both sexes never weaken merely from aging; the ancient leaders are the largest, most formidable figures. Latest user steering explicitly requested more distinct facial structures and more adult brutality, rejecting the interchangeable faces/animated-Hobbit tone.

## Implemented

The ten-step chapter is playable from Bramm's wagon repair and Svala's first portion through tracking/hunting, the feast, the burning of Emberhide, a timed rescue battle, Hrothgar's genuine duel, joining the larger Stonebelly Host, clearing and physically escorting a wagon through Sundered Pass, a negotiated goblin contract, and an independent wagon/hearth. Seven connected regions, nine individually illustrated principal NPCs, directional whole-body frames, expressive portraits, six cinematic moments, camera/character staging, written dialogue, choices and scene resume are integrated. Bramm/Dorrik rescue outcomes change the later cast. Hrothgar has both mercy and exceptional-victory outcomes; valid attacks are never ignored.

The final portrait revision changes faces, age, nose/eye shapes, scars and asymmetric expressions while retaining identities. The full cinematic treatment shows bloodied aftermath, Gorund's severed head, the threat of the challenge and a battered player. A caravan continuity error was corrected: the living leader is Hrothgar, not Gorund. New chapters default to full brutality. Esc → Brutality selects restrained art/dialogue and combat effects; the option persists. Prompt/provenance records: `docs/CHAPTER_ART_PROMPTS.json` and `docs/CHAPTER_ART_REVISION.json`. These are generated illustrations, not human-drawn artwork.

Core activities spend/produce real resources. Food heals and grants a temporary strength bonus. Courtship with Astrid, Runa and Eydis is explicitly optional and follows different activities; friendship remains available. Personal wagons have a provision-rack upgrade and can be packed and settled in safe regions. Camp residents use lightweight routes with obstacle avoidance; Bramm/Dorrik can accompany the hunt.

## Saves and compatibility

New scene `scenes/fire_we_carry.tscn`, CLI `--chapter-one`, save `user://fire_we_carry_v1.json`. Atomic temp/rename and schema validation protect unreadable files. Enemy HP, partial caravan movement, dialogue cursor, relationships, fates, inventory and chapter state persist. Original campaign slots and the first Ogre visit remain separate and accessible; user data stays at godot/app_userdata/Chiefs of War. Do not run development tests against real saves.

## Verified evidence and limits

All twelve regression suites passed locally and in CI. Chapter One: 92 checks covering actual gameplay/combat traversal, timing, block/parry/dodge, both duel outcomes, rescues, accounting/idempotence, optional relationships, scene/encounter/caravan persistence, schema rejection and old/malformed-save preservation. Release tooling: 17 tests. Actual Linux OpenGL images reviewed, including revised portraits and both cinematic settings. Exact exported pack launch/clean exit and native Windows normal, practice, first-Ogre and Chapter One entries passed, including path spaces, external working directory and save isolation. Publication verified the downloaded ZIP, checksum and exact source before exposing the release.

This is a first playable chapter, not a claim of final animation or human playfeel acceptance. User judgment remains pending. Followers are not tactical party AI; routines are not full life simulation. Equipment currently supports the hunting axe and earned sharpening, not a broad interchangeable wardrobe. Marriage, birth, inheritance and generational simulation are future milestones. Do not conflate courtship flags with those systems.

## Continuity

Development branch: feature/hearth-and-hunger. The release branch and tag are immutable published history; do not replace v0.7.0 with another source. The default warlord branch remains older; preserve unrelated work. Pre-chapter archive: archive/before-fire-we-carry at 2d58ec58c152291df0459e051d19545178cd59f9. Local reconstructed commits differ from connector SHAs; preserve actual upstream parents and compare trees. This status update is a documentation-only follow-up to the released source.
