---
name: Librarian pass — equipment (Ausrüstung) system research
date: 2026-06-20
branch: docs/research-equipment-system
tags: [session, research, librarian, equipment, items, merchant]
---

# 2026-06-20 — Research inbox: equipment (Ausrüstung) system

## What I did
Processed a buildable equipment-system design (gear in hand-placed tiers + a
diegetic reactive merchant). Found the three "core choices" the prompt called
locked (medium stats · tiered hand-placed replacements · diegetic reactive
merchant) were **not recorded anywhere**, and there's no equipment field on
ItemDef and no merchant system — so this is a net-new feature. Human ruling:
capture as a **living mechanics design doc**.

- Filed verbatim → `docs/research/done/2026-06-20-ausruestung-equipment-system-research.md`
  (`status: integrated` + integration log).
- **`docs/mechanics/equipment.md`** (new) — the distilled spec: the three core
  choices, "show strength without numbers" (sprite / recontext / Journal /
  companions / audio), mercy/soothe-fitting gear, the diegetic reactive merchant
  (+ failure cautions), the tiny touch-first UI, the data additions (ItemDef
  fields, PlayerData equipped map, merchant stock tables, **save by ID**), the
  5-phase build order, and the filter/guardrail check.
- **`docs/ideas.md`** — queued the build (post-slice, content-gated) + pointer.
- **Pointer notes** in [[mechanics/inventory]] (equipment layer) and
  [[mechanics/combat]] (gear feeds mercy/soothe, not damage).

## Notes
- Design-only — nothing built. Sequenced after vision-cone + Hollow House authoring.
- Respects the strict-diegetic style (no numeric HUD) and guardrails; the research
  itself flagged pure-damage gear + gamey shops to avoid.
- check-brain green; docs only; zero locked decisions reopened (the inventory
  decision is extended, not changed).
