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
2. ~~Clamp Camera2D limits to backdrop rects~~ — **DONE 2026-06-12**
   (branch `fix/zone-coherence-camera-palette`): `ZoneRoot` clamps the player
   camera to the `GroundBackdrop` rect + 16px bleed on zone enter, and resets
   limits in zones without a backdrop so clamps never leak across transitions.
3. ~~Palette hard-lock pass over existing village props~~ — **DONE
   2026-06-12** (same branch): new `tools/palette_lock.py` (PIL,
   nearest-RGB remap, alpha preserved, `--dry-run`); all 10 village props
   were 100% off-palette and are now locked to the backdrop's 48 colors.
   Expected casualty: cool accents (chapel roof) went warm-olive — the
   palette has no cool colors by design; polish via item 5 regen if needed.
4. ~~Extend foundations + contact ellipses to the village zone~~ — **VERIFIED
   ALREADY COVERED 2026-06-12**: `PropShadows.apply($World)` runs in BOTH zone
   scripts (village_green.gd:50), village props follow the StaticBody2D+
   Sprite2D pattern it targets, and village buildings sit on baked worn
   foundations since the backdrop lock. The research screenshots predated
   this (stale vintages).
5. **Regenerate worst offenders** — candidates staged 2026-06-12:
   `candidates/well_v2.png` (60px) + `candidates/fence_v2.png` (52×41), both
   generated via the item-6 recipe against real ground crops and
   palette-locked. **User decides swaps in the editor placement pass**
   (collision shapes were sized for the old sprites). Buildings deliberately
   NOT regenerated: palette lock + baked foundations already ground them, and
   a regen would fight the foundations painted into the backdrop.
6. ~~`create_map_object` smoke test~~ — **PASSED 2026-06-12**: no server-side
   500 (unlike create-tileset's reference params); style/projection inherited
   from the backdrop crop; palette only partially inherited → run
   `tools/palette_lock.py` on every result. **Production recipe**: crop the
   zone backdrop where the prop will stand → background_image (the MCP path
   mode hands back a curl command — key comes from `~/.config/pixellab/api_key`,
   never inline) → object size ≈ crop size × oval fraction (64px crop +
   fraction 0.72 ≈ 45–60px prop; 128px crop ≈ 75px+ prop — pick crop size for
   target scale) → trim transparent border → palette-lock → stage in
   `assets/sprites/village/candidates/` for editor placement (placement/scale
   is the user's editor pass).
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
