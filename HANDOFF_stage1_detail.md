# Handoff: Flesh Out Stage 1 Detail

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

## What Stage 1 Is Missing (Your Job)

### 1. Full Teaching Scripts (Say/Check/Action)
Stage 0 has complete scripts with exact wording for each act. Stage 1 only has bullet-point outlines. Write full `.teach.md` scripts for all 4 recipes following the CourseForge format:
- Say: (exact words for the teacher)
- Check: (what the user must do before continuing)
- Action: delegate to subagent with exact instructions and return format

Use Stage 0's act scripts as the template for format and level of detail.

### 2. Working Recipe YAMLs
Design the actual Goose recipe YAML for each Stage 1 recipe. These are the "working mode" versions (no teaching). They should:
- Read `.goose/team_context.md` for stack info
- Use parameters where appropriate (e.g., PR number, file path, function name)
- Specify extensions needed
- Include clear instructions for the agent

### 3. Architecture Clarification
Stage 0 uses teacher/hands exclusively. For Stage 1 teaching mode:
- Teaching mode should still use teacher/hands (teacher talks, subagents do code work)
- Working mode is direct agent interaction (no teacher wrapper)
- The teach-wrapper.yaml handles the switch

### 4. Subagent Delegation Detail
Each teaching script needs specific subagent delegation instructions — what the subagent is told, what it returns, how the teacher uses the response. Stage 0 has this. Stage 1 doesn't yet.

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
