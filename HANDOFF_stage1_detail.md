# Handoff: Flesh Out Stage 1 Detail

> **UPDATE (2026-04-12):** This handoff was written before the syllabus redesign. The project is now 8 stages (0-7), uses an adaptive teaching model (not scripted), and Stage 1 has quality-rated dimensions instead of binary signals. **Read `ideas/syllabus.md` FIRST** — it is the source of truth. The 4 gaps below are still valid but need reinterpretation against the new adaptive model. Specifically:
> - **Gap 1 (delegate convention):** Still needed — the code-work subagent convention must be documented
> - **Gap 2 (dynamic content):** Largely solved by the adaptive model — the facilitator coaches on real results, not scripted content
> - **Gap 3 (pitfall teaching):** Partially solved — pitfalls surface naturally during real work, but fallback strategy still needed for when they don't
> - **Gap 4 (teacher-instructions.md):** Still needed — must now describe the facilitator/eval/code-work architecture, quality rating model, and teaching modes

## What You're Doing
Continue planning the RIL Agentic Harness — specifically, flesh out the missing pieces of Stage 1. The full plan lives at `ideas/plan.md` — read it first (it's ~1400 lines, read the whole thing). Also read `REFERENCES.md` for quick-access technical details.

## Project Context
We're building an agentic development harness for Reliance teams by forking Goose (https://github.com/aaif-goose/goose). The harness teaches teams agentic development progressively through 6 stages (0-5) using "recipes" (Goose's YAML workflow format). We combine Goose's runtime with our pipeline's design patterns and CourseForge's teaching model.

## Key Decisions Already Made
1. **Fork Goose**, extend at recipe layer, don't touch Rust core
2. **ACP for subscriptions** — Claude Max via claude-acp, no API keys
3. **Provider-agnostic** — recipes specify capability tiers (reasoning/fast/quick), not models
4. **LLM-based orchestration first** — use Goose's native subagents, add code-based orchestration only if needed
5. **Hooks deferred** — Goose has ToolInspector trait, adding deterministic hooks is ~200 lines when needed
6. **Everyone starts at Stage 0** — no maturity assessment, skip commands available
7. **Onboarding per project** — config lives in `{project}/.goose/`, shared via git
8. **Teacher never disappears** — grows up with the user (basics → peer-level). Teaching mode forced on first run of every recipe, `/teach` to revisit
9. **Teacher/Hands pattern** — main agent teaches (never touches code), subagents do all code work and report back
10. **Dual-mode recipes** — working recipe YAML + separate teaching script (.teach.md), wrapped by teach-wrapper.yaml meta-recipe

## What Stage 1 Has Now
Read the "Stage 1 Design" section in the plan. It has:
- 4 recipes: code-review, test-writer, bug-fix, refactor (lowest → highest risk)
- Teaching concepts, pitfalls, and nuance for each recipe
- Teaching flow outlines (bullet points, not full scripts)
- Readiness criteria for Stage 2

## Known Gaps to Resolve FIRST (Before Writing Scripts)

Two independent evaluators reviewed this project cold. These are the gaps they found that must be resolved before writing Stage 1 scripts. Handle these in order.

### Gap 1 (HIGH): Formalize the delegate() convention
The Stage 0 act scripts use a pseudocode format for subagent delegation:
```
Action: delegate to subagent:
  "Instructions here...
  
  Return:
  - field_name: description
  - field_name: description"
```
This is NOT actual Goose API syntax — it's a convention that the teach-wrapper's LLM interprets. **This needs to be explicitly stated as the convention.** Write it into `teaching/meta/teacher-instructions.md` so all future script authors know: "Use this pseudocode format. The teach-wrapper LLM will interpret it as a delegate() tool call."

Also decide and document:
- Should delegate calls include `extensions: ["developer"]` or is that implicit?
- Should return formats be flat (like Stage 0) or can they be nested (e.g., list of findings)?
- When the teacher needs to run a git command, does it delegate that too, or can it do it directly?

### Gap 2 (HIGH): Handle dynamic content in teaching scripts
Stage 0 could be fully scripted because the teacher controlled everything (chose the file, planted the bug). Stage 1 works on REAL code — the teacher can't predict what the subagent will find during a code review or what bugs exist.

Design a convention for how teaching scripts handle dynamic results:
- The `Say:` blocks can't be 100% verbatim when the content depends on what the subagent found
- Proposed pattern: Use `Say (dynamic):` blocks where the teacher gets guidance on WHAT to communicate but not exact wording, vs `Say:` blocks for exact wording on teaching points
- The teacher needs to editorialize on subagent results (e.g., "this finding is important because..." or "this one is noise, here's why...")
- Document this convention in `teaching/meta/teacher-instructions.md`

### Gap 3 (MEDIUM): Pitfall teaching on uncontrolled code
Stage 0 taught "AI makes mistakes" by having the subagent intentionally plant a bug (Act 4). Stage 1 can't plant bugs — it works on real commits. But each recipe has a specific pitfall to teach:
- Code review: "AI praises clean code even if it has bugs"
- Test writer: "AI writes tests that pass but test nothing"
- Bug fix: "AI suppresses errors instead of fixing root cause"
- Refactor: "AI subtly changes behavior during cleanup"

Design a fallback strategy for each recipe. Options:
- **If the AI demonstrates the pitfall naturally during the demo:** Teacher points it out live
- **If the AI doesn't make the mistake:** Teacher explains it abstractly with a hypothetical example
- **Hybrid:** Teacher always shows the pitfall example (maybe via a delegate call that asks the subagent to show a "what would go wrong" scenario), then checks if the real demo had the same issue

Pick one approach and document it. This is a design decision, not an implementation detail.

### Gap 4 (MEDIUM): Create teacher-instructions.md
This file is referenced in the project structure but doesn't exist. It should contain:
- The delegate() pseudocode convention (from Gap 1)
- The dynamic content convention (from Gap 2)
- The pitfall teaching strategy (from Gap 3)
- Teacher behavior rules extracted from the plan:
  - Never break the fourth wall
  - Speak as instructor, not as AI following a script
  - Check points are gates — STOP and WAIT
  - Stage 0: say "helper" not "subagent"
  - Stage 1+: decide vocabulary progression
  - When delegating, briefly tell the user what's happening
  - Subagent returns are PRIVATE (teacher decides what to share)
- Level adaptation table (from plan — how teacher behavior changes per stage)

Create this file at `teaching/meta/teacher-instructions.md` BEFORE writing any Stage 1 scripts.

---

## After Resolving Gaps, Write These Deliverables

### 1. Full Teaching Scripts (Say/Check/Action)
Stage 0 has complete scripts with exact wording for each act (in `ideas/plan.md` under "Act Scripts"). Stage 1 only has bullet-point outlines. Write full `.teach.md` scripts for all 4 recipes following the format established by Stage 0 + the conventions you documented in teacher-instructions.md.

Each script should:
- Use Say/Check/Action format
- Use delegate pseudocode for all code work
- Include the specific pitfall/nuance from the plan
- Take ~20-30 minutes
- End with a bridge to the next recipe (or to Stage 2 for recipe 1.4)

### 2. Working Recipe YAMLs
Design the actual Goose recipe YAML for each Stage 1 recipe. These are the "working mode" versions (no teaching). They should:
- Read `.goose/team_context.md` for stack info
- Use parameters where appropriate (e.g., PR number, file path, function name)
- Specify extensions needed (at minimum `developer`)
- Use tier references, not model names (per Principle 9)
- Include clear instructions for the agent
- Be clean and reusable — no teaching content mixed in

### 3. Architecture Clarification
Stage 0 uses teacher/hands exclusively. For Stage 1:
- Teaching mode: teacher/hands (teacher talks, subagents do code work)
- Working mode: direct agent interaction (no teacher wrapper)
- The teach-wrapper.yaml handles the switch automatically

## Architecture Reference

### How Teaching Mode Works
```
User runs: goose run code-review
System checks progression → never taught → runs teach-wrapper automatically

teach-wrapper.yaml:
  1. load("teaching/stage-1/code-review.teach.md")
  2. Teacher follows the script
  3. Subagents do code work when script says "Action: delegate"
  4. After completion, marks recipe as taught in progression file
```

### How Working Mode Works
```
User runs: goose run code-review (after teaching completed)
→ runs recipes/stage-1/code-review.yaml directly
→ single agent, does the job, returns results
```

### File Structure
```
recipes/stage-1/
├── code-review.yaml          # Working recipe
├── test-writer.yaml
├── bug-fix.yaml
└── refactor.yaml
teaching/stage-1/
├── code-review.teach.md      # Full Say/Check/Action teaching script
├── test-writer.teach.md
├── bug-fix.teach.md
└── refactor.teach.md
```

## Design Constraints
- Teaching scripts use the teacher/hands pattern (teacher talks, subagents do code work)
- Subagents are explained to users as "helpers" (plain language, introduced in Stage 0)
- Permission mode: smart approval (reads auto-approved, writes shown to user)
- All work on real feature branches, real code (not practice branches like Stage 0)
- Each teaching script should take ~20-30 minutes
- Each teaching script must include the specific pitfall and nuance listed in the plan
- Bridge at the end of Recipe 1.4 sets up Stage 2: "What if another AI checked the first one's work?"
- Working recipes should be clean and reusable — no teaching content mixed in

## Reference Files
- Full plan: `ideas/plan.md`
- Technical references: `REFERENCES.md` (pipeline patterns, Goose mechanics, CourseForge format)
- Stage 0 act scripts (for format reference): in `ideas/plan.md` under "Act Scripts (Say/Check/Action Detail)" — these are COMPLETE scripts that have NOT yet been extracted to individual act files. Use them as the format template for Stage 1 scripts.
- Project CLAUDE.md: project context, principles, decisions, structure
