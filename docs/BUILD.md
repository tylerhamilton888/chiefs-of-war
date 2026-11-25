# Build and validation

Open the repository in Godot 4.4.1 and run scenes/main_menu.tscn. The optional game argument --chapter-one opens the same campaign directly.

From the repository root, use a temporary user-data directory for every test. These suites create and modify test saves.

```sh
godot --headless --editor --import --quit
for suite in menu_flow_test loading_test chapter_test chapter_quality_test ogre_scale_test ogre_navigation_test; do
  XDG_DATA_HOME="$(mktemp -d)" godot --headless --fixed-fps 60 --script "tests/$suite.gd" -- --test || exit 1
done
python3 -m unittest discover -s tools -p test_release.py
```

The Windows workflow also renders the campaign and loading screens, exports the embedded executable with matching templates, packages notices, checks the exported game data, and starts the executable on Windows. For a manual export, create builds/windows and run:

```sh
godot --headless --export-release "Windows Desktop" builds/windows/HearthAndHunger.exe
```

See [release procedure](engineering/validation-and-release.md) before publishing a new version.
