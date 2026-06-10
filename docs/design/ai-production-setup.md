---
name: AI Production Setup (FOSS-first)
date: 2026-06-10
tags: [design, pipeline, ai-tools, licensing]
status: active
related_decisions: [[decisions/2026-06-10-new-features-and-ai-setup]]
---

# AI Production Setup — FOSS-first, upgrade later if needed

The complete per-area AI/tooling stack to take *Cycle of Innocence* from current state to shipped (Linux/Android/Web). Chosen stance (2026-06-10): **start free/FOSS everywhere; upgrade selectively to paid tools only when a concrete quality or volume wall is hit.**

## Stack by production area

| Area | Now (free/FOSS) | Upgrade trigger → paid option |
|---|---|---|
| Pixel art | **Grok Imagine** (already locked, AGENT_RULES R4) → **Aseprite** cleanup, nearest-neighbor import | Sprite *volume* wall (many enemy variants) → Retro Diffusion ~$10/mo |
| Music | **ACE-Step** (Apache 2.0, free web/self-host) for instrumental loops → **Audacity** loop/crossfade, export OGG | Need vocals or signature tracks → Suno Pro $10/mo (commercial license; never use Suno free tier commercially) |
| SFX | **ChipTone** + **sfxr** (free) for UI/hits/pickups; layer in Godot audio buses | Complex organic horror SFX ("wet stone crumble") → ElevenLabs SFX $5/mo Pro |
| Voice | **None — deliberate.** Text-only horror (Undertale/Inscryption precedent); text + ambience scarier than mediocre TTS | Trailer narration only, if ever |
| Dialogue | **Dialogue Manager** (MIT, pure GDScript — replaced Yarn Spinner: C#-only addon breaks Web export in 4.4) + LLM-drafted dialogue using [[story/bible]] as context, human-reviewed, **pre-baked only** (no runtime LLM text) | — |
| Code agents | **Claude Code + Cursor** (existing) + **godot-mcp** (FOSS MCP server: scene-tree reads, run-game, error capture) | — |
| In-game AI | **LimboAI** behavior trees + `NavigationAgent2D` pathfinding. **No runtime LLM calls** — offline mobile requirement, 300–1000ms latency, per-player API cost | — |
| Testing | **GUT** unit tests + `godot --headless` (CI-able via GitHub Actions) | — |

## Installed in this repo (2026-06-10)
- `addons/` — Dialogue Manager v3.10.4, LimboAI v1.6.0 (Godot 4.4 GDExtension build), GUT v9.6.0
- `tests/` — smoke tests; run via `tools/run-tests.sh`
- godot-mcp registered in Claude Code MCP config (scene-tree access for agents)

## Workflow rules
1. **Art**: Imagine prompt batches from [[art/imagine-prompts]] → generate at 2–4× target size → downscale in Aseprite (interpolation: none) → palette discipline pass → import with nearest filter. Always add human Aseprite work on top of AI output (strengthens legal authorship position — no AI tool indemnifies).
2. **Audio**: generate 3–5 ACE-Step candidates per mood, pick, loop in Audacity. Compose as **stems** (ambient/tense/danger sharing BPM/key per zone theme) for the adaptive system ([[../mechanics/adaptive-audio]]). Keep generation prompts/files as provenance receipts.
3. **Dialogue**: LLM drafts against the story bible; human pass for voice consistency; Dialogue Manager's in-editor test scene to validate branches; nothing generated at runtime.
4. **Code**: Grok = vision/architecture/prompts; Claude Code/Cursor = implementation via godot-mcp; runtime errors pasted back in text (agents are runtime-blind — test with F5/headless, report, iterate). Agents scaffold; humans balance (damage values, AI difficulty, dread tuning are playtest work).
5. **Enemy/companion AI**: design archetypes as LimboAI behavior trees (patrol/alert/chase/attack; companion follow/assist/fear states keyed to bond & corruption); tune via blackboard variables; watch live with LimboAI's visual debugger.

## Store compliance (disclosure)
- **Steam**: Tier 1 pre-generated AI content form — disclose AI-assisted sprites/music/SFX categories. Dev tools (Claude Code, Cursor, Copilot) are **exempt**, as are rule-based AI (LimboAI) and procedural generation. No live-generated content shipped.
- **Google Play**: similar disclosure in listing; EU listings should label AI-generated content explicitly. Offline-playable is also a Play policy expectation — another reason for no runtime LLM.
- **itch.io**: no formal requirement; add a transparency note on the page (audience values it).
- Never claim "100% handmade"; "designed and directed by the developer using AI-assisted tools" is accurate.
- **Licensing red lines**: no commercial use of free tiers that forbid it (ElevenLabs free, Suno free); no voice-cloning real people; keep prompt/project receipts for all generated assets.

## Cost posture
Current monthly cost: **$0** beyond existing subscriptions (Grok, Claude/Cursor). Full selective-paid stack if all upgrade triggers fire: ~$25/mo (Retro Diffusion + Suno + ElevenLabs). Decision per tool, recorded in [[decisions/_index]] when taken.

## Related
- [[decisions/2026-06-10-new-features-and-ai-setup]] · [[art/imagine-prompts]] · ../AGENT_RULES.md (R4 asset pipeline) · ../GROK.md
