---
name: How to call role agents and the swarm
tags: [agents, howto, swarm]
---

# How to use the agents (cheat sheet)

Plain instructions. Same rules for Claude Code and Grok when skills are loaded.

---

## 0. Always (before real work)

1. Be on a **feature branch** (not `main`) if files will change.  
2. Everyone obeys **`AGENTS.md`** + `docs/agents/shared-contract.md`.  
3. End big sessions with **`/reflect`**.

---

## 1. Call **one specialist** (smallest tool)

Type the slash command **or** say the role name.

| You type / say | What you get |
|----------------|--------------|
| `/level-design` | Zone / graybox / transitions |
| `/creative-art` | Still pixels, props, concepts |
| `/programming` | Feature + tests |
| `/animation` | Motion / SpriteFrames |
| `/story-writer` | Canon, dialogue, lore hooks |
| `/dread-director` | One horror beat |
| `/companion-designer` | Briar / Echo beat |
| `/combat-designer` | Attack / mercy / gates |
| `/audio` | SFX wiring |
| `/playtest-qa` | Smoke / proof (not “fun”) |
| `/librarian` | Research triage |
| `/reviewer` | Risk review |
| `/project-manager` | Coordinator only |
| `/reflect` | Session close |

**Example prompts after the slash:**

```text
/programming
Implement bare fists dealing no damage to monsters. Tests required.

/story-writer
Write the hollow-house key find line and the Journal entry. Flag: hollow_key.

/playtest-qa
Run smoke and report evidence only.
```

**Tip:** One role per message when you want a clean lane. Hand off explicitly:
“Done for story-writer; switch to /programming.”

---

## 2. Call the **project manager** (coordinator in chat)

```text
/project-manager
Mission: <one sentence>
Constraints: <optional>
```

**Examples:**

```text
/project-manager
Mission: Wire flute-gate so weapons also do nothing to monsters pre-flute.
Pick roles, order them, and dispatch one at a time. Do not implement yourself.

/project-manager
What is the best next bite from STATE.md and ideas.md? Plan only.
```

The PM should answer with: **Mission / Branch / Order / Human gates / Next**.  
Then either it dispatches roles in this chat, or you start a workflow (below).

---

## 3. Call the **full swarm** (option C) — workflows

Workflows are automated multi-agent runs (Grok Build). Watch them in **`/workflows`**.

### A) You already know the mission → `content-studio`

**In Grok**, run the named workflow with args (UI or tool equivalent):

```text
/workflow content-studio
```

**Args (conceptually):**

| Arg | Required | Meaning |
|-----|----------|---------|
| `mission` | **yes** | One sentence deliverable |
| `mode` | no | `"plan-only"` or `"full"` (default full) |
| `story` | no | `true`/`false` — default **true** on full |
| `code` | no | default **true** |
| `level` | no | default **false** |
| `art` | no | default **false** |
| `animation` | no | default **false** |
| `audio` | no | default **false** |
| `dread` | no | default **false** |
| `companion` | no | default **false** |
| `combat` | no | default **false** |
| `qa` | no | default **true** on full |
| `review` | no | default **true** on full |

**Example missions:**

```text
mission: "Add bare-fists-no-monster-damage with GUT tests"
mode: "full"
story: false
code: true
combat: true
qa: true
review: true
```

```text
mission: "Place berries forage spot in playground fringes with Journal line"
mode: "full"
story: true
code: true
level: true
art: false
qa: true
```

```text
mission: "Only plan Briar pose polish pass"
mode: "plan-only"
```

**What happens on `full`:**

1. PM agent plans (read-only).  
2. **You** approve at a pause (resume in `/workflows`).  
3. Roles run **in sequence** for lanes you turned on.  
4. QA + reviewer.  
5. **You** F5 feel gate (pause).  
6. Final report in the workflow result.

**Do not** turn every lane on for one mission.

### B) “What next?” then maybe build → `project-swarm`

```text
/workflow project-swarm
```

Optional args: `hint` (string) if you already lean toward a topic.

**What happens:**

1. PM reads `STATE.md`, ideas, slice goals → proposes **one** next mission + lanes.  
2. **You** approve / edit at pause.  
3. Same pipeline as `content-studio` for that mission.  
4. Human F5 gate → report.

---

## 4. Manual swarm (no workflow UI)

Use this in Claude Code or any chat that has the skills:

```text
1) /project-manager
   Plan mission X. List order only.

2) /story-writer
   (only the story task from the plan)

3) /programming
   (only the code task)

4) /playtest-qa
   Prove it.

5) /reviewer
   Risk pass on the branch.

6) You F5 in Godot.

7) /reflect
```

You are the “resume button” between steps. Slower than workflows; easier to steer.

---

## 5. Safety cheats

| Don’t | Do instead |
|-------|------------|
| 12 writers at once on one scene | Sequential implementers |
| Skip smoke after zone/code | `/playtest-qa` |
| Let PM “just code it” | Force hand-off to `/programming` |
| Trust agent “dread lands” | Your F5 |
| Work on `main` | Feature branch first |
| Infinite epic mission | Cut to one bite |

---

## 6. After any swarm

1. Read the report (what shipped / blocked).  
2. Play the bite yourself.  
3. Commit/push if not already (R6).  
4. Merge via Forgejo tools when happy.  
5. `/reflect` + web **Sync now** when the session ends.

---

## Quick decision tree

```text
Need one craft job?          → /role-name
Need a plan + order?         → /project-manager
Know mission, want auto crew → /workflow content-studio
Don't know next work?        → /workflow project-swarm
Session over?                → /reflect
```

More context: [[README]] · [[swarm]] · [[shared-contract]]
