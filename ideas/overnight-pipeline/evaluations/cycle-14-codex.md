# Cycle 14 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 14
**Type:** Regression
**Baseline:** Cycle 1
**Stage:** 0 (See What AI Can Do)
**Recipe:** All 5 acts
**Persona:** Priya (eager/over-accepting)
**Mock dev model:** GPT 5.4
**Date:** 2026-04-13

---

## Critical Findings First

Cycle 14 passes the regression gate. No dimension drops by 2+ points, and I do not recommend a revert.

I am more conservative than the Opus eval on script faithfulness. The current Act 1 script tells the helper to pick a file with meaningful logic, "not a config file, not a test." Cycle 14 picks `src/flask/config.py` for the facilitator's initial demonstration. In Flask, this file is real framework logic, not an application config file, but the literal filename and module purpose still violate the script's guardrail. That keeps Script Faithfulness at 4/5 rather than improving to 5/5.

The main result is stability, not a major improvement. The Cycle 1 regressions that were actually fixed are working: missing `team_context.md` fallback now triggers cleanly, the Act 3 git shortcut does not falsely trigger, and the transcript no longer injects inline "edge case triggered" notes into the main session. The carried-forward weaknesses remain: Priya is still too compliant, Act 2 still accepts approval without review verification, Act 3 is still facilitator-demo-only, and enterprise readiness remains mostly untested.

---

## Regression Score Comparison

| Dimension | Cycle 1 Baseline | Cycle 14 Score | Delta | Status | Evidence |
|---|---:|---:|---:|---|---|
| Script Faithfulness | 4/5 | 4/5 | 0 | Same | Fallback and shortcut fixes work, all five acts complete, and Act 4/Act 5 branches execute. Deduction: Act 1 demonstration chooses `src/flask/config.py` despite the script's "not a config file" selection rule. Intermediate state writes are also not visible in the transcript. |
| Fourth-Wall Discipline | 5/5 | 5/5 | 0 | Same | Facilitator dialogue does not mention evals, ratings, teaching scripts, progression, or system architecture. Simulation notes are clearly separated metadata, and Cycle 14 avoids Cycle 1's inline edge-case annotations. |
| Mock Dev Realism | 3/5 | 3/5 | 0 | Same | Priya stays on-persona as eager and over-accepting, but still behaves like a yes-machine. Realistic touches improve slightly: she misdiagnoses the Act 4 bug as a crash and gives an off-target Act 5 instruction using `message`, but she asks no workflow, process, IDE, PR, or team questions. |
| Pedagogy | 4/5 | 4/5 | 0 | Same | The five core lessons land: code reading, propose/approve/edit, git undo, AI fallibility, and prompt specificity. The Act 4 silent-failure bug is a stronger real-world example than Cycle 1's empty-string indexing crash. Deductions remain: Act 2 does not verify that Priya reviewed the change, and Act 3 never makes her run the git commands herself. |
| Pacing | 4/5 | 4/5 | 0 | Same | The session flows cleanly through all acts with useful wait-time insights. Reusing `config.py` gives continuity, but Act 4 requires a full reveal after Priya's wrong "crash" answer, and Act 5's wrong-parameter detour adds a little friction. Neither is a regression. |
| Stuck-Path Handling | 4/5 | 4/5 | 0 | Same | The Act 4 hint ladder handles accepts-without-checking correctly: general nudge, specific condition, then full reveal. Act 5 gracefully translates Priya's wrong-function-parameter instruction. The persistent gap is Act 2, where over-acceptance still goes unchallenged. |
| Enterprise Readiness | 3/5 | 3/5 | 0 | Same | No enterprise path is triggered. The facilitator correctly avoids volunteering enterprise context to an eager developer, but the mock persona never asks about CI, code review, team visibility, security, IDE integration, or audit flow. This remains untested rather than improved. |
| **Total** | **27/35** | **27/35** | **0** | **Same** | Stable regression result. |

---

## Top 3 Improvements

1. **Missing `team_context.md` fallback now works in the live scenario.** Cycle 1 had to simulate around a missing project context file. Cycle 14 explicitly shows the fallback scanning project metadata in Acts 1 and 2, and the Act 4 delegation also has the fallback path. This fixes a real script dead-end.

2. **The Act 3 adaptive shortcut is now precise enough to avoid a false skip.** The current script requires demonstrated git comprehension, not just a stray git term. Priya does not show that comprehension in Acts 1-2, so the full undo walkthrough runs. That is the right result for this persona.

3. **Act 5 handles a specific-but-off-target instruction better than Cycle 1 tested.** Priya says to raise `TypeError` for `message` in a function that does not take `message`. The facilitator does not embarrass her or blindly apply the wrong instruction. It translates the intent to the rate-limit-key context and proceeds. That is a useful robustness gain.

---

## Regressions

No revert-level regressions detected.

There is one small script-faithfulness regression risk to track: Act 1's first demonstration picked `src/flask/config.py` despite the script saying the selected file should not be a config file. This does not drop the dimension below baseline because Cycle 1 also had script-faithfulness issues, and the selected file still contains real framework logic. But it is worth tightening in the simulator or facilitator implementation so future runs respect the file-selection constraint literally.

---

## Carried-Forward Gaps

1. **Act 2 review verification is still absent.** Priya approves and confirms she sees the change, but the facilitator never asks what the change actually did.

2. **Act 3 is still passive.** The facilitator demonstrates `git diff` and `git checkout`; Priya never runs the commands.

3. **Priya still asks no enterprise or workflow questions.** This keeps enterprise readiness at 3/5 and makes the prepared enterprise-response paths untested in Stage 0.

4. **Mock dev realism remains capped.** The Act 4 and Act 5 mistakes are more realistic than Cycle 1, but the overall response pattern remains compliant and low-curiosity.

---

## Revert Recommendation

**No revert.** No dimension dropped by 2+ points. No dimension dropped at all against the provided Cycle 1 baseline. The regression test is stable at **27/35**, with the main applied fixes verified and remaining weaknesses carried forward as existing Bucket B items rather than new breakage.
