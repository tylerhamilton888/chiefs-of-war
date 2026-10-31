# Verified 0.6.2 delivery

Source 25e9b4bfcdbfa847a86a59b05a3d91aef0158b31; run 41152724848 succeeded. All import/regression/render/export/package checks passed. Native Windows normal, creator, old practice and new Ogre startup/clean exit passed with no runtime errors; campaign sentinel, path spaces and external working directory were verified. Publication downloaded and verified the uploaded package before making the release public. ZIP 110668478 bytes; SHA256 f3de3c7e5265e361b6faf74da5d590e9b43a6974470cbc621a5f3464a22d4030. Human playfeel and native graphical review remain pending.

The corrected Ogre suite passes 40 checks; legacy customization 73, opener 48, edges 17, motion 20, feel 10, execution 28, defense/48 poses, save slots, menu flow and practice passed. 17 release boundary tests passed. This establishes functional behavior, not final art acceptance or a complete sandbox.

---

## Native startup correction

First run 41151630352 passed imports/regressions, render checks and packaging, then native Windows Ogre shutdown reported an AudioStream resource still active at exit. Publication was blocked; 0.6.0 was not released. Reproduced locally with the Dummy audio driver. Fixed by reusing the legacy campaign's stop/release plus mixer-drain interval, guarded against duplicate exits. Linux packaged Ogre startup with active audio is now an explicit release gate as well as native Windows startup. Run 41152025724 used the earlier pre-fix 0.6.1 source; the follow-up run must be checked for the corrected source.

## Final boundary correction

The new Ogre suite now passes 40 checks, including actual movement to both map boundaries followed by save/load. The validator previously rejected reachable y positions below 80 or above 1310; accepted bounds now cover the full collision area. Delivery target is 0.6.2 with both fixes.

# Hearth and Hunger 0.6.0 local pivot checks

Godot 4.4.1 Linux. Each suite used isolated XDG_DATA_HOME, never user saves. New ogre_hearth_test: 36 checks, 0 failures. Legacy customization, opener (48 checks), edges (17), motion, feel (10), execution (28), defense including 48 poses, practice isolation, save slots and menu-flow suites passed. 17 publication/package boundary tests passed, including new package names while retaining legacy validation. An initial local wrapper incorrectly gave --fresh to the save/menu suites; those invocations were discarded and rerun with the repository's intended flags. Do not count initial failures as regressions or conceal the incorrect invocation.

Rendered title, campsite, all 16 pose/direction combinations and pause menu in Godot OpenGL. Corrected neighboring atlas fragments with UV boundaries, aligned frame feet using measured alpha bounds, and adjusted camera framing. No script/runtime errors on final render. A four-frame generated walk remains a user-review candidate, not a claim of final authored-animation quality or enjoyable playfeel. The first scene has one Ogre, static camp structures, timber/provisions and cooking. No new Ogre attacks, eating animation, movement of the caravan or NPC simulation.

Windows export and native CI verification are tracked in the release run; until it succeeds, do not claim the release delivered.

---

# 0.3.1 motion revision

147 checks: the existing 127 gameplay checks plus 20 motion/import checks for both outfits. Motion checks cover texture import, idle grounding, movement, stop, dodge cadence, attack facing and recovery. Functional tests alone initially missed invalid idle texture imports; the rendering review and dedicated motion test caught them, and both idle atlases were regenerated and reimported.

Actual OpenGL review covers four facings in both outfits, moving/idle/strike transitions, character setup, village, and interiors. Windows export checked through the Linux engine; native Windows execution is not available here. Four-keyframe pose continuity and human playtest acceptance remain limitations.

# 0.3 QA — The Ancestral Hearth

Godot 4.4.1. 127 checks passed:

- 35 foundation checks: independent world objects, persistent depletion, fire ignition/spread, wetness, firebreaks, movement, collision and saving.
- 27 legacy camp checks: attack timing/range/facing, resource duplication, construction, independent building collision, enter/leave, equipment, damage mitigation, worker cargo and pause.
- 48 opening checks: character identity, actual movement through the village and interiors, conversations, two trees felled through timed contact frames, physical log collection, cancelled and completed construction, dummy practice, hunter encounter, four live wolf fights with telegraphs and dodges, harvesting, return, single-use reward, forging, save/reload and worker navigation/deposit. The bot completed the sequence without defeat recovery. It uses movement and attack commands, not damage/resource grants or teleports to complete the quest.
- 17 edge checks: provision preservation at full health, saving east of the old map bounds, malformed identity rejection before mutation, attack cancellation and pause/resume, held-input release, hidden-furniture collision, warned/cancelled fire and checkpoint restore, defeat recovery, reunion reward gating and buffered attack completion.

Visual review used actual Linux OpenGL viewports: character setup, square-aligned village buildings, distinct room furnishings, portrait dialogue, wolf telegraph and pause menu. It caught and corrected scalloped path rendering, wrapped objective markers, oversized modal panels, palette double-multiplication and invisible furnishing collisions. The ground blend samples live terrain state; trees/buildings are separate objects.

Windows export validation: successful x86-64 embedded-PCK export, launch of that pack through Linux Godot, and ZIP integrity. Native Windows execution is not available in this environment. Automated combat does not establish human difficulty or fun. Sprite continuity and the limited creator remain open acceptance items.

Commands (use separate temporary XDG_DATA_HOME directories for parallel tests):

```
godot --headless --path . --fixed-fps 60 --script tests/foundation_test.gd -- --fresh
godot --headless --path . --fixed-fps 60 --script tests/camp_test.gd -- --fresh
godot --headless --path . --fixed-fps 60 --script tests/opener_test.gd -- --fresh --test
godot --headless --path . --fixed-fps 60 --script tests/opener_edges.gd -- --fresh --test
```

`--test` skips the initial creator overlay and audio playback; the opening test explicitly opens and commits the creator. The visual capture script runs without that flag. Production UI and audio are included in the export.

## 0.3.2 validation

Foundation 35, camp 27, complete opening 48, edge cases 17 and motion 20 checks pass. New `tests/polish_test.gd` adds 23 checks covering active-room furniture collision, actual walking through every room, doorway approach behavior, forge frontage, menu viewport bounds, disabled actions, timber transfer and reward visibility. Run this suite with a rendering display (OpenGL), `--fixed-fps 60 --script tests/polish_test.gd -- --test --fresh`; headless font/layout measurements do not represent the rendered UI. `tests/polish_visual.gd` captures creator, village, doors, rooms and menus to `/tmp/chiefs032-visual` (create directory first). Rendered at 1280x800 using Mesa software OpenGL. Native Windows execution and subjective playfeel were not tested here.

## 2026-10-30 — Faces of Ashfang customization

Fresh Godot 4.4.1 Linux checks: customization 73 headless checks (74 including rendered layout), opener 48 with zero recoveries, opener edges 17, motion 20, feel 10, execution 28; all passed. Practice entry/save sentinel passed and its expanded pause menu was verified in a rendered run. Headless font/layout measurements are not substituted for actual rendered UI checks. Creator, four facings, both outfits, ordinary attack frames and mirrored finishers were captured and inspected; iron finisher head registration was corrected. Windows export succeeded; native Windows execution remains unverified. Release CI repeats regression/export/resource smoke gates before attaching the ZIP.

GitHub release CI run 41094541852 independently passed import/regressions, rendered creator and practice menus, Windows export, packaged-resource smoke and ZIP integrity. Published v0.4.1 source: 339183d219d89a4a497d3eb2b9dae1def686cfc2. ZIP SHA-256: c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81.

## Chapter One 0.7.0 candidate — 2026-10-31

Fresh local Godot 4.4.1 isolated runs: customization, opener, opener edges, motion, feel, execution, defense, save slots, first Ogre hearth, Chapter One, menu flow and practice all pass without script/runtime errors. Chapter One has 92 checks, including full gameplay traversal, actual attack contact timing and damage, rescue consequences, victory/defeat branches, resource/reward accounting, moving caravan, partial encounter/caravan persistence, optional relationships, save validation and older/malformed-save preservation. Release-tool tests: 17 pass. Actual OpenGL renders inspected for family camp, giant elders, dialogue/expression portraits, Stonebelly host, cinematic panel, duel/contact pose and journal. Normal active-audio chapter startup/clean exit tested locally; native Windows and published-package verification remain the release workflow's gate. Human playfeel is not established by these checks.
