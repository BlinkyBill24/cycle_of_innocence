# Session — Food healing (eat to restore health)

Branch: `feat/food-healing` · newest entries first.

## What this adds (plain language)

Rowan can now **eat food to heal**. Open the satchel, tap a food item, and it
restores hearts — then that one item is used up. Each food heals a set amount:

| Food | Heals |
|---|---|
| Forest Berries | 1 heart |
| Dried Meat | 2 hearts |
| Honeycomb | 3 hearts |
| Hearty Meal | 4 hearts |

Sensible rules built in:
- You can never heal **above** the 10-heart cap (extra healing is just lost, not stored).
- Eating at **full health does nothing** and does **not** waste the food.
- You can't eat a food you don't have.
- A small munch sound plays when you eat.

## How it works under the hood (optional detail)

- The eat verb is **generic**: it reads a single `heal_hearts` number off the item.
  A future medicine/bandage item just sets that number — no new code. (1 heart = 2 HP.)
- One source of truth for health: `Inventory.eat` only *asks* to heal (emits
  `player_heal_requested`); the player applies it through the `Health` component,
  which clamps to the max and syncs back to `PlayerData.current_hp`. No double-counting.
- **Persistence fix found along the way:** on load, the player now restores the
  *saved* health (`restore_to(current_hp)`) instead of snapping to full. New games
  still start full; respawn still heals fully.

## Dual-use note (flagged, not guessed)

Berries and Dried Meat can *also* feed Briar (the FEED path). The feed code is
untouched and still works via `Inventory.use`, but the satchel **tap** now always
*eats* these two. Choosing how the player picks eat-vs-feed is an **undesigned
input decision** — flagged in the decision doc, `inventory.md`, and `ideas.md`
rather than guessing a clever auto-dispatch. Nothing was deleted.

## Verification

- New GUT tests: `tests/test_food_healing.gd` (heal-by-value + consume, clamp/no
  overheal **and still consumes on the clamp branch**, full = no-op + no waste,
  zero-food impossible, the heal-request signal contract, save/load preserves
  health + food counts, loaded player restores saved health). Plus two direct
  `restore_to` tests in `tests/test_health.gd` (clamp + invuln-clear).
- **377 tests pass.** `check-brain` clean. **Web/HTML5 export builds.** `eat.wav` imported.
- A 5-dimension adversarial review (heal correctness, persistence, eat-vs-feed,
  scope/guardrails, test completeness) returned **no blockers**; its test-gap notes
  (consume-on-clamp, signal contract, direct `restore_to` test) are now covered.

## Scope kept clean

HUD/hearts display untouched · heal values unchanged from the decision · no new
real-time input · no companion-AI change · no medicine built · no hunger/drain.
Unrelated working-tree drift (`project.godot`, obsidian workspace, stray `.import`
regens) deliberately kept **out** of this commit.
