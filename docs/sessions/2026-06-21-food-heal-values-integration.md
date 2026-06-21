---
name: Librarian pass — food heal values
date: 2026-06-21
branch: docs/food-heal-values
tags: [session, research, librarian, healing, inventory, decision, workflow]
---

# 2026-06-21 — Integrate food heal values (decision)

Processed `research/food-heal-values.md` — Steffen's own decision → canon.

## Recorded
- Decision: `docs/decisions/2026-06-21-food-heal-values.md` — food self-heal (berries 1,
  dried meat 2, treat 3, feast 4 hearts), medicine (bandage 5, restorative full), Rowan =
  10 hearts (1 = 2 HP), whole-hearts-only, rationed-not-spam, human-tuned.
- `mechanics/inventory.md`: food is dual-use (FEED Briar + HEAL Rowan) + the heart table.
- `ideas.md`: future code tasks (implement HEAL verb, set values, dual-use dispatch FLAG,
  medicine set, world-place berries).

## Correction carried through
The source note claimed "the use_kind enum already reserves HEAL." It does NOT
(`UseKind` = NONE/FEED_COMPANION/EQUIP/THROW). Corrected in the decision record, inventory,
ideas, the source-note body (strikethrough + note), AND the stale 2026-06-13 inventory
decision line. `Health.heal()` exists; 10-heart/2-HP grounding verified in code.

## Adversarial verification (ultracode)
Ran a 5-dimension verification workflow (values / code-accuracy / cross-links / scope /
completeness) BEFORE merge. It caught real blockers I'd missed:
1. `ideas.md:87` still re-asserted the retracted "reserves HEAL" claim → fixed.
2. The source note BODY still stated it (contradicting its own banner) → corrected inline.
3. The source's SECOND flag — "final feel depends on enemy damage-per-hit (unknown)" — was
   dropped → added to the decision record + inventory note.
Plus the 2026-06-13 stale claim + the food-goal-prompt capture. Scope dimension passed
(docs-only, no balance in code, dual-use dispatch left FLAGGED). `_compiled/` snapshot left
as auto-generated.

## Verified
check-brain green; docs-only (no code/scene/resource touched). Inbox clear.
