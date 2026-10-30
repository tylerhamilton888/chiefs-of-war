# Generation specifications

Mode: built-in image-generation tool. All images are candidates.

Character: original massive adult olive-skinned Orc, enormous angular jaw/tusks, black tied-back hair and short beard, sleeveless brown leather harness, trousers and fur-trimmed boots. A four-column/four-row transparent full-body atlas, rows south/west/east/north, four walking poses per direction, consistent anatomy and foot anchor. Reference: user's Fantasy Orc Game Art Acceptance Board, style only. No chibi, photorealism, toy-like softness, excessive texture or franchise reproduction.

Iron equipment variant: same character identity and proportions; battered blackened iron breastplate, asymmetrical blunt shoulder guards, heavy gauntlets and shin guards, charcoal leather and oxblood cloth. Four-direction four-frame walking atlas. Hard angular illustrated shapes, no dwarf runes, glossy 3D or cozy cartoon treatment. No weapons in walking candidate.

Modular props: six independently isolated transparent objects in a 3x2 sheet: mature Nordic pine, cut stump, felled log, angular grey rock, straight timber wall, thatched roof with no walls. Elevated game view, no attached terrain or scenery. Earthy restrained illustrated shapes; no existing IP.

Terrain: seamless overhead mossy olive-green grass and muted earth texture only. No trees, rocks, buildings, paths, water or objects. No horizon or vignette. Quiet diffuse lighting, controlled brush shapes.

Rejected axe sheet: four directions and four successive full-body two-handed axe-swing poses matching base Orc identity, no tree target. Rejected after inspection because direction and cropping requirements were not met.

Rejected environment approach: one painted complete clearing. Retained only as an earlier visual experiment outside the repository, never used as the current playable map.

## 0.2 reference-led generation

Built-in image generation; no image API fallback. User's uploaded `image(20261029-234521).png` was the style reference. Prompt direction: bold hand-inked contours, broad flat gouache planes, restrained two/three-value shadows, rugged original northern Orcs, massive adult male physiques, readable elevated top-down views. Avoid photoreal microtexture, 3D-rendered surfaces, cute proportions and fine noise.

Architecture: six isolated assets, hall/forge/storehouse above anvil bench/fur bed/timber chest. Props: pine/stump/log above ore boulder/palisade/contained hearth. Portraits: dark-haired hero, silver-bearded smith, red-bearded laborer, beautiful adult female Orc healer with feminine features, small tusks, olive skin, side braids and slate bodice. Character sheets: four directions and four whole-body poses, blue-cloth leather and red-cloth iron kits; separate walk and two-handed axe actions. Sprite facing rows were verified and remapped in atlas metadata, not assumed from prompts. Clipped followthrough cells are not played. Generation cannot yet be treated as a finished animation pipeline.

## 0.3 square-aligned architecture

Built-in image tool; input was the project's generated `assets/camp/architecture.png`.

Use case: precise-object-edit. Asset type: production sprite atlas for a hand-drawn 2D Orc game. Redraw these six original assets with corrected ORIENTATION. Keep the material palette, hand-inked outline, broad painted planes, tusks, black iron, battered timber and blood-red clan cloth. CRITICAL: SQUARE-ALIGNED elevated view, camera looking directly toward the FRONT of each object, zero yaw, no diagonal/isometric rotation. ALL front wall baselines and door lintels horizontal; all upright posts vertical. Show some roof top and furniture top from above, but no left/right side walls. Buildings face straight down toward viewer like classic screen-aligned 2D strategy game buildings. No tilted composition. Arrange exactly THREE equal 512x512 columns and TWO equal 512x512 rows in a 1536x1024 transparent canvas, one complete isolated object in each cell, 20px transparent margin, no overlap or clipping. Top row: large Orc clan hall open central doorway and symmetrical tusk pillars; open-front Orc smithy with horizontal roofline and central forge; small timber store with centered door. Bottom row: smith's workbench and anvil facing straight forward; hide-covered bed with footboard horizontal at bottom and headboard horizontal at top; open timber supply chest with front edge horizontal. Keep drawn game art, not photorealism, no glossy 3D, no scenery, no text. Actual transparent background, no painted background or contact-shadow halo.

The generator did not preserve equal-width cells; consuming metadata uses inspected object bounds instead.

## 0.3 ground

Built-in image tool, new generation.

Use case: stylized-concept. Asset type: seamless tileable dirt ground texture for a hand-inked 2D fantasy strategy game, directly overhead with absolutely no camera tilt or perspective. Square 1024x1024. Dry trampled grey-brown soil, subtle small irregular packed-earth patches, a few very small slate chips, fine boot scuffs. Flat diffuse neutral daylight. Broad restrained hand-painted gouache planes with sparse tiny pen marks. Low contrast, muted umber and grey-tan, readable as ground under colorful characters. Uniform material across the whole image, seamless edges, no central composition, no grass, no plants, no buildings, no characters, no large rocks, no border, no text, no realistic photograph.

## 0.3 creature and details — retained specifications

Built-in image tool, original project assets. Wolf: transparent 4×2 atlas of one dark-grey direwolf facing right, four walking poses followed by crouched charge warning, lunge, recoil and dead poses; elevated game view, strong ink contours and broad painted planes. Details: transparent 3×2 atlas containing an Orc practice dummy, eastern signpost, supply bundle/chest, clan banner, cooking rack and wolf pelt. The initial call used the earlier elevated three-quarter direction; architecture and furniture were subsequently corrected to square alignment. These are specifications, not a verbatim transcript of those two prompts.
