# Handoff: V1 Module Generation Complete

**Date:** 2026-04-12
**Session:** Multi-model module generation and comparison
**Status:** V1 draft modules in place across all 8 stages. Cherry-pick refinements and runtime validation remain.

---

## What Was Done

Generated complete V1 teaching modules for all 8 stages of goose-wizard using two models in parallel:
- **Claude Opus 4.6** — via Agent subagents (6 parallel agents for Stages 2-7)
- **Codex / GPT 5.4** — via codex_review.py (7 parallel calls for Stages 1-7)

Both models received the same inputs: the module-designer skill, syllabus, example module, and recipe/eval/progression format references. Each generated complete working recipes (Goose YAML) and teaching scripts (.teach.md) with embedded eval prompts and coaching language.

### Generation Results

| Model | Files Generated | Stages Complete | Duration |
|-------|----------------|-----------------|----------|
| Opus | 48 (26 recipes + 28 teaching) | All 8 | ~2.5-9.6 min per stage |
| Codex | 42 (20 recipes + 22 teaching) | 7 of 8 (Stage 5 timed out) | ~84s-557s per stage |

### Evaluation Process

Two independent comparisons were run:
1. **Opus evaluation** (Claude Opus agent) → `ideas/module-comparison-v1.md`
2. **Codex evaluation** (GPT 5.4 agent) → `ideas/module-comparison-v1-codex-eval.md`

The Opus evaluation was somewhat biased toward Opus (scored it Opus 4, Codex 1, Tie 3). The Codex evaluation gave a fairer split (Codex 3, Opus 3, Tie 1 excluding Stage 5). Both agreed on a hybrid approach.

---

## What's In Place Now

The final combined module set lives in `recipes/stage-N/` and `teaching/stage-N/`. Source per stage:

| Stage | Recipe Source | Teaching Source | Why |
|-------|-------------|----------------|-----|
| 0 | **Codex** | **Opus** | Codex has better operational safety (unique branch fallback, no-reset rules, approval before deletion). Opus has richer teaching scripts with fuller bridges and private bug prompts. |
| 1 | **Opus** | **Opus** | Richer coaching examples, better stuck paths, more specific weak-rating language. |
| 2 | **Opus** | **Opus** | More complete eval dimensions including conditional "spec as contract." |
| 3 | **Codex** | **Codex** | Clearly stronger: explicit JSON handoff contracts, scoped-context eval dimension, role/contract/safety parameters in recipe. |
| 4 | **Opus** | **Opus** | Versions were effectively identical (possible cross-contamination). |
| 5 | **Opus** | **Opus** | Only version — Codex timed out. |
| 6 | **Opus** | **Opus** | Concrete facilitator language ("Here is the part I would not let pass as green") beats Codex's meta-instructions. |
| 7 | **Codex** | **Codex** | Better metrics baseline handling, side-effect awareness, no-fake-comparison safeguards. |

### File Count: 48 files total
- 26 working recipe YAMLs
- 22 teaching scripts (.teach.md) — includes 5 Stage 0 act scripts + 17 adaptive teaching wrappers

---

## Known Issues

### Cross-Contamination
Both Opus and Codex agents wrote to the same root `recipes/` and `teaching/` directories during generation. For Stages 4, 6, and parts of 2, the files are byte-identical between versions — meaning the "comparison" for those stages has limited value. The similarity is likely a mix of the highly prescriptive shared blueprint (syllabus + module-designer skill) and possible filesystem influence.

### Stage 5 Codex Gap
Codex timed out on Stage 5 (the most complex stage — 12 files). If a Codex-generated alternative is wanted, it should be regenerated separately with a longer timeout or the stage split into smaller batches.

### Not Runtime Validated
No file has been tested against the actual Goose recipe runner. YAML syntax, parameter templating, sub-recipe invocation, and extension declarations are structurally plausible but unverified.

### Progression State Management
Both versions describe writing to `.goose/state/progression.json` but neither provides schema migration, concurrency handling, or corruption recovery.

### Empty Subdirectories
`recipes/stage-0/acts/` and `recipes/stage-0/state/` are empty directories created by an agent during generation. They should be deleted manually.

### Parallel Directories to Clean Up
`modules-v1-opus/` and `modules-v1-codex/` still exist and should be manually deleted — they were the intermediate generation directories. The final files are all in the root `recipes/` and `teaching/` directories now.

---

## Cherry-Pick Refinements for V2

These are specific improvements from each version that should be patched into the final set. Each is a focused edit, not a rewrite.

### From Codex → Patch into Opus-based stages

1. **Stage 1 test-writer: Proactive assertion-quality prompt.** Codex's test-writer teaching prompts the developer to inspect assertion quality immediately ("Would these tests catch a real bug?") rather than waiting for eval. Add this to the framing or task section of `teaching/stage-1/test-writer.teach.md`.

2. **Stage 1 recipes: Residual-risk return fields.** Codex's `code-review.yaml` returns residual risks and impact classifications. Add these to the Opus recipe's return section.

3. **Stage 2 spec-first: Spec-ownership eval dimension.** Codex evaluates whether the developer actively owned the acceptance criteria vs. letting AI define success. Add this as a 5th dimension to `teaching/stage-2/spec-first.teach.md`.

4. **Stage 2 review-gate: Gate-decision-discipline framing.** Codex's review-gate eval distinguishes "gate blocks on evidence" from "gate passes on tone." Sharpen the Opus review-gate eval prompt with this framing.

### From Opus → Patch into Codex-based stages

5. **Stage 3: Richer coaching examples.** Codex's teaching scripts are operationally stronger but sometimes thin on coaching language. Add Opus's vivid contrast examples (especially the "pipeline vs. one agent with helpers" comparison) to `teaching/stage-3/three-agent-pipeline.teach.md`.

6. **Stage 7 pipeline-self-edit: Audit-only mode.** Codex's pipeline-self-edit recipe moves from audit to safe consolidation edits. Add an audit-only mode flag (default: true during teaching) so learners see the audit pattern before any auto-editing happens.

---

## Next Steps (Priority Order)

### 1. Resolve the 4 gaps from HANDOFF_stage1_detail.md
The original handoff identified 4 gaps that needed re-evaluation against the adaptive model:
- Delegate convention
- Dynamic content handling
- Pitfall strategy
- `teacher-instructions.md`

These are now partially addressed by the teaching scripts but `teaching/meta/teacher-instructions.md` still needs to be written. It should incorporate the adaptive teaching framework and draw from the patterns established in the V1 teaching scripts.

### 2. Apply the 6 cherry-pick refinements listed above
Each is a focused edit — add a dimension, add a return field, add a prompt. Estimate: ~30 minutes total.

### 3. Write teacher-instructions.md
This is the master reference for how the facilitator agent behaves. It should codify:
- The 4 teaching modes and when each applies
- How to read and use eval results
- Coaching voice rules (colleague, not instructor; never break fourth wall)
- Stuck path handling patterns
- Bridge patterns between modules
- State management conventions

Draw from the patterns now visible across all 48 files.

### 4. Runtime validation against Goose
Test at least one recipe per stage against the actual Goose runtime:
- Does the YAML parse correctly?
- Do parameters render?
- Does sub-recipe invocation work?
- Do extensions load?
- Does structured output return properly?

Start with Stage 1 `bug-fix.yaml` (simplest, most complete example).

### 5. Progression state hardening
Add schema validation, concurrent-write handling, and corruption recovery to the progression state system. Currently it's convention-based with no enforcement.

### 6. V2 quality pass
After cherry-picks and runtime validation, re-score all modules against the 10-criterion scorecard. Target: all stages >=80/100.

---

## Key Files

| File | What It Is |
|------|-----------|
| `ideas/syllabus.md` | Source of truth for concepts, quality dimensions, design decisions |
| `ideas/module-comparison-v1.md` | Opus-authored comparison (somewhat biased toward Opus) |
| `ideas/module-comparison-v1-codex-eval.md` | GPT-authored comparison (fairer stage-level assessment) |
| `teaching/meta/module-designer/SKILL.md` | Module design skill with quality scorecard |
| `teaching/meta/module-designer/references/example-module.md` | Bug Fix reference implementation |
| `recipes/stage-N/*.yaml` | Final working recipes (N = 0-7) |
| `teaching/stage-N/*.teach.md` | Final teaching scripts (N = 0-7) |

## Infrastructure Note

The `codex_review.py` script in `~/ClaudeProjects/AgenticSystem/` was modified during this session to handle Windows command-line length limits. Long prompts are now written to a temp file and Codex is instructed to read that file. The temp file is cleaned up after the run. This fix is necessary for any future Codex calls with large prompts.
