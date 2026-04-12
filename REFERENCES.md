# Reference Sources — Read These When Needed

This project draws from three systems. This file tells you exactly where to find what.

---

## 1. Our Pipeline (AgenticSystem)

**Location:** `~/ClaudeProjects/AgenticSystem/`

### Key files to read for pipeline patterns
| Pattern | Where to Find It |
|---------|------------------|
| Agent roles & file ownership matrix | `templates/n8n_workflow/CLAUDE.md` |
| Skill files (per-agent knowledge) | `templates/n8n_workflow/pipeline/skills/*.md` |
| Inner loop orchestration | `templates/n8n_workflow/autonomous_dev.py` |
| Outer loop (cycles + review) | `continuous_dev.py` |
| Cycle review checklist (14 steps) | `cycle_review_prompt.md` |
| Pipeline learnings (hard-won insights) | `learnings.md` |
| Project config (model tiers, circuit breakers) | `templates/n8n_workflow/project_config.json` |
| 16-agent evaluation findings | `Evaluations/*.md` |
| Bootstrap/scaffolding | `bootstrap.py` |

### Key learnings to inform recipe design
- **Evaluators rubber-stamp clean cycles** — vague checklists produce vague reviews. Specific verification steps produce findings. (learnings.md)
- **False positives worse than failures** — 32 tests "passed" but were never executed. Pipeline reported success when product was broken. (learnings.md)
- **Self-verification bias** — agents that write should never verify their own work. This is the #1 pattern to teach. (CLAUDE.md)
- **ACE pattern missing Curator** — system observes problems but doesn't close the loop. Generator → Reflector → Curator needed. (Evaluations/)
- **65% of supervisor reviews find nothing** — reviews that check artifacts (code exists?) instead of outcomes (does it work?) are useless. (Evaluations/)
- **Queued items never picked up** — "queued for planner" is write-only. 11+ items stuck. (Evaluations/)
- **Rules accumulate, nobody prunes** — 15 rules, some duplicated in 3 files. Competing rules reduce accuracy by 37.5%. (Evaluations/)

### Pipeline architecture (for Stages 3-5 recipes)
```
Inner Loop (10 sessions):
  LOG SCAN → LOG AGENT → CRITICAL BUG CHECK → BUILD → TEST → FIX → SUPERVISORS

Outer Loop (continuous):
  Inner Loop → Cycle Review → Verify Reviewer Changes → Check Stop → Next Cycle
```

Agents: Spec Analyzer, Node Builder, Validate-Fix, Deploy+Test, Cycle Reviewer
Each agent loads ONE skill file. File ownership matrix prevents agents stepping on each other.
Circuit breaker: 3 consecutive failures → escalation file → route to specialist or human.

---

## 2. Goose Framework

**Repo:** https://github.com/aaif-goose/goose
**Docs:** https://goose-docs.ai/

### How recipes work (YAML format)
```yaml
version: 1.0.0
title: "Recipe Name"
description: "What it does"

parameters:
  - key: param_name
    input_type: text
    requirement: required
    description: "What this param is"

instructions: |
  Instructions for the agent...

extensions:
  - type: builtin
    name: developer

prompt: |
  Starting prompt with {{ param_name }} template vars
```

### How subagents work
Two systems:
- **`delegate()`** — spawns a subagent, runs a task, returns result. Supports `async: true` for background.
- **`load()`** — injects knowledge/file content into current agent's context (NOT a subagent).

Key constraints:
- Subagents cannot spawn subagents (hard blocked)
- Subagents forced to Auto permission mode
- Up to 5 concurrent (configurable via GOOSE_MAX_BACKGROUND_TASKS)
- Extension scoping: `extensions: ["developer"]` limits subagent tools
- Results return as tool call results (text or structured JSON)

### How ACP works
```bash
# Install
npm install -g @zed-industries/claude-agent-acp
npm install -g @zed-industries/codex-acp

# Configure
export GOOSE_PROVIDER=claude-acp
export GOOSE_MODEL=default  # opus, sonnet, haiku
```
Spawns CLI tools as subprocesses, uses subscription auth (not API keys).

### How sub-recipes work
```yaml
sub_recipes:
  - name: "task_name"
    path: "./subrecipes/task.yaml"
    description: "What it does"
    values:
      param: "value"
```
Parent invokes via: `subagent(subrecipe: "task_name", parameters: {...})`

### Hooks gap (for future reference)
- No deterministic hooks like Claude Code's PreToolUse/PostToolUse
- `ToolInspector` trait exists — 5 inspectors in chain already
- Adding `ScriptHookInspector`: ~200 lines new Rust, 3-5 lines changed
- File: `crates/goose/src/agents/agent.rs`, method: `create_tool_inspection_manager()` (line 258)

---

## 3. CourseForge Teaching Model

**Location:** `~/ClaudeProjects/CourseForge/`

### Say/Check/Action format
```markdown
### Step N: [Title] (X minutes)

Say:
"[Exact words for the teacher to say to the student]"

Check: [Gate — student must do X before continuing. STOP and WAIT.]

Action: [Tool call or file operation — exact details]

Say:
"[What to say after the action completes]"
```

### Key rules (from SCRIPT_INSTRUCTIONS.md)
- Follow scripts verbatim — Say blocks are exact wording
- Never break the fourth wall ("I've read the script")
- Speak as instructor, not as AI following a script
- Check points are gates — STOP and WAIT for student response
- Every module wrap-up must preview the next module
- Support both visual and terminal environments

### Exercise quality scorecard (10 criteria, all must score ≥6, total ≥70)
1. Few turns (1-3 major interactions)
2. Clear input → output
3. Obviously verifiable success
4. One skill per exercise
5. Watch then do
6. Minimal domain knowledge required
7. The "aha" is the tool, not the content
8. Synthetic data does the heavy lifting
9. Instantly relatable scenario
10. Mirrors original structure

### Key files to read
| File | Purpose |
|------|---------|
| `template/.claude/SCRIPT_INSTRUCTIONS.md` | Meta-rules for how Claude teaches |
| `forge/instruction-docs/exercise-quality-scorecard.md` | Full 10-criterion rubric |
| `.claude/FORGE_INSTRUCTIONS.md` | Pipeline orchestration protocol |
| `forge/playbook.md` | Lessons learned from running the system |
