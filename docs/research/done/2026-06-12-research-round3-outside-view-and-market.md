---
name: "Research round 3 — outside-view audit, tech verification & market positioning (concept-prompt rerun)"
date: 2026-06-12
source: "claude.ai web research bridge (Claude Fable 5), grounded in docs/_compiled/ snapshots of 2026-06-12"
prompt: "Original pre-lock concept prompt ('expert game design consultant… analyze the following game concept', Yarn-Spinner-era summary) rerun as the R7 bridge smoke test"
status: integrated
---

# Round 3 — Outside-View Audit & Market Research

> **Reconciliation note (read first).** The submitted prompt predates the 2026-06-10 lock-in. Stale elements were **flagged, not followed**, per R7 propose-first:
> - "Yarn Spinner for dialogue" → superseded by **Dialogue Manager** ([[decisions/2026-06-10-new-features-and-ai-setup]]; C#/.NET cannot export to Web in Godot 4 — independently re-verified below).
> - "Mubert/ACESTEP" → stack is **ACE-Step, FOSS-first** ([[design/ai-production-setup]]); "Retro Diffusion/PixelLab" → **PixelLab** decided ([[decisions/2026-06-10-sprite-tool-pixellab]]).
> - "party combat" → locked as **light companion assists** ([[mechanics/combat]]).
> - "Vertical slice first" → **slice shipped**; greenlit post-slice queue complete ([[state-and-roadmap]]). Sections 1–4 below are therefore audits-with-deltas, not fresh consulting; depth went to the genuinely open questions (tech verification, market, next steps).
> - Prompt sections asking for "modular sprites/equipment (weapons/armor)" guidance: **fails the filter** as posed — equipment combinatorics serve neither story, a companion arc, a horror beat, nor replay right now; the vault already deferred paper-doll layering until morality-outfit×age sheets stop sufficing. No recommendation made.

## 1. Overall assessment (current state, honest)

**On the right track — unusually so for a solo project.** The process layer (GUT suites at 150–184 green, decision records, patent audit, compiled-snapshot research loop) is rarer than any individual mechanic and is itself a risk reducer. Design coherence is high: mercy-as-lullaby × HollowingClock × companion quirks × village-that-moved-on is a genuinely differentiated identity, not a feature pile.

**Main risks, ranked:**
1. **Systems-rich, content-poor.** The greenlit feature queue is complete, but authored content (zones, dialogue volume, audio, recontext moments) is now the long pole. This is the classic solo-dev failure mode: engines get finished, games don't. The vault already names the cure ("playtest/feel pass recommended; story/content pass") — this audit seconds it strongly.
2. **No marketing surface.** The vault plans an itch web demo + NAS loop but records no Steam intent. In the 2025–26 market, wishlists pre-launch are the dominant predictor of month-one sales, and pages should exist 6–12 months before launch [verified 2026-06-12, sunstrikestudios.com 2026 guide; howtomarketagame.com]. Web/itch is a discovery channel; Steam is where comparable titles earn (see §5). **Flag: a platform/Steam decision is missing, and lead times mean it should be made soon — proposed, not assumed.**
3. **External playtest cadence.** Interface horror, suspicion→alarm tuning, and clock pacing ("urgency without anxiety treadmill" — an open lookback question) can only be validated by players who aren't the author. The NAS web build makes this cheap.
4. **Theme-handling at marketing time.** Child-sacrifice horror is shippable (plenty of precedent) but store-page framing, content warnings, and capsule tone will need deliberate care at the demo milestone. Production risk: none. Marketing risk: real but manageable.

## 2. Design recommendations (deltas only — rounds 1–2 cover the rest)

- **Demo as a complete emotional arc.** Mouthwashing's breakout was word-of-mouth/streamer-driven, with lifetime Steam sales 10–15× first-week — the long tail of a *streamable, self-contained* narrative experience [verified 2026-06-12, GameDiscoverCo via difmark.com; gamedeveloper.com]. Transferable: design the public demo to end exactly on the stage 0→1 HollowingClock transition (first bell, Briar's whimper, the world tilting) — a reveal beat that makes viewers need the rest. Stands on: ZoneManager, Dialogue Manager, HollowingClock, adaptive audio. Filter: serves a horror beat + story, and replay-curiosity for free.
- **Position against the F&H wave, not inside it.** Fear & Hunger has spawned an explicit imitator wave ("fhunger-likes"), and Look Outside (jam Oct 2024 → Devolver release Mar 2025) rode that lane to strong reviews [verified 2026-06-12, darkrpgs.home.blog; Wikipedia; Medium interview]. The crowding is in *brutalist* horror RPGs. Cycle of Innocence's mercy-core ("the monsters are the children; the lullaby is the verb") is the counter-position — keep it front of every pitch sentence. Filter: replay/market value via differentiation; no mechanic change needed.
- Everything else the prompt asks (loop, age progression, twist pacing, top-down atmosphere) is already specified and largely built in [[mechanics/*]]; no outside finding this round improves on the vault's answers.

## 3. Technical verification (the open items, checked)

- **Web export reality [verified 2026-06-12, godotengine.org 4.3 progress report; deepwiki godot-docs].** Godot 4.3+ restored **single-threaded web export**, which fixes the long-standing Apple/iOS issues and runs without cross-origin isolation (itch-embed friendly); audio defaults to Sample mode via Web Audio API with low latency in single-threaded builds. Web export remains **Compatibility renderer only**, and **C# cannot export to web** — independent confirmation that the Dialogue-Manager switch was forced and correct. Practical guidance: keep initial payload small (tens of MB, not 100+), prefer single-threaded export for the itch demo, test Firefox/Chromium first (Safari WebGL2 quirks persist) [verified 2026-06-12, best-games.io 2026 optimization guide]. **Recommendation: treat Web as the demo/discovery channel; Android native remains the real mobile product.** This matches the existing constraint rather than reopening it.
- **AdaptiSound: reject, record it.** Asset Library lists it for Godot 4.1, and the GitHub README states v1.0 **does not support web exports** [verified 2026-06-12, godotengine.org/asset-library/asset/1983; github.com/MrWalkmanDev/AdaptiSound]. That breaks the hard Web constraint outright. The hand-rolled `AdaptiveAudio` autoload (already built, v2 crossfade) was the right call — propose a short decision note closing the "AdaptiSound only if verified 4.4-compatible" thread so it never resurfaces.
- Dialogue, cutscenes, age-morph, save: already solved in-project; nothing found that beats the current implementations. [training knowledge: no superior Godot 4.4 pattern surfaced in this round's sources]

## 4. Scope & solo strategy

One sentence: **stop building systems; start filling them.** Concretely — define "content-complete" per zone (recontext moments authored, gossip pools written, stems present, props placed) and burn those down before any new mechanic, with the playtest/feel pass as the gate between arcs. The AI division of labor (Claude Code hub, Grok voice/art, Codex gates, PixelLab batches) is already disciplined; the only addition worth making is scheduling *external* playtesters through the NAS web build at the end of each content arc.

## 5. Market & competition

- **The lane is commercially proven.** Mouthwashing: 500k+ copies on Steam at $13, five-person team, Overwhelmingly Positive, awards [verified 2026-06-12, gamedeveloper.com; gamesradar.com]. World of Horror, OMORI, Undertale, and Fear & Hunger established that lo-fi/pixel horror with strong identity sells in the hundreds of thousands to millions [training knowledge — re-verify exact figures at the marketing milestone].
- **The lane is also crowding** — specifically the brutalist F&H-like corner (§2). Differentiators no current comp combines: child→adult life arc with morality-driven body/world change, mercy as the core combat verb, the village-that-moved-on conspiracy, and authored companion family. The one-line positioning that survives contact: *"Undertale's mercy in Silent Hill's village — and you grow up inside it."*
- **Capsule/trailer caution.** February 2025 Next Fest data: pixel art over-performed in systems-depth genres, while the top RPG demos were 3D; horror itself placed ×2 in the top tier [verified 2026-06-12, presskit.gg Next Fest guide]. Implication: sell *horror tone and premise* in capsule/trailer, never "retro RPG" aesthetics.
- **Steam mechanics to plan around** [verified 2026-06-12, presskit.gg; biggamesmachine.com]: Next Fest runs Feb/Jun/Oct; pick the last fest before launch (2–4 months out); ship the demo 2–4 weeks *before* the fest; 68–88% of fest wishlists come from people who never launch the demo — the store page does the selling.

## 6. Next 2–4 weeks (mapped to the actual roadmap)

1. **Structured playtest/feel pass** (the vault's own recommended next arc): clock pacing, interface-horror frustration ceiling, suspicion tuning, plus the slice-gate leftovers (stem overlap, darker dread, bark visibility). Recruit 3–5 outside testers via the NAS/itch web build; capture against the existing lookback questions.
2. **Audio content sprint (AU1 done right):** produce the playground/fringes stems as *one composition, stripped mixes* so the v2 crossfade can graduate to true layering; write the AdaptiSound-rejected decision note (§3).
3. **Playground recontext authoring:** the 2–3 thesis-statement moments for the first revelation — content, not mechanism (mechanism is live).
4. **Decide the Steam question** (user decision, flagged): if any 2027 demo/launch is plausible, a Coming Soon page belongs in late 2026 with the Feb-or-Jun 2027 Next Fest as the demo target. Re-run the patent review at that same milestone per [[decisions/2026-06-10-patent-risk-review]].

## Recommendation

The concept needed validating in 2025; in June 2026 it needs **finishing**. Hold the locked stack (every lock re-verified clean this round), spend the next arc on playtests and authored content rather than mechanics, treat Web as the shop window and Android as the mobile product, and make the Steam-timing decision now so wishlist lead time starts compounding — positioned explicitly as the mercy-core counterweight to the Fear-&-Hunger wave.
