# Windows release procedure

Use the checks in [Build and validation](../BUILD.md) and the checked-in Windows workflow. Each release needs a unique version, matching project.godot and release.json entries, release notes and the exact source commit. Keep published tags immutable.

A push to release/vX.Y.Z triggers publication for that version. A workflow dispatch can request publication explicitly. The workflow packages one GUI executable, the player instructions, build metadata and engine notices. It launches the menu and campaign from the extracted archive on Windows, then verifies uploaded assets and checksums before marking a draft public. Inspect the run and release before retrying.

Use a Linux engine pack check to verify packaged resources. Record native Windows execution and visual playtesting separately.
