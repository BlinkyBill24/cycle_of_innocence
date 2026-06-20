---
name: Warden Oslo search patterns investigation
date: 2026-06-20
source: Grok read of docs/mechanics/village-life.md + scripts/autoload/village_state.gd + scripts/npcs/villager.gd + scenes/npcs/villager.tscn
prompt: Investigate Warden Oslo search patterns
status: integrated
integrated: 2026-06-20 (branch docs/research-village-suspicion) — current behaviour confirmed sound; two post-slice extensions. See log at foot.
---

# Warden Oslo Search Patterns — Investigation

**Summary**  
Warden Oslo is the stage-2 search warden who only appears when `HollowingClock.stage >= 2`. He follows a small set of authored “search_” markers in the playground area, idles at them, and uses standard LOS detection to spot Rowan and raise suspicion. No complex AI — straight-line movement to markers + continuous suspicion while visible.

**Exact patterns (from village_state.gd SCHEDULES)**  
Only active via `STAGE2_STARTED = [&"warden_oslo"]` when stage >= 2:

- DAWN: marker `search_gate`
- DAY: marker `search_plaza`
- DUSK: marker `search_path`
- NIGHT: marker `search_plaza`

All activity label = `search`. Markers resolved via node groups in `playground_fringes` (and related) zones.

**Behavior (from villager.gd)**  
- Moves toward current resolved marker at 55 px/s if >6 px away, else idles.
- Every frame: distance check ≤70 px + `LineOfSight` RayCast2D (clear LOS = not colliding).
- While seeing: adds `effective_notice_rate(25.0, eavesdropping) * delta` suspicion per second (×2.5 if eavesdropping).
- Shows floating exclaim sprite on first notice.
- Re-resolves slot on time or hollowing stage change.
- Stage 3+ would hide him if he were in `STAGE3_STOPPED` (he is not).

**Mapping to locked systems**
- VillageState suspicion/routines (core — his route and activation are pure data + stage logic)
- ZoneManager + zone recontextualization (markers + stage-2 recontext of playground area)
- HollowingClock (suspicion reports feed alarm points)
- DreadManager (patrol tension + potential Briar fear hook)
- companion bond/corruption + PlayerData (currently unused — high-value extension point)
- GameEvents + Dialogue Manager (villager_reported + gossip changes)
- SaveManager (persists suspicion + reported state)

**Filter result**  
Passes cleanly:
- Story: “the village comes looking” for the escaped offering (delayed alarm bible beat).
- Horror beat: patrolling warden forces hiding/stealth and creates visible “someone is searching” tension.
- Replay: stealth vs loud playstyles change when he appears and how much suspicion he generates; different stage timings create different worlds.
- Companion arc: clearest missing piece — easy to hook Briar reactions or bond-modulated evasion help.

Nothing fails the filter. Avoid future procedural movement or complex search AI (already guarded).

**Clear recommendation**  
Keep current marker-patrol + LOS notice as-is (simple, legible, authored, Web-friendly).

Next content pass additions (lightweight, authored):
1. High Briar bond → small notice-rate reduction or early warning when Oslo is active nearby. Low bond/corruption → Briar more fearful. Stands on companion bond + DreadManager + VillageState.
2. Successful multi-phase evasion of Oslo triggers small hand-written recontext (new gossip, missed clue, journal entry). Stands on ZoneManager recontext + Journal + HollowingClock.

These turn Oslo from background patrol into a living part of the conspiracy and companion relationship without new systems.

[End of research — status: inbox]

---

## Librarian integration log (2026-06-20, branch `docs/research-village-suspicion`)

Processed per `docs/research/README.md` (propose-first). Mostly a **confirmation**:
the documented behaviour (stage-2-only `STAGE2_STARTED`; dawn `search_gate` / day
`search_plaza` / dusk `search_path` / night `search_plaza`; 55 px/s to marker;
≤70px + LOS RayCast notice; `effective_notice_rate(25.0, …)` ×2.5 eavesdrop)
matches `village_state.gd` / `villager.gd`. **Verdict: keep the marker-patrol +
LOS notice as-is** (simple, legible, authored, Web-friendly). Two post-slice
extensions captured (companion-aware, like the suspicion-decay file). Nothing
reopens a locked decision; the research flags procedural/complex search AI as the
thing to avoid (already guarded).

- **`docs/ideas.md`** — post-slice: (1) high Briar bond → small notice-rate
  reduction / early warning when Oslo is active nearby (low bond/corruption →
  Briar more fearful); (2) a successful multi-phase evasion writes a small
  authored recontext (new gossip / missed clue / journal entry). Hand-written, not
  procedural.
- **`docs/mechanics/village-life.md`** — extended the "Future direction" note with
  the Oslo companion-aware extensions + a one-line "current patrol reviewed, sound".
- Not promoted to a spec — confirmatory + queued extensions.
