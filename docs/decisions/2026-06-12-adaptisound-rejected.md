---
name: "AdaptiSound rejected — hand-rolled AdaptiveAudio is canonical"
date: "2026-06-12"
tags: [decision, audio, tech]
status: active
related_features: ["[[mechanics/adaptive-audio]]"]
related_bugs: []
supersedes: null
superseded_by: null
---

# AdaptiSound Rejected — Hand-Rolled AdaptiveAudio Is Canonical

## Context

[[decisions/2026-06-10-recent-games-research-greenlight]] greenlit adaptive
audio as "FOSS AdaptiSound or hand-rolled," and the slice roadmap carried the
condition "AdaptiSound only if verified 4.4-compatible." The hand-rolled
`AdaptiveAudio` autoload shipped for the slice (v2 crossfade after the
gate-playtest stem clash), but the addon question stayed formally open
(lookback question in the greenlight record).

Research round 3 ([[research/done/2026-06-12-research-round3-outside-view-and-market]])
checked it: the AdaptiSound README states **"Version 1.0 does not support WEB
exports"** and the addon targets Godot 4.3. `[verified 2026-06-12 by web
research; re-verified locally same day against github.com/MrWalkmanDev/AdaptiSound README]`

## Decision

AdaptiSound is **rejected permanently** — no web export support breaks the hard
Web constraint (AGENTS.md locked stack) outright. The hand-rolled
`scripts/autoload/adaptive_audio.gd` (v2 exclusive-crossfade) is the canonical
adaptive-audio implementation.

## Alternatives

- **Wait for AdaptiSound web support**: rejected — un-dated roadmap promise vs
  an already-working autoload; addon-pin rule makes external audio middleware a
  standing upgrade liability.
- **Other audio middleware**: not searched — nothing found that beats ~100
  lines we own ([training knowledge]).

## Consequences

- Answers the greenlight record's lookback question: we hand-rolled, and the
  addon path is closed, not pending.
- The layered-stem ideal (true aligned stems: one composition, stripped mixes)
  lands in our own autoload when the audio content sprint produces real stems —
  no third-party dependency.

## Implementation

- **Commits**: branch `feature/research-bridge` — [[mechanics/adaptive-audio]]
  Option-1 line replaced, status corrected to implemented; roadmap M3.3
  annotated resolved.

## Related

[[mechanics/adaptive-audio]] · [[decisions/2026-06-10-recent-games-research-greenlight]] ·
[[research/done/2026-06-12-research-round3-outside-view-and-market]]
