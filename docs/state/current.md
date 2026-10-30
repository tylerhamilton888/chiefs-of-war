# Current implementation state

Updated: 2026-10-30. Default branch: `warlord` (renamed from `main`). **0.4.0 reconstruction is in progress; no new verified release yet.**

Canonical playable baseline: warlord `132e4f876b91d88499bab9efd0790c6a86087081`, GitHub release v0.3.2 Clan and Hearth. Working branch: `recovery/axe-and-iron-2026-10-30`; initial recovery checkpoint `1bea3094c6529e4121d5f8201c05064bcf3748b3`. Check actual Git heads for newer checkpoints.

## Implemented baseline

Named male Orc with skin/cloth palettes, leather/iron whole outfits, movement/buffered axe/Space dodge; Ashfang village, Yrsa/Harn/Bren/Torren, three enterable furnished buildings; tree harvesting/log collection, ore collection, three-stage timber store, autonomous timber worker/storage, palisades; axe/dodge tutorial, eastern hunter/wolf expedition, pelt return and iron reward; save/load, provision healing, recoverable defeat, menus and guarded fire/recovery.

Historical baseline reports 170 checks and actual-engine review; use QA.md for that evidence. Fresh testing of the reconstruction must be recorded separately.

## In progress now

- Earned optional side-on goblin/rival-Orc finishers and restrained goblin cleave; post-iron-kit raider encounter, options and combat save extension.
- New generated complete-character animation candidates require crop/contact/identity review, not merely successful import.
- Documentation sharding is complete: categorized requirements, root agent routing, architecture/assets/recovery guides, decision/state records.

The complete Git clone and asset import now succeed after the user made the repo public. Missing-asset recovery is no longer the active blocker. Fresh reconstruction checks: `opener_test.gd` passed **48 checks, 0 failures, 0 recoveries**; `execution_test.gd` passed **24 checks, 0 failures**. These are mechanics/regression results, not visual acceptance. Engine screenshots were captured; crop/contact/identity review and the remaining regression suites are pending.

The execution implementation and its new tests/assets live on the recovery branch. The default branch retains the playable 0.3.2 implementation plus continuity documentation; do not assume an execution file exists on warlord.

## Planned, not delivered

Expanded facial/hair/beard/mustache creator; individual armor slots; full directional enemy/execution animation; block/parry/heavy combat; richer schedules/relationships/family; full invasion/chieftain duel/new-tribe prologue; settlement politics, conquest, larger-world persistence, broader hunting/industry and disaster systems. Female playable characters are not initial scope.

## Acceptance still required

Validate actual contact/crop/scale, cancellation/interruption/target-loss, pause/work/interior interactions, ordinary kills, options, save compatibility and complete opening. Export and inspect pack, publish real Windows release with source/checksums. Native Windows and human playfeel must be reported honestly; automation cannot certify fun.
