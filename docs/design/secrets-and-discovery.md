---
name: Secrets & Discovery Design
date: 2026-06-13
tags: [design, secrets, discovery, exploration, replay]
status: draft
related: "[[mechanics/zone-recontextualization]] · [[mechanics/encounters-mercy]] · [[mechanics/progression]] · [[characters/companions]] · [[playtest/2026-06/synthesis]]"
source: "[[research/done/2026-06-13-secrets-discovery-design]] (R7 bridge)"
---

# Secrets & Discovery Design

The **secrets** pillar of the locked next arc (*early-game authored beat + doom
signals + secrets*), which the [[playtest/2026-06/synthesis]] identified after
4/4 testers said "not enough action or secrets." This is the actionable spec;
full sourcing in [[research/done/2026-06-13-secrets-discovery-design]].

> Reliability markers preserved from the source: `[verified 2026-06-13]` =
> checked against a citable source this session; `[training knowledge]` =
> unverified; weak claims flagged inline.

## The model: knowledge-as-key, not item-keys

The games that make discovery feel *earned* gate progress on what the **player**
understands, not on items: Outer Wilds (knowledge becomes the upgrades), Void
Stranger (new knowledge recontextualizes already-visited floors — the closest
shipped analogue to our ZoneManager recontext spine), Tunic, Obra Dinn, Lorelei.
`[verified 2026-06-13]` This is the project's **biggest discovery-design
advantage**: the recontext spine already IS this pattern. The reward is the
knowledge itself — the playground flipping safety→horror→grief is the payoff, no
item required.

The early-game "drought" is a **density + signposting** problem, not a
content-count problem. A few high-signal early secrets — each serving story, a
companion arc, OR a horror beat, surface-readable on run 1 and recontextualized
on replay/NG+ — beats a long list. `[verified 2026-06-13]`

## Binding rules (enforce on every secret we author)

1. **No-wiki rule.** Every secret's key knowledge must be learnable *inside* the
   game. No brute-force/ARG dependency on the critical path. Fez's "Black
   Monolith" needed an external website — the cautionary tale; Lorelei keeps all
   knowledge in-game and randomizes solutions so guides don't work. `[verified 2026-06-13]`
2. **No collectible checklist.** Vacuuming busywork serves none of the four
   pillars (story / companion arc / horror beat / replay). `[verified 2026-06-13]`
3. **Journal is a memory aid, never a quest log.** It records what the player
   *witnessed*, never a to-do list — the Outer Wilds ship-log / Obra Dinn
   logbook line. Already half-stated in [[mechanics/progression]]; hold it.
   `[verified 2026-06-13]`
4. **Nothing story-critical is permanently missable.** Documented quit-trigger
   for single-playthrough RPG players; lore stays re-findable or NG+-surfaced.
   `[verified 2026-06-13]`

Plus the existing guarantee, now sourced: **critical path never requires
combat** (Crow Country ships a combat-free Exploration Mode; mercy/stealth always
viable). `[verified 2026-06-13]`

## Telegraphing that a secret EXISTS (without spoiling it)

Plant a "there's more here" prime early. Tunic's untranslated runic language
signals a hidden layer outside the player's grasp; the Zelda-1 "every bush could
be a secret" feeling; the affordance trick of showing an unreachable area keyed
to a tool you don't have yet. `[verified 2026-06-13]` Our telegraph is
**ritual-symbol literacy** ([[mechanics/zone-recontextualization]]): illegible
cult symbols early, legible late — so the replay reads as dread.

**Pitfall:** don't *pre-explain* puzzles in foreshadowing (Crow Country) —
prime curiosity without spelling out the solution. `[verified 2026-06-13]`

## Early playground "thesis" zone — authored priority list

The first 10–20 min is the dense thesis node: 2–3 immediately discoverable
surface secrets, each promising "more here." Ordered by leverage given the
synthesis's density verdict.

1. **Briar dig-to-lore spot** — companion arc + story + replay. Briar whines at
   disturbed ground → dig → buried toy = lore fragment; recontextualizes
   post-revelation/NG+ as a specific child's. Hits the cross-use rule (dig =
   puzzle + combat interrupt + lore) + Fable II precedent + second-read.
   **Highest priority.** ✅ **v1 built 2026-06-13** (`feature/journal-and-dig-lore`):
   `DiggableSpot` gained a `lore_text` payload that writes a witnessed Journal
   entry; the playground's three dig spots author specific lost-children
   fragments (the rabbit "Mara — Harmony 71", the too-small shoe, the warm
   wooden duck at the keepsake). NG+ recontextualization still to author.
2. **One illegible cult symbol, placed prominently** — story + replay + horror.
   Cheapest high-leverage "more here"; becomes legible late via symbol literacy.
3. **Companion-gaze signpost to a recontext node** — companion arc + horror.
   Echo circles / Storm balks near the feature that will flip safety→horror. No
   UI marker; animal-imperfect (see [[characters/companions]]).
4. **Stilled-monster-leads-to-keepsake** — story + companion + horror + replay.
   ⚠️ **Mechanism already implemented** ([[mechanics/encounters-mercy]]) — the
   research's "prototype now" is stale, BUT its real point stands: this is a
   **novel mechanic with no shipped template** (Spiritfarer is the nearest
   analogue) and its **legibility is unproven** — no tester in the 4-session
   pass reached it. Validate "do they understand 'follow me'?" before scaling.
5. **One witnessed recontextualization beat + its first Journal entry** — story
   + replay. The player *sees* the playground flip; one diegetic "observed sign"
   fires. Thesis statement for the spine + proof-of-concept for the Journal.
   ✅ **Journal built 2026-06-13** (`Journal` autoload + `JournalPanel`, toggle
   J): witnessed-only, idempotent, save round-trips, LORE/DOOM kinds (the
   memory-aid-not-checklist rule enforced — no API to add an unwitnessed
   entry). Dig fragments fire LORE entries now; the **witnessed-recontext beat
   that fires a DOOM entry** is the remaining authoring step (pairs with the
   hollowing-clock doom-legibility roadmap).

## After the early arc proves out

- **"Three players at once" layering** (Animal Well): a clean critical path
  (Crow Country), an optional explorer layer, a reserved NG+/community layer.
  Density under constraint — north star "at any point, something you're
  wondering about." `[verified 2026-06-13]`
- **Obra-Dinn confirmation buffer** (confirm-in-threes) for any deduction-style
  cult secret, to block brute-force guessing. `[verified 2026-06-13]`
- **Second-read VillageState gossip** that reads differently once a revelation
  is known.

## Benchmarks that change the plan

- Still "early drought" after stage 1 → signposting/density problem; add
  telegraphs, tighten the first 10–15 min. **Do NOT add collectibles.**
- Stilled "follow me" reads as confusing → fall back to companion-modeled follow
  / clearer lead before scaling.
- Any secret needs a wiki/external tool → cut from critical path; optional
  community easter egg only.

## Caveats (from source)

Solo-dev authoring-cost risk: recontextualization at scale is expensive — Void
Stranger / Outer Wilds / Animal Well achieve it via small dense worlds, so scope
recontext nodes conservatively. Replay-value secrets assume players replay —
endings/morality/NG+ echoes must give a narrative reason or second-read secrets
go unseen. This is design-pattern analysis, not a guarantee; validate against
playtests, especially the novel mechanics.

## Related

[[research/done/2026-06-13-secrets-discovery-design]] ·
[[mechanics/zone-recontextualization]] · [[mechanics/encounters-mercy]] ·
[[mechanics/progression]] · [[characters/companions]] ·
[[mechanics/hollowing-clock]] (doom-legibility roadmap) ·
[[design/feature-candidates-2026-06]]
