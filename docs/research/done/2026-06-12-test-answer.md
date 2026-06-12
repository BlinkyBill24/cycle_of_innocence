---
name: HollowingClock dependents + doom presentation constraints (bridge verification, setup-guide §B4)
date: 2026-06-12
source: claude.ai project chat
prompt: "Which mechanics stand on the HollowingClock, and what would a new player-visible doom presentation have to respect?"
status: integrated
---

Both halves of this are answerable straight from the vault snapshots — here's the map, then the constraints.
What stands on the HollowingClock
Feeds it (writes alarm points / milestones):

Mercy/combat verbs — kill +25, betrayal +40, domination +35, stilling −20; 100 points pulls a stage early, overflow carries. The clock literally is "the world's response to who Rowan is becoming."
VillageState suspicion — per-villager suspicion crossing threshold converts to alarm points once per villager; the stage advances because specific people started talking.
Story milestones — revelations, zone firsts, age-ups, consumed once per id.
Player noise — sightings by villagers/Wardens, loud kills near the village, high-corruption powers.

Reads it (consumes stage / stage_advanced):

Encounters-mercy — Frenzy (3) un-stills every Stilled monster with no betrayal cost (spared_ history kept); Alarm (2) spawns the unsaveable emergency-ritual child in the deep fringes.
Day/night-hideout — night dread floor 20 + 5×stage; night spawns and ritual processions scale by stage; hideout discovery/forced relocation gated to Frenzy+.
DreadManager — +12 dread per stage advance, plus the night-floor scaling above.
Enemy perception — detection radius ×(1 + 0.1×stage); spawn tables and patrol routes per zone are keyed to stage.
Dialogue Manager — hollowing_stage gates dialogue everywhere; balloons read HollowingClock.stage directly.
VillageState routines & gossip — schedules harden at stage 2, stop at stage 3 (the empty bench); gossip pools are stage-keyed and carry real intel.
Adaptive audio — the danger stem is driven partly by stage ≥ 2; stems crossfade from dread + time + stage.
Companions — Briar's whimper on advance is the implemented early-warning; the design canon is Echo refusing to fly toward the village a stage before the player learns why.
Endings — peak-stage and stage-at-finale flags feed the branch logic (Frenzy + low bonds → The Failure).
SaveManager / NG+ — stage, points, pending queue, consumed milestones, per-stage loss flags all persist; NG+ resets to stage 0 but carries $knew_it_was_coming echoes.

Plus the queue infrastructure itself: advancement never fires mid-dialogue (exploration_paused) or inside the hideout (hideout_entered/exited), only on resume/zone transition.
What a new player-visible presentation must respect
The hard ones first — these are recorded rules, not vibes:

"No timer UI" is a written presentation rule. The hollowing-clock doc says it outright, and the 2026-06-10 research session explicitly folded "doom-meter UI as diegetic church bells / village posters instead of any HUD element (World of Horror inversion)" into the doc's presentation rules. A HUD meter, stage number, or progress bar contradicts a recorded decision — you'd have to explicitly reopen it, and I'd flag that as failing your own filter (a meter serves legibility, not story, a companion arc, a horror beat, or replay; the diegetic signs serve all four).
No implied wall-clock. Stages are event-driven by design ("no anxiety treadmill," mobile-friendly). Any presentation that reads like a countdown — draining bar, ticking anything — lies about the mechanic and reintroduces the anxiety treadmill you deliberately cut.
Hidden state stays hidden. Stage and alarm points are hidden by design; "the cost of delay is shown, not told." A presentation that announces "Stage 3 — an NPC has died" violates shown-not-told twice over. The player should infer the stage from the world, never read it off a number.
The queue rule applies to presentation too. Anything triggered by stage_advanced fires on resume/zone transition, never mid-dialogue or in the hideout — the hideout's safety contrast is what makes dread legible, and a doom signal inside it breaks the anchor.
Don't fight the existing feedback stack. Each advance already plays the distant bell, Briar's whimper, +12 dread, and a horror_stinger, and the danger audio stem kicks in at stage 2. New presentation has to layer with this, not duplicate it or drown it.
Don't obsolete the companions. Companion behavior is the canonical early-warning channel — that's a pillar (family as instrument, same logic as quirks and the Empath insight tell). A presentation that tells the player before Briar/Echo do steals their job.
Accessibility contract. Horror-intensity slider scales presentation, never mechanics — and per the interface-horror precedent, information must survive low intensity (distorted dialogue keeps a visible cue at low settings). So the doom signal needs a calm-legible form too, plus the standing color-blind/alternative-cue rule.
House HUD style + platform. "Minimalist in exploration, more info in menus"; day/night has no clock UI either (palette shift only). Touch targets, no hover, cheap on Web export — CanvasModulate/shader-tier effects, not new render passes.

One non-issue worth stating: patent-wise this is clear ground — the doom clock audit found nothing, and even fake-UI-glitch presentation falls under the expired Nintendo sanity patent.
Recommendation
If the goal is more doom legibility, do it inside the recorded rule rather than reopening it, on two layers:
Diegetic density (world layer): the doc already names posters, patrols, church bells, NPC dialogue as the reading surface, and VillageState gives you stage-keyed gossip and schedules for free. The cheapest high-value additions are stage-keyed poster swaps as recontext-style node groups (the RecontextGroup pattern already exists, just keyed to stage instead of revelation) and a bell pattern language — the chapel rings differently per stage, so attentive players can literally count the doom. Both serve the horror beat (the net closing) and replay (learning to read the world).
Rowan's inference (journal layer): if you want something the player can consult, put it in the Growth/Memory journal as observed signs, not state — entries appear only when the player has witnessed the corresponding world change ("The Wardens carry lanterns now." / "Mrs. Alden's bench was empty today."). That's diegetic in fiction, lives in the sanctioned more-info-in-menus place, respects hidden-state and shown-not-told, and doubles as a companion/NPC memorial that feeds the grief tone. It's also the natural NG+ hook: $knew_it_was_coming can pre-seed dread-tinged journal lines.
The already-captured inbox candidate — corruption visibly spreading across zone maps (Children of Morta note from 2026-06-10) — is the right visual escalation channel if zones feel static later, and it's stage-compatible. I'd leave it parked until playtests say the world reads too slowly; it's an art-cost item, and the bell/poster/journal trio gets you legibility first for far less.
One thing I'd flag against the filter: any always-on-screen indicator, however diegetic-skinned (e.g., a corner candle that burns down). It still functions as a meter, still implies continuous time, and still competes with the companions — it fails the filter even though it technically isn't a "timer UI."
