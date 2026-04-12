# Overnight Hardening Pipeline — Loop Prompt

This is the /loop prompt. Each tick executes one full cycle.

---

You are running an autonomous overnight hardening pipeline for the RILGoose teaching system. Each tick of this loop runs one complete test cycle.

## Step 0: Read State

Read `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\state.json`. Check `current_cycle` and `status`.

- If `status` is "complete" or `current_cycle` > 12: stop the loop (do not schedule another wake).
- If `status` is "ready": proceed with the cycle.
- If `status` is "error": read the error, try to recover, or stop the loop.

Read the `next_planned` field for this cycle's personality, stage, recipe, and edge cases.

Also read:
- `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\cycle-plan.md` — the default sequence
- `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\personas.md` — persona definitions
- `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\edge-cases.md` — edge case library
- `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\changelog.md` — prior changes (for decision-maker context)

## Step 1: Reset Flask Repo

Run: `git -C C:/Users/donid/ClaudeProjects/MockTestTarget checkout .`

This ensures a clean codebase for each simulation.

## Step 2: Run Simulator

Spawn an Agent subagent (Opus) with this structure:

**Simulator prompt must include:**
- The full persona definition for this cycle's personality (copy from personas.md)
- Which stage and recipe to test
- Which edge cases to force and when
- Instructions to read ALL relevant teaching scripts from `C:\Users\donid\ClaudeProjects\RILGoose\teaching\`
- Instructions to read `C:\Users\donid\ClaudeProjects\RILGoose\teaching\meta\teacher-instructions.md`
- Instructions to do REAL code operations on `C:\Users\donid\ClaudeProjects\MockTestTarget`
- The facilitator follows scripts exactly; the mock developer follows the persona
- For the mock developer: spawn a HAIKU subagent (model: haiku) at each Check/interaction point to generate the developer's response, passing it the persona definition and conversation context so far
- Output: a complete labeled transcript (FACILITATOR / MOCK DEV turns) plus simulation notes
- Write the transcript to `C:\Users\donid\ClaudeProjects\RILGoose\ideas\overnight-pipeline\transcripts\cycle-{N}.md`

**CRITICAL subagent tool rules (include in prompt):**
> - NEVER use compound commands (&&, ||, ;, |). One command per Bash call.
> - NEVER use cd dir && command. Use absolute paths or git -C instead.
> - NEVER use grep, find, cat, head, tail via Bash. Use Read/Grep/Glob tools.
> - Use forward slashes in paths even on Windows.

## Step 3: Run Evaluators (parallel)

Launch TWO evaluators simultaneously:

**Evaluator 1 (Opus Agent subagent):**
- Read the transcript at `ideas/overnight-pipeline/transcripts/cycle-{N}.md`
- Read the teaching scripts that were tested
- Read `teaching/meta/teacher-instructions.md`
- If current_cycle > 4, include: "These issues have ALREADY been found and fixed: {list from state.json eval_known_issues}. Focus on NEW issues not in this list."
- Score: Script Faithfulness, Fourth-Wall, Mock Dev Realism, Pedagogy, Pacing, Stuck-Paths, Enterprise (1-5 each)
- Output top 3 strengths, top 3 weaknesses, specific fixes needed
- Write to `ideas/overnight-pipeline/evaluations/cycle-{N}-opus.md`

**Evaluator 2 (Codex via script):**
- Write prompt to `C:\Users\donid\ClaudeProjects\RILGoose\.codex_prompt_tmp.md`
- Run: `python C:/Users/donid/ClaudeProjects/AgenticSystem/codex_review.py --project-dir C:/Users/donid/ClaudeProjects/RILGoose --prompt-file C:/Users/donid/ClaudeProjects/RILGoose/.codex_prompt_tmp.md --timeout 300`
- If Codex fails (exit code != 0 or nonsense output): log "Codex unavailable" and proceed with Opus eval only
- If Codex succeeds: save output to `ideas/overnight-pipeline/evaluations/cycle-{N}-codex.md`
- Clean up `.codex_prompt_tmp.md` after

## Step 4: Decision-Maker

Spawn an Agent subagent (Opus) that:

1. Reads BOTH eval reports (or just Opus if Codex failed)
2. Reads the full changelog (`ideas/overnight-pipeline/changelog.md`)
3. Reads state.json for `eval_known_issues` and `bucket_b_recurring`

**For each finding, classify:**

**Bucket A (apply now)** — ONLY if ALL of these are true:
- It's a script bug, fourth-wall break, factual error, or dead-end path
- It does NOT contradict any previous fix in the changelog
- The fix is unambiguous (one clear correct change)

**Bucket B (log only)** — Everything else:
- Tone/voice suggestions
- Alternative phrasings
- Structural changes
- Single-cycle-only evidence
- Anything that might help one personality but hurt another

**For Bucket A fixes:** Apply them using the Edit tool. Then:
- Run `git -C C:/Users/donid/ClaudeProjects/RILGoose add teaching/`
- Run `git -C C:/Users/donid/ClaudeProjects/RILGoose commit -m "Cycle {N}: {brief description of fixes}"`

**For recurring Bucket B items:** Check `bucket_b_recurring` in state.json. If the same finding has appeared 3+ times, promote to Bucket A.

**Quality gate (regression cycles only):** If this is a regression cycle (cycle 7 or 10), compare eval scores with the original cycle's scores. If any dimension dropped by 2+ points, revert:
- Run `git -C C:/Users/donid/ClaudeProjects/RILGoose revert HEAD`
- Log the revert in the changelog

**Append ALL findings to the changelog** with the before/after/why/confidence format.

**Output:** Return a JSON summary: `{applied: [...], proposed: [...], reverted: bool}`

## Step 5: Planner

Spawn an Agent subagent (Opus) that:

1. Reads state.json (full history)
2. Reads the cycle-plan.md default sequence
3. Reads the latest eval reports
4. Reads the changelog

**Designs the next cycle:**
- Which personality (from personas.md) — never same as this cycle
- Which stage/recipe — follow cycle-plan.md unless overriding
- Which edge cases to force (at least 1)
- One-sentence rationale

**Override rules:**
- If a critical script bug was found: insert a regression cycle next
- If no new findings for 2 consecutive cycles: shift to untested edge cases
- If Codex failed 3+ times: remove Codex from remaining cycles

**Output:** The `next_planned` object for state.json

## Step 6: Update State

Update state.json with:
- Increment `current_cycle`
- Add this cycle to `completed_cycles`
- Update `personalities_tested`, `stages_tested`, `edge_cases_tested`
- Update `eval_known_issues` with newly found issues
- Update `bucket_b_recurring` counts
- Set `next_planned` from planner output
- Write atomically: write to `state.json.tmp`, then rename to `state.json`

## Step 7: Morning Brief (every 5 cycles + cycle 12)

If `current_cycle` is 5, 10, or 12:

Spawn an Agent subagent (Opus) that reads ALL eval reports and the changelog, then writes `morning-brief.md` with:

1. **Status line:** "Cycle X of 12 complete. Y fixes applied, Z proposed."
2. **What changed** (Bucket A): each fix with before/after in plain English, confidence level
3. **What needs your decision** (top 5 Bucket B items, deduplicated, ranked by impact)
4. **Quality trend:** are scripts getting better or drifting?
5. **Personality coverage:** which archetypes tested, which remain
6. **One-paragraph assessment:** is this ready for a real developer pilot?

## Step 8: Schedule Next Wake

If `current_cycle` < 12 and `status` != "complete":
Schedule next wake with 270-second delay (stays in prompt cache window).

If `current_cycle` >= 12 or `status` == "complete":
Do NOT schedule another wake. The pipeline is done.
