# Chiefs of War — current handoff

0.3.2 Clan and Hearth follows published 0.3.1 Iron Stride. Release location: https://github.com/tylerhamilton888/chiefs-of-war/releases/tag/v0.3.2

User direction: original hulking male Orcs with enormous shoulders/traps, heavy fists, tusked beastly jaws and short thick legs; feminine but clearly Orc women. Maintain rugged inked/painted 2D art and square-aligned architecture. Always publish Windows builds as real GitHub releases, not only source commits.

Main scene `scenes/opener.tscn` now runs `scripts/polished_opener.gd`, extending the existing opening. `clan_art.gd` defines three new generated atlas layouts. `doorway.gd` adds proximity door leaves to hall/storehouse while preserving the forge's open frontage. New NPC portraits/idle poses, room-specific furnishings, earned trophy, dedicated inventory/journal/pause/storage/fire menus, conversation layout, focus/disabled states and transition fade. Saves remain `ancestral_hearth_v1.json` compatible.

147 existing tests and 23 new rendered polish checks passed. The rendered test must use OpenGL/display because headless layout does not resolve text wrapping accurately. Screenshots reviewed for rooms, characters and menus. Native Windows hardware testing pending. NPC idle poses are two-frame alternates; Bren still shares existing motion/axe cycles. Art and motion are improved candidates, not final hand-drawn animation.

Local checkout: /workspace/scratch/4589cb0adcd5/chiefs-of-war. Its historical git ancestry differs from GitHub; use GitHub main as canonical parent, preserve other remote files via base_tree, and never force-push the local branch. Code, sources, import metadata and tests are committed. Build artifacts belong in release assets, not the source tree.
