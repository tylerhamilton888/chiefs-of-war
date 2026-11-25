# Project state

## Verified starting point

The preparation build is commit `b89b3b3cf445f24808af4a7a7f050a647501207e` on the Ogre lineage of `tylerhamilton888/chiefs-of-war`. The historical Frontier world remains available at tag `v0.8.10`. The baseline's campaign opens or resumes The Fire We Carry through `scenes/main_menu.tscn`. It has seven connected regions, nine named principal characters, family work, hunting, cooking, rescue outcomes, a duel, contracts and a personal wagon. The main save is `user://fire_we_carry_v1.json`.

Prior baseline validation covered chapter progression, chapter quality, scale, navigation, loading, the title and save isolation, rendered dialogue layout and native Windows startup. The art-consolidation pass verified 32 shipped campaign textures and 21 review images. The published marks apply to the tested baseline. User judgment of animation and equipment in motion is still needed.

## Starting implementation gaps

At the baseline commit, the two important player sheets are the active Nordic motion atlas and its earlier art master. The chapter also has whole-body attack artwork, atlas registration data, a mobile wagon and separate painted portraits. Reuse these where they survive an actual-motion review. The animation repair history records limited authored poses and earlier issues with returning from work or attacks to a correctly grounded walk. [Animation repair record](docs/ANIMATION_QUALITY_0_8_8.md)

The existing guard costs, modest generic food inventory and chapter objectives differ from the full design. Multi-type dietary XP, permanent dietary talents, the living illustrated travel map, a complete modular wardrobe and persistent custom camp layouts require later milestones. The current authored chapter extends through more paid work than the intended short prologue. Revise that transition without losing the consequences of earlier saves.

## Current milestone

Life at the Hearth uses the campaign as the primary acceptance scene. The art handoff's seven reference images are concepts. Runtime clips, save checks and human art review are separate evidence. See [task handoff](TASK_HANDOFF.md) for outstanding checks.

## Life at the Hearth playtest · 0.9.1

New characters choose an Ogre and clan name, background and one of four hair/beard colors. Background supplies are granted once. The original campaign save remains readable. The opening timber job has a leaning wagon, three reachable bundles, optional directions from Bramm, progress feedback, an in-world repair and a handoff to supper. The camp uses worn paths between the work areas, reusable contact shadows and an unobstructed view of the wagon. The player uses the existing Nordic illustrated body with revised walk cadence, alternating profile steps, stable diagonal facing and Shift for a brisk pace. Belongings supports the hunting axe and a slower iron maul with their own whole-body combat poses.

The developer yard shares chapter combat, uses disposable state and exercises a weak goblin and a resistant raider. Tab changes weapons, R resets, Esc returns to title. The chapter's stamina-like action gates are removed. The yard and Goblin Cairn use the same unarmored goblin, felled by one clean axe hit. Goblin shearing, field meat, advanced combat movement and dietary talents remain future work.

Recorded in Godot at gameplay zoom: [wagon repair](docs/review/life-at-the-hearth/wagon-repair.mp4), [axe and maul](docs/review/life-at-the-hearth/axe-and-maul.mp4), [practice yard](docs/review/life-at-the-hearth/practice-yard.mp4), [creator](docs/review/life-at-the-hearth/creator.webp). The weapon and yard clips were captured during this milestone, before the final campaign HUD adjustment. Current art uses limited authored views and mirrored poses. Human review of weight, grip, direction changes and readability is pending.

Godot 4.4.1 checks exercised the normal title and creation flow, old and damaged saves, walking and four-facing weapon poses, 96 chapter checks, 23 opening/quality checks, 161 navigation checks, 13 scale checks and 16 arena checks. The real renderer checked the creator color change and 104 dialogue/layout conditions. The exported game data launched both the chapter and arena in Godot on Linux. The Windows release workflow separately tests launch and clean exit on Windows.
