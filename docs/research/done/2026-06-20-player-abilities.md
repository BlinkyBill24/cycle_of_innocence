---
name: Player character abilities — jump, crouch, punch, attack, dodge and what fits
date: 2026-06-20
source: Grok design discussion
prompt: what character abilities could we add to the game? jump, crouch, punch, attack, dodge ... what makes sense in your opinion?
status: integrated
integrated: 2026-06-20 (branch docs/research-player-abilities) — design directions; see integration log at foot
---

# Player Abilities Research — What Actually Fits Cycle of Innocence

**Filter applied strictly**: Only ideas that serve story, companion arc, horror beat, or replay value. Mapped only to locked systems. Guardrails respected.

## Recommended (pass the filter)

**Crouch / low stance**
Serves horror beat (hiding during dread spikes, avoiding VillageState suspicion) and replay (different paths through zones).
Stands on: ZoneManager (hiding spots + recontext), VillageState suspicion/routines, DreadManager (tension while low), companion bond/corruption (Briar guards or reacts).
Recommendation: Add first. Simple to implement in player controller.

**Age & morality-tied attack variants**
Makes PlayerData progression visible in combat. Innocent path feels desperate or merciful; ruthless path hits harder but affects companions and corruption. Strong story and replay value.
Stands on: PlayerData age/morality/companions, mercy/soothe combat, DreadManager, companion bond.
Recommendation: High priority. Start with two feels + companion reaction differences.

**Contextual companion-assisted movement (Briar boost / dig vault)**
Deepens companion arc. High bond = you can reach story or exploration spots with Briar’s help. Low bond or corruption = assist fails or feels wrong.
Stands on: PlayerData companion bond/corruption + LimboAI, ZoneManager (specific interact points), GameEvents.
Recommendation: Excellent. Replaces generic jump with relationship-driven movement.

**Short dodge / evade**
Adds tension to horror moments and mercy combat (dodge then soothe).
Stands on: Player controller + DreadManager (success reduces dread or triggers assist).
Recommendation: Good follow-up after crouch. Keep it short and grounded.

## Flagged or lower priority

**Free jump** — Conditional only.
Risks turning the game platformer-like and hurts dread pacing + 32×32 readability. Only consider as a rare “desperate leap” during high-dread story beats. Fails general horror filter otherwise.

**Separate punch button** — Merge instead.
Redundant with existing attack. Use the idea as part of age/morality attack variants or as the close-range mercy option.

## Overall clear recommendation

Add in this order:
1. Crouch / low stance (horror + VillageState)
2. Age/morality attack variants (story + replay)
3. Contextual Briar-assisted movement (companion arc)

These three strengthen what already exists without new locked tech or guardrail violations. Dodge can follow soon after. Jump stays very limited or story-gated only.

[End of research — ready for librarian pass]

---

## Librarian integration log (2026-06-20, branch `docs/research-player-abilities`)

Processed per `docs/research/README.md` (propose-first). Design directions (not
decisions), pre-filtered against the four pillars + guardrails; all build on
existing systems (player controller has EXPLORING/ATTACKING states + a partial
crouch anim; `hideout` hiding spots exist). Human ruling: ideas inbox + short
pointer notes.

- **`docs/ideas.md`** — the four abilities in suggested order (crouch/hide ·
  age/morality attack variants · Briar-assisted movement · short dodge) + the two
  "careful" notes (free jump → rare/story-gated only; separate punch → merge into
  attack variants).
- **Pointer notes** added to [[mechanics/combat]] (attack variants / dodge /
  merged punch / limited jump), [[mechanics/vision-and-darkness]] (crouch/hide for
  stealth + suspicion), and [[characters/companions]] (Briar-assisted movement).
- Not promoted to decisions/specs — design work for when a direction is picked up.
