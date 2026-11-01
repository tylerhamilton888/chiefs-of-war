# 0.8.9 quality evidence

Scope: The Fire We Carry's ten-step opening chapter, the current Sundered Frontier systems, existing artwork in the Godot renderer, menu/loading/save regressions and the Windows release package. No player saves were used; every suite has an isolated XDG_DATA_HOME.

## Reproduced defects

The initial `chapter_quality_test.gd` had **12 failures in 17 checks** on 0.8.8: repeated feast charges and stage rewind, repeated rescue/welcome/negotiation credit, overwritten arrival healing, purchase-time position rollback, four unsafe camera corners and an incorrect entrance on the Cairn-to-Pass road. All pass after the repairs.

Additional inspected issues repaired: dialogue staging hid speakers behind the dialogue panel; Flint's front/rear drawings were taller than his side drawings at the same scale; unregistered beast frame rectangles could include neighboring silhouettes; stationary ridgeback walking advanced with elapsed time; defeated ridgeback retained its red hit tint/threat drawing; paired actions hid sprites but left original root-level indicators and shadows. Existing source PNGs are unchanged. Registration remains deterministic geometry around whole authored figures, with exact source hashes, not altered pixels or skeletal deformation.

## Verification

`chapter_test.gd` traverses all ten milestones, both duel outcomes, rescue consequences, partial caravan/encounter persistence, resource accounting, optional relationships and malformed-save preservation. `chapter_quality_test.gd` covers the defects above plus actual scene reload/resume. `ogre_navigation_test.gd` walks the first three timber pickups and axle repair using movement, real proximity prompts and E input; then checks static-physics reachability of interactions/NPCs across all fourteen regions and each Chapter One road transition.

`frontier_systems_test.gd` exercises initial trunk delivery, mineral work, taming/harness/cargo menus, Flint's physical trip to the depot, cooking/food/crafting, an active telegraphed ridgeback charge into a snare, hunt/harvest/transport, timed and failed champion clinches, pass/tollhold clearing with actual weapon contacts, negotiated payment, restored trade wagons, protection encounters, household packing/settling and durable save reload. Alternative Dunmere resolutions require their prerequisites and cannot pay twice. Some combat fixtures hold enemies still to isolate damage/reward accounting; this is not evidence of human combat balance.

`ogre_animation_test.gd` verifies texture transitions, scale/pose registration, all 22 exact source sheets, original bloody-sheet fallback and Flint turning/stopping. `frontier_brutality_test.gd` verifies log contact, earned feeding, interruption, throw collision and finisher cleanup. Creator/loading/menu and archived regressions remain release gates.

Fresh local counts: Chapter One 94, chapter quality 17, navigation 201, frontier systems 84, brutality 31, creator 22 and animation 90, all passing. Loading transitions pass. Godot 4.4.1 import has no script/runtime errors.

Actual OpenGL review: full-body player/weapon/work/carry/clinch/devour/cast/beast pose sheets; opening dialogue, host, personal hearth at the southern boundary, northern road, caravan, challenge panel and both journals. `ogre_quality_visual.gd` checks all final dialogue choice rows and text layouts (**100 checks**) at the game's 1280×800 logical viewport. New captures and logs are retained by the release workflow.

Exact source, native Windows launch result and downloadable ZIP checksum are recorded in current state and the session handoff after publication.

## Remaining playtest judgments

The sprites still use a small number of authored poses; guard art is reused for some dodge/stun actions. No claim of newly drawn in-betweens or human-level animation polish. Chapter NPC schedules and hunt followers are lightweight; no tactical party AI, broad wardrobe, marriage/children or dynasty simulation is delivered. The four-color frontier creator is separate from the chapter protagonist. Human difficulty, pacing and enjoyment are not established by automated tests or static captures.
