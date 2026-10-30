# Character art and animation standards

Status: **design requirements**, not a claim of implemented features.

Source: [original master brief](../MASTER_BRIEF.md), sections 5, 6, 7, 8. The sections below preserve the supplied wording. Historical instructions such as creating a new repository describe the initial assignment; the existing repository must be continued.

Read [current state](../state/current.md) for actual implementation and [decisions](../state/decisions.md) for later clarifications. Do not automatically implement the entire long-term scope.

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
