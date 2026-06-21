---
name: food-heal-values
date: 2026-06-21
source: design conversation (Steffen) + vault snapshot cross-check
prompt: "Propose per-food heart-restore values for player self-healing, for a confirmed 10-heart Rowan."
status: integrated
---

> **Librarian pass — integrated 2026-06-21** (branch `docs/food-heal-values`). Steffen's own
> decision → canon. Recorded: [[decisions/2026-06-21-food-heal-values]]. Applied to
> [[mechanics/inventory]] (food is now dual-use FEED+HEAL; added the heart table). Build
> consequences captured in [[ideas]] (implement HEAL, set values, dual-use dispatch FLAG,
> medicine set, world-place berries). **Correction:** the note's "the use_kind enum already
> reserves HEAL" is WRONG — `UseKind` is only NONE/FEED_COMPANION/EQUIP/THROW; the decision
> record + ideas reflect the corrected status (HEAL is unbuilt). No code; balance stays human-tuned.

# Food Heal Values (Player Self-Healing)

Decision: eating food restores a portion of Rowan's hearts, scaled per food.
Rowan's maximum is **10 hearts** [verified 2026-06-21 — Steffen, from code].
The values below are a proposed starting point for playtest tuning, not final balance.

## Values

Food (player self-heal):
- Wild berries — **1 heart** (common; foraged trickle)
- Dried meat — **2 hearts** (uncommon; preserved)
- Special treat (honeycomb or similar) — **3 hearts** (rare)
- Hearty meal / found feast — **4 hearts** (very rare; best food)

Medicine, kept above food for coherence (separate future item set, same HEAL path):
- Bandage / poultice — **5 hearts**
- Rare restorative (story item) — **full heal (10 hearts)**

## Design reasoning
- One clean step per tier (1/2/3/4 food), medicine above (5/full).
- Common food barely dents the bar (10% per berry) → foraging stays meaningful;
  rare food is a real heal you ration; nothing edible beats medicine.
- Whole hearts only — at a 10-heart pool, 1 heart = 10% is fine granularity;
  half-hearts add fiddliness without benefit.
- Healing is a rationed resource, not a spam button — serves the survival-horror beat.

## Grounding (from vault snapshots) [verified 2026-06-21]
- The inventory doc frames food (berries, dried meat) primarily as *companion care*
  (FEED → bond); this decision extends those same items to *player* healing.
- ~~The `use_kind` enum already reserves HEAL (not yet built);~~ **[CORRECTED on integration:
  `UseKind` is only NONE/FEED_COMPANION/EQUIP/THROW — HEAL is NOT in the enum; adding it is
  part of the build. See the banner + [[decisions/2026-06-21-food-heal-values]].]** the first
  HEAL consumer was planned to be a bandage. These food values + the food goal prompt exercise HEAL.
- The `berries` item + `ForageSpot` already exist; berries are not yet world-placed.
- Food scarcity is already supported (no early shops, foraging-only, 8–12 slot bag) —
  satisfies the four-pillar horror-beat filter (healing matters because it's scarce).

## Flags
- [FLAG] Final feel depends on enemy damage-per-hit (currently unknown). These values
  are a starting point; tune by playtest (human-tuned per project rules — agents
  don't balance).
- [FLAG] Dual-use: `berries` / `dried_meat` serve both companion FEED and player
  HEAL. How the game chooses "eat (heal Rowan)" vs "feed (Briar)" is an unresolved
  dispatch/UI decision. The same berry self-heals OR feeds the companion — a
  deliberate resource-tension hook (serves companion arc + horror) — but the
  input/UI mechanism is not yet designed.

## Notes for librarian
- Reconcile with `mechanics/inventory.md` (food currently framed as companion-care only).
- The food goal prompt (Claude Code) now carries these exact values, replacing its
  earlier placeholders.
- Medicine items (bandage 5, restorative full) are reserved for a later task on the
  same HEAL path — not built yet.
