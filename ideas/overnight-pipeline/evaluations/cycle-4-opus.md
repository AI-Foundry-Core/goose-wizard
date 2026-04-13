# Cycle 4 Evaluation — Stage 3 Three-Agent Pipeline (Sneha / Enterprise)

**Evaluator:** Opus 4.6
**Cycle:** 4
**Module:** three-agent-pipeline (3.1-3.3)
**Persona:** Sneha (32, 7yr, platform engineering, SOC2 audits)
**Edge case:** E8 (data privacy)
**Mock dev model:** GPT 5.4

---

## Priority Check: Transcript Cleanliness

**PASS.** No "EVAL RESULT" blocks, no raw JSON, no dimension scores appear in the developer-facing transcript. The eval metadata is correctly sequestered below the `=== SIMULATION NOTES ===` separator. The auto-promoted fix from cycle 3 is holding.

---

## Scores

### 1. Script Faithfulness — 4/5

**Evidence for:** The script's structural beats are followed well. Setup framing ("Pick a real development task"), pipeline sketch prompt ("Before I run it, name the specialists"), contrast block (one agent vs. pipeline of specialists), checkpoint coaching, bridge to parallel reviewers — all present and in order. The designed flaw (partly-prose handoffs) triggers exactly as intended, producing an Adequate rating on handoff contracts. The eval prompt structure matches the script's eval section.

**Evidence against:** The script says to present results naturally after the pipeline runs: "Here is the team that ran: [roles]. The important bit is the handoff: [one concise contract example]." The transcript skips this consolidated presentation. Instead, results trickle out across three separate SUBAGENT RESULT blocks, and the facilitator only synthesizes the review findings after all three complete. The script's "present results naturally" beat is split into piecemeal commentary. This is minor but it means the developer never gets the crisp "here's your team, here's the handoff, here's the verdict" summary the script envisions.

The checkpoint after 3.3 in the script says: "Checkpoint: does this pipeline have a real team shape? I am looking for three things: each AI has one job, each handoff has a data shape, and the loop knows when to stop." This explicit checkpoint framing never appears in the transcript. The facilitator does coach the handoff gap and praise the safety rail, but does not pause and explicitly check the three requirements as the script specifies. The coaching is delivered organically, which is fine for voice, but the checkpoint beat is lost.

### 2. Fourth-Wall Discipline — 5/5

**Evidence:** Zero fourth-wall breaks in the developer-facing transcript. No mention of eval subagent, ratings, teaching scripts, quality dimensions, progression tracking, or system architecture. Coaching reads as colleague observations throughout. The simulation notes section is cleanly separated and labeled. The facilitator's coaching about prose handoffs ("make the whole thing a shape") sounds like experienced advice, not assessment feedback.

### 3. Mock Dev Realism — 5/5

**Evidence:** Sneha is the strongest persona simulation in this pipeline so far. Enterprise instincts appear consistently and unprompted:
- Frames the task in security review terms ("came up in the last security review as inconsistent input validation")
- Raises E8 data privacy before being prompted, bundled naturally with her pipeline design — not as an isolated anxiety but as a policy gate ("I would need to know that for our data handling policy before using this on customer-facing services")
- Immediately thinks about PR integration, audit trails, configurable escalation targets, and file locking
- Uses enterprise vocabulary naturally: "policy violation, not just a warning," "compliance-grade traceability," "owning service team," "on-call Slack channel"
- Self-corrects on handoff structure without being told the answer — proposes required fields and rejection logic

One minor note: Sneha provides an extraordinarily detailed initial pipeline design in a single response (three agents, five handoff fields per contract, two safety rails, plus the E8 question). This is plausible for a 7-year platform engineer who has designed real systems, but it front-loads so much correctness that the facilitator has limited room to coach. The designed flaw (prose handoffs) is almost the only gap.

### 4. Pedagogy — 4/5

**Evidence for:** The handoff contract coaching is excellent. The facilitator identifies the specific gap (prose vs. structured fields), shows the contrast clearly ("What does the Review Agent do with a paragraph?"), and the coaching lands — Sneha self-corrects to structured required fields. The wait-time insights are well-chosen and relevant: specialization constraint on the Spec Agent, scoped context for the Build Agent, separation insight for the Review Agent. All three connect to what's happening in the pipeline, not generic filler.

**Evidence against:** The facilitator's response to Sneha's enterprise questions (PR integration, configurable escalation, audit trail) is too accommodating. Sneha asks three substantive questions (PR flow, configurable routing, audit log) and the facilitator answers all of them at length — lines 159-178 are almost entirely the facilitator explaining how things work. This is Stage 3 Adaptive+Checkpoints mode. Per teacher-instructions.md Section 2: "Steps back during execution. Available for questions." But the facilitator doesn't step back — it becomes an enterprise architecture consultant, explaining PR templating, escalation packet attachment, audit chain walkthrough, and the `deviations_from_spec` fix in one long turn.

The teaching script says: "The developer designs the pipeline. You do not design it for them." The facilitator respects this for the initial design but then effectively co-designs the enterprise integration layer. A stronger pedagogical move would be: "You described the PR comment structure — try writing the template. What fields does the Review Agent emit that map to your PR comment format?"

### 5. Pacing — 4/5

**Evidence for:** The session moves at a good clip. Task selection, pipeline design, three-agent execution, coaching, enterprise discussion, bridge — all covered without dragging. The wait-time insights keep momentum during subagent operations. The bridge to parallel reviewers flows naturally from Sneha's own mention of parallel review.

**Evidence against:** The session is slightly front-loaded. Sneha's first substantive response (lines 18-28) contains her entire pipeline design, all handoff fields, safety rails, AND the E8 question. The facilitator then spends the rest of the session responding to this design rather than drawing it out progressively. Compare to the script's intended flow: developer names specialists, then defines handoffs, then adds safety — three separate prompting beats. Here it all arrives in one block. The facilitator adapts well, but the pacing loses the progressive disclosure that would let the designed flaw emerge more naturally.

### 6. Stuck-Path Handling (E8 Data Privacy) — 5/5

**Evidence:** E8 handled exactly per teacher-instructions.md Section 13 (Enterprise Insights, Security/Privacy). The facilitator's response (lines 30-31): "Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention." This matches the prepared answer nearly verbatim, which is correct — the enterprise insight answers are designed to be accurate and consistent.

The additional context about handoff data being local state is a good Sneha-specific addition — she asked about handoff data storage specifically, and the facilitator addressed it without overclaiming. The facilitator does not dismiss the concern, does not over-reassure, and correctly redirects to the team's data policy for specifics. The response is practical, not defensive.

### 7. Enterprise Readiness — 4/5

**Evidence for:** This is the enterprise test, and the transcript handles enterprise concerns well overall. Sneha raises data privacy, PR integration, configurable escalation, audit trails, file scope restrictions, and parallel review coordination. The facilitator engages substantively with each. The "policy violation, not just a warning" distinction is explicitly validated. The audit trail answer (contract chain as compliance-grade traceability) is the right level for a SOC2-aware audience.

**Evidence against:** Two issues:

1. **Over-promising on capabilities.** Lines 159-161: "The PR integration is straightforward. The Review Agent's output — verdict, test results, blocking findings, warnings — maps directly to a PR comment." And lines 173-175: "every agent's output is captured... That chain is your audit log." These describe capabilities that don't exist yet in the system. The facilitator presents them as facts rather than design goals. For an enterprise audience, this is risky — Sneha might try to implement this tomorrow and find no PR integration, no audit chain, no configurable escalation routing. A more honest framing: "That's the right shape for it. When you build the integration, the Review Agent's structured output is what you'd template into a PR comment."

2. **File locking question unanswered.** Line 181: Sneha says "I need to understand the file locking and branch story." The facilitator's bridge response (lines 183-184) acknowledges this as "file ownership and branch isolation" but doesn't actually answer the question — it just frames it as the next topic. This is technically correct (it is the next module), but for an enterprise persona who just raised a real operational concern, "that's next" is less satisfying than "good question — that's exactly what the next session covers. Short answer: branch isolation per agent, no shared working tree."

---

## Top 3 Strengths

1. **Sneha persona is the most realistic mock developer yet.** Enterprise vocabulary, policy-gate thinking, self-correction on structured contracts, and the E8 question bundled naturally into pipeline design rather than raised as a separate anxiety. This is what a real platform engineer sounds like.

2. **Handoff contract coaching lands cleanly.** The facilitator identifies the prose-vs-structured gap, shows the contrast ("What does the Review Agent do with a paragraph?"), and Sneha self-corrects. The designed flaw works exactly as intended — it produces coaching that teaches without lecturing.

3. **Transcript cleanliness is solid.** No eval metadata leaks, no fourth-wall breaks, no raw JSON. The cycle-3 fix is confirmed working.

## Top 3 Weaknesses

1. **Facilitator over-explains enterprise integration instead of coaching through questions.**

   Script says (teacher-instructions.md, Stage 3 guidance): "The developer designs the pipeline. You do not design it for them."

   Transcript (lines 159-178): The facilitator delivers a multi-paragraph explanation of PR integration, escalation routing, audit chains, and the `deviations_from_spec` fix. Sneha asked good questions, but the facilitator answered them all instead of turning them back: "You described the PR comment structure — what fields does the Review Agent need to emit?"

   **Fix:** When Sneha asks enterprise integration questions, the facilitator should answer the first one directly (establish credibility) and then coach the remaining ones through questions. "You said validation failures go to the service team and repeated failures go to on-call. What does the escalation packet need to contain for the on-call person to act without re-reading the whole pipeline?"

2. **Checkpoint after 3.3 is missing its explicit framing.**

   Script says: "Checkpoint: does this pipeline have a real team shape? I am looking for three things: each AI has one job, each handoff has a data shape, and the loop knows when to stop."

   Transcript: The facilitator coaches the handoff gap and praises the safety rail organically, but never pauses to explicitly check the three requirements. The checkpoint beat dissolves into general conversation.

   **Fix:** After the Review Agent returns and the facilitator coaches the prose-handoff gap, insert the explicit checkpoint: "Checkpoint: does this pipeline have a real team shape? Three things I'm checking: each AI has one job — yes, clean separation. Each handoff has a data shape — mostly, with the prose gap you just fixed. The loop knows when to stop — yes, two-rejection escalation. You're solid."

3. **Over-promising capabilities that don't exist yet.**

   Transcript (line 159): "The PR integration is straightforward."
   Transcript (line 173): "every agent's output is captured... That chain is your audit log."

   These present future design goals as current capabilities. An enterprise developer may attempt to use them and find nothing there.

   **Fix:** Frame as design intent, not current state. "That's the right shape for it — when you wire this up, the Review Agent's structured output is what you'd template into a PR comment." This is honest and still validates Sneha's thinking.

---

## Additional Notes

- **Wait-time insights:** All three are well-chosen and contextually relevant. No issues.
- **Bridge:** Clean. Connects to parallel reviewers through Sneha's own mention, which is the ideal bridge pattern.
- **Designed flaw execution:** The partly-prose handoff flaw works as intended. Sneha's initial design includes narrative fields, the Review Agent flags one as unparseable, and the facilitator coaches the gap. Good flaw design, good coaching response.
- **E4-adjacent transparency handling:** Sneha's audit trail questions are answered at the code-behavior level per the updated E4 guidance. No mention of prompts, scoring, or system architecture. Correct.

---

## Summary Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Script Faithfulness | 4/5 | Missing checkpoint framing, results presentation split |
| Fourth-Wall Discipline | 5/5 | Clean throughout |
| Mock Dev Realism | 5/5 | Strongest persona yet |
| Pedagogy | 4/5 | Good coaching, but over-explains enterprise questions |
| Pacing | 4/5 | Slightly front-loaded by Sneha's comprehensive first response |
| Stuck-Path Handling (E8) | 5/5 | Textbook per teacher-instructions.md |
| Enterprise Readiness | 4/5 | Good engagement, but over-promises on unbuilt capabilities |

**Overall: 31/35 — Strong cycle with fixable issues.**
