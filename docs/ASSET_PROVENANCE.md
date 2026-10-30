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

## 0.3 assets

`assets/opener/wolf.png`, `details.png`, `architecture_aligned.png`, and `earth.png` were generated with the built-in image tool on 2026-10-30. The architecture is a new square-aligned redraw of the project's earlier generated architecture, replacing its diagonal yaw. Wolf and detail atlases contain complete isolated poses/objects; their source pixels are preserved and regions are described in JSON. The earth tile contains no harvestable scenery. A live terrain-mask shader blends it with the grass.

`ambient.wav`, `swing.wav`, `growl.wav` and `success.wav` are original deterministic synthesizer outputs (seeded noise, filters, oscillators and envelopes), without sampled recordings. Their generation script is in `tools/make_opener_audio.py`.

The skin/cloth shader is a limited palette recoloring, not a body-part rig or an independently layered armor system. This release does not claim final animation approval or human-authored drawings.

## 0.3.1 hulking Orc revision

Five original source atlases in `assets/motion/source` were generated with the built-in image generation tool. Reference: the project's prior Orcs, revised toward Garrosh-like extreme nonhuman musculature without copying his costume. Prompts specify huge traps, near-neckless shoulders, outsized forearms/hands, projecting tusked jaw, and short thick legs. Leather: fur collar, crossed brown harness, blue loincloth; iron: dark plates, red loincloth.

`tools/pack_motion.cjs` extracts whole sprites, excludes disconnected neighbouring fragments, preserves their alpha, resizes uniformly and packs fixed pelvis/ground anchors. No skeletal deformation or rotating body parts. Left views mirror right views. Final assets: stride/rest/strike in both outfits. Source atlas backgrounds contain RGB matte values under zero alpha; this is not an opaque background in-game.

Early narrow-bodied replacement candidates were rejected and are not used. Four-pose cycles remain a limited stylized animation, not a claim of final animation quality.

## 0.3.2 clan and decor pass

`assets/polish/clan_portraits.png`, `clan_idle.png` and `decor.png` are original AI-generated illustrations created with OpenAI image generation for this project. No third-party character art was copied. Direction: rugged inked/painted Orc clan, massive tusked male silhouettes, feminine tusked Yrsa, square-facing timber/iron furnishings. Runtime atlas regions are defined in `scripts/clan_art.gd`; preserve their alpha channels. Idle art has two key poses per NPC, not full bespoke animation cycles. Bren retains the existing shared locomotion and axe cycles when working.
