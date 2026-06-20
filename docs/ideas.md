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
- **Briar bond-hooks — next-pass priorities** (consolidated, from [[research/done/2026-06-20-briar-bond-hooks]]; live quirk thresholds confirmed accurate): (1) wire Briar reactions to **VillageState / Warden Oslo** (high bond → early warning / slight decay help; corruption → unpredictable); (2) complete **dig-to-lore + interest-point gaze** (bond controls reliability of scent-growl / ear-perk toward buried recontext); (3) expose **2–3 authored bond milestones** that feel earned/visible. Named gaps to fill eventually: mercy/soothe synergy (high bond strengthens soothe; corruption interferes), an adaptive-audio Briar whimper/growl layer in the dread stems, and threshold-gated refusal/breaking-point scenes. *(Consolidates the Briar/warden/bond-growth ideas already captured above.)* See [[characters/companions]].
- **Escape-room set-piece — post-slice signature feature** (spec at [[mechanics/escape-room-setpiece]], from [[research/done/2026-06-20-escape-room-set-piece-research]]): ONE bespoke locked room at the conspiracy reveal — solving it *is* how the truth comes out — fusing locked-in horror + lore-by-solving + a Briar-cooperation climax (needs both child and dog). 2–3 layered steps, diegetic (no markers/HUD/timer), fair via the Three-Clue Rule + no soft-locks. Build order: empty sealed room → one Briar step → rest + dread escalation → fairness/polish. Not recurring — a one-off.
- **Warden Oslo patrol — confirmed sound + two post-slice extensions** (from [[research/done/2026-06-20-warden-oslo-search-patterns]]): the stage-2 marker-patrol + LOS-notice warden is accurate to code and well-tuned — **keep it**. Post-slice (hand-written, not procedural): (1) high Briar bond → small notice-rate reduction / early warning when Oslo is near (low bond/corruption → Briar more fearful); (2) a successful multi-phase evasion writes a small authored recontext (new gossip / missed clue / journal entry). See [[mechanics/village-life]].
- **Suspicion decay — confirmed sound + one post-slice extension** (from [[research/done/2026-06-20-villagestate-suspicion-decay]]): the current `0.7×`/phase decay (with report threshold 100 → +25 alarm, eavesdrop ×2.5) is well-tuned — **keep it**. Post-slice, make decay **companion/morality-aware** via hand-written flags (not procedural): ruthless morality → slower decay (villagers stay paranoid); high Briar bond → small zone decay bonus or one authored "distraction" per phase. A specific case of the Terranigma authored-village-evolution idea; see [[mechanics/village-life]].
- **Player abilities — post-slice directions** (from [[research/done/2026-06-20-player-abilities]]), in suggested order: (1) **crouch / low stance** — hide during dread spikes, dodge VillageState suspicion, alternate paths ([[mechanics/vision-and-darkness]]); (2) **age/morality attack variants** — make progression visible in combat (start with two feels + companion reactions, [[mechanics/combat]]); (3) **Briar-assisted movement** — high bond boosts/vaults you to reach spots, a relationship move not a generic jump ([[characters/companions]]); (4) **short dodge** (dodge → soothe, can shave dread). *Careful:* free **jump** stays rare/story-gated only (platformer creep + 32×32 readability); a separate **punch** button is redundant → fold into the attack variants / close-range mercy option.
- **Equipment (Ausrüstung) system — post-slice feature** (spec at [[mechanics/equipment]], from [[research/done/2026-06-20-ausruestung-equipment-system-research]]): a child's tools/garments/keepsakes in ~3 hand-placed tiers, sold by one diegetic reactive merchant; medium stat weight, no numeric HUD ("stronger" shown via sprite/recontext/Journal/companions/audio). Build order (content-first): (1) extend ItemDef + equip slots + tiny equip screen + one found tool; (2) author 2–3 tiers for one slot; (3) one Dialogue-Manager merchant; (4) merchant reacts to morality + dread; (5) soothe/utility identity gear + polish. Sequenced after vision-cone + Hollow House authoring. Don't add a tier/slot without authored content.

### SNES-classics design directions (post-slice) — from [[research/done/2026-06-20-zelda-terranigma-mana-evermore-transferable-features]]
*Directions to consider after the current slice; all amplify systems we already have, none reopen a locked decision.*
- **"Same place, wrong now" — recontext state layers** (Zelda ALttP Light/Dark world): give a zone 2–3 *authored* states (normal → escalating dread → post-revelation) flipped by morality/bond/story flags, not a global switch. Pilot ONE zone (village green or Hollow House). Web-safe authored flips, not real parallel-dimension tech. Builds on [[mechanics/zone-recontextualization]] (system already exists).
- **Deeper Briar (dog) utility** (Secret of Evermore): bond/corruption drive her dig/sniff/bark "reveal" assists and make corruption *visible/wrong* (glowing eyes, off movements). High bond = reliable reveals; low/corrupted = fearful/unpredictable. Builds on companion bond/corruption + LimboAI + DreadManager. See [[characters/companions]].
- **Authored village evolution** (Terranigma): the village visibly changes from the player's choices via *hand-written* VillageState flags (suspicion/routines/ritual remnants) tied to morality/bonds — never procedural. Keep it subtle horror-tinged, not town-building. See [[mechanics/village-life]].
- **Bond-threshold companion growth** (Mana/Evermore): 2–3 bond milestones per companion unlock specific new assists/story beats (extends the Briar item above). Authored per companion, not generic party leveling.
- *Skip — radial "Ring Command" menu* (Secret of Mana): do NOT port. Too close to the BioWare radial-dialogue patent guardrail, adds menu clutter, weak on Web/horror. Use context actions / linear list menus instead.
- *Use sparingly — Zelda dungeon key/item hunting*: at most one or two "revelation keys" / companion-assisted environmental solves that open new recontext or dialogue. Avoid full traditional key loops (slows the horror pacing).
- *Low priority — Evermore alchemy/crafting*: only if reframed as "ritual fragments / conspiracy echoes" that serve a horror beat or revelation (e.g. a crafted soothe that reveals a hidden truth). Skip if it turns grindy/menu-heavy.

- **✅ RESOLVED 2026-06-20 — LimboAI exports cleanly to Web.** Headless release export (`godot --headless --export-release "Web"`) succeeds with `rc=0`, no errors, and bundles `liblimboai.web.template_release.wasm32.nothreads.wasm`. Toolchain confirmed correct: the Web preset has `variant/extensions_support=true` (GDExtension dlink template) + `variant/thread_support=false` (nothreads → no COOP/COEP needed); LimboAI's `.gdextension` declares `web.*` libs and ships both nothreads/threads wasm; the `web_dlink_nothreads_release.zip` template is installed. *Remaining (human, runtime-blind for agents): serve the build and open it in a browser to confirm the wasm initializes + a LimboHSM runs in-page — nothreads serves from any static host.* See [[sessions/2026-06-20-verify-limboai-web]], [[design/ai-production-setup]] Web-export constraints.
- **Keep AdaptiveAudio Sample-mode-safe** (same survey): Godot Web audio is Sample mode — no `AudioEffect`/reverb/procedural. AdaptiveAudio is currently clean (crossfaded stems, no effects) — keep it so; pre-bake any future effect into the file rather than adding runtime DSP. See [[design/ai-production-setup]] Web-export constraints.
- ✅ **CONFIRMED 2026-06-20 — Web audio works in a real browser.** Exported the build (`godot --headless --export-release "Web"`, clean), served it (`python3 -m http.server` over the `exports/web` bundle), and the human played it in-browser: **everything works, sounds are audible.** So both Web risks are now closed — LimboAI (`nothreads` wasm) *and* audio. Background (why this mattered): browsers block audio until the first click/tap and Web crossfade timing is looser than in-editor, so "works on F5" never proved Web; `AdaptiveAudio` is DSP-free volume crossfades on the game clock, which is exactly the Web-safe pattern. **Re-confirm after any Godot/addon version bump** (templates + addons are pinned to the engine version). `[verified 2026-06-20 — in-browser playtest]`
- *Confirmation (no action):* the 2026 orchestration survey validates the existing setup — TradeForge single-source-of-truth (vault → scoped task spec → Claude Code → verify), the plan→verify→evidence loop, and the PixelLab generate-curate-finish pipeline are the recommended patterns. Nothing to change.
- **Adopt the Michael Games asset pack as a quarantined placeholder source** (from [[research/done/2026-06-20-michael-games-aarpg-harvest]]): drop the CC/free-commercial, no-AI pack (`michaelgames.itch.io/2d-action-adventure-rpg-assets`) under a `placeholder/`-style path so it pairs with the placeholder-mode build (real drawn greybox > polygon for silhouette/scale). **Placeholder-only — prohibited from ship** (own palette/projection → Projection Canon + palette-lock violation). Needs the lint/gate to isolate `placeholder/` so it can't survive into a release build.
- **Combat code reference (read-only)**: MIT `github.com/michaelmalaska/aarpg-tutorial` — clean typed Area2D hit/hurtbox to compare against if we revisit combat plumbing. Do NOT lift its direct-singleton-call wiring (keep GameEvents) or its hand-rolled FSM (stay on LimboAI). See [[mechanics/combat]] Technical Notes.
- **Aseprite (optionality note)**: not in the stack ("no Aseprite installed"); it's the community-standard hand-edit/cleanup tool *if* a need ever arises (fixing a PixelLab frame, tuning a placeholder, a one-off). No stack change implied.
- **Art-register Stage 1 (from [[research/done/2026-06-20-pixel-art-pipeline-consistency]])**: author a single **master palette PNG** (32–48 colors) + one character turnaround + one tile/material reference sheet, and stand up a **runtime WebGL2-safe palette-clamp shader** (canvas_item, fixed-iteration — no dynamic loops; KoBeWi MIT base), confirmed in a real HTML5 export *before* relying on it (fallback: bake palette quantization at import). The style-lock protocol = minimize generators + lock one master ref/palette, not better prompting. Ties into [[art/prop-coherence]] Rule 1 (resolves the per-zone-48 vs one-master-palette question).
- **LPC Spritesheet Generator** as a free *consistency backbone* if PixelLab character drift persists — re-skin its shared 4-dir skeleton into our register via the palette clamp. ⚠ Licensing: CC-BY-SA 3.0 / GPL 3.0, attribution + DRM-clause care for Steam/iOS (see ai-production-setup red lines). `[verified 2026-06-20]`
- **ComfyUI circular-padding seamless tiling** (Seamless Tile node + Make Circular VAE, or ComfyUI_Seamless_Patten) as the tileset fallback if PixelLab `create_topdown_tileset` seams are unacceptable; verify seams with an Offset Image node. `[verified 2026-06-20]`
- **Bug (pre-existing, found 2026-06-19)**: zone smoke tests log `Node not found: "Ground"` / `"DuskTint"` and `set_cell on a null value` for `village_green.gd` + `playground_fringes.gd` — those zone scripts reference nodes the scenes don't have (scenes use `GroundBackdrop`; there's no `DuskTint`). Tests still pass (null-tolerant) but it's noisy and a latent crash. Fix the node names or guard the lookups.
- Cleanup: `scripts/world/gated_door.gd` is now unused by any scene (Hollow House inner gate went key-item, 2026-06-19, [[decisions/2026-06-19-hollow-house-key-gate-hybrid]]). Delete once no planned slice wants a dig-to-open gate.
- ✅ DONE 2026-06-20 — Monster + ambient SFX wiring: monster sounds (`monster_attack`/`monster_hurt`/`monster_creep`) were *already* wired in `enemy_base.gd`, and the doom bell *already* tolls per stage advance (`HollowingClock._ring_bells`, countable). Newly wired this pass: **`campfire_crackle`** loops on the Hideout fire (AudioStreamPlayer2D). Tests in `test_ambient_audio.gd`.
- ✅ DONE 2026-06-20 — Ambient SFX beds: **crickets** night bed (looping, always under the score) + **owl** occasional stinger now driven by AdaptiveAudio (owl hushes in the hideout / near a threat). Loop-enabled the `crickets.wav` import. Pure `AdaptiveAudio.owl_due` is unit-tested.
- ✅ DONE 2026-06-20 — Per-surface footsteps: the hook (player picks by `SurfaceZone`) shipped earlier; this pass authored the real playground **surface map** (path hub, sand pit, wood on swings/slide/roundabout/frame; `wood`→hard step). Positions are best-effort over the *painted* equipment — an editor pass can nudge them. `test_footstep_surface.gd`.
- SFX coverage gaps (next ElevenLabs batch when credits reset): monster vocalizations (twisted-child stalk/lunge), item pickup vs the "found" stinger, bond-up chime, UI open/close (satchel/journal), water/fog ambience.
- ✅ DONE 2026-06-20 — Weapon combat wiring: `sturdy_stick` = EQUIP (melee swing), `slingshot` = THROW (projectile spending `sling_stones`); equip via the satchel, attack reads the equipped weapon. ItemDef UseKind EQUIP/THROW + ammo_id, PlayerData.equipped_weapon, `thrown_projectile.tscn`. Tested in `test_weapon_combat.gd`.
- ✅ DONE 2026-06-20 — Weapon **legibility** follow-up (playtest: "items cannot be equipped" / "unclear if I hit with hands, stick or slingshot"). Equipping always *worked* but was invisible. Fix: HUD weapon line ("Bare hands" / name / "Slingshot (N)"), satchel **equipped slot glows** + **"Tap to equip"** affordance in the detail panel, and a **per-weapon swing pitch** (stick lower, sling higher) so the three read audibly. `Sfx.play` gained a `base_pitch` arg. `test_weapon_feedback.gd`. (No balance change — hands/stick stat-weight is still the deferred equipment pass.)
- ✅ DONE 2026-06-20 — Item world-placement: `forest_berries` + the three weapon items (`sturdy_stick`/`slingshot`/`sling_stones`) now placed as `ForageSpot` pickups in playground/fringes. Tested in `test_item_placement.gd`. (Dig-up items were already placed.)
- Dig-up loot variety: `DiggableSpot.dig_item` is a single id — a weighted table or per-NG+ swap (like `lore_text_recontext`) could make repeat digs less samey.
- Inventory v1.1: shared "one modal at a time" guard — Journal + Inventory panels both sit at layer 60; v1 mitigation is force-close-on-foreign-pause, but a single modal-stack arbiter would be cleaner. From [[decisions/2026-06-13-inventory-system]].
- Inventory touch parity hardening: the v1 "BAG" button opens the satchel, but slot interaction (feed/inspect) on touch isn't designed yet — needs a touch pass before the mobile demo.
- Item effect extensibility: `use_kind` enum reserves HEAL / REDUCE_DREAD; first utility consumable (bandage / clean lantern oil) will exercise the non-FEED dispatch + the `consumed_on_use=false` reusable-tool path (whistle/lantern).
- Morality-flavored item *effects* (not just descriptions): the "kind herb soothes / ruthless prep poisons" idea from [[mechanics/inventory]] is still unbuilt — v1 only swaps description text.
- Quirk journal UI: let the player pin one observed line per discovered quirk (companion-quirks.md diagnosis loop) — fold into the interface-horror/UI pass.
- ✅ DONE 2026-06-20 — Plateau discovery cue: when generic soothe stalls at 60, the monster now briefly **turns toward its buried key** (no UI), via `EnemyBase._update_glance` + pure `should_glance_at_secret`. Tested in `test_monster_glance.gd`. (Complements the existing "it calms… but something is missing" stall feedback.)
- ✅ DONE 2026-06-20 — Faction-aware hitboxes: added `Faction` (player/ally/enemy) + a `hostile()` rule (hit lands only across the player-side↔monster line), plus same-character self-exclusion in `Hurtbox`. A Dominated thrall's lunge is now `ally` — wounds enemies, never Rowan. Plumbing only; reused the existing hit/hurtbox nodes (one shared `hit_hurt` layer + code filter, no per-faction layers). `tests/test_faction.gd`, `test_combat_boxes.gd`, `test_enemy_base.gd`.
- **Detective / "focus" vision sense** *(borderline — flagged, R7 2026-06-13)*: an RDR2-Eagle-Eye-style player highlight (slow-move + short-range gated). **Only revisit if playtests show players hard-stuck** — it risks undercutting dread and duplicating [[mechanics/companion-pointer]] Briar-seek. Fails the four-pillar filter as-is. From [[research/done/2026-06-13-companion-pointer-investigation-design]].
- **Guiding-wind environmental cue** (R7 2026-06-13): a subtle diegetic directional reinforcement for Briar-seek without UI — leaf/dread-fog drift, or a doom bell growing louder toward the target (Ghost of Tsushima's wind, our flavor). Reinforces, never replaces, Briar.
- **Whistle-to-recall-and-re-point** (R7 2026-06-13): the reserved reusable whistle tool (see Item effect extensibility above) doubles as the Briar-seek *recall* — re-triggers her tell so the cue is never a one-shot. Folds into [[mechanics/companion-pointer]].
- **Player-triggered re-hint escalation** (R7 2026-06-13): if the player keeps missing a clue, escalate Briar's insistence **only when recalled**, never auto-interrupt (avoids Okami/Issun's "breaks into a cutscene to point at the obvious").
- **Hollow House — world entrance** (hollow-house slice 2026-06-13): the quest scene is bootable standalone but has no in-world door yet. Add a `DoorTransition` into `hollow_house` from the village + a `spawn_from_hollow_house` marker in `playground_fringes` so the exit lands somewhere authored. Editor pass.
- **Hollow House — real art + audio** (2026-06-13): graybox placeholders shipped — real interior tiles/props, a dedicated `seek_tell` Briar animation (currently reuses dig/stare/trot), and a real `briar_seek` bark (ElevenLabs, when credits reset; placeholder yip in place). Pixel/audio pass.
- **Recall input touch parity** (2026-06-13): the new `recall_companion` action (C) needs a touch control before the mobile demo — fold into the touch-controls pass alongside the satchel BAG button.
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
- Extra art vendors — Ludo.ai tilesets, Leonardo/Midjourney "tilemap export" (2026-06-12 art-tooling research): Ludo adds nothing layout-level [verified 2026-06-12]; Leonardo/MJ first-party tilemap export likely doesn't exist [unverified]; all three would add vendors to the locked art lane without capability we lack. ([[art/prop-coherence]])

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

*(Secrets research 2026-06-13 deepened the first three of these with sourced backing — Animal Well "each tool teaches a singular fact, discoverable through play not text"; Crow Country ships a combat-free Exploration Mode + 15 optional non-combat secrets; Lorelei keeps all knowledge in-game + randomizes solutions. All folded into [[design/secrets-and-discovery]].)*

## 📥 Captured this session (footstep surfaces, 2026-06-13)

- **SurfaceZone editor pass**: the per-surface footstep hook ships with ONE rough `PlazaGravel` zone in the playground — author the real surface map in the editor (path band, ritual sand, wood on the play equipment). Add `SurfaceZone` Area2Ds, set `surface` (gravel/path/sand → gravel sound; anything else → grass). Pairs with the SFX session's `footstep_gravel` wiring.

## 📥 Captured this session (interior room pipeline research, 2026-06-14)

Synthesized in [[art/interior-design-kit]] + [[art/prop-coherence]]; deferred tooling
captured here ([[research/done/2026-06-14-research-interior-room-pipeline]]). Minimum
viable build order: Blender rig → script → QA gate → room template; ComfyUI when the
prop-depth cap bites; LoRA last.

- **Blender canon-angle orthographic greybox rig** — cheapest, highest-leverage
  perspective lock; renders depth/structure control images at the ~20° oblique to feed
  both PixelLab depth-img2img (props) and ComfyUI ControlNet (backdrops). Build first.
- **One automated `downscale(NN) → grid-snap/quantize → palette-lock → QA-gate` script**
  run on 100% of assets — extend the QA gate to also check palette conformance on
  backdrops (not just projection ratios).
- **ComfyUI Depth + MLSD ControlNet** for room backdrops too big for the 180px
  depth-img2img cap / when backdrop drift bites. MLSD keeps wall lines straight.
- **Self-trained style LoRA** on ~20–40 own palette-locked canon-angle assets — only if
  style drift persists after ControlNet (last resort).
- **Retro Diffusion** (FLUX, hard 32/64 grid alignment, palette control, ControlNet+LoRA,
  Aseprite ext/API) — strongest specialized supplement if grid fidelity stays the pain.
- **Web-export watch**: Compatibility renderer, shared prop/wall atlases, mid-size
  backdrops, let Godot emit WebP; watch unique-PNG count (Godot 4.3 wasm ≈40 MB raw /
  ~5 MB Brotli baseline).

## 📥 Captured this session (interior design kit, 2026-06-14)

Synthesized in [[art/interior-design-kit]]; engineering task captured here.

- **Stairs set-piece tech** (the one hard problem in flat top-down): when authored stairs land, support (a) a **railing-tile layer above the player** so Rowan draws *behind* the rail descending, and (b) **slow player movement while on a stair `Area2D`** to sell depth the flat camera can't show (Bitzos). Pairs with `DoorTransition` stair set-pieces ([[mechanics/accessible-interiors]]). Defer until the real interior art pass replaces the graybox.

## 📥 Captured this session (secrets research, 2026-06-13)

Synthesized in [[design/secrets-and-discovery]]; raw captures here for the inbox trail.

- **Obra-Dinn confirmation buffer** ("confirm in threes"): for any deduction-style cult secret, require N confirmations before the game locks it in — blocks brute-force guessing. Copied since by Golden Idol / Roottrees. Reserve for after the early arc proves out.
- **Replay/failure as the key** (Inscryption): the safe code is only visible after the player has died at least once — failure itself unlocks. Candidate flavor for NG+ / death-gated reveals; pairs with the existing NG+ echoes.
- **Second-read VillageState gossip**: author gossip lines that read differently once a revelation is known (Undertale-style foreshadowing-that-only-reads-post-twist; In Stars and Time loop-locked re-interaction). Cheap replay layer on the existing stage-keyed gossip pools.
- **"Three players at once" layering** (Animal Well): clean critical path / optional explorer layer / reserved NG+/community layer — density under constraint. The structural target once the early secrets arc lands.

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

## 📥 Captured this session (projection canon, 2026-06-12)

- **QA overlay layer** (user art task): transparent layer with the two canon ellipses, a canon box, and a vertical ruler — the rule-5 import gate for every new prop/building/repaint. ([[art/prop-coherence]]) → **CLOSED 2026-06-12**: shipped as `assets/reference/qa_overlay_128.png` + legend + `tools/gate_sheet.py` (no Aseprite needed).
- **Bitforge fallback params unconfirmed**: confirm `view`/`oblique_projection` on `generate-with-style-v2` against https://api.pixellab.ai/v2/openapi.json before next relying on the fallback path.

## 📥 Captured this session (research round 3, 2026-06-12)

- **External playtest cadence**: 3–5 outside testers through the NAS/itch web build at the end of *every* content arc — not just the next one. (Round-3 audit; the rest of its process advice lives in the roadmap "Next arcs" block.)
