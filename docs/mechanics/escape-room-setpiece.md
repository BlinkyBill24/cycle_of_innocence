---
name: Escape-Room Set-Piece (signature, one-off)
date: 2026-06-20
tags: [mechanics, set-piece, horror, companion, secrets, design, post-slice]
status: design (living spec) — not yet built
related:
  - "[[mechanics/zone-recontextualization]]"
  - "[[design/secrets-and-discovery]]"
  - "[[characters/companions]]"
  - "[[mechanics/hollowing-clock]]"
  - "[[mechanics/encounters-mercy]]"
  - "[[story/bible]]"
source: "[[research/done/2026-06-20-escape-room-set-piece-research]]"
---

# Escape-Room Set-Piece (signature, one-off)

**One** bespoke, hand-built locked room, placed at the moment the child uncovers
the rigged lottery. Solving the room **is** how the truth comes out. It does
three jobs at once — a locked-in horror beat, conspiracy lore revealed by solving,
and a companion-cooperation climax — and then it's over. **Not** a recurring
mechanic or a genre pillar.

## Verdict (working design — treat as locked unless revisited)
- **A single signature room, at the conspiracy reveal.** Yes to one; no to making
  escape-room puzzling recurring (that fights the exploration-horror-action
  identity and is a solo-dev time sink).
- **2–3 steps, each doing double/triple duty:** advance the puzzle, drip a piece of
  lore, and/or use the companion. One action, several payoffs.
- **Needs both child and companion** (the Brothers principle) — neither alone gets
  out. Use **one** companion (Briar the dog is the natural fit).
- **Diegetic only:** no markers, no numeric HUD, **no countdown timer**.

## How one room does all three jobs (without overload)
Layering — a single action pays off in more than one way. Illustrative shape (not fixed):
1. The room **seals** (seen + heard + a balloon line). Briar senses/finds something
   the child can't → first clue **and** first lore fragment.
2. The child combines/observes to open a way → second lore fragment, dread climbs.
3. The **truth clicks** (the rigging) → the exit opens → release.

## Companion-cooperation beat (the heart)
- Build so the room **requires** Briar; drive it with existing LimboAI behaviours +
  the bond system (her eagerness reflects bond/corruption).
- Per-companion flavours if ever reused: Briar dig/fetch/squeeze/scent · Echo
  fly/see-from-above/grab · Storm shove/reach-high.
- **Avoid the escort trap:** the companion step is player-triggered and clearly
  readable (an obvious "tell"), never a fragile follow-AI that fails silently.
  (Same legibility lesson as the navigation playtest.)

## Dread + "locked in" without a timer
- The lock-in lands: door shuts visibly/audibly, the space tightens, the child reacts.
- Pressure without a clock (Majora's / Amnesia): rising adaptive-audio stems, a
  threat that advances **in the world**, light/space changing, the **church bell**
  marking escalation. Let HollowingClock build mounting pressure + DreadManager
  raise the dread state.
- **Fair, not lethal:** looming dread, not death-by-timer (child protagonist + mercy ethos).

## Story by solving
- Each solved step writes a **witnessed Journal** entry — LORE as the truth
  surfaces, a DOOM entry as dread peaks. Objects + room changes carry the story
  (Gone Home / Edith Finch / BioShock environmental narrative). See
  [[design/secrets-and-discovery]].

## Fair with no HUD / no hint markers
- **Three-Clue Rule:** every critical step has ≥3 independent clues, so one missed
  object can't soft-lock understanding.
- **Escalating nudges:** if the player stalls, the world nudges harder (sound,
  light, the companion gestures); the companion-as-hint is re-triggerable.
- **Nothing missable / no hard dead-ends** (the established no-missable fallback).
- **Avoid:** moon-logic, pixel-hunting, unfair dead-ends, a timer UI, a fragile
  escort step, over-scoping into a dungeon.

## How it sits on existing systems
ZoneManager (lock-in: seal the zone, gate the exit until the "solved" flag flips) ·
GameEvents (step-solved signals) · DreadManager / HollowingClock (mounting dread) ·
Dialogue Manager (child + companion reactions, gentle hints) · witnessed Journal
(LORE/DOOM) · DiggableSpot (reuse for a Briar-dig step) · LimboAI + bond · inventory
+ ItemDef (found/combined items) · mercy/soothe combat (any threat is calmed/evaded,
not killed) · SaveManager · adaptive audio (stems rise, resolve on escape).

**New data is small:** a few "step solved" booleans + a "room sealed" flag + the
clue→lore links. **Save simple flags/IDs as true/false, not serialized Godot
objects** — they survive updates + the Web export far better; on load the room reads
the flags and restores its state. All ordinary GDScript/signals/resources — Web-safe.

## Build order (small phases)
1. **Empty sealed room** — enter → it locks (ZoneManager + balloon + sound) → one
   trivial exit trigger. Prove the lock-in-and-release loop.
2. **One companion step** — a single step that needs Briar (dig/point), wired to
   LimboAI + DiggableSpot, that writes one Journal LORE entry.
3. **The rest** — remaining 1–2 steps, dread escalation (HollowingClock/DreadManager
   + rising stems), the final truth reveal that opens the exit.
4. **Fairness + polish** — Three-Clue pass, companion nudges, no-dead-end check,
   save/load of step flags, audio resolve on escape.

Scope-cut signals: a step with no lore to carry → cut it; a fiddly-to-read companion
step → simplify the action; dread not landing → add audio + an advancing threat, not
more puzzle.

## Filter & guardrails
Story (it *is* the reveal, solved into) · companion (cooperative climax, deepens
bond) · horror (locked-in dread at the darkest moment) · replay (modest — a
one-off; NG+ can recontextualize its lore, don't force replay). **Avoid:** making
it recurring/a pillar; moon-logic; pixel-hunting; a timer UI; a fragile escort;
dungeon creep. No nemesis/procedural-NPC, no radial dialogue wheel, child tone, Web-safe.

> Sequenced **post-slice**. Full per-reference detail in the filed research
> [[research/done/2026-06-20-escape-room-set-piece-research]].
