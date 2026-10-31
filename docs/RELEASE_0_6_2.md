# Hearth and Hunger 0.6.2 — First Ogre Hearth

The existing Chiefs of War project begins its Ogre / traveling-household pivot. The established bright, inked, chunky illustrated style stays. The new concept boards supply anatomy and cultural ideas, not a replacement rendering style.

Extract the Windows ZIP and launch **HearthAndHunger.exe**. Choose **Enter the wandering hearth**. WASD moves; E collects fallen timber, takes provisions and cooks at the hearth. F5 saves; Esc returns to the title or quits. Progress resumes on the next visit. The camp contains a large covered wagon, canvas shelter, cooking station and supplies.

This is the first playable pivot, not the complete sandbox. The new Ogre uses a distinct strongman design and full-body directional idle/walk poses. These are generated illustration candidates; gait, proportions and playfeel need user review. Ogre combat, modular equipment, mobile camp deployment, NPC family simulation and beasts are not implemented in this new scene. The cooking interaction currently adds stored meals; it does not include an eating animation, hunger drain or food buffs.

Earlier Orc characters, three campaign slots, appearance editing, hunting/combat and practice remain accessible under Earlier campaigns. Their saves remain in the same OS user-data folder. Ogre progress is in a separate wandering_hearth_v1.json file. The complete pre-pivot source is preserved on archive/chiefs-before-hearth-and-hunger; repository history remains intact.

The package has one obvious root executable, START HERE.txt, optional old combat practice in Extras, and build/source information in Support. Matching checksums accompany the download. The release pipeline verifies Godot tests, rendering, export, native Windows startup and downloaded package integrity before publication.

Final validation correction: saves now accept the complete physically reachable map area, including the northern and southern boundaries. Automated movement-to-edge/save/reload regressions pass.

The new scene stops and releases audio playback before returning to the title or exiting, preserving the established clean shutdown behavior.
