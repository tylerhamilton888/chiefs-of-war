# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Active work

User requested expanded face/hair/skin customization and starting colors after the recovery conversation failed. Working checkout: `/workspace/scratch/5065e2351aee/chiefs-of-war`, branch `feature/orc-customization`. Based on GitHub recovery commit `7c9f30a24a2dae923765581eb827e40f177d9192`; local checkpoint `491e296` preserves later recovered combat artwork and fixes. Do not touch or discard the old `/workspace/scratch/dcdfb20f8502/chiefs-of-war-complete` workspace.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Verified delivery / next step

Published v0.4.1 — Faces of Ashfang: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.1 . Source `339183d219d89a4a497d3eb2b9dae1def686cfc2`, CI run `41094541852` succeeded including regressions, rendered menus, export, pack smoke and ZIP integrity. ZIP is 78,926,376 bytes; SHA-256 `c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81`. Native Windows playtesting remains unverified.

The requested customization is delivered. Next: gather the user's playtest feedback on appearance and combat/gathering feel; do not automatically expand scope. The release workflow is scoped to the explicit release/customization-0.4.1 branch; do not push ordinary follow-up docs to that branch (it would try to republish the existing tag).

## Runtime

Godot 4.4.1: `/workspace/scratch/dcdfb20f8502/runtime/Godot_v4.4.1-stable_linux.x86_64`. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. All source/art changes are remotely committed. Verify actual branch heads for subsequent checkpoints. Never force-push or replace repository ancestry.
