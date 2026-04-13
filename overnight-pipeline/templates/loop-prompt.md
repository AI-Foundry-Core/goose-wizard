# Overnight Pipeline — Loop Prompt Template

Copy this file into your run folder and customize the sections marked with {CURLY_BRACES}.

---

You are running an autonomous overnight pipeline. Each tick of this loop runs one complete cycle.

## Logging Rule (APPLIES TO EVERY STEP)

Every agent's full output must be saved to `{RUN_DIR}/logs/cycle-{N}-{step}.md`. Steps are:
- `activity` — full activity agent output
- `eval-opus` — full Opus evaluator output
- `eval-codex` — full Codex evaluator output (or "FAILED: {reason}")
- `decision` — full decision-maker output
- `planner` — full planner output
- `summary` — morning brief agent output (at milestone cycles only)

## Step 0: Read State

Read `{RUN_DIR}/state.json`. Check `current_cycle` and `status`.

- If `status` is "complete" or `current_cycle` > {TOTAL_CYCLES}: stop the loop.
- If `status` is "ready": proceed with the cycle.
- If `status` is "error": read the error, try to recover, or stop the loop.

Read the `next_planned` field for this cycle's configuration.

Also read:
- `{RUN_DIR}/cycle-plan.md` — the default sequence
- Any reusable assets needed (personas, edge cases, reference docs)

## Step 1: Reset (if needed)

{RESET_INSTRUCTIONS}
<!-- Example for simulation runs: -->
<!-- Run: git -C {TARGET_REPO} checkout . -->
<!-- Example for audit runs: no reset needed -->

## Step 2: Run Activity

{ACTIVITY_INSTRUCTIONS}
<!-- This is the pluggable part. Describe what the activity agent should do. -->
<!-- For simulations: spawn a simulator agent with persona + teaching script -->
<!-- For audits: spawn a reviewer agent with the document + criteria -->
<!-- For stress-tests: spawn a runner agent with the recipe + edge cases -->

**Output requirements:**
- Write complete output to `{RUN_DIR}/transcripts/cycle-{N}.md`
- Include: configuration used, key decisions made, full output
- Save the full agent output to `logs/cycle-{N}-activity.md`

**CRITICAL subagent tool rules (include in every agent prompt):**
> - NEVER use compound commands (&&, ||, ;, |). One command per Bash call.
> - NEVER use cd dir && command. Use absolute paths or git -C instead.
> - NEVER use grep, find, cat, head, tail via Bash. Use Read/Grep/Glob tools.
> - Use forward slashes in paths even on Windows.

## Step 3: Run Evaluators (parallel)

Launch TWO evaluators simultaneously:

**Evaluator 1 (Opus Agent subagent):**
- Read the output at `{RUN_DIR}/transcripts/cycle-{N}.md`
- Read the source material that was tested
- {EVAL_CRITERIA_OPUS}
- Score: {SCORING_DIMENSIONS} (1-5 each)
- Output top 3 strengths, top 3 weaknesses, specific fixes needed
- Write eval to `{RUN_DIR}/evaluations/cycle-{N}-opus.md`

**Evaluator 2 (Codex via script):**
- Write prompt to `.codex_prompt_tmp.md` — include "write evaluation only, do NOT explore the repo"
- Run: `python {CODEX_SCRIPT} --project-dir {PROJECT_DIR} --prompt-file {PROJECT_DIR}/.codex_prompt_tmp.md --timeout 300`
- Save to `logs/cycle-{N}-eval-codex.md` and `evaluations/cycle-{N}-codex.md`
- If Codex fails: proceed with Opus eval only, increment `codex_failures`
- Clean up `.codex_prompt_tmp.md`

## Step 4: Decision-Maker

Spawn an Agent subagent (Opus) that:

1. Reads BOTH eval reports (or just Opus if Codex failed)
2. Reads the full changelog (`{RUN_DIR}/changelog.md`)
3. Reads state.json for known issues and recurring patterns

**For each finding, classify:**

**Bucket A (apply now)** — ONLY if ALL of these are true:
- It's a clear bug, factual error, or contradiction
- It does NOT contradict any previous fix in the changelog
- The fix is unambiguous (one clear correct change)

**Bucket B (log only)** — Everything else:
- Tone/style suggestions, alternative approaches, single-occurrence evidence

{ADDITIONAL_BUCKET_A_CRITERIA}
<!-- Add domain-specific auto-fix criteria here -->

**For Bucket A fixes:** Apply using the Edit tool, then commit individually.

**For recurring Bucket B items:** If same finding appears 3+ times, promote to Bucket A.

**Append ALL findings to the changelog** with before/after/why/confidence format.

## Step 5: Planner

Spawn an Agent subagent (Opus) that designs the next cycle:
- What configuration to use (persona, target, edge cases)
- One-sentence rationale

**Override rules:**
- If a critical bug was found: insert a regression cycle next
- If no new findings for 2 consecutive cycles: shift to untested targets
- If Codex failed 3+ times: disable Codex for remaining cycles

**Output:** The `next_planned` object for state.json.
**IMPORTANT:** The planner sets `next_planned` ONLY. Never touch `current_cycle`.

## Step 6: Update State

Update state.json:
- Increment `current_cycle`
- Add this cycle to `completed_cycles`
- Update known issues and recurring pattern counts
- Set `next_planned` from planner output

## Step 7: Morning Brief (milestone cycles)

At cycles {MILESTONE_CYCLES}:

Write `{RUN_DIR}/morning-brief.md` with:
1. Status line: "Cycle X of {TOTAL_CYCLES} complete. Y fixes applied, Z proposed."
2. What was tested and what was found
3. What needs decisions (top Bucket B items)
4. Coverage: what's been tested vs. what remains
5. One-paragraph assessment

## Step 8: Schedule Next Wake

If `current_cycle` <= {TOTAL_CYCLES} and `status` != "complete":
Schedule next wake with 270-second delay (stays in prompt cache window).

Otherwise: set `status: "complete"` and stop.
