---
name: Food heal values (player self-healing)
date: 2026-06-21
status: decided
deciders: Steffen
source: "[[research/done/food-heal-values]] (design conversation + vault cross-check)"
tags: [decision, inventory, combat, healing, survival-horror]
---

# Food Heal Values (Player Self-Healing)

Authoritative record of Steffen's decision (2026-06-21): eating food restores a portion
of Rowan's hearts, scaled per food. **Starting points for playtest tuning, not final
balance** — humans tune balance per project rules; agents don't.

## Rowan's pool
**10 hearts** maximum `[verified 2026-06-21 — from code]`. HUD convention: **1 heart = 2 HP**
(`hud.gd` `HP_PER_HEART`), so 10 hearts = 20 HP. Heal amounts below are in **whole hearts**.

## Values (the HEAL path)
Food — player self-heal:
| Food | Hearts | Rarity |
|---|---|---|
| Wild berries | **1** | common (foraged trickle) |
| Dried meat | **2** | uncommon (preserved) |
| Special treat (honeycomb or similar) | **3** | rare |
| Hearty meal / found feast | **4** | very rare (best food) |

Medicine — kept ABOVE food for coherence (a separate future item set on the **same HEAL
path**, not built yet):
| Item | Hearts |
|---|---|
| Bandage / poultice | **5** |
| Rare restorative (story item) | **full heal (10)** |

## `[FLAG]` Why these are provisional
**Final feel depends on enemy damage-per-hit, which is currently unknown.** You cannot
finalize heal values without knowing how hard a hit lands (a 1-heart berry means something
very different at 1-heart hits vs 4-heart hits). Treat the table as a starting point and
re-tune once combat damage is set — human-tuned per project rules.

## Design reasoning
- One clean step per tier (1/2/3/4 food), medicine above (5/full).
- Common food barely dents the bar (10% per berry) → foraging stays meaningful; rare food
  is a real heal you ration; nothing edible beats medicine.
- **Whole hearts only** — at a 10-heart pool, 1 heart = 10% is fine granularity;
  half-hearts add fiddliness without benefit.
- Healing is a **rationed resource, not a spam button** — serves the survival-horror beat.
  Food scarcity is already supported (no early shops, foraging-only, 8–12 slot bag).

## Implementation status (corrected — the source note was wrong here)
- **HEAL is NOT yet in the code.** `ItemDef.UseKind` is `NONE / FEED_COMPANION / EQUIP /
  THROW` — there is **no HEAL value** (the source note's "the use_kind enum already reserves
  HEAL" is incorrect). Implementing the HEAL path is a future task: add `HEAL` to the enum
  **or** a `heal_hearts` field on `ItemDef`, then wire `Inventory.use` → `Health.heal(hearts × 2)`.
- `Health.heal(amount)` (HP, clamped to `max_hp`) **does** exist — the future HEAL verb calls it.
- Today `berries` / `dried_meat` are used as **FEED_COMPANION** (→ Briar bond). This decision
  **extends** the same items to player HEAL — they become dual-use.

## Resolved — dual-use dispatch: **ask at the point of use** (2026-06-21)
The same `berries` / `dried_meat` serve BOTH companion FEED (Briar bond) AND player HEAL
(Rowan hearts). **Decision: tapping a dual-use food opens a small `Eat` / `Give to <companion>`
choice** so the player owns the "share or keep" tension at the moment of use. Single-purpose
items act immediately (pure food is eaten, companion-only care is given). No hidden modifier or
proximity auto-dispatch — the choice is explicit and predictable. Implemented in
`scripts/ui/inventory_panel.gd` (`is_dual_use` / `food_affordance` + the choice sub-modal;
tests in `tests/test_eat_vs_feed.gd`). The dual use remains the deliberate resource-tension hook.

## Out of scope here (future tasks → [[ideas]])
The medicine item set (bandage 5, restorative full); world-placing the berries; a feed item
for Echo (all feed items currently target Briar). *(Done since: the HEAL verb, the food `.tres`
values, and the eat-vs-feed dispatch UI are all built.)*
*(The future Claude Code "food goal" carries these exact values, replacing its earlier
placeholders — so the build phase uses this table directly.)*
