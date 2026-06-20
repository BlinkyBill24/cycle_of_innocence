---
name: ausruestung-equipment-system-research
date: 2026-06-20
source: Claude Opus 4.8 + extended web research
prompt: >
  How to implement an equipment system ("Ausrüstung" — armor/weapons/items, found or
  bought, that get stronger as the game progresses) for Cycle of Innocence (Godot 4.4,
  typed GDScript, 32×32 pixel art, Dialogue Manager + LimboAI, Web hard constraint / no C#).
  Locked decisions: MEDIUM stat weight (real but modest, respects mercy/soothe combat);
  TIERED REPLACEMENTS (find/buy better authored, hand-placed versions — not procedural,
  not a single item that levels up); DIEGETIC merchant that reacts to morality and
  dread/suspicion. Reference games: Zelda (ALttP), Terranigma, Secret of Evermore,
  Secret of Mana; plus RE4 merchant, Pathologic 2, Undertale for diegetic/reactive shops.
  Deliver simplest-first implementation approaches for a solo beginner; how to gate tiers;
  how to show "you got stronger" with NO numeric HUD; reactive-merchant patterns + failure
  cautions; gear that supports mercy/soothe not just damage; minimal 32×32 inventory UI for
  touch/web/desktop; plain-language data architecture mapped onto existing systems; apply
  the story/companion/horror/replay filter and flag failures. Honor guardrails (no
  nemesis/procedural-NPC, no radial dialogue wheel, no cozy-mechanic reuse, child
  protagonist, Web-safe).
status: integrated
integrated: 2026-06-20 (branch docs/research-equipment-system) — distilled into a mechanics spec; see integration log at foot
---

# Ausrüstung (Equipment) System — Design Research

## What this is

How to add gear — tools/weapons, garments/armor, and keepsakes — that the player can **find or buy**, that comes in a few **hand-made tiers** (better versions over time), and that is sold by a **merchant who is a real character in the world** and reacts to how the player is doing. Built to fit the mercy/soothe combat and the horror tone, on top of systems you already have.

## The short version (what to do)

- Build it on your **existing item system**. Add a few fields to your item template (ItemDef = your "item recipe" resource) so an item can be equipment: which slot it fills, which tier it is, and a small stat effect. `[training knowledge]`
- Keep gear **authored and hand-placed**, with only a **few tiers** per slot (about three). Each new tier is a memorable story moment, not a grind. This is the Zelda way, and it suits you better than a shop-grinding economy. `[training knowledge]`
- Gate tiers mainly by **story beats and where the player can go**, with the merchant as a secondary path. `[training knowledge]`
- Show "you got stronger" through the **world and feel**, never numbers: the gear changes how the child looks, old enemies feel manageable, the Journal records it, companions react. `[training knowledge]`
- Make gear that supports **calming/soothing and defense**, not just hitting things. This is the part that keeps the feature true to your game. `[training knowledge]`
- Keep the inventory screen **tiny**: about three equip slots plus a small consumables area, big tap targets for phone. `[training knowledge]`

**Recommendation:** the smallest design that satisfies your three locked choices (medium / tiered / diegetic) is: extend your item template, hand-place ~3 tiers per slot tied to story-and-zone beats, and add one recurring merchant character who reacts to morality and dread. Avoid shop-grinding and stat screens. Build it in small phases (below).

---

## 1 — What each reference game teaches

- **Zelda: A Link to the Past** — gear comes in a few set tiers you earn at big moments (the sword and armor each upgrade a couple of times through the story and exploration, not by shopping). Each upgrade is a discrete, memorable event. **Take this:** few tiers, hand-placed, tied to story/exploration milestones. `[verified 2026-06-20]`
- **Terranigma** — shops in each new town sell stronger gear, so your power is gated by *where you can travel* plus money. **Take this:** if you use the merchant for tiers, let the stock grow as the player reaches new areas, rather than letting them buy everything early. `[verified 2026-06-20]`
- **Secret of Mana** — weapons get stronger when you find an upgrade item (an "orb") and bring it to a smith who applies it. **Take this:** "find a special item → an NPC makes your gear better" is a clean, diegetic way to gate an upgrade behind exploration instead of money. (Note: this is closer to *upgrading one item* than *replacing it with a new tier* — useful as a feel reference, not a model to copy whole, since you chose tiered replacements.) `[verified 2026-06-20]`
- **Secret of Evermore** — uses a trading/bartering economy where the "currency" differs by region. **Take this (carefully):** a region-specific economy is atmospheric but complex; likely more than you need as a beginner. Flagged as optional. `[verified 2026-06-20]`
- **Resident Evil 4 — the Merchant** — the famous diegetic merchant: he appears in the world, has a voice and personality, travels, sells and buys. He is a *character*, not a menu. **Take this:** one recurring, characterful merchant who lives in the world. `[verified 2026-06-20]`
- **Pathologic 2** — the town's economy reacts to the worsening situation: scarcity rises, prices climb, bartering shifts as the world deteriorates. **Take this:** an economy that responds to your rising dread/suspicion. This is your strongest reference for "stock and prices shift with the horror." `[verified 2026-06-20]`
- **Undertale** — shopkeepers notice your route (merciful vs. violent) and change how they talk and behave. **Take this:** the merchant reacts to the player's morality. `[verified 2026-06-20]`

---

## 2 — Tiers: how to gate them, and how to show "you got stronger"

**How to gate the tiers**
- Mainly by **story beat** and **zone access** (Zelda/Terranigma), not by money. `[training knowledge]`
- Use the **"found upgrade + NPC applies it"** trick for some upgrades, so exploration is rewarded (Secret of Mana feel). `[training knowledge]`
- Keep it to **~3 tiers per slot**. More than that becomes a grind and starts to fail the filter. `[training knowledge]`

**How to say "you got stronger" with no numbers on screen** (your game is strictly diegetic — no markers, no stat HUD):
- **Looks:** the new gear visibly changes the child's sprite. The player *sees* the change. `[training knowledge]`
- **Feel:** an enemy that used to be scary is now manageable. Lean on your **ZoneManager recontextualization** so old encounters read differently after an upgrade. This is the most honest "you got stronger" signal. `[training knowledge]`
- **Record:** a **witnessed Journal** entry marks the acquisition ("I have this now"). `[training knowledge]`
- **Companions:** Briar/Echo/etc. react to the new item via the **bond system**. `[training knowledge]`
- **Sound:** a small **adaptive-audio** stem shift when equipped or first used. `[training knowledge]`
- **Avoid:** floating "+5 attack", number tooltips, a stats page. These break the diegetic rule. `[training knowledge]`

---

## 3 — The merchant: diegetic and reactive

**Make it a character, not a menu**
- One recurring merchant who exists in the world (RE4 model). Buying happens **inside conversation** (Dialogue Manager balloons) or a simple in-world panel — not an abstract shop grid. `[training knowledge]`

**Make stock and prices react**
- **To morality** (PlayerData): the merchant warms or cools, comments, and offers different things depending on how the child has been behaving (Undertale model). `[training knowledge]`
- **To dread/suspicion** (DreadManager, HollowingClock, VillageState): as the world worsens, prices rise, stock thins, and the merchant grows uneasy or changes (Pathologic 2 model). `[training knowledge]`

**What makes diegetic shops fail (cautions)**
- Wrapping a gamey grid menu in one line of dialogue still feels like a menu. Keep the *interaction* in-world. `[training knowledge]`
- Reactive prices that punish the player without explanation feel unfair. Always **say why** through the merchant ("Things cost more now. People are frightened."). `[training knowledge]`
- A merchant who sells raw power on demand quietly kills your scarcity and dread. Keep stock limited and meaningful. `[training knowledge]`

---

## 4 — Gear that fits mercy/soothe combat (the identity part)

This is the most important section for keeping the feature *yours*. Gear should help the player **calm, defend, and explore**, not only fight. `[training knowledge]`

- **"Weapons" as a child's tools:** a bell, a small instrument, a lantern, a slingshot, a noisemaker — things that **soothe or distract** rather than kill. Tonally right for a child protagonist. `[training knowledge]`
- **Soothe-boosting gear:** items that make calming faster or more effective, or that reach more enemies. `[training knowledge]`
- **Resilience gear:** garments/keepsakes that improve **defense** or **resistance to dread** (for example, something that eases the HollowingClock's pressure). `[training knowledge]`
- **Utility gear:** items that open optional paths or reveal secrets (feeds exploration and replay), or that **strengthen a companion bond**. `[training knowledge]`
- **Flag / use sparingly:** pure damage-max weapons with no soothing or utility angle. They pull the game toward the brutal-combat lane you're deliberately avoiding. `[training knowledge]`

---

## 5 — Inventory & equipment screen (small, touch-first)

- **About three equip slots:** tool/weapon, garment/armor, keepsake/accessory. Plus a small **consumables** area. `[training knowledge]`
- **Equipping:** tap (or click) an item to put it in its slot. Show clearly what is equipped. `[training knowledge]`
- **Touch-first:** big tap targets, few items on screen, no tiny drag-and-drop. If it works on a phone, it works on web and desktop too. `[training knowledge]`
- **Pixel-art-friendly:** chunky frames, one clear icon per item, readable at small size. `[training knowledge]`

---

## 6 — How it sits on what you already have

Stands on these existing systems (nothing new and exotic required):
- **ItemDef + inventory** — extend the item template so an item can be equipment. `[training knowledge]`
- **GameEvents bus** (your central "announcement" system) — fire a signal when something is equipped or acquired. `[training knowledge]`
- **PlayerData** — holds what's equipped; morality drives the merchant. `[training knowledge]`
- **mercy/soothe combat** — reads the small stat effects from equipped gear. `[training knowledge]`
- **ZoneManager** — gates tiers by area, and makes old enemies feel different after an upgrade. `[training knowledge]`
- **DreadManager / HollowingClock / VillageState** — drive the merchant's reactive stock and prices. `[training knowledge]`
- **Dialogue Manager** — the merchant's conversations and buying. `[training knowledge]`
- **companion bond/corruption** — companion reactions to gear. `[training knowledge]`
- **SaveManager** — remembers owned/equipped gear and which tiers are unlocked. `[training knowledge]`
- **adaptive audio** — a stem shift on equip/use. `[training knowledge]`
- **witnessed Journal** — records acquisitions diegetically. `[training knowledge]`

New data you'd add: a few fields on the item template (slot, tier, small stat effect, whether it's found/bought), a small "what's equipped" record on PlayerData, and merchant stock lists keyed to morality and dread. `[training knowledge]`

---

## 7 — Does it pass the filter?

- **Story:** yes — each tier is an authored beat; the merchant is a character. `[training knowledge]`
- **Companion arc:** yes — companions react to gear; bond-boosting keepsakes. `[training knowledge]`
- **Horror beat:** yes — the merchant and prices respond to dread; gear interacts with the HollowingClock. `[training knowledge]`
- **Replay:** yes — zone-recontextualized gear, optional utility items, and an NG+ angle. `[training knowledge]`
- **Flag / avoid:** stat-grinding for its own sake; a numeric HUD or tooltips; pure damage weapons; a gamey storefront; opaque or punishing reactive prices. `[training knowledge]`

---

## 8 — Recommended build order (small phases)

1. **Make gear exist.** Extend the item template, add the equip slots to PlayerData, build the tiny equip screen, and wire **one** found tool that changes combat. (Smallest end-to-end slice.) `[training knowledge]`
2. **Add tiers.** Author 2–3 tiers for one slot, gated by a story/zone beat. Make getting one a **Journal moment** plus one diegetic "stronger" cue (sprite change, or old enemies feeling easier). `[training knowledge]`
3. **Add the merchant.** One recurring character via Dialogue Manager, selling a few items in conversation. `[training knowledge]`
4. **Make the merchant react.** Stock/prices shift with morality (Undertale) and with dread/suspicion (Pathologic 2). `[training knowledge]`
5. **Add identity gear + polish.** Soothe/utility gear lines, companion reactions, audio stem shifts, and touch-UI polish. `[training knowledge]`

Throughout: **don't add a tier or a slot you don't have authored content for.** (Same content-first rule the project already runs on.) `[training knowledge]`

---

## 9 — If something starts going wrong (course corrections)

- Equipping feels like spreadsheet optimization → cut stat detail, push toward soothe/utility/identity gear. `[training knowledge]`
- The merchant feels like a vending machine → stronger dialogue, more scarcity, more reactivity. `[training knowledge]`
- "You got stronger" isn't landing → lean harder on enemies *feeling* different (recontextualization) over any other cue. `[training knowledge]`
- Saves break across versions → make sure you're saving item **IDs**, not whole item objects (see Details). `[training knowledge]`
- A tier has no story reason to exist → cut it. `[training knowledge]`

---

## Details (optional, technical — skip unless you want the data picture)

- **Item template (ItemDef) additions:** exported fields for `slot` (a fixed list: tool/garment/keepsake), `tier` (a small number), `modifiers` (a small set like attack / defense / soothe / dread-resist), and `source` (found / bought / both). Keep the modifier numbers **small** to honour the "medium" decision. `[training knowledge]`
- **What's equipped:** PlayerData keeps a simple map of slot → item ID. Combat reads the modifiers from whatever IDs are equipped. `[training knowledge]`
- **Merchant stock:** small data tables keyed by morality band and dread/suspicion level; when the conversation opens, the merchant picks the right stock list for the current state. `[training knowledge]`
- **Saving (important):** store equipped IDs, owned IDs, and tier-unlock flags as **plain text/number IDs**, not as saved Godot Resource objects. On load, rebuild the items by looking those IDs up in your item database. IDs survive game updates and the Web export far better than serialized objects. `[training knowledge]`
- **Web-safe:** all of this is ordinary GDScript and resources — no threads, no C#. Fine for the Web target. `[training knowledge]`

---

## Caveats

- **Reliability markers:** `[verified 2026-06-20]` = a factual claim about how a reference game works, examined during the research pass; the actual source links live in the research artifact this file was distilled from — attach or reconfirm them when filing. `[training knowledge]` = design synthesis, system-mapping, and recommendations (reasoning, not a cited fact).
- **Single research pass, no second model** — so nothing is marked `[cross-model]`.
- **No invented sources here.** This inbox file was distilled from the completed research output; the full per-source citation list is in that artifact, not re-listed in-line.
- **Reconfirm specifics:** exact tier names/counts and exact merchant behaviours in the reference games vary by version/region. The descriptions are accurate as general knowledge; check a primary source before treating any precise detail as fact.
- **Frontmatter judgment calls:** `date` is the date produced; `name` and `source` are defaults — rename on filing if the vault uses a different convention.
- **Guardrails honoured:** no nemesis/procedural-NPC system, no radial emotion-dialogue wheel, no reuse of earlier cozy-game mechanics; child-protagonist tone kept (gear reads as a child's tools); Web-safe throughout. Locked stack and recorded decisions treated as locked.

---

## Librarian integration log (2026-06-20, branch `docs/research-equipment-system`)

Processed per `docs/research/README.md` (propose-first). This is a **buildable
feature design**, not just inspiration. Found: the three "core choices" the
prompt calls locked (MEDIUM stat weight · TIERED hand-placed replacements ·
DIEGETIC reactive merchant) were **not recorded anywhere** in the vault, and the
current item system has no equipment fields and no merchant. So this is a
net-new feature, designed to sit on existing systems; it respects the diegetic/
no-numbers style and the guardrails (it flags pure-damage gear + gamey shops).
Human ruling: capture as a **living mechanics design doc**.

- **`docs/mechanics/equipment.md`** (new) — distilled feature spec: the three
  core choices, the "show strength without numbers" approach, the diegetic
  reactive merchant, mercy/soothe-fitting gear, the tiny touch-first UI, the data
  additions (ItemDef fields, a PlayerData equipped map, merchant stock tables,
  **save by ID not by Resource object**), the 5-phase build order, and the
  filter/guardrail check. Full per-source detail stays in THIS filed research.
- **`docs/ideas.md`** — queued the build (post-slice, content-gated) + pointer.
- **Pointer notes** added to [[mechanics/inventory]] (equipment is a layer on it)
  and [[mechanics/combat]] (gear feeds mercy/soothe, not just damage).
- Not promoted to a `decisions/` record (human chose the living-doc form); the
  three core choices are recorded in the mechanics doc as the working design.
