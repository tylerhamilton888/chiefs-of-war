# Asset and animation workflow

Read [character/animation requirements](../design/characters-and-animation.md) and [provenance](../ASSET_PROVENANCE.md) before creating/replacing art. Existing generated assets are candidates; never describe them as human-drawn or final accepted art.

## Existing structure

- `assets/camp`, `assets/characters`, `assets/environment`: earlier prototype art retained for regression scenes.
- `assets/opener`: square-aligned architecture, ground/details, wolf atlas and original synthesized audio.
- `assets/motion`: registered full-body idle/stride/strike atlases in leather/iron.
- `assets/motion/source`: original source candidates, excluded from release exports.
- `resources/*.json`: atlas rectangles and foot anchors. `camp_actor.gd` and `opener_actor.gd` consume them.
- `assets/polish`: clan portraits, idle poses and room/village decor.
- `assets/executions`: finisher/enemy frame candidates included on warlord and in v0.4.1. Their mappings currently live in execution scripts; use the actual mappings, not guessed uniform cells.

## Acceptance loop

1. Inspect the existing character/reference, choose the smallest missing action set, preserve identity/outfit.
2. Generate original full-body poses with generous clear gutters and real transparency. Record prompt/provenance. Do not alter silhouettes with code rotations or arbitrary stretched limbs.
3. Verify actual PNG dimensions/alpha. Author frame rectangles and stable foot/pelvis anchors from actual pixels. Never assume the generator obeyed the requested cell dimensions.
4. Review at gameplay scale, both horizontal facings and supported outfits. No adjacent sprite leakage, severed anatomy, floating tools, scale jumps or foot sliding.
5. Align weapon contact and victim reaction with the actual gameplay impact time. Do not cover a poor strike with a large flash.
6. Import and test the final files, include them in the source commit and exported pack, and record remaining limitations.

Use whole-character frames for primary animation. Horizontal mirroring is a current prototype limitation; do not claim four independently drawn directional executions. Keep configurable blood effects separate from baked art where possible.

Validate downloaded assets against their upstream Git blob hashes. Empty API responses are missing bytes, not valid transparent images. `.godot/` is generated cache; source PNGs, import settings and UID files belong to version control, subject to the repository's existing conventions.

The original hero atlas had neighboring axe fragments inside its frame rectangles. `hero-spaced.png` is the imagegen repacking edit; use its measured rectangles/anchors in execution_opener.gd, not the old HERO_RECTS. Preserve source candidates but exclude superseded atlases from release exports. Check enemy frame gutters similarly.
