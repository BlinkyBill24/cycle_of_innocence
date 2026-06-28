---
name: AI Production Setup (FOSS-first)
date: 2026-06-10
tags: [design, pipeline, ai-tools, licensing]
status: active
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# AI Production Setup — FOSS-first, upgrade later if needed

The complete per-area AI/tooling stack to take *Cycle of Innocence* from current state to shipped (Linux/Android/Web). Chosen stance (2026-06-10): **start free/FOSS everywhere; upgrade selectively to paid tools only when a concrete quality or volume wall is hit.**

## Stack by production area

| Area | Now (free/FOSS) | Upgrade trigger → paid option |
|---|---|---|
| Pixel art (concepts/bibles) | **Grok Imagine** → pixel cleanup (scripted or GIMP/Pixelorama — no Aseprite installed) + `tools/pixelize.py` (magenta chroma-key), nearest-neighbor import | — |
| Pixel art (character animation & variants) | Grok placeholders for the slice (functional but clunky) | **TRIGGER FIRED 2026-06-10** (Grok can't grid-align animation sheets) → **PixelLab** ~$12-30/mo pause-able, when variant work starts — skeleton rigs keep pose timing identical across outfit/age variants (see [[decisions/2026-06-10-sprite-tool-pixellab]]) |
| Pixel art (static tiles/icons + **tilesets**) | Grok Imagine (concept/icons) | **PixelLab `create_topdown_tileset`** (Wang, 32px, `view="low top-down"`) recommended primary for terrain/floors/walls per [[research/done/2026-06-20-pixel-art-pipeline-consistency]]; **Retro Diffusion** ($20 Lite / $65 full) as palette-strict fallback — *caveat: RD's Aseprite ext is static-only; 4-dir animation needs the RD website/API/Replicate* `[verified 2026-06-20]` |
| Music | **ACE-Step** (Apache 2.0, free web/self-host) for instrumental loops → **Audacity** loop/crossfade, export OGG | Need vocals or signature tracks → Suno Pro $10/mo (commercial license; never use Suno free tier commercially) |
| SFX | **ChipTone** + **sfxr** (free) for UI/hits/pickups; layer in Godot audio buses | Complex organic horror SFX ("wet stone crumble") → ElevenLabs SFX $5/mo Pro |
| Voice | **None — deliberate.** Text-only horror (Undertale/Inscryption precedent); text + ambience scarier than mediocre TTS | Trailer narration only, if ever |
| Dialogue | **Dialogue Manager** (MIT, pure GDScript — replaced Yarn Spinner: C#-only addon breaks Web export in 4.4) + LLM-drafted dialogue using [[story/bible]] as context, human-reviewed, **pre-baked only** (no runtime LLM text) | — |
| Code agents | **Claude Code + Cursor** (existing) + **godot-mcp** (FOSS MCP server: run-game + console-error capture; reads scene *files*, **not** the live runtime tree). Installed = `Coding-Solo/godot-mcp` v0.1.1. `[FLAG 2026-06-28]` This base server has **no live runtime-tree/autoload visibility** (can't show DreadManager/HollowingClock live state) and carries an **unpatched command-injection advisory** (issue #64 — localhost-only, untrusted-path vector; low risk in solo local use). | Add a runtime-visibility server → `Erodenn/godot-mcp-runtime` (free; injects bridge at runtime, **nothing stays in the project → no web-export cleanup**, best fit for the Web constraint) **or** `PrajnaAvidya/Godot-Peek-MCP` (free; more debug power — live tree, stack traces, perf monitors — but ships an addon you must export-exclude, and **Linux x86_64 only** — verify the binary on Mint first). Avoid `IvanMurzak/Godot-MCP` (needs C#/.NET → breaks Web export). See [[../research/done/Claude-Godot-MCP-Servers-Research-2026-06-28]]. |
| In-game AI | **LimboAI** behavior trees + `NavigationAgent2D` pathfinding. **No runtime LLM calls** — offline mobile requirement, 300–1000ms latency, per-player API cost | — |
| Testing | **GUT** unit tests + `godot --headless` (CI-able via GitHub Actions) | — |

## Placeholder / greybox art (NOT shippable)
*From [[research/done/2026-06-20-michael-games-aarpg-harvest]] (placeholder-only ruling, 2026-06-20).*
The Michael Games **2D Action-Adventure RPG asset pack** (`michaelgames.itch.io/2d-action-adventure-rpg-assets`, name-your-price, **free for commercial use**, *"no generative AI"* `[verified 2026-06-20]`) is a sanctioned **placeholder/greybox source** for prototype + the placeholder-mode test build — a real drawn sprite can read silhouette/scale better than a polygon. **It is hand-drawn with its own palette + projection**, so it is **prohibited from any shippable scene** (would violate Projection Canon / `CANON_VIEW` + the master-palette lock). If adopted, quarantine it under a `placeholder/`-style path the gate can isolate so it can never silently survive into ship. Shippable use would be a separate decision (reopens Projection Canon + palette lock), not a placeholder swap. *(Aseprite — the pack creator's hand tool — remains optionality only; not in the stack, "no Aseprite installed" above.)*

## Installed in this repo (2026-06-10)
- `addons/` — Dialogue Manager v3.10.4, LimboAI v1.6.0 (Godot 4.4 GDExtension build), GUT v9.6.0
- `tests/` — smoke tests; run via `tools/run-tests.sh`
- godot-mcp (`Coding-Solo/godot-mcp` v0.1.1) registered in Claude Code MCP config — run-game + scene-*file* reads + console-error capture. **No live runtime tree** (autoload/instanced-node state invisible); see the `[FLAG 2026-06-28]` runtime-server upgrade path in the stack table and [[../research/done/Claude-Godot-MCP-Servers-Research-2026-06-28]].
- PixelLab API client `tools/pixellab_api.py` (user subscribed 2026-06-10, free tier; key at `~/.config/pixellab/api_key`, never committed; generation needs credit top-up)

## Workflow rules
1. **Art**: Imagine prompt batches from [[art/imagine-prompts]] → generate at 2–4× target size → downscale scripted or in GIMP/Pixelorama (interpolation: none; no Aseprite installed) → palette discipline pass → import with nearest filter. Always add human pixel-edit work on top of AI output (strengthens legal authorship position — no AI tool indemnifies). For *keeping concept art on-model* (anchor images, look-block templates, the no-seed caveat), see [[art/grok-reference-workflow]]. **Super Grok Heavy (confirmed 2026-06-21) does NOT change this pipeline** — it improves the concept/reference stage only; PixelLab stays canonical for sprites. `[verified 2026-06-21]`
2. **Audio**: generate 3–5 ACE-Step candidates per mood, pick, loop in Audacity. Compose as **stems** (ambient/tense/danger sharing BPM/key per zone theme) for the adaptive system ([[../mechanics/adaptive-audio]]). Keep generation prompts/files as provenance receipts.
3. **Dialogue**: LLM drafts against the story bible; human pass for voice consistency; Dialogue Manager's in-editor test scene to validate branches; nothing generated at runtime.
4. **Code**: Grok = vision/architecture/prompts; Claude Code/Cursor = implementation via godot-mcp; runtime errors pasted back in text (agents are runtime-blind — test with F5/headless, report, iterate). Agents scaffold; humans balance (damage values, AI difficulty, dread tuning are playtest work).
5. **Enemy/companion AI**: design archetypes as LimboAI behavior trees (patrol/alert/chase/attack; companion follow/assist/fear states keyed to bond & corruption); tune via blackboard variables; watch live with LimboAI's visual debugger.

## Web-export constraints (the hard target)
*From [[research/done/2026-06-20-ai-assisted-gamedev-orchestration-survey]], `[verified 2026-06-20]`.* Web/HTML5 is a locked hard constraint (AGENTS.md); these are the specifics AI tools most often violate — encode them and **test the actual web export each milestone, not just the desktop run**:
- **Audio is Sample mode** (Web Audio API, default since 4.3): **no `AudioEffect`, reverb, Doppler, or procedural audio**. → **pre-bake any effects into the files; no runtime DSP.** (Our `AdaptiveAudio` is already clean — crossfaded stems, no effects; keep it that way. Switching Default Playback Type to Stream to regain effects costs latency.)
- **Single-threaded is the default/recommended mode.** Threads need `SharedArrayBuffer` → cross-origin-isolation (COOP/COEP) headers many hosts (GitHub Pages, basic itch) don't send → use a PWA service worker / `coi-serviceworker`. Prefer no-threads.
- **Compatibility / WebGL2 renderer only** (Forward+ won't run); avoid WebGL2-incompatible dynamic-loop shaders (ties to the palette-clamp shader caveat in [[art/prop-coherence]] Rule 1).
- **Keep it small & smooth**: Basis Universal texture compression; never run heavy work in `_process()` (the browser kills a long frame); Safari/iOS have historical SharedArrayBuffer/WebGL2 quirks.
- **✅ LimboAI Web export verified (2026-06-20)**: LimboAI is a GDExtension (v1.6.0, gdextension-4.4) and GDExtension Web export *has* historically been fragile, but ours is fine — a headless release export succeeds and bundles `liblimboai.web…nothreads.wasm`. The Web preset must keep `variant/extensions_support=true` (dlink template) + `variant/thread_support=false` (nothreads) for this to hold; LimboAI ships both nothreads/threads wasm. Re-verify after any Godot/LimboAI version bump. *(Still owed: an in-browser runtime smoke — serve + open the build.)*

## Store compliance (disclosure)
> **Dated snapshot (2026-06-20) — NOT legal advice.** Law/policy here is perishable and unsettled in the middle; re-verify on the official pages and get professional advice before a commercial launch. Source: [[research/done/2026-06-20-ai-assisted-gamedev-orchestration-survey]] §7.
- **Steam** (policy rewritten **2026-01-17**, player-facing focus): two disclosure buckets — **Pre-Generated** (AI assets shipped in the game) and **Live-Generated** (runtime AI, also needs guardrails + an in-overlay player-report button; we ship none). Disclose AI sprites/music/SFX/VO/lore under "About This Game". **AI *coding* assistants are explicitly exempt** (Claude Code/Cursor/Copilot), as are rule-based AI (LimboAI) and procedural generation. No bright-line for "how much editing removes the obligation" → keep originals + revision history. Internal-only concept art (not shipped) needs no disclosure. Valve has begun enforcing with page removals.
- **Copyright / authorship**: raw AI output with no meaningful human authorship is **not** copyrightable (*Thaler*, DC Circuit 2025; cert denied **2026-03-02**; prompts alone = unprotectable ideas per the USCO Jan-2025 report). But an **AI-assisted work is registrable where human selection/arrangement/editing is creative** (USCO registered "A Single Piece of American Cheese", 2025-01-30, after 35+ inpaint rounds). → **document your human authorship** (sprite hand-edits, code architecture, written narrative, selection/arrangement) to protect the **game-as-a-whole** even if individual raw assets aren't.
- **Training-data litigation (live, perishable):** *Andersen v. Stability AI* → trial begins **2026-09-08**; *Sony v. Suno* summary-judgment hearing **July 2026** (Warner/UMG already settled with Suno/Udio). → prefer **license-clean / consent-trained / indemnified** tools (Adobe Firefly, ElevenLabs, Stable Audio, PixelLab, Retro Diffusion); scraped-data tools carry residual risk you inherit (most disclaim indemnification).
- **Google Play**: disclose AI content in the listing; EU listings label AI explicitly; offline-playable is a Play expectation (another reason for no runtime LLM). No Steam-equivalent generative-disclosure framework yet — verify at submission.
- **itch.io**: no mandatory requirement (optional AI-disclosure field); add a transparency note (audience values it). **Epic** has no AI-disclosure requirement. Jurisdictions diverge (UK *Getty v. Stability*; EU) — US guidance is not global.
- Never claim "100% handmade"; "designed and directed by the developer using AI-assisted tools" is accurate.
- **Licensing red lines**: no commercial use of free tiers that forbid it (ElevenLabs free, Suno free); no voice-cloning real people; keep prompt/project receipts for all generated assets. **LPC Spritesheet Generator** assets (if ever adopted as a consistency backbone, [[research/done/2026-06-20-pixel-art-pipeline-consistency]]) are CC-BY-SA 3.0 / GPL 3.0 — attribution required, with a GPL/DRM-clause wrinkle for encrypted storefronts (Steam/iOS); prefer CC0/OGA-BY there `[verified 2026-06-20]`.

## Cost posture
Current monthly cost: **$0** beyond existing subscriptions (Grok, Claude/Cursor). Full selective-paid stack if all upgrade triggers fire: ~$25/mo (Retro Diffusion + Suno + ElevenLabs). Decision per tool, recorded in [[decisions/_index]] when taken.

## Related
- [[decisions/2026-06-10-new-features-and-ai-setup]] · [[art/imagine-prompts]] · ../AGENT_RULES.md (R4 asset pipeline) · ../GROK.md
