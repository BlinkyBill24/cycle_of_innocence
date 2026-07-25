---
name: Agentic playtest smoke
date: 2026-07-24
tags: [design, testing, agents, pipeline]
status: active
related:
  - "[[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]"
  - "[[design/hollow-house-quest]]"
  - "[[research/done/Claude-Godot-MCP-Servers-Research-2026-06-28]]"
---

# Agentic playtest smoke

**Plain language:** before an agent (or you) says “the hollow-house path still works,” run a short checklist that boots the game, proves the key/door/book wiring is still plugged in, and catches script crashes. This does **not** decide if the house feels scary — that stays a human F5 call.

Comes from the “one-person AI studio” Testing pillar: agents should **show evidence**, not only write code. `[[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]`

## One command (headless)

```bash
bash tools/playtest_smoke.sh
```

| Flag | Meaning |
|---|---|
| `--gut-only` | Only GUT wiring + quest logic |
| `--boot-only` | Only headless scene boots |
| `--frames N` | Frames to run each boot (default 120) |

Also keep the full suite: `bash tools/run-tests.sh`.

### What the shell smoke covers

1. **GUT** — `test_playtest_smoke_path.gd` (placements) + hollow-house logic + flute placement + village load.  
2. **Headless boot** — main playground, hollow house hall/back, village green — fail on `SCRIPT ERROR` / parse errors.

### Exit meaning

- **0** — wiring + boots look clean enough for agents to continue.  
- **Non-zero** — fix before claiming the path works.  
- **Human still required** for dread, bond, control feel, touch, and Web export.

## Critical path (what “green” means)

| Step | In game | How smoke checks it |
|---|---|---|
| Enter house from village | `HollowHouseDoor` → `hollow_house.tscn` | GUT wiring |
| Dig buried key | `BuriedKey` dig_item `hollow_key` | GUT + logic reveal |
| Unlock inner door | `InnerDoor` unlock_item / flag | GUT + logic unlock |
| Back nook | flute + ledger | GUT placement |
| Truth beat | book read + 2 doom signs → revelation | GUT quest logic |
| Boot no crash | main + house scenes | headless `--quit-after` |

## Live MCP walk (godot-mcp-runtime)

Use when you need **screenshots** or live tree state (not only headless). Requires the Godot MCP server.

**Do not run `tools/playtest_smoke.sh` while an MCP `run_project` session is active** — both inject/use the bridge and can fight over the TCP port. Stop MCP first (`stop_project`), or run smoke after the live walk.

### Recipe

1. **`run_project`**
   - `projectPath`: repo root  
   - `scene`: omit (uses main) or `scenes/zones/hollow_house.tscn`  
   - `background`: `true` for unattended agent runs  

2. **Wait** ~2s for boot, then **`get_debug_output`** — fail if `SCRIPT ERROR`.

3. **`run_script`** — teleports / grants state so you don’t need perfect pathfinding. Example:

```gdscript
extends RefCounted
func execute(scene_tree: SceneTree) -> Variant:
	var out := {}
	var player := scene_tree.get_first_node_in_group("player")
	out["has_player"] = player != null
	out["zone"] = str(ZoneManager.current_zone_id) if ZoneManager else ""
	# Force mid-quest state for a door check (does not replace full F5):
	if not Inventory.has(&"hollow_key"):
		Inventory.add(&"hollow_key")
	out["has_key"] = Inventory.has(&"hollow_key")
	out["dread"] = DreadManager.dread if DreadManager else -1.0
	out["flute_found"] = PlayerData.has_story_flag(&"flute_found")
	if player:
		out["player_pos"] = [player.global_position.x, player.global_position.y]
	return out
```

4. **`take_screenshot`** — at least:
   - boot / current zone  
   - after granting key (or after dig, if you simulate it)  
   - optional: open inventory (`I` via `simulate_input`)  

5. **`simulate_input`** (optional movement): short `W`/`A`/`S`/`D` holds with `wait` frames between press/release. Prefer `run_script` for state assertions.

6. **`get_debug_output` again** — still no `SCRIPT ERROR`.

7. **`stop_project`** when done (frees the single process slot).

8. Run **`bash tools/playtest_smoke.sh`** or full **`tools/run-tests.sh`**.

### Screenshot storage

MCP saves under `.mcp/screenshots/` (gitignored). Attach paths or describe them in the session journal; do not commit binary dumps unless intentional.

## When to run

| Moment | Minimum |
|---|---|
| After touching doors, diggables, inventory, zones, hollow-house scripts | `playtest_smoke.sh` |
| Before “done” on a feature that touches the slice path | smoke + full GUT |
| Art-only import | boot-only is enough if no scripts changed |
| Claiming dread/bond “feels right” | human F5 only |

## What this is not

- Not a replacement for Web export smoke (`tools/serve_web.py` + browser).  
- Not automated pathfinding through the whole village.  
- Not balance or horror tuning.  
- Not Sorceress / WizardGenie — stays in Godot.  

## Completion checklist (agents)

- [ ] `bash tools/playtest_smoke.sh` exit 0  
- [ ] (If runtime MCP available) one screenshot path noted in the session journal  
- [ ] `bash tools/run-tests.sh` when the change is broader than the smoke select list  
- [ ] Human told what still needs eyes (feel / Web / touch)

## Related code

- `tools/playtest_smoke.sh`  
- `tests/test_playtest_smoke_path.gd`  
- `tests/test_hollow_house.gd` (`test_full_quest_path_smoke`)  
- `scripts/world/hollow_house_quest.gd` · `door_transition.gd` · diggable / forage spots  
