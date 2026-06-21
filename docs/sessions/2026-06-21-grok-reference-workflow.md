# Session — Librarian pass: Grok reference-art workflow

Branch: `docs/grok-reference-workflow`.

## What this did (plain language)

Processed the research inbox file about using **Super Grok Heavy** for consistent
concept art. The research **agreed with** our locked decision (Grok = concept
references only → PixelLab for real sprites), so nothing was reopened — it just
added practical know-how that wasn't written down anywhere.

## Changes (proposed → user approved "apply all")

- **New** `docs/art/grok-reference-workflow.md` — the how-to: the **anchor-set**
  practice (reuse a fixed concept image per character because Grok has no "seed"),
  the repeatable 5-step workflow, and two fill-in **look-block templates**
  (character + environment). Reliability markers (`[verified]` / `[training
  knowledge]` / `[FLAG]`) preserved.
- **Cross-links:** one pointer at the top of `imagine-prompts.md` (which is a
  prompt *log*, not a how-to) and one in `ai-production-setup.md`'s workflow rules,
  plus a dated note that **Super Grok Heavy doesn't change the pipeline**.
- **Inbox → done:** moved the verbatim research file to
  `docs/research/done/2026-06-21-grok-heavy-reference-art-workflow.md`, status
  flipped `inbox → integrated`.

## Open items carried forward (in the new doc)

- Verify in-app whether Grok has any saved project/style memory for images (assumed no).
- Heavy's image/video quotas are unofficial — xAI publishes none.

check-brain clean. Docs-only; no code/tests touched.
