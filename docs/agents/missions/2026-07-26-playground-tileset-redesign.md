---
name: "Mission — Playground tileset redesign (T2)"
date: "2026-07-26"
tags: [agents, mission, art, tileset]
branch: "feature/playground-tileset-redesign"
status: active  # human: T1 still wins; chase Sorceress-kit density
---

# Mission: Redesign playground ground tiles (not another big paint)

## One sentence

Ship a **new 32×32 Wang ground tileset** for the playground that looks flat, dusk, and tile-native — so we can stop relying on the big painted ground plate the human still dislikes.

## Why

- **T1** (ground-only paint + v2 props) is **merged** and better than BG1, but the **tiles/ground still fail the human gate**.
- Current PixelLab playground atlas was generated **without** explicit `view="low top-down"` (API default = **high top-down**) and with `transition_size=0.5` (reads as **raised path / elevation**).
- Stack already owns the right tools: **PixelLab create-tileset** (terrain), **Grok Imagine** (look targets / seamless fills), optional **Sorceress Tileset Forge** (browser cleanup only — not map gen).

## Tool lane (locked for this bite)

| Job | Tool | Notes |
|-----|------|--------|
| Wang grass ↔ path atlas (production) | **PixelLab** `POST /create-tileset` via `tools/pixellab_tilesets.py` | 32px, `view=low top-down`, **flush** wording, low transition |
| Mood / look targets / anonymous seamless fills | **Grok Imagine** | Log every prompt in `docs/art/imagine-prompts.md` |
| Optional seam polish | **Sorceress Tileset Forge** (human browser) | Cleanup only — not auto-stack |
| Scene wire / Wang paint | `/level-design` **after** human picks winner | Do not auto-swap production scene without human |

**Do not** add Sorceress to the permanent stack without a decision.  
**Do not** invent new props this bite (keep T1 v2 equipment).  
**Do not** auto-collision from PNG.

## Success (done-when)

Creative-art deliverables:

1. [ ] Fresh PixelLab **playground** (and optionally **ritual** / **grass_blend**) atlases under `assets/reference/pixellab_tilesets/` named for the redesign (e.g. `playground_v2_tileset_32.png` + preview ×4).
2. [ ] 2×2 seam check PNGs for pure grass and pure path (no obvious motif grid / seam lines).
3. [ ] Imagine look-target stills (optional but preferred) in `assets/reference/tileset_redesign_2026-07-26/`.
4. [ ] Prompts logged in `docs/art/imagine-prompts.md`.
5. [ ] Side-by-side compare sheet: **old atlas | new atlas | T1 painted crop** for human pick.
6. [ ] Session journal entry for this branch.

Then stop for **human F5 / pick**.  
Only after pick: `/level-design` swaps `ground_tileset` / repaints playground Wang field (and decides whether the painted plate stays as a soft underlay or goes away).

## Art direction (plain words)

- Village playground at **dusk after the ritual** — warm dry grass, trampled packed-earth paths.
- **True top-down**, **flat** — path sits **level with** grass, no curb, no cliff, no “upper terrace.”
- Anonymous texture (no unique flower/rock you can spot repeating).
- Limited warm dusk palette (anchors already in `pixellab_tilesets.py` `PALETTE`).
- Equipment is **props**, never painted into ground tiles.
- Horror is **quiet** — wrong emptiness / trampled ritual wear, not gore.

## Role order

1. **`/creative-art`** (this bite — primary)
2. Human pick gate
3. **`/level-design`** — wire winner into playground zone
4. **`/playtest-qa`** — smoke only
5. Human F5 feel → merge

## Technical constraints

- Branch: `feature/playground-tileset-redesign` (already cut from main after T1 merge `d7644c8`).
- PixelLab balance was ~$5.50 + Tier 2 gens; keep re-rolls cheap (one playground first, then optional ritual/blend).
- Old `state.json` tileset IDs may be dead (`status` returned None) — **re-queue** under new keys (`playground_v2`, …); do not destroy old PNGs until human signs off.
- `transition_size`: prefer **0.0** or **0.25** for flush path (0.5 taught the “raised curb” look).
- Always pass **`view: "low top-down"`**.
- Install path after download: `tools/gen_zone_tileset_tres.py` copies atlases → `assets/sprites/tiles/` (level-design owns when to run for production).

## Out of scope

- Fringes full redesign (optional later same pipeline)
- Village green re-roll
- Prop redraw (T1 v2 stands unless palette-lock needs a new plate)
- Collision / WorldSolids changes
- Sorceress full AutoSprite / SFX

## Human gates (never fake)

- Does the grid disappear at game zoom?
- Does the path feel walked-in dirt, not a raised sidewalk?
- Do T1 props still sit on this ground without looking pasted from another game?
- Prefer tiles over painted plate? Hybrid underlay ok?

## Handoff packet for `/creative-art`

```text
Mission: Redesign playground 32px Wang ground tiles (grass↔path), flat low top-down dusk.
Branch: feature/playground-tileset-redesign
Read: docs/agents/missions/2026-07-26-playground-tileset-redesign.md
      tools/pixellab_tilesets.py
      assets/reference/pixellab_tilesets/playground_tileset_preview.png
      assets/sprites/painted/playground_painted.png (T1 ground-only)
      docs/art/imagine-prompts.md style lock
Tools: PixelLab create-tileset (primary), Grok Imagine look-targets, Sorceress optional human polish only
Deliver: playground_v2 atlas + previews + seam checks + compare sheet + prompt log + journal
Stop: human pick before level-design wires production
```


## Update 2026-07-26 (human feedback)

**T1 still looks best.** PixelLab `playground_v2` rejected for feel.

Quality bar (user Downloads, now in `assets/reference/tileset_redesign_2026-07-26/`):
- Sorceress village kit PNG — modular 2D ground band = target density
- Lush 3D nature JPEG — detail density only; **not** CoI style

Next creative path: **T1+ denser paint** and/or **modular high-detail ground tiles** (Imagine + Sorceress Seedream), not more flat Wang 16-tile sets for the hero playground plate.


## Locked direction (human 2026-07-26)

- **No** slicing `t1_plus` / painted plates into fake tiles.
- Keep continuous paint; chase beauty on the plate.
- Fix **prop match** (palette + optional restyle candidates), not tile-cutting.
- Production plate on this branch = T1+ install.
