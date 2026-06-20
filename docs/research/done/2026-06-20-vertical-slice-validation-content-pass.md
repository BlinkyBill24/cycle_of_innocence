---
name: Vertical Slice — Validation & Content Pass (Cycle of Innocence Core Proof)
date: 2026-06-20
source: "Grok task breakdown (user-provided, 'Detail vertical slice tasks') — corrected and reframed by Claude against COI's actual build state. Underlying frame: standard indie production milestones (vertical-slice-first) + direct mapping to the locked Godot 4.4 stack and existing systems."
prompt: "Review Grok's vertical-slice task list and output a proper vault-ready inbox file: fix the misused reliability markers and reframe from a build-from-scratch plan to a validation + content pass that matches where the project actually is."
status: integrated
related: "[[plan/slice-implementation-roadmap]] · [[plan/playtest-protocol-2026-06]] · [[2026-06-20-solo-dev-project-setup-godot-web]] · [[AGENTS.md]]"
---

> **Librarian pass — integrated 2026-06-20** (branch `docs/research-slice-validation-pass`).
> ~90% of this note already lives in the slice roadmap + the solo-dev-setup note + AGENTS
> guardrails, and the note itself warns against duplicating the live roadmap. So the
> integration is intentionally **light**: a single **"Posture" callout** added to
> [[plan/slice-implementation-roadmap]] capturing the genuine delta — reframe the remaining
> slice work as **validation + content (not build)**, name the two bottlenecks (Web-proof /
> audio + content authoring), keep Briar (not Echo/Storm), and cross-link both 2026-06-20
> research notes.
>
> Verify-on-integration resolved: **"gdkeys" / Rami Ismail attributions dropped** (unconfirmable —
> not cited). **Web-audio de-risk NOT re-added** (already in [[ideas]] from the solo-dev pass;
> export run 2026-06-20 builds clean, audio code Web-safe, in-browser listen still the human's).
> **No parallel 0–10 task list added** (would duplicate M0–M3). **No art-register/backdrop edits**
> (open decisions; the note agrees "polish later," already the roadmap stance). Cross-link to
> the solo-dev note done.

# Vertical Slice — Validation & Content Pass

> **Inbox note for librarian triage.** This is a *corrected* version of a Grok task list.
> Two problems were fixed: (1) every task had been tagged `[verified 2026-06-20]`, which
> overclaims — these are **design/process recommendations**, not facts checked against a
> source, so they are re-tagged `[training knowledge]`; (2) the original read as a
> *build-from-scratch* plan, but **most of these systems are already built** in COI, so it
> is reframed as a **validation + content** pass.
>
> Markers: `[training knowledge]` = established/general practice. `[FLAG]` = needs a
> decision or a source-check on integration. `[verified 2026-06-20]` is used **only** for
> claims that actually rest on a citable source or your own recorded test.

---

## What changed vs the Grok version (read this first)

- **Markers corrected.** The Grok note marked all 11 steps `[verified 2026-06-20]`. Nothing in it was checked against a source — its own provenance line says it's a "synthesis." Task advice can't be "verified" the way a fact can, so it's now `[training knowledge]`. `[FLAG: this was the main accuracy problem]`
- **Reframed to match reality.** Per your own snapshots, the slice systems already exist — GameEvents, PlayerData, DreadManager, HollowingClock, VillageState, ZoneManager + recontextualization, Dialogue Manager balloons, companion bond/corruption, mercy/soothe, SaveManager, adaptive audio, the witnessed Journal, and the Hollow House micro-quest. So steps that said "implement player movement" or "ensure GameEvents can emit signals" are rewritten as **"confirm it still works, especially on Web."** `[verified 2026-06-20 — your vault]`
- **Source attribution flagged.** The original credits "gdkeys" as a vertical-slice source. I can't confirm that's a real, citable source — drop or verify it on integration. `[FLAG]`
- **Your real bottleneck is named.** It is **not** building systems. It is **(a) proving the slice runs on the Web target — audio especially — and (b) authoring enough content to fill the systems** (the "content drought" your own notes flag). The order below reflects that.

---

## Vertical slice goal (unchanged — this part Grok got right)

One small zone (~10–20 min) that proves the horror-conspiracy tone: the player enters, interacts with the environment and a companion (bond seed), hits one clear horror/conspiracy beat (dread spike + suspicion hint), makes at least one meaningful choice that touches PlayerData (morality/companions), and can save/load — and it **runs and feels right on Web**. It seeds replay through ZoneManager recontextualization and morality tracking. `[training knowledge]`

Every task is filtered for **story / companion arc / horror beat / replay**; anything failing the filter is flagged, not recommended.

---

## Recommended order (validation → content → Web proof → polish)

### 0. Scope lock in the vault (½ day) `[training knowledge]`
- One Canvas/note for this milestone: the exact zone, companion, and horror beat. Link to the bible.
- Write the **success criteria in feeling terms** ("what 'feels like the game' means" for dread + the companion moment) — reuse your existing slice gate: *did the choice matter, did dread land, did the bond feel real, did it run on Web at an acceptable load time.*
- Hold the line: one zone, one companion moment, one horror beat, basic save. Flag any creep.
- *Filter:* keeps the single source of truth accurate. ✔

### 1. System smoke-test, not a rebuild (½–1 day) `[training knowledge]`
- These already exist — so **confirm each still fires** end to end in the slice scene: a GameEvents signal round-trips; PlayerData/DreadManager/ZoneManager react; SaveManager writes and restores a PlayerData snapshot (morality + companion bond).
- Do this **in an exported Web build, not just the editor** — that's where breakage hides.
- *Stands on:* GameEvents, SaveManager, PlayerData, DreadManager, ZoneManager.
- *Filter:* decoupling that carries story choices + horror state into replay. ✔

### 2. Interaction loop check (½–1 day) `[training knowledge]`
- Confirm top-down movement + collision and the interact/"examine" verb emit the right GameEvents and can trigger dialogue or environmental notes.
- *Stands on:* ZoneManager, GameEvents.
- *Filter:* the loop that carries story + horror beats; foundation for recontext on revisit. ✔

### 3. Zone + recontextualization seed (1–2 days; **content, not just code**) `[training knowledge]`
- Confirm the slice zone loads via ZoneManager and tracks entry/exit.
- **Author** at least one element that recontextualizes later (a note, object, or lighting state that changes after a choice or a dread/stage event), plus one VillageState suspicion hint.
- *Note:* the recontext **mechanism is built** — the work here is **writing the content** that flips. The words/lore are yours; don't have a tool invent them. `[verified 2026-06-20 — your vault]`
- *Stands on:* ZoneManager + recontextualization, VillageState.
- *Filter:* replay (revisit reads differently) + horror (suspicion as dread) + story (conspiracy clues). ✔

### 4. Companion bond seed (1–2 days; mostly content) `[training knowledge]`
- Place one companion (LimboAI behavior already exists for the dog). Use Dialogue Manager balloons for 1–2 short exchanges that introduce it and seed the bond; on the choice, update PlayerData bond and emit via GameEvents.
- Keep it short but emotionally clear — it must read as the *start of an arc*.
- *Stands on:* Dialogue Manager balloons, PlayerData (companions + bond), GameEvents, companion bond/corruption.
- *Filter:* companion arc + story; the choice can nudge morality for replay. ✔
- *`[FLAG]`* If this companion is Briar (dog), good — it's built. If you're tempted to use Echo or Storm, **stop**: they aren't built yet, and adding them is a new-mechanic detour that breaks your content-complete-per-zone rule.

### 5. The horror / conspiracy beat (2–3 days; the heart of the slice) `[training knowledge]`
- Implement one self-contained beat: an environmental shift, an overheard suspicious routine, or a dread spike tied to a player action/choice.
- Trigger DreadManager (and HollowingClock if the beat is stage-timed); shift the adaptive audio stem(s); produce a VillageState suspicion change the player can notice; let the outcome lightly move morality or bond.
- *Stands on:* DreadManager, HollowingClock, VillageState, adaptive audio, GameEvents, PlayerData.
- *Filter:* the core horror + conspiracy delivery; recontext fuel for replay; story weight via consequence. ✔

### 6. Persistence check across the beat (½ day) `[training knowledge]`
- Confirm a save **after** the beat + companion moment restores PlayerData and any recontext-relevant zone state on load.
- Keep your debug PlayerData readout for now; hide it for testers (your protocol already says debug HUD off for testers).
- *Stands on:* SaveManager, PlayerData.
- *Filter:* replay + story continuity. ✔

### 7. Mercy/soothe — only if the beat needs it (1–2 days, conditional) `[training knowledge]`
- If your beat involves a light action moment, use the existing mercy/soothe resolution and wire its outcome to morality/bond. **Skip entirely if the beat is stronger as pure atmosphere/investigation.**
- *Stands on:* mercy/soothe, PlayerData, GameEvents.
- *Filter:* include **only** if it serves this beat or a bond consequence; flag and cut if it becomes generic action. ✔

### 8. Art, audio & atmosphere polish (2–4 days; **do this later, not early**) `[training knowledge]`
- Consistent 32×32 style on player, companion, tiles, key objects; lighting/grading that sells the innocence→horror contrast; finalize the stem transitions; add small interact/dread feedback.
- *`[FLAG]` Toolchain:* you use **GIMP / Pixelorama / scripted + PixelLab**, **not Aseprite**. Also: your character sprites and the painted backdrops aren't yet on one locked art register, and there's an **open backdrop decision** — so heavy art polish here may be redone. Polish *enough to judge feel*, then stop. `[verified 2026-06-20 — your vault]`
- *Stands on:* adaptive audio, ZoneManager (atmosphere), DreadManager.
- *Filter:* strengthens the horror beat + tone; consistency supports replay. ✔

### 9. Web export + self-playtest (the step that actually de-risks you) `[training knowledge]`
- Run the full flow: enter → companion bond → horror beat → morality/suspicion effect → save/load → re-enter (recontext check).
- **Export to Web and confirm the risky parts:** does audio start (browsers block sound until the first click/tap) and do the stems crossfade acceptably? Input and loading OK? `[verified 2026-06-20 — browser autoplay policy; Godot Web audio caveats]`
- *Note:* LimboAI (your AI addon) is already confirmed to export to Web; **audio is the open Web risk.** `[verified 2026-06-20 — your vault test]`
- Record 1–2 self-play sessions; note where dread lands vs goes flat. Fix blockers only.
- *Stands on:* all systems (integration).
- *Filter:* proves story + companion + horror + replay actually work for a player. ✔

### 10. Document + plan next milestone (½ day) `[training knowledge]`
- Update the milestone note: what worked, what to revisit, end-of-slice PlayerData/bond/dread values.
- Define the next milestone — but **gate it on the external playtest**, not on your own playthrough. Your drafted protocol ([[plan/playtest-protocol-2026-06]]) is the gate.
- *Filter:* keeps the vault accurate; prevents knowledge loss. ✔

---

## Clear recommendation

- **Treat this as a validation + content pass, not a build.** The systems are done; spend the time **(1) confirming the slice runs and feels right on Web (audio is the live risk), and (2) authoring the recontext content, the companion exchange, and the horror beat** that fill the systems.
- **Resist early art polish.** Your art register isn't locked and the backdrop decision is open — polishing now risks rework. Get the *feel* right, then freeze.
- **Use your own gates, not Grok's optimism.** Your content-complete-per-zone rule and the drafted playtest protocol are stronger discipline than "keep iterating" — keep them.
- **Use the built companion (Briar).** Don't pull Echo/Storm into the slice; that's a new-mechanic detour.

If a new idea appears mid-build, run it through the filter (story / companion / horror / replay). If it fails, park it in the inbox for a later milestone or drop it.

---

## Verify on integration (librarian to-do)
- [ ] Drop or source-check the **"gdkeys"** attribution and the Rami Ismail milestone reference.
- [ ] Confirm the slice's chosen **zone / companion / horror beat** matches what's actually half-built (avoid authoring a second parallel slice).
- [ ] Cross-link to [[2026-06-20-solo-dev-project-setup-godot-web]] (the Web-audio + LimboAI findings overlap with step 9).
- [ ] Reconcile against [[plan/slice-implementation-roadmap]] so this note doesn't duplicate or contradict the live roadmap.
