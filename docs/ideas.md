---
name: Ideas Inbox — Cycle of Innocence
tags: [inbox]
---

# Ideas Inbox — Cycle of Innocence

Raw capture → triage → promote to decisions/features. Never delete, only move.

## 🆕 Unsorted
*Raw capture during sessions. No structure required.*

- (From approved plan) First companion in escape: small dog or bird that was also "wrong" for the ritual — instant bond + shared "marked" status.
- Consider one "corruptible exotic" companion option late-game (high risk/reward for ruthless paths).
- Care mechanics for animals: simple (feed from foraged items, soothe after horror events, protect in fights) but with visible loyalty + visual shifts.
- Horror via animals: the dog whimpering at things the player can't see yet; bird refusing to land in certain zones; horse bolting and forcing a choice.
- NG+ idea: carry over a "ghost" of a lost companion that gives unique (bittersweet) dialogue/options.
- Accessibility: "reduced dread" mode that mutes some stingers / companion fear reactions while keeping story.

## 🔜 Ready to promote
*Triaged ideas, ready to become decisions or features.*

- (Phase 0) Generate protagonist + first animal bible(s) with Grok image_gen using the prompt template in the plan before any code.
- Strong emphasis on "no Mote reuse" — document guardrails in GROK.md and local handbook.

## 📥 Captured this session
- Plateau discovery cue: when generic soothe stalls at 60, the monster could glance toward its buried key (environmental hint without UI).
- Faction-aware hitboxes before multi-enemy zones: a Dominated thrall's lunge currently uses the player-hurting hitbox layer — fine with one enemy, needs factions later.
*From plan creation + initial setup (2026-04). Move to Unsorted or Ready after review.*

- Protagonist as escaped sacrifice + animal companions (dog/ bird / horse) as primary found family and mechanical helpers.
- Use test/ as active dev root for now; create self-contained docs/ vault here while linking to parent.
- Create GROK.md + full Obsidian setup inside test/ before Phase 0 code spikes.
- Leverage existing hooks (check-branch), .grok agents/skills (spawn_subagent, imagine, graphify on bible), and parent obsidian scripts.
- Yarn Spinner chosen (→ replaced by Dialogue Manager 2026-06-10); real-time action combat; 32x32 pixel with age + corruption + animal growth variants.

## 🗑️ Rejected
*Won't-do with reasons. Keep for future reference.*

- Human-centric party as primary bonds (replaced by animals per revision).
- Any direct reuse of Mote cozy mechanics, diorama framing, or season/vine systems.

## 📥 Captured this session (story fleshing)

- Gave the protagonist a concrete name and background: Rowan, Subject-07, escaped during the Night of the Hollowing with the first companion (a pup that was also a "lesser offering").
- Companions now have names and strong personalities: Briar (hound — emotional heart, most tragic corruption path), Echo (bird — knowledge and uncomfortable truths), Storm (mount — symbol of freedom and the cost of care).
- The four endings are now distinct and companion-dependent. The "Transformation" ending feels like the thematic sweet spot (hopeful but alien, found family literally changes the rules of the world).
- Early choice "The Food" (sharing with Briar on night 1) is now the very first major signal for bond vs corruption.
- Need to decide: Can any human ever be a true long-term ally, or are all human bonds ultimately tragic or illusory? (Leaning toward "mostly tragic" to keep the animal found-family focus pure.)
- For art: Now that we have specific companion personalities and the "corrupted" body-horror direction, the next image_gen calls should be for full bibles with growth + corruption variants.

## 📥 Captured this session (game features brainstorming)

- Strong support for player naming the protagonist and all companions — this is high immersion value for the found-family theme and costs very little.
- Gender selection for Rowan with mostly cosmetic pixel art impact but meaningful subtle narrative flavor (elders' biases, some companion reactions). Keeps story universal while adding replay texture.
- Morality as the primary "build" and visual driver (age + morality variants for sprites + shaders) instead of traditional character creator or heavy customization. This keeps art scope under control while making choices feel visible.
- Companion care items as the main "inventory loop" — turns inventory into an emotional and mechanical extension of the bond system rather than busywork.
- Dread meter as a global systemic layer that affects combat, audio, visuals, *and* companion behavior. This is a great way to make horror feel systemic rather than just set dressing.
- Revelation-gated content (abilities, enemy behavior, puzzle solutions, dialogue) as a core way the conspiracy "leaks" into gameplay.
- Horror intensity slider that reduces effects but never removes mechanical or story consequences — important accessibility commitment.
- NG+ with companion "echoes" and knowledge carry-over is one of the strongest replay hooks alongside different morality/ending paths.
- Every feature brainstorm was filtered through "does this serve the story, a companion arc, or a horror beat?" — several ideas were cut or deferred for scope.

These ideas are now documented in the new design/mechanics files and should be referenced when moving from story bible → prototype.

## 📥 Captured this session (slice gate polish, 2026-06-10)

Gate passed; polish items from the verdict (address during post-slice audio/feel passes):

- **Audio stem overlap**: stems clash when layered — regenerate as true aligned layers (same seed/progression in ACE-Step, or strip-down mixes of ONE track), duck tense/danger under stingers, review mix levels. ([[mechanics/adaptive-audio]])
- **Darker dread**: push the dusk/vignette further at high tiers — consider lowering CanvasModulate with dread, not just the overlay.
- **Bark visibility**: barking is easy to miss — louder/double bark SFX, a small "!" pixel indicator above Briar, and/or a brief hop animation; companion telegraphs must read instantly (feeds [[mechanics/companion-quirks]] later).

## 📥 Captured this session (legal, 2026-06-10)

- **Re-run the patent review at the demo/marketing milestone**: verify Nemesis patent unchanged, check Palworld-case fallout (USPTO re-exam of US 12,403,397 may set precedent), and have an IP attorney sanity-check before commercial release. ([[decisions/2026-06-10-patent-risk-review]])

## 📥 Captured this session (sprite tooling, 2026-06-10)

- **PixelLab API/MCP from the hub**: PixelLab has an API + documented MCP/Claude Code workflow — when variant batches start (outfits × ages), drive generation from Claude Code instead of clicking the web UI. (Decision: [[decisions/2026-06-10-sprite-tool-pixellab]])
- **Paper-doll layering v2**: if weapon/equipment combinatorics outgrow the 3 morality outfit states, switch from full variant sheets to base-body + clothing/weapon overlay layers (PixelLab can generate clothing-only transparent layers); composite in Godot.
- LPC/OpenGameArt dog walk cycles (CC) as animation timing reference for Briar polish.

## 📥 Captured this session (research round 2, 2026-06-10)

- **Ability layering rule** (Animal Well): every companion ability must ship with 2-3 cross-context uses (Briar's dig = puzzle + combat interrupt + lore unearthing) — depth without new ability count. Apply when implementing assists.
- **Puzzle-only progression guarantee** (Crow Country): accessibility stretch goal — the critical path never *requires* combat (mercy/stealth always viable). Audit when zones are built.
- **Ritual-symbol literacy** (Lorelei and the Laser Eyes): the player gradually learns to *read* the cult's symbols; late-game environmental text becomes legible. Cheap flavor layer on zone-recontextualization.
- **Transformation phases mid-fight** (Look Outside): corrupted companion boss variants could evolve phases during the encounter — reserve for the Briar tragedy fight if corruption path is taken.

## 📥 Captured this session (central brain, 2026-06-10)

- Karpathy LLM-wiki pattern: later, consider an auto-synthesized `wiki/` layer over raw docs (graphify skill could seed it) so agents read compounding summaries instead of raw files.
- When parallel implementation starts, use git worktrees per agent (Claude Code EnterWorktree / Grok CLI's native worktree subagents) to avoid file collisions.
- Watch Claude Code issue #34235 (native AGENTS.md support) — if it lands, the CLAUDE.md shim can shrink further.
- Cursor reads AGENTS.md natively — revisit Cursor background agents only if a heavy parallel refactor ever needs them (cost: credits).

## 📥 Captured this session (genre research, 2026-06-10)

Researched-but-not-greenlit candidates worth keeping (source game in parens):

- Save-scarcity "sanctuaries" — saves only at hideout/safe lights, making safety a resource (Fear & Hunger, softened). Partially absorbed by [[mechanics/day-night-hideout]]; full scarcity deferred — may frustrate mobile sessions.
- Corruption spreading visibly across zone maps over time, reclaimable by player action (Children of Morta). Overlaps with [[mechanics/hollowing-clock]] stages; revisit if zones feel static.
- Companion refusal extension: corrupted/low-bond companions refusing commands mid-combat with visible body language (The Last Guardian). Already implied in companions doc — promote when companion AI is built in LimboAI.
- Meta-narrative save awareness: NG+ companions reacting to "other timelines" (Undertale). NG+ echoes already designed; this is the +1 flavor pass.
- Doom-meter UI as diegetic church bells / village posters instead of any HUD element (World of Horror inversion) — folded into [[mechanics/hollowing-clock]] presentation rules.
- Monster silhouettes rendering with faint child-outlines after the revelation — folded into [[mechanics/vision-and-darkness]].

## 📥 Captured this session (story revision implications)

- The playground ritual + creepy clowns/stuffed animals/toys is much stronger thematically than a stone circle. It weaponizes childhood safety and play, which will make the horror land harder for the player (especially in the child section).
- Lottery / Harmony Score makes the system feel more modern-bureaucratic and unfair. Parents competing or gaming the "score" could be a great source of side dialogue and moral choices later (e.g., a family that sabotaged another's score).
- Villagers believing the ritual succeeded for days/weeks creates a powerful "the world moved on without you" feeling. Rowan can potentially watch or overhear normal village life while hiding. This delay also justifies the ramp-up of extra sacrifices when things start going wrong.
- Art & zone design impact: The ritual site can be revisited later (now a corrupted, blood-stained playground with abandoned toys that still move). Early "safe" playground memories can contrast with later horror versions.
- Monster creation: The escalation ("sacrificing more and more") means there can be fresher, more recently transformed monsters mixed with older ones — good variety and tragedy.
- Potential early game moment: Rowan overhears parents celebrating or breathing a sigh of relief ("Thank the Harmony Lottery our little one wasn't picked this time") while knowing the truth.

These should feed into zone design, art prompts, and the first few dialogue nodes.
