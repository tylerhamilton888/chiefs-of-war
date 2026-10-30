# Hearth and Steel implementation

Work branch: feature/hearth-menu-and-combat. Target 0.5.0. Published 0.4.2 remains unchanged until this version passes release gates.

Main entry is scenes/main_menu.tscn. save_slots.gd routes three campaigns: slot one preserves ancestral_hearth_v1.json, then ancestral_hearth_slot_2.json and ancestral_hearth_slot_3.json. Slot-specific fire/expedition checkpoints prevent cross-character recovery. No automatic save deletion or overwrite UI exists. Full load validation remains in opener.gd; a failed existing campaign load returns to the menu and blocks saving. Menu preference is separate menu.cfg. Practice can be entered via menu or legacy CLI and bypasses campaign reads/writes. CLI bypass occurs only at first boot so practice can return to menu.

RMB begins a 0.18-second frontal parry window with 0.55-second rearm cooldown. A successful parry consumes the window and staggers the attacker. Otherwise front blocks consume guard and take 15% chip damage. Rear hits bypass guard. Exhaustion breaks guard for 0.65 seconds, taking 60% of the hit. Guard recovers at 30/second while lowered. Guard permits slow movement; dodge cancels it. Guard can cancel only the final 0.18 seconds of axe recovery, preserving committed contact timing. Pause/work/action cancellation clears guard. Both wolves and raiders use the same defense resolver.

Defensive sprites are whole-body authored poses in four directions for leather and iron, with per-frame silhouette rectangles and foot anchors. No separated body parts or moving standalone weapon substitutes. The existing appearance shader remains active; defensive head registration also clears the source topknot. Six poses per direction: guard, impact, dodge anticipation, step, recovery, ready.

Tests: save_slots_test, menu_flow_test (real creator/audio; no --test), defense_test, and existing customization/opener/edges/motion/feel/execution/practice. hearth_visual and defense_visual render actual game assets. New-character and menu native Windows smoke are separate checks. Tests run only with isolated XDG_DATA_HOME/APPDATA.

## Generated art provenance and prompt set

Built-in image generation was used; no API/CLI generation. Reference assets are this repository's own architecture_aligned.png, rest_leather/iron.png and clan_idle.png. Existing buildings are the style anchor. Files below are project assets, never external runtime dependencies. Human acceptance remains pending.

| Saved project path | Final prompt / specification |
| --- | --- |
| assets/overhaul/menu_hearth.png | Widescreen illustrated dawn Orc village; favored tusked timber hall and slate forge on the right, quiet darker foreground left for menu; warm timber, ivory and crimson; no UI/text. |
| assets/overhaul/props.png | Six isolated whole-object sprites: pine, stump, log bundle, mineral rock, tusked palisade, campfire. Broad shading and dark contours matching buildings, transparent background. |
| assets/overhaul/ground.png | Seamless top-down sage/moss grass over olive-brown earth, sparse tufts and slate pebbles, calm low-contrast painted midtones, no buildings or large props. |
| assets/overhaul/defense_leather.png | 24 coherent full-body muscular adult Orc sprites, six defensive poses across front/left/right/back, brown leather/fur/blue cloth, held axe; spacing refinement to separate silhouettes. |
| assets/overhaul/defense_iron.png | Exact defensive poses/layout with slate iron shoulder/bracer/greave armor and crimson cloth; generous transparent gutters. |
| assets/overhaul/clan_idle.png | Restyle eight NPC poses to broad warm illustrated shading and clear contours; preserve identities. Follow-up changes only adult female keeper's clothing to fitted leather bodice, bare shoulders, narrow midriff, split crimson wrap skirt and knee boots, maintaining neutral poses and grounded anatomy. |

Raw generation outputs remain in the session generated_images directory. Production atlases retain genuine alpha and are referenced directly; resource JSON selects regions without modifying raster art. The optional additional decor generation was interrupted; existing decor remains.

Local verification: all ten suites passed with clean script/runtime logs (customization 73, opener 48, edges 17, motion 20, feel 10, execution 28, defense, slots, real menu flow and practice). Native menu, village, all defensive directions/outfits and Yrsa were rendered with Godot/Mesa. Appearance atlas mipmaps remove severe minification aliasing, and the old topknot is cleared in defensive poses. Publication gate remains pending.
