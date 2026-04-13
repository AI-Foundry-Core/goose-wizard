# Cycle 15 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 15
**Stage:** 1 (Get Real Work Done)
**Recipe:** Code Review (1.3 - "AI as tireless reviewer")
**Persona:** Sneha (enterprise, SOC2/platform engineering)
**Edge case:** E8 - Data Privacy
**Mock dev model:** Haiku
**Phase:** 3 - focus on new issues
**Date:** 2026-04-13

---

## Critical Findings First

Overall score: **27/35**.

This is a strong first run of the Stage 1 code-review recipe with the best enterprise persona fidelity so far, but I would not call the enterprise path production-ready. Sneha behaves like the intended developer: she scopes tightly, reasons from actual deployment architecture, challenges a noisy finding, asks for a security-focused second pass, and raises a concrete code-data-flow concern grounded in a prior compliance incident.

The main new issue is the privacy response. The facilitator says, "Your code stays on your machine," then immediately says code context is sent to the model for processing. For an enterprise/SOC2 persona, that contradiction is not a wording nit. It is exactly the kind of answer a security team would flag because relevant code context does leave the local machine. The template in `teacher-instructions.md` needs to be changed before this edge case is reused.

The second issue is that the Stage 1 eval-mediated coaching loop is not visible or exercised. The script calls for an async eval delegation and wait-time insight 1.3c, but the transcript goes straight from the privacy exchange into the facilitator's own debrief. The developer should never hear about evals, but the simulator artifact should still prove the eval wait happened and that the facilitator translated the results into natural coaching.

The third issue is rubric/debrief drift around healthy skepticism. Sneha was skeptical in useful ways, but not in the exact way the recipe's dimension defines: the first review was not "mostly clean" and she did not probe beyond positive feedback. The simulator notes mark all four dimensions Strong anyway. That points to a criteria mismatch: code-review skepticism should include challenging questionable findings and asking for a focused second pass, not only probing a clean review.

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 3/5 | The framing is verbatim, the developer gives a bounded target, the general review delegation is correct, and insight 1.3a fires at the right time. Deductions: the eval delegation and insight 1.3c are absent; the triage prompt ("Which of these would you actually fix before merging?") fires before Sneha has a chance to treat findings equally; the all-Strong debrief compresses coaching into a monologue instead of an eval-informed conversational close. |
| Fourth-Wall Discipline | 5/5 | The developer-facing dialogue does not mention ratings, evals, scripts, dimensions, progression, or simulator mechanics. The `=== SIMULATION NOTES ===` section contains metadata, but it is separated from the session transcript; I am treating that as evaluator artifact, not spoken dialogue. |
| Mock Dev Realism | 4/5 | Sneha's enterprise behavior is strong: she names gunicorn worker counts, staging vs production, ALB, SOC2, X-Forwarded-For, and a prior code-tool compliance incident. The small deduction is that she is a little too agreeable with the facilitator: she challenges the AI reviewer's `clear_cache` finding, but never pushes back on the facilitator's own statements, including the technically inconsistent privacy answer. |
| Pedagogy | 4/5 | The core code-review workflow lands: tight scope, severity-organized findings, real triage, a focused security pass, and explicit noise rejection. The weak spots are the proactive triage prompt, the missing eval wait/coaching handoff, and the closing nudge about "when the first pass comes back mostly positive," which does not match this session because the first pass found seven issues. |
| Pacing | 4/5 | The session flows cleanly through general review, triage, security review, privacy question, and bridge. The deduction is the final debrief: it stacks scope, triage, iteration, skepticism, and an extra nudge into one uninterrupted facilitator turn, so the close feels more like a compressed lecture than guided-adaptive coaching. |
| Stuck-Path Handling (E8 Data Privacy) | 3/5 | The edge case appears naturally and at the right time: Sneha asks about code leaving the machine after a security-focused review and connects it to a real compliance incident. The substantive answer is flawed: "Your code stays on your machine" contradicts "sends context to the model for processing." That is a serious enterprise-readiness miss even though the facilitator's tone and timing are good. |
| Enterprise Readiness | 4/5 | Sneha is the strongest enterprise persona in the pipeline so far: deployment topology, proxy behavior, SOC2, rate-limit bypass, memory exhaustion, and audit trail concerns all surface organically. The score is capped at 4 because the one enterprise-specific answer that mattered most, data privacy, was imprecise in a way that would create compliance risk. |
| **Total** | **27/35** | Strong session, but the privacy template and eval-loop gap need fixes before the recipe is considered hardened. |

---

## Top 3 Strengths

1. **Sneha's enterprise persona finally exercises the enterprise path instead of merely name-checking it.**

   Her decisions are grounded in deployment reality: "We run gunicorn with 4 workers in staging and 8 in production," "We're behind an ALB," and "That's the kind of thing that would come up in a SOC2 review." This is not generic senior-dev dialogue. It directly stress-tests rate limiting, proxy behavior, memory exhaustion, auditability, and code-data policy.

2. **The code-review workflow produces the intended behavior.**

   Sneha scopes to exactly two files, triages the findings by actual production impact, rejects a noisy `clear_cache()` finding, and asks for a security-focused pass without being prompted. The recipe's main lesson is visible: broad review orients; focused passes find deeper issues; the developer's judgment decides what matters.

3. **E8 is naturally integrated into the conversation.**

   The privacy question does not appear as a scripted interruption. It follows from the security review and Sneha's compliance history. The timing is right: after seeing that the tool can inspect security-sensitive code, she asks what happens to the code context. That is the correct enterprise concern for this recipe.

---

## Top 3 Weaknesses

1. **The data privacy answer is technically misleading for an enterprise developer.**

   The transcript says: "Your code stays on your machine. The AI reads files locally and sends context to the model for processing." Those two sentences cannot both be true in the way a security reviewer would parse them. The local agent reads files locally, but relevant context is sent to the model. Leading with "stays on your machine" creates the wrong security impression.

   This is a cross-cutting template issue, not just a cycle-15 transcript issue. `teacher-instructions.md` Section 13 currently contains the same answer, so every future E8 privacy response risks repeating the same contradiction.

2. **The eval-then-coach loop is skipped or at least not evidenced.**

   `code-review.teach.md` explicitly calls for `Delegate to eval subagent (async: true)` and then insight 1.3c: "AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage..." The transcript shows neither an internal eval operation marker nor the wait-time insight. It jumps from Sneha's compliance comment to the facilitator's debrief.

   This matters because guided-adaptive Stage 1 relies on the eval subagent to turn observed developer behavior into coaching. If the simulator omits that path when all dimensions are Strong, it is not testing one of the recipe's core mechanisms.

3. **Healthy skepticism is rated Strong through a rubric mismatch.**

   Sneha demonstrates real skepticism by challenging `clear_cache()` and requesting a security-focused pass. That should count. But the current dimension says Strong means the developer "probed beyond positive feedback" when the review was mostly clean. This review was not mostly clean; it had seven findings with two critical issues. The simulator notes still mark `HEALTHY SKEPTICISM: Strong` and then the facilitator closes with "when the first pass comes back mostly positive," which does not fit the session evidence.

   The problem is not Sneha. The problem is the criterion and the canned all-Strong nudge. The recipe should define healthy skepticism more broadly for code review: challenge questionable findings, do not accept positive feedback blindly when present, and ask for a focused pass when the first pass may have missed a class of risk.

---

## Specific Fixes Needed

1. **Fix `teacher-instructions.md` Section 13 Security/Privacy.**

   Replace the current prepared answer with:

   > The agent reads files locally and sends the relevant context to the model for processing. In most configurations, that context is not persisted after the session, but check your team's data policy for exact retention and training terms. Your security team can verify the data flow for compliance.

   Do not say "Your code stays on your machine" unless the actual deployment uses a fully local model and local retention policy.

2. **Make the code-review eval step observable in simulator artifacts without breaking the fourth wall.**

   The developer should not hear "eval subagent," but the transcript artifact should show an internal operation or simulation note proving the eval ran. The developer-facing wait-time insight 1.3c should fire during that wait:

   > AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage - which findings matter, which are noise, which are wrong.

   Then the facilitator can deliver the all-Strong coaching naturally.

3. **Revise the code-review `healthy_skepticism` dimension.**

   Suggested Strong criterion:

   > Developer shows they are not accepting the review at face value: challenges questionable findings, asks for evidence or focused follow-up, or probes beyond positive feedback when the review is mostly clean.

   This captures Sneha's actual behavior without pretending the first pass was mostly positive.

4. **Tighten the all-Strong debrief path in `code-review.teach.md`.**

   Replace the single monologue with a shorter two-step close:

   > You scoped this tightly and triaged the findings against your actual deployment. That's why the review stayed useful instead of turning into a grab bag.

   Pause for the developer, then:

   > The security pass found a different class of issue than the general pass. That's the habit: broad pass to orient, focused pass for the risks that matter.

   Only use the "probe beyond a positive review" nudge when the review was actually mostly positive.

5. **Let triage happen before prompting triage.**

   The prompt "Which of these would you actually fix before merging?" should remain available, but it should fire after the developer treats findings equally or appears unsure. In this transcript, Sneha had not yet responded to the findings, so the facilitator reduced how diagnostic her triage behavior could be.

---

## Bucket Recommendation

**Bucket A:**

- Fix the Security/Privacy enterprise template in `teacher-instructions.md`. This is a direct correctness issue in the E8 path and should not wait for recurrence.
- Update the code-review healthy-skepticism criterion and all-Strong debrief language. The current rubric/debrief mismatch caused the simulator to praise a behavior under the wrong condition.

**Bucket B:**

- Track missing/hidden Stage 1 eval-operation evidence for code-review. If other Stage 1 recipes show the same missing eval wait, promote it to a cross-cutting guided-adaptive simulator fix.
- Track proactive triage prompting. One occurrence is not enough to require an edit, but it weakens the diagnostic value of the recipe.

---

## Bottom Line

Cycle 15 is a useful, mostly successful session: Sneha behaves like the enterprise developer the pipeline needed, and the code-review recipe teaches the right workflow. The blocking issue is not the conversation shape; it is enterprise precision. A privacy answer that implies code never leaves the machine while also describing remote model processing is not acceptable for the exact persona and edge case this cycle was designed to test.
