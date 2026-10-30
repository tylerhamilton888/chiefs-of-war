# Settled decisions

Latest explicit user instructions govern. This record distinguishes user direction from implementation choices; it is not a list of new restrictions.

| Date | Decision | Source / consequence |
| --- | --- | --- |
| 2026-10-29 | Continue Chiefs of War as an independent Godot 4 game; never modify The Stellar Holds for this project. | Original master brief §1/17. |
| 2026-10-29 | Rugged illustrated 2D, Warcraft II as a general readability reference; square-aligned buildings rather than diagonal staging. The 3D experiment was rejected. | Subsequent user art feedback; existing 0.3–0.3.2 implementation. |
| 2026-10-29 | Male Orcs are enormous adult hulks. Female NPCs are feminine and recognizably Orcish, with meaningful roles. Initial player scope is male Orcs. | Original brief §5–8 and later physique direction. The old roadmap's female-player priority was inconsistent and is corrected. |
| 2026-10-29 | Individually illustrated complete-body animation; do not substitute skeletal/paper-doll motion or floating tools. | Original brief §8; later execution directive. |
| 2026-10-29 | A competent, enjoyable opener is required; functionality alone does not establish polish or fun. | User response to 0.3 opener development. |
| 2026-10-29/30 | Publish actual GitHub Windows releases; source-only delivery is insufficient. | User explicitly rejected an absent release in Game Context Check. |
| 2026-10-29/30 | Earned optional short executions, goblin axe finisher/cleave and intact rival-Orc finisher, restrained gore. | Retrieved combat-brutality directive; see design/executions.md for provenance limits. |
| 2026-10-30 | User made the repository public to unblock private-repository source downloads. | Current conversation. This is access state, not authorization to expose secrets or change unrelated repositories. |
| 2026-10-30 | Categorize initial writeups into Markdown shards and add persistent routing/current-state/handoff documentation. | Current user request; preserve original wording and distinguish requirements from implemented work. |

## Implementation choices, not design replacements

The village/first-expedition slice ends with the pelt return and iron kit; the burning village, chieftain duel and new tribe remain planned. The execution reconstruction adds an optional post-iron-kit encounter rather than pretending to implement that invasion. F/Shift+F and the small side-on range gate are prototype choices, subject to playtesting.

No rigid classes or forced leadership, no vegetable-farming foundation for Orc food, no unannounced catastrophic erasure of player accomplishments. Those requirements already live in the original design shards.

## October 30 playtest direction

User requested an actual main menu, multiple character/save slots, a major art pass matching the favored buildings, and tighter combat with better animation, blocking and parrying. Implementation target: three isolated campaign slots (legacy path remains slot one), warm timber/stone/ivory/crimson illustrated style, RMB directional block with a brief timed parry, and authored whole-body defensive poses. These changes are in progress on feature/hearth-menu-and-combat, not yet in published 0.4.2.

Adult female NPC clothing direction: traditional fantasy silhouettes with fitted leather, bare shoulders, some midriff and split/shorter skirts, while retaining grounded proportions, neutral poses and practical boots/bracers. User explicitly wants this balance, not an overtly sexualized game. Updated Yrsa candidate atlas follows this direction.
