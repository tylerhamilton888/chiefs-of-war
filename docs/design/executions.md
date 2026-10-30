# Executions and combat brutality

Status: **accepted direction; implementation acceptance is separate**. See [current state](../state/current.md).

Source: user directive in **Game Context Check**, 30 October 2026 at approximately 03:14 UTC (29 October local evening). This is a categorized recovery of the retrieved requirements, **not a verbatim transcript**. The complete original message was not available in the recovered context. The base combat brief remains [combat and bestiary](combat-and-bestiary.md).

## Intent

Brutality communicates strength, impact and consequence without excessive or grotesque spectacle. The player should feel like an enormously powerful Orc warrior. Preserve tight combat and coherent illustrated animation.

## Opportunity and player control

Executions must be earned through ordinary combat and optional. Potential triggers include critical wounds, stagger/vulnerability, guard breaks, perfect parries/counters, exceptional heavy attacks, stuns and knockdowns. These are candidate systems, not a claim all currently exist.

Standard attacks must still feel effective and kill enemies. Avoid random forced interruptions, long repeated cinematics, unnecessary loss of control and softlocks. A short clear commitment, synchronized contact and prompt control recovery are required. Prior recovered prototype used F from alongside a wounded/staggered target and Shift+F for an optional goblin cleave; these are implementation controls, not new global input requirements.

## Target identity and restraint

- Goblins: physically overpowered by the Orc; an occasional stylized dismemberment variant is allowed.
- Rival Orcs: weighty grounded kills; first prototype includes a non-dismembering finisher.
- Large monsters: need distinct suitable techniques later, not a scaled-up copy of a goblin animation.
- Blood and dismemberment should be restrained. Configurability is desired. Any small Ferocity/intimidation/breathing-room reward must not trivialize encounters; these remain options rather than mandatory systems for this slice.

## Animation contract

Original complete-character illustrated frames with consistent anatomy, hands, weapon attachment, outfit, hair and foot contact. Do not simulate an execution by rotating static body parts or hiding poor contact under effects. No floating weapons or placeholder gore. A side-on first prototype is acceptable if its directional limitations are stated honestly; broader directional animation remains the game's goal.

Attacker, target reaction, damage event, impact audio and visual feedback must share a contact time. Review contact, recoil, collapse and return to control in the engine, including mirrored facing and iron outfit.

## First acceptance milestone

1. Earned stagger/vulnerability foundation.
2. One illustrated axe finisher against a goblin.
3. One grounded intact rival-Orc finisher.
4. One restrained goblin dismemberment variant.
5. Synchronized feedback and reliable control recovery.
6. Regression and edge-case tests, actual-engine visual review, and a verified GitHub Windows release.

Test early cancel, pause, interruption, target death/removal, blocking terrain, invalid distance/direction, ordinary kills, repeated input, save/reload and options. Passing code tests does not certify animation quality or player enjoyment.
