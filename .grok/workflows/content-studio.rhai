let meta = #{
    name: "content-studio",
    description: "PM plans one CoI content bite, then runs selected role agents in order with human gates",
    when_to_use: "Ship one vertical content bite with the multi-role swarm (option C)",
    phases: [
        #{ title: "Plan", detail: "project manager reads brain and plans lanes" },
        #{ title: "Approve", detail: "human approves or edits the plan" },
        #{ title: "Build", detail: "role agents implement in sequence" },
        #{ title: "Verify", detail: "playtest-qa + reviewer" },
        #{ title: "Feel", detail: "human F5 gate" },
    ],
};

let plan_schema = #{
    "type": "object",
    "required": ["mission", "branch_slug", "summary", "steps", "human_gates", "risks"],
    "properties": #{
        "mission": #{ "type": "string" },
        "branch_slug": #{ "type": "string" },
        "summary": #{ "type": "string" },
        "steps": #{
            "type": "array",
            "maxItems": 12,
            "items": #{
                "type": "object",
                "required": ["role", "task"],
                "properties": #{
                    "role": #{ "type": "string" },
                    "task": #{ "type": "string" },
                },
            },
        },
        "human_gates": #{ "type": "array", "items": #{ "type": "string" }, "maxItems": 8 },
        "risks": #{ "type": "array", "items": #{ "type": "string" }, "maxItems": 8 },
    },
};

let step_schema = #{
    "type": "object",
    "required": ["status", "summary", "hand_off"],
    "properties": #{
        "status": #{ "type": "string" },
        "summary": #{ "type": "string" },
        "hand_off": #{ "type": "string" },
        "files_touched_note": #{ "type": "string" },
    },
};

let verify_schema = #{
    "type": "object",
    "required": ["status", "evidence", "blockers"],
    "properties": #{
        "status": #{ "type": "string" },
        "evidence": #{ "type": "string" },
        "blockers": #{ "type": "array", "items": #{ "type": "string" }, "maxItems": 8 },
    },
};

// --- args ---
if args == () { pause("verification", "Pass args.mission (one sentence). Optional: mode plan-only|full, and lane flags story/code/level/art/animation/audio/dread/companion/combat/qa/review as true/false."); }

let mission = args.mission;
if mission == () || mission == "" {
    pause("verification", "args.mission is required — one sentence deliverable.");
}

let mode = "full";
if args.mode != () && args.mode != "" { mode = args.mode; }

fn flag_default(v, default_on) {
    if v == () { default_on } else { v == true || v == "true" || v == 1 }
}

let on_story = flag_default(args.story, true);
let on_code = flag_default(args.code, true);
let on_level = flag_default(args.level, false);
let on_art = flag_default(args.art, false);
let on_animation = flag_default(args.animation, false);
let on_audio = flag_default(args.audio, false);
let on_dread = flag_default(args.dread, false);
let on_companion = flag_default(args.companion, false);
let on_combat = flag_default(args.combat, false);
let on_qa = flag_default(args.qa, true);
let on_review = flag_default(args.review, true);

if mode == "plan-only" {
    on_qa = false;
    on_review = false;
}

// --- shared prompt preface ---
let law = "";
law += "You work on Cycle of Innocence (Godot 4.4 GDScript). Obey AGENTS.md and docs/agents/shared-contract.md. ";
law += "R1: never commit to main; use/create a feature branch. R5: note journal needs. ";
law += "Hard bans: no C#/.NET, no runtime LLM in game, no nemesis/procedural companion ranks, Storm mount is cut, flute-gates monster mercy, bare fists do not harm monsters, only Briar+Echo as companion design. ";
law += "Plain language in your summary. Mission: ";

let mission_q = json_encode(mission);

// ========== PLAN ==========
phase("Plan");
log("PM planning mission");

let pm_prompt = "";
pm_prompt += law;
pm_prompt += mission_q;
pm_prompt += " ROLE: project-manager only. Read STATE.md, AGENTS.md vertical slice, docs/agents/swarm.md, and docs/ideas.md using read_file/grep. ";
pm_prompt += "Produce ONE vertical bite plan. branch_slug like feature/short-name. steps[].role must be from: ";
pm_prompt += "story-writer, programming, level-design, creative-art, animation, audio, dread-director, companion-designer, combat-designer, playtest-qa, reviewer, librarian. ";
pm_prompt += "Only include steps needed for the mission. Prefer fewer steps. human_gates must include a real F5 feel check when anything playable changes. ";
pm_prompt += "Do not implement code or art. Use tools; do not answer from memory alone.";

let pm = agent(pm_prompt, #{
    label: "pm-plan",
    capability_mode: "read-only",
    output_schema: plan_schema,
});

if pm == () || !pm.success || pm.output == () {
    complete(#{ summary: "PM plan failed", ok: false });
}

let plan = pm.output;
let plan_json = json_encode(plan);
log("Plan ready: " + plan.summary);

// ========== APPROVE ==========
phase("Approve");
await_user("user", "Approve this Content Studio plan (or edit mission/lanes and re-run). Resume to continue build. Plan JSON was produced by PM — check mission, steps, human_gates, risks in the run log/result.");

if mode == "plan-only" {
    let ppath = write_scratch_file("content_studio_plan.json", plan_json);
    complete(#{
        summary: "Plan-only complete",
        mode: mode,
        plan: plan,
        path: ppath,
        ok: true,
    });
}

// ========== BUILD (sequential implementers) ==========
phase("Build");

let role_preface = "";
role_preface += law;
role_preface += mission_q;
role_preface += " Full plan JSON: ";
role_preface += plan_json;
role_preface += " ";

fn run_role(role_name, lane_on, skill_hint, cap_mode) {
    if !lane_on {
        return #{ skipped: true, role: role_name, status: "skipped", summary: "lane off", hand_off: "" };
    }
    log("Dispatch " + role_name);
    let p = "";
    p += role_preface;
    p += "ROLE: ";
    p += role_name;
    p += ". Load and follow the job contract in .claude/skills/";
    p += role_name;
    p += "/SKILL.md (read_file it). ";
    p += skill_hint;
    p += " Do only this role's lane. If the plan has no step for you, set status=skipped. ";
    p += "If your work is blocked, status=blocked with reason. Else status=done. ";
    p += "Use tools (read/edit/test as your capability allows). Implement the task from the plan steps matching your role. ";
    p += "Keep the change vertical-slice small. hand_off: who should go next.";
    let r = agent(p, #{
        label: role_name,
        capability_mode: cap_mode,
        output_schema: step_schema,
    });
    if r == () || !r.success || r.output == () {
        return #{ skipped: false, role: role_name, status: "failed", summary: "agent failed", hand_off: "project-manager" };
    }
    return #{
        skipped: false,
        role: role_name,
        status: r.output.status,
        summary: r.output.summary,
        hand_off: r.output.hand_off,
    };
}

let results = [];
results.push(run_role("story-writer", on_story, "Write only player-facing text/hooks/docs for this bite.", "read-write"));
results.push(run_role("programming", on_code, "Implement code+tests. Run bash tools/run-tests.sh when you change code.", "all"));
results.push(run_role("level-design", on_level, "Edit zones/placement/collision/transitions only as needed.", "read-write"));
results.push(run_role("combat-designer", on_combat, "Combat/mercy gates and fair verbs only.", "all"));
results.push(run_role("companion-designer", on_companion, "Briar/Echo authored beat only; no procedural parties.", "read-write"));
results.push(run_role("creative-art", on_art, "Still art only; log prompts; engine-ready sizes.", "read-write"));
results.push(run_role("animation", on_animation, "Motion/SpriteFrames only; match anim names code expects.", "read-write"));
results.push(run_role("audio", on_audio, "SFX keys and event wiring only; no API keys in repo.", "read-write"));
results.push(run_role("dread-director", on_dread, "One dread beat staging; leave feel dials for human.", "read-write"));

// ========== VERIFY ==========
phase("Verify");

let qa_out = #{ status: "skipped", evidence: "qa lane off", blockers: [] };
if on_qa {
    log("playtest-qa");
    let qp = "";
    qp += role_preface;
    qp += "ROLE: playtest-qa. Read .claude/skills/playtest-qa/SKILL.md and docs/design/agentic-playtest-smoke.md. ";
    qp += "Run bash tools/playtest_smoke.sh and/or bash tools/run-tests.sh as appropriate. ";
    qp += "Do NOT run shell smoke concurrent with an active MCP run_project. ";
    qp += "Evidence only — never claim dread/bond/fun. status=pass|fail|blocked.";
    let qr = agent(qp, #{
        label: "playtest-qa",
        capability_mode: "all",
        output_schema: verify_schema,
    });
    if qr != () && qr.success && qr.output != () {
        qa_out = qr.output;
    } else {
        qa_out = #{ status: "failed", evidence: "qa agent failed", blockers: ["qa agent failure"] };
    }
}

let review_out = #{ status: "skipped", evidence: "review lane off", blockers: [] };
if on_review {
    log("reviewer");
    let rp = "";
    rp += role_preface;
    rp += "ROLE: reviewer. Read .claude/skills/reviewer/SKILL.md. ";
    rp += "Review the git diff for this bite (git diff / git status / read files). Risk-first: Web export, patent, flute-gate, R1, tests. ";
    rp += "status=approve|approve_with|block. evidence=summary of findings. blockers=list.";
    let rr = agent(rp, #{
        label: "reviewer",
        capability_mode: "read-only",
        output_schema: verify_schema,
    });
    if rr != () && rr.success && rr.output != () {
        review_out = rr.output;
    } else {
        review_out = #{ status: "failed", evidence: "review agent failed", blockers: ["review agent failure"] };
    }
}

// ========== FEEL ==========
phase("Feel");
await_user("user", "Human F5 gate: play the bite in Godot. Check dread/bond/readability yourself. Resume when finished (or accept residual risk). Agents cannot sign off feel.");

let report = #{
    summary: "Content Studio run finished",
    mission: mission,
    mode: mode,
    plan: plan,
    build: results,
    qa: qa_out,
    review: review_out,
    human_feel: "awaited — human resumed after F5 gate",
    ok: true,
};

let report_path = write_scratch_file("content_studio_report.json", json_encode(report));
log("Content Studio complete");
complete(#{ summary: "Content Studio complete for: " + mission, path: report_path, report: report, ok: true });
