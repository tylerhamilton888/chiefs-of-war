# Hearth and Hunger

Work in the existing Godot 4.4.1 Ogre project. Start with README.md, docs/state/current.md and docs/SESSION_HANDOFF.md. Keep The Fire We Carry as the opening of a single ongoing campaign. The main scene is scenes/main_menu.tscn. Preserve campaign saves, story outcomes and the illustrated three-quarter presentation.

Use docs/design/chapter-one.md and docs/engineering/chapter-one.md for the playable campaign. Current ARPG direction is in docs/state/decisions.md. Reuse individual Ogre actors and their artwork where appropriate. The previous complete Frontier implementation and Orc prototype can be inspected in Git history. A development arena must use disposable state and the campaign combat implementation.

Run relevant checks with Godot 4.4.1 in a disposable XDG_DATA_HOME. See docs/BUILD.md. Verify player-facing changes through their normal entry points. Keep commits recoverable and preserve published release history. When a release is requested, use the Windows workflow and validate the packaged launch before reporting publication.
