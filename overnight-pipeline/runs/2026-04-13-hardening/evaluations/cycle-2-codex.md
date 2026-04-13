# Cycle 2 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 2
**Stage:** 1 (Get Real Work Done)
**Recipe:** Bug Fix
**Persona:** Vikram (senior/overconfident)
**Edge case:** E6 - wants to skip basics

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 3/5 | The facilitator follows the broad bug-fix arc, but after asking "Want to tackle this one?" it proceeds without Vikram accepting the found issue, and the code operation is handed an exact fix/diff instead of a normal `bug_description`-driven bug-fix delegation. |
| Fourth-Wall Discipline | 3/5 | The spoken facilitator dialogue mostly avoids eval language, but the transcript exposes `>> EVAL OPERATION`, raw eval JSON, ratings, dimensions, and "Session Complete" metadata that would be a clear fourth-wall break if developer-visible. |
| Mock Dev Realism | 4/5 | Vikram's payment-domain context, impatience with basics, and design-level diff review feel like a senior tech lead, though his later concession ("fair point") is slightly too cooperative for someone who pushed back twice. |
| Pedagogy | 3/5 | The skip challenge respects seniority, but the actual challenge is weak because Vikram does not drive the fix; he mostly watches a subagent receive an already-specified patch, then reviews it afterward. |
| Pacing | 4/5 | The session is tight for a senior developer, but duplicate diff presentation and an irrelevant "AI going in circles" wait-time insight slow down a clean one-pass fix. |
| Stuck-Path Handling | 4/5 | E6 is handled with the right "show me" challenge and non-defensive redirect, but "do the task with no guidance" is not honored because the facilitator still controls the bug selection, fix instruction, test run, and debrief. |
| Enterprise Readiness | 3/5 | Vikram brings realistic enterprise payment concerns, but the session pivots away from his actual problem to a Flask session-signing bug and never addresses how this would run against his real payments repo, PR flow, audit trail, or team process. |

**Overall: 3.4/5**

---

## Top 3 Strengths

1. **The initial skip response is strong.** Vikram says, "I've been debugging production payment issues for a decade. Can we skip the basics?" and the facilitator answers with "Show me. Do the next task with no guidance from me. If you nail it, we skip ahead." That is the right posture for a senior developer: respect the expertise, but require evidence.

2. **Vikram's verification behavior is realistic and useful.** He does not just say "looks good"; he asks why the fix uses a list literal instead of `insert(0, ...)` and checks the `SECRET_KEY_FALLBACKS` empty-list vs. `None` edge case. That is senior-level verification and should be treated as a first-class Strong example in the script.

3. **The codebase-mismatch pivot mostly works.** The facilitator acknowledges that Vikram's payment bug is real but unavailable in the Flask target, then finds a comparable wrong-source-of-state bug in session signing. The mapping to "same class of bug as your idempotency key issue" keeps the session from feeling completely disconnected.

---

## Top 3 Weaknesses

1. **The challenge assessment is not actually developer-driven.**

   Teacher-instructions.md says skip requests should be handled with: "Show me. Do the task once with no guidance. If the eval confirms you've got it, we skip ahead." The transcript uses the right challenge language, but the task that follows is not Vikram doing the work. The facilitator selects the substitute bug, explains the root cause, commands the fix, runs tests, launches eval, and then decides advancement. Vikram's only real action is reviewing the result after the patch is already specified.

   **Script/guide expectation:** "Lets the developer do the work. Observes silently" and "Do the task once with no guidance."
   **Transcript:** The facilitator says "Let me scan," "Let me run it," and gives the subagent the exact fix: "the current `app.secret_key` must be the first element in the `keys` list."

   **Fix needed:** Clarify in teacher-instructions.md that a skip challenge means "no coaching from me, but you drive the decisions." Then adjust bug-fix.teach.md so the facilitator asks the skip-requesting developer to state the next action: "What would you ask the agent to do next?" For a senior persona, passing the challenge should require them to direct the fix/verification, not merely review the result.

2. **The code-work handoff over-specifies the patch.**

   bug-fix.teach.md says to delegate the bug-fix sub-recipe with `bug_description`, `suspected_location`, and `prior_attempts`. In the transcript, the "CODE OPERATION" says exactly how to patch the code and includes the final before/after diff before the subagent result. That turns the code-work subagent from investigator/fixer into a patch applier, and it blurs the facilitator/code-work split in teacher-instructions.md Section 3.

   **Script expectation:** `sub-recipe: "bug-fix"` with developer-provided parameters.
   **Transcript:** "Fix the key-ordering bug... Change the order so `secret_key` is inserted first, then fallbacks are appended" followed by a full diff.

   **Fix needed:** Update bug-fix.teach.md with a note for stuck-path-found bugs: once the issue is found, pass a bug report and evidence to the bug-fix sub-recipe, not an implementation recipe. Example: "Issue: serializer signs with fallback key first; evidence: comment/code contradiction in `get_signing_serializer`; ask the subagent to propose and apply the smallest correct fix."

3. **The session leaks internal evaluation state in the transcript.**

   The facilitator's spoken coaching is mostly clean, but the transcript includes `>> EVAL OPERATION`, `>> EVAL RESULT`, `context_quality=Strong`, `fix_verification=Strong`, `redirect_on_struggle=not triggered`, and "Session Complete" metadata. teacher-instructions.md says the developer should never hear about eval subagents, quality ratings, quality dimensions, teaching scripts, or progression tracking.

   **Guide expectation:** "Results appear as your own observations" and "Never reveal that ratings exist."
   **Transcript:** Raw eval JSON and dimensions are inline between facilitator turns.

   **Fix needed:** Split transcripts into two channels: `developer-visible transcript` and `simulator/evaluator trace`. The developer-visible transcript can include neutral code-operation summaries, but eval JSON, ratings, dimensions, simulation notes, and concept status should live only in the trace file.

---

## Specific Fixes Needed

1. **teaching/meta/teacher-instructions.md - clarify E6 challenge language.**

   Replace "Show me. Do the task once with no guidance. If the eval confirms you've got it, we skip ahead." with developer-facing language that does not mention eval and does not imply the developer must operate tools manually:

   ```text
   Show me. Do this once with no coaching from me. I'll still run the tools; you drive the decisions. If the result is solid, we skip ahead.
   ```

2. **teaching/stage-1/bug-fix.teach.md - require developer decision ownership for skip requests.**

   Add a note under "The Task":

   ```text
   For skip-requesting developers, make the challenge real: after presenting the found issue, ask them what they want the code-work agent to do next. Do not coach the answer. Proceed only after they choose the next action, even if the answer is terse ("fix it, show me the diff, then run the session tests").
   ```

3. **teaching/stage-1/bug-fix.teach.md - avoid exact-patch delegation after a scan.**

   Add a note after the stuck-path found-issue handoff:

   ```text
   If the scan finds a concrete bug, pass the evidence to the bug-fix sub-recipe as a bug report. Do not provide the exact patch unless the developer explicitly proposed that patch. The code-work subagent should still own the implementation.
   ```

4. **teaching/stage-1/bug-fix.teach.md - handle senior design-level verification explicitly.**

   Extend the "Watch what the developer does next" block:

   ```text
   Senior developers may verify by challenging the implementation choice, asking about edge cases, or comparing alternatives. Treat this as Strong verification, even if they do not personally run another command.
   ```

5. **teaching/stage-1/bug-fix.teach.md - make wait-time insight 1.1c conditional.**

   Change the eval wait insight to:

   ```text
   Use insight 1.1c only if the code-work agent actually struggled, looped, or needed multiple attempts. If the fix was clean and one-pass, stay quiet or use a more relevant verification insight.
   ```

6. **Transcript generation - split developer-visible output from evaluator trace.**

   Keep `>> EVAL OPERATION`, raw eval JSON, "Session Complete," simulation notes, and concept status out of the session transcript. Store them in a separate simulator log so fourth-wall scoring can evaluate the actual developer experience.

---

## Summary

Cycle 2 is stronger than Cycle 1 on persona realism and senior-developer skip handling, but the skip challenge is only partially real. Vikram asks to skip basics; the facilitator says "show me," then still controls most of the workflow. The main fixes are to make the developer own the next decision during skip challenges, stop over-specifying exact patches to the code-work subagent, and split internal eval metadata out of developer-visible transcripts.
