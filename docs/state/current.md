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
