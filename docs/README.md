# Chiefs of War documentation map

Start with [current state](state/current.md) and the [session handoff](SESSION_HANDOFF.md). [AGENTS.md](../AGENTS.md) routes future development sessions to the smallest relevant context.

## Design requirements

| Document | Covers |
| --- | --- |
| [Vision](design/vision.md) | Individual Orc fantasy, player freedom, progression and tone |
| [World and culture](design/world-and-culture.md) | Wilderness, instability, tribal values, family and persistent society |
| [Characters and animation](design/characters-and-animation.md) | Male/female designs, customization, complete-body frames and art standards |
| [Combat and bestiary](design/combat-and-bestiary.md) | Input, combat feel, distinct Orc/goblin/troll/giant/wildlife identities |
| [Executions](design/executions.md) | Later combat-brutality directive and first finisher milestone |
| [Economy and building](design/economy-and-building.md) | Carnivorous diet, hunting, gathering, industry, construction and labor |
| [Narrative opening](design/narrative-opening.md) | All five intended prologue acts and player agency |
| [Milestones and quality](design/milestones-and-quality.md) | Vertical-slice scope, acceptance gates and staged development |
| [Development mandate](design/development-mandate.md) | Original assignment, repository/workflow and commercial originality |

The numbered sections were split **without dropping or paraphrasing the original requirements**. [MASTER_BRIEF.md](MASTER_BRIEF.md) is the preserved source snapshot, not a live status report. [source-map.json](design/source-map.json) records all 19 section assignments and its checksum. Later clarifications live in [decisions](state/decisions.md); the execution shard identifies its recovered rather than verbatim provenance.

## Engineering and continuity

- [Architecture map](engineering/architecture.md): actual entry points, ownership and contracts.
- [Asset pipeline](engineering/assets.md): atlases, frame anchors, identity and provenance.
- [Validation and release](engineering/validation-and-release.md): reproducible checks and Windows delivery.
- [Recovery](engineering/recovery.md): checkpoints, file integrity and known tool limitations.
- [Current state](state/current.md): implemented / in progress / planned, with evidence.
- [Decision record](state/decisions.md): settled requirements, dates and sources.
- [QA history](QA.md), [changelog](../CHANGELOG.md), [asset provenance](ASSET_PROVENANCE.md).

When a request concerns one subsystem, read its shard and current code; do not reload the entire original brief or rediscover already-recorded decisions.
