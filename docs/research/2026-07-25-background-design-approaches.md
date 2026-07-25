---
name: Background design approaches — painted vs tileset vs paint+props
date: 2026-07-25
source: Project-manager synthesis + vault (prop-coherence, open backdrop decision, pixel pipeline research) + general top-down RPG practice (ALttP-class tilesets; gamedev consensus on paint vs tile)
status: inbox
tags: [research, art, level, backdrops, tilesets]
related:
  - "[[art/prop-coherence]]"
  - "[[decisions/2026-06-20-village-backdrop-rerender]]"
  - "[[research/done/2026-06-20-pixel-art-pipeline-consistency]]"
  - "[[design/ai-production-setup]]"
---

# Background design: three approaches (research)

**Plain language:** how should the “world picture” under Rowan be built so it looks good, plays solid, and stays shippable for a solo Godot/Web horror RPG?

This note compares **three real options**, maps them to **Cycle of Innocence as built today**, and recommends a **default stack + when to break it**. It does **not** reopen the open backdrop decision by itself (R7).

## The three approaches

### A — Flat painted backdrop (one big image)

**What:** A single `Sprite2D` (or few layers) of the whole zone. Camera clamps to it. Characters walk on top.

**Pros**
- Fast mood and composition (one illustration).
- Unique “lived-in” layout without tiling seams.
- Matches “conspiracy space, not modular kitbash” (already load-bearing for VillageState markers).
- CoI already depends on this for **camera clamp** (`GroundBackdrop` on every zone).

**Cons**
- No free collision — paint is not solid (exactly the “walk over everything” bug).
- Hard to revise one tree without repainting the map.
- Style can drift vs 32×32 characters (painterly vs crisp pixel).
- Web weight if many huge unique PNGs.

**Industry note:** Common for **mood demos, painting-first games, and some mobile RPGs**. Classic SNES Zelda is *not* this — it is tile-based with props.

---

### B — Tilesets (ground as modular cells)

**What:** `TileMap` / Terrain / Wang tiles for grass, path, sand, water, floors. Reuse cells; paint layout in Godot.

**Pros**
- Collision can ride the tileset (or a collision layer) — walkability and art stay linked.
- Cheap iteration: change one tile, fix every instance.
- Canonical SNES / ALttP pattern: shared bricks, palette swaps, unique props for identity.
- CoI already has Wang tooling (`create_topdown_tileset`, playground terrain enums in `playground_fringes.gd`).

**Cons**
- Easy to look “kitbashy” if every zone is the same grass kit.
- Transition tiles and projection must stay locked (`view=low top-down`).
- Authored village *layout* still needs design (markers, patrols, eavesdrop) — tiles don’t invent story space.
- Converting current painted villages into pure tiles is a large art pass (see open decision).

**Industry note:** Default for **Zelda-likes and most 2D top-down RPGs** for a reason: reuse + collision + readability.

---

### C — Flat paint (or simple ground) + objects on top (hybrid)

**What:** Backdrop (or tile ground) for **floors only**; trees, swings, buildings, furniture as **separate sprites** (y-sorted) with **hand footprints** for collision.

**Pros**
- Best of both: mood ground + modular, collidable props.
- Matches CoI rules already: Grok ground-only repaints, props palette-locked, PropShadows, y-sort `World`.
- Collision plan (C1/C2) fits this model exactly — solids are prop footprints, not paint.
- Recontext can toggle prop groups without repainting the whole map.
- Industry hybrid: ALttP tiles for ground **plus** doodads; many modern pixel games use painted ground plate + prop kits.

**Cons**
- Two art pipelines to keep in sync (ground register vs prop register).
- If buildings stay *baked into* the paint *and* you don’t cut them out as props, collision and y-sort stay approximate (current village).
- Needs discipline: no baked shadows on props, projection canon, scale chart.

---

## Comparison (slice-relevant)

| Concern | A Paint only | B Tiles only | C Paint/tile ground + props |
|---------|--------------|--------------|------------------------------|
| Looks unique / storyful | High | Medium (needs unique props) | High |
| Walkable vs solid | Poor without hand collision | Good | Good (footprints) |
| Change one tree | Hard | Easy | Easy if tree is a prop |
| Style match to 32px chars | Risk | High | High if props locked |
| Web / reuse | Heavy unique PNGs | Light | Medium |
| CoI camera clamp | Native | Need clamp object or keep plate | Native if keep `GroundBackdrop` |
| CoI layout markers | Fine | Fine | Fine |
| Solo ship speed now | Already done | Big rebuild | Incremental |

---

## What CoI actually ships today

| Layer | Reality |
|-------|---------|
| Exterior “ground” | **Painted** `GroundBackdrop` (playground, village, fringes, interiors placeholders) |
| Terrain code | Wang/paint helpers still exist for playground, but **visual** is paint |
| Props | Mix: some real sprites (totem, forage icons); much equipment is **paint-only** with surface zones |
| Collision | Borders + hand solids (C1 playground equipment, C2 village buildings/trees) — **not** from paint |
| Open decision | [[decisions/2026-06-20-village-backdrop-rerender]] — paint vs re-render-to-32px/tiles **still proposed** |

So we are **A + partial C**: painted whole scenes, props incomplete, collision being hand-authored (correct for A).

---

## Recommendation (project-manager / non-binding)

### Default for the vertical slice: **Hybrid C, with current paint as ground plate**

1. **Keep** `GroundBackdrop` for camera clamp and mood (status quo, Option 3 of the open decision — don’t full-convert yet).  
2. **Treat paint as “floor + baked mass that we gradually cut out.”**  
3. **Promote anything that must block or y-sort** to **prop sprites** + **footprint StaticBody2D** (C1/C2 pattern).  
4. **Use tilesets** where modularity wins:  
   - interior floors/walls  
   - optional path/sand/grass patches if a zone is rebuilt  
   - not a forced rewrite of every exterior this week  
5. **Do not** auto-generate collision from backdrop pixels (fragile; Web-hostile).  

### When to pick each pure mode later

| Choose… | If… |
|---------|-----|
| Stay heavy paint (A) | Human says register mismatch is fine through slice; art time goes to characters/dread |
| Full tiles (B) | Human accepts the open decision Option 2; master palette + one pilot zone first |
| Deep hybrid (C+) | Props are cut from paint or regenerated; buildings become collidable y-sorted shells |

### Human call still open

The vault already flags this: **lookback** — does paint-vs-pixel read as wrong in F5, or is hybrid good enough?  
That answer should close [[decisions/2026-06-20-village-backdrop-rerender]], not an agent alone.

---

## Implementation bites (if we continue)

| Bite | Mission | Roles |
|------|---------|--------|
| **BG0** | Human F5: “does paint clash with Briar/Rowan?” (yes/no/soft) | **You** |
| **BG1** | Extract or place **top playground props** as sprites on paint (if still paint-only) + keep C1 solids | `/creative-art` → `/level-design` |
| **BG2** | Same for **one village landmark** (e.g. well or market crate) as real prop | `/creative-art` → `/level-design` |
| **BG3** | Pilot **one** zone ground re-render (32px quantize) *or* path tileset under paint | `/creative-art` + `/librarian` decision update |
| **BG4** | Interior floors as tilesets (already recommended in interiors docs) | `/creative-art` → `/level-design` |

---

## Librarian proposal (for human)

1. **Accept hybrid C as working policy for exteriors through slice** (document in prop-coherence or a short decision).  
2. **Leave full re-render decision OPEN** until BG0 human lookback.  
3. **Next build work:** prop extraction where paint-only props still fool the eye after C1/C2 collision (not a full village tile rebuild).  

---

## Sources (project)

- [[art/prop-coherence]] — ground-only paint + props lock; open tension  
- [[decisions/2026-06-20-village-backdrop-rerender]] — paint vs re-render (proposed)  
- [[research/done/2026-06-20-pixel-art-pipeline-consistency]] — tiles + re-render pipeline  
- Accessible interiors / ZoneRoot — `GroundBackdrop` clamp invariant  
- Recent C1/C2 sessions — hand footprint collision on paint zones  

## Sources (general practice)

- ALttP-class design: shared tiles + unique doodads/entrances (compression + identity)  
- Common gamedev tradeoff: full hand-drawn maps vs tile modularity (iteration, collision, style lock)  
- Hybrid (ground plate + prop sprites) is the usual modern compromise for AI-assisted or painting-first pipelines  

---

## Integration status

**Inbox** — propose-first. No lock edited. Human: accept hybrid policy? pilot re-render? continue prop extraction only?
