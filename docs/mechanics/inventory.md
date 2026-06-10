---
name: Inventory & Items
tags: [mechanics, inventory, design]
status: draft
related: [[design/game-features]], [[mechanics/progression]], [[story/bible]]
---

# Inventory & Items

## Design Goals
- **Light and purposeful**, in the spirit of classic Zelda and Mana games.
- Items should feel meaningful and tied to story, companions, or exploration — not busywork.
- Support the themes: care for companions, uncovering the conspiracy, surviving with limited resources.
- Keep art and UI scope manageable (small pixel icons, limited slots).

**No** heavy RPG inventory, crafting systems, or economy in v1.

## Inventory Structure

**Slot Limit**: 8–12 slots (small grid or list). Forces prioritization.

**Categories**:

1. **Key Items**
   - Story-critical objects (ritual fragments, old journals, keys to hidden areas).
   - Often unique and cannot be discarded.
   - Many trigger revelations or new dialogue when examined or shown to the right person/companion.

2. **Companion Care Items**
   - Food (foraged berries, dried meat, special treats).
   - Soothing items (herbs, tokens, a brush).
   - These are the most common "consumables" and directly feed the bond/corruption systems.
   - Some are companion-specific (a high-pitched whistle only Echo responds to well).

3. **Combat / Utility Consumables**
   - Simple healing (bandages, poultices).
   - Temporary dread reducers (a charm, a lantern oil that burns "clean").
   - Throwable distractions or weak bombs (very limited).

4. **Memory / Lore Items**
   - Collectible fragments (child drawings, broken ritual tools, letters).
   - These don't take normal inventory space — they go into the Journal.
   - Collecting them feeds the revelation system and can unlock new Yarn branches or companion conversations.

## Interaction with Other Systems

- **Companions**: Many items exist primarily to care for them. Using the right item at the right time (after a bad scare, when corruption is rising) can have big bond payoffs.
- **Morality**: Some items have different descriptions or secondary effects based on current morality tier (a "kind" herb soothes; the same plant prepared ruthlessly can be used as a toxin or power enhancer).
- **Puzzles & Exploration**: Key items and companion-specific tools gate or solve environmental challenges.
- **Narrative**: Showing certain items to NPCs or companions can dramatically change conversations (proof of the cycle, evidence of what happened to a previous offering).

## UI

- Simple, clean retro-modern grid or list.
- Icons are small pixel art.
- Hover/inspect shows name + short description (flavored by current morality and known revelations when relevant).
- Companion care items can be used directly from the inventory or via contextual prompts when near a companion.

**Journal** (separate from main inventory):
- Acts as both quest log and conspiracy bible.
- Organized by revelations, companion notes, and "things Rowan has seen."
- This is where most lore items live.

## Acquisition & Economy

- **Foraging / Exploration**: Primary source of food and simple materials. Encourages careful exploration of zones.
- **Story / Character Moments**: Many important items are given, found in specific story locations, or received as thanks from rare kind NPCs.
- **No shops** in early game. Later, very limited and morally charged (buying from someone who may be complicit in the cycle).
- No selling or complex crafting. If an item is no longer needed, it can usually be discarded or is automatically cleaned up after its story use.

## Scope & Future

**v1**:
- Small, curated list of items.
- Focus on companion care and story keys.
- UI that feels good on keyboard, gamepad, and touch.

**Potential Expansions** (post-v1 or DLC):
- Slightly deeper care system for companions (different foods have different effects).
- A few more utility items for advanced puzzles.
- Optional "memory" collectibles that are purely for completionists and deeper lore.

**Hard Cuts for v1**:
- Any form of heavy crafting or resource management.
- Weapon or armor upgrades (progression comes from age, morality, and companions instead).
- Large inventories or "bag of holding" solutions.

## Technical Notes

- Simple array or dictionary in PlayerData (or a dedicated Inventory resource).
- Items are data-driven (small resources or a JSON/table) so they can carry effects, descriptions, and Yarn commands.
- Use signals when items are gained/used/lost so the journal, companions, and dialogue systems can react.
- Icon loading via the existing pixel art pipeline.

See [[design/game-features]] for how inventory fits into the larger feature set and [[characters/companions]] for specific care item ideas tied to each animal. The inventory should never feel like the point of the game — it should feel like a quiet tool that helps you protect the only family you have left.