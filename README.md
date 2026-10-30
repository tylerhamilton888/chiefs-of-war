# Chiefs of War — The Ancestral Hearth

An original 2D Orc sandbox in Godot 4.4.1. Version 0.3.2 polishes the clan characters, menus, doorways and room furnishings. The opening connects the home village to a first hunting expedition and an earned iron kit. The art uses square-aligned elevated views, inked outlines and painted materials.

## Play

Extract the Windows ZIP, then run `ChiefsOfWar.exe`. No Godot installation is needed. `Fresh-Hearth.bat` starts at character setup; saving afterward replaces the 0.3 campaign slot. The old 0.2 slot is separate.

Name your Orc and choose a complexion and cloth palette. Enter the Ash Hall and speak to Yrsa. Help Bren finish the timber store, practice your axe and dodge, then follow the eastern trail to the overdue hunter. Clear the Greytooth pack, take its leader's pelt, return to Yrsa, and ask Harn to forge your iron kit. The journal updates throughout. You can gather and explore ahead of its suggested order.

Afterward, assign Bren to gather timber into the storehouse, build palisades, change your owned outfit, or experiment with the guarded fire controls. This is a finite region: depleted trees and defeated wolves stay depleted.

## Controls

| Input | Action |
| --- | --- |
| WASD | Move |
| Hold left mouse | Aim and swing the axe; aim anywhere on a nearby tree or creature |
| Space | Dodge; cancels an uncommitted swing |
| E | Talk, harvest, gather loose ore, build a storehouse stage, enter/use a building |
| 1 | Eat a provision to recover health |
| I | Inventory and equipment |
| J | Current objective and controls |
| C | Change owned leather/iron outfit |
| B | Palisade placement; click clear nearby ground, costs 2 timber |
| R | Clear nearby ground under the cursor into an earth firebreak |
| G | Douse nearby fuel for 45 seconds; cancel pending fire drill |
| Esc | Pause, close a dialog, cancel construction or placement |
| F5 | Save |
| F6 | Restore the optional fire checkpoint |

Inside a building, walk north from the threshold and press E to talk/use it. E near the southern threshold leaves. Enemy charges have an amber warning and a recovery window. Sidestep after the warning, then close in and strike. Defeat returns you to the hearth with your belongings intact.

Fire controls are in Pause. Ordinary hearths never start accidental fires. A drill selects a dry standing tree, marks it, warns for eight seconds, and saves a recovery checkpoint first. Dousing, bare earth and the spread toggle provide control. No offline simulation or daily deadlines.

## Save and source

Autosave runs every 30 seconds. Saves also occur at character creation, expedition entry, major rewards, and exit. Campaign file: `%APPDATA%/Godot/app_userdata/Chiefs of War/ancestral_hearth_v1.json`.

Import `project.godot` in Godot 4.4.1 and press F5. Main scene: `scenes/opener.tscn`. Earlier scenes remain regression harnesses. The abandoned 3D trial is excluded.

## Scope and remaining work

- Character setup currently offers a name and three skin/three cloth palettes on one male Orc. Hair, faces, body choices and female player sprites are not implemented.
- Equipment changes between two complete outfits. Individual armor slots remain future work.
- This is the village/first-expedition opening, not the full invasion, chieftain duel and adoption prologue.
- Illustrated assets are AI-generated, not human-drawn. The new hulking leather/iron sets include planted idles, contact/passing walk poses and matched axe strikes. Four keyframes per direction remain visibly stylized; horizontal facings are mirrored, and some pose/armor continuity still needs refinement.
- Wolves use side-facing whole-body poses, mirrored horizontally. They do not yet have four directional animation sets.
- Three enterable buildings share a compact room shell with distinct furnishings and portraits. NPC schedules and relationship systems are future work.
- Building sections have independent health and collision; visual destruction uses column removal, pending authored collapse art and structural support rules.
- Surface changes are firebreaks, not terrain elevation or fluid simulation.

Validation: 147 automated checks pass, including a complete opening through movement, timed attacks, building, hunting, return and forging. Actual Linux OpenGL game views were inspected. The exported Windows pack launches under the Linux engine; native Windows execution and human playtesting were not performed here. These checks establish functionality, not a verdict on fun.

See `docs/QA.md`, `docs/ASSET_PROVENANCE.md`, `docs/ART_PROMPTS.md`, and `docs/ROADMAP.md`.
