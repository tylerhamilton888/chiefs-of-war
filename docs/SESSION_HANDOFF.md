# Session handoff

Read [current state](state/current.md), then follow root [AGENTS.md](../AGENTS.md) to the relevant shard. Do not reconstruct the project from chat memory.

## Active task

Resume the interrupted **Game Context Check** execution milestone and deliver a verified GitHub Windows release. User additionally requested categorized Markdown "sharding" of the initial writeups to avoid repeated reassessment; that documentation structure is now in place.

## Checkpoint and environment

- Canonical old main: `132e4f876b91d88499bab9efd0790c6a86087081` / v0.3.2.
- Initial WIP recovery commit: `1bea3094c6529e4121d5f8201c05064bcf3748b3`, branch `recovery/axe-and-iron-2026-10-30`. Check current head for later commits.
- Complete normal checkout: `/workspace/scratch/dcdfb20f8502/chiefs-of-war-complete`.
- Godot 4.4.1 executable: sibling `runtime/Godot_v4.4.1-stable_linux.x86_64`.
- The earlier `chiefs-of-war` directory contains incomplete original asset recovery; **do not use it as the game source**.
- Public access now works; complete project imports without errors. Previous private binary-download blocker is resolved.

## Next concrete work

Finish execution edge tests and in-engine art/contact review; fix failures, verify complete opener regression, export Windows and publish. Update state/current and this handoff with exact evidence. Initial new files are `scripts/execution_opener.gd`, `scripts/raider.gd`, `assets/executions/*`; scene points at execution extension. No unpublished old-chat test result counts as evidence.

Documentation: all 19 master-brief sections are preserved in eight design shards, linked by docs/README and source-map.json; later execution requirements are explicitly labeled recovered rather than verbatim. Corrected the old roadmap's contradictory female-player milestone. See engineering/recovery for checkpoint/access lessons.
