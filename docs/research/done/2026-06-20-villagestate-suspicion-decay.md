---
name: VillageState suspicion decay mechanics investigation
date: 2026-06-20
source: Grok read of docs/mechanics/village-life.md + scripts/autoload/village_state.gd + hollowing-clock.md
prompt: Investigate VillageState suspicion decay mechanics
status: integrated
integrated: 2026-06-20 (branch docs/research-village-suspicion) — current system confirmed sound; one post-slice extension. See log at foot.
---

# VillageState Suspicion Decay — Investigation

**Current implementation (v1, shipped 2026-06-11)**

From `scripts/autoload/village_state.gd`:
- `const SUSPICION_DECAY_PER_PHASE := 0.7`
- On every `WorldState.time_changed` signal (phase advance: dawn/day/dusk/night):
  ```gdscript
  for npc_id in suspicion:
      suspicion[npc_id] = float(suspicion[npc_id]) * SUSPICION_DECAY_PER_PHASE

Raised via add_suspicion(npc_id, amount).
At ≥ SUSPICION_REPORT_THRESHOLD (100.0) and not yet reported: adds REPORT_ALARM_POINTS (25.0) to HollowingClock exactly once, emits villager_reported, and marks reported.
Eavesdropping multiplies notice rate ×2.5.
High suspicion changes gossip lines to more paranoid versions.

From docs/mechanics/village-life.md:

Suspicion per villager, raised by sightings, lowered by time.
Feeds Hollowing Clock “player noise” rule.
Part of authored routines + stage shifts (stage 2 adds search detail, stage 3 stops some schedules).

From docs/mechanics/hollowing-clock.md:

Alarm points from reported villagers advance stages early.
Mercy/stealth delays stages; loud/ruthless accelerates them.

Mapping to locked systems

VillageState suspicion/routines (core)
HollowingClock (direct feed via alarm points)
ZoneManager + zone recontextualization (routines resolve per zone and stage; empty benches = recontext horror)
DreadManager (can raise local dread in high-suspicion areas; Briar fear behavior)
PlayerData age/morality/companions + companion bond/corruption (currently unused — ideal hook)
GameEvents + Dialogue Manager (villager_reported signal, gossip balloons)
SaveManager (persists suspicion dict + reported list)

Filter result
Passes cleanly on story (delayed alarm via specific villagers talking), horror beat (net closing then loosening), and replay (stealth vs loud playstyles create different stage timings). Companion arc is the clearest missing link — easy to add via Briar reactions or bond-modulated decay.
Flagged
Nothing in current decay fails the filter. Any future move toward procedural NPC behavior or visible meters would fail and should be rejected.
Clear recommendation
Keep 0.7× multiplicative decay per phase as baseline (simple, gives breathing room, makes hiding/hideouts meaningful).
Extend post-slice by wiring PlayerData morality and companion bond:

Ruthless morality → slower decay (villagers stay paranoid).
High Briar bond → small zone decay bonus or one authored “distraction” per phase.
Use the already-noted Terranigma-authored evolution path (hand-written flags for suspicion/routines tied to morality/bonds) so it stays subtle horror.

This keeps decay on existing systems, serves all four criteria, and turns suspicion into a living companion-aware pressure system rather than just background simulation.
[End of research — status: inbox]

---

## Librarian integration log (2026-06-20, branch `docs/research-village-suspicion`)

Processed per `docs/research/README.md` (propose-first). This is mostly a
**confirmation** of the shipped system (the documented current behaviour —
`SUSPICION_DECAY_PER_PHASE = 0.7`, report threshold 100 → +25 alarm, eavesdrop
×2.5 — was checked against `village_state.gd` and is accurate). **Verdict: keep
the 0.7×/phase baseline; no change.** One post-slice extension proposed, which is
a specific case of the already-captured Terranigma "authored village evolution"
idea. Nothing reopens a locked decision; nothing fails the filter (the research
itself flags that procedural-NPC behaviour or visible meters would).

- **`docs/ideas.md`** — post-slice idea: make suspicion decay **companion/
  morality-aware** (ruthless → slower decay / villagers stay paranoid; high Briar
  bond → small zone decay bonus or one authored "distraction" per phase), via
  hand-written flags (not procedural). Linked to the Terranigma evolution idea.
- **`docs/mechanics/village-life.md`** — extended the existing "Future direction"
  note with this specific decay-modulation, plus a one-line confirmation that the
  current 0.7×/phase decay was reviewed and is sound.
- Not promoted to a spec/decision — confirmatory + a queued extension.
