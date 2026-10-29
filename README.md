# Chiefs of War

An original Godot 4 top-down Orc sandbox. **0.1.0 is a world-systems prototype, not the promised 15–30 minute vertical slice.**

This project is independent of The Stellar Holds. No code or art was imported from that game.

## Play

Extract the Windows ZIP and launch `ChiefsOfWar.exe`. Godot does not need to be installed. This build is unsigned. The Windows export was produced successfully; native Windows execution was not available in the development environment. Linux Godot import, live rendering, and automated scene tests were run.

For source: import `project.godot` into Godot **4.4.1**, then press F6 on `scenes/hearth.tscn` or F5 to run the project.

## Included

- Four-direction whole-body Orc movement candidate, with leather / heavy iron outfit switching.
- Independent persistent trees, logs, rocks, wall segments, roof parts and a contained hearth.
- Damageable objects: trees become stumps plus collectible timber; wall removal opens a physical gap.
- Cell-editable terrain with earth firebreaks and water collision.
- Fire ignition, heat buildup, limited-radius wind-biased spread, fuel consumption, fire damage and charred remains.
- Contained hearth safety, explicit ignition causes only, spread toggle, free prototype extinguishing with wet protection, warned test disaster, and recovery checkpoint.
- Versioned world save: objects, terrain, damage, fires, timber, equipment and player position.

## Controls

| Key | Action |
| --- | --- |
| WASD | Walk |
| E | Inspect nearby object / collect timber |
| C | Compare leather and iron whole-body outfit candidates |
| G | Wet / extinguish nearby objects; cancel pending test disaster |
| J | Help; pauses simulation while open |
| L | Advance lighting preview |
| F1 + arrows | Review direction / animation frames |
| F3 | Toggle clearly labeled world test tools |
| F5 | Save world |
| F6 | Restore checkpoint from before last warned test disaster |
| Escape | Close help, or save and exit |

With F3 enabled: click near an object's base to apply 25 test damage; I ignites the hovered object; B/T/R/O place wall/tree/rock/roof at the cursor; right-click cycles grass/earth/water; P toggles spread; F4 schedules an eight-second warned test ignition and saves a recovery checkpoint. These are development tools, **not finished attacks, construction, or woodcutting actions**. Trees take four test hits; walls take six. E collects the resulting logs.

Saves live in Godot's `user://` directory, typically `%APPDATA%/Godot/app_userdata/Chiefs of War/` on Windows. `world_v2.json` is the current save; `before_test_disaster.json` is the recovery checkpoint. There is no offline fire progression.

## Verification

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/foundation_test.gd -- --fresh
godot --headless --path . --export-release "Windows Desktop"
```

Use a separate `XDG_DATA_HOME` for automated testing on Linux. Tests cover 35 checks including physical wall traversal, water collision changes, persistence, and fire safety. See `docs/QA.md` for limitations.

## Status

Foundation implemented. Living-Orc art is under review. Gathering/combat/worker loops, individually equipped armor slots, building support/collapse, and the narrative prologue are not finished. See `docs/ROADMAP.md` and the original `docs/MASTER_BRIEF.md`.
