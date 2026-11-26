# Hearth and Hunger

An illustrated, three-quarter-view Ogre RPG made in Godot 4.4.1. The campaign opens with *The Fire We Carry*. Help Bramm repair the family wagon at Emberhide Crossing, go on your first hunt, and carry the household through the burning of Emberhide to the Stonebelly Host. After repairing the wheel and cooking, you can bring Bramm a spare bowl at the wagon. The same journey continues when you earn a wagon of your own.

Open `project.godot` and run the main scene. Choose **Begin Journey** to create your Ogre or **Continue** to resume. The title, journal, roads and personal wagon all belong to the same campaign. The campaign uses the existing `fire_we_carry_v1.json` save. Retired Orc and Frontier saves are left on disk and can still be opened with their original versions.

WASD walks, Shift runs while traveling, left click swings the equipped weapon toward the cursor, right click guards or parries, and Space dodges. Press E to interact, Q to eat, J for routes and objectives, I for belongings and equipment, F5 to save, and Esc to pause.

[Start here](START_HERE.md) · [Game Design Bible](docs/design/GAME_DESIGN_BIBLE.md) · [Opening chapter outline](docs/design/OPENING_OUTLINE.md) · [Current development state](docs/state/current.md) · [Build and validation](docs/BUILD.md)

The [0.8.10 release](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.10) archives the previous multi-mode build. Its Frontier world, inventories, tests and full combat orchestration remain available there. Reusable Ogre actors, art and weapon definitions are retained in source for the shared combat work.

Choose **Practice Yard** on the title screen to try the current movement and weapon animations against a goblin and an Orc raider. To open the same yard directly, launch `HearthAndHunger.exe -- --developer-arena` or run `scenes/developer_arena.tscn` from the editor. Tab changes weapon, H toggles the helm, B toggles the mantle, R resets the encounter and Esc returns to the title. After a clean axe kill, F eats the goblin cut, or E packs it. Carry it to the pot and press E to make two portions of stew. Arena play uses disposable progress.
