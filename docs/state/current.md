# Current implementation state

Updated: 2026-10-30. Default branch: `warlord` (renamed from `main`). **0.4.0 combat playtest preparation is in progress; no newly published build yet.**

Playable release baseline: v0.3.2, game source `132e4f876b91d88499bab9efd0790c6a86087081`. Active source: `recovery/axe-and-iron-2026-10-30`. Check actual Git heads for latest checkpoints.

## Implemented

Named male Orc, palette and leather/iron outfit selection; Ashfang village, four named NPCs, three enterable buildings; tree chopping/falling/log collection, surface ore collection, staged timber store, physical worker cargo/storage, palisades; tutorial, wolf hunt, hunter return and iron reward; campaign save/load, healing, recoverable defeat and guarded fire.

Recovery branch adds optional earned side-on goblin/rival-Orc finishers, optional goblin cleave, blood/dismember settings, raiders after the iron reward and legacy-save-compatible combat state. Current feel pass reduces axe windup/recovery, buffers late-dodge clicks, adds raider cursor targeting/recoil, consistent contact feedback, focus-loss pause, target-removal cleanup and an unsaved `--combat-yard` practice mode.

## Evidence and remaining work

Fresh baseline suites passed: foundation 35, camp 27, motion 20, full opener 48 (zero recoveries), opener edges 17, rendered polish 23; worker storage check passed. New feel suite passed 7. Practice entry/save isolation/rendered menu passed. Execution edge suite expanded to 28; target-removal cleanup is under recheck.

Actual engine sequences captured for goblin cleave, mirrored Orc finisher and tree chopping/falling. Review found neighboring-axe fragments in the original finisher atlas. Repacked artwork is being generated and must be inspected/imported before export. Native Windows and human playfeel remain unverified.

## Planned, not delivered

Expanded face/hair creator; individual armor slots; full directional enemy/finisher animation; block/parry/heavy combat; richer schedules/relationships/family; full invasion/chieftain duel/new-tribe prologue; settlement politics, larger-world persistence and broader industry. Female playable characters are not initial scope.

## Documentation

Eight categorized design shards preserve all 19 master-brief sections verbatim. Requirements, decisions, engineering contracts and active status are separated. Root AGENTS.md is the session entry point. Source-download blocker was resolved when the user made the repo public; do not repeat that investigation.
