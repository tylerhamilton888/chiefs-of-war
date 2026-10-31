# 0.8.8 animation quality sweep

## Reproduced defects

- The player has no chapter-specific walking atlas. `ChapterActor.show_frame` falls back to `OgreActor.show_frame`, which previously changed the crop but never restored the walking texture after weapon/work/carry frames. All 24 cross-action/direction cases plus two scale/physics checks failed on 0.8.7 (26/26).
- Base walking used a fixed 0.55 scale despite the frontier's 170-unit stature. Actions and unarmed walking therefore changed apparent body size. Log attack art also had a mismatched stature reference.
- The original crop rectangles were reused after face edits. Alpha inspection found clipped outlines and pieces of neighboring figures/weapons inside overlapping rectangles, especially axe/maul windups and spearmen.
- Some paired Nordic sheets contain translucent background residue; registered geometry excludes the surrounding residue and retains the full drawn figures.
- Log attacks skipped the authored intermediate swing. Front/rear carry cycles repeated the same contact foot. Flint flipped to right when stopping from leftward movement; champion gait advanced on elapsed time even without displacement.

## Implementation

`tools/register_ogre_frames.gd` reads source alpha and writes only `resources/ogre_frame_registration.json`: complete-pose boundaries, foot anchors, texture sizes, source SHA-256 hashes and render polygons for 20 active atlases. It never modifies source image pixels, separates limbs or synthesizes new artwork. Multiple complete figures in paired frames remain together. Coordinates derive from the exact currently active sources.

`scripts/ogre_frame_art.gd` renders these whole illustrations using static Polygon2D geometry with original atlas UVs. The Sprite2D still owns visibility, palette material, scale, modulation and placement. There is no skeletal animation or deformation. Geometry is cached per source/frame/facing. Fallback to the untouched bloody devour atlas restores normal sprite drawing and hides previous geometry. Existing shader hair regions remain in their original UV space.

## Verification

The new `ogre_animation_test.gd` covers all facing/action returns, actual physics transitions, scale consistency, texture/hash/geometry registration for every active sheet, paired-figure inclusion, normal-sprite fallback and companion idle facing. `ogre_animation_visual.gd` renders all player actions, paired moves, spearmen and clan figures against foot lines. `ogre_animation_sequence.gd` records continuous real-engine movement, weapons, work, carry, dodge and feeding transitions. Release CI runs the regression and retains visual contact sheets with its build artifact.

Local checks: 29 frontier brutality, 22 creator and 94 chapter checks passed. The initial 26 animation regression checks all failed before the fix and all passed after. Expanded suite and final visual review are recorded in current state. Windows checks and published release are separate from local evidence.

## Limits

The existing art remains a small set of individually illustrated poses; this is not a new in-between animation pass. Dodge/stun still reuse defensive poses. Human judgment of movement feel remains pending. Save formats, player progress, hit timing and damage values are unchanged.
