---
name: Librarian pass — pixel-art pipeline consistency research
date: 2026-06-20
branch: docs/research-pixel-pipeline
tags: [session, research, librarian, art, pipeline]
---

# 2026-06-20 — Research inbox: pixel-art pipeline consistency

## What I did
Processed the new research file through the librarian pass (R7, propose-first).

- **Found it in the wrong copy.** The file was dropped in the stale `game/test`
  checkout, not the canonical repo (the three-copies gotcha again,
  [[canonical-project-copy]] in memory). Brought it into the canonical inbox as
  `docs/research/done/2026-06-20-pixel-art-pipeline-consistency.md` (body verbatim,
  `status: integrated`, + a librarian integration log footer).
- **Assessment**: strong, mostly `[verified 2026-06-20]`. ~70% **confirmatory** of
  positions already locked (PixelLab-for-characters, Rule 5 `low top-down`,
  flat-lit + runtime lighting, layered backdrop/occluder/y-sort — the latter
  *validated* by Godot #78964).
- **Proposed + (after approval) applied — section B additive edits:**
  - `art/prop-coherence.md` Rule 1: runtime WebGL2-safe palette-clamp shader note
    (+ per-zone-48 vs master-palette question); Rule 4: Godot #78964 / #102160
    cull-mode workaround note.
  - `design/ai-production-setup.md`: tiles row → PixelLab `create_topdown_tileset`
    primary, RD palette-strict fallback + **RD-Aseprite-ext-is-static-only**
    caveat; LPC CC-BY-SA/GPL licensing red-line.
  - `decisions/2026-06-10-sprite-tool-pixellab.md`: drift-avoidance workflow
    (clean turnaround reference, "fixed head → always", 45° regen). *Decision not
    reopened — implementation detail.*
  - `docs/ideas.md`: master-palette + style-lock Stage-1, LPC backbone (+licensing
    flag), ComfyUI circular-padding seamless fallback.
- **Flagged tension → new OPEN decision** (user chose "open a decision record"):
  `decisions/2026-06-20-village-backdrop-rerender.md` — re-render the painted
  village map into the 32px register vs keep the painted-backdrop lock. The lock
  was **not** edited (R7); my non-binding rec is Option 3 (defer + pilot one zone
  after Stage 1 tooling). Linked from prop-coherence's verdict block.

## Notes
- Nothing tripped the patent guardrails; every finding passed the four-pillar filter.
- The duplicate still sits in `game/test/docs/research/` — harmless (separate
  checkout); user can delete it.
- check-brain green. No code changed (docs only).
