---
name: Briar companion bond hooks exploration
date: 2026-06-20
source: Grok read of docs/characters/companions.md + docs/mechanics/companion-quirks.md + scripts/autoload/player_data.gd + previous village-life and warden-oslo research
prompt: Explore Briar companion bond hooks
status: integrated
integrated: 2026-06-20 (branch docs/research-village-suspicion) — confirmation + consolidated next-pass priorities. See log at foot.
---

# Briar Companion Bond Hooks — Exploration

**Current state**  
Briar is the emotional heart companion. Bond (0–100) and corruption (0–100) are stored in `PlayerData.companions["briar"]` with signals `bond_changed` / `corruption_changed`. Dialogue Manager already mutates them via `add_companion_bond` / `add_companion_corruption`. Quirks unlock at authored thresholds and are expressed through LimboAI.

**Implemented / strongly planned hooks**

1. **Quirk system (diagnosable behaviors)**  
   - Bond ≥ 60: scent growl (true ping at diggables)  
   - Corruption ≥ 40: long stare (delay before obeying, softens with bond)  
   - Corruption ≥ 70: phantom guard (growls at nothing)  
   - Bond ≥ 75: dusk press (−5 dread at night)  
   Hideout care softens expression. Empath insight shows “!” tell only on true pings.  
   Stands on: PlayerData, LimboAI, DreadManager, GameEvents (quirk_acquired/expressed), companion bond/corruption.

2. **Visual & progression hooks**  
   Pup → adult appearance tied to Rowan age + bond time. Corruption adds glowing eyes, matted fur, monstrous form. Can become horror encounter or require mercy scene.  
   Stands on: PlayerData (age/morality/companions), age_advanced signal.

3. **Interest-point / gaze system (planned)**  
   Briar orients (ear perk, growl, dig-paw) toward recontext nodes and secrets. Imperfect/animal on purpose. Higher bond = more reliable.  
   Stands on: ZoneManager + recontextualization, vision-and-darkness, DreadManager, companion bond.

4. **Contextual assists scaling with bond (partially live)**  
   Dig assist → dig-to-lore (buried toy = recontext fragment). Bond-threshold growth for new assists/story beats. Planned: high-bond assisted movement/vault.  
   Stands on: companion bond/corruption, LimboAI, ZoneManager, PlayerData, mercy/soothe combat.

5. **Emerging world-state reaction (from Warden Oslo research)**  
   Briar can react to high VillageState suspicion or active search patterns (growl toward plaza, early warning, or fearful refusal). High bond = reliable; corruption = unpredictable.  
   Stands on: VillageState suspicion/routines, HollowingClock, DreadManager, companion bond/corruption.

**Gaps that would serve the filter**  
- Direct hook from bond to VillageState suspicion decay or Warden Oslo notice rate.  
- Mercy/soothe combat synergy (high bond strengthens soothe; corruption interferes).  
- Adaptive audio integration (Briar whimpers/growls layer into dread stems).  
- Story-gated refusal / breaking-point scenes wired to thresholds.

**Filter result**  
All current and strongly referenced hooks pass:  
- Story: “innocence preserved or weaponized” + found-family beats.  
- Companion arc: core emotional relationship.  
- Horror beat: corruption quirks and potential monstrous turn / mercy-kill.  
- Replay: different bond paths produce different quirks, assist reliability, recontext fragments, and ending branches.

**Clear recommendation**  
Prioritize these three in the next content pass:

1. Wire Briar reactions to VillageState / Warden Oslo (high bond = early warning or slight decay bonus; corruption = unpredictable reactions). Stands on VillageState + DreadManager + LimboAI.

2. Complete dig-to-lore + interest-point system (bond controls reliability of scent growls / ear perks toward buried recontext). Stands on ZoneManager recontext + vision-and-darkness.

3. Expose 2–3 authored bond-threshold milestones for Briar (e.g. 60 = reliable dig-to-lore + scent growl; 75 = dusk press). Make them feel earned and visible. Stands on PlayerData + CompanionQuirkDefs + LimboAI.

These extensions make every change in the Briar relationship matter in moment-to-moment play while staying fully on existing systems and authored guardrails.

[End of research — status: inbox]

---

## Librarian integration log (2026-06-20, branch `docs/research-village-suspicion`)

Processed per `docs/research/README.md` (propose-first). Largely a **confirmation
+ consolidation**: the live quirk thresholds it lists are accurate (bond ≥60 scent
growl · corruption ≥40 long stare · corruption ≥70 phantom guard · bond ≥75 dusk
press — see `companion_quirk_defs.gd` / `companion_base.gd`), and several of its
"next" items are already captured this session (Briar depth, bond-threshold growth,
warden/suspicion companion-aware hooks). Net-new value is the **prioritized next-
pass list** + the named gaps (mercy/soothe synergy, adaptive-audio Briar layer,
threshold breaking-point scenes). Nothing reopens a locked decision.

- **`docs/ideas.md`** — one consolidated entry: the three next-pass Briar priorities
  (wire reactions to VillageState/Warden Oslo; complete dig-to-lore + interest-point
  gaze; expose 2–3 authored bond milestones) + the named gaps.
- **`docs/characters/companions.md`** — one line in the "Future direction" note
  pointing at the consolidated bond-hooks priorities.
- No new spec/decision — it consolidates existing companion design + this session's
  captured ideas.
