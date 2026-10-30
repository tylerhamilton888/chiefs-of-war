# Chiefs of War — agent entry point

Continue this existing Godot 4.4.1 / GDScript game. Do not create a replacement project or touch The Stellar Holds. This file is the short routing guide; read the relevant shards instead of reassessing the entire project on every task.

## Start a session

1. Read `docs/state/current.md` and `docs/SESSION_HANDOFF.md`.
2. Inspect `git status --short`, current branch/commit, and remote branch heads. Preserve uncommitted work. Use actual GitHub state over claims in an interrupted chat.
3. Read only the domain documents and implementation files needed for the request using the table below.
4. Read `docs/state/decisions.md` before changing a settled direction. Latest explicit user instructions take precedence. Flag genuine conflicts; do not silently redesign the game.
5. Continue the listed next action. Do not rerun discovery already recorded unless files, requirements, access or test evidence changed.

| Task | Design shard | Implementation/context |
| --- | --- | --- |
| Scope, progression, player freedom | `docs/design/vision.md` | `docs/ROADMAP.md` |
| World, tribes, culture, society | `docs/design/world-and-culture.md` | `docs/state/decisions.md` |
| Characters, portraits, movement, equipment art | `docs/design/characters-and-animation.md` | `docs/engineering/assets.md`, `docs/ASSET_PROVENANCE.md` |
| Melee, enemies, hunting combat | `docs/design/combat-and-bestiary.md` | `docs/engineering/architecture.md` |
| Finishers, blood, dismemberment | `docs/design/executions.md` | `scripts/execution_opener.gd`, `scripts/raider.gd` |
| Gathering, workers, food, building | `docs/design/economy-and-building.md` | `scripts/world_state.gd`, `scripts/opener.gd` |
| Story, characters, opening quests | `docs/design/narrative-opening.md` | `docs/state/current.md`, `scripts/opener.gd` |
| Tests, exports, publication | `docs/design/milestones-and-quality.md` | `docs/engineering/validation-and-release.md`, `docs/QA.md` |
| Session loss or access failure | `docs/engineering/recovery.md` | `docs/SESSION_HANDOFF.md` |
| Original assignment/source audit | `docs/design/development-mandate.md` | `docs/MASTER_BRIEF.md`, `docs/design/source-map.json` |

## Non-negotiable project constraints

- Original rugged illustrated 2D art, square-aligned elevated environments. Warcraft II is a readability reference, never an asset source. Do not revisit the rejected 3D direction.
- Male Orcs are imposing adult hulks, with enormous shoulders, arms, hands and jaws. No lanky, chibi or anime replacements. Initial player scope is male Orcs; feminine but recognizably Orc female NPCs are important characters. Female player art is not a current milestone.
- Complete coherent illustrated animation frames; no disconnected body parts, floating tools or skeletal deformation substitutes. Be honest that generated illustration candidates are not human-drawn or automatically accepted final art.
- Responsive melee, Space dodge, optional earned short finishers. Normal attacks remain effective. Restrained stylized brutality, not excessive gore.
- Carnivorous Orc food economy, physical labor, useful autonomous workers, and freedom to remain a hunter/craftsman rather than being forced into leadership.
- The invasion, chieftain duel and new-tribe adoption are the intended later prologue, not already delivered by the current hunting opener.
- Preserve existing saves. Do not silently use a development test or fresh-game launcher against the user's campaign slot.

## Checkpoint and completion discipline

- Commit coherent tested changes throughout development, and checkpoint unfinished work explicitly as WIP before long asset generation, risky tooling, or handing off. Push/sync the checkpoint and update handoff; a local commit alone does not survive loss of a workspace.
- Preserve upstream ancestry. Do not force-push a reconstructed root history. If terminal write authentication is absent, use GitHub tools with the actual upstream parent/base tree and only explicit changed paths.
- Never upload empty/partial asset recoveries. Validate bytes, imports and hashes before substituting source files.
- Keep design intent separate from implementation status and test evidence. Record exact test suites, failures, source commit and remaining visual/native-platform limitations.
- A finished requested build includes the actual downloadable Windows GitHub release, source reference and checksums. A source commit or a promise to publish is not release completion.
- Do not call a feature polished or fun solely because automated tests pass. Inspect actual engine output; retain pending human playtest judgments honestly.
- Update `docs/state/current.md` and `docs/SESSION_HANDOFF.md` when state changes; update the relevant shard and decisions only when requirements change. Avoid appending contradictory notes across many files.
