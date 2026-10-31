# Hearth and Hunger

An original illustrated 2D Ogre RPG/sandbox in Godot 4.4.1, continuing Chiefs of War and preserving its history. Our existing bright, chunky, outlined game style stays; concept boards guide cultural and character ideas.

[Download the Windows Chapter One build](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.7.0). Extract All, run **HearthAndHunger.exe**, choose **The Fire We Carry · Chapter One**.

The chapter goes from family work and the first hunt through the burning of Emberhide, Hrothgar's duel and Stonebelly's traveling host, to a personal wagon. Nine principal characters, seven connected areas, resource/cooking/construction gameplay, real combat and rescue outcomes, illustrated Godot cinematics, negotiated work and optional individual courtships are integrated into the existing game.

WASD move, E interact, LMB axe, RMB directional block/parry, Space dodge, Q eat, J journal/routes, I belongings, F5 save, Esc pause. Pack at your personal wagon, travel, then B settles it in a safe region. The chapter has an independent save; old campaigns and the first Ogre visit remain available.

This is a first playable chapter, with generated art/animation candidates still subject to human review. Interchangeable weapon/armor wardrobes and generational family simulation remain future work. See [release scope](docs/RELEASE_0_7_0.md), [chapter design](docs/design/chapter-one.md), [implementation](docs/engineering/chapter-one.md), and the [complete user directive](docs/source/FIRE_WE_CARRY_DIRECTIVE.txt).

Open `project.godot` with Godot 4.4.1. Main scene: `scenes/main_menu.tscn`. `--chapter-one` launches the chapter directly; `--ogre-hearth` retains the first Ogre visit. The reusable Windows build/release workflow runs regressions, actual renders, export and native package startup checks before publication.
