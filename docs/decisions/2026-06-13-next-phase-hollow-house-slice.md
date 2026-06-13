---
name: "Next phase — author the Hollow House slice, then playtest, then art"
date: "2026-06-13"
tags: [decision, roadmap, vertical-slice, playtest]
status: active
related_features: ["[[design/hollow-house-quest]]", "[[mechanics/companion-pointer]]"]
related_bugs: []
supersedes: null
superseded_by: null
---

# Next Phase — Hollow House Slice → Playtest → Art

## Context
The shipped systems (DreadManager, ZoneManager + recontext, Briar companion +
bond/corruption + quirks, Dialogue Manager, Journal, inventory/DiggableSpot,
SaveManager, adaptive audio, mercy/soothe, [[mechanics/accessible-interiors]]) are
built but **unproven as cohering *content***. The [[playtest/2026-06/synthesis]]
4/4 testers said "not enough action or secrets." The R7 research bridge
([[research/done/2026-06-13-companion-pointer-investigation-design]]) names the
two recurring solo-dev failure modes — **feature overloading** and **testing too
late** — and recommends a sequence that de-risks both. AGENTS.md's "content-
complete per zone" rule and the four-pillar feature filter apply.

## Decision
Proceed in strict order:

1. **Author the [[design/hollow-house-quest]] micro-quest** — one Tier-A authored
   interior, 3–6 clues + 1 hidden-truth, ~10–20 min, built on existing systems
   only. First delivery of [[mechanics/companion-pointer]] (Briar-seek) and the
   secrets pillar of the locked next arc. *Gate to proceed:* playable
   start-to-finish on Linux **and** Web, all six systems firing.
2. **Run the queued structured external playtest** ([[plan/playtest-protocol-2026-06]]).
3. **Zone-coherence / art pass** on the *validated* slice (the one "beautiful
   room", recontext visual states, 32×32 interactable glint language).
4. **Defer all new mechanics** until the zone is content-complete and the slice
   tests well.

### Playtest decision thresholds (Phase 2 → action)
- **> ~1 in 3 testers miss Briar's cue** → make it more persistent / multi-channel
  **before** the art pass.
- **Testers brute-force / ignore deduction** → tighten knowledge-gating
  (Obra-Dinn sets-of-three style).
- **Testers report "fetch-quest / checklist" feel** → revise Journal copy
  (memory, not counter) and reduce required clues.

## Alternatives
- **Art / zone-coherence pass first** — *rejected:* polishing content before
  playtest validates the beats risks art-passing content testing tells us to cut
  (vertical-slice doctrine: "cut scope before production; believe the evidence").
- **New mechanic first (e.g. detective vision, combat depth)** — *rejected:*
  fails the four-pillar filter as a *next* step and adds feature-overload risk.
  "Detective vision" is parked in [[ideas]] (borderline — only if playtests show
  players hard-stuck; it risks undercutting dread and duplicating Briar).
- **Playtest before the quest** — *rejected:* nothing self-contained to test yet;
  the slice is what makes a playtest meaningful.

## Consequences
- **+** A single coherent artifact proves the game's identity (dread + bond +
  knowledge discovery) and makes the playtest meaningful; feedback drives where
  polish goes.
- **+** Briar-seek ships with an explicit readability gate instead of assumed-good.
- **−** Briar-seek + the no-missable fallback is net-new behavior work (LimboAI
  `seek_target` branch + fallback affordance) on top of quest authoring.
- **−** Holds the broader art pass until after playtest — intentional.

## Implementation
- **Commits**: _pending — quest + companion-pointer build._
- **Files**: [[design/hollow-house-quest]], [[mechanics/companion-pointer]];
  builds on [[mechanics/accessible-interiors]].
- **Verified**: Phase-1 exit = Web export playthrough with all six systems firing.

## Lookback Questions
- Did the slice actually make the playtest meaningful, or did testers still want
  more before forming an opinion?
- Did Briar-seek read without a HUD marker, or did we have to add one?
- Did knowledge-gating feel like discovery, or did testers want a checklist after all?

## Related
- [[design/hollow-house-quest]] · [[mechanics/companion-pointer]] · [[design/secrets-and-discovery]] · [[mechanics/accessible-interiors]] · [[plan/slice-implementation-roadmap]] · [[plan/playtest-protocol-2026-06]] · [[playtest/2026-06/synthesis]]
