# Faces of Ashfang playtest

CHIEFS OF WAR 0.4.1 — FACES OF ASHFANG PLAYTEST

Extract the entire ZIP first.
ChiefsOfWar.exe: normal campaign (continues your existing save).
Combat-Practice.bat: immediate, UNSAVED combat/gathering practice.
Practice never loads or writes your campaign. Esc > Reset practice restores the yard.

WASD move; hold left mouse to swing; Space dodge; E interact/collect.
C switches owned leather/iron outfits. I inventory, J journal, Esc pause.
Axe contact is at 0.22 seconds, total swing 0.56 seconds plus a brief contact stop.
You can dodge out of an uncommitted strike. Late-dodge attack clicks are buffered.

Practice starts with iron gear. Raiders are east/southeast; the practice dummy is north.
Chop nearby pines and collect their timber with E. Surface ore uses E.
Two ordinary hits can stagger a raider. Move alongside, then F to finish.
Shift+F requests the optional goblin cleave. Normal attacks remain lethal.
Space cancels a finisher BEFORE impact. Esc > Combat & brutality toggles blood/dismemberment.
In the campaign, raiders become available after you earn the iron kit.

QUICK PLAYTEST
1. Chop two trees and collect the logs: does each impact feel connected?
2. Try tap attacks, holding attack, moving between swings, and dodging during windup.
3. Fight a goblin with ordinary attacks; then reset and try an earned finisher.
4. Try the rival Orc, both outfits, and both sides of a finisher.
Please report missed inputs, hits that visually miss, awkward recovery, or unclear enemy warnings.

LIMITS
This is an early playable prototype. Finishers currently support side-on alignment and
horizontal mirroring, not independently drawn animations in every direction. Surface
ore collection is still a simple timed action. Native Windows execution and human
playfeel were not verified in the Linux build environment. The full invasion prologue,
parry/block/heavy attacks and wider sandbox systems remain future work.

Source and exact validation are recorded in BUILD.txt and repository docs/QA.md.
Engine: Godot 4.4.1. Original generated illustration candidates; no Warcraft assets.

## Faces of Ashfang — 0.4.1

Create a character with face, hair, beard, mustache, hair color, skin and cloth choices. The left preview supports front/left/right/back, standing/walking/axe swings and leather/iron. Previewing iron does not grant it. Randomize changes your look, not your name or progress.

Existing character: press Esc → Appearance. Save applies the look and saves the campaign; Cancel restores your previous appearance. Old saves retain their original face until edited. Practice appearance changes never save over a campaign.
