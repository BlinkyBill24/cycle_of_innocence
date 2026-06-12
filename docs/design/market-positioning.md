---
name: Market Positioning & Platforms
date: 2026-06-12
tags: [design, marketing, platform]
status: draft
related_decisions: "[[decisions/2026-06-12-steam-timing]]"
---

# Market Positioning & Platforms

Source: research round 3
([[research/done/2026-06-12-research-round3-outside-view-and-market]]).
Reliability markers preserved; **re-verify all sales figures at the marketing
milestone** (alongside the patent re-review).

## The lane is commercially proven — and crowding

- Mouthwashing: **500k+ copies on Steam at $13, five-person team**,
  Overwhelmingly Positive; lifetime sales 10–15× first week, word-of-mouth /
  streamer-driven. `[verified 2026-06-12, gamedeveloper.com; gamesradar.com; GameDiscoverCo]`
- World of Horror, OMORI, Undertale, Fear & Hunger: lo-fi/pixel horror with
  strong identity sells hundreds of thousands to millions. `[training knowledge —
  re-verify exact figures at marketing milestone]`
- The crowding is specifically the **brutalist F&H-like corner** ("fhunger-likes";
  Look Outside rode that lane jam→Devolver in 5 months). `[verified 2026-06-12]`

## Positioning

**Counter-position against the Fear & Hunger wave, not inside it.** The
mercy-core is the differentiator no current comp combines: child→adult life arc
with morality-driven body/world change, mercy as the core combat verb, the
village-that-moved-on conspiracy, authored companion family.

One-liner that survives contact:

> **"Undertale's mercy in Silent Hill's village — and you grow up inside it."**

Keep it at the front of every pitch sentence; the monsters-are-children lullaby
verb is the hook, never "retro horror RPG."

## Capsule & trailer rules

- Sell **horror tone and premise**, never "retro RPG" aesthetics — Feb-2025
  Next Fest data: pixel art over-performed in systems-depth genres, top RPG
  demos were 3D, horror placed ×2 in the top tier. `[verified 2026-06-12, presskit.gg]`
- Theme handling: child-sacrifice horror is shippable (ample precedent), but
  store-page framing, content warnings, and capsule tone need deliberate care
  at the demo milestone. Production risk: none. Marketing risk: real, manageable.

## Demo design

The public demo is a **complete emotional arc**, ending exactly on the
HollowingClock **stage 0→1 transition** — first bell, Briar's whimper, the
world tilting. Streamable and self-contained (the Mouthwashing long-tail
lesson); the reveal beat makes viewers need the rest. Stands on: ZoneManager,
Dialogue Manager, HollowingClock, adaptive audio. Serves a horror beat + story
+ replay-curiosity.

## Platform split

| Channel | Role |
|---|---|
| **Web (itch + NAS)** | Shop window: demo, discovery, external playtest loop — never the product |
| **Android** | The real mobile product (native export; touch parity already a slice criterion) |
| **Steam** | The revenue platform — timing pending [[decisions/2026-06-12-steam-timing]] |

### Web export — verified facts (Godot, 2026-06-12)

- Godot 4.3+ restored **single-threaded web export**: no cross-origin
  isolation needed (itch-embed friendly), fixes Apple/iOS issues; audio via
  Web Audio API Sample mode, low latency. `[verified 2026-06-12, godotengine.org]`
- Web export is **Compatibility renderer only**; **C# cannot export to web**
  (independent confirmation the Dialogue Manager switch was forced and correct).
- Keep initial payload in the **tens of MB**, prefer single-threaded export for
  the itch demo, test **Firefox/Chromium first** (Safari WebGL2 quirks persist).
  `[verified 2026-06-12]`

## Related

[[decisions/2026-06-12-steam-timing]] · [[decisions/2026-06-10-patent-risk-review]] ·
[[design/game-features]] · [[research/done/2026-06-12-research-round3-outside-view-and-market]]
