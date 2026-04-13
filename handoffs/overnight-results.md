# Handoff: Overnight Pipeline Results

**Date:** 2026-04-13 (morning)
**Branch:** `overnight-pipeline`
**Status:** Pipeline complete. 20 cycles, 72 fixes, all regressions passed.

---

## What Happened

An autonomous pipeline ran 20 test cycles overnight against all RILGoose teaching scripts. Each cycle simulated a full teaching session with a mock developer persona, evaluated the transcript with two independent evaluators (Opus + Codex/GPT 5.4), classified findings, applied safe fixes, and designed the next cycle.

**Runtime:** ~6 hours across 20 cycles
**Codex failures:** 0 (one timeout on the final cycle, non-blocking)

---

## What to Read First

1. **`ideas/overnight-pipeline/morning-brief.md`** — Executive summary. 5-minute read. Has the stage coverage table, personality coverage, top 5 decisions needed, and one-paragraph assessment.

2. **`ideas/overnight-pipeline/changelog.md`** — Every fix applied (with before/after/why) and every fix proposed (with evidence and occurrence count). This is long but comprehensive.

3. **This file** — Context for a fresh session to continue the work.

---

## Results Summary

| Metric | Value |
|--------|-------|
| Cycles completed | 20 of 20 |
| Bucket A fixes applied | 72 |
| Bucket B items tracked | 55 (20+ unique patterns) |
| Auto-promotions (Bucket B → A) | 5 patterns |
| Regressions run | 3 (Stage 0, Stage 3, Stage 5) |
| Regressions passed | 3 of 3 |
| Quality trend | 23/35 → 34/35 (peak at Cycle 19) |
| Codex failures | 0 |
| Stages covered | All 8 |
| Recipes tested | 17 of 26 (65%) |
| Personas used | All 9 |

---

## Most Important Fixes (read the changelog for details)

### Critical (would have blocked pilot)
1. **Privacy answer contradiction** (Cycle 15) — Section 13 of teacher-instructions.md said "Your code stays on your machine" then immediately said "sends context to the model for processing." Fixed to accurate data flow description. Would have failed enterprise security review.

2. **Mode mismatch in fully adaptive sessions** (Cycles 6, 13, 16) — Facilitator was driving the session when the developer should drive (Stages 5-7). Added guardrails: open questions before enumerating, developer designs before code runs, Socratic ratio guidance.

### Systematic (applied to every module)
3. **Wait-time insights** — Every module was missing the ordered insight list required by teacher-instructions.md Section 13. Added to all tested modules across cycles 7-18.

4. **Enterprise grounding** — Every module was missing enterprise context questions. Added sections with team workflow, CI placement, and audit trail questions.

5. **Developer-driven verification** — The biggest structural fix. In Stage 5+, the developer must propose verification commands BEFORE the subagent runs anything. Verified holding in final regression (Cycle 20).

### Script-Level
6. **team_context.md fallback** (Cycle 1) — Scripts assumed .goose/team_context.md exists. Added fallback scanning.
7. **Challenge assessment wording** (Cycle 2) — "No guidance" → "No coaching from me, you drive the decisions."
8. **Insight conditioning** (Cycle 2) — Wait-time insights skip when irrelevant (clean one-pass fix, challenge assessments).
9. **Reject-repair loop** (Cycle 10) — Developer must reject incomplete build and repair before bridge.
10. **Finding-validity check** (Cycle 17) — Developer must sample-check findings against source before editing instructions.

---

## What Still Needs Decisions

### Bucket B Items Approaching Auto-Promotion (2 of 3 occurrences)
These will auto-promote to Bucket A if they appear one more time:
- **Act 2 review verification** — Developer approves without evaluating content. Would add a "what did that change actually do?" check.
- **Act 3 developer hands-on** — Developer watches facilitator undo but never tries git themselves. Would add a hands-on step.
- **Persona enterprise questions** — Mock dev personas don't naturally surface enterprise workflow questions.

### Simulator Issues (not script fixes)
- **Persona fading** — Mock dev personas (both Haiku and GPT 5.4) lose their defining traits after ~60% of sessions. 9 occurrences across the pipeline.
- **Eval loop not evidenced** — Scripts specify async eval delegation but simulator transcripts don't show the eval-mediated coaching mechanism. 4 occurrences.
- **Simulation notes contain eval metadata** — The `=== SIMULATION NOTES ===` section in transcripts contains dimension scores and ratings. Evaluators disagreed on whether this matters (notes are evaluator-only, not developer-visible).

### Untested Recipes
9 recipes were not tested in the 20-cycle run:
- Stage 2: review-gate
- Stage 3: parallel-reviewers
- Stage 4: spec-review, spec-decomposition
- Stage 5: eval-design, eval-layers, eval-isolation, eval-gate
- Stage 7: pipeline-self-edit

These scripts have the systematic fixes (wait-time insights, enterprise grounding) from the modules that WERE tested, but they haven't been simulated.

---

## Git State

**Branch:** `overnight-pipeline` (not merged to main)
**Commits:** ~30 commits from `685970e` (baseline) to `ccd3099` (pipeline complete)

To see all changes:
```
git -C C:/Users/donid/ClaudeProjects/RILGoose log --oneline overnight-pipeline
git -C C:/Users/donid/ClaudeProjects/RILGoose diff main..overnight-pipeline --stat
```

To merge to main when ready:
```
git -C C:/Users/donid/ClaudeProjects/RILGoose checkout main
git -C C:/Users/donid/ClaudeProjects/RILGoose merge overnight-pipeline
```

---

## File Map

### Pipeline Infrastructure (read-only reference)
```
ideas/overnight-pipeline/
├── state.json              — Final state (status: complete, 20 cycles recorded)
├── morning-brief.md        — Executive summary (read this first)
├── changelog.md            — All 72 applied fixes + 55 proposed fixes
├── cycle-plan.md           — The 20-cycle schedule
├── loop-prompt.md          — The autonomous loop instructions
├── personas.md             — 9 mock developer personas
├── edge-cases.md           — 14 edge case scenarios
├── transcripts/            — 20 simulated session transcripts
│   └── cycle-{1-20}.md
├── evaluations/            — 40 evaluation reports (Opus + Codex per cycle)
│   └── cycle-{1-20}-{opus,codex}.md
└── logs/                   — Full agent output logs for every step
    └── cycle-{1-20}-{simulator,eval-opus,eval-codex,decision,planner,summary}.md
```

### Teaching Scripts (these were EDITED by the pipeline)
```
teaching/
├── meta/teacher-instructions.md    — Master facilitator guide (heavily updated)
├── stage-0/act-{1-5}*.teach.md     — Stage 0 scripts (4 fixes)
├── stage-1/{bug-fix,test-writer,code-review,refactor}.teach.md  — Stage 1 (many fixes)
├── stage-2/{build-then-test,spec-first}.teach.md
├── stage-3/{three-agent-pipeline,escalation-routing}.teach.md
├── stage-4/{idea-to-spec,spec-to-pipeline}.teach.md
├── stage-5/{eval-foundation,eval-ratchet}.teach.md
├── stage-6/{cycle-review,continuous-dev}.teach.md
└── stage-7/{metrics-dashboard,skill-evolution}.teach.md
```

---

## What a Fresh Session Should Do Next

### Option A: Review and Merge
1. Read `morning-brief.md` and `changelog.md`
2. Spot-check a few transcripts to validate quality
3. Merge `overnight-pipeline` to `main`
4. Decide on the 3 Bucket B items approaching promotion

### Option B: Continue Testing
1. Run more cycles targeting untested recipes (9 remaining)
2. Focus on Stage 5 which has the most untested (4 of 6)
3. Consider a focused pipeline on just the untested recipes

### Option C: Address Simulator Issues
1. Fix persona fading (add mid-session persona reinforcement instructions)
2. Fix eval loop visibility (add eval delegation markers to transcripts)
3. Fix simulation notes metadata (separate evaluator trace from transcript)

---

## Technical Notes for the Next Session

- **MockTestTarget** (`C:\Users\donid\ClaudeProjects\MockTestTarget`) is the Flask repo used for all code operations. It has untracked `.goose/` state files from simulations — safe to clean with `git -C ... checkout .` and `rm -rf .goose/`
- **Codex evaluator** at `C:\Users\donid\ClaudeProjects\AgenticSystem\codex_review.py` worked flawlessly for 19 cycles, timed out once on Cycle 20
- **State.json** is the source of truth for pipeline progress. Status is "complete."
- All teaching script edits are committed individually with descriptive messages on the `overnight-pipeline` branch
