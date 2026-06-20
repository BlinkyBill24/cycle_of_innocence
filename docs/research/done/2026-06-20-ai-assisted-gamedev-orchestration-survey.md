---
name: ai-assisted-gamedev-orchestration-survey
date: 2026-06-20
source: Claude Opus 4.8 + extended web research
prompt: >
  Thorough 2026 state-of-the-art survey of AI-assisted solo indie game development,
  with Claude Code + Claude (web/desktop) as the central orchestrators but covering
  the FULL AI stack (art, audio, narrative, legal/platform) for a solo dev building a
  2D top-down pixel-art RPG in Godot 4.4 (typed GDScript; Web/HTML5 hard constraint
  ruling out C#; Linux + Android; Dialogue Manager + LimboAI). Cover: (1) Claude Code
  for game dev — strengths/weaknesses, prompting, CLAUDE.md/context mgmt, plan/verify
  loop, subagents/Dynamic Workflows/ultracode, cost, failure modes; (2) Godot 4.4 +
  GDScript LLM pitfalls, addon integration, Web-export constraints, Godot AI tooling/MCP;
  (3) AI art/sprite/tileset pipeline + style consistency + per-tool licensing;
  (4) AI audio/music/VO + commercial-licensing status; (5) AI for narrative/design +
  single-source-of-truth discipline; (6) orchestration/workflow meta + shipped
  postmortems; (7) 2026 legal/IP/platform landscape. Verifiable current sources;
  distinguish verified from training knowledge; flag perishable facts. Broader
  transferable survey, full-orchestration scope (not project-anchored).
status: integrated
integrated: 2026-06-20 (branch docs/research-orchestration-survey) — mostly confirmatory; see integration log at foot
---

# AI-Assisted Solo Indie Game Development: A 2026 State-of-the-Art Survey

Claude Code + Claude at the center, covering the full AI orchestration stack for a solo dev shipping a 2D top-down pixel-art RPG in Godot 4.4 (typed GDScript; Web/HTML5, Linux, Android targets; Dialogue Manager + LimboAI).

## TL;DR

- A solo dev can realistically orchestrate an end-to-end pipeline in mid-2026 — Claude Code for implementation, Claude web/desktop for design/research, plus PixelLab/Retro Diffusion for art and ElevenLabs/Suno for audio — but the binding constraint is no longer code generation; it is the human's ability to review, curate, and keep authored content (level design, balance, narrative coherence) ahead of what the AI can produce. Treat AI as leverage on a human director, not autopilot. `[training knowledge]`
- The hard Web/HTML5 constraint is the single most important technical guardrail: it permanently rules out C#/.NET, pushes toward single-threaded export defaults, the WebGL2/Compatibility renderer, and Sample-mode audio — and LLMs frequently generate code that violates these. Encode the rules in CLAUDE.md and verify with a headless boot check on every change. `[verified 2026-06-20]` (Godot Web-export constraints) / `[training knowledge]` (the guardrail framing)
- Legal status is settled at the extremes and unsettled in the middle: AI-generated code used as a dev tool needs no Steam disclosure and raw AI output isn't copyrightable (Thaler, cert denied 2026-03-02), but player-facing AI art/audio/text must be disclosed on Steam, and the big training-data lawsuits (Andersen v. Stability AI, trial 2026-09-08; Sony v. Suno, summary-judgment hearing July 2026) are live. Pick license-clean tools and document human authorship. `[verified 2026-06-20]`

## Key Findings

1. Claude Code is genuinely strong at game *systems* code and weak at game *feel*. It excels at state machines, save/load, signal/event buses, inventory, UI scaffolding, and tests; it struggles with anything requiring play-feel judgment (tuning, juice, balance), with Godot 3-vs-4 API drift, and with respecting addon conventions. The human stays in the loop on architecture, tuning, and verifying the game actually runs. `[training knowledge]` (synthesis, grounded in the community sources below)
2. The dominant failure mode is context/architecture drift, not bad syntax. Practitioner sources converge on the same discipline: plan before implementing, keep diffs small, manage context aggressively (CLAUDE.md, /clear, /compact, subagents), and demand evidence (test output, headless boot, screenshots) rather than the model's assertion of success. `[verified 2026-06-20]` (official + community practice) / `[training knowledge]` (synthesis)
3. Claude Code ships extremely fast — version-gate everything. As of June 2026 the current flagship is Claude Opus 4.8 (released 2026-05-28), with Dynamic Workflows and the "ultracode" setting (v2.1.154+). These are powerful but token-hungry and overkill for most solo game-dev tasks. Anything here about specific Claude Code features may be outdated within weeks. `[verified 2026-06-20]` (with the model-naming caveat in Caveats)
4. The pixel-art consistency problem is solved "well enough" by purpose-built tools, not general models. PixelLab and Retro Diffusion produce real on-grid pixel art with reference-based consistency and directional/animation tooling; general models (Midjourney, DALL·E) produce "pixel-look" art that falls apart on the grid. The shipped pattern is generate-many → curate → hand-finish in Aseprite. `[verified 2026-06-20]` (tool capabilities) / `[training knowledge]` (the generate-curate-finish pattern)
5. AI audio is production-ready but legally bifurcated. ElevenLabs Music and Stable Audio ship clean commercial licenses (licensed training data); Suno and Udio sound best but carry partly-unsettled litigation. For a commercial game, prefer license-clean tools or accept documented risk. `[verified 2026-06-20]`
6. Real solo devs are shipping commercial games with heavy AI assistance — the clearest case is *Fire Field*, a Diablo-like ARPG built in ~3 months with Claude Code generating ~120,000 lines — but every credible account stresses that debugging, balancing, and iteration remain human bottlenecks. AI compresses build time, not the need for judgment. `[verified 2026-06-20]`

## Details

### (1) Claude Code for game dev

What it's good at / bad at. In a game-dev context Claude Code is most reliable on self-contained systems with clear correctness criteria: finite state machines, signal/event buses (autoload singletons in Godot), save/load serialization, inventory and stats, menu/UI scaffolding, and unit tests — the tasks where it can show evidence it worked. It is least reliable where success is a matter of feel (movement tuning, combat juice, difficulty balance), where the correct answer depends on unwritten design intent, and where it must respect a third-party addon's conventions rather than reinventing them. `[training knowledge]` The Godot community's repeated caution is that an LLM is typically more hindrance than help when you're just getting started, because you can't catch its hallucinations until you understand the engine yourself. `[verified 2026-06-20]`

Prompting and the plan/implement/verify loop. The official Claude Code best-practices guidance is explicit about separating research/planning from implementation (plan mode separates exploration from execution) and about demanding evidence — the test output, the exact command run and what it returned, or a screenshot of the result — rather than the model's assertion that it worked. `[verified 2026-06-20]` For a Godot project, "evidence" means: the game boots headless without errors, GdUnit4 tests pass, and ideally a screenshot from an automation tool. Structure goal-prompts as (a) state the goal and locked constraints, (b) point at the specific files/scenes in scope, (c) ask for a plan first, (d) implement in a small diff, (e) verify with a named command. `[training knowledge]`

Context and memory management. CLAUDE.md is the project's constitution — loaded every session, high-priority, and re-injected after compaction (project-root CLAUDE.md survives /compact; nested ones reload when touched). Keep it to durable facts: build/export commands, the typed-GDScript style rule, "Web export is a hard constraint — never use C#, never use threads-by-default APIs," directory layout, and locked architectural decisions. `[verified 2026-06-20]` (CLAUDE.md behavior) Files over ~200 lines degrade adherence; use path-scoped rules and skills for detail not needed every session. `[verified 2026-06-20]` Since v2.1.59, Claude Code also keeps an auto-memory MEMORY.md it writes itself (200-line cap on the primary file). `[verified 2026-06-20]` Use /context to see token usage, /clear between unrelated tasks (community-reported to cut per-message token cost ~30–50%), and git worktrees to run parallel sessions on isolated branches. `[verified 2026-06-20]` (features) / `[training knowledge]` (the 30–50% figure is a community report, not an Anthropic number)

Subagents, background sessions, agent teams, Dynamic Workflows (ultracode). Subagents are isolated Claude instances spawned by the main session with their own context window, tools, and model; built-ins include Explore (read-only, Haiku, search), Plan, and a general-purpose worker, and they keep heavy codebase-reading out of the main context. `[verified 2026-06-20]` The trade-off: Anthropic notes subagent-heavy workflows can consume around 7× the tokens of a single-thread session; 3–5 concurrent is the practical sweet spot. `[verified 2026-06-20]` Dynamic Workflows (launched 2026-05-28, v2.1.154, research preview) let the lead write a JavaScript orchestration script that fans out tens to hundreds of subagents (cap: 16 concurrent, 1,000 total) running in the background, with adversarial verification. `[verified 2026-06-20]` "ultracode" (the keyword was renamed from "workflow" in v2.1.160, 2026-06-02) is a Claude Code setting that sends xhigh reasoning effort plus auto-orchestrates a workflow for substantive tasks. `[verified 2026-06-20]` For solo game dev these are mostly overkill — they shine on big migrations and codebase-wide audits, not on tuning a player controller — and they have no default spend cap (one Hacker News user reported spinning up 62 Opus 4.8 subagents and hitting the 5-hour cap in 18 minutes). `[verified 2026-06-20]` (the HN figure is a practitioner anecdote, not an Anthropic figure) / `[training knowledge]` (the "overkill for solo game dev" judgment) Use /effort high for routine work; reserve ultracode for genuine fan-out tasks. `[training knowledge]`

Cost/quota discipline for a solo dev. A Claude Pro subscription (~$20/mo) includes a Claude Code quota; one Godot RTS hobbyist reported the Pro quota was manageable until exhausted, then you wait or switch accounts. `[verified 2026-06-20]` Tier models (Opus for hard reasoning, Sonnet for most work, Haiku for search/lint), stop idle sessions, /clear between tasks, and codify model limits in subagent YAML so you don't default everything to Opus. `[training knowledge]`

Failure modes and guardrails. The recurring game-dev failure modes: hallucinated Godot APIs/classes, over-engineering simple systems, silently breaking working code, and drifting from the locked architecture. `[training knowledge]` Guards: (a) a headless boot check (`godot --headless --quit`) and GdUnit4 tests as the definition of done; (b) small diffs and frequent commits so you can revert; (c) "locked-decision discipline" — record architectural decisions in CLAUDE.md so the model can't relitigate them; (d) a fresh-context review subagent (or the bundled /code-review skill) to check the diff against your plan; (e) PreToolUse hooks for hard rules (e.g., block writes that introduce C# files). `[verified 2026-06-20]` (the mechanisms exist) / `[training knowledge]` (the guard recipe) Community wisdom: context degradation is the primary failure mode, and simple control loops tend to outperform multi-agent systems. `[verified 2026-06-20]` (community-reported)

Godot-specific Claude tooling. There is a growing ecosystem of Claude Code skills/plugins for Godot (e.g., a Randroids-Dojo Godot skill with GdUnit4 + PlayGodot automation; a "Claude Code Game Studios" pack reporting 49 agents / 73 skills; the godogen autonomous generator). `[verified 2026-06-20]` Note that some of these assume C#/.NET (e.g., godogen's Godot output and the IvanMurzak Godot-MCP, which requires the mono/C# build) — incompatible with the Web target. `[verified 2026-06-20]` There are also several Godot MCP servers (Coding-Solo's godot-mcp via npx; the GDAI MCP plugin; "Godot MCP Pro" at $15 one-time) that let the agent drive the editor, run the project, read errors, and take screenshots — closing the see-the-result loop. MCP support generally requires Godot 4.4+. `[verified 2026-06-20]` (specific tool names/prices should be reconfirmed — they change)

### (2) Godot 4.4 + typed GDScript specifics

How well LLMs know Godot 4.x. The consistent 2026 assessment: Claude Opus is the strongest model for GDScript, with GPT close behind. `[verified 2026-06-20]` (community assessment) The hardest problem is not intelligence but stopping the model from writing Godot 3 — the public internet is full of Godot 3 tutorials, so models confidently emit deprecated syntax (old `yield`/coroutine patterns, `KinematicBody2D` instead of `CharacterBody2D`, the `export` keyword instead of `@export`, `.connect()` string-signal syntax). A single deprecated call can break a whole script. LLMs also confuse GDScript with C# answers and invent class names/methods. `[verified 2026-06-20]` (the Godot-3 drift problem) / `[training knowledge]` (the specific failure catalogue)

Mitigations. Pin the version in CLAUDE.md ("Godot 4.4, typed GDScript, @export/@onready annotations, signal Callable syntax"); require static typing everywhere (it makes hallucinated APIs fail fast at parse time); use a Godot-specific system prompt/skill; and verify against the running editor (MCP) or headless boot rather than trusting compiled-looking code. Godot's human-readable .tscn/.tres and project.godot files help — they're diffable in version control, so both you and the LLM can track accidental changes. `[training knowledge]` (with .tscn/.tres being text-based `[verified 2026-06-20]`)

The named addons.
- Dialogue Manager (Nathan Hoad, MIT, Godot 4.4+) is a mature, stateless branching-dialogue addon with its own script-like syntax and an in-editor editor with syntax error reporting; its DialogueLabel extends RichTextLabel (so BBCode works). Free on GitHub/Asset Library; $10+ on itch as a way to support the author. `[verified 2026-06-20]` The AI risk is that it will try to hand-roll a dialogue system or fight the addon's `.dialogue` syntax — feed it the addon's docs and instruct it to use the runtime API, not reinvent it. `[training knowledge]`
- LimboAI (limbonaut, MIT) provides Behavior Trees + hierarchical State Machines for Godot 4, implemented in C++ but fully usable from GDScript for custom tasks/states. `[verified 2026-06-20]` Critically: it ships as either a C++ module or a GDExtension shared library, and projects stay compatible with both — but you must verify the GDExtension build exports cleanly to Web, as GDExtension Web support has historically been fragile. `[verified 2026-06-20]` (dual-build) / `[training knowledge]` (the Web-fragility caution) Keep AI from inventing its own state machine when LimboAI tasks are the convention. `[training knowledge]`

Web/HTML5 export constraints AI gets wrong. This is the highest-risk area. Per Godot docs: C# cannot be exported to Web in Godot 4 (an architectural .NET limitation) — a hard wall. `[verified 2026-06-20]` As of Godot 4.3, single-threaded export is the default and recommended mode; threading requires SharedArrayBuffer, which needs cross-origin-isolation headers (COOP/COEP) that many hosts (GitHub Pages, itch basic hosting) don't allow — the workaround is a PWA service worker or the coi-serviceworker library. `[verified 2026-06-20]` Godot 4 Web targets WebGL2 via the Compatibility renderer only (Forward+ won't run); community best practice is to choose Compatibility, since players prefer good graphics that work over amazing graphics that crash. `[verified 2026-06-20]` Audio defaults to Sample mode (Web Audio API, low latency) since 4.3, which lacks AudioEffect, reverberation, Doppler, and procedural audio — to get effects you must set Default Playback Type to Stream at a latency cost. `[verified 2026-06-20]` Other gotchas: keep file sizes small (Basis Universal texture compression), never run heavy work in `_process()` (the browser will kill a long frame), and Godot 4 Web historically had macOS/iOS Safari issues with SharedArrayBuffer and WebGL2. `[verified 2026-06-20]` AI tools frequently suggest threads, C#, Forward+ shaders, and WebGL1-incompatible dynamic-loop shaders — all of which break the build. Encode "web-safe" rules in CLAUDE.md and test the actual web export, not just the desktop run. `[training knowledge]`

### (3) AI art / sprite / tileset pipeline

State of the art for consistent 2D pixel art. The market has bifurcated into purpose-built pixel tools vs. general image models. PixelLab is the most complete game-asset tool: text-to-pixel, skeleton-based animation, directional rotations from a reference, tilesets/maps, a reference-based consistency model, a browser app and Aseprite plugin, and an API for in-game/live generation. `[verified 2026-06-20]` Retro Diffusion (Astropulse) uses a FLUX-based model trained on licensed pixel art plus a proprietary downscaling/quantization step to hit true grid alignment and limited palettes; runs via web app or a local Aseprite extension. `[verified 2026-06-20]` Scenario is strongest at style training — upload reference assets, train a custom model, generate matching assets across types — but is not pixel-art-first. `[verified 2026-06-20]` ComfyUI + ControlNet (with pixel-art LoRAs) gives maximum control for those willing to manage the local pipeline. Grok Imagine and other general models can produce pixel-looking output but aren't grid-faithful. `[training knowledge]` (with PixelLab/Retro Diffusion/Scenario specifics `[verified 2026-06-20]`)

The consistency problem (style/palette/perspective drift). The core unsolved-by-default problem: diffusion models trained on photos break hard edges, limited palettes, and grid alignment. `[training knowledge]` Teams solve it with (a) reference-locked generation (PixelLab "characters" lock a sprite; references extend to tiles); (b) custom-trained style models (Scenario, local LoRAs); (c) palette enforcement and quantization post-processing; and (d) the universal pattern from shipped 2026 indie games: generate many sprite variations, pick the best, refine in a pixel editor. `[verified 2026-06-20]` (the generate-curate-refine pattern is reported) / `[training knowledge]` (the taxonomy) For a top-down RPG you'll want a fixed palette, fixed camera angle, and a character reference established early and reused. `[training knowledge]`

Licensing / ownership / training-data status (per tool).
- PixelLab — Terms of Service grant output ownership: "You own the copyrights to your creations", with commercial and non-commercial use permitted and no separate permission required; outputs may not be used to train other models. Commercial licensing included on all paid plans; free trial, then tiers from ~$12/mo. `[verified 2026-06-20]`
- Retro Diffusion — The model is trained on licensed assets from Astropulse and other pixel artists with their consent. The developer's official position: the code and models are owned by Astropulse LLC and may not be used commercially (i.e., you can't resell the software/model), but the *outputs* are owned by whoever generates them. Pay-per-credit web app (50 free credits) plus a one-time-purchase local Aseprite extension. No IP indemnification (warranty disclaimed). `[verified 2026-06-20]` (ToS could not be retrieved verbatim — see Caveats)
- Scenario — Terms (updated 2026-02-23) assign output rights to the user ("You own your Generated Assets"); generations from public foundation models are cleared for commercial use, while custom-trained models put training-data rights on you. Paid plans include a full commercial license; the free tier is personal/eval only. Pricing from ~$15/mo. `[verified 2026-06-20]`
- Grok / xAI — Consumer ToS: "you retain your ownership rights to the User Content"; outputs are usable commercially (attribution to Grok requested). No IP indemnification (user accepts liability); terms are vaguer and the product has been under regulatory scrutiny — higher risk for serious commercial work. `[verified 2026-06-20]`
- Adobe Firefly — Positioned as commercially safe: trained on licensed content (Adobe Stock) plus public-domain/expired-copyright content, does not train on user content, and offers IP indemnification for paid/enterprise users on native Firefly models only (not integrated partner models like Veo/Runway). The safest legal choice, though not pixel-art-specialized. `[verified 2026-06-20]`

Platform policy (Steam): see §7.

### (4) AI audio / music / dialogue-VO

Music. The 2026 landscape: Suno (v5/v5.5) and Udio are the quality/feature leaders but carry partly-unsettled licensing — both were sued by the RIAA/major labels in 2024. Warner Music settled with Suno on 2025-11-25 (with Suno also acquiring Warner's Songkick), and UMG settled with Udio on 2025-10-29; Sony is the lone major-label holdout, with a pivotal *Sony v. Suno* summary-judgment hearing set for July 2026 before Chief Judge F. Dennis Saylor IV (D. Mass.). `[verified 2026-06-20]` ElevenLabs Music (v2, 2026-05-27) and Stable Audio ship clean commercial licenses built on licensed training data — ElevenLabs has licensing deals with Merlin and Kobalt. `[verified 2026-06-20]` For a commercial game, the practitioner pattern is to use Suno/Udio for prototypes/internal music and ship ElevenLabs Music to clients/players. `[training knowledge]` Note Suno's terms disclaim copyright ownership in outputs and offer no indemnification. `[verified 2026-06-20]` Google Lyria RealTime is notable for adaptive music that responds to gameplay (real-time instrumental streaming via WebSocket). `[verified 2026-06-20]` Meta MusicGen (MIT) is the self-host option. `[verified 2026-06-20]`

SFX. ElevenLabs' text-to-SFX generator produces game sound effects from text prompts (up to 30s, with a loop parameter for ambience), via a REST API for batch generation, with a royalty-free commercial license on paid plans. `[verified 2026-06-20]` Adobe Firefly's sound-effects generator is trained only on licensed and public-domain data, so outputs are commercially safe. `[verified 2026-06-20]`

Voice/dialogue VO. ElevenLabs is the dominant TTS/voice engine in 2026; usable for NPC barks and full VO. For a branching-dialogue RPG, generate per-line VO keyed to your Dialogue Manager lines. `[verified 2026-06-20]` (ElevenLabs position) / `[training knowledge]` (the per-line workflow)

Web-export audio considerations. Tie back to §2: Godot Web defaults to Sample mode with no effects/reverb/procedural audio. Pre-bake any effects into your audio files, keep stems short and compressed, and avoid runtime DSP that won't work in Sample mode. Adaptive-music layering (e.g., crossfading stems) works but test latency in-browser. `[verified 2026-06-20]` (Sample-mode limitation) / `[training knowledge]` (the workflow advice)

### (5) AI for writing / narrative / design

Claude (web/desktop) is well-suited as a research and design partner feeding the implementation tool — narrative design, branching dialogue drafts, lore/worldbuilding, quest design, playtest-feedback analysis, and design research. One worldbuilder reported generating a ~90-page world bible in a single session using a structured Claude skill. `[verified 2026-06-20]` (single anecdote) / `[training knowledge]` (the partner-role framing)

The single-source-of-truth discipline is the make-or-break pattern. The recurring failure (documented in the StormTome worldbuilding project) is context drift: as a world grows past the model's window, names and facts mutate and the model contradicts itself; Claude tends to stop at its limit, ChatGPT drifts. The solution is to keep authoritative lore/design in an external store (a docs/ folder, Obsidian, or a wiki) and have the LLM read from and write to it rather than holding everything in conversation — the StormTome team did this via a Claude MCP bridge to Confluence (which worked, imperfectly). `[verified 2026-06-20]` For your workflow: keep a docs/ vault in-repo as the canonical design bible, have Claude web/desktop produce *research artifacts* there, and feed *only the relevant, finalized slice* to Claude Code as implementation instructions. Separate "what the world is" (vault) from "what to build next" (task spec). `[training knowledge]`

Patterns. Use Claude Projects or Claude skills to encode reusable design templates (quest schema, a dialogue-node format that matches Dialogue Manager syntax, character sheets). Have Claude analyze playtest notes for patterns rather than asking it to invent balance numbers blind. `[training knowledge]`

### (6) Orchestration / workflow meta

Division of labor for a solo dev:
- Claude web/desktop → research, narrative/design, lore, quest outlines, playtest analysis; output lands in the docs/ vault.
- Claude Code → implementation against typed-GDScript and web-safe rules, tests, refactors, headless verification.
- PixelLab/Retro Diffusion (+ Aseprite) → sprites, tilesets, animations; curate + hand-finish.
- ElevenLabs (Music/SFX/VO) / Stable Audio → license-clean audio, pre-baked for Web.
- Dialogue Manager → the canonical store of dialogue content (not the LLM).
`[training knowledge]` (recommended allocation; tool capabilities `[verified 2026-06-20]`)

Hand-off pattern: design in the vault → distill a scoped task spec → Claude Code plans → implements a small diff → verifies (boot + tests + screenshot) → you review → commit. Keep research artifacts (open-ended exploration) physically separate from implementation instructions (locked, scoped) so the agent doesn't treat speculation as a spec. `[training knowledge]`

The cardinal risk: AI outrunning authored content. Because AI makes systems cheap, the danger is a game with twenty mechanics and no coherent level, quest, or balance design behind them. Discipline: gate system work behind authored content — don't build a crafting system until there's a designed reason to craft. AI is bad at creative coherence — making sure every element feels like it belongs in the same world. `[verified 2026-06-20]` (the coherence-weakness observation is reported) / `[training knowledge]` (the gating discipline)

Cost/time realism. The subscription stack is modest (Claude Pro ~$20/mo, PixelLab ~$12+/mo, ElevenLabs and Scenario tiers, optional Godot MCP ~$15 one-time). The real cost is human review time. *Fire Field*'s solo dev slept ~3 hours/night for three months; AI compressed implementation but did not eliminate the core work — testing, debugging, balancing, and iteration are still required. `[verified 2026-06-20]`

What actually shipped (2024–2026).
- Fire Field (Naoki Fujinaga, 2026): a commercial Diablo-like ARPG on Steam, built solo in ~3 months. Fujinaga — a 45-year-old Japanese developer with no prior game-dev experience — told KoreaGameDesk he wasn't counting lines of code and only learned he had generated around 120,000 lines after someone asked on X, with Claude Code generating the majority of the code while he acted as "director and integrator." He slept ~3 hours/night, shipped 95 subtitle languages / 70 dubs on a custom (non-Unity/Unreal) engine, and named debugging — bugs growing exponentially as features were added — as the hardest part. `[verified 2026-06-20]`
- GameMaker officially integrated Claude Code in 2026 to enable AI-assisted ("vibe coding") workflows — a signal that engine vendors are baking this in. `[verified 2026-06-20]`
- Numerous Godot+Claude hobbyist reports (e.g., a "Building an RTS in Godot" dev series) document both rapid systems development and the loss-of-control risk — one author scrapped his AI experiment because he had lost complete touch with the underlying code. `[verified 2026-06-20]`

### (7) Legal / IP / platform landscape (2026)

Copyrightability of AI output. Settled at the extremes: raw AI output with no meaningful human authorship is not copyrightable. In *Thaler v. Perlmutter* the DC Circuit affirmed the human-authorship requirement (130 F.4th 1039, March 2025), and the Supreme Court denied certiorari on 2026-03-02 (No. 25-449), leaving that ruling intact — which Holland & Knight characterized as the end of the road for Thaler. `[verified 2026-06-20]` The US Copyright Office's January 2025 Part 2 report holds that prompts alone are insufficient — prompts function as instructions conveying unprotectable ideas. `[verified 2026-06-20]` But AI-assisted works can be registered where human contribution is sufficiently creative: on 2025-01-30 the Office registered "A Single Piece of American Cheese" (to Invoke AI, Inc.; CEO Kent Keirsey) as a copyrightable compilation/arrangement, finding sufficient human authorship in the selection, arrangement, and coordination of the AI-generated material; Keirsey had performed 35+ rounds of inpainting and submitted a time-lapse video as evidence of his creative process. `[verified 2026-06-20]` Practical takeaway: document your human authorship (selection, arrangement, hand-editing of sprites, original code architecture, written narrative) and you can likely protect the *game as a whole* even if individual raw AI assets aren't independently protectable. *Allen v. Perlmutter* (a 600-prompt image) is still pending and may sharpen the line. `[verified 2026-06-20]` (case status) / `[training knowledge]` (the takeaway)

Training-data lawsuits (live). *Andersen v. Stability AI* (artists v. Stability, Midjourney, DeviantArt, Runway) survived motions to dismiss on key copyright claims (2024-08-12); a third amended complaint was filed 2026-02-27, and the case has moved into discovery with trial set to begin 2026-09-08 — potentially precedent-setting on whether training on scraped art and "in the style of" outputs infringe. `[verified 2026-06-20]` Music: the Suno/Udio label settlements above resolve some exposure, but *Sony v. Suno* heads to a summary-judgment hearing in July 2026. `[verified 2026-06-20]` This is why tool choice matters: license-clean tools (Adobe Firefly, ElevenLabs, Stable Audio, and the consent-trained PixelLab/Retro Diffusion models) insulate you from the worst-case training-data fallout; tools trained on scraped data carry residual risk you inherit (most offer no indemnification). `[training knowledge]` (the risk-allocation judgment)

Storefront disclosure (Steam, 2026). Steam's AI policy (launched January 2024) was rewritten 2026-01-17 to focus on player-facing content. Two categories require disclosure: Pre-Generated (AI-made assets that ship in the game) and Live-Generated (AI content created at runtime, which also requires guardrails plus a player-report button in the Steam overlay). `[verified 2026-06-20]` Crucially: AI coding assistants are explicitly exempt — the rewritten policy puts AI-tool efficiency gains outside the scope of disclosure, and third-party analysis confirms code from assistants like Copilot, Claude Code, Cursor, and Cody is exempt. `[verified 2026-06-20]` So Claude Code use needs no disclosure, but AI-generated sprites, music, SFX, VO, or lore that ship in the game must be disclosed under "About This Game." Over 7,300 Steam games had disclosed AI content as of March 2026 (StraySpark); the AI and Games newsletter counted 4,311 disclosures by end of 2025 (~22% of the 20,004 games released that year), and Valve has begun enforcing with page removals. `[verified 2026-06-20]` There is no bright-line threshold for "how much editing removes the obligation" — keep your AI originals, revision history, and final versions. Concept art used only as internal reference (not shipped) does not require disclosure. `[verified 2026-06-20]` (Steam guidance) / `[training knowledge]` (the record-keeping advice) itch.io has no comparable mandatory generative-AI disclosure (it added an optional AI-disclosure field), and the Epic Games Store has no AI disclosure requirement (Tim Sweeney argues such labels are becoming meaningless); mobile stores (Google Play/Android) are developing frameworks but have no Steam-equivalent generative-content disclosure as of mid-2026 — verify at submission time. `[verified 2026-06-20]`

Jurisdictional uncertainty. The UK (Getty v. Stability, November 2025; the s.9(3) "computer-generated works" provision untested for modern AI) and the EU diverge from the US. Fair-use-for-training is explicitly unresolved — the Copyright Office's Part 3 report says some training will qualify as fair use and some won't. Treat this section as a snapshot, get your own legal advice for a commercial launch, and re-check before shipping. `[verified 2026-06-20]` (case/report status) / `[training knowledge]` (the advice)

## Recommendations

Stage 0 — Set the guardrails before generating anything (week 1).
1. Write a CLAUDE.md that locks: Godot 4.4, typed GDScript everywhere, "Web/HTML5 is a hard constraint: no C#, no default-threaded APIs, Compatibility/WebGL2 renderer, Sample-mode-safe audio," export commands, directory layout, and "use Dialogue Manager / LimboAI APIs — do not reinvent them."
2. Stand up a docs/ vault as the single source of truth, and a headless boot check + GdUnit4 test harness as your definition of done.
3. Decide art and audio tools on a license-clean-first basis: PixelLab or Retro Diffusion for sprites (both grant output ownership), ElevenLabs/Stable Audio for audio. Keep all AI originals and edit history for Steam disclosure.

Stage 1 — Establish style and content spine before systems (weeks 2–4). Lock a palette, camera angle, and a character reference in your art tool. Draft the core narrative/world in the vault with Claude web/desktop. Resist building systems until there's authored content that needs them.

Stage 2 — Implement in small, verified loops. Plan mode → small diff → headless boot + tests + screenshot → review → commit. Default to /effort high; reserve ultracode/Dynamic Workflows for genuine fan-out (a big refactor), and set an explicit token budget when you do. Use a fresh-context review subagent before counting work done.

Stage 3 — Integrate audio/art web-safely and disclose. Pre-bake audio effects (Sample-mode limitation). Test the web export on every milestone, not just desktop. Fill out Steam's Generative AI content survey for all shipped AI art/audio/text; leave code undisclosed (exempt).

`[training knowledge]` for the staged plan (synthesis); the constraints and policy facts it rests on are `[verified 2026-06-20]`.

Benchmarks that should change the approach:
- If the web export breaks or stutters → drop to Compatibility renderer, single-threaded, Basis Universal textures, and audit for C#/thread/shader violations the AI introduced.
- If Claude Code starts breaking working code or relitigating decisions → context is polluted; /clear, tighten CLAUDE.md, shrink diffs.
- If token/quota burn spikes → you're over-using subagents/ultracode; tier down models and disable auto-orchestration.
- If the Andersen v. Stability AI trial (2026-09-08) or the Sony v. Suno hearing (July 2026) lands adversely → re-audit any scraped-data-trained assets and prefer license-clean/indemnified tools.
- If systems are outrunning authored content → stop building mechanics and design levels/quests/balance.

## Caveats

- Reliability markers used in this file: `[verified 2026-06-20]` = backed by a source retrieved during this research pass (official docs, tool ToS/pricing pages, case dockets, reputable dev coverage), checkable via the Sources list below. `[training knowledge]` = synthesized judgment or general practice not tied to a specific source retrieved this pass. This was a single research pass with no second-model corroboration, so nothing is marked `[cross-model]`; that marker is reserved for findings confirmed across models.
- Fast-moving facts (treat as perishable): Claude Code features (Opus 4.8, Dynamic Workflows, ultracode, version numbers like v2.1.160) are from May–June 2026 and change weekly; AI art/audio tool pricing, model versions, and license terms change frequently. Re-verify on official pages before relying on any specific number.
- Source quality: claims about Claude Code internals and "ultracode token burn" include practitioner anecdotes (Hacker News) that are not Anthropic figures — illustrative, not guaranteed. Some Claude Code "model" names surfaced in search (e.g., "Claude Fable 5," "Mythos") appear in secondary blogs and should be treated skeptically against official Anthropic announcements.
- Legal content is not legal advice and is unsettled in the middle of the spectrum (how much human input confers copyright; whether training is fair use). Jurisdictions diverge. Get professional advice before a commercial launch.
- GDExtension on Web: LimboAI's GDExtension Web-export reliability should be tested early on your actual toolchain; do not assume it just works.
- The consistency and coherence problems are real and only partially solved — budget human curation time for art-style drift and for keeping the game's design coherent.
- Retro Diffusion ToS could not be retrieved verbatim from the website (JS-rendered); the ownership language is from the bundled EULA and the developer's official product-page statement. Several pricing figures (Retro Diffusion extension, Grok tiers, Scenario Pro, Firefly standalone, Godot MCP) come partly from third-party sources and should be reconfirmed on official pages.
- Frontmatter judgment calls: `date` is the date produced (2026-06-20); adjust if your convention is date-requested vs date-filed. `name` and `source` are defaults — rename on filing if the vault has a different slug/provenance convention.

## Sources

Verifiable URLs captured this pass (a subset — the legal-case, Godot-docs, Steam-policy, and Fire-Field facts were drawn from research coverage whose primary sources should be reconfirmed at filing):

- PixelLab Terms of Service — https://www.pixellab.ai/termsofservice
- Retro Diffusion (Astropulse) — https://astropulse.itch.io/retrodiffusionai and https://astropulse.itch.io/retrodiffusion
- Scenario FAQ — https://help.scenario.com/en/articles/frequently-asked-questions-faq/
- xAI Terms of Service (Consumer) — https://x.ai/legal/terms-of-service ; xAI FAQ — https://x.ai/legal/faq
- Adobe Firefly / Stock responsible-AI statement — https://blog.adobe.com/en/publish/2024/04/16/growing-responsibly-age-of-ai-adobe-firefly-stock

---

## Librarian integration log (2026-06-20, branch `docs/research-orchestration-survey`)

Processed per `docs/research/README.md` (propose-first). This is a **broad
transferable survey**, ~80% **confirmatory** of practice already locked here
(TradeForge single-source-of-truth + R7, the plan→verify→evidence loop, Web as a
hard constraint, the PixelLab generate-curate-finish pipeline). Human ruling:
integrate the **focused web-export slice + ideas**, **full refresh** of Store
compliance. Four-pillar filter: the bulk is meta/process, not story/companion/
horror/replay, so it is intentionally **not** integrated — it stays here.

- **`docs/design/ai-production-setup.md`** — new **"Web-export constraints"**
  subsection (Sample-mode audio has no `AudioEffect`/reverb/procedural → pre-bake,
  no runtime DSP; single-threaded default + COOP/COEP / `coi-serviceworker` for
  threads; Compatibility/WebGL2 only; Basis Universal textures; no heavy
  `_process`; **verify LimboAI GDExtension Web export early**). **"Store
  compliance"** fully refreshed with the 2026 legal/Steam timeline (dated
  snapshot, not legal advice).
- **`docs/ideas.md`** — verify LimboAI Web export (locked-stack risk); keep
  AdaptiveAudio Sample-mode-safe (currently clean — no effects); one-line note
  that the survey validates the existing SSOT + plan/verify + PixelLab pipeline.
- **Not integrated (by design):** Claude Code orchestration meta (subagents/
  ultracode/Dynamic Workflows, `/clear`, model tiers), perishable model/version
  facts, and the shipped-postmortems — confirmatory or out-of-scope; they remain
  in this filed survey if ever needed.
