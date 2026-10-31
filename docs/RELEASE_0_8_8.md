# Hearth and Hunger 0.8.8 — Animation Repair

Fixed a serious animation transition bug: walking after an attack, carrying or work could use the previous action's sprite sheet with walking coordinates, displaying cropped or unrelated body parts. Walking now restores its own complete-body frames and maintains the character's scale.

Re-registered the active Ogre and spear-goblin poses so overlapping atlas rectangles do not show neighboring weapons or figures. Existing artwork, palettes and bloody finishers remain. Log swings use the intervening swing pose, front/rear log carrying alternates the authored feet, Flint retains his facing when stopping, and the champion's walking advances with actual movement.

Includes new transition, geometry and visual regression coverage. Saves and combat hit timing are unchanged. This repairs the existing animation set; it does not add a new high-frame-count animation library.
