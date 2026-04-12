# Handoff: Launch Overnight Hardening Pipeline

**Date:** 2026-04-12
**Purpose:** A fresh Claude Code session reads this and immediately launches the autonomous overnight pipeline.
**Expected runtime:** ~8.5 hours (20 cycles at ~25 min each)

---

## What This Does

Runs 20 automated test cycles against the RILGoose teaching system. Each cycle:
1. Simulates a full teaching session with a mock developer persona
2. Two evaluators (Opus + Codex/GPT 5.4) assess the transcript
3. A decision-maker applies safe fixes and logs risky ones
4. A planner designs the next test cycle
5. Everything is logged for morning review

Covers all 8 stages (0-7) with 9 different developer personalities and 14 edge case scenarios. Mock developer responses alternate between Haiku (odd cycles) and GPT 5.4 (even cycles) for model diversity.

---

## Prerequisites (already done)

- [x] Flask cloned at `C:\Users\donid\ClaudeProjects\MockTestTarget`
- [x] Goose installed at `C:\Users\donid\.local\bin\goose.exe`
- [x] Pipeline infrastructure at `ideas/overnight-pipeline/` (state.json, personas, edge cases, cycle plan, loop prompt)
- [x] Teaching scripts at `teaching/` (Stages 0-7, all with fixes from today's session)
- [x] Git branch `overnight-pipeline` with baseline checkpoint
- [x] Codex at `C:\Users\donid\ClaudeProjects\AgenticSystem\codex_review.py`
- [x] Machine will stay on and won't sleep

---

## Files To Read First

Read these in order to understand the pipeline:

1. **`ideas/overnight-pipeline/loop-prompt.md`** — The complete step-by-step instructions for each cycle. This is the source of truth for what to do.
2. **`ideas/overnight-pipeline/state.json`** — Current state. Shows cycle 1 is ready to start.
3. **`ideas/overnight-pipeline/cycle-plan.md`** — The 20-cycle schedule: which stage, recipe, personality, mock dev model, and edge cases per cycle.
4. **`ideas/overnight-pipeline/personas.md`** — 9 mock developer personas with full behavioral definitions.
5. **`ideas/overnight-pipeline/edge-cases.md`** — 14 edge case scenarios.
6. **`ideas/overnight-pipeline/changelog.md`** — Where all applied and proposed changes are logged.

You do NOT need to read the teaching scripts themselves — the simulator subagent reads them during each cycle.

---

## How To Launch

### Step 1: Verify you're on the right branch

```
git -C C:/Users/donid/ClaudeProjects/RILGoose branch
```

Should show `* overnight-pipeline`. If not:
```
git -C C:/Users/donid/ClaudeProjects/RILGoose checkout overnight-pipeline
```

### Step 2: Verify state is clean

Read `ideas/overnight-pipeline/state.json`. It should show:
- `current_cycle`: 1
- `status`: "ready"

If cycle > 1 (pipeline was partially run before), that's fine — it picks up where it left off.

### Step 3: Launch the loop

Use `/loop` with this prompt (no interval — self-paced dynamic mode):

```
/loop Run one cycle of the overnight hardening pipeline for RILGoose teaching scripts. Read the full instructions from C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\loop-prompt.md and execute Steps 0-8 for the current cycle. State is in C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\state.json. All file paths use forward slashes. One command per Bash call, no compound commands.
```

### Step 4: Let it run

Each cycle:
1. Reads state.json to know what to do
2. Resets Flask repo
3. Spawns simulator agent (the big one — 5-8 min)
4. Spawns 2 evaluators in parallel
5. Spawns decision-maker (applies Bucket A fixes, logs Bucket B)
6. Spawns planner (designs next cycle)
7. Updates state.json
8. Writes morning brief at cycles 7, 14, 20
9. Schedules next wake at 270s delay

After cycle 20 (or if status becomes "complete"), the loop stops automatically.

---

## Key Technical Details

### Subagent Rules (include in EVERY agent prompt)
```
- NEVER use compound commands (&&, ||, ;, |). One command per Bash call.
- NEVER use cd dir && command. Use absolute paths or git -C instead.
- NEVER use grep, find, cat, head, tail via Bash. Use Read/Grep/Glob tools.
- Use forward slashes in paths even on Windows.
```

### Mock Developer Model Alternation
- Odd cycles: Haiku subagent (model: haiku) at each interaction point, real-time
- Even cycles: GPT 5.4 via `python C:/Users/donid/ClaudeProjects/AgenticSystem/codex_review.py --project-dir <dir> --prompt-file <file> --timeout 300`
- If Codex fails 3+ times: all remaining cycles use Haiku

### Stage Progression Context (Stages 2-7)
Each simulator prompt must pre-seed the mock developer's context as if they've completed all prior stages. The loop-prompt.md has the full details including stage-specific mistake instructions for realistic Weak/Adequate coaching triggers.

### Change Classification
- **Bucket A (auto-applied):** Script bugs, fourth-wall breaks, factual errors, dead-ends, premature coaching (Stages 5-7), phantom prerequisites
- **Bucket B (logged only):** Tone/voice, alternative phrasings, structural, single-cycle evidence
- Bucket B items appearing 3+ times auto-promote to Bucket A

### Quality Gate
- Regression cycles (14, 19, 20): compare with prior scores, revert if 2+ point drop
- First-time recipes: validation only (no baseline to compare)

### Git Checkpoints
Every Bucket A fix is committed on the `overnight-pipeline` branch. Reverts use `git revert HEAD`. The baseline commit is the starting point for all changes.

---

## Output Files (what the team sees in the morning)

### Primary (read these first)
- **`ideas/overnight-pipeline/morning-brief.md`** — 5-minute executive summary. Written at cycles 7, 14, 20. Split into high-confidence (Stages 0-1) and exploratory (Stages 2-7) sections.
- **`ideas/overnight-pipeline/changelog.md`** — Every fix applied (with before/after/why) and every fix proposed (with evidence and occurrence count).

### Secondary (for debugging)
- **`ideas/overnight-pipeline/transcripts/cycle-{N}.md`** — Full simulated session transcript for each cycle
- **`ideas/overnight-pipeline/evaluations/cycle-{N}-opus.md`** — Opus eval for each cycle
- **`ideas/overnight-pipeline/evaluations/cycle-{N}-codex.md`** — Codex eval for each cycle (if available)
- **`ideas/overnight-pipeline/logs/cycle-{N}-{step}.md`** — Full agent output for every step (simulator, eval-opus, eval-codex, decision, planner, summary, mock-dev-responses)
- **`ideas/overnight-pipeline/state.json`** — Final state with all completed cycles

### Git History
```
git -C C:/Users/donid/ClaudeProjects/RILGoose log --oneline overnight-pipeline
```
Shows every Bucket A fix as an individual commit with a descriptive message.

---

## If Something Goes Wrong

### Pipeline stopped mid-cycle
Just re-launch the `/loop` command. It reads state.json and picks up from wherever it left off.

### state.json is corrupt
The pipeline writes to `state.json.tmp` then renames. If both are corrupt, manually set:
```json
{"current_cycle": N, "status": "ready", "total_planned_cycles": 20, ...}
```
where N is the next cycle to run.

### Codex keeps failing
After 3 failures, the pipeline automatically switches all remaining cycles to Haiku. Check `codex_failures` in state.json.

### Scripts seem to be getting worse
Check the changelog for contradictory fixes (Bucket A fix in cycle N contradicts Bucket A fix in cycle M). The decision-maker checks for this, but if it slips through, manually revert to the baseline:
```
git -C C:/Users/donid/ClaudeProjects/RILGoose reset --hard 685970e
```
(That's the commit hash of the expanded pipeline baseline.)

### Context window issues
If the loop orchestrator starts behaving erratically (skipping steps, wrong cycle numbers), the context is degraded. Stop the loop, open a fresh session, read this handoff, and re-launch. State.json preserves all progress.

---

## What Was Done Before This Pipeline

### This Session (2026-04-12)
1. Ran Stage 0 mock test against Flask with "Rahul" (skeptical dev)
2. Two evaluators (Opus + Codex) found 7 issues: Act 3 needs adaptive shortcut, Act 2 edit too trivial, enterprise FAQ missing, Act 5 semi-specific handling, etc.
3. Applied all 7 fixes to Stage 0 + Stage 1 scripts
4. Built Wait-Time Insights framework (Section 13 in teacher-instructions.md) + master insight library + 15 while-waiting blocks in scripts
5. Two more evaluators verified the fixes (found 7 more issues — all fixed)
6. Designed and built this pipeline with 4 adversarial reviews and fixes

### Prior Session (2026-04-12, earlier)
- Generated all 30 teaching scripts and 26 recipes via multi-model pipeline
- Audited and fixed all scripts (25 recipe YAML fixes, teach-wrapper, bootstrap files)
- Installed and configured Goose CLI
- All recipes pass `goose recipe validate`

### The Teaching System
- 8 stages: See What AI Can Do → Get Real Work Done → Two AIs → AI Specialists → Spec Writing → Verification → Autonomous Ops → Self-Improvement
- Progressive teaching modes: Scripted → Guided-Adaptive → Adaptive+Checkpoints → Fully Adaptive
- Three-agent pattern: Facilitator (guides) + Code-Work (does code) + Eval (rates quality)
- Target audience: Skeptical Reliance enterprise developers, 3-5yr experience
- Full design in `ideas/syllabus.md`
