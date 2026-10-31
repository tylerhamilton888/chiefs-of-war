# The Ogre Experience — governing gameplay direction

Source: the user's October 31, 2026 major gameplay directive, “Combat, Hunting, Mercenary Work & Living World.” This is an implementation record of that directive, not a verbatim transcription. It supersedes further narrative/dynasty expansion as the immediate priority. Preserve the released chapter and all earlier saves in the existing Godot project.

## Creative foundation

Hunt. Fight. Feast. Prosper. Roam. The individual Ogre's physical actions come first. A diminished people descended from an ancient dominant civilization, Ogres value strength, providing for their own, tradition and pragmatic bargains. Different factions judge conduct by their own interests; there is no universal morality score. Both sexes continue growing stronger and larger with age. Keep imposing, upright strongman males, individually recognizable feminine Ogre women, and the established bright, inked, chunky illustrated art. No skeletal substitutes, floating weapons, disconnected limbs, or static sprites rotated through grapples.

## Ordered milestones

1. Physicality: responsive movement; curated log/carcass hauling, barricade breaking and heavy labor. Make actions happen in the world with complete-body frames and real collision.
2. Combat: light/heavy attacks, weapon timing/reach, buffering and cancel windows, directional block/perfect parry, guard breaks, dodge, readable threats, stagger/knockback/hit-stop and short earned finishers. Small enemies threaten through coordinated formations and openings; Ogre duels test timing and counters.
3. Hunting: signs, preparation, a creature with readable distinct attacks/openings, harvesting, transport and substantial food/material rewards. Food supports recovery/endurance/strength without punitive starvation. Battle feeding grants a short combat benefit; Ferocity rewards successful contact/counters rather than misses.
4. Home and beast: physical deployed camp, packing and travel; one named useful animal with trust, care, commands and hauling before a roster. Long-term breeding, mounted travel/combat, labor and caravan integration remain future work.
5. Contracts: data-driven terms, real existing regional threats, negotiation including provisions/rights/salvage rather than only coin. Durable, observable outcomes; no disconnected kill counters.
6. Reactive frontier: faction-specific reliability/strength/brutality/treachery, protection/tribute/disputes/trade, and a controlled corrupt bargain. Expand continent politics, dynasty and romance only after the core loop is enjoyable.

## Current implementation target

An accessible Sundered Frontier excursion in the existing game, also reachable from the chapter's independent hearth. Reuse terrain, camp, portraits and compatible actors. A separate atomic frontier save protects the released narrative while new combat is exercised. Forest, beast territory, pass, two settlements and a training champion form one small region. Existing enemies and rockfalls precede accepting the contract.

The first delivery should exercise all twelve steps of the user's playable loop and the five acceptance scenarios: Goblin Band, Ogre Champion, Great Beast, Troubled Pass, Corrupt Bargain. Implement real hauling, combat, rewards, care and regional changes, with explicit limits rather than menu-only claims. Contract E includes accept/reject/alternative terms and physically reachable settlement resolutions with consequences.

## Acceptance and delivery

Inspect actual generated action frames and Godot renders at gameplay zoom. Test combat timing, input buffering, collisions, counters, interruptions, repeat rewards, hunting/cargo, food, camp upgrades, companion behavior, contract outcomes, save/load and malformed-save preservation. Run legacy regressions and exact-package smoke, native Windows launch/exit, then commit/sync source and publish a new immutable Windows release. Automated success is not evidence of human playfeel acceptance. Record source, build, verification and limitations.

Not a commitment to ship continent simulation, multiple new species, breeding, mounted combat, large equipment wardrobes, or dynasty in this first slice. The directive explicitly asks for focused playable milestones.
