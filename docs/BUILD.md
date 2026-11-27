# Build and validation

Open the repository in Godot 4.4.1 and run scenes/main_menu.tscn. The optional game argument --chapter-one opens the same campaign directly.

From the repository root, use a temporary user-data directory for every test. These suites create and modify test saves.

```sh
godot --headless --editor --import --quit
for suite in menu_flow_test hearth_walk_test bramm_work_test svala_work_test family_supper_test armed_gait_test dodge_step_test head_gear_test field_kitchen_test chapter_loot_test developer_arena_test cleaver_stroke_test chapter_equipment_test loading_test chapter_test chapter_quality_test ogre_scale_test ogre_navigation_test; do
  XDG_DATA_HOME="$(mktemp -d)" godot --headless --fixed-fps 60 --script "tests/$suite.gd" -- --test || exit 1
done
python3 -m unittest discover -s tools -p test_release.py
```

The Windows workflow also renders the campaign and loading screens, exports the embedded executable with matching templates, packages notices, checks the exported game data, and starts the executable on Windows. For a manual export, create builds/windows and run:

```sh
godot --headless --export-release "Windows Desktop" builds/windows/HearthAndHunger.exe
```

See [release procedure](engineering/validation-and-release.md) before publishing a new version.

## Practice Yard combat capture

From the title, enter **Practice Yard**. Press **V** to toggle combat particles, hit flashes and combat sounds. Footsteps, the swing clock, hit holds, collision and damage use the same settings in both passes. **F2** toggles the HUD and **R** resets the encounter.

Record a continuous 30-second run from the repository root with a display available. Add `--effects-off` after `--cleaver-benchmark` for the matching pass. The capture checks the miss, goblin cut, armored hit, guard, dodge, felling and cookpot through gameplay controls.

```sh
XDG_DATA_HOME="$(mktemp -d)" godot --audio-driver Dummy --fixed-fps 30 --write-movie /tmp/yard.avi --script tests/cleaver_benchmark_capture.gd -- --test --cleaver-benchmark
```

To record the armed run with both armor pieces equipped and combat effects disabled, use the same command with `--script tests/armed_run_capture.gd -- --test --armed-run`. The take keeps the hunting axe equipped through the charges, guard and return run. Append `--maul` to record the same sequence with the iron maul.

For a turning review, run `tests/equipment_turn_capture.gd` with `-- --test --turns`. Add `--maul` for the second weapon. The yard opponents are stationary. The recording turns the cursor through all four facings while ready, guarding and moving, then turns during a sprint and strikes toward the rear.

## Artwork and review images

Keep original artwork and retired variants in `art_source/`. Mirror the corresponding asset folder there so the original is easy to find. Godot ignores this directory and the Windows export excludes it. Store the current game images in `assets/`. Godot's lossless importer preserves sprite transparency and atlas geometry. The four opaque title and loading illustrations use a quality 0.90 lossy import. Their checked-in PNGs retain the original pixels.

Runtime textures target a maximum of 2048 pixels per side. If an atlas is too large, trim transparent gutters or divide it into sheets and update its frame rectangles and foot anchors. Verify the rendered poses at gameplay zoom. Check dimensions before importing with `python3 tools/check_art.py` (Pillow required).

The visual suites write WebP previews outside the game. To make a review copy of an individual image:

```sh
godot --headless --script tools/art_preview.gd -- assets/ogre/menu_camp.png /tmp/hearth-menu.webp
```

The writer preserves aspect ratio and transparency, caps the longest edge at 960 px, aims for 350 KB, and rejects an encoded image above 750 KB. It checks the write and the resulting byte count. The command requires a new output path. For chat, show one preview at a time and keep full-resolution originals in files. Give screenshots, concepts and animation studies their actual labels. A gameplay capture comes from the running game.
