# Cycle 12 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 12
**Stage:** 4 (From Idea to Buildable Spec)
**Recipe:** Spec to Pipeline
**Persona:** Deepak (hostile/resistant, 30, 5 years backend experience)
**Edge case:** E7 - compares to Copilot
**Mock dev model:** GPT 5.4

---

## Critical Findings First

Cycle 12 has a strong opening and a credible E7 moment. Deepak's Copilot objection lands naturally, and the facilitator handles it well by conceding that Copilot can write plausible code, then shifting the argument to hidden decisions and verifiability. The spec agent finding window-boundary and header gaps gives the session real evidence for the spec-to-pipeline approach.

The biggest problem is not just that Phase 1 is skipped. The bigger operational miss is that the session catches a weak coverage trace, names it correctly, and still hands the plan to the build agent without repairing the trace. Deepak sees that REQ-1 says "all blog endpoints" while the test only hits the index route. The facilitator acknowledges the catch, offers two possible fixes, then proceeds. The review agent later flags the same REQ-1 weakness. That undercuts the core lesson: a coverage matrix is only useful if a weak trace blocks handoff until it is fixed.

The second major issue is that test specificity is under-tested. The script asks the developer to classify three acceptance criteria by test level and give setup, action, and expected result before delegation. Instead, the generated pipeline creates the test shapes. Deepak mostly accepts them, so the transcript cannot prove he has the 4.4 testability skill independently.

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 3/5 | The opening framing and later matrix/plan checkpoints match the script closely. However, the setup does not ask for an existing decomposed or reviewed spec, Phase 1's preflight testability check is skipped entirely, and the weak REQ-1 trace is not fixed before build handoff even though the script says not to hand off until every requirement traces cleanly. |
| Fourth-Wall Discipline | 5/5 | The developer-facing transcript does not mention evals, ratings, scripts, progression, or the teaching system. The `=== SIMULATION NOTES ===` section contains internal metadata, but it is separated from the transcript and does not leak into facilitator dialogue. |
| Mock Dev Realism | 4/5 | Deepak's initial resistance is credible: short answers, a concrete Copilot challenge, grudging concession after the spec agent catches gaps, and an attempted skip with "Fine. Next." The final third becomes too cooperative: he reviews dependencies cleanly, accepts build-readiness, and loses most of the hostile persona. |
| Pedagogy | 3/5 | The E7 explanation and matrix-inspection prompt are strong. The deduction is severe because the session teaches "inspect the matrix" but not "repair the matrix before build." Deepak catches the weak REQ-1 trace, yet the build proceeds and the review agent repeats the same finding. |
| Pacing | 4/5 | The session moves briskly and the Copilot objection is handled without derailing. The middle gap-resolution section is thin, and the final coaching is too long for a hostile developer, but the flow is mostly readable. |
| Stuck-Path Handling (E7) | 4/5 | The initial Copilot response is concrete and non-defensive: "Copilot makes those decisions silently. A spec makes them visible." The weakness is that E7 is not carried forward at the strongest evidence point: the REQ-1 trace gap should have been used as a callback to show what prompt-to-code would miss. |
| Enterprise Readiness | 3/5 | Rate limiting, API-key/IP fallback, headers, and coverage matrices are enterprise-relevant. The session still lacks enterprise workflow grounding: existing test conventions, CI placement, spec ownership, security/SRE review, and where the coverage matrix would live. It also shows build work without an actual test execution result. |

**Overall: 26/35.** Strong competitor-objection handling, but the core spec-to-pipeline contract is weakened by proceeding after a known weak trace.

---

## Top 3 Strengths

1. **The Copilot objection is handled with credibility.**

   The facilitator does not pretend Copilot is useless. It says Copilot would write a rate limiter, then names what the prompt leaves unresolved: window algorithm, boundary behavior, key/IP identity, and hidden decisions. That is the right response to a hostile developer because it argues from verifiability, not tool loyalty.

2. **The spec agent gaps are realistic and useful.**

   GAP-1 window boundary, GAP-2 fixed-window burst behavior, GAP-3 rate-limit headers, and GAP-4 vague performance are exactly the kinds of issues a backend developer would recognize. They are not toy problems, and they give Deepak a concrete reason to concede "that's not nothing."

3. **The matrix checkpoint forces real inspection.**

   When Deepak says "Fine. Next.", the facilitator does not let him skip. It asks him to inspect REQ-1 and he identifies the mismatch: one index-route test does not prove all four blog endpoints are rate-limited. That is the best teaching moment in the transcript.

---

## Top 3 Weaknesses

1. **The session proceeds to build after a known weak trace.**

   Deepak correctly says REQ-1 needs tests for create, update, and delete, or a decorator-presence assertion. The facilitator says "That is the right catch," but does not revise the coverage matrix, skeleton tests, or implementation plan. It then asks whether the plan is build-ready, and the build proceeds. The review agent later says the same thing: "REQ-1 test coverage is narrow." This turns the checkpoint into a comment instead of a gate.

2. **Phase 1 preflight testability is skipped.**

   The script explicitly asks the developer to pick three acceptance criteria and state test level, setup, action, and expected result. The transcript asks for five requirements and "how a test would prove it works," then delegates. That softer prompt never proves Deepak can choose unit vs integration vs e2e, identify manual checks, or write executable test shapes himself.

3. **The hostile/E7 behavior fades instead of compounding.**

   Deepak's Copilot skepticism is realistic early, but after the matrix catch he becomes cleanly cooperative. He also never re-raises the Copilot comparison. A hostile developer would likely challenge the overhead again after seeing the matrix or after the build result: "So I still need to review all this manually?" The session misses a chance to use the later evidence to make the E7 argument stronger.

---

## Specific Fixes Needed

1. **Add a hard repair step after weak matrix traces in `spec-to-pipeline.teach.md`.**

   Suggested instruction under Phase 2:

   > If the developer finds a weak trace, do not proceed to the execution plan yet. Ask them to choose the repair: add a stronger test, split the requirement, or mark a manual gate. Delegate a narrow matrix/test-spec revision, then re-present only the changed trace and ask whether it now proves the requirement.

2. **Restore the Phase 1 preflight prompt.**

   Before any spec-agent delegation, ask:

   > Pick three acceptance criteria. For each one: test level, setup, action, expected result.

   If the developer resists, scale down to one criterion instead of skipping:

   > Just one. Pick the rate threshold. What exact test proves it works?

3. **Add an E7 callback after the matrix catch.**

   Suggested facilitator line:

   > This is the concrete difference from prompt-to-code: a prompt can produce plausible code, but the matrix gave you a place to see that "all blog endpoints" only had one endpoint behind it.

4. **Tighten the final coaching.**

   Replace the multi-paragraph debrief with three sentences: one specific behavior, one sharpening note, one bridge. For example:

   > You checked the matrix instead of trusting it, and that exposed the REQ-1 gap. Next time, stop there and repair the trace before build, because a build agent will execute the plan exactly as written. The next step is the spec quality gate: review the spec before build and define when the project should stop.

5. **Add one enterprise grounding question before handoff.**

   Suggested line:

   > Where would this coverage matrix live for your team: in the spec PR, the test plan, or the CI artifact?

   Keep it to one question unless the developer asks for workflow design.

---

## Notes

I am not counting the separated simulation notes as a fourth-wall failure. The developer transcript is clean.

The simulated rating of `pipeline_readiness = Strong` is too generous. Deepak checks task order and dependencies, but only after a known traceability defect is left unresolved. I would rate pipeline readiness as Adequate at best for this run, because the plan looked orderly while still carrying the REQ-1 coverage defect into build and review.
