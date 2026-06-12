# Decisions — architecture/process decision records, oldest first
> GENERATED 2026-06-12 by tools/compile_snapshots.py — do NOT edit (not here, not in claude.ai). Source of truth is the Obsidian vault in the game repo; this file is replaced wholesale at milestones.
> Sources: docs/decisions/2026-06-09-cycle-of-innocence-build-plan.md, docs/decisions/2026-06-10-central-brain-agents-md.md, docs/decisions/2026-06-10-new-features-and-ai-setup.md, docs/decisions/2026-06-10-patent-risk-review.md, docs/decisions/2026-06-10-recent-games-research-greenlight.md, docs/decisions/2026-06-10-repo-consolidation-game-only.md, docs/decisions/2026-06-10-slice-implementation-plan.md, docs/decisions/2026-06-10-sprite-tool-pixellab.md, docs/decisions/2026-06-12-web-research-bridge.md


======================================================================
SOURCE: docs/decisions/2026-06-09-cycle-of-innocence-build-plan.md
======================================================================

---
name: Cycle of Innocence — Phased Build Plan
date: 2026-06-09
tags: [decision, build-plan, cycle-of-innocence, preproduction]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Cycle of Innocence — Phased Build Plan (Approved)

## Context

User requested a complete, phased Grok Build plan in Plan Mode for a 2D top-down action-adventure RPG blending Zelda/Mana/Terranigma gameplay with Super Metroid/Silent Hill/Alien horror dread, Attack on Titan-style conspiracy twists and escalating revelations, and Fable-style protagonist life progression (child → adult with choice-driven appearance, personality, relationships, and world reactivity).

**Prior art (R3b)**: Full grep + reads of `../docs/decisions/`, learnings, ideas, sessions, handbook, and sibling `../rpg-adventure/GROK.md` + godot/ showed the existing project vision was a cozy non-combat 3D pixel diorama puzzle game ("Echoes of the Verdant Realm" / Mote, with vine/season mechanics). The 2D rpg-adventure/ was a room-based prototype with good engineering patterns but "pure gameplay" / forgiving tone and no horror or deep narrative.

This plan (and the project in `test/`) is a **major pivot** to a dark, story-heavy title. Explicit user revision during plan review: no Mote reuse, protagonist is an escaped child sacrifice, primary companions are rescueable/raiseable animals (dog, bird, horse...) with raising, bond, and corruption mechanics.

Clarifications locked via ask_user_question: title "Cycle of Innocence", develop in current workspace `test/`, real-time action combat, Yarn Spinner for dialogue.

The full detailed plan (phases, pipelines, code sketches, risk mitigation, verification, next steps) was written to the Grok session plan file and is the source of truth.

## Decision

Ship **Cycle of Innocence** following the complete 7-phase build plan (Phase 0 pre-prod through Phase 6 release prep) as documented in the session plan artifact.

Key commitments:
- Develop in `test/` (project root for this title for now).
- Create and maintain local Obsidian vault at `docs/` (inside this directory) + `GROK.md` at root (modeled on sibling + parent rules).
- Reuse only low-level patterns from siblings (2D player controller, autoloads, room/zone, touch/input, pixel pipeline, Imagine tools). No Mote mechanics or tone.
- Protagonist = escaped sacrifice. Animal companions as core progression, utility, and emotional stakes (with growth + possible corruption).
- Real-time action combat + Yarn branching narrative with age/morality/bond variables.
- Strict vertical slices, AI leverage (image_gen, subagents, graphify, skills), scope control via gates, and full adherence to monorepo rules (branch, Obsidian consult, journals, ideas, status.py).

See the full plan for detailed milestones per phase, code examples, asset prompts, architecture diagram, and verification steps.

## Alternatives
- Evolve the existing cozy Mote vision or rpg-adventure tone directly — rejected (user requested this specific dark conspiracy + animal bonds + escaped sacrifice concept).
- Pure custom dialogue system (no Yarn) — rejected (Yarn chosen for writer velocity on heavy branching reveals).
- Human party as primary bonds — revised per user feedback to animal companions only.

## Consequences

**Positive**
- Delivers the exact ambitious vision requested (horror + twists + Fable progression + animal found-family).
- Reuses proven 2D Godot cross-platform engineering from the monorepo while starting fresh on story/mechanics.
- Local vault + GROK.md + documented use of hooks/agents gives strong memory and AI acceleration for solo dev.
- Early vertical slice + gates protect against scope creep on art (age + animal variants) and writing.

**Negative / trade-offs**
- Significant tonal departure from prior project work (Mote pre-prod just completed GREEN).
- Higher emotional/art/writing scope than the previous cozy prototype (mitigated by focused 2–3 animals, Yarn, phased approach).
- Must maintain discipline on "within this directory" vault while still feeding parent docs/ per R3.

## Implementation
- **Branch**: `feature/cycle-of-innocence` (created; all work here).
- **Files** (initial from this session):
  - `GROK.md` (root)
  - `docs/` (full local vault: home.md, ideas.md, _templates/, decisions/, sessions/...)
  - `docs/decisions/2026-06-09-cycle-of-innocence-build-plan.md` (this doc)
  - `docs/sessions/2026-06-09.md` (setup journal)
- The complete actionable plan (phases 0–6, pipelines, snippets, next steps) lives in the Grok session plan file and should be referenced / partially mirrored here.
- Next: engine spike (port player + basic zone + age stub), art spike (first bibles via image_gen), Yarn first nodes, persist more as work progresses.

**Verified**: Plan approved via exit_plan_mode after exploration, clarification questions, and user revision for animals + escaped-sacrifice protagonist + no Mote reuse.

## Lookback Questions
- Did the animal companion focus (raising + corruption) deliver the intended emotional horror weight?
- Did the first vertical slice (escape + one companion + one horror beat) land the "loss of innocence + conspiracy seed" tone?
- How well did Yarn variable sync + PlayerData handle age + bond + revelation state across platforms?
- Did we keep scope under control (2–3 animals, focused campaign)?

## Related
- [[home]]
- [[../../docs/home]]
- [[../../docs/decisions/2026-04-06-game-vision-echoes-verdant-realm]] (prior vision — not reused)
- [[../../rpg-adventure/GROK.md]] (patterns source)
- Full session plan artifact (Grok)
- Parent [[../../CLAUDE.md]]


======================================================================
SOURCE: docs/decisions/2026-06-10-central-brain-agents-md.md
======================================================================

---
name: Central brain via AGENTS.md for multi-CLI AI workflow
date: 2026-06-10
tags: [decision, tooling, ai-workflow]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Central Brain (AGENTS.md) for Multi-CLI AI Workflow

## Context
The user asked: (a) is it possible/sensible to work with multiple CLI AIs (Grok, Claude, Codex) sharing one central, always-current project brain ("Karpathy-like"); (b) pros/cons of Cursor-agent-as-coordinator vs switching between CLIs.

Audit found all four tools installed (Claude Code, Grok CLI 0.2.38, Codex CLI 0.133.0, Cursor 3.7.21) but the brain fragmented across `game/CLAUDE.md`, `test/GROK.md`, `test/AGENT_RULES.md` and two vaults — with rules duplicated 3–4× and **live divergence**: the 2026-06-10 Yarn→Dialogue Manager switch missed ~28 references across 11 design docs within a day.

Research (June 2026): `AGENTS.md` is the Linux Foundation open standard (60k+ projects), read **natively** by Codex CLI, Cursor, and Grok CLI; Claude Code consumes it via a one-line `@AGENTS.md` import in CLAUDE.md. Karpathy's "one brain" pattern = behavior file (agents.md) + synthesized markdown wiki — the Obsidian vault already is the wiki half.

## Decision
1. **Yes to multi-CLI with one brain.** Architecture: **`AGENTS.md` holds behavior** (rules, stack, roles, slice definition); **the Obsidian vault holds knowledge** (bible, mechanics, decisions, sessions); per-tool files are thin shims.
2. **Claude Code is the day-to-day hub**: it already drives Codex (`codex:rescue` plugin) and Grok (MCP), and hooks enforce R1. Cursor stays the IDE, reading AGENTS.md natively — no Cursor-specific rules maintained.
3. Implemented: canonical `test/AGENTS.md`; `test/CLAUDE.md` = `@AGENTS.md` + Claude notes; `AGENT_RULES.md` = pointer shim (kept for old prompt references); `GROK.md` = Grok-specific (Imagine pipeline) + slice table + session history; ~28 stale Yarn references fixed; `tools/check-brain.sh` drift guard (verified: catches an injected stale term); sync script now ships the brain files to the published repo.

## Alternatives
- **Cursor agent as coordinator** — rejected as hub (kept as IDE). Pros: one UI, multi-model (Claude/GPT/Grok), background agents, built-in review UI. Cons: vendor lock-in (Cursor-specific rules/workflows), credit-based unpredictable cost, aggressive context truncation vs Claude Code's 1M window, and the existing investment (hooks, skills, Grok MCP, codex plugin, auto-memory) doesn't carry over.
- **Manual CLI switching, no hub** — viable *because of* AGENTS.md (every tool reads the same brain), but adds per-task coordination overhead the user doesn't need given the Claude hub exists. Available anytime as fallback — that's the point of the standard.
- **rulesync-style generated configs** — overkill for a solo dev with 4 tools; symlink/import + drift guard suffices.
- **Symlinking CLAUDE.md → AGENTS.md** — rejected in favor of `@AGENTS.md` import: allows Claude-specific additions and avoids symlink issues.

## Consequences
- + One edit updates every tool; yesterday's divergence class is now structurally prevented and mechanically detected (`check-brain.sh` in the completion checklist).
- + Codex/Grok/Cursor sessions started in `test/` are automatically up to date with zero per-tool config.
- − Old prompts referencing AGENT_RULES.md content now land on a pointer (one hop).
- − GROK.md history was condensed; full prior text remains in git history.

## Implementation
- **Branch**: `refactor/central-brain-agents-md`
- **Files**: `AGENTS.md` (new), `CLAUDE.md` (new), `AGENT_RULES.md`, `GROK.md`, `tools/check-brain.sh` (new), `tools/sync-to-rpg-adventure.sh`, `../CLAUDE.md` (pointer note), ~11 docs de-Yarned (`docs/design/game-features.md`, `docs/story/bible.md`, `docs/characters/companions.md`, …)
- **Verified**: `check-brain.sh` passes (and fails correctly on injected drift); GUT 7/7 still green; Codex smoke test reads AGENTS.md.

## Lookback Questions
- Did any tool ignore AGENTS.md in practice (esp. Grok CLI version drift)?
- Did Claude Code gain native AGENTS.md support (issue #34235), making CLAUDE.md shim removable?
- Is the drift guard catching enough, or should it diff rule sections semantically?

## Related
- [[2026-06-10-new-features-and-ai-setup]] · [[../design/ai-production-setup]] · ../AGENTS.md


======================================================================
SOURCE: docs/decisions/2026-06-10-new-features-and-ai-setup.md
======================================================================

---
name: New features from genre research + AI production setup
date: 2026-06-10
tags: [decision]
status: active
related_features:
  - "[[mechanics/encounters-mercy]]"
  - "[[mechanics/hollowing-clock]]"
  - "[[mechanics/day-night-hideout]]"
  - "[[mechanics/vision-and-darkness]]"
  - "[[design/ai-production-setup]]"
related_bugs: []
supersedes: null
superseded_by: null
---

# New Features from Genre Research + AI Production Setup

## Context
With the story bible, mechanics docs, and progression core (PlayerData/AgeMorph) in place, we researched comparable games (Darkwood, Fear & Hunger, Undertale, OMORI, World of Horror, Children of Morta, Moonlighter, Eastward, The Last Guardian, Black & White) to find proven mechanics that fit a 2D top-down horror ARPG, and surveyed the AI tooling needed to actually finish the game solo (art, audio, dialogue, code agents, in-game AI, testing). Candidates were filtered against existing design docs per R3b — dread meter, bond/corruption, morality, NG+ echoes, and endings already exist and were not re-proposed.

## Decision
1. **Greenlight 4 new features** into the design vault (full specs in mechanics/):
   - [[mechanics/encounters-mercy]] — soothe/spare resolution (monsters are former sacrificed children); Domination as the Vessel mirror.
   - [[mechanics/hollowing-clock]] — 5-stage event-driven doom escalation mechanizing the bible's "delayed alarm".
   - [[mechanics/day-night-hideout]] — action-driven day/night loop + hideout safe-camp hosting companion care and saves.
   - [[mechanics/vision-and-darkness]] — facing-cone line-of-sight fog with companion senses (scent/overwatch/steadiness).
2. **AI production stack: FOSS-first** (see [[design/ai-production-setup]]); upgrade to paid tools only on concrete quality/volume walls. No runtime LLM in the shipped game.
3. **Tooling installed**: GUT v9.6.0 (+ `tests/` with PlayerData smoke tests, `tools/run-tests.sh`), LimboAI v1.6.0 (GDExtension for Godot 4.4), Dialogue Manager v3.10.4, godot-mcp built at `~/godot-mcp` for Claude Code scene-tree access.
4. **Tech-stack change: Yarn Spinner → Dialogue Manager.** The official YarnSpinner-Godot addon is C#-only; the .NET Godot build cannot export to Web in 4.4, and Web (itch demo + NAS playtest loop) stays a target platform. Dialogue Manager is pure GDScript, MIT, actively maintained, and reads/writes PlayerData autoloads directly (no variable-sync layer). Existing docs' "$yarn_variable" notation maps 1:1 to Dialogue Manager state access.

## Alternatives
- **Coin-flip save/combat mechanics (Fear & Hunger)**: rejected — punishing RNG conflicts with the mobile audience and the bond-driven emotional core.
- **1-bit/severe palette constraint (World of Horror)**: rejected — 32×32 SNES-style identity already locked in art pipeline.
- **Turn-based combat (Eastward/OMORI)**: rejected — real-time Zelda/Mana combat is locked in the build plan.
- **Merchant/economy loop (Moonlighter)**: rejected — inventory doc explicitly keeps no economy in v1.
- **Yarn via .NET Godot**: rejected — loses Web export in 4.4, heavier Android builds.
- **GDYarn**: rejected — unmaintained since Jan 2024.
- **Paid AI stack (~$70/mo)**: deferred — FOSS path covers v1; revisit per-tool when a wall is hit.

## Consequences
- + Four interlocking systems give the vertical slice and full game their horror identity (cone × night × clock × mercy).
- + Dialogue runs on all three target platforms with zero sync code; agents get scene-tree access via godot-mcp.
- − Docs/AGENT_RULES/GROK references to "Yarn" need a sweep (done for locked-stack files; older design docs read "Yarn" as "dialogue system").
- − Four new systems are design-debt until the slice proves them; build order: vision cone → day/night → mercy → clock (clock last, it depends on world state).

## Implementation
- **Commits**: (this branch: `feature/ai-setup-and-new-features`)
- **Files**: `docs/mechanics/{encounters-mercy,hollowing-clock,day-night-hideout,vision-and-darkness}.md`, `docs/design/ai-production-setup.md`, `docs/design/game-features.md` (§14), `addons/{gut,limboai,dialogue_manager}/`, `tests/test_player_data.gd`, `tools/run-tests.sh`, `project.godot`
- **Verified**: `godot --headless --editor --quit` clean; GUT smoke tests pass headless.

## Lookback Questions
- Did the Hollowing clock create urgency without anxiety-treadmill feel in playtests?
- Did Dialogue Manager hold up for the full branching scope (choice matrix, $hollowing_stage gates)?
- Which paid-tool upgrade triggers actually fired?

## Related
- [[2026-06-09-cycle-of-innocence-build-plan]] · [[design/game-features]] · [[story/bible]]


======================================================================
SOURCE: docs/decisions/2026-06-10-patent-risk-review.md
======================================================================

---
name: Patent risk review — all planned features audited, none require redesign
date: 2026-06-10
tags: [decision, legal, patents, risk]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Patent Risk Review (June 2026)

> **Not legal advice.** Research-based audit by AI agents with cited sources. Engage an IP attorney before commercial release. Re-run this review at the demo/marketing milestone.

## Verdict
**No planned feature requires redesign.** Our biggest apparent exposure — the dread/sanity system with interface horror — is covered by a patent that **expired in 2021**. The two live patents that brush our design (Nemesis, dialogue wheel) are avoided by architecture we already have.

## Per-feature audit

| Our feature | Relevant patent | Holder | Status | Risk | Action |
|---|---|---|---|---|---|
| Dread meter, hallucinations ([[mechanics/horror-and-dread]]) | US 6,935,954 "Sanity system" | Nintendo | **EXPIRED Nov 2021**, no live family | ✅ none | use freely |
| Interface horror — fake glitches, distorted dialogue, input degradation ([[mechanics/interface-horror]]) | US 6,935,954 (its claims literally covered fake interface glitches) | Nintendo | EXPIRED | ✅ none | use freely |
| Companion bond/corruption, quirks, refusals ([[characters/companions]], [[mechanics/companion-quirks]]) | US 10,926,179 "Nemesis" | Warner Bros. | **LIVE → Aug 2036** | ⚠️ low | keep authored-not-procedural discipline (below) |
| NG+ companion echoes ([[mechanics/progression]]) | US 10,926,179 | Warner Bros. | LIVE | ⚠️ low | same |
| Dialogue UI (Dialogue Manager list balloons) | US 8,082,499 "dialogue wheel" | BioWare/EA | LIVE → **Oct 2029** | ✅ n/a as built | guardrail: no radial emotion-mapped wheel before 2030 |
| Mercy/soothe resolution ([[mechanics/encounters-mercy]]) | none found | — | — | ✅ | — |
| Hollowing doom clock ([[mechanics/hollowing-clock]]) | none found | — | — | ✅ | — |
| Village NPC schedules ([[mechanics/village-life]]) | US 7,637,806 (obscure, never enforced) | unclear | unclear | ✅ very low | nothing |
| Storm as rideable mount | JP 7,493,117 family (riding/switching, Palworld suit) | Nintendo/TPC | live in JP; US counterpart under USPTO re-exam | ✅ negligible | simple authored riding only — no capture, no summon-from-storage, no ride-switching system |
| Companion acquisition (story-bonded rescues) | JP 7,545,191 (throw-to-capture) | Nintendo/TPC | live, contested | ✅ n/a | we never capture creatures |
| Vision cone, day/night, adaptive audio, zone recontext, age morph, dig assist | none found | — | — | ✅ | — |

## The Nemesis distinction (why our companions are clear)
US 10,926,179 claims **procedurally generated** NPC evolution: hierarchies/ranks/promotions, power centers (forts), social vendettas between NPCs, and cross-save propagation of evolved NPCs. Our system is the opposite on every axis: **three fixed, authored characters** whose bond/corruption progressions, refusal thresholds, quirk acquisitions, and NG+ echo lines are **designer-scripted story beats** (data on `PlayerData.companions`, thresholds in docs) — no hierarchy, no ranks, no procedural generation of characters, single-player saves only. WB has never sued anyone over this patent (indies included); the practical defense is our own documentation showing authored design — which this vault already is.

**Design-language discipline** (now noted in the relevant docs + AGENTS.md): never describe or implement companions as "procedural nemesis systems", "NPC hierarchies", or "rank promotions" — in code, docs, or marketing copy.

## Enforcement reality (2026)
No documented mechanic-patent suit by a major publisher against a small indie. The notable cases are Nintendo v. Pocketpair (mid-sized, throw-capture specific — Pocketpair removed sphere-throwing; USPTO re-exam pressuring Nintendo's US position) and Nintendo v. Colopl (mobile giant). Risk for a solo EU dev with this design profile is minimal; the discipline above is cheap insurance.

## Lookback Questions
- At demo/marketing milestone: any new patents (esp. Palworld-case fallout)? Nemesis still standing unchanged?
- Did any post-slice feature drift toward procedural companion generation (would change the analysis)?

## Related
[[design/game-features]] · [[mechanics/companion-quirks]] · [[mechanics/interface-horror]] · [[2026-06-10-recent-games-research-greenlight]]


======================================================================
SOURCE: docs/decisions/2026-06-10-recent-games-research-greenlight.md
======================================================================

---
name: Recent-games research (round 2) — greenlight quirks, interface horror, adaptive audio, village life, recontextualization
date: 2026-06-10
tags: [decision, features, research]
status: active
related_features:
  - "[[mechanics/companion-quirks]]"
  - "[[mechanics/interface-horror]]"
  - "[[mechanics/adaptive-audio]]"
  - "[[mechanics/village-life]]"
  - "[[mechanics/zone-recontextualization]]"
related_bugs: []
supersedes: null
superseded_by: null
---

# Research Round 2 — Recent Games (2022–2026) Feature Greenlight

## Context
After round 1 (genre classics → mercy/clock/day-night/vision-cone), the user asked for analysis of recent releases with unique features and a feasibility-filtered suggestions list. ~22 games researched (Look Outside, Pacific Drive, Dredge, Mouthwashing, Heartworm, Sorry We're Closed, Shadows of Doubt, Void Stranger, Animal Well, Undertale Yellow, In Stars and Time, Cult of the Lamb, Crow Country, Hades II, Lorelei, Leap Year, Roadwarden, Moonring, etc.). Full findings: [[design/feature-candidates-2026-06]].

## Decision
User greenlit all four proposed groups:
1. **Slice-adjacent**: [[mechanics/companion-quirks]] (Pacific Drive), [[mechanics/interface-horror]] (Mouthwashing/Heartworm), [[mechanics/adaptive-audio]] (3-stem mixing, FOSS AdaptiSound or hand-rolled).
2. **Post-slice**: [[mechanics/village-life]] (schedules + gossip + suspicion; Shadows of Doubt/Sorry We're Closed), [[mechanics/zone-recontextualization]] (Void Stranger).
3. Refinement notes appended to round-1 docs: unique soothe per monster (mercy), counterfeit pings (vision), loop-memory dialogue (progression NG+).
4. Design rule to ideas inbox: ability layering (Animal Well) — every companion ability ships with 2-3 cross-context uses.

Build order unchanged: **vertical slice first**; Tier A bolts onto slice systems, Tier B comes after.

## Alternatives (rejected, with reasons)
- **Microphone-input horror** (Stifled/Phasmophobia): Web/Android API fragility, accessibility, privacy.
- **Procedural dungeons** (Moonring): handcrafted zones are locked design.
- **Settlement/follower management** (Cult of the Lamb/Bellwright): scope; companions are the management layer.
- **Companion recruitment tiers/tokens** (Hades II/Dave the Diver): conflicts with 3 fixed story companions.
- **Card/deck mechanics** (Inscryption): genre mismatch; its sacrifice-weight insight is already core story.
- **Crow Country full no-combat mode**: deferred to ideas inbox as accessibility stretch (mercy path partially covers).

## Consequences
- + Round-2 features are mostly *expression* layers over existing data (companions dict, dread, dialogue, audio buses) — high horror payoff, low architectural risk.
- + Village-life finally mechanizes the bible's cruelest beat (the village moves on without Rowan).
- − Design-debt grows: 9 greenlit-but-unbuilt systems now precede the slice. Mitigation: slice scope unchanged; greenlit docs are specs, not commitments to v1 if the slice gate fails.
- − Audio pipeline gains a constraint (stem-based composition, shared BPM/key).

## Implementation
- **Branch**: `docs/feature-research-round2`
- **Files**: `docs/design/feature-candidates-2026-06.md`, 5 new `docs/mechanics/*.md`, §15 in `docs/design/game-features.md`, refinement appendices in 3 round-1 docs, audio row in `docs/design/ai-production-setup.md`.
- **Verified**: check-brain.sh green; status.py no RED; pushed to origin.

## Lookback Questions
- After the slice: did quirks read as "family you can diagnose" in playtests, or as bugs?
- Did interface horror stay on the right side of frustrating (esp. on touch)?
- Was AdaptiSound 4.4-compatible, or did we hand-roll?

## Related
[[2026-06-10-new-features-and-ai-setup]] · [[design/feature-candidates-2026-06]] · [[design/game-features]]


======================================================================
SOURCE: docs/decisions/2026-06-10-repo-consolidation-game-only.md
======================================================================

---
name: Repo consolidation — develop in tchintchie/game only
date: 2026-06-10
tags: [decision, tooling, git]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Repo Consolidation — `tchintchie/game` Only

## Context
The project lived in two places: the `game` monorepo (actual development in `test/`) and `tchintchie/rpg-adventure` (a standalone mirror, force-overwritten via rsync + `git subtree split` per old rule R6). Costs observed: every commit doubled (~1000+ files when synced), force-pushes destroyed mirror history, and the duality caused real confusion — work pushed to `game` was invisible to the user looking at `rpg-adventure`. All tooling (parent Obsidian vault, `scripts/obsidian/`, hooks, AGENTS.md brain) is path-anchored in the monorepo.

## Decision
Develop **only** in `github.com/tchintchie/game`. Retired: the `rpg-adventure/` monorepo subdir (542 files removed; history preserved in git), `tools/sync-to-rpg-adventure.sh`, and the publish workflow. **R6 rewritten** in [[../../AGENTS.md|AGENTS.md]]: commit on feature branch + push to origin; user merges. The drift guard (`tools/check-brain.sh`) now also fails if living docs reinstate the sync/publish workflow.

A public standalone repo will be created **when a demo is ready** — freshly named for the locked title (e.g. `cycle-of-innocence`), produced via `git subtree split` at that point. The GitHub `rpg-adventure` repo can be archived by the user (left frozen until then).

## Alternatives
- **Keep dual setup**: rejected — ongoing sync overhead and confusion for no benefit while the project is solo/pre-demo.
- **Migrate to standalone now**: rejected — breaks vault/hooks/script paths today; the split is a one-command operation later, and the repo name should match the final title anyway.

## Consequences
- + Commits halve in size; one repo to look at; no force-push churn; normal branch/PR flow.
- + Old prototype sources remain available via git history (`git log -- rpg-adventure/`).
- − github.com/tchintchie/rpg-adventure goes stale until archived/replaced (user action).
- − Old journals/decisions referencing the sync workflow are now historical (exempt in the drift guard).

## Implementation
- **Branch**: `refactor/central-brain-agents-md`
- **Files**: `AGENTS.md` (R6, checklist, tree), `tools/check-brain.sh` (mirror guard), removed `tools/sync-to-rpg-adventure.sh` + `../rpg-adventure/`, `docs/home.md`, `docs/art/imagine-prompts.md`, auto-memory.
- **Verified**: `check-brain.sh` green after cleanup; `status.py` no RED; pushed to origin.

## Lookback Questions
- When the demo ships: did we split a clean `cycle-of-innocence` repo and archive rpg-adventure?
- Did anything still depend on the removed prototype files?

## Related
- [[2026-06-10-central-brain-agents-md]] · [[2026-06-10-new-features-and-ai-setup]]


======================================================================
SOURCE: docs/decisions/2026-06-10-slice-implementation-plan.md
======================================================================

---
name: Vertical slice implementation plan with AI agent task distribution
date: 2026-06-10
tags: [decision, plan, vertical-slice, agents]
status: active
related_features:
  - "[[plan/slice-implementation-roadmap]]"
related_bugs: []
supersedes: null
superseded_by: null
---

# Vertical Slice Implementation Plan + Agent Distribution

## Context
Design pre-production is complete: story bible, 13 documented systems (9 greenlit this week), AGENTS.md central brain, full tooling (Dialogue Manager, LimboAI, GUT, godot-mcp, Grok MCP, Codex plugin). Code: progression core only (PlayerData, controller, age morph, tests). The user asked for an actual implementation plan that distributes tasks across the AI agents. Builds on [[2026-06-09-cycle-of-innocence-build-plan]] (Phases 0–2 concretized).

## Decision
Adopt the milestone roadmap in [[plan/slice-implementation-roadmap]]:
- **M0** art/audio as a parallel track owned by Grok Imagine (+ human Aseprite/ACE-Step/ChipTone) that never blocks code.
- **M1** core systems by Claude Code (DreadManager → Combat v1 → Briar companion → Zone framework), one branch per system, GUT tests each, **Codex review gates** after combat and companion AI.
- **M2** narrative & persistence (first Dialogue Manager scene with "The Food" choice — Grok reviews voice; SaveManager; scripted dread beat).
- **M3** assembly (mercy v1, touch input, adaptive audio v1, web export) ending in the human **slice gate** from AGENTS.md.
- Post-slice order fixed: vision cone → day/night+hideout → mercy full → hollowing clock → quirks → interface horror → village life → recontextualization.
- This session: plan documents only (user decision) — no art runs, no code.

## Alternatives
- **Cursor-led implementation**: rejected — hub topology already decided ([[2026-06-10-central-brain-agents-md]]); Cursor stays the human's in-editor tool.
- **Art-first sequencing** (wait for sprites before systems): rejected — placeholder-driven development keeps the critical path on code; art is async.
- **Feature-parallel implementation** (multiple systems at once via worktrees): deferred — sequential branches until the first systems prove the patterns; revisit worktree parallelism post-slice.

## Consequences
- + Every agent has an explicit lane and interface; hand-offs reference specs by wikilink instead of re-explaining.
- + Codex gates add a second model's eyes exactly where solo-dev blind spots live (physics layers, AI structure).
- − Sequential M1 is slower than parallel worktrees — accepted for pattern stability.
- − Art quality risk stays human-gated (Aseprite cleanup is the bottleneck by design).

## Implementation
- **Branch**: `docs/slice-implementation-plan`
- **Files**: `docs/plan/slice-implementation-roadmap.md` (new), this doc, `docs/art/imagine-prompts.md` (A3–A5 prompts appended), `GROK.md` (slice table → M0–M3), task board entries.
- **Verified**: check-brain + status green; frontmatter valid; pushed to origin.

## Lookback Questions
- Did the Codex gates catch real issues, or add ceremony?
- Did the art track keep pace with code without blocking?
- Was the slice gate verdict honest (re-scope actually considered)?

## Related
[[plan/slice-implementation-roadmap]] · [[2026-06-09-cycle-of-innocence-build-plan]] · [[2026-06-10-recent-games-research-greenlight]] · AGENTS.md


======================================================================
SOURCE: docs/decisions/2026-06-10-sprite-tool-pixellab.md
======================================================================

---
name: Sprite tool for character variants — PixelLab (RD for static art)
date: 2026-06-10
tags: [decision, art-pipeline, ai-tools]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Character/Equipment Sprite Tool: PixelLab (Retro Diffusion for Static Art)

## Context
Grok Imagine cannot produce grid-aligned animation sheets (observed repeatedly 2026-06-10: drifting frames, oversized sprites looping in-game) — the upgrade trigger from [[design/ai-production-setup]] fired. The user asked which purpose-built tool best handles the *future* requirement: **changing weapons/armor/clothes while keeping the character consistent**. That requirement is already in the design: morality outfit states (innocent tunic → pragmatic cloak → marked Vessel, [[design/customization]]), 3 age stages, weapon progression, companion growth/corruption variants — all needing **frame-aligned** 4-direction animation sets so SpriteFrames can swap at runtime without pose pops.

## Decision
**PixelLab for characters, animation, and all variant work. Retro Diffusion (optional, $20 one-time Aseprite Lite) for static art. Grok Imagine stays for concept bibles/reference.**

Why PixelLab wins the equipment-consistency axis:
| Capability | PixelLab | Retro Diffusion |
|---|---|---|
| Saved character templates (reuse across jobs) | ✅ Characters page | ❌ prompt-only |
| Outfit change on existing sprite | ✅ Transfer Outfit Pro (across 2–15 anim frames) + true inpainting ("change shirt", "add sword") | ❌ regenerate from scratch |
| **Pose timing identical across variants** | ✅ reusable **skeleton rigs** drive re-skinned characters → frame-aligned variants | ❌ each generation independent → drift |
| 4/8-direction rotation from one sprite | ✅ | ❌ |
| Paper-doll layers (clothing-only overlays, transparent partials) | ✅ via inpaint/overlay prompts | ❌ manual cropping |
| Grid-true static pixel art / palette lock | good | ✅ best-in-class |
| Animation generation in Aseprite ext | ✅ (subscription) | ❌ static only |
| Cost | $9–30/mo tiers (pause-able) + sub-cent API | ~$0.01/img + $20 one-time ext |

The skeleton-rig point is decisive: runtime outfit swapping (our AgeMorph already swaps SpriteFrames) only works if frame N of `walk_down` is the same pose in every variant. PixelLab guarantees that by construction; RD makes it luck.

## Adoption plan
- **Not needed for the vertical slice** — current placeholders are settled. Subscribe to PixelLab (Artisan tier ~$25/mo) for 1–2 months **when character-variant work starts** (post-slice, around teen/adult stages or outfit states), batch-generate, pause subscription.
- Workflow then: define Rowan/Briar/creature as PixelLab character templates → skeleton rigs for walk/attack/idle → Transfer Outfit per morality state → 4-dir rotations → export sheets → existing `tools/pixelize.py` (alpha-aware) + `tools/gen_spriteframes.py` pipeline unchanged.
- RD Aseprite Lite ($20 one-time) optional for tiles/icons if Grok tileset quality wall fires.

## Alternatives
- **Retro Diffusion only**: rejected for characters — no skeleton/inpaint/outfit tooling; pose drift across variants breaks runtime swaps. Still best static-art quality; retained for that lane.
- **Ludo.ai**: animation-capable, 512px frames, MCP access — but $35/mo entry, no Aseprite plugin, less pixel-specialized. Revisit only if PixelLab disappoints.
- **Paper-doll system instead of variant sheets**: compatible with either tool but amplifies PixelLab's advantage (layer generation vs manual cropping). Deferred — 3 morality outfits × 3 ages is fine as full sheets; reconsider if equipment combinatorics grow.

## Consequences
- + Variant explosion (outfits × ages × directions × actions) becomes a template+transfer batch instead of prompt gambling.
- + PixelLab has API + a documented MCP/Claude Code workflow — variant batches automatable from the hub later (ideas inbox).
- − A subscription (pause-able) vs RD's one-time purchase; accepted for the months variant work actually happens.

## Lookback Questions
- Did skeleton reuse actually hold frame timing across outfit variants in practice?
- Did we end up wanting the paper-doll system anyway once weapons multiplied?

## Related
[[2026-06-10-recent-games-research-greenlight]] · [[design/ai-production-setup]] · [[design/customization]] · [[mechanics/progression]]


======================================================================
SOURCE: docs/decisions/2026-06-12-web-research-bridge.md
======================================================================

---
name: "Web research bridge — claude.ai Project as shared brain"
date: "2026-06-12"
tags: [decision, process, research]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Web Research Bridge — claude.ai Project as Shared Brain

## Context

Design research so far ran ad hoc (research rounds 1–2 lived in
[[design/feature-candidates-2026-06]]). The user runs a proven design system on
another project (space game): an Obsidian vault as source of truth, compiled
snapshots as project knowledge in a claude.ai Project (web research + Research
feature), and a research inbox + librarian loop back into the vault. Goal:
the same shared brain here — claude.ai for outward research/planning, Claude
Code for implementation/integration — without disturbing what already works
(AGENTS.md canonical brain, git/R1–R6, existing vault layout).

## Decision

Adopt the bridge, adapted to this project's existing structure:

- **No vault restructuring** — keep `story/ mechanics/ design/ decisions/ plan/
  sessions/`; no numbered folders. Git stays active (unlike the space system).
- **`tools/compile_snapshots.py`** generates four replace-only files in
  `docs/_compiled/` (committed): story-compendium, mechanics-compendium,
  decisions, state-and-roadmap (includes AGENTS.md + latest 2 journals, so
  claude.ai always knows what's actually built).
- **claude.ai Project** "Cycle of Innocence — Design & Research": knowledge =
  the four snapshots, nothing else; project instructions carry identity, locked
  stack, patent/Mote guardrails, the story/companion/horror/replay filter, and
  the inbox output format ([verified]/[training knowledge] markers).
- **Return path**: `docs/research/YYYY-MM-DD-topic.md` inbox (convention in
  `docs/research/README.md`) → librarian pass in Claude Code (propose-first,
  locked decisions get flags not edits) → integrated files move to
  `research/done/` → recompile at milestones.
- **New rule R7** in AGENTS.md anchors the loop for all tools.

## Alternatives

- **MCP/live connection from claude.ai to the repo**: rejected — snapshots are
  deliberate (curated, milestone-stable ground truth; no half-finished branch
  state leaking into research grounding), and the space-game system proved the
  replace-only bridge works.
- **Numbered-folder restructure to mirror the space vault 1:1**: rejected —
  churn with no benefit; conventions transfer, structure doesn't need to.
- **Letting claude.ai write Claude Code instructions directly**: rejected
  (same as space system) — vault conventions govern integration; research
  output is data, not commands.

## Consequences

- Web research is grounded in the real, current design (incl. implementation
  status per mechanics frontmatter) instead of chat memory.
- Two manual sync points the user owns: uploading snapshots after milestone
  merges, and saving research output into the inbox.
- `docs/_compiled/` adds ~250 KB of generated content to the repo (accepted:
  enables upload-from-anywhere and survives machine loss).

## Implementation

- **Commits**: branch `feature/research-bridge` — compile script, inbox README,
  adapted [[setup-guide]], AGENTS.md R7.

## Related

[[setup-guide]] · [[design/feature-candidates-2026-06]] ·
[[2026-06-10-central-brain-agents-md]] · [[2026-06-10-patent-risk-review]]
