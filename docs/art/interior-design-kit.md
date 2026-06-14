---
name: Interior Design Kit — Classic Top-Down Interiors Reference
date: 2026-06-14
tags: [art, pipeline, interiors, reference]
status: active
source: "[[research/done/2026-06-14-interior-design-kit-reference]] (R7 bridge, claude.ai Research)"
related: "[[art/prop-coherence]] · [[art/imagine-prompts]] · [[mechanics/accessible-interiors]] · [[design/hollow-house-quest]] · [[mechanics/zone-recontextualization]] · [[mechanics/vision-and-darkness]]"
---

# Interior Design Kit — Classic Top-Down Interiors

Art-production reference for the three interior scenes (`cottage_ground`,
`cottage_basement`, `hollow_house`). The **systems** are already built
([[mechanics/accessible-interiors]]); this is the **asset grammar** that fills
them. Reliability markers preserved from source:
`[verified 2026-06-14]` (web-checked) / `[training knowledge]` / `[inference]`.

> **Reaffirms locked rules — no decision reopened.** The brief independently
> confirms our flat-neutral authoring rule ([[art/prop-coherence]] rule 2), the
> `CanvasModulate` + `PointLight2D` + occluder lighting stack
> ([[mechanics/vision-and-darkness]]), and the low-top-down projection canon
> ([[art/prop-coherence]] rule 5). These are **confirmations**, not edits.

## Core grammar (all three rooms share it)
- **Camera-facing back wall, 2–3 tiles tall**, consistent around the room; thin
  (1-tile) side walls; corner pieces; a framed doorway (door on a layer above
  the wall). Build from a **wall-frame tileset** (Slynyrd "boxy rooms").
  `[verified 2026-06-14]`
- **Boxy, enclosed floor**: one base tile that loops on all four sides + **at
  least one variant** (cracked/discolored) per texture to fight visual fatigue;
  border/edging where floor meets wall. **Rugs are focal anchors.**
- **Furniture = 32×32 map objects** placed in **clusters along walls**, central
  floor kept open for movement. One **focal point** (hearth/stove or bed) given
  negative space to breathe; entrance and stairs on opposite/adjacent edges so
  sightlines aren't blocked.
- Author tiles/props **FLAT and neutral** — no baked hearth glow, no colored
  dread tint, no directional shadows. Runtime `CanvasModulate`/`PointLight2D`
  per-floor `dread_baseline` owns all mood. (Identical to our shipped rule.)

## Room sizes (in tiles, 32×32) — `[inference]`, prototype to camera zoom
- **Minimum cozy single room:** ~**8×6** interior floor (one furniture group).
- **Comfortable small house room:** ~**10×8 to 12×10** (room for stairs + 2–3
  clusters).
- **Large benchmark:** ~**24×14** (LimeZu "Modern Interiors", at 16px) — big end.
- **Back wall height: 2–3 tiles**, consistent (RPG Maker interior convention).
  `[verified 2026-06-14]`
- *No source gives a hard minimum* — these are reasoned from RPG Maker
  conventions + SNES screen math (256×224 ≈ 8×7 tiles at 32px). Adjust on F5.

## Mood grammar — cozy vs. abandoned vs. middle (invertible checklist)
| Register | Palette | Furniture | Light | The tell |
|---|---|---|---|---|
| **Warm / safe** (`cottage_ground`) | ambers, warm browns, soft reds, cream | intact, upright, symmetric | warm runtime pool at the hearth | tidy clutter, family objects |
| **Tended but tense** (`cottage_basement`) | **same warm material palette** | intact, orderly storage | **lower** `CanvasModulate`, one dim light, longer shadows | cold stone creeping in + **one** slightly-off object |
| **Hollow / wrong** (`hollow_house`) | desaturated greys, sickly green, cold blue | broken/overturned, dust-sheeted | cold thin light from a broken window | **a single wrong detail / an absence where something should be** |

The **"single wrong detail"** is the highest-leverage horror device (Dr. Andrew
Wedgbury, "The Architecture of Fear", drwedge.uk, 7 Feb 2025: *"A single chair
in the centre of an empty room… suggests recent occupation"*; Don Carson's
"frozen tableau", Gamasutra 2000). It maps directly onto the `recontext` node —
reserve the strongest one for `hollow_house`; keep `cottage_basement` to **one**
subtle off-note so the gradient reads.

## Stairs — the one genuinely hard problem
Flat top-down can't show a descent. Solutions, in order of preference for us:
1. **Author each staircase as a single hand-made oblique set-piece sprite**
   (proportioned to the character/wall height), **not** a tiled floor.
2. Put **railing tiles on a layer ABOVE the player**; draw the player behind them.
3. **Slow the player while traversing** to sell depth the camera can't show
   (Bitzos). Fallback: simplify to a single "stairs" icon tile.

Source: Slynyrd "Pixelblog 35 – Top Down Interiors" (30 Nov 2021). *Engineering
task captured in [[ideas]].*

## Per-scene prop checklists

**`cottage_ground`** — tended, safe, warm (`dread_baseline 0.0`, dread decays).
~10×8 floor, back wall 3 tall. Hero set (**~12–16**): stove/hearth (focal),
table, 2 stools, bed, wardrobe/shelf, cradle, rug, 2–3 pots, plant, portrait,
barrel, door, **stairs set-piece**. Marta's `marker_marta` spot beside the
hearth or a table cluster — keep sightlines clear of tall furniture / the
camera-facing wall.

**`cottage_basement`** — tended but tense (~45 dread, middle register). ~8×6,
stone floor/walls. Hero set (**~8–10**): stairs-up set-piece, 3–4 barrels/crates
(labeled, orderly), shelf unit, preserve jars, lantern/candle (light source),
**one "wrong" object** (overturned crate / shadow with no caster / a child's toy
where it shouldn't be).

**`hollow_house`** — abandoned, eerie (high dread). ~10×8 to 12×10 (bigger feels
emptier), **deliberately asymmetric**, mostly empty negative space. Hero set
(**~10–14**): broken table, overturned chair(s), dust-sheet shape, cobweb
overlays, broken-floorboard tile(s), peeling/stained-wall variant, broken window
(light source), debris, **the single "wrong" tableau object**, door.

## Production sequence
1. **Shared tileset + lighting contract first** — one neutral 32×32 wall-frame +
   prop library, flat-lit, palette-locked. Confirm the Godot stack
   (`CanvasModulate` keyed to `dread_baseline`, `PointLight2D` radial gradient,
   shadow filter **None/Fast** to keep crisp pixels, wall occlusion polygons).
   Benchmark: if dread tint muddies warm props, **lower `CanvasModulate` alpha —
   don't repaint sprites**.
2. **Author the three scenes** from the checklists above.
3. **Validate against filters** — every "wrong detail" pays off via the recontext
   node (story); strongest device reserved for `hollow_house` (horror); Marta
   sightlines clear (companion); warm state reads "definitively safe" on a second
   visit so the hollow contrast lands (replay).

## Asset benchmark (ceiling, not a target)
A fully-stocked interior pack is ~**39 furniture + ~64 small décor** + structural
tiles (Penzilla "Top-Down Retro Interior", `[verified 2026-06-14]`). We ship each
scene with **far fewer hero props, well-clustered** — this is the upper bound, not
the plan.

## Caveats (from source)
- **Best tutorial is 16×16, not 32×32** (Slynyrd Pixelblog 35) — principles
  transfer, pixel density and exact prop sizes do **not**; re-derive for 32×32
  (Pixels-by-Skab is the true 32×32 reference).
- **Room dimensions are inferred**, not sourced — prototype and adjust.
- **One ALttP detail corrected**: the "dark basement needing the Lantern + a
  large mirror" is **Twilight Princess**, not A Link to the Past. The cozy
  ALttP layout (square room, bed + 3 jars at top, chest bottom-right) is verified.
- **Terranigma / Secret of Mana specifics are secondhand** (atmosphere verified;
  exact palettes/tiles not documented) — directional, not precise.
- **The "single wrong detail" is film/horror scholarship applied to games** —
  well-supported theory, but **playtest whether it reads at 32×32**, where
  subtlety is hard.

## Related
[[art/prop-coherence]] · [[art/imagine-prompts]] · [[mechanics/accessible-interiors]] · [[design/hollow-house-quest]] · [[mechanics/zone-recontextualization]] · [[mechanics/vision-and-darkness]]
