---
name: Session 2026-06-13 — bible concept art + PixelLab character sheets
date: 2026-06-13
tags: [session, cycle-of-innocence, art, pixellab]
branch: feature/bible-concept-art-batch3
commits: []
---

# Session 2026-06-13 — bible concept art + PixelLab character sheets

## Focus
New Grok bible concept art (protagonist stages, full companion sets, new
monsters) → then the PixelLab `create-character-pro` pass to turn the
animatable ones into 8-direction character sheets.

## What I did
*(newest first)*
- **PixelLab character-sheet pass (batch 3)** — ran the proven
  `create-character-pro` (`create_from_concept`) pipeline on the 10 *directional*
  bibles → 8-dir characters (ids in `assets/reference/pixellab_v2/state.json`,
  strips in `*_pro_preview.png`). Templates: `mannequin` (rowan_teen/adult,
  crawler, ghost_girl, evil_warden), `dog` (briar_adult/corrupt), `horse`
  (storm_young/adult/corrupt). The 5 non-directional bibles (Echo egg/hatchling/
  adult/corrupt + grasping-roots) are deferred to the object path — no template
  fits birds/objects. Full prompt + recipe in [[art/imagine-prompts]].
  - **Fixed two pipeline regressions the user caught in the first batch:**
    (1) the dog/horse templates painted a **backdrop box** — `create_pro` had
    lost the `style_description` no-box negative from the 2026-06-11 briar note;
    restored it. (2) corrupted/glow bibles bled a **magenta halo** into the
    generation as speckled bg — added `_strip_magenta_fringe` to concept
    extraction. Also de-translucent-ified the ghost (rendered invisible) and
    gave `preview()`/`_fetch_frame()` a browser UA (Backblaze now 403s UA-less
    fetches). Regenerated the 7 affected (both dogs, 3 horses, crawler, ghost);
    deleted the old artifacted characters from the account. Kept the 3 clean
    ones (rowan_teen, rowan_adult, evil_warden).
  - **Worktree isolation:** your `sync.sh` had moved `game/test` to `main`
    (PRs #87–89), which lacks the batch-3 bibles, so this whole pass ran in a
    throwaway worktree at `game/wt-charsheets` off the branch — `game/test`
    never touched. Worktree removed at end of session.
- **Grok bible concept art (batch 3)** — 15 bibles (2k, magenta key, locked
  format): protagonist late-teen + adult; Briar adult (**Belgian Malinois**) +
  corrupted; Echo egg→hatchling→adult→corrupted; Storm young→adult→corrupted;
  monsters fetus-crawler, grasping-roots, ghost-girl, evil-warden. All horse
  stages reworked once after feedback (colt read / no hippie-unicorn / real
  body-horror). Prompts in [[art/imagine-prompts]].

## Open / next
- **Animate** the 10 stored PixelLab characters → `sheets-pro` → `.tres`
  (define `SHEET_ROWS` per char), same as rowan/briar/twisted. This is the
  "later" step the sheets were built for.
- **5 deferred non-character bibles** (Echo egg/hatchling/adult/corrupt,
  grasping-roots) need the object pipeline (`create_map_object` /
  `animate_object`).
- **Branch reconciliation:** `feature/bible-concept-art-batch3` is behind `main`
  (PRs #87–89). On merge, reconcile the journal — my earlier batch-3 entry sits
  in the shared `2026-06-13.md` (pre-R5-rewrite); fold it into per-session files.

## Related
[[art/imagine-prompts]] · [[characters/companions]] · [[story/bible]]
