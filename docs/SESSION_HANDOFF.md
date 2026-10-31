# Sundered Frontier — adult feeding and log weapon checkpoint

The user asked for more brutal Ogre eating, including biting limbs off and swallowing goblins whole, and reminded us the carried log should be a weapon. The recovered frontier WIP was synced to feature/hearth-and-hunger at f068423ae41bf36f10c8f2fe03f748c1b8cfa66a; its tree matches local WIP 67e4857 and it is not a release. Further work adds G bite and Shift+G whole-goblin swallow, gated by vulnerability and Ferocity, and makes a carried log a longer-reaching weapon with distinct light/heavy timing and knockback. Swallowed enemies disappear and defeat is saved. The log can still be dropped and delivered. Full adult and restrained feeding art follow the existing gore setting. New AI-generated full-body art is recorded in docs/BRUTALITY_ART_PROMPTS.md.

Current evidence: Godot 4.4.1 import; 28 focused gameplay/save, throw-collision, contract and lift-interruption checks; existing Chapter One 92 checks, Ogre Hearth 40, execution 28 and feel 10 checks passed in isolated data directories. The generated source and prepared atlases were visually inspected as images. A graphical engine render could not yet be captured locally because the available Xvfb lacks xkbcomp; native Windows and human playtesting remain pending. The wider Sundered Frontier systems and additional contract edge cases, visual alignment, release build and publication remain unverified. Windows preview workflow run 41206855186 was started against source c6e6489908f87ccf81bad0cf1df6558042b2458d; inspect its actual status/artifacts before retrying. It does not publish a release. Do not claim a finished new release. Prior released v0.7.0 remains available.

# Sundered Frontier — development checkpoint, not a released milestone

The latest Ogre Experience directive now governs. See `docs/design/ogre-experience.md`. New `scripts/frontier/` and `scenes/ogre_frontier.tscn` integrate physical labor/cargo, buffered axe/maul combat, goblin formations, whole-body throw/feeding/clinch art, ridgeback hunt, useful Flint hauling, portable camp and data-driven regional contracts. Title entry and Chapter One home link are wired; separate `ogre_frontier_v1.json` protects prior progress.

WIP: import and direct/headless startup pass. Full gameplay regression, actual rendered review, balancing, legacy regression and Windows delivery are still pending. Do not claim this checkpoint complete or publish yet. Generated assets/metadata and prompt provenance live in assets/frontier, resources/frontier and docs/FRONTIER_ART_PROMPTS.json. Current runtime `/tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64`. GitHub parent before this WIP is the directive checkpoint on feature/hearth-and-hunger; compare trees and preserve remote ancestry.

The prior verified release remains below for historical evidence.

---

# Hearth and Hunger — verified Chapter One delivery

**v0.7.0 is published and verified.** Source c4f401f5b91b7653a31fbc13ab39391d72ed6de8; tree e8afa9a0e9aed49ed12643ee3ea476d447113173; successful workflow 41160548157. Download https://github.com/tylerhamilton888/chiefs-of-war/releases/download/v0.7.0/HearthAndHunger-Windows-0.7.0.zip (140637873 bytes), SHA256 af71b8d52ddda9a081d63a895f068e1a3399b6532c274a7ebb9f42eba3f63252.

Read `docs/state/current.md`, `docs/design/chapter-one.md`, `docs/engineering/chapter-one.md`, and the user's preserved `docs/source/FIRE_WE_CARRY_DIRECTIVE.txt`. The requested playable chapter and later portrait/brutality revision are integrated in this release. The chapter reaches a personal hearth through actual work, hunting, combat, rescue consequences, a duel with alternate outcomes, the larger host, physical caravan movement and paid contracts.

Latest user feedback: portraits looked too similar; cutscenes felt like an animated Hobbit rather than a game for adults. Three portrait sheets were revised with distinct facial structures, age, scars and expressions. Full-brutality cinematic artwork adds bloody aftermath and Gorund's severed head, with mature proportions/expressions and matching dialogue; the restrained option remains available. Default for new chapters is full. A generated caravan continuity error was corrected before integration. See `docs/CHAPTER_ART_REVISION.json` for prompts and source images.

Validation: twelve regression suites, 92 chapter checks, 17 release-tool tests, inspected actual engine renders, exact-package smoke, native Windows startup/clean exit for all modes, and verified publication/download. Human playfeel and final art acceptance remain pending. Broad weapon/armor wardrobes, tactical party AI and generational family simulation are not delivered; do not claim otherwise.

Current feature branch `feature/hearth-and-hunger`; safety archive `archive/before-fire-we-carry`. Published source is local 18201cad41250e009f073dc45bf4d4b09263f811, remote c4f401f5b91b7653a31fbc13ab39391d72ed6de8; trees match. This handoff is a documentation-only follow-up. Never force reconstructed history onto upstream or mutate the published tag. Do not touch The Stellar Holds or unrelated default-branch work.

Launch `--chapter-one`; independent save `user://fire_we_carry_v1.json`. Earlier Ogre and campaign slots remain intact. Tests use isolated XDG_DATA_HOME. New suite command: `--headless --fixed-fps 60 --script tests/chapter_test.gd -- --test`, no --fresh. Local runtime `/tmp/hearth-runtime/Godot_v4.4.1-stable_linux.x86_64`; graphics helper `/tmp/hearth-runtime/render_chapter.py` uses Xvfb TCP because Unix sockets are unavailable here. `tests/chapter_visual.gd` captures the real game, revised portraits and both gore treatments.

Next action: respond to the user's playtest/art feedback against this actual build. Any new implementation should receive a fresh version and the existing release workflow; source-only delivery is insufficient. If interrupted during future publication, inspect actual GitHub run/release state before retrying. No additional user permission is needed for already requested development and build delivery.
