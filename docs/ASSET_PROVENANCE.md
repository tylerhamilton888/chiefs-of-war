# Asset provenance

All project code was newly authored for Chiefs of War. Godot 4.4.1 is the runtime, distributed under its own MIT license and third-party notices. See THIRD_PARTY_NOTICES.txt in the build.

The following assets were generated with the built-in image-generation tool on 2026-10-29, for this original project:

| Asset | Role | Status |
| --- | --- | --- |
| assets/characters/orc_walk_candidate.png | 16 full-body directional walking illustrations | Candidate; weak passing poses, not final |
| assets/characters/orc_iron_candidate.png | Same character in heavy iron outfit | Candidate; identity/action consistency needs refinement |
| assets/environment/props.png | Independent tree, stump, log, rock, wall and roof regions | Prototype; alignment and final harsh style pending |
| assets/environment/grass.png | Ground-only material | Prototype; no harvestables or buildings baked in |

The user's Fantasy Orc Game Art Acceptance Board supplied style reference for the first character. It was read as reference, not imported as game geometry. No Warcraft, Warhammer or Stellar Holds assets were imported. The initial painted clearing was removed from gameplay after the modularity correction. The generated axe-swing sheet is rejected and not shipped because west-facing strike poses face east and cell boundaries clip some poses.

No external sound assets are included. Prototype fire shapes and terrain overlays are drawn by project code. The engine's default font is covered by Godot's included notices. Generated artwork is not claimed to be human-hand-drawn, exclusively copyrightable, or independently legally cleared; it uses an illustrated visual treatment and must pass final production review.

Prompt specifications are retained in ART_PROMPTS.md. Original image pixels are retained; atlas regions are selected using metadata, not body-part deformation.

## 0.2 assets

All `assets/camp/*.png` are original project candidates produced with the built-in image-generation tool using the user's October 29 character/style board and subsequent generated character references. They are **AI-generated in a hand-drawn visual style**, not human-drawn commissions. No Warcraft II asset files were imported; its role is general readability/art-direction reference only. Photoreal-looking first-pass portraits and architecture were rejected in favor of the user's inked reference.

`architecture.png`, `props.png`, `portraits.png`, `walk_leather.png`, `walk_iron.png`, `attack_leather.png`, `attack_iron.png`, `floor.png`, and `npcs.png` supply the current art. Atlas metadata preserves original image pixels and selects whole-body regions. Four short WAVs were newly synthesized from decaying oscillators and seeded noise; no external audio recordings were used. Current sprites remain unapproved candidates.
