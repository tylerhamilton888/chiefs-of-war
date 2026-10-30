# Development mandate and original workflow

Status: **design requirements**, not a claim of implemented features.

Source: [original master brief](../MASTER_BRIEF.md), sections 1, 17. The sections below preserve the supplied wording. Historical instructions such as creating a new repository describe the initial assignment; the existing repository must be continued.

Read [current state](../state/current.md) for actual implementation and [decisions](../state/decisions.md) for later clarifications. Do not automatically implement the entire long-term scope.

---

# 1. Your Role and Immediate Assignment

You are my lead game developer, gameplay programmer, technical artist, and development partner for **Chiefs of War**, an original fantasy sandbox game intended for eventual commercial release.

Your assignment is to:

1. Create a new, preferably private GitHub repository named `chiefs-of-war`.
2. Initialize a new Godot 4 project within that repository.
3. Establish clean project architecture, documentation, and version control.
4. Develop original character and environmental art following the requirements below.
5. Implement a functional and enjoyable initial gameplay loop.
6. Test your work in Godot, fix problems, commit changes, and provide playable Windows builds when possible.

**Do not modify any existing game repositories or projects, including The Stellar Holds.**

Work autonomously within this specification. Make reasonable technical decisions without constantly requesting approval.

Major art-direction changes, substantial additions to scope, or major changes to the game's central vision should be approved before implementation.

Our priority is quality and enjoyable gameplay over accumulating unfinished features.

---
# 17. Repository and Development Workflow

Create a fresh GitHub repository named:

`chiefs-of-war`

Use a private repository initially if the connected GitHub account permits it.

Initialize a Godot 4 project using GDScript.

Maintain a sensible repository structure for:

- Scenes.
- Scripts.
- Resources.
- Character artwork.
- Animations.
- Environment art.
- Audio.
- UI.
- Documentation.
- Tests.

Include:

- A README.
- A Godot-compatible `.gitignore`.
- Setup and running instructions.
- A changelog.
- An asset provenance document.
- A milestone roadmap.
- Documentation explaining architectural decisions where necessary.

All artwork, audio, and code must be suitable for an original commercial game.

Do not import unauthorized Warcraft, Warhammer, or other proprietary assets.

Commit completed, tested work regularly.

Provide GitHub commit references and clear build information.

When possible, create downloadable Windows builds for review.

Do not report untested functionality as complete.

If access to GitHub, Godot, asset tooling, or build infrastructure is unavailable, explain the specific limitation and continue with work that can be performed.

---
