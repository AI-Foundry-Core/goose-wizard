# Handoff: V2 Audit Fixes Complete + Goose Installed

**Date:** 2026-04-12
**Session:** Multi-model generation, evaluation, consolidation, audit, and fix pipeline
**Status:** All V1 content generated, evaluated, merged, audited, and fixed. Goose CLI installed. Runtime validation is the next step.

---

## What Was Done This Session

### Phase 1: V1 Module Completion
Generated the 4 missing pieces using parallel Claude + Codex agents (8 agents total):
- **6 cherry-pick refinements** across existing files (assertion-quality prompt, residual-risk fields, spec-ownership dimension, gate-decision framing, vivid coaching contrasts, audit-only mode)
- **`teaching/meta/teacher-instructions.md`** — master facilitator behavior reference (12 sections, ~530 lines)
- **`teaching/stage-3/escalation-routing.teach.md`** — Stage 3 safety rails teaching script
- **`teaching/stage-4/spec-to-pipeline.teach.md`** — Stage 4 capstone teaching script

### Phase 2: Evaluation
2 independent evaluators (Claude + Codex) compared all 9 pairs. Results in `ideas/v1-cherry-pick-eval_claude.md` and `ideas/v1-cherry-pick-eval_codex.md`. Winners merged into `consolidated/` then promoted to root.

### Phase 3: Audit
4 audit agents (2 Claude + 2 Codex) checked plan adherence, runtime readiness, consistency, and voice compliance. Found 7 blockers + 7 medium issues. Audit reports in:
- `ideas/audit-consistency-voice.md`
- `ideas/audit-plan-adherence.md`
- `ideas/audit-runtime-readiness.md`

### Phase 4: Fixes
4 Claude fix agents applied all corrections in parallel:

1. **Recipe YAML fixes** — `input_type: text` → `string` across 25 recipes, added `default:` to all optional params, added RIL agent references to Stage 4/6 recipes
2. **teach-wrapper.yaml** — the runtime glue that wires facilitator + code-work subagent + eval subagent
3. **`.goose/` bootstrap** — template `team_context.md` + initial `progression.json`
4. **Teaching script bugs** — 6 fixes: removed `"concept"` field from spec-first eval, added Strong-overwrite protection to 4 scripts, added Stage 0 completion state update, fixed continuous-dev bridge stage references

### Phase 5: Verification
2 verification agents (Claude + Codex) independently checked all fixes. Results in:
- `ideas/verification-claude.md`
- `ideas/verification-codex.md`

One residual found by Codex (spec-first Strong-overwrite) was fixed immediately.

### Phase 6: Goose Installation + Configuration
- Goose CLI v1.30.0 installed at `<HOME>\.local\bin\goose.exe`
- ACP adapter `@agentclientprotocol/claude-agent-acp@0.26.0` installed globally via npm
- Provider configured: `GOOSE_PROVIDER: claude-acp`, `GOOSE_MODEL: default` in config.yaml
- `goose doctor` passed — Git, Node, Python, npm all detected, Claude ACP connected
- All 26 recipes + teach-wrapper pass `goose recipe validate`

---

## Current File Inventory

### Working Recipes (25 files)
```
recipes/stage-0/stage-0-welcome.yaml
recipes/stage-1/bug-fix.yaml, code-review.yaml, test-writer.yaml, refactor.yaml
recipes/stage-2/build-then-test.yaml, review-gate.yaml, spec-first.yaml
recipes/stage-3/escalation-routing.yaml, parallel-reviewers.yaml, three-agent-pipeline.yaml
recipes/stage-4/idea-to-spec.yaml, spec-decomposition.yaml, spec-review.yaml, spec-to-pipeline.yaml
recipes/stage-5/eval-design.yaml, eval-foundation.yaml, eval-gate.yaml, eval-isolation.yaml, eval-layers.yaml, eval-ratchet.yaml
recipes/stage-6/continuous-dev.yaml, cycle-review.yaml
recipes/stage-7/metrics-dashboard.yaml, pipeline-self-edit.yaml, skill-evolution.yaml
```

### Teaching Scripts (34 files)
```
teaching/stage-0/ — 5 act scripts (act-1 through act-5)
teaching/stage-1/ — 4 scripts (bug-fix, code-review, refactor, test-writer)
teaching/stage-2/ — 3 scripts (build-then-test, review-gate, spec-first)
teaching/stage-3/ — 3 scripts (escalation-routing, parallel-reviewers, three-agent-pipeline)
teaching/stage-4/ — 4 scripts (idea-to-spec, spec-decomposition, spec-review, spec-to-pipeline)
teaching/stage-5/ — 6 scripts (eval-design, eval-foundation, eval-gate, eval-isolation, eval-layers, eval-ratchet)
teaching/stage-6/ — 2 scripts (continuous-dev, cycle-review)
teaching/stage-7/ — 3 scripts (metrics-dashboard, pipeline-self-edit, skill-evolution)
```

### Teaching Meta
```
teaching/meta/teacher-instructions.md — master facilitator reference
teaching/meta/teach-wrapper.yaml — runtime glue (NEW this session)
teaching/meta/module-designer/ — skill file + 5 reference docs
```

### Bootstrap Files (NEW this session)
```
.goose/team_context.md — template for teams to fill in
.goose/state/progression.json — initial empty state
```

### Ideas / Audit Trail
```
ideas/syllabus.md — source of truth (unchanged)
ideas/plan.md — original research (unchanged)
ideas/rollout-playbook.md — rollout plan (unchanged)
ideas/module-comparison-v1.md — Opus evaluation of V1 generation
ideas/module-comparison-v1-codex-eval.md — Codex evaluation of V1 generation
ideas/v1-cherry-pick-eval_claude.md — Claude evaluation of cherry-picks
ideas/v1-cherry-pick-eval_codex.md — Codex evaluation of cherry-picks
ideas/audit-consistency-voice.md — voice/structure audit
ideas/audit-plan-adherence.md — gap/coverage audit
ideas/audit-runtime-readiness.md — Goose compatibility audit
ideas/verification-claude.md — fix verification (Claude)
ideas/verification-codex.md — fix verification (Codex)
```

### Cleanup Done
- All 18 `_claude`/`_codex` variant files deleted by user
- `consolidated/` directory still exists (redundant — can be deleted)

---

## What's Already Done (Runtime Validated)

- All 26 recipe YAMLs + teach-wrapper.yaml pass `goose recipe validate`
- Template conditionals removed (Goose only supports `{{ param }}` substitution, no `if/endif`)
- Optional `file`-type params changed to `string` (Goose doesn't allow defaults on file params)
- Bug-fix recipe tested end-to-end via `goose run` — works, returns clean output
- Goose can be driven entirely from Claude Code via Bash (`goose run --recipe <path> --params "key=value" --no-session --max-turns N -q`)

### Running Goose from Claude Code

No need to open Goose separately. Use this pattern:
```bash
C:/Users/donid/.local/bin/goose.exe run \
  --recipe <path-to-recipe.yaml> \
  --params "param1=value1" \
  --params "param2=value2" \
  --no-session \
  --max-turns <N> \
  -q \
  2>&1
```

Key flags:
- `--no-session` — automated, no session file
- `--max-turns N` — cap iterations to prevent runaway
- `-q` — quiet mode, only model output
- `--explain` — show recipe params without running
- `--output-format json` — structured JSON output
- `goose recipe validate <path>` — syntax check without running

---

## What's Next: Full End-to-End Mock Test

### 1. Find a Sample Python Codebase
Find a real, public Python codebase suitable for testing all 8 stages. Requirements:
- Python 3.x, not too large (under 10k LOC)
- Has bugs or TODOs to fix (Stage 1)
- Has untested code (Stage 1 test-writer)
- Has PRs or code worth reviewing (Stage 1 code-review)
- Has legacy patterns worth refactoring (Stage 1 refactor)
- Complex enough to need multi-agent pipelines (Stage 3+)
- Has or could have a spec/feature to decompose (Stage 4)
- Ideally a web app or API with a test suite

### 2. Mock the Full Teaching Flow
Run every stage's teaching recipes against the sample codebase. Developer responses should be **mocked by Haiku subagents** that simulate basic, low-level Python developers with 3-5 years experience. These mock developers should:
- Know Python syntax and basic patterns
- Not know about AI-assisted development
- Make realistic mistakes: vague bug descriptions, accepting fixes without checking, writing broad test scopes, not verifying diffs
- Gradually improve across stages (learning from the teaching)
- Sometimes push back or be skeptical (these are Reliance devs, not AI enthusiasts)

### 3. Evaluate the Full Flow
After the mock run completes, launch parallel evaluation agents:
- **Opus evaluator** — assess teaching quality, coaching effectiveness, progression tracking, bridge coherence
- **GPT 5.4 evaluator** — same scope, independent assessment

Both evaluators should check:
- Did the facilitator stay in character (no fourth-wall breaks)?
- Was coaching appropriate for each rating level?
- Did progression state track correctly?
- Were stuck paths handled when the mock developer gave poor input?
- Did bridges connect stages coherently?
- Did the mock developer's skill visibly improve across stages?
- What broke? What felt unnatural? What needs rewriting?

### 4. Remaining Technical Gaps
- Structured return enforcement — recipes use prose `Return:` sections, not `json_schema`
- `onboarding/onboard.yaml` — referenced in CLAUDE.md but doesn't exist
- `install/install.sh` — referenced in CLAUDE.md but doesn't exist
- Progression state hardening — still convention-based, no code enforcement
- Update CLAUDE.md to reflect current state

---

## Key Technical Notes for Next Session

- **Goose binary:** `<HOME>\.local\bin\goose.exe` — run directly with full path
- **Goose config:** `<APPDATA>\Block\goose\config`
- **Run from Claude Code:** `C:/Users/donid/.local/bin/goose.exe run --recipe <path> --params "key=val" --no-session --max-turns 5 -q 2>&1`
- **Mock developer model:** Use Haiku (`claude-haiku-4-5-20251001`) subagents with persona prompts for 3-5yr Python devs
- **Evaluation models:** Opus (Agent subagent) + GPT 5.4 (Codex via codex_review.py) in parallel
- **All recipes use `input_type: string`** (was `text`, fixed this session)
- **All optional params have defaults** (was missing, fixed this session)
- **teach-wrapper.yaml** is thin by design — logic lives in teacher-instructions.md and .teach.md scripts
- **The skill file** at `teaching/meta/module-designer/SKILL.md` should be loaded for any module design work
- **RIL agents** at `~/ClaudeInfra/ril-agents/` are referenced inside working recipes, not the teach-wrapper

## Agents Used This Session
- 8 generation agents (4 Claude + 4 Codex)
- 2 evaluation agents (1 Claude + 1 Codex)
- 4 audit agents (2 Claude + 2 Codex)
- 4 fix agents (4 Claude)
- 2 verification agents (1 Claude + 1 Codex)
- **Total: 20 subagents**
