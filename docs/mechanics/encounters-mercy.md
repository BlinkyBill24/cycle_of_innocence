---
name: Mercy & Calm Encounter Resolution
date: 2026-06-10
tags: [feature, mechanics, combat, morality, horror]
status: implemented
related_decisions: "[[decisions/2026-06-10-new-features-and-ai-setup]]"
---

# Mercy & Calm Encounter Resolution

## What it does
Most monsters are former sacrificed children ([[story/bible]] twist #1). Encounters can therefore be resolved three ways: **fight**, **flee/avoid**, or **soothe/spare**. Soothing is the Empath-path counterpart to combat — Rowan (and companions) calm a monster enough that it stops attacking, with lasting consequences in the choice matrix and endings. Inspired by Undertale's spare system, reframed through the game's own lore: you are not negotiating with a stranger, you are recognizing a child the village fed to the Hunger.

## Why it fits (prior art check, R3b)
- [[mechanics/combat]] already lists "calmed threats" as an experience source and the Empath ability branch in [[mechanics/progression]] includes "calming abilities, non-lethal options" — this doc mechanizes those stubs.
- [[story/endings]]: The Transformation ending requires understanding that monsters/animals are marked children — sparing is the gameplay verb that *teaches* this.
- New compared to existing docs: a concrete per-encounter resolution loop, spare-state persistence, and corruption cost for killing spareable monsters.

## Flow
1. Spareable monsters carry a hidden **Recognition** state (0–100). Most combat-capable monsters are spareable; Hunger manifestations and Wardens are not.
2. Player actions raise Recognition in real time (no menu pause — keeps Zelda/Mana feel):
   - **Hold-to-soothe**: stand ground, hold the soothe button (child Rowan hums the ritual lullaby — body horror inversion: the song that killed them is the only language they remember). Leaves Rowan defenseless (i-frames off, dread rising).
   - **Companion assist**: Briar at high bond lies down non-threateningly (+Recognition aura); Echo mirrors the monster's old name-call; Storm's calm presence slows monster aggression.
   - **Tokens**: offering a Memory/Lore item tied to that monster's past (links [[mechanics/inventory]] Memory items to gameplay) gives a large boost.
3. At Recognition ≥ threshold the monster becomes **Stilled**: stops attacking, follows light, may lead Rowan to a secret (its old home, a buried toy → lore fragment).
   > **Originality flag** (secrets research 2026-06-13, [[design/secrets-and-discovery]]): the combat-pacify-*then-guide-to-keepsake* variant is **novel — no shipped game provides a proven template** (Spiritfarer's pacify→reveal→lead-to-resolution is the nearest analogue). Strength for originality; risk because there's nothing to copy. **Legibility is unvalidated** — no tester in the 4-session feel pass reached this beat. Validate "does the player grasp 'follow me'?" before authoring more; fall back to companion-modeled following if not. `[verified 2026-06-13]`
4. Stilled monsters persist per save. They re-aggro only if attacked or if the [[mechanics/hollowing-clock]] advances a stage (the Hunger reasserts its grip — escalation undoes mercy, which is the horror).

## Morality & corruption hooks
- Sparing: morality toward Innocent/Empath, small dread reduction, sets `spared_<id>` flags consumed by [[story/choice-matrix]].
- Killing a monster *after* it was Stilled: heavy morality push toward Vessel, +companion corruption if they witnessed it (Briar learns from you — Black & White-style behavioral mirroring), unique horrified companion reactions.
- Ruthless path inversion: a Vessel-tier Rowan can **Dominate** instead of soothe — same mechanic, opposite flavor: the monster obeys out of fear, fights for you once, then dies. Power now, ending flags later.

## Data model
- `Monster.recognition: float`, `Monster.spareable: bool`, `Monster.stilled: bool` (persisted).
- PlayerData: `spared_count`, `dominated_count`, per-monster flags into the existing revelation/choice flag system.
- GameEvents: `monster_stilled(id)`, `stilled_monster_killed(id)` signals.

## Edge cases
- Soothing in a group fight: only one target gains Recognition at a time; others keep attacking (risk/reward).
- High dread distorts the soothe: at dread > 80 the lullaby audio warps and Recognition gains halve — mercy is hardest when you're terrified, which is the point.
- Accessibility: horror-intensity slider does not change Recognition mechanics, only presentation.

## Mobile note
Hold-to-soothe maps cleanly to a touch hold; no extra buttons beyond existing interact.

## Research notes (2026-06, round 2)
- **Unique soothe per monster** (Undertale Yellow): each spareable monster has one *specific* interaction that moves Recognition fastest (show the buried toy, hum THEIR verse, let Briar approach first); repeating the generic soothe plateaus. Discovering the specific one = environmental storytelling payoff. See [[design/feature-candidates-2026-06]].

## Implementation notes (2026-06-10, branch feature/full-mercy)
- Generic soothe plateaus at Recognition 60; each monster exports `soothe_key_flag` — for the TwistedChild it is `dug_playground_buried_toy` (Briar digging up the toy IS the discovery payoff). With the key: rate ×1.6 and the plateau lifts.
- Briar calm aura: bond ≥ 25, not afraid, within 90px of the target → rate ×1.5 (stacks with the key). Dread > 80 halves everything. Pure rule: `PlayerController.soothe_rate()`.
- Stilled children lead: stay within 90px and the child walks to its `secret_spot_path` (keepsake diggable east of the swings) — once, flagged `led_<id>`. It stops *beside* the spot and waits; the reveal stays Briar's dig (assist + bond reward), never the monster's (playtest fix 2026-06-11).
- Domination: at Vessel tier the same hold becomes `add_domination` — ×1.4 rate, ignores dread and needs no key (fear is the easy road). The thrall heels, fights other monsters once, then crumbles; `dominated_<id>` keeps it dead forever. Morality +8, Briar corruption +5.
- Bookkeeping: `PlayerData.spared_count` / `dominated_count` + permanent `spared_`/`dominated_` flags (betrayal clears `stilled_`, never the history). All persisted.

## Related
- [[mechanics/combat]] · [[mechanics/horror-and-dread]] · [[mechanics/hollowing-clock]] · [[story/choice-matrix]] · [[characters/companions]]
