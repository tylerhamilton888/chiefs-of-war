# Loading-art revision — work in progress

The user disliked the injured boar in the loading artwork, likes animals, and requested a snowy tracking scene with an animal companion and another depicting an Ogre clan feast. They explicitly corrected a misinterpretation: combat violence, blood and existing finishers should remain unchanged. Replace the loading image, add the feast to the rotation and preserve the existing battle loading image. New images must show no wounded animals. 0.8.3 is not yet released; the existing public 0.8.2 remains available.

---

# Hearth and Hunger 0.8.2 — Ogre-only menu and loading screens, published

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.2
Windows: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.2/HearthAndHunger-Windows-0.8.2.zip
Source 4e67455dc1db7c7564d7fe1b2438d6d9a7335c32 (tree 1fd5f65322b407e67595e15c2aad3a2c0dedddeb); release run 41213200956 passed. ZIP size 160570709 bytes; SHA-256 6f1fe6965a399df891bc123b0d3e30b8d61d10097be7afed11a628906fabad7e. Public prerelease has both verified ZIP and checksum; native Windows startup and release-download verification passed.

The user saw the old Orc creator/save and directed that Orc content be removed from playable view but preserved as a backburner and for other groups. The main menu now shows three independent Ogre frontier hearths and the separate Ogre story. Slot one uses the original Ogre frontier path and keeps that progress; slots two and three are new paths. Empty slots open the Ogre creator. Orc saves and source remain untouched, and the Windows ZIP excludes the old Orc practice launcher. Tests confirm no Orc menu entry, separate Ogre saves, protection against overwriting occupied or unreadable slots, and unchanged legacy save bytes.

The user also requested dedicated Ogre loading screens. Two generated illustrations with context-specific tips and a real background-loading progress bar appear when entering Sundered Frontier or The Fire We Carry, including story-to-frontier travel. An error offers a return to title. Art prompts are in docs/LOADING_ART_PROMPTS.md. Menu and both screens were visually inspected in the real Godot renderer.

Local tests: Ogre menu/three saves/legacy preservation, loading transitions including failure path, 19 creator checks, 29 combat checks, 92 Chapter One checks, and 18 release-format checks. The full release workflow, render checks, Windows launch and public asset verification passed. First run 41212236579 hung on an archived-scene regression that referenced a removed menu method; that test was corrected and the succeeding run 41213200956 used the fixed source. The feature branch has the same source tree before this documentation-only update; the release branch is immutable once published.

This remains an early playtest; the player has not yet evaluated the new build. The creator is still the existing body/hairstyle with four color presets, not independently drawn hairstyle and face shapes. Retain that limitation honestly.

---

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
