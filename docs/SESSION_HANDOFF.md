# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Canonical state

Canonical development branch: `warlord`. The customization and recovered combat changes are merged there; do not reconstruct or re-merge them from old chats. Verified source checkpoint before this documentation audit: `9c1ab3ad00cab4b34813185d359474f47d07be84`. Historical feature/recovery branches are retained for traceability. Local workspace paths below are optional runtime aids, not the source of truth. Preserve any surviving uncommitted work in older workspaces.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Verified delivery / next step

Published v0.4.1 — Faces of Ashfang: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.1 . Source `339183d219d89a4a497d3eb2b9dae1def686cfc2`, CI run `41094541852` succeeded including regressions, rendered menus, export, pack smoke and ZIP integrity. ZIP is 78,926,376 bytes; SHA-256 `c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81`. Native Windows playtesting remains unverified.

The requested customization is delivered. Subsequent task: diagnose repeated publication/chat failures and make publication reliable. The reusable `.github/workflows/windows-release.yml`, `release.json`, and `tools/release.py` replace the one-version workflow. See engineering/validation-and-release.md for the authoritative procedure and incident evidence. Publishing is done by GitHub Actions; ordinary `warlord` pushes only build/check. Do not return to the browser upload path or push to the historical release/customization-0.4.1 branch.

Publication repair is verified: source `4e070a985b4b14103d03ebe1e8edaa87791e4ae8`, GitHub run `41108614385` succeeded. All 14 publication failure/retry tests passed, as did game regressions, rendered UI, Windows export, packaged smoke and ZIP integrity. The workflow freshly downloaded and verified the existing v0.4.1 release without changing it, and retained build artifact `13003011598` and logs `13003486823`. The new draft/upload failure branches have automated tests; this repair intentionally did not publish another game version. Do not claim ChatGPT's internal unknown-error root cause is diagnosed; those logs are unavailable. v0.4.1 is the latest verified playable build. The manually published v0.4.0 has no attached assets and has been left intact.

Next: gather the user's appearance/combat/gathering playtest feedback; do not automatically expand game scope. On the next requested release, update release.json/project version/notes and use the release runbook.

## Runtime

Godot 4.4.1: `/workspace/scratch/dcdfb20f8502/runtime/Godot_v4.4.1-stable_linux.x86_64`. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. All source/art changes are remotely committed. Verify actual branch heads for subsequent checkpoints. Never force-push or replace repository ancestry.

## Repository readiness audit — 2026-10-30

Confirmed default branch is warlord; feature/orc-customization was identical to its head at audit start. Release source is an ancestor of that head, with documentation-only follow-up changes. Release assets and successful CI were verified against GitHub. Original master-brief checksum and all 19 section assignments across eight shards verified. Current scene/script literal resource references resolve. No build executables, archives or .godot cache are tracked. Stale unmerged-combat notes were corrected. See engineering/validation-and-release.md for the proven Actions publication path and the empty historical v0.4.0 release. Gameplay code and published artifacts were not changed by this audit.
