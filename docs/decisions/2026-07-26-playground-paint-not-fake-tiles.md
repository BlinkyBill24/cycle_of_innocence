---
name: "Playground ground = continuous paint (no fake tiles)"
date: "2026-07-26"
tags: [decision, art, tileset, playground]
status: accepted
branch: feature/playground-tileset-redesign
---

# Decision: Playground ground stays a continuous painted plate

## Context

After T1 (ground-only paint + separate props) and a PixelLab Wang tileset
attempt (`playground_v2`), the human preferred **T1 / T1+ painted ground** and
rejected treating a full paint as if it were a tileset.

## Decision

1. **Do not slice** a fully painted playground plate into Wang/autotiles.
2. A **fully painted plate** must stay continuous and as beautiful as we can
   make it (T1+ denser grass is the current production candidate).
3. **Modular tilesets** remain valid only when the zone is *authored as tiles*
   (village grass/path grids, etc.) — not as a fake cut of a hero paint.
4. The remaining quality problem is **prop coherence** (palette + style match
   to the plate), not re-tiling the plate.

## Implementation this branch

- Production plate: `assets/sprites/painted/playground_painted.png` ← T1+
  (backup: `playground_painted_t1_pre_plus.png`).
- Props: palette-locked to adaptive 48 colors from the new plate
  (`tools/palette_lock.py --max-colors 48`).
- Restyle Imagine candidates kept under `props/candidates/*_t1plus.png` for
  optional later adoption (silhouette changes need human pick).

## Related

- [[agents/missions/2026-07-26-playground-tileset-redesign]]
- [[art/prop-coherence]]
- [[sessions/2026-07-25-playground-t1-ground-props]]
