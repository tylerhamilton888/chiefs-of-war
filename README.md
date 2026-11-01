# Hearth and Hunger

An original illustrated 2D Ogre RPG/sandbox in Godot 4.4.1, continuing Chiefs of War and preserving its history. Our existing bright, chunky, outlined game style stays; concept boards guide cultural and character ideas.

[Download Windows 0.8.9](https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.8.9). Extract All, run **HearthAndHunger.exe**, choose **The Fire We Carry · Ogre Story** for the story, or an Ogre hearth for **Sundered Frontier**.

The chapter goes from family work and the first hunt through the burning of Emberhide, Hrothgar's duel and Stonebelly's traveling host, to a personal wagon. Nine principal characters, seven connected areas, resource/cooking/construction gameplay, real combat and rescue outcomes, illustrated Godot cinematics, negotiated work and optional individual courtships are integrated into the existing game.

WASD move, E interact, LMB axe, RMB directional block/parry, Space dodge, Q eat, J journal/routes, I belongings, F5 save, Esc pause. Pack at your personal wagon, travel, then B settles it in a safe region. The chapter has an independent save; the three frontier hearths have their own saves. Legacy Orc campaigns and assets are archived in source, outside the playable menu.

Sundered Frontier adds heavy attacks (R or Shift+LMB), log weapons, earned throws and clinches (F), bites (G), whole-goblin swallowing (Shift+G), hauling, Flint the pack companion and regional contracts. X puts cargo down; T places a snare. These frontier mechanics are a separate expedition, not all part of the narrative chapter's simpler axe combat. The frontier creator offers a name and four hair/beard palettes of one existing body and hairstyle.

This is a playtest build. Existing poses and gameplay have received a quality pass; human judgment of feel, balance and animation remains essential. Interchangeable armor wardrobes and generational family simulation remain future work. See [release scope](docs/RELEASE_0_8_9.md), [quality evidence](docs/QUALITY_0_8_9.md), [chapter design](docs/design/chapter-one.md), and [implementation](docs/engineering/chapter-one.md).

Open `project.godot` with Godot 4.4.1. Main scene: `scenes/main_menu.tscn`. `--chapter-one` launches the chapter directly; `--ogre-hearth` retains the first Ogre visit. The reusable Windows build/release workflow runs regressions, actual renders, export and native package startup checks before publication.
