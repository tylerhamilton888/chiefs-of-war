# CHIEFS OF WAR
## Master Game Development Brief — Version 1.0
**Engine:** Godot 4  
**Language:** GDScript  
**Platform:** Windows PC initially  
**Genre:** 2D Top-Down Open-World Action RPG / Sandbox / Tribal Simulation  
**Repository:** New GitHub repository — `chiefs-of-war`  
**Status:** New project — establish repository and first playable prototype

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

# 2. The Core Game Concept

**Chiefs of War** is a hand-drawn, top-down fantasy sandbox combining the satisfying everyday progression of Stardew Valley with the personal adventure, tribal politics, and military ambitions of a barbarian action RPG.

Our design philosophy could be summarized as:

**"Stardew Valley for the Boys."**

That is a description of the intended experience, not a limitation on who might enjoy playing it.

The game should emphasize:

- Physical strength and tactile gameplay.
- Craftsmanship, gathering, hunting, and building.
- Brotherhood, family, community, and belonging.
- Personal achievement, wealth, and prosperity.
- Exploration, dungeons, dangerous monsters, and treasure.
- Warfare, conquest, leadership, and legacy.
- Freedom to live according to the player's own ambitions.

The player is always an individual Orcish man inhabiting a persistent world.

He is not an omnipotent strategy-game cursor.

He personally chops trees, works at crafting stations, fights enemies, hunts monsters, and interacts with other characters.

As he gains wealth, reputation, followers, and territory, he may delegate increasingly large amounts of labor and responsibility.

However, **increasing power should expand the player's options, never eliminate his ability to participate in ordinary activities.**

A mighty chieftain should still be able to spend an afternoon fishing, hunting, chopping wood, or forging weapons.

## Core progression

The game should naturally support an organic journey from:

**Peon → Craftsman / Hunter / Warrior → Respected Clansman → Chieftain → Warlord**

These are examples of possible social development, not mandatory classes or fixed progression stages.

A player may remain a humble hunter for his entire playthrough.

Another may found a tribe and build a prosperous settlement.

Another may conquer neighboring kingdoms and establish a brutal empire.

All should represent legitimate ways to play.

---

# 3. Setting — A Savage and Unstable World

The world of Chiefs of War is an ancient, dangerous fantasy realm dominated by monstrous and barbarian peoples.

The initial setting consists largely of wilderness, with scattered tribal settlements, fortified strongholds, isolated communities, dungeons, and ancient ruins.

The world should feel genuinely untamed.

The dominant peoples include:

- Orcs
- Goblins
- Trolls
- Giants
- Various monstrous humanoids
- Dangerous wildlife and fantasy megafauna

Conventional fantasy civilizations, such as humans, elves, or Dwarfs, are not necessary for the initial setting.

They may eventually appear through exploration of other continents or magical portals to other worlds.

## Environmental instability

The land itself is dangerous.

Earthquakes, storms, landslides, volcanic activity, and other environmental upheavals have prevented the formation of many enormous, stable civilizations.

Protected valleys, defensible mountain strongholds, and regions of relative geographic stability are therefore highly valuable.

Tribes fight over these regions.

Environmental disturbances may:

- Expose buried ruins or dungeons.
- Reveal mineral deposits.
- Block or open travel routes.
- Trigger monster migrations.
- Threaten frontier settlements.
- Change the strategic importance of territory.

Disasters must not arbitrarily erase the player's achievements without reasonable warning or opportunities to respond.

The world is dangerous, but the game must remain enjoyable rather than relentlessly punitive.

---

# 4. Orcish Culture — Strength, Honor, Blood, Tradition

Orcish civilization is deeply patriarchal, martial, traditional, and fiercely hierarchical.

Its four primary virtues are:

**Strength. Honor. Blood. Tradition.**

A fifth practical influence is **Pragmatism**.

Orcs believe that strength establishes worthiness and that weakness is something to be overcome, exploited, or despised.

Their understanding of strength includes physical power, courage, willpower, craftsmanship, perseverance, and the ability to lead.

They are capable of tremendous affection, familial loyalty, friendship, pride, humor, and devotion.

However, these qualities exist within a society considerably harsher than ordinary human civilization.

Their love is demanding.

Their honor is uncompromising.

Their loyalties can be fierce.

Their punishments can be brutal.

An Orcish father may demonstrate affection by training his son to become a great warrior.

An Orcish mother may fiercely protect her family while raising her children to endure hardship.

A chieftain may honor a defeated rival with a warrior's death while simultaneously eliminating the possibility of future revenge.

Another chieftain may recognize a defeated enemy's abilities and offer him a position among his own warriors.

Captives may be ransomed, recruited, enslaved, released, or executed, depending on the customs and decisions of their captors.

Orcs are **not mindless monsters**, but neither are they simply modern humans with green skin.

Different Orcish tribes should interpret their shared cultural values differently.

Some prize conquest above all.

Others revere endurance, craftsmanship, or adherence to sacred oaths.

Their social customs should create meaningful opportunities for the player to establish an identity within this world.

---

# 5. Character Art Direction

This is one of our highest-priority acceptance areas.

**Chiefs of War must have an original, serious, stylized, hand-drawn 2D visual identity.**

Our inspirations include the strong silhouettes, exaggerated anatomy, and expressive characters of classic Warcraft and classic Warhammer Fantasy illustrations.

We are not attempting to reproduce either intellectual property.

Our own identity should combine savage Orcish physicality with Germanic, Celtic, and Norse cultural influences.

## Rendering requirements

The final artwork should use:

- Confident illustrated silhouettes.
- Clear, intentional contours.
- Stylized proportions.
- Purposeful shading.
- Limited, controlled surface texture.
- Bold but harmonious colors.
- Readable shapes at gameplay scale.
- Visually coherent animation frames.

Avoid:

- Photorealism.
- Excessive AI-looking texture.
- Overly soft Disney-like design.
- Anime aesthetics.
- Chibi or baby-like proportions.
- Excessive comic-book inking.
- Arbitrary shiny highlights.
- Inconsistent appearances between animation frames.
- Overcomplicated armor or clothing that obscures the character's silhouette.

**Character design must be strong before detail is added.**

Use reference images provided in this session where accessible. The user's preferred first in-game art reference is a starting point, not blanket approval of every detail.

If an essential reference image is unavailable in Work, request that specific reference rather than inventing its contents.

---

# 6. Male Orcs — "Testosterone Titans"

Male Orcs should have immense, exaggerated, imposing physiques.

They are not simply large green humans.

They are physically formidable fantasy humanoids.

Their baseline anatomy should communicate extraordinary strength.

## Required characteristics

- Enormous shoulders.
- Deep, powerful chests.
- Thick necks and trapezius muscles.
- Massive forearms and upper arms.
- Huge hands.
- Powerful thighs and calves.
- Properly proportioned legs.
- Heavy brows and deep-set eyes.
- Enormous angular jaws.
- Pronounced lower tusks.
- Strong, structured noses rather than flat pig-like snouts.
- Clearly adult faces and anatomy.

**No slender, lithe, dainty, or conventionally pretty male Orc designs.**

Individual builds may differ.

A young hunter might be leaner by Orcish standards, while a veteran warrior could be a mountain of muscle.

An older craftsman might carry a heavy belly and possess enormous working arms.

But all should unmistakably belong to a physically imposing species.

## Hair and facial customization

Orcish male hairstyles should be strongly influenced by traditional and stereotypical Northern European warrior aesthetics.

Include options such as:

- Long loose hair.
- Center-parted shoulder-length hair.
- Tied-back hair.
- Side braids.
- Warrior braids.
- Shaved sides with long hair.
- Heavy natural beards.
- Short beards.
- Braided beards.
- Long mustaches.
- Thick walrus mustaches.
- Braided mustaches.
- Mustache-and-beard combinations.

**Mustaches and beards must be separately customizable.**

Avoid making every Orc resemble a Warcraft-style mohawked warrior.

Additional future customization should include facial structure, tusk variations, skin tone, scars, tattoos, and warpaint.

---

# 7. Female Orcs — Orcish, Feminine, and Traditionally Beautiful

This is a specific and important artistic requirement.

Female Orcs are not initially planned as playable characters, but they are an essential part of Orcish society and must receive the same care in their visual design.

**Female Orcs should be recognizably Orcish while also being traditionally feminine and beautiful in their own way.**

They should not look like ordinary human women painted green.

However, they should not simply be smaller male Orcs or deliberately grotesque caricatures.

## Physical design requirements

Female Orcs should generally possess:

- Distinctly feminine facial proportions.
- Attractive and expressive faces.
- Recognizable Orcish jaws and cheekbones.
- Noticeable but generally more restrained tusks than males.
- Structured noses rather than pig-like snouts.
- Physically capable, healthy-looking bodies.
- Natural feminine curves and proportions.
- Appropriate muscular development for their activities.
- A clear visual relationship to the same Orcish species as the men.

Their appearance should be attractive within the stylized fantasy aesthetic, without making them look frail or inappropriately delicate for the world they inhabit.

Avoid anime-inspired beauty conventions and generic fantasy pinup designs.

## Hair, dress, and personality

Female hairstyles can include:

- Long loose hair.
- Elaborate Northern European-style braids.
- Braided crowns.
- Tied-back hair.
- Practical working hairstyles.
- Decorated ceremonial hairstyles.

Clothing should reflect occupation, wealth, family position, and tribal identity.

Examples include:

- Wool and linen dresses with leather belts.
- Fur-lined cloaks.
- Woven and embroidered garments.
- Metal torcs and family jewelry.
- Protective leather working clothes.
- Status garments decorated with bone, bronze, silver, or iron.

Female Orc NPCs may be mothers, wives, craftswomen, hunters, shamans, healers, merchants, household leaders, or other figures consistent with their particular tribe.

They should have personalities, relationships, opinions, ambitions, and meaningful interactions with the player.

**Their culture is patriarchal, but female Orc characters must not be visually interchangeable or exist merely as scenery.**

For the initial development phase, prioritize one strong representative female NPC design after the playable male model is established.

---

# 8. Animation — Individually Illustrated Frames

This is non-negotiable.

**Use individually drawn 2D animation frames for each supported character action and gameplay direction.**

Do not approximate proper animation by awkwardly bending static illustrations or rotating disconnected body parts.

Do not use skeletal deformation as a substitute for the character's primary hand-drawn animation.

Each animation should depict an anatomically coherent character performing the intended action.

## Initial priority animations

- Idle.
- Walk.
- Run.
- Turn.
- Light melee attack.
- Heavy melee attack.
- Block.
- Parry.
- Dodge.
- Hit reaction.
- Stagger.
- Death.
- Woodcutting.
- Mining.
- Carrying objects.
- Construction and hammering.

Begin with four-direction animation, with the capacity to add more directional detail later.

Every supported animation must contain appropriate full-body frames.

A character chopping a tree should visibly swing an axe into it.

A character carrying timber should visibly support the timber with his arms or shoulder.

A character wielding a sword should actually grip it.

**No floating weapons, disconnected hands, detached heads, arbitrary tool sprites, or changing character proportions.**

Hair and facial hair should also remain visually consistent throughout actions.

Temporary development placeholders must be clearly identified and must never be passed off as approved final artwork.

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

# 11. Orcish Diet and Hunting Economy

**Orcs are carnivorous.**

Traditional Orcish communities consume enormous quantities of meat.

Their food economy is primarily founded on:

- Hunting.
- Fishing.
- Animal husbandry.
- Meat preservation.
- Trade.
- Raiding and tribute.

Crop agriculture may exist primarily for feeding livestock or producing useful non-food materials.

Do not base Orcish subsistence on ordinary human-style vegetable farming.

## Hunting gameplay

The player should be able to:

1. Discover or track animals.
2. Follow signs of their presence.
3. Approach prey.
4. Engage in meaningful combat or hunting.
5. Recover meat and valuable materials.
6. Transport the results home.
7. Process and use the resources.

A large monster should be a major accomplishment.

Successful hunting may support:

- Feeding a tribe.
- Crafting equipment.
- Trade.
- Trophy decoration.
- Prestige and reputation.
- Ceremonial events.
- Development of specialized hunting professions.

Monster hunting should ultimately support both solitary adventure and organized expeditions with companions.

---

# 12. Gathering, Industry, and Construction

Everyday physical activities must feel satisfying.

## Woodcutting

Trees should react visibly to axe impacts.

Successful blows should produce meaningful impact feedback.

Trees should eventually fall, producing timber that the player can collect or transport.

## Mining

Mining should involve meaningful tool strikes and visible resource extraction.

Rocks should not merely disappear instantly when clicked.

## Construction

Buildings should visibly progress through construction stages.

The player should be able to participate personally in construction.

Eventually NPC workers should assist.

## Autonomous labor

NPC workers should perform useful jobs without requiring constant player input.

A player personally chopping trees or mining should generally outperform one ordinary worker.

However, a group of workers should eventually produce more than the player could achieve alone.

The principal advantage of employing workers is that productive activity continues while the player pursues other interests.

We want the player to feel satisfaction from both **doing the work** and **building an enterprise that functions without him**.

---

# 13. The Narrative Opening — The Fall of the Birth Tribe

This is our intended opening structure.

It should establish the player's identity, introduce core mechanics, and provide a meaningful connection to Orcish society.

The player is not a Chosen One.

He is an ordinary young Orc whose life is violently disrupted.

## Act I — The Ancestral Hearth

The player begins in a functioning Orcish village belonging to his birth tribe.

This is his home.

The opening introduces the fundamentals of Orcish life through actual gameplay.

The player learns:

- Gathering.
- Woodcutting.
- Basic crafting.
- Construction.
- Combat.
- Interaction with other Orcs.
- Hunting or resource collection.

He meets a handful of memorable NPCs.

Potential examples include:

- A respected older warrior who teaches combat.
- A childhood friend.
- A skilled craftsman.
- An elder or family member.
- The tribe's chieftain.

The player should begin forming relationships with the inhabitants.

The village should feel alive and familiar.

## Act II — The First Expedition

The player is sent on a relatively modest expedition.

Possible objectives include clearing out troublesome wolves, hunting a dangerous creature, or attacking a small goblin camp that has been harassing the tribe.

He may travel with a few companions.

The expedition introduces combat, exploration, and the possibility of danger outside the village.

The player succeeds and returns home.

## Act III — The Burning Village

Upon returning, the player discovers that his tribe is under attack.

A larger, more powerful Orcish tribe has invaded.

The village is burning.

The player charges into battle.

**This must be a playable combat sequence, not merely a cutscene.**

He fights enemies, attempts to defend his people, and may influence the survival of certain NPCs.

He can demonstrate courage and skill, even though his tribe is severely outmatched.

Eventually, the attacking chieftain notices him.

## Act IV — The Chieftain's Challenge

The enemy chieftain is an enormous, formidable Orcish warrior.

He challenges the player to a formal duel.

The player faces him directly.

The chieftain should use understandable combat mechanics rather than simply becoming invulnerable through arbitrary scripting.

The intended narrative is that the inexperienced player is decisively defeated.

The chieftain chooses to spare him because he recognizes his bravery or potential.

The player should receive appropriate recognition for unusually skillful performance.

Do not pretend the duel is fair while secretly ignoring valid player actions. Handle unexpected outcomes coherently.

## Act V — A New Beginning

The conquering chieftain offers the surviving player a place within his tribe.

Other survivors may also be absorbed into the new community.

Some may have died or escaped.

Others may be taken captive.

The player's initial circumstances may be influenced by his actions and choices.

He might begin as:

- A laborer.
- A hunter.
- An apprentice craftsman.
- A promising warrior.
- A captive expected to prove his worth.

These are starting circumstances, not restrictive classes.

The player may eventually:

- Become loyal to the conquering tribe.
- Rise through its ranks.
- Challenge the chieftain.
- Seek revenge.
- Escape and establish independence.
- Locate survivors of his birth tribe.
- Restore his ancestral clan.
- Establish completely new traditions.

**The game must never force one of these paths as the only legitimate outcome.**

## Narrative implementation priority

This complete opening is a major eventual feature.

However, its production must follow the successful implementation of the underlying movement, combat, gathering, construction, and NPC systems.

Do not spend the initial milestone building elaborate cinematics while fundamental gameplay remains unfinished.

---

# 14. Persistent World and Tribal Simulation

The long-term game should support a living world.

Tribes should have persistent identities, resources, settlements, goals, and relationships.

They may:

- Trade.
- Raid.
- Expand.
- Recruit.
- Wage war.
- Form alliances.
- Experience internal disputes.
- Recover from disasters.
- Establish new settlements.

NPCs should eventually remember meaningful events.

A companion who helped build the player's first hut might later become an important military commander.

A defeated chieftain who is spared might become an ally or future rival.

A conquered settlement may be developed, taxed, occupied, liberated, or destroyed.

The world's simulation should create interesting opportunities without constantly demanding player intervention.

The player can participate in tribal politics or remain largely independent.

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

# 19. Working Philosophy

Chiefs of War is intended to become a game with a distinct personality and genuine commercial potential.

We are not attempting to create the largest possible game.

We are attempting to make a game that delivers a particularly satisfying fantasy:

**An ordinary Orc who can become whatever his strength, choices, and ambitions allow.**

The world should have warmth without being soft.

It should have brutality without becoming monotonously miserable.

It should celebrate personal achievement, craftsmanship, brotherhood, family, conquest, and the struggle to create a lasting legacy.

The player should be able to spend a quiet morning chopping timber, enjoy an afternoon hunting a monstrous beast, and return home to a thriving settlement.

He might later lead an army against his enemies.

He might become a great chieftain.

Or he might simply be an exceptionally prosperous Orc who makes excellent axes.

All are valid.

Our guiding standard is:

**Every action should feel satisfying. Every achievement should matter. Every character should feel like someone. Every victory should change something.**

Begin by creating the new GitHub repository and Godot project, then advance toward the first playable milestone.

Prioritize real, testable progress over elaborate planning documents.

**Build something that is genuinely enjoyable to play.**
