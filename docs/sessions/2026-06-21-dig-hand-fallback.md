---
name: Dig works even when Briar refuses
date: 2026-06-21
branch: fix/dig-hand-fallback
tags: [session, dig, companion, hollow-house, playtest, bugfix]
---

# 2026-06-21 — Dig by hand when Briar refuses (Hollow House key)

## The report
The Hollow House key dig "only worked after exiting and re-entering a few times."

## Cause
`_try_companion_assist`: with a companion present, it called `command_dig(nearest)` and
did NOTHING if Briar refused. `command_dig` refuses when Briar is **afraid** (the Hollow
House is dread-heavy), **busy / not in the follow state** (seeking the key, a quirk), or
**low bond** — and the "dig by hand" fallback only ran when there was NO companion at all.
So the dig silently failed until a re-enter happened to reset Briar to calm-and-following.

## The fix
One line of intent: `if not companion.command_dig(nearest): nearest.reveal()`. Briar still
digs when she can (the bond payoff); when she refuses/can't, Rowan uncovers it by hand —
the dig is never silently lost. No change to Briar's AI or the dread balance.

## Tests — suite 359 green, check-brain green
`test_dig_fallback.gd`: a terrified Briar refuses, yet `_try_companion_assist` still
reveals the spot (hand dig); the no-companion hand dig still works (regression).
