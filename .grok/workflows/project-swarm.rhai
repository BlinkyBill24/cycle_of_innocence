let meta = #{
    name: "project-swarm",
    description: "PM picks the next CoI bite from STATE/ideas, human approves, then Content Studio sequential roles run",
    when_to_use: "Full swarm option C when you do not already know the next mission",
    phases: [
        #{ title: "Propose", detail: "PM reads backlog and proposes one mission" },
        #{ title: "Approve", detail: "human accepts or redirects" },
        #{ title: "Plan", detail: "detailed plan for the mission" },
        #{ title: "Build", detail: "role agents sequential" },
        #{ title: "Verify", detail: "qa + review" },
        #{ title: "Feel", detail: "human F5" },
    ],
};

let proposal_schema = #{
    "type": "object",
    "required": ["mission", "why_now", "lanes", "branch_slug", "risks"],
    "properties": #{
        "mission": #{ "type": "string" },
        "why_now": #{ "type": "string" },
        "branch_slug": #{ "type": "string" },
        "lanes": #{
            "type": "object",
            "required": ["story", "code", "level", "art", "animation", "audio", "dread", "companion", "combat", "qa", "review"],
            "properties": #{
                "story": #{ "type": "boolean" },
                "code": #{ "type": "boolean" },
                "level": #{ "type": "boolean" },
                "art": #{ "type": "boolean" },
                "animation": #{ "type": "boolean" },
                "audio": #{ "type": "boolean" },
                "dread": #{ "type": "boolean" },
                "companion": #{ "type": "boolean" },
                "combat": #{ "type": "boolean" },
                "qa": #{ "type": "boolean" },
                "review": #{ "type": "boolean" },
            },
        },
        "risks": #{ "type": "array", "items": #{ "type": "string" }, "maxItems": 8 },
    },
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

let hint = "";
if args != () && args.hint != () { hint = args.hint; }

let law = "";
law += "You work on Cycle of Innocence (Godot 4.4 GDScript). Obey AGENTS.md and docs/agents/shared-contract.md and docs/agents/swarm.md. ";
law += "R1 never commit main. Vertical slice first. Two companions Briar+Echo only; Storm cut; flute-gates mercy; no patent nemesis systems; no C#; no runtime LLM in game. ";

// ========== PROPOSE ==========
phase("Propose");
log("PM proposing next bite");

let prop_p = "";
prop_p += law;
prop_p += "ROLE: project-manager. Read STATE.md, AGENTS.md (slice + rules), docs/ideas.md, docs/agents/README.md using read_file/grep. ";
prop_p += "Propose exactly ONE next content bite that is F5-able and small. Prefer unfinished slice items and marked code tasks in ideas.md. ";
if hint != "" {
    prop_p += "Human hint (honor if sane): ";
    prop_p += json_encode(hint);
    prop_p += " ";
}
prop_p += "Set lanes booleans: enable only what the bite needs (usually code+qa+review; not every lane). why_now must be plain language. Do not implement.";

let prop = agent(prop_p, #{
    label: "pm-propose",
    capability_mode: "read-only",
    output_schema: proposal_schema,
});

if prop == () || !prop.success || prop.output == () {
    complete(#{ summary: "Proposal failed", ok: false });
}

let proposal = prop.output;
log("Proposed: " + proposal.mission);

phase("Approve");
await_user("user", "Approve the proposed mission and lanes (see run output). Resume to build that bite, or stop the workflow and re-run with args.hint if you want a different topic.");

let mission = proposal.mission;
let lanes = proposal.lanes;
let on_story = lanes.story == true;
let on_code = lanes.code == true;
let on_level = lanes.level == true;
let on_art = lanes.art == true;
let on_animation = lanes.animation == true;
let on_audio = lanes.audio == true;
let on_dread = lanes.dread == true;
let on_companion = lanes.companion == true;
let on_combat = lanes.combat == true;
let on_qa = lanes.qa == true;
let on_review = lanes.review == true;

let mission_q = json_encode(mission);

// ========== PLAN ==========
phase("Plan");
let pm_prompt = "";
pm_prompt += law;
pm_prompt += "Mission: ";
pm_prompt += mission_q;
pm_prompt += " ROLE: project-manager. Read STATE.md and relevant docs/decisions. Produce a detailed plan with steps[].role from the known role list. branch_slug like ";
pm_prompt += json_encode(proposal.branch_slug);
pm_prompt += ". Only steps needed. Do not implement.";

let pm = agent(pm_prompt, #{
    label: "pm-plan",
    capability_mode: "read-only",
    output_schema: plan_schema,
});

if pm == () || !pm.success || pm.output == () {
    complete(#{ summary: "Plan failed after proposal", proposal: proposal, ok: false });
}

let plan = pm.output;
let plan_json = json_encode(plan);

// ========== BUILD ==========
phase("Build");

let role_preface = "";
role_preface += law;
role_preface += "Mission: ";
role_preface += mission_q;
role_preface += " Plan: ";
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
    p += ". Read .claude/skills/";
    p += role_name;
    p += "/SKILL.md and obey it. ";
    p += skill_hint;
    p += " Only your lane. status=done|blocked|skipped. Use tools. Vertical slice only.";
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
results.push(run_role("story-writer", on_story, "Story/dialogue/hooks only.", "read-write"));
results.push(run_role("programming", on_code, "Code+tests; run tools/run-tests.sh when appropriate.", "all"));
results.push(run_role("level-design", on_level, "Zones and placement only.", "read-write"));
results.push(run_role("combat-designer", on_combat, "Combat/mercy gates only.", "all"));
results.push(run_role("companion-designer", on_companion, "Briar/Echo beat only.", "read-write"));
results.push(run_role("creative-art", on_art, "Still art only.", "read-write"));
results.push(run_role("animation", on_animation, "Animation/SpriteFrames only.", "read-write"));
results.push(run_role("audio", on_audio, "Audio keys only.", "read-write"));
results.push(run_role("dread-director", on_dread, "One dread beat only.", "read-write"));

// ========== VERIFY ==========
phase("Verify");

let qa_out = #{ status: "skipped", evidence: "qa lane off", blockers: [] };
if on_qa {
    let qp = "";
    qp += role_preface;
    qp += "ROLE: playtest-qa. Read skill + agentic-playtest-smoke doc. Run smoke/tests. Evidence only.";
    let qr = agent(qp, #{ label: "playtest-qa", capability_mode: "all", output_schema: verify_schema });
    if qr != () && qr.success && qr.output != () { qa_out = qr.output; }
    else { qa_out = #{ status: "failed", evidence: "qa failed", blockers: ["qa failure"] }; }
}

let review_out = #{ status: "skipped", evidence: "review lane off", blockers: [] };
if on_review {
    let rp = "";
    rp += role_preface;
    rp += "ROLE: reviewer. Risk-first diff review. status approve|approve_with|block.";
    let rr = agent(rp, #{ label: "reviewer", capability_mode: "read-only", output_schema: verify_schema });
    if rr != () && rr.success && rr.output != () { review_out = rr.output; }
    else { review_out = #{ status: "failed", evidence: "review failed", blockers: ["review failure"] }; }
}

phase("Feel");
await_user("user", "Human F5 gate: play the bite yourself. Resume when done.");

let report = #{
    summary: "Project swarm finished",
    proposal: proposal,
    plan: plan,
    build: results,
    qa: qa_out,
    review: review_out,
    ok: true,
};
let path = write_scratch_file("project_swarm_report.json", json_encode(report));
complete(#{ summary: "Swarm complete: " + mission, path: path, report: report, ok: true });
