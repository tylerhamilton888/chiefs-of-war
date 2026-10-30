# Combat and enemy identities

Status: **design requirements**, not a claim of implemented features.

Source: [original master brief](../MASTER_BRIEF.md), sections 9, 10. The sections below preserve the supplied wording. Historical instructions such as creating a new repository describe the initial assignment; the existing repository must be continued.

Read [current state](../state/current.md) for actual implementation and [decisions](../state/decisions.md) for later clarifications. Do not automatically implement the entire long-term scope.

---

# 9. Combat — Tight, Responsive, and Satisfying

Combat is one of the primary attractions of Chiefs of War.

It should eventually deliver an excellent top-down action RPG experience.

The player must feel powerful, but enemies must be dangerous.

## Basic controls

- WASD — Movement.
- Mouse — Directional aiming.
- Left Mouse — Attack.
- Right Mouse — Block/parry.
- Spacebar — Dodge.
- E — Interact.

Support remappable controls as the game matures.

## Combat requirements

- Highly responsive input.
- Minimal unwanted input latency.
- Sensible input buffering.
- Clearly readable hitboxes.
- Tight movement control.
- Distinctive attack animations.
- Proper anticipation and recovery frames.
- Impactful hit feedback.
- Appropriate enemy stagger.
- Brief, restrained hit-stop.
- Directional combat awareness.
- Reliable dodging.
- Useful blocking and parrying.
- Recognizable enemy attack telegraphs.
- Satisfying sound effects.
- Proper weapon placement and animation.

Weapons should feel different.

A great axe should communicate weight and devastating impact.

A sword should feel more versatile and responsive.

A spear should reward spacing.

Shields should meaningfully change defensive options.

Combat must remain understandable when multiple enemies are present.

**Do not prioritize dozens of enemies before a duel against one enemy feels genuinely excellent.**

---
# 10. Enemy Factions and Creature Designs

We need an original and visually varied bestiary.

Enemies must differ in physique, behavior, movement, combat style, and the tactical challenges they present.

Do not simply recolor the same basic character and give it different statistics.

## A. Rival Orcs

Rival Orcs share the player's general anatomy and culture but possess different tribal identities.

Possible combatants include:

**Orc Raiders:** Aggressive warriors using axes and shields, often attacking in small groups.

**Orc Berserkers:** Terrifying, exceptionally muscular warriors relying on ferocious attacks, intimidation, and heavy weapons.

**Orc Shieldbearers:** Disciplined defensive fighters who block, advance, and protect their companions.

**Orc Champions:** Experienced duelists with sophisticated attack patterns, parries, counters, and combat techniques.

**Orc Chieftains:** Powerful individual opponents with distinctive equipment, personality, and leadership behavior.

Rival Orcs should support recruitment, diplomacy, surrender, captivity, and political interactions as these systems mature.

## B. Goblins

Goblins should contrast strongly with Orcs.

They are smaller, quicker, cunning, numerous, and opportunistic.

Their designs should emphasize:

- Narrower frames.
- Long arms and fingers.
- Large ears.
- Sharp features.
- Makeshift armor.
- Improvised weapons.
- Scavenged equipment.

Possible enemy types include:

**Goblin Sneaks:** Fast attackers who attempt ambushes.

**Goblin Spearmen:** Maintain distance and fight defensively.

**Goblin Slingers:** Harass the player from range.

**Goblin Trappers:** Use snares, barricades, and environmental hazards.

**Goblin Bosses:** Cunning leaders who depend on subordinates and dirty tactics.

Goblin camps should feel materially different from Orcish settlements.

## C. Trolls

Trolls are dangerous, physically imposing, and difficult to kill.

They should have a distinct anatomy, movement style, and combat personality.

Some may be lumbering giants, while others may be long-limbed, hunched, and unnaturally fast.

Potential qualities:

- Tough hides.
- Regeneration.
- Powerful reach.
- Heavy blunt attacks.
- Brutal grappling or charging attacks.
- Vulnerabilities to specific tactics or weapons.

Possible types include forest trolls, cave trolls, and powerful tribal troll warriors.

A troll should be a frightening encounter, particularly for inexperienced players.

## D. Giants

Giants should feel like genuine environmental threats.

They are enormous compared with Orcs and should possess a correspondingly immense physical presence.

Possible types include:

**Hill Giants:** Primitive territorial creatures wielding uprooted trees and boulders.

**Stone Giants:** Ancient, heavily built creatures resembling living mountain fortresses.

**Mountain Giants:** Rare, colossal adversaries capable of threatening entire settlements.

These should eventually provide memorable boss fights, large-scale hunts, and opportunities for diplomacy or recruitment in exceptional circumstances.

## E. Ordinary Wildlife

The wilderness should include huntable animals such as:

- Wolves.
- Boars.
- Deer and elk.
- Bears.
- Wild cattle or bison.
- Large predatory cats.

Animals should have believable behavior, including flight, aggression, pack hunting, territorial defense, and natural wandering.

Not every encounter must result in combat.

## F. Fantasy Megafauna

Monster hunting should become a significant gameplay activity.

Develop original creatures appropriate to a savage, ancient world.

Initial design concepts include:

**Thunder-Tusk:** An enormous, heavily muscled tusked herbivore capable of devastating charges. Provides huge quantities of meat, valuable hide, and massive ivory-like trophies.

**Dreadwolf:** An exceptionally large, aggressive pack predator with powerful jaws and distinctive stalking behavior.

**Ironback:** A massive armored beast with an exceptionally tough hide, forcing hunters to exploit vulnerable areas.

**Grave Bear:** A monstrous cave-dwelling bear with immense strength, terrifying roars, and extremely dangerous close-range attacks.

**Ridgefang:** A large predatory reptilian or mammalian monster inhabiting rocky wilderness, capable of ambushes and rapid lunges.

These are provisional concepts, not final canonical species.

Each creature should have a strong silhouette, distinctive behavior, meaningful resources, and memorable combat encounters.

Avoid using identical AI behavior for every monster.

---
