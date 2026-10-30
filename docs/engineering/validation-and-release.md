# Validation and release runbook

Use Godot **4.4.1**, matching official export templates, and the repository's Windows Desktop preset. Main scene: `scenes/opener.tscn`. Native Windows execution and human playfeel are separate from Linux engine/export checks.

## Before checks

Import with `godot --headless --path . --editor --import --quit`. Inspect errors, not only exit status. Use separate temporary `XDG_DATA_HOME` directories for suites so tests never overwrite a player's campaign or each other's files. `-- --fresh --test` starts isolated test behavior. `--fixed-fps 60` makes frame-based suites reproducible and faster; use a display for layout/visual tests.

Execution, appearance and visual review tests are included on canonical `warlord`. The recovery and feature branches are historical checkpoints, not required sources for missing current features.

## Suites

| Script | Evidence |
| --- | --- |
| `tests/foundation_test.gd` | Independent state, persistence, ignition/firebreak/wetness and basic collisions |
| `tests/camp_test.gd` | Legacy melee/gathering/building/equipment/worker regression |
| `tests/worker_test.gd` | Physical worker cargo/deposit behavior |
| `tests/opener_test.gd` | Complete opening using movement and actual combat through forging |
| `tests/opener_edges.gd` | Cancellation, save validation, menus, fire/recovery and buffered attacks |
| `tests/motion_test.gd` | Outfit imports, grounding, cadence, facing and recovery |
| `tests/polish_test.gd` | Rendered room collision, door approach, menu layout and trophy state |
| `tests/feel_test.gd` | Axe contact latency, single impact, dodge follow-up, action locks and visible gathering damage |
| `tests/practice_test.gd` | `--combat-yard` entry, campaign sentinel untouched, rendered menu fits |
| `tests/execution_test.gd` | Execution opportunity, contact, cleanup, options and persistence; inspect current file for exact coverage |

Command pattern: `godot --headless --path . --fixed-fps 60 --script tests/opener_test.gd -- --fresh --test`. Omit `--headless` and select `--rendering-method gl_compatibility` for rendered suites. Record the actual suite output and any Godot errors in QA.md; never carry forward old counts as fresh evidence.

Use visual scripts for actual engine frames. Verify both outfits, mirrored facing, attacker/target contact, frame gutters, foot anchors, menus and return to control. A technically playing animation is not automatically accepted.

## Windows export

Create `builds/windows`, then run `godot --headless --path . --export-release "Windows Desktop" builds/windows/ChiefsOfWar.exe`. The preset embeds its PCK. Use an official matching custom template path if templates are not installed in the normal Godot location; do not commit machine-specific paths.

Run relevant tests against the exported pack as well when possible. A pack run under Linux validates packaged resources/scripts, not native Windows compatibility. Package the EXE with controls/readme, exact build/source information and third-party engine notices. Include a fresh-game launcher only with a clear save-slot warning. Validate ZIP integrity and SHA-256.

## Publish and verify

Commit/sync final source, documentation and asset provenance; preserve upstream ancestry. Publish an actual GitHub release with Windows ZIP, checksum file and useful engine preview/clip. Confirm it is published rather than draft and verify assets are attached with correct names/sizes. Use GitHub Actions for release uploads. The verified path is `.github/workflows/customization-release.yml`, successfully used by run `41094541852`. Do not repeatedly attempt unauthenticated terminal pushes or switch to browser uploads when this workflow can perform the release.

Record source SHA, release URL and tests in current state/handoff. Do not call source-only progress a playable release, or omit known native-Windows/animation/human-playtest limitations. If blocked, checkpoint explicit WIP and identify the concrete blocker.

## Fast playtest

Run the packaged `Combat-Practice.bat`, or `godot --path . -- --combat-yard`. This mode never loads or writes campaign files; reset through its pause menu. Use a temporary XDG_DATA_HOME and `--combat-yard --test` for practice_test.gd, which writes a deliberate sentinel only in that isolated location. The normal EXE continues the campaign.


## Repeatable publication and recovery

1. Start from current `warlord`. The 0.4.1 source and art are already merged. Preserve any new upstream changes.
2. For the next requested release, adapt the checked-in workflow to a new explicit release branch and unused version tag. Update the project version, release notes and artifact names together. The existing `release/customization-0.4.1` trigger/tag is historical; pushing to it again would try to create an already-existing release.
3. Commit/sync the source first, then create the chosen release branch at that exact commit. GitHub Actions performs import, regressions, rendered UI checks, export, packaged-resource smoke, ZIP integrity, checksum and publication.
4. Inspect the run status and failing step/logs. A failed build is a concrete CI failure; it is not evidence about a ChatGPT client error. If the run is successful, inspect release metadata and assets before taking any further write action. Do not publish duplicates because the chat UI stalled.
5. Record the immutable source SHA, release URL, ZIP size/digest and run ID in current state/handoff, then bring the accepted source and continuity updates into `warlord` with ancestry preserved.

Verified download is v0.4.1 (a published prerelease with attached assets). A separate v0.4.0 release has no assets as of this audit; it is not a playable delivery. Use the explicit v0.4.1 URL in the README, not GitHub's generic latest-stable shortcut. Preserve historical releases unless the user asks to remove them.
