# Audit: Plan Adherence — RILGoose

**Date:** 2026-04-12
**Auditor:** Claude Opus 4.6 (second pass — replaces prior audit)
**Scope:** Syllabus concepts vs. actual files, handoff completion, missing files, cross-references.

---

## 1. Concept Coverage: Syllabus vs. Actual Files

### Stage 0 (5 concepts — Scripted)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 0.1 AI reads your actual code | `recipes/stage-0/stage-0-welcome.yaml` (single recipe, 5 acts) | `teaching/stage-0/act-1-see-your-code.teach.md` | DONE |
| 0.2 AI edits your actual code | (same recipe) | `teaching/stage-0/act-2-first-edit.teach.md` | DONE |
| 0.3 Everything is reversible | (same recipe) | `teaching/stage-0/act-3-undo-button.teach.md` | DONE |
| 0.4 AI is confident, not correct | (same recipe) | `teaching/stage-0/act-4-catch-the-bug.teach.md` | DONE |
| 0.5 You control the quality | (same recipe) | `teaching/stage-0/act-5-say-it-better.teach.md` | DONE |

**Verdict:** Stage 0 complete. All 5 acts extracted to individual teaching scripts. Single recipe covers all acts.

### Stage 1 (4 concepts — Guided-Adaptive)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 1.1 Bug Fix | `recipes/stage-1/bug-fix.yaml` | `teaching/stage-1/bug-fix.teach.md` | DONE |
| 1.2 Test Writer | `recipes/stage-1/test-writer.yaml` | `teaching/stage-1/test-writer.teach.md` | DONE |
| 1.3 Code Review | `recipes/stage-1/code-review.yaml` | `teaching/stage-1/code-review.teach.md` | DONE |
| 1.4 Refactor | `recipes/stage-1/refactor.yaml` | `teaching/stage-1/refactor.teach.md` | DONE |

**Verdict:** Stage 1 complete. All 4 recipes + teaching scripts exist. However, root versions lack cherry-pick improvements (see Section 2).

### Stage 2 (4 concepts — Adaptive + Checkpoints)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 2.1 Why one AI isn't enough | `recipes/stage-2/build-then-test.yaml` | `teaching/stage-2/build-then-test.teach.md` | DONE |
| 2.2 Specialists beat generalists | `build-then-test.yaml` + `review-gate.yaml` | (covered by 2.1 and 2.3 scripts) | DONE (shared) |
| 2.3 Prove it works, don't just look | `recipes/stage-2/review-gate.yaml` | `teaching/stage-2/review-gate.teach.md` | DONE |
| 2.4 Define success before building | `recipes/stage-2/spec-first.yaml` | `teaching/stage-2/spec-first.teach.md` | DONE |

**Verdict:** Stage 2 complete. Root spec-first.teach.md lacks the cherry-picked "Spec ownership" dimension.

### Stage 3 (5 concepts — Adaptive + Checkpoints)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 3.1 Agent roles and specialization | `recipes/stage-3/three-agent-pipeline.yaml` | `teaching/stage-3/three-agent-pipeline.teach.md` | DONE |
| 3.2 Agents need clear contracts | (same recipe) | (covered by 3.1 script) | DONE (shared) |
| 3.3 Safety rails for autonomous op | `recipes/stage-3/escalation-routing.yaml` | **MISSING from root** | GAP |
| 3.4 Layered testing | `recipes/stage-3/parallel-reviewers.yaml` | `teaching/stage-3/parallel-reviewers.teach.md` | DONE |
| 3.5 Parallel agents need coordination | (same recipe) | (covered by 3.4 script) | DONE (shared) |

**Verdict:** Stage 3 has 1 gap. `escalation-routing.teach.md` exists only as `_claude`/`_codex` variants in root and as a merged file in `consolidated/`. Never promoted.

### Stage 4 (6 concepts — Adaptive + Checkpoints)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 4.1 Vague specs produce vague output | `recipes/stage-4/idea-to-spec.yaml` | `teaching/stage-4/idea-to-spec.teach.md` | DONE |
| 4.2 Progressive elaboration | (same recipe) | (covered by 4.1 script) | DONE (shared) |
| 4.3 Decompose by persona | `recipes/stage-4/spec-decomposition.yaml` | `teaching/stage-4/spec-decomposition.teach.md` | DONE |
| 4.4 Every requirement must be testable | `recipes/stage-4/spec-to-pipeline.yaml` | **MISSING from root** | GAP |
| 4.5 AI-assisted spec quality gates | `recipes/stage-4/spec-review.yaml` | `teaching/stage-4/spec-review.teach.md` | DONE |
| 4.6 Kill criteria | (same recipe as 4.5) | (covered by 4.5 script) | DONE (shared) |

**Verdict:** Stage 4 has 1 gap. `spec-to-pipeline.teach.md` exists only as `_claude`/`_codex` variants in root and as a merged file in `consolidated/`. Never promoted. Note: `spec-decomposition.teach.md` also touches 4.4, so there is partial coverage, but the dedicated 4.4 module is missing from root.

### Stage 5 (6 concepts — Fully Adaptive)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 5.1 Never trust self-reported results | `recipes/stage-5/eval-foundation.yaml` | `teaching/stage-5/eval-foundation.teach.md` | DONE |
| 5.2 Layered eval strategy | `recipes/stage-5/eval-layers.yaml` | `teaching/stage-5/eval-layers.teach.md` | DONE |
| 5.3 Eval ratchets prevent regression | `recipes/stage-5/eval-ratchet.yaml` | `teaching/stage-5/eval-ratchet.teach.md` | DONE |
| 5.4 Specific checks find problems | `recipes/stage-5/eval-design.yaml` | `teaching/stage-5/eval-design.teach.md` | DONE |
| 5.5 Mock external dependencies | `recipes/stage-5/eval-isolation.yaml` | `teaching/stage-5/eval-isolation.teach.md` | DONE |
| 5.6 Evals must run before autonomy | `recipes/stage-5/eval-gate.yaml` | `teaching/stage-5/eval-gate.teach.md` | DONE |

**Verdict:** Stage 5 complete.

### Stage 6 (6 concepts — Fully Adaptive)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 6.1 Step back and evaluate the whole | `recipes/stage-6/cycle-review.yaml` | `teaching/stage-6/cycle-review.teach.md` | DONE |
| 6.2 Close the feedback loop | (same recipe) | (covered by 6.1 script) | DONE (shared) |
| 6.3 Success signals can lie | (same recipe) | (covered by 6.1 script) | DONE (shared) |
| 6.4 Capture what you learn | `recipes/stage-6/continuous-dev.yaml` | `teaching/stage-6/continuous-dev.teach.md` | DONE |
| 6.5 Agents need their own memory | (same recipe) | (covered by 6.4 script) | DONE (shared) |
| 6.6 Shared state requires discipline | (same recipe) | (covered by 6.4 script) | DONE (shared) |

**Note:** Syllabus references `ten-session-cycle` as a recipe name for concept 6.1, but the actual recipe is `cycle-review.yaml`. Minor naming mismatch, not a functional gap.

**Verdict:** Stage 6 complete (with naming discrepancy).

### Stage 7 (5 concepts — Fully Adaptive)

| Concept | Recipe | Teaching Script | Status |
|---------|--------|-----------------|--------|
| 7.1 The Curator closes the loop | `recipes/stage-7/skill-evolution.yaml` | `teaching/stage-7/skill-evolution.teach.md` | DONE |
| 7.2 Agent instructions should evolve | (same recipe) | (covered by 7.1 script) | DONE (shared) |
| 7.3 Rules accumulate and conflict | `recipes/stage-7/pipeline-self-edit.yaml` | `teaching/stage-7/pipeline-self-edit.teach.md` | DONE |
| 7.4 Measure, don't guess | `recipes/stage-7/metrics-dashboard.yaml` | `teaching/stage-7/metrics-dashboard.teach.md` | DONE |
| 7.5 Audit your guardrails | (same recipe as 7.3) | (covered by 7.3 script) | DONE (shared) |

**Verdict:** Stage 7 complete. Root `pipeline-self-edit.yaml` lacks the audit-only mode flag from cherry-pick #6.

### Concept Coverage Summary

- **41 concepts** defined in the syllabus
- **39 concepts** have matching recipes + teaching scripts in the root directories
- **2 concepts** have recipes but missing final teaching scripts in root:
  - 3.3 `escalation-routing.teach.md` -- merged version in `consolidated/` only
  - 4.4 `spec-to-pipeline.teach.md` -- merged version in `consolidated/` only

---

## 2. Cherry-Pick Completion

The handoff lists 6 cherry-picks. All 6 were applied in `consolidated/`. NONE have been promoted to the root directories.

| # | Cherry-Pick | Consolidated File | In Root? |
|---|-------------|-------------------|----------|
| 1 | Stage 1 test-writer: proactive assertion-quality prompt | `consolidated/teaching/stage-1/test-writer.teach.md` | NO |
| 2 | Stage 1 code-review: residual-risk return fields | `consolidated/recipes/stage-1/code-review.yaml` | NO |
| 3 | Stage 2 spec-first: spec-ownership eval dimension | `consolidated/teaching/stage-2/spec-first.teach.md` | NO |
| 4 | Stage 2 review-gate: gate-decision-discipline framing | `consolidated/teaching/stage-2/review-gate.teach.md` | NO |
| 5 | Stage 3 three-agent-pipeline: richer coaching examples | `consolidated/teaching/stage-3/three-agent-pipeline.teach.md` | NO |
| 6 | Stage 7 pipeline-self-edit: audit-only mode flag | `consolidated/recipes/stage-7/pipeline-self-edit.yaml` | NO |

**Verdict:** Cherry-picks are done but stranded in `consolidated/`. The root tree is the V1 pre-cherry-pick state.

---

## 3. Handoff Next-Steps Status

| # | Priority Item | Status | Detail |
|---|---------------|--------|--------|
| 1 | Resolve 4 gaps from HANDOFF_stage1_detail.md | DONE in consolidated | Delegate convention, dynamic content, pitfall strategy addressed in `consolidated/teaching/meta/teacher-instructions.md`. Root `teaching/meta/teacher-instructions.md` does not exist. |
| 2 | Apply the 6 cherry-pick refinements | DONE in consolidated | Not promoted to root. See Section 2. |
| 3 | Write teacher-instructions.md | DONE in consolidated | Full behavioral reference at `consolidated/teaching/meta/teacher-instructions.md`. Not in root. |
| 4 | Runtime validation against Goose | NOT STARTED | No evidence of any recipe tested against Goose runtime. |
| 5 | Progression state hardening | NOT STARTED | No schema, validator, migration, concurrency, or recovery logic. |
| 6 | V2 quality pass | NOT STARTED | No re-scoring against the 10-criterion scorecard. |

---

## 4. Stage 0 Act Scripts

All 5 act scripts are extracted and complete in `teaching/stage-0/`:
- `act-1-see-your-code.teach.md`
- `act-2-first-edit.teach.md`
- `act-3-undo-button.teach.md`
- `act-4-catch-the-bug.teach.md`
- `act-5-say-it-better.teach.md`

The recipe `recipes/stage-0/stage-0-welcome.yaml` references all 5 by path. CLAUDE.md still says "not yet extracted" -- this is outdated.

**Verdict:** Stage 0 is complete and extracted. CLAUDE.md needs updating.

---

## 5. Missing Files

### Files referenced in CLAUDE.md that do not exist

| Referenced File | Status |
|-----------------|--------|
| `teaching/meta/teacher-instructions.md` | MISSING -- exists only at `consolidated/teaching/meta/teacher-instructions.md` |
| `teaching/meta/teach-wrapper.yaml` | MISSING -- never created |
| `onboarding/onboard.yaml` | MISSING -- never created |
| `install/install.sh` | MISSING -- never created |

### Teaching scripts missing from root (exist in consolidated)

| File | Root Status |
|------|-------------|
| `teaching/stage-3/escalation-routing.teach.md` | Only `_claude`/`_codex` variants in root |
| `teaching/stage-4/spec-to-pipeline.teach.md` | Only `_claude`/`_codex` variants in root |

### Leftover variant files to clean up (14 files)

These are intermediate generation artifacts that should be removed after consolidated versions are promoted:

- `recipes/stage-1/code-review_claude.yaml`
- `recipes/stage-1/code-review_codex.yaml`
- `recipes/stage-7/pipeline-self-edit_claude.yaml`
- `recipes/stage-7/pipeline-self-edit_codex.yaml`
- `teaching/stage-1/test-writer_claude.teach.md`
- `teaching/stage-1/test-writer_codex.teach.md`
- `teaching/stage-2/spec-first_claude.teach.md`
- `teaching/stage-2/spec-first_codex.teach.md`
- `teaching/stage-2/review-gate_claude.teach.md`
- `teaching/stage-2/review-gate_codex.teach.md`
- `teaching/stage-3/escalation-routing_claude.teach.md`
- `teaching/stage-3/escalation-routing_codex.teach.md`
- `teaching/stage-3/three-agent-pipeline_claude.teach.md`
- `teaching/stage-3/three-agent-pipeline_codex.teach.md`
- `teaching/stage-4/spec-to-pipeline_claude.teach.md`
- `teaching/stage-4/spec-to-pipeline_codex.teach.md`
- `teaching/meta/teacher-instructions_claude.md`
- `teaching/meta/teacher-instructions_codex.md`

---

## 6. Cross-References

### Teaching scripts to recipes: All valid

Every teaching script references a recipe that exists as a YAML in `recipes/stage-N/`.

### Recipes to RIL agents: All paths resolve

Every `~/ClaudeInfra/ril-agents/plugins/...` path referenced in recipe YAMLs resolves to an actual file. Verified:

- `error-debugging/agents/debugger.md` and `error-detective.md` -- exist
- `unit-testing/agents/test-automator.md` -- exists
- `comprehensive-review/agents/code-reviewer.md` and `architect-review.md` -- exist
- `code-refactoring/agents/legacy-modernizer.md` -- exists
- `agent-teams/agents/team-lead.md`, `team-implementer.md`, `team-reviewer.md` -- exist
- `product-planning/agents/prd-development.md` -- exists
- `product-specification/agents/feature-spec.md` and `acceptance-criteria.md` -- exist
- `product-evaluation/agents/product-evaluation.md` and `post-mortem.md` -- exist
- `documentation-generation/agents/tutorial-engineer.md` -- exists

### RIL agent mapping gaps (not broken, but missing references)

The syllabus maps every stage to specific RIL agents, but several recipes do not reference any:

| Recipe | Syllabus Maps To | Reference In YAML? |
|--------|-----------------|-------------------|
| `recipes/stage-4/spec-review.yaml` | (no specific mapping) | No RIL agent |
| `recipes/stage-4/spec-to-pipeline.yaml` | (no specific mapping) | No RIL agent |
| `recipes/stage-6/continuous-dev.yaml` | Conductor framework | No RIL agent |
| `recipes/stage-6/cycle-review.yaml` | Conductor framework | No RIL agent |
| `recipes/stage-7/metrics-dashboard.yaml` | (no specific mapping) | No RIL agent |
| `recipes/stage-7/pipeline-self-edit.yaml` | (no specific mapping) | No RIL agent |

The Conductor plugin exists at `~/ClaudeInfra/ril-agents/plugins/conductor/agents/conductor-validator.md` but no Stage 6 recipe references it.

---

## Prioritized Punch List

### P0 -- Promote consolidated files to root (blocks everything else)

The `consolidated/` directory contains finished, cherry-picked work that is not live. Copy these 9 files to their root locations:

1. `consolidated/teaching/meta/teacher-instructions.md` --> `teaching/meta/teacher-instructions.md`
2. `consolidated/teaching/stage-1/test-writer.teach.md` --> `teaching/stage-1/test-writer.teach.md`
3. `consolidated/recipes/stage-1/code-review.yaml` --> `recipes/stage-1/code-review.yaml`
4. `consolidated/teaching/stage-2/spec-first.teach.md` --> `teaching/stage-2/spec-first.teach.md`
5. `consolidated/teaching/stage-2/review-gate.teach.md` --> `teaching/stage-2/review-gate.teach.md`
6. `consolidated/teaching/stage-3/three-agent-pipeline.teach.md` --> `teaching/stage-3/three-agent-pipeline.teach.md`
7. `consolidated/teaching/stage-3/escalation-routing.teach.md` --> `teaching/stage-3/escalation-routing.teach.md`
8. `consolidated/teaching/stage-4/spec-to-pipeline.teach.md` --> `teaching/stage-4/spec-to-pipeline.teach.md`
9. `consolidated/recipes/stage-7/pipeline-self-edit.yaml` --> `recipes/stage-7/pipeline-self-edit.yaml`

### P1 -- Clean up variant files and staging directory

After P0, delete:
- All 18 `_claude`/`_codex` variant files listed in Section 5
- The `consolidated/` directory
- Empty directories `recipes/stage-0/acts/` and `recipes/stage-0/state/` (per handoff)

### P2 -- Create or drop teach-wrapper.yaml

`teaching/meta/teach-wrapper.yaml` is referenced in CLAUDE.md as part of the architecture (meta-recipe that wraps any recipe in teaching mode, adding facilitator + eval subagent). It was never created. Either create it or remove it from CLAUDE.md. This is architecturally important -- without it, the facilitator/eval/code-work three-agent pattern described in the syllabus has no runtime implementation.

### P3 -- Update CLAUDE.md

The project instructions are stale:
- Says Stage 0 "not yet extracted" -- it has been
- Says Stage 1 teaching scripts "TO BE CREATED" -- they exist
- Says teacher-instructions.md "TO BE CREATED" -- it exists in consolidated
- Lists `teaching/stage-2+/` which does not exist (individual stage dirs used instead)
- Does not mention the `consolidated/` directory or variant file situation
- Does not mention the `HANDOFF_v1_modules.md` which is now the latest handoff

### P4 -- Syllabus naming fix

Concept 6.1 references recipe `ten-session-cycle` but actual recipe is `cycle-review.yaml`. Update syllabus or rename recipe.

### P5 -- Fill RIL agent gaps in recipes

Stage 6 recipes should reference the Conductor framework. Stage 4 `spec-review` and `spec-to-pipeline`, and Stage 7 `metrics-dashboard` and `pipeline-self-edit` could benefit from RIL agent references.

### P6 -- Runtime validation (handoff item #4)

No recipe has been tested against Goose. Start with `recipes/stage-1/bug-fix.yaml` (simplest, most complete).

### P7 -- Progression state hardening (handoff item #5)

No schema, validation, concurrency handling, or corruption recovery for `.goose/state/progression.json`. Every teaching script reads this file but nothing initializes or validates it.

### P8 -- V2 quality pass (handoff item #6)

Re-score all modules against the 10-criterion scorecard from `teaching/meta/module-designer/SKILL.md`.

### P9 -- Create onboarding and install infrastructure

`onboarding/onboard.yaml` and `install/install.sh` are listed in CLAUDE.md but never created. Either create them or remove from the project structure documentation.
