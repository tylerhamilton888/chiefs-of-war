# Hearth and Hunger

An original 2D nomadic Ogre sandbox in Godot 4.4.1, continuing the Chiefs of War project and its history. Our existing bright, inked game style stays; the new concepts supply Ogre and traveling-clan design ideas.

## First playable pivot — 0.6.2

Choose **Enter the wandering hearth** from the title. Walk as the new strongman Ogre through a woodland camp with a covered wagon, canvas shelter, cooking hearth and provisions. Collect fallen timber, take meat from the supplies and prepare stored meals. WASD moves, E interacts, F5 saves and Esc opens the menu. Progress persists separately from earlier characters.

This is an initial playable pivot, not a completed overhaul or sandbox. Ogre combat, equipment swapping, camp travel/deployment, beasts and family simulation remain future milestones. Generated character art and four-frame movement need user review; assets are not human-drawn.

The Windows package uses **HearthAndHunger.exe**. See [0.6.2 release notes](docs/RELEASE_0_6_2.md). Publication is complete only when the GitHub release contains the verified ZIP and checksum.

## Earlier campaigns

The original characters, three save slots, appearance customization, hunting/combat, village and practice yard remain playable under Earlier campaigns. The rename preserves the original save folder and all campaign paths. [Earlier game guide](docs/LEGACY_CHIEFS_README.md). [Pre-pivot archive](https://github.com/tylerhamilton888/chiefs-of-war/tree/archive/chiefs-before-hearth-and-hunger).

## Development

Open project.godot with Godot 4.4.1. Main scene: scenes/main_menu.tscn. --ogre-hearth enters the new scene directly. See [governing pivot](docs/design/hearth-and-hunger.md), [implementation](docs/engineering/ogre-pivot.md), and [complete user directive](docs/source/HEARTH_AND_HUNGER_DIRECTIVE.txt).

Read AGENTS.md and the current state before editing. Tests use isolated XDG_DATA_HOME; never test against user campaigns. The reusable release workflow checks imports, regressions, actual rendering, Windows export, native Windows startup and downloaded archives before publication.
