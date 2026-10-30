# Session recovery and checkpoint protocol

## Resume without reinventing

Read root AGENTS → state/current → SESSION_HANDOFF → relevant design/engineering shard. Inspect actual branch state and uncommitted files. The handoff's next action should be concrete, not a retrospective essay. Read the full master brief only for source auditing or a genuine unresolved requirement.

## Durable checkpoints

Commit each coherent tested increment. Before expensive generation, tooling risk or a session handoff, save unfinished work explicitly to a WIP branch if needed. Sync it remotely and write: exact branch/base/commit, modified files, tests run/results, unverified work, next action and blocker. Keep playable releases separate from WIP checkpoints. Update existing state/handoff records rather than appending conflicting status in many documents.

Do not let many new images, scripts and test results exist only in the conversation's scratch directory. Generated image preservation does not preserve uncommitted game code.

## Known October 30 access failure

Private-repository terminal Git was unauthenticated. GitHub text reads worked; binary `fetch_file` above 1 MiB returned empty contents, binary `fetch_blob` attempted UTF-8 decoding, and browser downloads timed out. The user then made the repository public. A complete normal Git clone succeeded and all original artwork imported. **That blocker is resolved; do not repeat the old recovery investigation.**

Canonical baseline was main `132e4f876b91d88499bab9efd0790c6a86087081` (0.3.2). WIP execution reconstruction was saved at `1bea3094c6529e4121d5f8201c05064bcf3748b3` on `recovery/axe-and-iron-2026-10-30`. Old chat claims about an unpublished 0.4.0 passing tests were not independently recoverable and are not fresh evidence.

Prefer a normal checkout when available. If only GitHub writes work, create blobs/tree/commit from the actual upstream base tree and parent, preserving unrelated paths and expected branch head. Never force-push reconstructed local root history or upload zero-byte failed asset downloads.

Do not make a repository public or change account permissions yourself without explicit authorization. Never ask the user to paste tokens into chat. Diagnose actual access before suggesting setting changes.
