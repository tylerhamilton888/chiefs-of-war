# Milestones and acceptance standards

Status: **design requirements**, not a claim of implemented features.

Source: [original master brief](../MASTER_BRIEF.md), sections 15, 16, 18. The sections below preserve the supplied wording. Historical instructions such as creating a new repository describe the initial assignment; the existing repository must be continued.

Read [current state](../state/current.md) for actual implementation and [decisions](../state/decisions.md) for later clarifications. Do not automatically implement the entire long-term scope.

---

# 15. First Development Milestone — Playable Vertical Slice

**Do not attempt to implement everything above immediately.**

We need a small, polished playable demonstration first.

The first milestone should feature:

### One male Orc player model

Original hand-drawn character artwork.

Consistent four-direction movement.

Correct anatomy and proportions.

### One small wilderness region

A forest clearing, rocky terrain, a small camp, and a few interactable objects.

### One satisfying woodcutting loop

Equip an axe, strike a tree, see appropriate feedback, obtain timber, and transport or collect it.

### One construction project

Gather enough resources to build a small functional structure.

### One useful NPC Peon

The NPC can autonomously gather resources and deposit them into storage.

### One ordinary enemy

A goblin or rival Orc with basic but well-animated combat behavior.

### One huntable creature

A wolf, boar, or small original fantasy predator.

It must have proper movement, attacks, reactions, and rewards.

### Basic atmosphere

Simple day/night lighting and a readable, attractive environment.

### A genuine gameplay loop

The player should be able to spend approximately fifteen to thirty minutes gathering, constructing, fighting, hunting, and improving his immediate circumstances.

**The experience should make him want to keep playing.**

---
# 16. Mandatory Quality Standards

Quality must be verified in the actual Godot game, not inferred from concept illustrations.

Before accepting an implementation, confirm:

- The game launches without critical errors.
- Player movement is responsive.
- Character proportions are consistently adult and imposing.
- Animation frames are properly illustrated.
- Hands and weapons are correctly connected.
- Feet interact naturally with the ground.
- No floating or disconnected equipment.
- No changing appearance between animation frames.
- Combat hitboxes are functional.
- Attacks visually correspond to their actual hit registration.
- Enemies react correctly.
- Gathering provides satisfying feedback.
- Construction visibly progresses.
- NPC workers function correctly.
- Art maintains a coherent visual identity.
- Performance is acceptable during normal gameplay.

Do not treat an animation as finished merely because it technically plays.

Do not treat a combat system as finished merely because enemies can lose health.

The game must **feel** good.

If quality requirements cannot be met within a milestone, reduce the feature's scope rather than hiding the problem beneath temporary effects or misleading presentation.

---
# 18. Development Priorities

Work in the following order:

**Milestone 0 — Foundation**

Create repository, Godot project, project architecture, and initial character art direction.

**Milestone 1 — The Living Orc**

Implement a properly drawn playable male Orc with responsive movement, directional animations, and a simple environment.

**Milestone 2 — Hands of the Peon**

Implement tactile gathering, woodcutting, material handling, and basic construction.

**Milestone 3 — Blood and Iron**

Implement excellent melee combat, one ordinary enemy, and one huntable creature.

**Milestone 4 — The First Hearth**

Implement a small living camp, autonomous Peon labor, basic storage, and visible settlement improvement.

**Milestone 5 — A World Worth Living In**

Expand NPC interactions, hunting, resource processing, and meaningful local progression.

**Milestone 6 — Ashes of the Clan**

Begin implementing the narrative prologue using the established gameplay systems.

Future milestones will expand into tribal politics, conquest, settlement development, dungeons, monster hunts, and larger persistent-world simulation.

Do not begin major future milestones until the necessary foundations are functional and appropriately polished.

---
