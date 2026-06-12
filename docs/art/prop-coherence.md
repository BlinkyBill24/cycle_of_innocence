---
name: Prop Coherence — rules & fix plan
date: 2026-06-12
tags: [art, pipeline, rules]
status: active
related_decisions: "[[sessions/2026-06-11]] (backdrop art direction lock)"
---

# Prop Coherence — Rules & Fix Plan

Source: art-tooling research + cross-model (Grok) review
([[research/done/2026-06-12-research-art-tooling-prop-coherence]]), corrected
by local verification 2026-06-12.

**Verdict (convergent across two models + audit): the stack is right; the
screenshot failures are a compositing/workflow gap, not a tooling gap.**
PixelLab characters, Grok GROUND-ONLY backdrop repaints, and the hand-rolled
adaptive audio are all reaffirmed — keep the locked art lane.

**Mid-2026 reality check** `[verified 2026-06-12]`: AI map tooling is
asset/tileset-level everywhere (PixelLab map tools are guided inpainting;
Ludo.ai is tilesets; nothing layout-level exists). Nothing one-shots a village
that "makes sense." Layout stays design work here **by necessity** — it is
load-bearing: VillageState routine markers, eavesdrop zone placement, Warden
patrol readability, recontext groups. Zones must read as *lived-in conspiracy
spaces, not modular kitbash* — that is the replay-value stake.

## Rules (apply to every prop, every zone)

1. **Palette hard-lock**: extract each zone backdrop's 48-color palette;
   force-quantize every prop to it (ImageMagick `-remap` / Aseprite CLI —
   tool belongs in `tools/`). Upgrades the Terranigma-pass desaturation fix
   into a guarantee. Biggest visual win per minute.
2. **Flat-neutral-light authoring**: props carry NO baked time-of-day light
   and NO cast shadows — `CanvasModulate` + lights own time-of-day. (A prop
   repainted to match one scene's light is wrong in every other scene.)
3. **Scale chart** (pin in [[art/imagine-prompts]]): player = 32 px reference;
   door ≈ 1.3× player; lamp/fence/well heights pinned alongside.
4. **Shadow canon (restated — a cross-model review garbled it)**: procedural
   contact-shadow ellipses for small props; baked worn foundations for
   buildings; **no shadow ellipses on ≥96 px sprites** (they caused floating).

## Prop generation workflow

- **New props**: PixelLab `create_map_object` with a crop of the actual zone
  backdrop as `background_image` (style/palette/light/projection inherited;
  output stays a transparent sprite for y-sort/collision) `[verified
  2026-06-12, pixellab.ai/mcp]` — **gated on a smoke test first**: our record
  shows reference-image params 500ing server-side on `create-tileset`; the
  proven style path is `generate-with-style-v2`/bitforge, which is the
  fallback with the same crop.
- **PROPS-ONLY `edit_image` diagnostic**: one repaint pass on a real composited
  screenshot ("repaint the lantern/bench/well to match the ground lighting and
  palette") to set the visual bar before regenerating anything. **Benchmark
  only, never the standing pipeline** — re-cropping repainted props bakes
  scene light into the sprite (violates rule 2).

## Ordered fix plan (cheap → structural; verified state 2026-06-12)

1. ~~Remove courtyard decal instances~~ — **already clean in repo** (no
   decal/courtyard/set-piece nodes in any scene; the reviewed screenshots were
   stale vintages).
2. **Clamp Camera2D limits to backdrop rects** (or add bleed margin) —
   confirmed missing (no `limit_*` anywhere); kills the grey void. *(code,
   trivial)*
3. **Palette hard-lock pass** over existing village props (rule 1 tool).
4. **Extend foundations + contact ellipses** to the village zone's
   buildings/props (prop footprints into the geometry-guide step).
5. **Regenerate worst offenders** under rules 1–3: well, fences, the image-3
   house (cool violet-grey props on warm ochre ground; baked daylight on the
   cottage).
6. **`create_map_object` smoke test** with a real backdrop crop (workflow
   above).
7. **Editor pass (user)**: missing StaticBody2D on the painted stone wall;
   audit painted features vs collider coverage; check the midday player-glow
   toggle.

## Filter test

Serves **horror beats** directly (the warm/cold zone thesis is a palette
effect — it cannot land while props carry foreign palettes), **companion
arcs** (Briar's pings/digs read as grounded only in a believable village
edge), and **replay** (recontext moments need lived-in spaces to
recontextualize). No new mechanics — everything slots inside the
content-complete-per-zone rule.

## Related

[[art/imagine-prompts]] · [[plan/slice-implementation-roadmap]] ·
[[research/done/2026-06-12-research-art-tooling-prop-coherence]] ·
[[sessions/2026-06-11]]
