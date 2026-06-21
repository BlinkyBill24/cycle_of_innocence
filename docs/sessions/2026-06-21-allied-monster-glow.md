---
name: Allied-monster glow indicator
date: 2026-06-21
branch: feat/allied-monster-glow
tags: [session, monster, lighting, mercy, diegetic, save-load]
---

# 2026-06-21 — Allied-monster glow (diegetic safety read)

A soothed creature now glows softly, so the player can read at a glance which monsters
are safe and which are still a threat. Visual only — no soothe/combat change.

## The state it hooks (confirmed, not invented)
The "fully allied / on Rowan's side" state already exists: **`stilled`** — the mercy-
soothe outcome (encounters-mercy.md). It is persistent (the `stilled_<stable_id>` story
flag, restored on `_ready`, saved via SaveManager) and it reverts (betrayal + hollowing
re-aggro). The **Dominated** thrall is NOT this — it's transient (fights once, then
crumbles/queue_frees), so it's correctly out of scope.

## What I built
- `twisted_child.tscn`: an **`AlliedGlow` PointLight2D** (reuses the existing
  `glow_radial.png` lighting stack — same as the campfire), **`enabled = false`** by
  default, warm placeholder tone (`Color(1, 0.92, 0.72)`, energy 0.55, scale 0.6).
- `enemy_base.gd`: `_refresh_allied_glow()` sets `allied_glow.enabled = stilled` — a pure
  read of the persisted state, called at every `stilled` mutation: `_become_stilled`
  (on), `_ready` restore (on/off to match the load), `_betrayed` (off), and hollowing
  re-aggro (off). The light is `get_node_or_null` so a monster without it still works.
- No global `CanvasModulate` / dread-config change; per-monster light only. No shader.

## Tests — suite 346 green, check-brain green; Web export builds
`test_allied_glow.gd`: hostile = dark; soothed = glow; betrayal = off; hollowing
re-aggro = off; a monster loaded from the saved `stilled` flag glows; the glow survives a
real SaveManager save/load round-trip.

## Flags (for the PR)
- **PointLight2D, no shader** — the preferred path; Web export builds clean.
- **Reversion IS a state** (betrayal / re-aggro) — handled + tested, glow goes off.
- **Colour/energy are a placeholder** (warm "restored innocence") — tune to the final
  palette later. Note the Stilled sprite tint is cool-blue; the warm light reads against it.
- I'm runtime-blind: the export *builds*, but whether the glow **renders** at the right
  subtlety is an F5/Web check for you (lighting only shows against the dusk CanvasModulate).
