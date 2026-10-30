# Current architecture map

Engine: Godot 4.4.1; GDScript; Windows x86-64 first. Read this map before changing ownership. Historical layer details are retained in [ARCHITECTURE.md](../ARCHITECTURE.md).

This map includes the **recovery branch** implementation. On main/v0.3.2 the scene enters `polished_opener.gd` directly; `execution_opener.gd` and `raider.gd` are unfinished recovery-branch additions.

## Entry and inheritance

`project.godot` → `scenes/opener.tscn` → `execution_opener.gd` → `polished_opener.gd` → `opener.gd` → `camp.gd`.

This is an existing layered prototype, not permission to rewrite it wholesale. Overrides are invoked during parent `_ready()`: guard access to child-layer fields until initialized. Earlier scenes/tests exercise earlier layers and must remain functional.

| Owner | Responsibility |
| --- | --- |
| `world_state.gd` | Serializable independent world objects, stable IDs, material edits, finite resources and guarded fire |
| `world_prop.gd`, `camp_prop.gd` | Rendering/collision derived from world records; tree/material feedback |
| `building.gd` | Three-stage/section building visuals and collision, independent wall/roof records |
| `camp.gd` | Base camp world, services, inventory, worker cargo, legacy enemies, save foundation |
| `opener.gd` | Player setup, village-to-hunt quests, Greytooths, navigation, save validation, menus/input and feedback |
| `polished_opener.gd` | Clan portraits/idle art, furnished interiors, animated doorways and focused menus |
| `execution_opener.gd` | Optional raiders, execution orchestration/options, extension save data; see current state for validation |
| `orc.gd` → `camp_actor.gd` → `opener_actor.gd` | Actor motion, outfit atlases, buffered axe contact, dodge, control locks and palette |
| `direwolf.gd` | Wolf telegraph/lunge/recovery/loot and death |
| `raider.gd` | Goblin/Orc health/posture/vulnerability/telegraph, whole-body combat/death poses |
| `clan_art.gd`, `doorway.gd`, terrain scripts/shaders | Atlas layouts, proximity doors, square-aligned authored environment |

## Contracts to preserve

- Outdoor collision is layer 1; actors layer 2; interior obstacles layer 4. Room transitions reparent player/mask and suspend outdoor actors. Only the current room's furniture collides.
- Axe damage is triggered by the actor's contact event, then range/facing/line-of-sight tested by the world. Do not apply damage on initial button press or cosmetic frame playback.
- The execution coordinator owns its shared contact event; target cannot pay out twice. Every interruption path must restore control and release a living held target.
- Existing campaign path is `user://ancestral_hearth_v1.json`, opener_version 1, extending camp/world snapshots. Add optional fields with defaults; do not reject an old valid save merely because it has no execution fields.
- World tests and saves use stable object IDs. Workers move a real bundle into cargo and then storage; do not generate timber solely from elapsed time.
- Modal pause stops actions/simulation; held input must be cleared. Test creator, work cancellation, death/recovery, interiors and save restoration when introducing action locks.
- Guarded fire has explicit ignition, an eight-second warning/checkpoint, wet protection/firebreaks and independent recovery. No offline disaster simulation.
- Whole-outfit leather/iron swaps exist, including axe damage/armor differences in the opener. Individual equipment slots are not implemented.

Before larger world expansion, profile current iteration; then introduce spatial partitioning/dirty notifications while keeping persisted IDs stable. The documentation sharding requested by the user is not a request to rewrite runtime world streaming.
