---
name: Transferable features from Zelda A Link to the Past, Terranigma, Secret of Mana and Secret of Evermore
date: 2026-06-20
date_source: 2026-06-20
source: Grok web_search + game design analysis
prompt: what features of zelda (a link to the past), terranigma, secret of mana and secret of evermore could benefit my game?
status: integrated
integrated: 2026-06-20 (branch docs/research-snes-features) — design directions; see integration log at foot
---

# Research: Transferable Mechanics from SNES Classics (ALttP, Terranigma, Secret of Mana, Secret of Evermore)

**Filter applied**: Every suggestion below was checked against "does it serve story, a companion arc, a horror beat, or replay value?" and mapped only to existing locked systems (GameEvents, PlayerData age/morality/companions, DreadManager, HollowingClock, VillageState suspicion/routines, ZoneManager + zone recontextualization, Dialogue Manager balloons, companion bond/corruption, mercy/soothe combat, SaveManager, adaptive audio stems). Guardrails respected: no procedural NPC/nemesis systems, no radial emotion-mapped dialogue wheels. No reuse of cozy mechanics.

Reliability: Web-checked details marked [verified 2026-06-20]. General design knowledge [training knowledge].

## 1. Parallel Worlds / Recontextualization (from A Link to the Past) [verified 2026-06-20]

**Feature**: The Light World and Dark World share the same geography but exist in altered states. Returning to a familiar location in the "wrong" state creates powerful recontextualization — what was safe is now corrupted or twisted. The Magic Mirror enables switching, and many dungeons/overworld secrets only exist or behave differently in one world. Environmental storytelling and player realization drive the experience.

**Why it fits Cycle of Innocence**:
- Directly supports ZoneManager + zone recontextualization (already planned as load-bearing).
- Serves **story** (the "delayed alarm" conspiracy and revelations about what the ritual actually did) and **horror beat** (uncanny wrongness in the village/playground the player already knows — toys that move wrong, familiar paths now dangerous).
- Excellent for **replay**: different morality or companion bond states could unlock different "layers" of the same zone or change what recontext moments appear.

**How to stand on existing systems**:
- Extend ZoneManager to support multiple authored states per zone (e.g. "normal", "escalating dread", "post-revelation").
- Tie state changes to PlayerData morality or specific companion events rather than a global switch.
- Use Dialogue Manager balloons for the "this place feels wrong now" realizations.
- DreadManager sources can be stronger or new in corrupted states.
- VillageState suspicion/routines can shift visibly when re-entering a zone in a new state.

**Recommendation**: High priority. This is one of the strongest matches. Pilot one zone (e.g. village green or Hollow House) with a subtle recontext trigger tied to the first major morality choice or Briar bond moment. Avoid full parallel dimension tech; keep it authored state flips for performance on Web.

## 2. Dog Companion Depth & Contextual Assists (from Secret of Evermore) [verified 2026-06-20]

**Feature**: The protagonist has a loyal dog that fights alongside (bite/claw attacks, gains aptitude/charged attacks as it "levels"), can be directly controlled (switch with Select), and has a unique utility: sniff for hidden alchemy ingredients when commanded. The dog changes form and abilities across different "worlds"/regions. It provides both combat support and exploration utility. The relationship feels personal.

**Why it fits Cycle of Innocence**:
- Briar is already the emotional heart companion (hound). This maps almost 1:1 to **companion arc** and **horror beat** (corruption variants could make Briar' s form or behavior subtly wrong/horrific).
- Serves **replay** (high bond = better/more reliable assists and reveals; low bond or corruption = fearful or unpredictable Briar).
- Dig assist already planned; sniffing/reveal hidden story elements or ingredients for rituals fits exploration without grind.

**How to stand on existing systems**:
- LimboAI behavior trees for Briar' s states (follow, assist/dig, fear, bark-reveal, corrupted variant).
- PlayerData.companions[briar] bond/corruption values drive which behaviors or new contextual actions unlock.
- DreadManager can modulate Briar' s fear responses or make corruption visible (glowing eyes, wrong movements).
- GameEvents for contextual triggers ("near diggable spot" or "hidden story echo nearby").
- No need for full control switch unless it adds to horror (e.g. temporary loss of control during high dread).

**Recommendation**: Very high priority. This strengthens the core companion fantasy more than almost anything else. Start with bond-level unlocks for Briar' s dig/bark utility and subtle corruption visual/behavior hooks. Document in characters/companions.md and mechanics/encounters-mercy or horror-and-dread.

## 3. Authored World/Town Impact Through Player Actions (from Terranigma) [verified 2026-06-20]

**Feature**: Player actions (delivering items, knowledge, or making specific choices) cause towns and the world to literally grow, change, or "resurrect" in authored ways. Towns evolve across chapters; trade routes open, buildings appear, NPCs react differently. It creates a living world feeling without being fully procedural. Strong emotional payoff as the player sees the consequences of their journey.

**Why it fits Cycle of Innocence**:
- Avoids procedural NPC systems (guardrail). Instead, use **authored** evolution of VillageState suspicion/routines and ZoneManager recontext events.
- Serves **story** (the conspiracy or "hollowing" spreading or being pushed back based on player morality and companion bonds) and **replay** (different paths produce different village end-states or available dialogues/endings).
- Horror angle: player actions could accidentally accelerate the wrongness (e.g. a choice that "feeds" the conspiracy) or help contain it.

**How to stand on existing systems**:
- VillageState already tracks suspicion/routines — extend with authored "chapter" or "escalation" flags tied to PlayerData morality and specific companion events.
- ZoneManager recontext moments can be gated or altered by these flags (e.g. new gossip or ritual remnants appear only after certain actions).
- Dialogue Manager balloons deliver the "the village feels different now" beats.
- SaveManager persists the state for NG+ and replay.
- HollowingClock or DreadManager can drive slow global escalation that player choices modulate.

**Recommendation**: Strong. This gives weight to choices without needing new systems. Implement as small authored state machines in VillageState for the first zones, triggered by the existing morality/bond changes. Flag in decisions if it risks feeling like town-building; keep it subtle horror-tinged evolution.

## 4. Companion Aptitude / Bond-Driven Ability Growth (from Secret of Mana & Evermore) [verified 2026-06-20]

**Feature**: In both games companions (or the dog) improve through use or story progress — weapons/aptitude level up, new charged attacks or abilities unlock. In Evermore the dog specifically gains power and utility. Not generic grinding; tied to the journey.

**Why it fits Cycle of Innocence**:
- Perfect for **companion arc** (Briar, Echo, Storm each could have their own bond-driven growth arcs) and **replay** (high bond paths unlock unique assists or story moments).
- Avoids generic party systems; keep authored per-companion.

**How to stand on existing systems**:
- PlayerData.companions[ name ].bond and .corruption drive unlocks (new LimboAI states or contextual actions).
- GameEvents signal when a new assist becomes available.
- Can tie into mercy/soothe combat (stronger soothe from high-bond companion) or DreadManager (corrupted companion adds new dread sources or helps resist).

**Recommendation**: High. Combine with #2 (Evermore dog). Define 2–3 bond thresholds per companion with clear gameplay/story payoffs. Keep implementation lightweight on LimboAI + PlayerData.

## Items flagged or lower priority

**Secret of Mana Ring Command Menu** [verified 2026-06-20]:
- Innovative radial ring for weapons/items/magic in real-time combat.
- **Flagged**: Radial menu structure risks overlapping with BioWare patent guardrail on radial emotion-mapped dialogue wheels (even if this is command, not emotion). Also adds menu complexity that may hurt horror immersion and Web performance.
- **Recommendation**: Do not port the ring system. Use context-sensitive actions (already planned for companion assists), hotkeys, or simple Dialogue Manager extensions for any choice-heavy moments. If a menu is needed, keep it linear/list-based.

**Traditional Zelda dungeon item progression & heavy key hunting**:
- Finding a dungeon-specific item that then has overworld utility.
- **Flagged / partial**: Heavy key/item hunting can slow pacing and pull focus from horror/conspiracy beats. The recontext and environmental puzzle aspects are stronger than the item gates.
- **Recommendation**: Use very selectively — perhaps one or two "revelation keys" or companion-assisted environmental solves that unlock new recontext or dialogue branches. Avoid full traditional dungeon key loops.

**Alchemy crafting from Evermore**:
- Combining found ingredients for spells/effects (exploration + dog sniff utility makes collecting meaningful).
- **Partial fit**: Could reframe as "ritual fragments" or "conspiracy echoes" collected during exploration, used for special mercy/soothe effects or temporary dread resistance. Stands on inventory + ZoneManager exploration.
- **Flagged if**: Becomes grindy or menu-heavy. Only pursue if it directly serves a horror beat or story revelation (e.g. crafting a "soothe" that reveals hidden truth).
- **Recommendation**: Low priority for now. The companion sniff/assist utility (#2) is the higher-value part of Evermore. Revisit only if inventory/Journal systems are expanded for story items.

## Overall Clear Recommendation

The strongest, highest-fit features that survive the filter and map cleanly to locked systems are:

1. **Parallel/recontext state layers** (ALttP) on ZoneManager + VillageState — for story revelations and horror uncanny beats.
2. **Deep dog companion utility + bond-driven behaviors** (Secret of Evermore) on PlayerData bond/corruption + LimboAI + DreadManager — core companion arc and horror potential.
3. **Authored world impact on village/town state** (Terranigma) on VillageState + ZoneManager recontext — gives choices weight and replay without procedural systems.
4. **Bond/aptitude growth for companions** (Mana/Evermore) — extends #2 and #3.

These four directly amplify the existing architecture (especially companion bond/corruption, ZoneManager recontext, VillageState, DreadManager) and serve story, companion arcs, horror beats, and replay. They do not require new locked tech, do not violate guardrails, and fit the 32×32 pixel top-down horror tone.

**Suggested next actions for librarian integration**:
- Add the recontext state idea to docs/mechanics/zone-recontextualization.md or a new decision if it reopens anything.
- Expand characters/companions.md and mechanics/horror-and-dread.md with the Evermore-style Briar utility and corruption hooks.
- Update VillageState spec in docs/mechanics/ or design/ with authored evolution examples tied to morality.
- Prioritize in post-slice queue after vision-cone and Hollow House authoring.

This research is ready for librarian pass. Conflicting or low-fit ideas (ring menu, heavy key hunting) are flagged above and should stay in ideas.md rejected if not useful.

[End of research file — status: inbox]

---

## Librarian integration log (2026-06-20, branch `docs/research-snes-features`)

Processed per `docs/research/README.md` (propose-first). These are **design
directions to consider later, not decisions** — and all four strong ideas
*amplify systems we already have* (zone recontextualization, companion bond/
corruption, VillageState). Nothing reopens a locked decision; the research
itself respected the patent guardrails (it flagged the ring menu). Human ruling:
**ideas inbox + short pointer notes in the matching design docs.**

- **`docs/ideas.md`** — captured the four strong directions (recontext state
  layers · Evermore-style Briar depth · Terranigma authored village evolution ·
  bond-threshold companion growth) with the "after the current slice" priority,
  plus the three skip/careful items (ring menu = don't; key-hunting = sparingly;
  alchemy = low priority/reframe as ritual fragments).
- **Short "future direction" pointer notes** added to the matching docs:
  [[mechanics/zone-recontextualization]] (state layers), [[characters/companions]]
  (Briar depth + bond growth), [[mechanics/horror-and-dread]] (corrupted-companion
  dread + "same place, wrong now"), [[mechanics/village-life]] (authored evolution).
- Not promoted to decisions/mechanics specs — that's design work for when a
  direction is actually picked up.