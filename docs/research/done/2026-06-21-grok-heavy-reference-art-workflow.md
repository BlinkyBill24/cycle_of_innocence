---
name: Grok Imagine (Super Grok Heavy) — consistent reference-art workflow
date: 2026-06-21
source: Claude (Opus 4.8) chat + web research (xAI docs, Scenario/PicLumen/GenAIntel/community guides, June 2026)
prompt: How to use new Super Grok Heavy access to make consistent pixel art for Cycle of Innocence — what project / instructions / reference images / source files are needed
status: integrated
integrated: 2026-06-21 → [[art/grok-reference-workflow]] (+ cross-links in [[design/ai-production-setup]], [[art/imagine-prompts]]); reaffirms [[decisions/2026-06-10-sprite-tool-pixellab]]
---

# Summary

Super Grok Heavy improves the **concept / reference** stage of the art pipeline. It is **not** a sprite engine, and nothing about the Heavy tier changes that. PixelLab stays canonical for actual sprites. This reaffirms the existing locked decision (Grok Imagine = concept reference only → PixelLab).

The key practical point: **consistency comes from reference images plus the vault, not from any Grok setting.** Grok has no way to reproduce the same image twice on its own, so a fixed set of "anchor" images is what holds a character or place on-model across many drawings.

---

# What Grok Imagine can and can't do (as of June 2026)

- Paints high-resolution concept images (up to ~2K); "game concept art" is an officially listed use case. `[verified 2026-06-21]`
- Cannot draw on a true 32×32 grid, cannot output transparent (see-through) backgrounds, cannot produce matching walk-frames per facing direction, cannot lock a palette across many assets. `[training knowledge — these are format limits; the painting-vs-sprite distinction]`
- **No "seed."** A seed is the setting that lets you reproduce an identical image. Without it, the same prompt gives a different picture every run, so consistency must come from reference images, not from re-running a prompt. `[verified 2026-06-21]`
- Accepts **up to 3 reference images per request** (think of them as: subject source, style source, environment source). `[verified 2026-06-21]`
- Documented consistency technique: reuse the **same anchor image** every time, and instruct it to *keep [element] identical* to stop drift. `[verified 2026-06-21]`

---

# Where Grok sits in the pipeline (unchanged — now confirmed)

```
Blender greybox  →  Grok concept paint (image-to-image, anchored)  →  PixelLab (canonical sprite)
   (perspective         (the look / mood / character design)            (grid, transparency,
    + layout)                                                            directions, palette)
```

Grok feeds the **front** of the pipeline. PixelLab is the **end**. Grok output is never shipped as a sprite. `[training knowledge / reaffirms locked decision]`

---

# What you need

- **An anchor set.** One approved concept image per recurring character (Rowan, Briar, Echo, Storm) plus one overall style/palette image. These are reused as references every time — they are the consistency lock.
- **One reusable "look block"** (templates below), stored in the vault. It describes *vibe* — palette, mood, framing — not pixel specs. Grok cannot honour "32×32"; that is PixelLab's job.
- **Greybox renders as references.** Feeding a Blender greybox in as a composition reference forces Grok to respect the ~20° low top-down angle and the layout before it paints. This is the cleanest defence against perspective drift, and it dovetails with the existing ComfyUI Depth/MLSD setup. `[training knowledge]`
- **No Grok-side "project."** Grok's image tool works prompt-by-prompt; no saved project or instructions memory for image generation could be found. The project bible stays in the vault and the look block is pasted each time. `[FLAG — inferred from absence of a documented feature as of 2026-06-21; verify in-app before relying on it]`

---

# Workflow (repeatable)

1. Pick or generate **one clean concept image per recurring character** — that is its anchor.
2. Paste the look block.
3. Build each prompt as: **look block + character anchor + style anchor (+ greybox if it's a scene) + "keep [character] identical."**
4. Curate the best result. **That image is the reference handed to PixelLab.** Grok's job ends there.
5. Never ship Grok output as a sprite — it breaks the grid, transparency, directions, and palette.

---

# Look-block templates (fill in)

> Built for **both characters and environments** — delete whichever half you don't need.
> Replace every `<…>` placeholder from your own character / palette canon. **Do not let Grok invent palette, proportions, or design details** — feed them in.

**Character look block**

```
2D top-down concept art of <character name>, <one-line canonical description from character bible>.
Palette: <list your locked hex codes / colour names>.
Framing: low top-down view, roughly 20° tilt; full body; neutral background.
Line/shape: <line weight, level of detail, e.g. "soft chunky shapes, minimal outline">.
Era / setting: <e.g. "rural, pre-industrial village">.
Mood: <e.g. "quiet dread, muted, slightly wrong">.
Keep identical to reference: face, outfit, proportions, colour palette.
No additional text or decorative elements.
```

**Environment look block**

```
2D top-down concept art of <place name>, <one-line description>.
Palette: <list your locked hex codes / colour names>.
Framing: low top-down view, roughly 20° tilt; <interior / exterior>; <camera distance>.
Materials / architecture: <e.g. "weathered timber, stone, thatch">.
Lighting / dread: <e.g. "dim, single warm light source, long shadows, oppressive">.
Era / setting: <as above>.
Keep identical to reference: layout, colour palette, architectural style.
No additional text or decorative elements.
```

---

# Cost note

For this job you barely touch Heavy's limits — concept references are light usage, and even standard SuperGrok would cover it. Heavy's real value to this project is its stronger multi-agent reasoning for the **Grok research drafts that already get audited** before vault integration, not the art step. `[verified 2026-06-21 re: tier structure and Heavy reasoning features]` `[FLAG — exact image/video quotas are unofficial: reported ≈1,000 ops/day on Heavy vs ≈200 on standard, but xAI publishes no fixed figures]`

---

# Reliability key

- `[verified 2026-06-21]` — confirmed against current web sources (xAI docs + multiple guides).
- `[training knowledge]` — general pipeline reasoning, not version-specific.
- `[FLAG]` — uncertain, inferred, or officially unpublished; verify before relying on it.

# Open items / to verify

- Confirm in-app whether Grok offers any saved project or style memory for images (currently assumed: no).
- Quota figures are unofficial and shift; xAI publishes none.

---

*status: integrated 2026-06-21 — content lives in [[art/grok-reference-workflow]]; this file kept as verbatim provenance.*
