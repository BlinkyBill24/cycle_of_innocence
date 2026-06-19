---
name: Hollow House — Investigation Micro-Quest (Vertical Slice)
date: 2026-06-13
tags: [design, quest, vertical-slice, horror, secrets, companions]
status: draft
related_decisions: "[[decisions/2026-06-13-next-phase-hollow-house-slice]]"
source: "[[research/done/2026-06-13-companion-pointer-investigation-design]] (R7 bridge)"
related: "[[mechanics/accessible-interiors]] · [[design/secrets-and-discovery]] · [[mechanics/zone-recontextualization]] · [[mechanics/companion-pointer]] · [[mechanics/hollowing-clock]]"
---

# Hollow House — the Investigation Micro-Quest

The first **Tier-A authored interior** ([[mechanics/accessible-interiors]] tiers)
and the concrete vehicle for the **secrets** pillar of the locked next arc
(*early-game authored beat + doom signals + secrets*) that the
[[playtest/2026-06/synthesis]] surfaced ("not enough action or secrets"). It is
the **vertical slice that makes a playtest meaningful**: the smallest artifact
that exercises every shipped system together. Sequencing & rationale live in
[[decisions/2026-06-13-next-phase-hollow-house-slice]]; sourcing in
[[research/done/2026-06-13-companion-pointer-investigation-design]].

> Reliability markers preserved from source: `[verified 2026-06-13]` /
> `[training knowledge]`.

## The shape (Gone Home, compressed)
A **closed floorplan** — entry hub + 2–3 small rooms off it, **one** diegetic gate
— so a tiny linear space reads as non-linear (Gone Home's "successful illusion")
`[verified 2026-06-13]`. ~10–20 minutes, a handful of beats. One **"beautiful
room"** gets disproportionate polish to show the game's ceiling.

**Beat spine:** arrive → enter → first dread beat + Briar reaction → search
(3–6 clues) → find the hidden book/truth → **recontextualization beat** → exit
changed. Edith Finch vignette discipline: short, digestible, with breathing room.

## Content budget
- **1 core revelation** (a hidden book/truth about this house's lost child) +
  **3–6 environmental clues**. Core story tells fully if all its pieces are found;
  peripheral lore sits "along a spectrum" of optionality (Gaynor) `[verified 2026-06-13]`.
- **One** diegetic gate max — a stuck door Briar scratches open, or a floorboard
  key she digs up. **Not** a key-hunt ("whose house would be like that?") `[verified 2026-06-13]`.

## Binding rules inherited (see [[design/secrets-and-discovery]])
1. **Knowledge-gated, not item-gated.** The quest completes when Rowan has
   **witnessed N doom-signals** (a Journal LORE/DOOM threshold), not when an
   inventory checklist is full. Reading the book **recontextualizes** signals the
   player already saw ([[mechanics/zone-recontextualization]] state change + new
   DOOM Journal entry) — the *aha*, not a fetch.
2. **Journal = memory, never a counter.** In-character "what Rowan noticed"
   entries; **no "x/y clues found"** (tracker-UI compulsion warning — Gaynor &
   Barlow) `[verified 2026-06-13]`.
3. **Nothing story-critical permanently missable.** Every required clue has a
   no-Briar fallback affordance ([[mechanics/companion-pointer]]).
4. **No-wiki / no pixel-hunt on the critical path.** Required interactables use
   the consistent 32×32 glint/outline language; obscure spots are *optional lore
   only*.
5. **Critical path never requires combat** — mercy/avoidance always viable
   ([[mechanics/encounters-mercy]]).

## System wiring (existing systems only)
| Beat | System |
|---|---|
| Find the hidden book/clues | [[mechanics/inventory]] DiggableSpot (+ItemDef) + shimmer fallback |
| Briar leads to a clue | [[mechanics/companion-pointer]] `seek_target` (+ no-missable fallback) |
| Dread rises with depth | DreadManager + [[mechanics/adaptive-audio]] (proximity "fear-emitter" volume curve on the dread stem) |
| Briar fears the *room* | [[mechanics/companion-quirks]] fear behavior — **foreshadows** the recontext |
| The truth reframes the space | [[mechanics/zone-recontextualization]] state change + DOOM Journal entry + single stinger |
| Doom-signal foreshadowing | [[mechanics/hollowing-clock]] bells/posters as the witnessed signals |
| Persist / replay | SaveManager (interior floor persistence) + NG+ recontextualized lore |

## Horror pacing (small interior)
- **Audio-first** — low drone under the bed; the **dread stem scales by proximity
  to the hidden truth** (Dead Space "fear emitter") `[verified 2026-06-13]`; a
  **single stinger** reserved for the recontext beat.
- **Darkness defines legibility** — Briar + a small light radius reveal; the dark
  hides the clue *and* the dread ([[mechanics/vision-and-darkness]]).
- **Briar as the unique amplifier** — she fears the room *before* the player
  learns why; her earlier dread pays off at the reveal (and again on NG+).

## Visual grammar (real-art pass)
Production grammar lives in **[[art/interior-design-kit]]** (the `hollow_house`
column): desaturated cold palette, deliberate asymmetry, mostly empty negative
space, broken/dust-sheeted furniture, cold thin light from a broken window. The
load-bearing dread device is the **single wrong detail / "absence where
something should be"** (Wedge's "recent occupation"; Carson's frozen tableau)
`[verified 2026-06-14]` — author it so it **pays off through the `recontext`
node**, not as set dressing that means nothing. Reserve the strongest one for
this house; the cottage basement gets only one subtle off-note so the gradient
reads. (The pass-1 slice is graybox — this is the PixelLab/Grok art pass.)

## Exit criteria (Phase-1 done)
Playable start-to-finish on Linux **and** Web export, with all six systems firing:
accessible-interiors transition, Briar-seek + fallback, DreadManager + adaptive
audio, companion fear, zone-recontext + Journal DOOM gate, save/reload inside the
house. Then → **Phase 2 external playtest** (thresholds in the decision record).

## Built — pass 1 (2026-06-13, branch `feature/hollow-house`)
Graybox slice on existing systems only; suite 262 green, headless boot clean.
- **Scene** `scenes/zones/hollow_house.tscn` (`InteriorRoot`, `dread_baseline 8`):
  closed floorplan — hub + a left room (doom-signals) + a right room (the ledger)
  behind one diegetic gate, with doorway gaps so it's traversable.
- **Briar-seek** (`CompanionBase.command_seek` + a `Seek` HSM state): lead →
  look-back loop → exclusive tell + new `briar_seek` SFX; eagerness scales with
  bond, hesitation/refusal with corruption; re-points on **recall (C)** via
  `GameEvents.companion_recalled`. Pure `pick_seek_target` unit-tested.
- **No-missable fallback**: `_try_companion_assist` now lets Rowan dig by hand
  when Briar's absent (Fable model); the ledger `DiggableSpot` carries a `Glint`
  affordance. Reveal is companion-agnostic (unit-tested).
- **Knowledge gate** `HollowHouseQuest`: the recontext beat fires only when the
  ledger is found **and** ≥2 `sign_hollow_*` DOOM entries are witnessed (either
  order) → unlock `hollow_house_truth` (ZoneRecontext swaps nodes) + one stinger
  + dread spike + a DOOM Journal entry + one balloon. Pure gate unit-tested.
- **Gate** `GatedDoor`: a stuck door Briar scratches open (digs the paired
  `hollow_door_scratch` spot) — one gate, not a key-hunt.
- **Horror**: `DeepDread` zone (level 55) in the ledger room makes Briar cower
  *before* the reveal (foreshadowing); `FearEmitter` ramps the dread stem by
  proximity to the ledger (pure curve unit-tested); one stinger reserved for the
  turn.
- **New assets** (graybox placeholders): `briar_seek.wav`, `hollow_house_floor`,
  `gate_panel`, `clue_glint`, `hollow_house_ledger` icon + ItemDef, the
  `hollow_house_book.dialogue` balloon.

> **F5 checks the human must do** (agents are runtime-blind): Briar-seek cue
> readability (does she clearly lead? does recall-C re-point?), the dread ramp
> into the ledger room, stinger timing on the reveal, and end-to-end traversal
> (hub → witness 2 signs → scratch the gate → seek/dig the ledger → recontext).
> **Art is graybox** — real interior tiles/props + a real `seek_tell` animation
> and `briar_seek` bark are the PixelLab/ElevenLabs pass.

## Built — pass 2 (2026-06-19, branch `feature/hollow-house-microquest`)
Wired the (previously unreachable) house into the world as a playable loop and
took the **key-item HYBRID** at a human fork — see
[[decisions/2026-06-19-hollow-house-key-gate-hybrid]]. **This supersedes the
pass-1 "stuck door Briar scratches open / not a key-hunt" gate above**; the
recontext beat stays knowledge-gated (the key gates *access*, the doom-signal
threshold still gates the *truth*).
- **Entrance**: `DoorTransition` off `village_green` (`BldCotL`) +
  `spawn_from_hollow_house` return; hall `ExitDoor` repointed to the green.
- **Key gate**: `DoorTransition.unlock_item_id` + persistent `unlock_flag` +
  `consume_key_on_unlock`, pure static `compute_locked()`. Buried-key
  `DiggableSpot` (`dig_item=&"hollow_key"`) in the hall; Briar's scent-growl/seek
  targets it. The key is spent on first unlock; the flag keeps the door open.
- **Book → back nook** (`hollow_house_back.tscn`): the ledger is a new
  `SearchableClue` INTERACT one-shot; reading it writes LORE + drives
  `HollowHouseQuest.try_fire` (still needs ≥2 `sign_hollow_*` DOOM). The hall
  quest node is the cross-scene safety-net; `RecontextDrawing` moved to the hall
  so the space reframes on exit.
- **New asset**: `hollow_key` ItemDef ("Tarnished Key", consumed) + PixelLab
  sprite (low top-down, 32px).
- Suite **275 green**; check-brain green. Removed: `GatedDoor` node, hall
  `Ledger`/`FearEmitter`/`DeepDread` (book moved; nook carries dread).

## Out of scope (defer)
Age-progression/long-arc systems, new mechanics, the zone-wide art pass (Phase 3,
after playtest validates the beats), and any "detective vision" sense (ideas
inbox — only if playtests show players hard-stuck).

## Related
[[mechanics/accessible-interiors]] · [[design/secrets-and-discovery]] · [[mechanics/companion-pointer]] · [[mechanics/zone-recontextualization]] · [[mechanics/hollowing-clock]] · [[mechanics/encounters-mercy]] · [[decisions/2026-06-13-next-phase-hollow-house-slice]] · [[story/bible]]
