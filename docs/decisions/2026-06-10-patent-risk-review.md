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

## Research cross-check (2026-06-13) — flag, not a re-decision
The R7 bridge [[research/done/2026-06-13-companion-pointer-investigation-design]]
independently re-verified the two live patents that brush our design; the verdict
above is **unchanged** (authored-not-procedural + balloon dialogue keep us clear).
Recorded for provenance:
- **BioWare dialogue wheel — US 8,082,499** ("Graphical interface for interactive
  dialog", filed 2007, granted 2011, **expires 2029**). Matches our row. `[verified 2026-06-13]`
- **WB Nemesis — US 10,926,179** (granted Feb 23 2021). ⚠️ **Discrepancy to
  verify:** the new research states "valid to **2035**"; our table says "→ Aug
  **2036**." Re-confirm the exact expiry at the demo/marketing milestone — does
  not change the verdict either way. `[verified 2026-06-13]`
- New this round: **Briar-seek** ([[mechanics/companion-pointer]]) audited against
  the same Nemesis frame — authored behavior on one fixed character, no procedural
  generation/hierarchy/rank → clear, same discipline as [[mechanics/companion-quirks]].

## Lookback Questions
- At demo/marketing milestone: any new patents (esp. Palworld-case fallout)? Nemesis still standing unchanged? **Confirm the Nemesis expiry (2035 vs 2036).**
- Did any post-slice feature drift toward procedural companion generation (would change the analysis)?

## Related
[[design/game-features]] · [[mechanics/companion-quirks]] · [[mechanics/interface-horror]] · [[2026-06-10-recent-games-research-greenlight]]
