# Chiefs of War — The First Hearth

Original top-down Orc sandbox in Godot 4.4.1. **0.2.0 is a small playable core and art trial, not a finished game or a completed narrative vertical slice.**

## Play

Extract the Windows ZIP and run `ChiefsOfWar.exe`. No Godot installation needed. Windows export is unsigned; engine testing and rendering were performed on Linux, not native Windows.

Start in Ashfang Camp. Cut the western pines, collect six timber, and raise the storehouse south of the hearth in three two-timber stages. Enter the forge, make an iron kit from four ore and two timber, then confront three rival Orcs on the southeastern ridge. The journal guides this loop without locking actions behind quest order. Afterward, build palisades or assign Bren to gather timber into the storehouse.

The hall restores health. Enemies drop ore and rations. Defeat returns you to camp without losing gear or materials. This is a finite authored region; trees and enemies do not respawn automatically.

## Controls

| Input | Action |
| --- | --- |
| WASD | Move |
| Left mouse | Aim and make one committed axe strike |
| Space | Dodge; brief invulnerability and cooldown |
| E | Collect logs, build storehouse stages, enter/use buildings, talk to Bren |
| C | Switch owned leather/iron outfit |
| 1 | Eat a ration |
| B | Toggle palisade placement; click clear nearby ground, costs 2 timber |
| R | Clear nearby ground under cursor into an earth firebreak |
| G | Douse nearby fuel; cancel pending fire drill |
| J | Journal and controls |
| Esc | Pause menu / close dialog / cancel placement |
| F5 | Save |
| F6 | Restore optional fire-drill checkpoint |

Inside buildings, walk away from the south threshold and press E to use the facilities; E near that threshold leaves. Fire spread can be disabled in the pause menu. The optional drill warns for eight seconds and creates a separate checkpoint. Hearths never cause accidental fires. No offline simulation.

## Save and source

Autosaves every 30 seconds and on exit. New save: `%APPDATA%/Godot/app_userdata/Chiefs of War/first_hearth_v1.json`. This does not overwrite the older world-foundation save. For a fresh playtest, use the included `Fresh-Camp.bat` (it ignores the prior save on launch; subsequent saving replaces the campaign slot).

Import `project.godot` in Godot 4.4.1 and press F5. `scenes/camp.tscn` is the current game; `scenes/hearth.tscn` preserves the earlier systems harness. The abandoned 3D trial is excluded.

## Current limits

- Generated illustrated art, not human-authored hand drawings. Character continuity, passing poses, armor details and contact alignment are still candidates. Clipped recovery frames are excluded from playback.
- Whole-outfit equipment sets; individual armor slots and customization remain future work.
- Interiors share a small layout. NPCs have portrait conversations, not schedules or relationship simulation.
- Three rival Orcs use the same base character artwork. Hunting fauna, enemy variety, and the birth-tribe invasion are not implemented.
- Building sections have independent damage/collision, with temporary sliced exterior loss rather than finished collapse art; no structural support graph.
- Bren uses local movement, not general navigation around arbitrary user-built mazes.
- Mining uses the current axe action; a dedicated pick/tool set is pending.
- Surface edits are firebreaks, not terrain elevation or fluid simulation.

See `docs/QA.md`, `docs/ASSET_PROVENANCE.md`, and `docs/ROADMAP.md`.
