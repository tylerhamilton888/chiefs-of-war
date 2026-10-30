# Session handoff

Read AGENTS.md, docs/state/current.md, then only the relevant design/engineering shard.

## Active work

User requested expanded face/hair/skin customization and starting colors after the recovery conversation failed. Working checkout: `/workspace/scratch/5065e2351aee/chiefs-of-war`, branch `feature/orc-customization`. Based on GitHub recovery commit `7c9f30a24a2dae923765581eb827e40f177d9192`; local checkpoint `491e296` preserves later recovered combat artwork and fixes. Do not touch or discard the old `/workspace/scratch/dcdfb20f8502/chiefs-of-war-complete` workspace.

Implemented customization lives in scripts/appearance.gd, orc_palette.gdshader, opener.gd and opener_actor.gd, with finisher integration in execution_opener.gd. Documentation: engineering/customization.md. Review generated artwork as candidate art, not new hand-drawn full-body actions.

## Next step at checkpoint

Appearance registration review and relevant regressions passed (see QA.md). Windows export passed. The explicit release/customization-0.4.1 branch triggers the release workflow; verify CI, published asset and checksum. No new published build is implied by this checkpoint. Native Windows playtesting is unavailable here.

## Runtime

Godot 4.4.1: `/workspace/scratch/dcdfb20f8502/runtime/Godot_v4.4.1-stable_linux.x86_64`. Original Xvfb binary was truncated; a good executable was extracted from runtime/xvfb-complete.deb into `/workspace/scratch/5065e2351aee/xserver`. Launch Xvfb and Godot within the same exec subprocess environment (separate exec calls cannot share its X display). Scratch render helper: `/workspace/scratch/5065e2351aee/render_test.py`. Set CHIEFS_REVIEW_DIR for test screenshots. All tests use isolated XDG_DATA_HOME.

Terminal Git push lacks credentials. Use GitHub connector blob/tree/commit/ref operations with the actual upstream base tree and parent, preserving history. Generated art has already been uploaded as Git blobs; verify actual branch head for subsequent checkpoints. Never force-push or replace repository ancestry.
