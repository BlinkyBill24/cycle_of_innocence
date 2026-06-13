---
name: "Session 2026-06-13 — Hollow House micro-quest (vertical slice)"
date: "2026-06-13"
tags: [session, cycle-of-innocence, quest, vertical-slice]
branch: feature/hollow-house
commits: []
---

# Session 2026-06-13 — Hollow House micro-quest

## Focus
Build the [[design/hollow-house-quest]] vertical slice — dread + Briar bond +
knowledge discovery — on EXISTING systems only (no new autoloads/mechanics).
Spec: [[decisions/2026-06-13-next-phase-hollow-house-slice]].

## What I did
*(newest first)*
- **Hollow House micro-quest, pass 1** (suite **262** green, headless boot clean).
  Mapped the exact API surface first via three parallel read-only agents
  (companion/LimboAI, diggable/journal/items, dread/audio/recontext/dialogue),
  then wired only existing systems:
  - **Briar-seek** ([[mechanics/companion-pointer]]): `CompanionBase.command_seek`
    + a `Seek` HSM state (lead → look-back loop → exclusive tell + new
    `briar_seek` SFX). Eagerness scales with bond, hesitation/refusal with
    corruption; safe-by-default. Re-points on **recall (C)** via
    `GameEvents.companion_recalled`. Pure `pick_seek_target` unit-tested.
  - **No-missable fallback** (Fable model): `_try_companion_assist` now lets
    Rowan dig by hand when Briar's absent; the ledger carries a `Glint`
    affordance. Reveal is companion-agnostic (unit-tested).
  - **Knowledge gate, not item gate** (`HollowHouseQuest`): the recontext beat
    fires only when the ledger is found AND ≥2 `sign_hollow_*` DOOM entries are
    witnessed, in either order → unlock `hollow_house_truth` (ZoneRecontext) +
    one stinger + dread spike + a DOOM Journal entry + one balloon. Pure gate
    unit-tested. Journal stays a memory aid (no x/y counter).
  - **One diegetic gate** (`GatedDoor`): Briar scratches it open (digs the paired
    spot) — not a key-hunt.
  - **Horror wiring**: `DeepDread` (level 55) makes Briar cower in the ledger room
    *before* the reveal (foreshadowing paid off when the book reframes it);
    `FearEmitter` ramps the dread stem by proximity to the ledger (pure curve
    unit-tested); one stinger reserved for the turn.
  - **Scene** `scenes/zones/hollow_house.tscn` (`InteriorRoot`): closed floorplan
    (hub + left room + gated right room) with traversable doorways; reused the
    playground lighting/DuskTint approach. New `recall_companion` input (C).
  - **+12 GUT tests** (`tests/test_hollow_house.gd`): seek-pick, knowledge gate,
    fear curve, fallback reveal, recontext lore choice.
  - Graybox assets only (`briar_seek.wav`, floor, gate panel, glint, ledger icon
    + ItemDef, `hollow_house_book.dialogue`).

## F5 checks I still need a human for (runtime-blind)
- Briar-seek **cue readability** — does she clearly lead? does **recall (C)**
  re-point? (the dominant readability failure mode — playtest threshold in the
  decision record).
- **Dread ramp** into the ledger room + Briar's pre-reveal cower.
- **Stinger timing** on the recontext beat.
- **End-to-end traversal**: hub → witness 2 signs → scratch the gate → seek/dig
  the ledger → recontextualization.
- Verify the **Web export** plays the loop.

## Open follow-ups (ideas inbox)
- A world/village **door into** `hollow_house` + a `spawn_from_hollow_house`
  marker (currently bootable standalone; entrance is the editor pass).
- Real interior **art** + a dedicated `seek_tell` animation + a real `briar_seek`
  bark (placeholders shipped).
- **Touch parity** for the recall input (mobile).
- Then: the **Phase-2 external playtest** per the decision record.

## Related
[[design/hollow-house-quest]] · [[mechanics/companion-pointer]] · [[decisions/2026-06-13-next-phase-hollow-house-slice]] · [[design/secrets-and-discovery]] · [[mechanics/accessible-interiors]]
