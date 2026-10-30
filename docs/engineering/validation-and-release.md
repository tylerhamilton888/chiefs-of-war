# Validation and release runbook

Use Godot **4.4.1**, matching official export templates, and the repository's Windows Desktop preset. Main scene: `scenes/opener.tscn`. Native Windows execution and human playfeel are separate from Linux engine/export checks.

## Before checks

Import with `godot --headless --path . --editor --import --quit`. Inspect errors, not only exit status. Use separate temporary `XDG_DATA_HOME` directories for suites so tests never overwrite a player's campaign or each other's files. `-- --fresh --test` starts isolated test behavior. `--fixed-fps 60` makes frame-based suites reproducible and faster; use a display for layout/visual tests.

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
| `tests/execution_test.gd` | Execution opportunity, contact, cleanup, options and persistence; inspect current file for exact coverage |

Command pattern: `godot --headless --path . --fixed-fps 60 --script tests/opener_test.gd -- --fresh --test`. Omit `--headless` and select `--rendering-method gl_compatibility` for rendered suites. Record the actual suite output and any Godot errors in QA.md; never carry forward old counts as fresh evidence.

Use visual scripts for actual engine frames. Verify both outfits, mirrored facing, attacker/target contact, frame gutters, foot anchors, menus and return to control. A technically playing animation is not automatically accepted.

## Windows export

Create `builds/windows`, then run `godot --headless --path . --export-release "Windows Desktop" builds/windows/ChiefsOfWar.exe`. The preset embeds its PCK. Use an official matching custom template path if templates are not installed in the normal Godot location; do not commit machine-specific paths.

Run relevant tests against the exported pack as well when possible. A pack run under Linux validates packaged resources/scripts, not native Windows compatibility. Package the EXE with controls/readme, exact build/source information and third-party engine notices. Include a fresh-game launcher only with a clear save-slot warning. Validate ZIP integrity and SHA-256.

## Publish and verify

Commit/sync final source, documentation and asset provenance; preserve upstream ancestry. Publish an actual GitHub release with Windows ZIP, checksum file and useful engine preview/clip. Confirm it is published rather than draft and verify assets are attached with correct names/sizes. The GitHub connection may not provide release-upload operations; an authorized signed-in browser is a fallback for that missing capability.

Record source SHA, release URL and tests in current state/handoff. Do not call source-only progress a playable release, or omit known native-Windows/animation/human-playtest limitations. If blocked, checkpoint explicit WIP and identify the concrete blocker.
