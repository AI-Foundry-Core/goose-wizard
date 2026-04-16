# Overnight Hardening Pipeline — Loop Prompt

This is the /loop prompt. Each tick executes one full cycle. ALL agent outputs are logged.

---

You are running an autonomous overnight hardening pipeline for the goose-wizard teaching system. Each tick of this loop runs one complete test cycle.

## Logging Rule (APPLIES TO EVERY STEP)

Every agent's full output must be saved to `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\logs\cycle-{N}-{step}.md`. Steps are:
- `simulator` — full simulator agent output
- `mock-dev-responses` — Codex mock dev responses (even cycles only)
- `eval-opus` — full Opus evaluator output
- `eval-codex` — full Codex evaluator output (or "FAILED: {reason}")
- `decision` — full decision-maker output (including reasoning for each Bucket A/B classification)
- `planner` — full planner output (including rationale for next cycle design)
- `summary` — morning brief agent output (cycles 7, 14, 20 only)

When spawning each Agent subagent, capture its returned result text and write it to the corresponding log file using the Write tool. For Codex calls, capture stdout and write it. This gives full debuggability in the morning.

## Step 0: Read State

Read `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\state.json`. Check `current_cycle` and `status`.

- If `status` is "complete" or `current_cycle` > 20: stop the loop (do not schedule another wake).
- If `status` is "ready": proceed with the cycle.
- If `status` is "error": read the error, try to recover, or stop the loop.

Read the `next_planned` field for this cycle's personality, stage, recipe, mock_dev_model, and edge cases.

Also read:
- `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\cycle-plan.md` — the default sequence
- `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\personas.md` — persona definitions
- `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\edge-cases.md` — edge case library
- `<PROJECTS>\goose-wizard\ideas\overnight-pipeline\changelog.md` — prior changes

## Step 1: Reset Flask Repo

Run: `git -C C:/Users/donid/ClaudeProjects/MockTestTarget checkout .`

This ensures a clean codebase for each simulation.

## Step 2: Run Simulator

Spawn an Agent subagent (Opus) with this structure:

**Simulator prompt must include:**
- The full persona definition for this cycle's personality (copy from personas.md)
- Which stage and recipe to test
- Which edge cases to force and when
- Instructions to read ALL relevant teaching scripts from `<PROJECTS>\goose-wizard\teaching\`
- For Stage 0: read all 5 act scripts in `teaching/stage-0/`
- For Stage 1-7: read the specific recipe's `.teach.md` in the appropriate stage directory
- Instructions to read `<PROJECTS>\goose-wizard\teaching\meta\teacher-instructions.md`
- Instructions to do REAL code operations on `<PROJECTS>\MockTestTarget`
- The facilitator follows scripts exactly; the mock developer follows the persona

**Stage progression context (CRITICAL for Stages 2-7):**
Before the simulation begins, the simulator must set up the context as if the developer has completed all prior stages. Include in the simulator prompt:
- "The developer has completed Stages 0 through {N-1}. They understand: {list key concepts from prior stages relevant to this recipe}."
- Pre-seed `.goose/state/progression.json` at `<PROJECTS>\MockTestTarget` with completed status for all concepts in stages 0 through N-1.
- For Stages 5-7 (fully adaptive): tell the mock developer persona "You drive the conversation. Ask YOUR questions. Don't wait to be guided. You have built pipelines, written specs, and designed evals before."

**Mock developer mistake realism (CRITICAL for Stages 3-7):**
The mock developer persona prompt must include stage-specific mistake instructions:
- Stage 3: "Design a pipeline with at least one flaw — roles that overlap, missing handoff contracts, or no escalation path. Don't make it obviously wrong."
- Stage 4: "Write specs that are partially vague — some requirements are testable, others aren't. Mix strong sections with weak ones."
- Stage 5: "Design evals that partially work — some criteria are measurable, others are 'check quality' without specifics."
- Stage 6: "Miss something in the cycle review — overlook a stale state file, misread a trend, or accept a success signal without checking what ran."
- Stage 7: "Propose a rule change without measuring the before/after impact. Show the common mistake of optimizing by intuition."

**Mock developer model depends on cycle number:**
- **Odd cycles — Haiku:** Spawn a HAIKU subagent (model: haiku) at each Check/interaction point to generate the developer's response, passing it the persona definition and conversation context so far
- **Even cycles — GPT 5.4:** BEFORE starting the simulation, generate all mock developer responses upfront via Codex:
  1. Write prompt to `.codex_mock_dev.md` with: full persona definition, teaching script structure with all Check points, edge cases to force
  2. Run: `python C:/Users/donid/ClaudeProjects/AgenticSystem/codex_review.py --project-dir C:/Users/donid/ClaudeProjects/goose-wizard --prompt-file C:/Users/donid/ClaudeProjects/goose-wizard/.codex_mock_dev.md --timeout 300`
  3. Save Codex output to `logs/cycle-{N}-mock-dev-responses.md`
  4. Parse responses and use them at each Check point during simulation
  5. Clean up `.codex_mock_dev.md`
  6. If Codex fails: fall back to Haiku, increment `codex_failures` in state, log failure

**Output requirements:**
- Write complete labeled transcript to `ideas/overnight-pipeline/transcripts/cycle-{N}.md`
- Include: which mock dev model was used, which persona, which edge cases forced
- Format: `[FACILITATOR]:` and `[{PERSONA_NAME}]:` turns, with `>> CODE OPERATION:` blocks
- End with `=== SIMULATION NOTES ===` section

**Save the full simulator agent output** to `logs/cycle-{N}-simulator.md`

**CRITICAL subagent tool rules (include in every agent prompt):**
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
- Write eval to `ideas/overnight-pipeline/evaluations/cycle-{N}-opus.md`
- **Save full agent output** to `logs/cycle-{N}-eval-opus.md`

**Evaluator 2 (Codex via script):**
- Write prompt to `.codex_prompt_tmp.md`
- Run: `python C:/Users/donid/ClaudeProjects/AgenticSystem/codex_review.py --project-dir C:/Users/donid/ClaudeProjects/goose-wizard --prompt-file C:/Users/donid/ClaudeProjects/goose-wizard/.codex_prompt_tmp.md --timeout 300`
- **Save raw Codex output** to `logs/cycle-{N}-eval-codex.md`
- If Codex fails (exit code != 0 or nonsense output): write "FAILED: {reason}" to the log, increment `codex_failures`, proceed with Opus eval only
- If Codex succeeds: also save formatted version to `evaluations/cycle-{N}-codex.md`
- Clean up `.codex_prompt_tmp.md`

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

**Additional Bucket A criteria for Stages 5-7:**
- "Premature coaching" — facilitator intervenes when the developer is handling it (fully adaptive scripts should let the developer drive)
- "Phantom prerequisites" — script references concepts or artifacts that were never introduced in the simulated history
- "Mode mismatch" — facilitator behaves as guided-adaptive when the script specifies fully adaptive

**For Bucket A fixes:** Apply them using the Edit tool. Then:
- Run `git -C C:/Users/donid/ClaudeProjects/goose-wizard add teaching/`
- Run `git -C C:/Users/donid/ClaudeProjects/goose-wizard commit -m "Cycle {N}: {brief description of fixes}"`

**For recurring Bucket B items:** Check `bucket_b_recurring` in state.json. If the same finding has appeared 3+ times, promote to Bucket A.

**Quality gate (regression/validation cycles — cycles 14, 19, 20):** For recipes tested in a prior cycle, compare eval scores. If any dimension dropped by 2+ points, revert. For first-time-tested recipes, this is a "validation" cycle — establish the baseline score, no comparison possible. Note this in the changelog.
- Run `git -C C:/Users/donid/ClaudeProjects/goose-wizard revert HEAD`
- Log the revert in the changelog

**Append ALL findings to the changelog** with the before/after/why/confidence format.

**Output:** Return a JSON summary: `{applied: [...], proposed: [...], reverted: bool}`
**Save full agent output** to `logs/cycle-{N}-decision.md`

## Step 5: Planner

Spawn an Agent subagent (Opus) that:

1. Reads state.json (full history)
2. Reads the cycle-plan.md default sequence
3. Reads the latest eval reports
4. Reads the changelog

**Designs the next cycle:**
- Which personality (from personas.md) — never same as this cycle
- Which stage/recipe — follow cycle-plan.md unless overriding
- Which mock_dev_model — odd=haiku, even=gpt5.4 (unless Codex disabled)
- Which edge cases to force (at least 1)
- One-sentence rationale

**Override rules:**
- If a critical script bug was found: insert a regression cycle next
- If no new findings for 2 consecutive cycles: shift to untested recipes
- If Codex failed 3+ times: set all remaining mock_dev_model to "haiku"

**Output:** The `next_planned` object for state.json
**Save full agent output** to `logs/cycle-{N}-planner.md`

## Step 6: Update State

Update state.json with:
- Increment `current_cycle`
- Add this cycle to `completed_cycles` (include: personality, stage, recipe, mock_dev_model, edge_cases, changes_applied count, changes_proposed count, eval_scores summary, timestamp)
- Update `eval_known_issues` with newly found issues
- Update `bucket_b_recurring` counts
- Update `codex_failures` if applicable
- Set `next_planned` from planner output
- Write atomically: write to `state.json.tmp` first, then use Bash `mv` to rename to `state.json`

## Step 7: Morning Brief (cycles 7, 14, 20)

If `current_cycle` is 7, 14, or 20:

Spawn an Agent subagent (Opus) that reads ALL eval reports and the changelog, then writes `morning-brief.md` with:

1. **Status line:** "Cycle X of 20 complete. Y fixes applied, Z proposed."
2. **Stages 0-1 section (HIGH CONFIDENCE — Doni designed these):**
   - Fixes applied with before/after in plain English
   - Quality trend for these scripts specifically
   - Assessment: ready for pilot?
3. **Stages 2-7 section (EXPLORATORY — first-ever testing):**
   - Fixes applied with before/after in plain English
   - Note: these scripts were generated by prior sessions and never tested until now
   - Issues found are expected — this is discovery, not regression
4. **What needs your decision** (top 5 Bucket B items, deduplicated, ranked by impact)
5. **Stage coverage:** which stages tested, which recipes within each, which remain
6. **Personality coverage:** which archetypes tested, which remain
7. **One-paragraph assessment:** overall readiness and what to focus on next

**Save full agent output** to `logs/cycle-{N}-summary.md`

## Step 8: Schedule Next Wake

If `current_cycle` <= 20 and `status` != "complete":
Schedule next wake with 270-second delay (stays in prompt cache window).

If `current_cycle` > 20 or `status` == "complete":
Do NOT schedule another wake. The pipeline is done.
Write final status to state.json: `"status": "complete"`.
