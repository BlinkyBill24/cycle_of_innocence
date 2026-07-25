---
name: Sorceress Tileset Forge evaluation (playground prop mismatch)
date: 2026-07-25
source: >
  Human lookback (BG0: paint “not too bad”; BG1 props “do not fit background at all”)
  + live product page https://sorceress.games/pages/tileset-forge
  + tool UI https://sorceress.games/tileset-creator
  + Tool API discovery 2026-07-25 (17 tools; no tileset_forge id)
  + vault: prop-coherence, open backdrop decision, background-design research
status: inbox
tags: [research, art, tilesets, sorceress, backdrops]
related:
  - "[[art/prop-coherence]]"
  - "[[decisions/2026-06-20-village-backdrop-rerender]]"
  - "[[research/done/2026-06-20-pixel-art-pipeline-consistency]]"
  - "[[sessions/2026-07-25-playground-props-sprites]]"
---

# Sorceress Tileset Forge — evaluation for Cycle of Innocence

## Why this note exists

**BG1** placed stock pixel props (swing/slide/roundabout/trees) on the **painterly**
`playground_painted.png`. Human: **props do not fit the background at all.**

That is a **register / style mismatch**, not a wiring failure. Collision (C1)
can stay; mismatched sprites should **not** ship on main.

Question: does **[Tileset Forge](https://sorceress.games/pages/tileset-forge)**
fix the world-building path better than paint+random props?

---

## What Tileset Forge actually is

From the product page + live `/tileset-creator` UI `[verified 2026-07-25]`:

| Claim | Reality |
|-------|---------|
| “AI art → perfect tilesets” | **Cleanup / forge tool**, not a full map generator |
| Generates original art? | **No** — starts from **uploaded** AI/hand sheets |
| Pipeline | Upload → **detect** tile components → **clean** (chroma, edge, alpha, fit cell) → **preview** stamp map → **export** PNG sheet (+ optional normal map) |
| Grid | You choose output tile W×H; fill/fit/anchor/rotate/flip |
| Engines | Plain PNG → Godot, Tiled, Unity, etc. |
| Agent API? | **Not in Tool API catalog** (2026-07-25). Live tools: `image_generate`, AutoSprite suite, Parallax suite, SFX/speech/music, 3D, ping. **No `tileset_*` tool id.** |

**Implication for agents:** Tileset Forge is a **human-in-browser** (or future browser automation) step. Our `tools/sorceress_api.py` **cannot** call Forge today. Closest API cousins:

- `image_generate` — make terrain/prop sheets (Grok Imagine, etc.)
- **Parallax** tools — multi-layer scrolling backgrounds (side-scroller style), **not** a top-down gameplay TileMap substitute
- PixelLab (existing stack) — `create_topdown_tileset` / Wang tiles (already documented)

---

## How it maps to the three background approaches

| Approach | Tileset Forge role |
|----------|-------------------|
| **A Paint only** | Optional: slice paint into tiles for reassembly (heavy) |
| **B Full tileset ground** | **Primary cleanup** after you generate a terrain sheet |
| **C Hybrid ground + props** | Clean **prop atlases** and **ground tiles** separately so they share cell size / edges |

Forge does **not** by itself solve “props match paint.” Matching needs:

1. Same **camera** (low top-down / prop-coherence Rule 5)  
2. Same **palette** (palette_lock / master palette)  
3. Same **lighting** (flat-neutral props; dread via CanvasModulate)  
4. Ideally **same generator pass** (one style ref) for ground *and* props  

Dropping pre-existing 32–96px prop sprites onto a soft Grok village/playground paint **will keep failing** even with Forge — Forge can’t restyle a swing to match a painterly merry-go-round already baked into the plate.

---

## Evaluation vs CoI needs

### Strengths for us

1. **AI sheet → engine-ready cells** — exactly the gap between Imagine/PixelLab mess and Godot TileSet.  
2. **Chroma / edge cleanup** — reduces dark fringes that read as “wrong register.”  
3. **Map preview** — stamp tiles before committing a zone rebuild.  
4. **Godot-friendly export** — PNG sheets; no WizardGenie lock-in if we only take PNG.  
5. Fits open decision **Option 3** (pilot one zone) better than silent full rewrite.

### Weaknesses / risks

1. **No Tool API** — agents can’t run Forge headless; human (or browser automation later) owns the pass.  
2. **Does not generate layout** — VillageState markers, eavesdrop, doors still hand-authored (good — keep that).  
3. **Does not replace PixelLab** for multi-dir characters; only environment tiles/prop sheets.  
4. **Double paint problem** — if backdrop still shows full equipment **and** we place tile props, double-image remains until ground is **ground-only** or fully tiled.  
5. Stack bloat — another vendor surface; only adopt if a **scored pilot** beats PixelLab Wang + hand `palette_lock`.

### Fit score (agent, for this job)

| Criterion | Score (0–5) | Note |
|-----------|-------------|------|
| Fixes BG1 style clash | **2** alone | Needs new matched art + ground-only plate |
| Tile cleanup quality (claimed) | **4** | Purpose-built for that |
| Agent automatable now | **1** | Browser-only |
| Solo-dev cost for slice | **3** | One pilot zone OK; all zones expensive |
| Aligns with CoI camera clamp | **3** | Keep a clamp plate or clamp TileMap bounds |
| Patent / Web | **5** | Offline PNG; no runtime LLM |

**Verdict:** Tileset Forge is a **useful cleanup station in a tile-first or tile+prop path**, **not** a drop-in fix for “wrong sprites on a pretty paint.”  
**Do not** adopt as production stack default until a playground (or village) pilot scores better than status quo.

---

## Recommended path (after human “props don’t fit”)

### Immediate (BG1 fallout)

| Action | Who |
|--------|-----|
| **Do not merge** `feature/playground-props-sprites` as-is | PM / human |
| **Keep** C1/C2 collision on main (solids without mismatched sprites) | already on main |
| Optional: delete or park BG1 branch after documenting | `/level-design` |

### Policy (closes the visual issue)

**Target architecture for exteriors (hybrid, improved):**

```text
Layer 0  Ground only (paint OR tiles) — paths, dirt, sand, grass  [no equipment drawn in]
Layer 1  Collidable y-sorted props (same style register as ground tiles)
Layer 2  Characters / NPCs
Layer 3  FX / fog / light
```

That means either:

**Path T1 — Ground-only repaint + style-matched props**  
1. `/creative-art`: Grok **ground-only** plate for playground (no swings in the image — prop-coherence ground-only rule).  
2. `/creative-art` or PixelLab: props from **same** style ref / palette.  
3. Optional **Tileset Forge** (human): if props arrive as a messy sheet, clean to 32/48 grid.  
4. `/level-design`: place props + keep C1 footprints.  

**Path T2 — Tile-first pilot (Tileset Forge heavy)**  
1. `/creative-art`: generate terrain **tile sheet** (Imagine or PixelLab Wang).  
2. **Human** Tileset Forge: detect → clean → export 32×32 sheet.  
3. `/programming` + `/level-design`: Godot TileMap + collision layer; keep `GroundBackdrop` clamp via empty bounds or full map sprite bake.  
4. Props as separate tiles/objects, same sheet family.  
5. Score vs current paint in F5; update [[decisions/2026-06-20-village-backdrop-rerender]].  

**Path T3 — PixelLab only (no Forge)**  
Use existing `create_topdown_tileset` + `create_map_object` at `view=low top-down` (already in vault). Forge optional if PixelLab sheets need edge cleanup.

### Suggested default

**T1 first for playground** (matches locked ground-only paint discipline + human BG0 “paint not too bad”).  
Use **Tileset Forge** only if the new prop/terrain sheets need cleanup, or if T1 still fails and we pilot **T2**.

---

## Human recipe — Tileset Forge trial (Arm D)

If you run Forge yourself (agents cannot API it today):

1. Open https://sorceress.games/tileset-creator (account with credits/plan as needed).  
2. **Input A:** export a crop of `playground_painted.png` OR a new ground-only Imagine sheet.  
3. **Input B:** a single AI sheet of playground props (same prompt style/palette).  
4. Detect → clean chroma → force **32×32** (or 48×48 for large props) → stamp a mini map → export PNG.  
5. Drop under `assets/reference/bakeoff_2026-07-25/arm_d_tileset_forge/`.  
6. Score vs paint-only and vs BG1 stock props (table below).  
7. Agent `/level-design` only imports if Arm D wins.

### Scorecard (0–5) — fill after trial

| Criterion | Paint only | BG1 stock props | Forge pilot |
|-----------|------------|-----------------|-------------|
| Style match ground↔props | — | 0–1 (human: fail) |  |
| 32px readability |  |  |  |
| Collision clarity | C1 ok | C1 ok |  |
| Time-to-import |  |  |  |
| Agent automatable | high | high | low (browser) |
| Ship for slice? | yes interim | **no** | ? |

---

## Agent hand-offs (do not all run at once)

| Role | Task |
|------|------|
| **PM** | Hold BG1 merge; pick T1 vs T2 after human score |
| **`/librarian`** | When pilot scores exist, update/close [[decisions/2026-06-20-village-backdrop-rerender]] |
| **`/creative-art`** | Ground-only playground plate **or** terrain tile sheet + matching prop sheet |
| **Human** | Tileset Forge cleanup pass if sheets are messy |
| **`/level-design`** | TileMap or prop placement after art wins |
| **`/programming`** | TileSet resource + collision layers if T2 |
| **`/playtest-qa`** | Soft-lock + boot smoke after rebuild |
| **`/reviewer`** | Diff size / Web texture budget |

---

## Bottom line

1. **You are right** — BG1 props on painterly paint is the wrong hybrid.  
2. **Tileset Forge** is a strong **tile cleanup/export** tool for Godot, **not** an API map builder and **not** a magic style-matcher for existing mismatched sprites.  
3. **Next build:** either **ground-only repaint + matched props (T1)** or a **scored Forge/PixelLab tile pilot (T2/T3)** — not shipping unstyled stock props.  
4. **Collision C1/C2 on main stays valuable** without the bad sprites.

## Integration status

**Inbox.** Human: confirm T1 vs T2; confirm abandon merge of `feature/playground-props-sprites`.
