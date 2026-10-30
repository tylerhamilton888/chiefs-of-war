# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Canonical state

Canonical development branch: `warlord`. The customization and recovered combat changes are merged there; do not reconstruct or re-merge them from old chats. The clear-launch source `2e0de70a05858ef94beb00f8a2113bfb947df4a8` and concurrent recovery checkpoint `2767978d3ccec559075f346cdd8fcca55942036a` are reconciled with both ancestries retained. Historical feature/recovery branches are retained for traceability. Local workspace paths below are optional runtime aids, not the source of truth. Preserve any surviving uncommitted work in older workspaces.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Verified delivery / next step

Published [v0.4.2](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.4.2), source `2e0de70a05858ef94beb00f8a2113bfb947df4a8`; run `41110249369` passed package, native Windows startup/exit and publication. ZIP `ChiefsOfWar-Windows-0.4.2.zip`: 78,945,015 bytes; SHA-256 `822b115c137d9f0d52e12cef64406c6330067e47a50016dc4fc5500a84121f09`. Native Windows normal and practice startup/exit, path spaces, external working directory and campaign isolation passed with clean game logs. Human graphical playfeel remains unverified.

The current download is Extract All → ChiefsOfWar.exe, with START HERE.txt at the root. No Godot installation is needed. Existing customization/combat and save location are preserved. Shutdown was repaired: audio stops before tree teardown; creator/practice quit without a campaign save; a failed campaign save keeps the game open. Local customization (73 checks), practice isolation and normal/practice startup passed.

Concurrent publication recovery from `2767978` is retained. The canonical reusable windows-release.yml now uses the clear package helper and native Windows job before its draft-first verified publication. release.json is 0.4.2 with package_layout clear-launch; release.py validates both old/new layouts. All 16 failure/retry/layout tests pass locally. The already-triggered one-version run delivered 0.4.2 before reconciliation; its workflow is removed on warlord. Never republish that tag from a new source. Future releases use the reusable runbook and a new version.

Next: gather user appearance/combat/gathering feedback; do not automatically expand scope. ChatGPT unknown-error internals remain unavailable; repository corruption was not established.

## Runtime

Current verified local Godot 4.4.1 executable: `/workspace/scratch/5065e2351aee/runtime/godot-complete`. The former Godot runtime under `/workspace/scratch/dcdfb20f8502/runtime` is no longer present. Do not assume a previous scratch runtime survives. The checked-in release workflows provision Godot 4.4.1 and matching export templates independently. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. All source/art changes are remotely committed. Verify actual branch heads for subsequent checkpoints. Never force-push or replace repository ancestry.

## Repository readiness audit — 2026-10-30

Confirmed default branch is warlord; feature/orc-customization was identical to its head at audit start. Release source is an ancestor of that head, with documentation-only follow-up changes. Release assets and successful CI were verified against GitHub. Original master-brief checksum and all 19 section assignments across eight shards verified. Current scene/script literal resource references resolve. No build executables, archives or .godot cache are tracked. Stale unmerged-combat notes were corrected. See engineering/validation-and-release.md for the proven Actions publication path and the empty historical v0.4.0 release. Gameplay code and published artifacts were not changed by this audit.
