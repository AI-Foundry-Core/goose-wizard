# Cycle 17 Evaluation - Codex (GPT 5.4)

**Evaluator:** Codex / GPT 5.4
**Cycle:** 17
**Stage:** 7 (The System Gets Smarter)
**Recipe:** Skill Evolution (7.1-7.2 - "Fix the instruction, not the output")
**Persona:** Arjun (curious/distracted, 27yo, 3yr exp)
**Edge case:** E4 - Transparency Question
**Mock dev model:** Haiku
**Phase:** 3 - focus on new issues
**Date:** 2026-04-13

---

## Critical Findings First

Overall score: **29/35**.

This is a strong Stage 7 session in the broad shape that matters: Arjun works from recurring findings, edits agent instructions rather than individual outputs, verifies the changed behavior, and ends with a usable understanding of the Curator loop. The E4 transparency question is handled cleanly and the "measure before you optimize" intervention is the best moment in the transcript.

The main new issue is that the verification loop is treated as successful even though the underlying review findings are not all credible. The baseline review data includes shaky claims, especially the `abort()` NoReturn finding, and it treats documented `get_flashed_messages()` same-request caching as a Medium behavior bug. That means the session teaches "measure before changing," but not "validate that the measurement source is trustworthy." For Stage 7, where the whole point is letting findings update agent instructions, bad findings are not incidental.

The second issue is that the facilitator pre-digests the first finding-to-instruction trace. After the discovery result, the facilitator states that the escalation rule landed in `LEARNINGS.md` instead of the doc-check instruction file. That is the core diagnostic insight the developer is supposed to practice. Arjun drives a lot of the later work, but the first and most important trace is partially handed to him.

The third issue is a recurring simulator/persona problem: Arjun's curiosity is too polished. He opens with one tangent, then becomes an ideal consulting client who produces clean abstractions on demand. This is not new to Cycle 17, so I would track it under the existing persona-fading bucket rather than create a new recipe fix. It still caps mock dev realism here.

---

## Scores

| Dimension | Score | Evidence |
|---|---:|---|
| Script Faithfulness | 4/5 | The framing, Curator concept, instruction edits, verification, and bridge all map to `skill-evolution.teach.md`. Deduction: the formal `skill-evolution` sub-recipe path is replaced by ad-hoc code operations, and the facilitator pre-digests one of the instruction-gap traces that the script says the developer should perform. |
| Fourth-Wall Discipline | 5/5 | The developer-facing dialogue does not mention evals, ratings, scripts, progression, or teaching mechanics. The E4 answer uses intended-behavior framing: the agent is "supposed to" read instructions, and the output tells you whether the instruction is doing its job. |
| Mock Dev Realism | 3/5 | Arjun has credible curiosity markers: task-vector tangent, Curator mechanism question, Jira escalation destination, and self-modification/alignment aside. Deduction: after the first tangent he becomes too focused and polished; his wait-time observations sound more like facilitator summaries than a distracted 3-year developer thinking aloud. |
| Pedagogy | 4/5 | The "what is the current ratio?" intervention is excellent: it turns a hunch into a measured decision and moves Arjun from deleting style findings to severity classification. Deduction: the session does not challenge the quality of the baseline findings, so it risks teaching instruction evolution from false positives. |
| Pacing | 4/5 | The arc is clean: discovery, doc-check edit, review severity edit, both verification passes, Curator articulation, bridge. Deduction: doc-check is edited and then left unverified while the review-agent arc runs; the facilitator could have asked whether Arjun wanted to verify the first edit before opening the second thread. |
| Stuck-Path Handling (E4) | 5/5 | The transparency question is natural and well handled. The facilitator says the Curator is a pattern Arjun is building, not an automatic hidden mechanism, and does not overclaim that instructions rewrite themselves. |
| Fully-Adaptive Mode Compliance | 4/5 | Arjun chooses doc-check first, moves to review-agent severity, initiates the return to doc-check verification, and describes the Curator loop himself. Deduction: the facilitator frames the initial discovery results into "three recurring patterns" and names the LEARNINGS-vs-instruction gap before asking Arjun where to start. |
| **Total** | **29/35** | Strong session structure and E4 handling; capped by shaky verification evidence, one pre-digested core trace, and recurring Haiku persona flattening. |

---

## Top 3 Strengths

1. **The "measure before you optimize" intervention lands exactly right.**

   Arjun wants to remove all style findings because they feel noisy. The facilitator asks for the current ratio instead of lecturing. The baseline shows 4 behavioral and 5 style findings, which disproves the "mostly noise" assumption and leads Arjun to a better design: severity tiers and output filtering. That is Stage 7 pedagogy working through a real engineering habit.

2. **E4 is handled with strong precision and no fourth-wall leakage.**

   Arjun asks how the system decides which rules to keep. The facilitator answers at the code-behavior level: agents follow instruction files, outputs reveal whether instructions are working, and there is no automatic instruction rewrite mechanism unless Arjun builds one. The answer is practical, accurate, and does not mention prompts, scoring, evals, or architecture.

3. **Arjun demonstrates the manual Curator loop end to end.**

   He identifies recurring findings, turns them into two targeted instruction files, verifies the review-agent output after severity filtering, and later verifies doc-check escalation with mock prior state. He also articulates the automation boundary correctly: a Curator can propose edits, but a human should approve them to avoid instruction drift.

---

## Top 3 Weaknesses

1. **The verification loop accepts questionable review findings as ground truth.**

   The review baseline is the evidence that justifies the severity instruction. But at least two findings are shaky. The `abort()` item says the `NoReturn` contract is risky if an aborter raises a non-HTTPException; raising is still non-returning, so the type-contract claim does not hold. The `get_flashed_messages()` item treats same-request cache behavior as a Medium bug even though the docstring explicitly says further calls in the same request return the same messages.

   That matters because the session's strongest lesson is "measure before changing." If the measurement source contains false positives, the next Stage 7 lesson should be "validate the findings before editing instructions." Otherwise the Curator loop can reinforce bad reviewer behavior.

   **Fix:** In `skill-evolution.teach.md`, add a verification-quality guardrail: before using review findings to change an instruction, ask the developer to sample at least one finding and confirm it against the source. Suggested prompt: "Before we tune the instruction around these findings, which of these are actually correct? Pick one Medium and one Low and check the code."

2. **The facilitator pre-digests the first finding-to-instruction trace.**

   After the discovery result, the facilitator says the escalation rule was added to `LEARNINGS.md`, not to the doc-check agent's instructions. That is the exact causal trace the developer is supposed to practice: recurring behavior -> missing instruction -> targeted edit. Arjun confirms and builds on it, but he does not discover that first trace independently.

   The later review-agent trace is more developer-driven, so this is not a full mode failure. But the first trace sets the frame for the whole session. In a fully adaptive Stage 7 session, the stronger move is to show the raw findings and ask, "What do you notice?"

   **Fix:** In `skill-evolution.teach.md`, add a note after discovery results: "Do not name the instruction gap first. Present the raw findings and ask what the developer sees. If they miss the gap, ask a hint question like, 'Where did that escalation rule actually land?'"

3. **Arjun's persona becomes too polished after the opening tangent.**

   The transcript checks the "curious" box early with the transformer task-vector tangent, then Arjun becomes consistently concise, correct, and cooperative. His wait-time comments are especially polished: "the distinction between re-reporting and escalating is the key difference" and "the ambiguity rule at the end is important" sound like facilitator takeaways.

   A tangent-prone developer should drift more than once, and at least one drift should be only partly useful. The Jira escalation question is credible and practical; the rest of the session is too clean for the stated persona.

   **Fix:** Track this under the existing Haiku persona-fading issue rather than as a new recipe bug. For Arjun specifically, update the persona prompt to require 2-3 recurring curiosity moves, with at least one partly off-base analogy that the facilitator must redirect without dismissing.

---

## Specific Fixes Needed

1. **Add a finding-validity check to `skill-evolution.teach.md`.**

   Before a developer edits instructions based on review findings, have them sample-check the findings against source evidence. The Curator loop should not blindly optimize from untrusted reviewer output.

2. **Add a fully adaptive discovery guardrail to `skill-evolution.teach.md`.**

   After discovery results, the facilitator should ask "What do you notice?" before categorizing the findings. Hint with questions only if the developer misses the instruction source.

3. **Probe one instruction-design edge case before creating files.**

   When Arjun proposes "escalate after 3+ cycles," the facilitator should ask one design question: "What happens if it keeps escalating and nobody acts?" or "Why 3 cycles?" That keeps the developer responsible for the rule semantics, not just the wording.

4. **Track Arjun persona flattening as a recurring simulator issue.**

   Do not promote this as a new Cycle 17 recipe defect. It is another occurrence of the existing mock-dev persona fading pattern, with Haiku demonstrating the trait once and then becoming a cooperative ideal user.

---

## Bucket Recommendation

**Bucket A:**

- Add the finding-validity check to `skill-evolution.teach.md`. This is new and high-impact because Stage 7 instruction evolution can amplify false positives if the source findings are not checked.
- Add the fully adaptive discovery guardrail to `skill-evolution.teach.md`. This is a narrow fix that protects the central 7.1 skill: tracing findings to instruction gaps.

**Bucket B:**

- Add an instruction-design edge-case probe to the same script. Useful, but lower urgency than preventing false-positive-driven instruction edits.
- Increment the existing Haiku/persona-fading issue for Arjun. This should be fixed at the simulator/persona-prompt layer, not in the skill-evolution script.
- Track the missing formal `skill-evolution` sub-recipe invocation as a production-recipe coverage gap. The ad-hoc operations worked conversationally, but they did not exercise the intended recipe interface.

---

## Bottom Line

Cycle 17 is a good Stage 7 session, but it is not as strong as the transcript's self-rating. The facilitator handles E4 cleanly and teaches "measure before optimize" well. The real risk is that the session treats reviewer output as trustworthy without checking it. A Curator loop that edits instructions from bad findings does not make the system smarter; it makes the bad signal more durable.
