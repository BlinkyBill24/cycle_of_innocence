---
name: Equipment (Ausrüstung)
date: 2026-06-20
tags: [mechanics, equipment, items, merchant, design, post-slice]
status: design (living spec) — not yet built
related:
  - "[[mechanics/inventory]]"
  - "[[mechanics/combat]]"
  - "[[mechanics/encounters-mercy]]"
  - "[[mechanics/zone-recontextualization]]"
  - "[[story/bible]]"
source: "[[research/done/2026-06-20-ausruestung-equipment-system-research]]"
---

# Equipment (Ausrüstung)

Gear — a child's **tools** (bell, lantern, slingshot, noisemaker), simple
**garments/keepsakes**, and a few **consumables** — that Rowan can **find or
buy**, in a handful of **hand-placed tiers**, sold by **one recurring merchant
who is a real character** and reacts to how the player is doing. It sits on the
existing item system and stays true to the mercy/soothe combat and horror tone.

## Core choices (working design — treat as locked unless revisited)
1. **Medium stat weight** — gear matters, but modestly. Numbers stay small so it
   never overshadows mercy/soothe. No spreadsheet optimisation.
2. **Tiered replacements, hand-placed** — about **3 tiers per slot**, each a
   memorable authored moment (the Zelda way). Not procedural, not one item that
   "levels up." Don't author a tier you have no story reason for.
3. **Diegetic, reactive merchant** — a character in the world (RE4 model), not a
   menu; buying happens inside conversation. Stock/prices react to **morality**
   (Undertale) and to **dread/suspicion** (Pathologic 2).

## Show "you got stronger" — without numbers (strict diegetic)
The game has no stat HUD, no `+5` tooltips, no stats page. Strength is felt, not read:
- **Looks** — new gear visibly changes the child's sprite.
- **Feel** — an enemy that used to be scary is now manageable; lean on
  [[mechanics/zone-recontextualization]] so old encounters read differently after
  an upgrade (the most honest "stronger" signal).
- **Record** — a witnessed [[mechanics/inventory]]/Journal entry marks the acquisition.
- **Companions** — Briar/Echo/Storm react via the bond system.
- **Sound** — a small adaptive-audio stem shift on equip/first use.

## Gear that fits mercy/soothe (the identity part)
Gear should help **calm, defend, and explore**, not only hit:
- **Tools, not weapons:** bell / instrument / lantern / slingshot / noisemaker —
  things that soothe or distract, tonally right for a child.
- **Soothe-boosting:** makes calming faster/stronger, or reaches more enemies.
- **Resilience:** garments/keepsakes that improve defense or ease the
  [[mechanics/hollowing-clock]]'s dread pressure.
- **Utility:** opens optional paths / reveals secrets / strengthens a companion bond.
- **Flag — use sparingly:** pure damage-max weapons with no soothe/utility angle
  (they pull toward the brutal-combat lane we avoid).

## The merchant — diegetic and reactive
- One recurring character (RE4). Buying happens in **Dialogue Manager** balloons
  or a simple in-world panel — never an abstract shop grid.
- **Reacts to morality** (PlayerData): warms/cools, comments, offers different stock.
- **Reacts to dread/suspicion** (DreadManager / HollowingClock / VillageState): as
  the world worsens, prices rise, stock thins, the merchant grows uneasy.
- **Failure cautions:** a grid menu wrapped in one dialogue line still feels like a
  menu — keep the interaction in-world; reactive prices must **say why** ("Things
  cost more now. People are frightened."); a merchant who sells raw power on demand
  kills scarcity and dread — keep stock limited and meaningful.

## Tiny, touch-first UI
~**3 equip slots** (tool/weapon · garment/armor · keepsake/accessory) + a small
consumables area. Tap an item to equip; show clearly what's equipped. Big tap
targets, few items on screen, no tiny drag-and-drop, chunky pixel frames. If it
works on a phone it works on web + desktop.

## How it sits on existing systems
ItemDef + inventory · GameEvents (equip/acquire signals) · PlayerData (what's
equipped; morality drives the merchant) · mercy/soothe combat (reads the small
modifiers) · ZoneManager (gates tiers by area; old enemies feel different) ·
DreadManager / HollowingClock / VillageState (merchant reactivity) · Dialogue
Manager (the merchant) · companion bond/corruption (reactions) · SaveManager
(owned/equipped/unlocked) · adaptive audio (stem shift) · witnessed Journal.

**New data to add** (all ordinary, Web-safe GDScript/resources — no threads, no C#):
- `ItemDef` exported fields: `slot` (tool/garment/keepsake), `tier` (small int),
  `modifiers` (small set: attack / defense / soothe / dread-resist — keep numbers
  small), `source` (found / bought / both).
- `PlayerData`: a simple `slot → item ID` equipped map; combat reads modifiers from
  equipped IDs.
- Merchant stock: small data tables keyed by morality band + dread/suspicion level.
- **Saving (important):** store equipped/owned/tier-unlock as **plain IDs**, not
  serialized Resource objects; rebuild items by looking IDs up. IDs survive game
  updates and the Web export far better.

## Build order (small phases — content-first)
1. **Make gear exist** — extend `ItemDef`, add equip slots to PlayerData, tiny equip
   screen, wire **one** found tool that changes combat (smallest end-to-end slice).
2. **Add tiers** — author 2–3 tiers for one slot, gated by a story/zone beat; make
   getting one a Journal moment + one diegetic "stronger" cue.
3. **Add the merchant** — one recurring character via Dialogue Manager, a few items.
4. **Make the merchant react** — stock/prices shift with morality + dread/suspicion.
5. **Identity gear + polish** — soothe/utility lines, companion reactions, audio
   stem shifts, touch-UI polish.

Rule: **don't add a tier or slot you don't have authored content for.**

## Filter & guardrails
Passes story (authored tiers; the merchant is a character) · companion (reactions;
bond keepsakes) · horror (merchant + prices respond to dread; gear eases the
HollowingClock) · replay (recontextualized gear, optional utility, NG+). **Avoid:**
stat-grinding, numeric HUD/tooltips, pure-damage weapons, a gamey storefront,
opaque/punishing prices. No nemesis/procedural-NPC, no radial dialogue wheel, child
tone kept, Web-safe.

> Sequenced **post-slice** (after vision-cone + Hollow House authoring). Full
> per-reference detail lives in the filed research
> [[research/done/2026-06-20-ausruestung-equipment-system-research]].
