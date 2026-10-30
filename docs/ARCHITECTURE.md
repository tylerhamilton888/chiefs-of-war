# Architecture

`world_state.gd` owns serializable object records keyed by persistent IDs and sparse 32-pixel terrain edits. It is independent of rendering, physics and input. Each wall and roof is its own object; no building or harvestable tree is painted into the ground. A future building aggregate can coordinate construction, ownership and structural collapse without replacing per-part state.

`world_prop.gd` renders one record and derives its collision from type and state. `terrain.gd` draws base ground and edits, maintaining water collision only where water exists. `hearth.gd` creates the region, connects tools/UI, steps fire at 4 Hz, and saves/restores version 2 snapshots. `orc.gd` handles CharacterBody2D movement and atlas-based full-body animation.

The small prototype uses direct iteration. Before expanding regions, replace all-pairs fire proximity with a spatial hash, terrain rebuild checks with dirty-cell events, and prop refresh polling with state notifications. Chunk persistence should retain stable object IDs and store player edits independently of terrain generation. Do not add offline fire simulation implicitly.

## Fire contract

Ignition sources are explicit: raid, disaster, deliberate, or spread. Unknown/ambient sources fail. Contained hearths cannot ignite or spread. Stone has no fuel. Nearby fuel accumulates heat and cools if exposure stops. Sources are snapshotted at each tick, preventing same-tick chain ignition. Earth and water crossed by the propagation line stop it; the first system uses local contact spread, not airborne embers. Wind biases heat transfer but cannot jump firebreaks. Wet protection lasts 45 seconds. Local burning causes 3 HP damage/sec and consumes finite fuel. Burnout removes blocking collision and produces charred stump visuals for trees. The player's G action is deliberately a free test extinguish tool, not the final bucket/worker system.

The prototype never generates unannounced natural disasters. F4 is a deliberate eight-second warned test with a pre-event save. F6 restores it. Ordinary autosave cannot overwrite this recovery file. Production disasters will require forecast/warnings, response tools, settlement protection options and balance tests before enabling them.

## Equipment contract

Outfit IDs resolve to complete directional frame sets. The current two whole-outfit candidates demonstrate visual replacement only; there are no armor stats or independently interchangeable slots. Final equipment requires authored compatible full-body variants or properly registered frame-by-frame clothing layers. No skeletal deformation or floating armor overlays may substitute for coherent drawn actions. Hair and beard/mustache customization remain separate future requirements.

## Current boundaries

Terrain editing changes surface material and water collision; it is not elevation sculpting, voxel excavation or fluid simulation. Structures have independent damage but no support graph yet. Grid transitions, fire effects, roof alignment and destruction art are provisional. The current region is a test clearing, not the final narrative village.

## 0.2 camp layer

`camp.gd` coordinates the authored region, room transitions, UI, inventory/progression, simple enemy and worker decisions. It uses the existing authoritative WorldState for environmental objects/fire. `camp_actor.gd` reuses whole-frame actor rendering and adds impact signals at 0.43 seconds into an 0.8-second action, with direction/range validation in the camp. `camp_prop.gd` maps new art and animates tree falls. `building.gd` derives three collision/visual columns from independent wall records. `camp_terrain.gd` draws surface edits without baking in props.

Rooms use collision layer 4; outdoors use layer 1. The player is reparented and masks switch at transitions. Outdoor actors pause indoors; fire state continues while inside, but pauses in modal menus. Saves always restore to an exterior doorway so stale room state cannot trap the player. Current rooms share a layout and services are deliberately simple.

Campaign data extends the v2 world snapshot with camp_version=1, progress, worker cargo/location, player position and enemy health. Physical logs have stable IDs and collection flags. A worker transfers one bundle into cargo then into storage, never paying timber just for elapsed time. Rations and iron are finite until the region is expanded.
