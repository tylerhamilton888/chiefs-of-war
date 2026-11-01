# Hearth and Hunger 0.8.10 — Scale implementation, release pending

Implemented the user's 1:2:4 footprint rule, proportional Ogre/elder bodies, smaller settlements and reeve, larger ridgeback, consistent pack beasts, full-body steering and size-aware contact. See docs/RELEASE_0_8_10.md. Fresh local scale (13), navigation (200), frontier systems (84), animation (90), chapter (94), chapter quality (17), brutality (31), creator (22) passed. Actual engine visual review passed; human balance/playfeel remains pending. No source PNG changes or save resets. Preserve pre-existing untracked source/import files.

Next: publish through the standard Windows workflow, verify all jobs and public assets, then replace this pending header with exact release evidence. Base remote feature head e624d8c02e80fda46765db5eac331fe11ee1dafe, tree c30069629b3f0ec896f2f001a4adac102054af50. Use actual upstream ancestry and expected-head lease.

---

# Hearth and Hunger 0.8.9 — Quality pass, published and verified

The user requested a general pass before the next opening-chapter playtest. Fixed 12 reproduced story/framing/entrance check failures, revised contextual objectives, and cleaned up beast poses, movement and paired-action overlays. Existing source art, blood settings, saves and Ogre-only menus are preserved. See docs/QUALITY_0_8_9.md and docs/RELEASE_0_8_9.md for scope and limits.

Fresh Godot 4.4.1 checks: chapter 94, chapter quality 17, navigation 201, frontier systems 84, brutality 31, creator 22, animation 90, rendered dialogue/layout 100; all passed. Loading transitions, import and 18 release-tool tests passed. Reviewed actual OpenGL output, including beast frames, chapter boundaries, dialogue, host, caravan, journals and gameplay sequence captures through log swings and feeding back to movement. The standard release pipeline also passed the full archived regressions, rendered checks and exported-pack checks.

Published Windows release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.9 . Download: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.9/HearthAndHunger-Windows-0.8.9.zip . Exact release source e6d2cd70bdba0ac860830802b3c562ddb8c7058f; tree 922763b7029eac41ccf321f2c23cbc423583e8ed. Workflow 41266973462, attempt 2: all three jobs successful. Native Windows main menu, Chapter One and frontier launch/clean-exit passed; publication verified the downloaded package. ZIP 210919990 bytes; SHA-256 7f9fa50404f841956f6c6ce4c66f4fb19ab7c0c2320efc83ddf9bd8915baefa5. The first attempt stopped on a connection reset while downloading Godot export templates; retrying the same source succeeded, with no game-code change.

Feature implementation commit 3e9d7aab39f6d82fcbd09a659a68ca3e87fa75ac has the same tested tree; this header is a documentation-only follow-up. The release branch/tag remain immutable. Local reconstructed commit IDs differ; preserve actual upstream ancestry. Next: respond to the user's playtest. Human feel/balance remain pending, and animation still uses limited authored poses. The chapter and frontier are separate saves and combat scopes; select The Fire We Carry for the opening chapter.

---

# Hearth and Hunger 0.8.8 — Animation repair, published and verified

The user reported broken animations. Reproduced the wrong-atlas return-to-walk bug (26 initial checks failed), fixed texture restoration and stature, and registered complete-pose geometry for 20 active atlases to prevent clipping/neighbor leakage. Improved log swing/carry sequencing, companion stopping/facing and champion gait cadence. Original art and combat gore remain. See docs/ANIMATION_QUALITY_0_8_8.md for evidence and remaining limited-pose animation constraints.

Local animation (85), chapter (94), brutality (29) and creator (22) checks passed. Reviewed whole-pose contact sheets, continuous gameplay captures and creator palettes in the real OpenGL renderer. Windows release is published and verified: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.8 . Source 91f13a5024854e960fe8f30c118d80e885cfe3f0 (tree d9204d61363bb7d587d8c01dd362f1051d7fd285), release run 41238624593. Full regressions, rendered scenes, exported-pack checks, native Windows launch and downloaded-asset verification passed. Windows ZIP: 210900524 bytes; SHA-256 2a7890b599f80679897127f250967363cc842daf5bcb762a4041d863f6e586b1. User playtest remains pending.

---

# Hearth and Hunger 0.8.7 — Clan feast refinement, published and verified

The user selected the earlier clan feast design and asked for the women to be more attractive. The feast loading image has been refined with softer feminine features while retaining broad Ogre facial anatomy, strong physiques, the clan, goblin spit and unharmed companion. The rest of the game's artwork still uses the 0.8.6 designs; this change does not replace all character art. Some visible teeth still resemble small lower tusks. Combat, saves and gameplay are unchanged.

Local validation: Godot 4.4.1 import and loading transition test passed; reviewed the feast loading screen in the OpenGL renderer. Windows release and native launch verified: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.7 . Exact release source 5116aeb34a8dd1d4cc0b8f4166f479271474b80c; successful run 41233977938. ZIP size 210733376 bytes; SHA-256 692fbce51db06cb26cd31290bbc5b6f2568aa921a5d569be44c2e4fc7d8a2e73. The workflow verified the downloaded assets and checksum. The user’s playtest remains pending. See `docs/LOADING_ART_PROMPTS.md`.

---

# Hearth and Hunger 0.8.6 — Faces of the Clan, published and verified

The user requested faces that look more Nordic and less Orc-like, saying the former look recalled The Hobbit trolls. They like the direction so far and note that scale and strength can distinguish Ogres even with more human faces. Revised AI-generated alternatives are active for three loading illustrations, three dialogue portrait atlases, nine named clan walking sheets, Hrothgar’s combat sheet, the player walking/weapon/work/carry sheets, two non-bloody paired combat sheets and both cinematic atlases. Strong, athletic female figures and formidable elders remain; Flint is unharmed in loading art. Original assets remain alongside the variants. The generated devour candidate changed dimensions and blood detail, so the original bite-and-swallow sheet remains in use and may have older facial features. Combat mechanics, blood settings and saves are unchanged.

Local checks: 94 chapter, 22 creator, 29 frontier brutality checks and loading/menu transitions passed; reviewed loading screens, portraits, creator colors, combat poses, clan scenes and both cinematics in Godot. Windows 0.8.6 published and verified: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.6 ; download https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.6/HearthAndHunger-Windows-0.8.6.zip . Exact source de808af42ce8dda0918a870024048ada8793093d (tree 78e7df68c3bda724a10eda48c49cc9b7d621ee18); successful release run 41221583270. ZIP size 208499331 bytes; SHA-256 1ac84b102d4a0b6c725a6b28d7a5638bb0a7b47ec8f241fe2212e39e4cd192fb. Full regressions, renders, native Windows launch and release-download checks passed. The user liked the direction while work was ongoing; their playtest of the released build is pending. See docs/NORDIC_FACE_ART.md for image generation prompts and scope.

---

# Hearth and Hunger 0.8.5 — The Clan, published and verified

Release: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.5
Windows: https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.8.5/HearthAndHunger-Windows-0.8.5.zip
Source 538e567f43c390c3f87fa395fdccd160fd7aaf59 (tree 755c70677f3b13f4ea655275e7ef81132bce8dd1); successful release run 41216367050. ZIP size 162973264 bytes, SHA-256 609bf3cf517fe835f8661db40fcbb6b833fe80102d9fb034542aa21a0b1a836b. The public prerelease has the verified ZIP and checksum. Regression, render, native Windows startup and release download verification passed.

The user requested replacing a loading screen showing a wounded animal with an Ogre tracking in the snow with the unharmed animal companion, plus a clan feast. They clarified that combat violence and blood remain welcome and existing combat and finishers must stay unchanged. They requested a dark Ogre edge (goblins on a spit), then asked that the art match established in-game Ogre designs and that the women be leaner and more athletic, matching the in-game sprites. All three rotating loading illustrations were revised using the actual character sprites as references: tracking with Flint, clan feast with goblin spit, and a log-wielding Ogre battling goblins. The feast is framed to show the full clan above the tips. No injured animals appear. Art was visually reviewed in Godot and loading transitions passed; combat code was unchanged and its 29 checks passed. The new build has not yet been playtested by the user.

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
