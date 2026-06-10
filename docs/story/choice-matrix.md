---
name: Major Choices & Consequences Matrix
tags: [story, mechanics, morality, companions]
status: draft
related: [[story/bible]], [[story/endings]], [[characters/companions]]
---

# Major Choices & Consequences Matrix

This is the living document of the most important player decisions. Each entry includes:
- When it happens (Act / rough location)
- The choice
- Immediate effects
- Long-term effects on morality, companions, revelations, and endings
- Yarn variable changes

**Design Goal**: Every meaningful choice should affect at least two of: companion bond/corruption, available dialogue/revelations, world reactivity, and ending eligibility. No “pure flavor” choices in the critical path.

## Early Game (Act 0 — The Escape & First Night)

### The Food
- **Choice**: Rowan has a tiny amount of scavenged hard bread and dried meat after fleeing. Briar (the pup) is starving and whimpering.
  - **Share with Briar**: +15 bond_briar, small negative to Rowan’s current_hp (hunger). Rowan says something kind.
  - **Keep for yourself**: +5 corruption_briar (Briar learns Rowan is not safe). Rowan stays at full hunger but feels guilty (or doesn’t).
- **Long-term**: This is the very first signal to the system about Rowan’s nature. High bond here makes Briar more likely to stand his ground in later fear events. Low bond makes him more likely to cower or eventually turn.

### The First “Monster” (Optional Mercy)
- **Choice**: Rowan and Briar encounter a shambling, half-formed thing wearing the remnants of a child’s white ritual robe. It is in pain and not immediately aggressive.
  - **Mercy kill it quickly**: Neutral to slightly negative morality. Briar is frightened but the thing doesn’t suffer.
  - **Try to help / talk to it**: High positive morality shift. Possible early revelation (it speaks a name or fragment of the cycle). High risk — it may attack in confusion.
  - **Leave it to suffer**: Negative morality. Briar’s bond drops (he doesn’t understand why Rowan would be cruel).
- **Long-term**: If helped and it survives the encounter in some form, it can become a recurring tragic figure or even a late-game ally/horror depending on later choices.

## Act 1 — The Fringes

### The Desperate Family (or Lone Survivor)
- **Choice**: At the edge of an abandoned farm, Rowan encounters a small family (or single parent + child) who are also hiding from the village. They have almost no food.
  - **Steal from them**: +corruption, possible combat or chase if caught. Short-term resource gain. Later: the family (or rumors of them) can turn the village more hostile or create a tragic echo if they are later taken as “replacements.”
  - **Share what little you have**: +morality, bond boost with any companion present. The family may give a small token or warning that becomes useful later.
  - **Drive them away violently**: Strong negative morality. High chance of Briar or Echo reacting badly. Creates a “Rowan the monster” rumor that follows you.
- **Companion reactivity**: Briar will remember if you were kind to the child. Echo may later bring news of what happened to that family.

### The Young Warden (Thorne or equivalent)
- **Choice**: One of the handlers from the original ritual (the one who hesitated) finds Rowan. He claims he wants to help but is clearly terrified and conflicted.
  - **Trust him / work with him**: Opens a path of partial human alliance. He can provide information about the elders and the next ritual. High risk of betrayal or him being captured and used against Rowan.
  - **Kill him / drive him off**: Prevents future betrayal but loses a source of inside knowledge. Strong negative morality hit. Companions may question Rowan.
  - **Use him then discard him**: Worst of both — information + high corruption + later guilt scenes or companion disapproval.
- **Twist potential**: This character can be the one who reveals early that “the monsters used to be like you.”

## Act 2 — Return & Deeper Truths

### The Captured “Monster” (Previous Child)
- **Choice**: Rowan discovers one of the “monsters” that is still somewhat lucid — a teenage girl who was taken two cycles ago. She is chained and being used by the elders to lure new offerings.
  - **Free her and try to help her escape**: Very high positive morality. She may join as a temporary tragic ally or give Rowan critical knowledge before dying. Strong positive effect on companion bonds (especially if Briar interacts with her).
  - **Mercy kill her**: Sad but “practical.” Moderate negative morality. Briar especially will be upset.
  - **Leave her / use her as distraction**: High corruption. She may curse Rowan with her last breath, causing later nightmare or dread events. Echo may refuse to help for a while.
- **Major revelation trigger**: Talking to her (or examining her remains) can unlock the “monsters are previous children” twist early.

### Companion Crisis Point
- **Choice**: One of the companions (most likely Briar or the future mount) is badly injured or captured during a raid on a ritual site.
  - **Risk everything to save them**: Huge bond boost. Possible permanent injury to the companion or Rowan. Opens “redemption of the corrupted” paths later.
  - **Sacrifice the companion to escape / complete the objective**: Massive corruption on that companion (or death). Other companions’ bonds drop hard. Unlocks unique ruthless abilities but poisons later dialogue.
  - **Abandon them**: The companion may survive in a corrupted state and become a recurring antagonist or tragic encounter.

## Act 3 — The Final Choices (Climax)

These are the big ones that directly gate endings.

### The Vessel Revelation
When Rowan learns they are the “perfect vessel”:
- Accept the power offered by the Hunger (to “save” the village on your terms): Strong negative morality. Massive power spike. High chance of companions being corrupted or lost.
- Reject it and try to destroy the vessel within yourself: High positive. Requires help from bonded companions. Very difficult combat or puzzle sequence.
- Offer one of your companions as a substitute vessel: Extremely high corruption for that companion. Possible unique “I did this for you” scenes. Opens some of the darkest endings.

### The Final Stand — Who Pays?
In the deepest ritual chamber, Rowan must decide how to deal with the Hunger:
- Use Rowan’s own blood + a willing (or forced) companion to try to break the cycle permanently.
- Attempt to transform the pact (using the animals’ unique “marked but not broken” nature).
- Take the elders’ place and become the new warden (with corrupted companions as your “pack”).
- Fail / be claimed (horror ending where the cycle continues with Rowan as the new monster).

Each major companion has specific “death / sacrifice / survival / corruption” flags that are checked here. Some endings are locked if too many companions are dead or fully corrupted.

## Quick Reference Table (Morality & Companion Impact)

| Choice Type          | Kindness Path Effect                  | Ruthless Path Effect                     | Companion Most Affected |
|----------------------|---------------------------------------|------------------------------------------|-------------------------|
| Food / Survival      | +Bond, small personal cost            | +Corruption, short-term gain             | Briar (dog)            |
| Mercy on the Broken  | +Morality, possible ally/knowledge    | +Corruption, rumor spreads               | Echo (bird)            |
| Human Strangers      | Possible fragile alliance             | Resources + hostility                    | All                    |
| Companion in Danger  | Huge +Bond, risk to Rowan             | Power or escape, massive -Bond / death   | The one in danger      |
| Final Vessel Choice  | Hard but “pure” path                  | Power + horror                           | All (especially the offered one) |

**Rule of Thumb**: If a choice would make a real parent or a good friend disappointed in you, it probably moves Rowan toward ruthlessness and companion corruption.

See [[story/endings]] for exactly which combinations of these flags produce which endings.