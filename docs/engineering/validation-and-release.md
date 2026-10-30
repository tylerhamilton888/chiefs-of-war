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

The standard route is **GitHub Actions**, not a browser release form. The connector can sync source but has no release upload operation, and this environment has no authenticated terminal Git push. GitHub's runner has its own short-lived `github.token`; do not ask the user for a token or pass binary releases through chat tool arguments.

1. Update `release.json` (version, title, notes path, prerelease flag), the project version and release notes for an actual new game release. Preserve the current prerelease policy unless the requested milestone warrants changing it. Never reuse a published version for another source commit.
2. Commit/sync source with upstream ancestry and expected-head protection. A push to `warlord` runs `.github/workflows/windows-release.yml` in **build/check mode only**. It does not publish a release. The run retains the Windows ZIP and logs as Actions artifacts for 14 days.
3. When release delivery is authorized, create the branch `release/vX.Y.Z` at that exact tested source commit using GitHub `create_branch` (or authenticated Git). A branch push triggers publication. Alternatively, GitHub Actions → Windows build and release → Run workflow → select the intended source branch → check `publish`. The manual action defaults to build/check only. No new permission is needed when the user has already requested delivery.
4. The runner imports, tests, renders, exports, checks the pack and ZIP, and saves an artifact **before** publishing. It creates/resumes a draft, uploads files, downloads them again, verifies checksums/archive/source identity, and only then publishes. A retry of the same published source verifies it without replacing anything. Another source under that tag fails explicitly. Timeouts, retained logs and a run summary provide a concrete failure instead of an indefinite browser upload.
5. Confirm the run succeeded and the release has `draft=false`, its Windows ZIP, checksum and preview. Record source SHA, run ID, release URL and relevant limitations in current state/handoff. Automated Linux pack checks do not establish native Windows or human playfeel acceptance.

Do not use the old `release/customization-0.4.1` branch for new work: its historical workflow hard-codes an already-published version. The reusable workflow replaces it on `warlord`.

### Interrupted chat or ambiguous tool result

Read GitHub state before retrying any mutation: `GET /repos/tylerhamilton888/chiefs-of-war/actions/runs?per_page=10` and the release/tag/assets. Use the GitHub connector's read-only `fetch`; retain only compact status fields, never dump full API responses or binary/base64 data into the conversation. Resume/poll the existing run. The connector's rerun-failed-jobs operation can retry a failed run; do not create a replacement chat, duplicate release branch or replacement tag as a troubleshooting step.

If GitHub already succeeded, finish verification and report the link. If a run failed, retrieve that job's logs and fix its concrete error. If a tool fails repeatedly, checkpoint source/run IDs and explain the exact blocker; do not cycle through the same failing path. An empty published release is not a playable build. Do not silently delete or rewrite a user's manual release.

### October 30 incident: confirmed evidence and limits

- Release v0.4.1 was published by `github-actions[bot]` at 17:01:01 UTC / 1:01:01 p.m. Eastern. Run `41094541852` passed every step. Its Windows ZIP is 78,926,376 bytes and SHA-256 is `c7dad59b295069f4f3ba13f8039e7b55851da837915ff17721d3f8cc12320b81`.
- A separate manually published v0.4.0 appeared at 18:29:26 UTC / 2:29:26 p.m. Eastern with no attached assets. It is not the latest playable Windows build.
- The historical workflow was hard-coded to one branch/tag/version and used a single `gh release create` operation; it was not a reusable, resumable release path. Browser-based publication was also documented because the connector lacked upload support.
- ChatGPT's internal error trace is unavailable. None of this proves why Work displayed “unknown error”; don't label a browser timeout, context size, permissions, or repository corruption as the established cause. The changes remove avoidable release dependencies and preserve progress outside the chat; they do not promise to repair the ChatGPT service.

## Fast playtest

Run the packaged `Combat-Practice.bat`, or `godot --path . -- --combat-yard`. This mode never loads or writes campaign files; reset through its pause menu. Use a temporary XDG_DATA_HOME and `--combat-yard --test` for practice_test.gd, which writes a deliberate sentinel only in that isolated location. The normal EXE continues the campaign.


Verified download is v0.4.1 (a published prerelease with attached assets). A separate v0.4.0 release has no assets as of this audit; it is not a playable delivery. Use the explicit v0.4.1 URL in the README, not GitHub's generic latest-stable shortcut. Preserve historical releases unless the user asks to remove them.
