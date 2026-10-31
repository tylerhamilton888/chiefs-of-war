# Chapter One implementation

`scenes/fire_we_carry.tscn` uses `scripts/chapter/chapter.gd`, extending the existing Ogre scene's camp, prop, UI and exit helpers. It reuses original terrain, world props, wolf/raider combat, buildings, sounds and menu. The earlier scene and campaigns remain launchable. New content is not a replacement project.

- `state.gd`: validated separate `user://fire_we_carry_v1.json`; atomic temp/rename writes; malformed saves are read-only visits. Stores quest flags, inventory, seven-region position, relationship axes, NPC fates, dialogue cursor, encounter HP, food duration and caravan progress. Never reads/writes legacy campaign or first-Ogre saves.
- `actor.gd`: extends the complete-body Ogre sprite actor. Unique cast atlases, authored axe/maul anticipation/contact/block frames, footing metadata, movement, patrol/follow routes, health, guard, parry and dodge. No skeleton or separate floating weapons.
- `story.gd`: ten-step chapter, contextual conversations, idempotent rewards, optional activities/courtship and ending into repeatable activities.
- `cinematic.gd`: reusable Godot camera tweens and collision-aware whole-body actor staging. Resets camera/staging on skip, scene change and exit. Dialogue state and effects remain in the chapter/story layers.
- `resources/chapter/`: cast records, dialogue/choices, portrait-expression selection and measured atlas regions. Pixel data is not modified by metadata measurement.
- `assets/chapter/`: nine cast atlases, player and Hrothgar combat atlases, beast, three expression-portrait sheets, and full/ restrained six-panel cinematic sheets. Prompts/provenance: `docs/CHAPTER_ART_PROMPTS.json`.

Controls: WASD / E / LMB / RMB / Space / Q / J / I / Esc / F5; B settles a packed household in a safe region. The first Ogre visit retains its original controls and save.

Validation: `tests/chapter_test.gd` is a complete automated gameplay traversal plus alternate-outcome, combat, persistence, idempotence and schema checks. Run with isolated XDG_DATA_HOME and `--headless --fixed-fps 60 --script tests/chapter_test.gd -- --test` (no --fresh). `tests/chapter_visual.gd` captures actual engine scenes/UI. The reusable Windows workflow runs both and adds exact-pack and native Windows chapter startup/clean-exit gates.

Limits: first playable chapter, pending user judgment of proportions, animation and playfeel. NPC routines are lightweight; followers accompany the hunt but do not implement party combat tactics. No full equipment wardrobe or generational household simulator. No claim that generated artwork is human-drawn. Do not remove these distinctions in future handoffs.
