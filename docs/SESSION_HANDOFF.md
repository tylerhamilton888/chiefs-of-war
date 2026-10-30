# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Canonical state

Canonical development branch: `warlord`. The customization and recovered combat changes are merged there; do not reconstruct or re-merge them from old chats. Verified source checkpoint before this documentation audit: `9c1ab3ad00cab4b34813185d359474f47d07be84`. Historical feature/recovery branches are retained for traceability. Local workspace paths below are optional runtime aids, not the source of truth. Preserve any surviving uncommitted work in older workspaces.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Verified delivery / next step

Published v0.4.1 — Faces of Ashfang: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.1 . Source `339183d219d89a4a497d3eb2b9dae1def686cfc2`, CI run `41094541852` succeeded including regressions, rendered menus, export, pack smoke and ZIP integrity. ZIP is 78,926,376 bytes; SHA-256 `c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81`. Native Windows playtesting remains unverified.

The requested customization is delivered. Next: gather the user's playtest feedback on appearance and combat/gathering feel; do not automatically expand scope. The release workflow is scoped to the explicit release/customization-0.4.1 branch; do not push ordinary follow-up docs to that branch (it would try to republish the existing tag).

## Runtime

Godot 4.4.1: `/workspace/scratch/dcdfb20f8502/runtime/Godot_v4.4.1-stable_linux.x86_64`. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. All source/art changes are remotely committed. Verify actual branch heads for subsequent checkpoints. Never force-push or replace repository ancestry.

## Repository readiness audit — 2026-10-30

Confirmed default branch is warlord; feature/orc-customization was identical to its head at audit start. Release source is an ancestor of that head, with documentation-only follow-up changes. Release assets and successful CI were verified against GitHub. Original master-brief checksum and all 19 section assignments across eight shards verified. Current scene/script literal resource references resolve. No build executables, archives or .godot cache are tracked. Stale unmerged-combat notes were corrected. See engineering/validation-and-release.md for the proven Actions publication path and the empty historical v0.4.0 release. Gameplay code and published artifacts were not changed by this audit.
