# Fitting equipment to the Ogre

The playable Ogre can wear the iron helm and scale mantle separately or together, with either the hunting axe or iron maul. The head slot defaults to bare and the body slot defaults to the original fur. Belongings uses the same actor and equipment layers as the world. The renderer draws the animated body, then the mantle, then the head piece.

## Fitting a helmet

Paint front, right profile and rear views on a transparent atlas using the Ogre's light direction. The renderer mirrors the right profile for west. Keep runtime sheets within the project's 2048-pixel edge limit. [Build guide](../BUILD.md)

For each view in the item definition, `views` gives the atlas rectangle in pixels. `mounts` gives the skull attachment's x and y within that rectangle plus the width of the fitted band. Measure where the item sits on the head. A tall crest or projecting brim may extend beyond the measurements. Register the item ID in `GearVisual.SLOTS` and expose it through Belongings. [Iron helm definition](../../resources/equipment/iron_helm.json)

The body atlas's full resource path and the frame's region origin identify a head socket. Its values give the skull center in region-local pixels, fitted width, tilt in degrees and item view. Optional polygons mark foreground parts of the hand or weapon. The renderer redraws those original pixels over the helmet, keeping the weapon detail and chosen hair color. A wider helmet may require additional hand or weapon coverage. [Head sockets](../../resources/equipment/head_sockets.json)

An equipped helmet spans roughly 26–29 screen pixels in the yard's ready stance. The iron helm uses three broad steel planes, a brass brow and a few large rivets. Leave transparent gutters around each view and generate mipmaps for the head layer's minification filter. Inspect the front, profile and rear at native gameplay size and check the silhouette under a raised forearm. [In-engine comparison](../review/living-hearth/helm.webp)

## Fitting a mantle

Paint three distinct views of the mantle. The shoulder rig supplies a panel rectangle and a coverage map for each body drawing. The mask's alpha channel retains the pose's shoulder outline and cuts out the hands, beard and weapon. Its red channel supplies the pose's local shading. Each mantle that fits the same shoulder outline shares these registrations; changing its paint requires three new views. [Scale mantle definition](../../resources/equipment/scale_mantle.json)

Each shoulder socket stores the panel's upper-left corner, width, height and view, followed by the coverage atlas index and the mask's source rectangle. These bounds are in pixels. The Ogre's mirrored, height-scaled and breathing forms reuse the same source registrations. Armor extending into a new part of the silhouette needs new coverage for those poses. [Shoulder sockets](../../resources/equipment/shoulder_sockets.json)

Run `python tools/build_shoulder_coverage.py` after editing the source poses or head sockets. This authoring utility requires Pillow, NumPy and SciPy. It writes the shoulder coverage atlases and the matching registrations together. Review front, rear and profile masks where skin, hair or steel crosses the fur. [Coverage tool](../../tools/build_shoulder_coverage.py)

## Adding a pose or weapon

A new full-body drawing needs registrations for each supported gear slot. At gameplay zoom, inspect the raised hands, behind-the-back swings, forward lean, turn and landing. Run `tests/head_gear_test.gd` to check fitted frames, mirrored transforms, layer order, breathing and the independent combinations. The axe and maul still own their painted grips and strike silhouettes. A different grip or swing needs its own weapon-family art. Boots, back items, shields and fully replaceable torso armor remain future slots.

## Weapon continuity

The hunting axe and iron maul each use one painted head at the same in-world size through the armed walk, dodge, guard and strike. The run sheets bake that same head into the carrying hand. The authored shaft and fingers establish the grip in each combat drawing.

When changing the carry art, run `python tools/build_armed_run.py` to extract the head masters and rebuild the run sheets. The head sockets and outlines of the original iron are registered in native frame pixels in `art_source/equipment/weapon_head_registration.json`. Each entry gives the socket x and y, the clockwise shaft angle, the source body height, and the outline as x/y pairs. Run `python tools/build_weapon_head_patches.py` with Pillow, NumPy and SciPy to rebuild the body patches and runtime sockets. Review both weapons from the front, side and rear with the helmet and shoulders fitted.
