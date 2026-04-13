# Cycle 10 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 10
**Stage:** 2 (Two AIs Are Better Than One)
**Recipe:** Spec First
**Persona:** Priya (eager/over-accepting, 26, 3 years experience)
**Edge case:** E9 - accepts without checking
**Mock dev model:** GPT 5.4

---

## Critical Findings First

Cycle 10 is a strong spec-first demonstration. Priya writes acceptance criteria before code, most criteria are testable, the tests fail before implementation, and the deliberate cache-invalidation miss gives the facilitator a clean E9 moment. The key teaching point lands: the spec is not just an input to the builder; it is the checklist for accepting or rejecting the result.

The main weakness is that the session stops after identifying the failing criterion. Priya learns that "cache invalidation" is the unmet criterion, but the workflow never sends the builder back to fix it and rerun the same six tests. For a spec-first module, ending with 5/6 tests passing risks teaching that recognizing a failed contract is enough. The real pattern is: identify the unmet criterion, reject the build, patch only that gap, and rerun until the acceptance suite is green.

The second issue is a missing Stage 2 completion checkpoint. The script says the checkpoint after 2.4 should review the Stage 2 arc: build-test separation, role separation, review gates, and spec-first. The transcript jumps from concept coaching directly into the Stage 3 bridge. It mentions some Stage 2 ideas in the bridge, but does not explicitly check whether Priya understands the full stage before advancing.

The third issue is script infrastructure: `spec-first.teach.md` has no module-specific `## Wait-Time Insights` section even though `teacher-instructions.md` requires ordered insights for subagent waits. The facilitator improvised one useful insight during the build wait, but the tested script lacks the reusable list that earlier cycles added to other modules.

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 4/5 | The facilitator follows the core script: frames "define success before building," asks for acceptance criteria before delegation, sharpens a vague performance criterion, writes tests first, presents 5/6 passing, and bridges to Stage 3. Deductions: the Stage 2 completion checkpoint is compressed into the bridge, and the script's expected build cycle stops with a failing criterion unresolved. |
| Fourth-Wall Discipline | 5/5 | The developer-facing conversation contains no references to evals, quality ratings, scripts, progression, or teaching architecture. The simulation notes still contain internal eval metadata, but that is a known transcript-artifact issue and is separated after `=== SIMULATION NOTES ===`. |
| Mock Dev Realism | 4/5 | Priya's eager feature choice and premature approval are plausible for the over-accepting persona. The main realism break is after redirection: she says she does not see anything "in the diff" even though the transcript only shows test output, not a diff. Her corrected response is also a bit more polished than a first-pass E9 recovery would likely be. |
| Pedagogy (Spec-First / E9) | 4/5 | The spec-first lesson is strong: criteria before code, tests fail first, implementation checked against the criteria, and the E9 acceptance mistake is caught cleanly. The weakness is that the facilitator explains the miss instead of making Priya drive the reject-and-repair step. |
| Pacing | 4/5 | The session is concise and mostly well paced. The coaching after E9 becomes a little speech-like, and there is only one wait-time insight across two code operations because the module lacks its own insight list. |
| Stuck-Path Handling (E9) | 4/5 | The edge case is triggered exactly: Priya approves a 5/6 passing build. The facilitator responds well by saying "Hold on" and asking which criterion is not met. The missing next step is operational: after Priya identifies the failed criterion, the session should repair and rerun before advancing. |
| Enterprise Readiness | 3/5 | The criteria include enterprise-relevant concerns: user permissions, graceful degradation, and not breaking existing routes. But the session never asks how this would enter CI, PR review, team ownership, or production cache architecture. It also treats an in-memory per-user cache as sufficient for a dashboard API without clarifying that this is a local tutorial implementation, not a production pattern. |

**Overall: 28/35.** Strong concept demonstration and a useful E9 moment. The main fix is to complete the contract loop: failed criterion -> developer rejection -> targeted repair -> rerun -> then bridge.

---

## Top 3 Strengths

1. **The acceptance criteria are genuinely usable.**

   Priya defines the feature in her own domain terms: same JSON shape, 5-minute cache hit, invalidation on underlying updates, per-user isolation, graceful degradation, and no regression to existing routes. The facilitator correctly spots that "fast and not slow down" is vague and pushes it into a testable non-regression criterion.

2. **The tests-first ordering is visible and concrete.**

   The transcript says all six tests fail before implementation because `/dashboard/summary` does not exist. That is exactly the proof this module is supposed to teach: the tests are not rubber stamps written after the code. They encode the contract before the builder starts.

3. **The E9 intervention is direct and effective.**

   Priya says the build "matches the spec perfectly" even though one test failed. The facilitator does not lecture about over-trusting AI. It points to the evidence and asks, "Which criterion is not met?" That is the right stuck-path move for an over-accepting developer because it forces criterion-by-criterion checking.

---

## Top 3 Weaknesses

1. **The workflow ends with a known failing acceptance criterion.**

   The transcript identifies `test_cache_invalidated_on_post_update` as failing, and Priya identifies the missing invalidation logic after prompting. Then the facilitator explains the lesson and bridges forward. It never asks Priya to reject the build, never delegates a targeted repair, and never reruns the six tests. That is the biggest gap because "spec as contract" should end with the contract satisfied or explicitly blocked.

2. **The Stage 2 completion checkpoint is not explicit enough.**

   `spec-first.teach.md` calls this the Stage 2 completion checkpoint and says to review all of Stage 2 before the bridge. The transcript gives a bridge that mentions "two agents" and "separation, independence, execution verification, spec-first," but it does not do the checkpoint job: read the state, identify any weak Stage 2 areas, and confirm readiness before advancing.

3. **`spec-first.teach.md` is missing module-specific wait-time insights.**

   The facilitator says one useful line during the build wait: "the spec you wrote is doing something important. It's a contract." But there is no `## Wait-Time Insights` section in the script, so future runs will depend on improvisation. This is the same class of script gap that earlier cycles fixed in other modules.

---

## Specific Fixes Needed

1. **Add a reject-and-repair branch to `spec-first.teach.md` for failed tests.**

   Suggested addition under the "If some tests fail" result path:

   > Ask the developer to name the unmet criterion and explicitly reject the build as incomplete. Then delegate a narrow repair: "Fix only the failing criterion: [criterion]. Do not broaden scope. Rerun the full acceptance suite." Present the rerun result before any coaching or bridge. If the same test still fails twice, stop and treat it as an implementation stuck path.

2. **Add an E9-specific response guard.**

   Suggested note:

   > If the developer approves a build while any acceptance test is failing, do not explain the answer first. Point to the failing evidence and ask: "Which acceptance criterion is not met?" After they answer, ask: "Would you approve this as done?" The developer must practice rejecting incomplete work.

3. **Make the Stage 2 completion checkpoint non-optional.**

   Add a short instruction before the Stage 3 bridge:

   > Before bridging, summarize the four Stage 2 capabilities and ask one checkpoint question: "Which part would you rely on to stop a wrong-but-working implementation?" If any Stage 2 concept is Weak in state, revisit that concept before advancing.

4. **Add a `## Wait-Time Insights` section to `spec-first.teach.md`.**

   Include 4-6 ordered insights tagged around `[define-success]`, `[verify]`, `[feedback-loops]`, and `[enterprise]`. The first one should be close to the improvised transcript line: "The spec is a contract. The builder does not decide what done means anymore; your tests do."

5. **Tighten the mock developer prompt around evidence access.**

   Priya should not refer to reviewing a diff unless the transcript has shown one. A more realistic corrected response would be: "The failing test maps to the invalidation criterion. I would not approve this until that test passes."

6. **Add one enterprise grounding question after the repaired acceptance suite passes.**

   Suggested line:

   > "Where would this acceptance suite run for your team - local only, PR checks, or CI before deploy?"

   Keep it to one question unless the developer asks to design the workflow.

---

## Notes

I am not treating the separated simulation notes as a new fourth-wall failure. The developer-facing transcript is clean, and the metadata-after-separator pattern is already tracked as simulator artifact hygiene.

The simulated eval rating of `spec_as_contract = Weak` is correct for Priya's first response. After prompting, she improves to Adequate behavior. That is exactly why the session should have included one more operational step: make her reject the incomplete build and repair the failing criterion while the mistake is fresh.
