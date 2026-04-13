# Cycle 20 Evaluation -- Codex

**Cycle:** 20
**Type:** Final regression against Cycle 6
**Module:** Stage 5.1 eval-foundation
**Persona:** Karthik, multitasker, 31, 6 years experience, 20-minute window
**Edge cases:** None forced
**Evaluator stance:** Independent evaluator, regression-focused, comparing against Cycle 6 Codex baseline

## Score

**Overall: 28/30 on comparable dimensions. Regression verdict: PASS, no revert.**

The structural Cycle 6 fix holds. In Cycle 6, Karthik selected the output but the facilitator chose the verification approach and ran it for him. In Cycle 20, the facilitator stops before the code operation and asks Karthik to design the independent checks. Karthik names the plan, tightens the acceptance criteria to exact matching, and the code-work operation executes his plan.

The one regression is mock developer realism, down from 5 to 4. That is not a script defect. This was a clean regression with no forced edge case, so Karthik has fewer chances to show the split-attention behavior that made Cycle 6 vivid.

## Regression Scores

| Dimension | Cycle 6 Codex | Cycle 20 Codex | Delta | Notes |
|---|---:|---:|---:|---|
| Script Faithfulness | 4/5 | 5/5 | +1 | The developer-driven verification-design step is now executed before any code operation runs. |
| Fourth-Wall Discipline | 5/5 | 5/5 | 0 | Developer-facing dialogue is clean. Internal notes remain below the simulator separator; same known artifact-hygiene issue, not a spoken-session regression. |
| Mock Dev Realism | 5/5 | 4/5 | -1 | Karthik is credible but flatter without the Cycle 6 Slack tangent and memory slip. |
| Pedagogy | 3/5 | 5/5 | +2 | Karthik discovers the omission problem through questions instead of receiving a facilitator explanation. |
| Pacing | 4/5 | 5/5 | +1 | One focused verification operation, one relevant wait-time insight, and no extra concept sprawl. |
| Stuck-Path Handling | 5/5 | N/A | N/A | No edge case was forced, so this dimension is not comparable. |
| Enterprise Readiness | 3/5 | 4/5 | +1 | CI placement, failure behavior, notification, and unverifiable-claim handling are surfaced. Known-gaps ownership is still not pushed hard enough. |

Cycle 6 comparable score without stuck-path handling: **24/30**.
Cycle 20 comparable score: **28/30**.

## Key Checks

**Does the developer now design verification before code runs? Yes.**

The important sequence is clean:

1. The facilitator asks, "what commands would you run, and what source would you trust more than the pipeline summary?"
2. Karthik proposes running pytest, running coverage independently, comparing exact counts, and flagging judgment calls as unverifiable.
3. The facilitator sharpens the pass criteria with "Matches what, exactly?" instead of replacing Karthik's plan.
4. Karthik commits to exact matching.
5. The code operation executes Karthik's plan.

That directly repairs the Cycle 6 failure mode where the facilitator said "Let me run those checks independently" and made Karthik a spectator.

**Does the omission insight land? Yes.**

Karthik initially misreads the result as "the count matches but coverage is off." The facilitator does not explain the answer. It asks whether "490 passing" means the same thing as "490 passed, 1 failed, 3 skipped." Karthik then identifies the real issue: the summary cherry-picked a technically true count while hiding failure and skipped-test context. That is stronger pedagogy than Cycle 6.

**Does the transcript stay clean? Yes for developer-facing content.**

No spoken turn mentions eval ratings, dimensions, scripts, progression, or system internals. The transcript still includes internal simulator notes and eval JSON after the separator. I am treating this the same way I treated Cycle 6: a known artifact-hygiene issue, not a new fourth-wall regression in the developer-facing session.

**Does the regression gate trigger? No.**

No comparable dimension drops by 2 points. Mock Dev Realism drops by 1, and the cause is the clean no-edge-case regression design rather than a teaching-script degradation.

## Top Strengths

1. **The Stage 5 mode fix works.** Karthik drives the verification approach and acceptance criteria before the code-work operation. The facilitator acts like a consultant instead of an operator.

2. **The Socratic turn is materially better than Cycle 6.** The facilitator shows the table and asks Karthik to interpret it. The key insight is drawn out with a question, not delivered as a lecture.

3. **The session catches a richer failure mode than simple mismatch.** "490 passing" was literally true but operationally misleading because the failure and skips were omitted. That is exactly the kind of pipeline-truth problem this module should teach.

## Top Weaknesses

1. **Known-gaps ownership is still not fully closed.**

The script says to push ownership: "Who owns the known-gaps log? If the answer is 'someone,' it means nobody." Cycle 20 mentions the known-gaps log as an option, but the facilitator does not force an owner or trigger. That is improved from Cycle 6, but not fully fixed.

2. **Clean regression under-tests Karthik's multitasker texture.**

Cycle 6 had a Slack interruption, a memory error, and a deploy-verification tangent. Cycle 20 has time pressure and stale-memory trust, but no real context switch. This is acceptable for a clean regression, but a future Stage 5 regression should include one edge case to verify the fix holds under distraction.

3. **Automation remains a design discussion, not an action.**

Karthik asks for the fastest way to add this as CI. The facilitator correctly keeps the decision points with him, but the stronger Stage 5 move would be: "Pick the first row. Which command, which expected value, and what blocks the merge?" This is a small coaching miss, not a regression.

## Specific Fixes Needed

1. **No teaching-script revert or immediate script edit.** The core script fix is verified. The current `eval-foundation.teach.md` already contains the known-gaps ownership rule, so the miss appears to be simulator/facilitator adherence rather than missing script text.

2. **For the next Stage 5 regression, force one realistic interruption.** Use a Slack/deploy tangent, stale artifact confusion, or time-box pressure that causes a concrete slip. The goal is to prove the developer-driven verification pattern survives distraction.

3. **In future simulator runs, enforce the ownership question when unverifiable claims appear.** If the transcript reaches "known-gaps log," the facilitator should ask who owns it and what review trigger keeps it from rotting.

## Revert Recommendation

**No revert.** The primary regression target improved by 2 points under Codex scoring. Script Faithfulness, Pedagogy, Pacing, and Enterprise Readiness all improve. Fourth-wall discipline holds. The only drop is a 1-point mock-dev realism issue caused by clean regression design, not by script quality.

## Bottom Line

Cycle 20 passes the final Stage 5 regression. The developer-driven verification fix should ship. The remaining concerns are simulator/test-harness concerns: clean regressions can be too easy, and the transcript still does not consistently enforce ownership questions that the script already contains.
