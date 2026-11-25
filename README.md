# Hearth and Hunger

An illustrated, three-quarter-view Ogre RPG made in Godot 4.4.1. The campaign opens with *The Fire We Carry*. Help Bramm repair the family wagon at Emberhide Crossing, go on your first hunt, and carry the household through the burning of Emberhide to the Stonebelly Host. The same journey continues when you earn a wagon of your own.

Open `project.godot` and run the main scene. Choose **Begin Journey** to create your Ogre or **Continue** to resume. The title, journal, roads and personal wagon all belong to the same campaign. The campaign uses the existing `fire_we_carry_v1.json` save. Retired Orc and Frontier saves are left on disk and can still be opened with their original versions.

WASD walks, Shift moves briskly, left click swings the equipped weapon toward the cursor, right click guards or parries, and Space dodges. Press E to interact, Q to eat, J for routes and objectives, I for belongings and weapon selection, F5 to save, and Esc to pause.

[Start here](START_HERE.md) · [Game Design Bible](docs/design/GAME_DESIGN_BIBLE.md) · [Opening chapter outline](docs/design/OPENING_OUTLINE.md) · [Current development state](docs/state/current.md) · [Build and validation](docs/BUILD.md)

The [0.8.10 release](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.10) archives the previous multi-mode build. Its Frontier world, inventories, tests and full combat orchestration remain available there. Reusable Ogre actors, art and weapon definitions are retained in source for the shared combat work.

For quick combat testing, launch `HearthAndHunger.exe -- --developer-arena` or run `scenes/developer_arena.tscn` from the editor. Tab changes weapon, R resets the encounter and Esc returns to the title. Arena play uses disposable progress.
