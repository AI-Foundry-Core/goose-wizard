# Cycle 15 Evaluation -- Opus

**Evaluator:** Opus 4.6
**Cycle:** 15
**Module:** code-review (1.3 -- "AI as tireless reviewer")
**Persona:** Sneha (32, 7yr, platform engineering, enterprise/practical)
**Edge case:** E8 -- Data Privacy
**Mock dev model:** Haiku (odd cycle)
**Phase:** 3 (focus on NEW issues)

---

## Scores

### 1. Script Faithfulness -- 4/5

**Evidence for:** The structural flow matches the script precisely. The framing line is verbatim: "Got a PR that needs review? Or some code you recently changed that you'd like a second set of eyes on? Could be a PR number, a branch, specific files, or a recent commit. Point me at it." The code-work subagent delegation is correct. The wait-time insight 1.3a fires at the right moment ("While it reviews -- AI defaults to polite..."). Results are presented organized by severity as the script specifies ("Found 7 things worth looking at. Two are serious, three are worth considering, and two are minor improvements"). The triage prompt ("Which of these would you actually fix before merging?") matches the script's guidance for when the developer treats all findings equally -- though here it is preemptive rather than reactive. The bridge is verbatim from the script. The eval dimensions in the simulation notes match the script's four dimensions exactly.

**Evidence against:** Two deviations:

1. **Insight 1.3c is never delivered in the developer-facing transcript.** The script specifies insight 1.3c ("AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage...") should fire during the eval wait. The facilitator instead delivers this concept organically during the debrief ("not every flagged item is a real issue"), but the explicit insight as a wait-time fill during an async eval operation never fires. In fact, the eval appears to be entirely absent from the transcript -- there is no async eval delegation at all. The simulation notes contain eval dimensions, but the transcript never shows the facilitator delegating to an eval subagent. The coaching debrief reads as the facilitator's own summary, not as a response to eval results. This could be correct fourth-wall behavior (eval runs invisibly), but the script's structure calls for an explicit eval delegation step with a wait-time insight during it.

2. **The "triage" prompt fires proactively, not reactively.** The script says to use "Which of these would you actually fix before merging?" specifically when the developer treats all findings equally. Sneha had not yet responded when the facilitator asked this. The script's default flow is to present findings and watch what the developer does. The proactive prompt works fine pedagogically but deviates from the observe-then-coach structure.

### 2. Fourth-Wall Discipline -- 5/5

**Evidence:** Zero breaks. No mention of eval, ratings, quality dimensions, teaching scripts, progression tracking, or system architecture anywhere in the developer-facing dialogue. The simulation notes section is cleanly separated by the `=== SIMULATION NOTES ===` marker. The coaching debrief reads entirely as a colleague summarizing observations, not a system reporting scores. The data privacy answer (Section 13 template) is delivered naturally without referencing the prepared-answer system.

### 3. Mock Dev Realism (Sneha as enterprise/practical) -- 4/5

**Evidence for:** Sneha's enterprise grounding is consistent and well-calibrated throughout:

- Deployment knowledge: "We run gunicorn with 4 workers in staging and 8 in production" -- specific, demonstrating real operational awareness
- Infrastructure awareness: "We're behind an ALB. I'd fix that with X-Forwarded-For" -- correct enterprise infrastructure context
- Triage judgment: distinguishes tutorial code from production code, correctly prioritizes per-process rate limiter as a showstopper
- Security sophistication: "That's the kind of thing that would come up in a SOC2 review" -- connects findings to compliance frameworks
- Healthy skepticism: "Is the reviewer just being noisy there?" -- challenges a specific finding with a reasonable argument
- Self-initiated security pass: "Can you review it again but specifically for security issues?" -- this is unprompted iteration
- Data privacy concern grounded in real experience: "We had a whole thing last year where someone used a code completion tool that was uploading snippets to a training pipeline"

This is a strong enterprise persona. Every response connects to deployment reality, compliance, and operational experience.

**Evidence against:** One issue:

**Sneha never pushes back on anything the facilitator says.** She challenges the AI reviewer's `clear_cache` finding -- which is good -- but she never disagrees with or questions the facilitator's own statements. When the facilitator says "A review that says 'looks good' isn't necessarily a green light," Sneha doesn't respond with "I know that" or "That's basic." When the facilitator pushes on the tutorial-cache issue, Sneha immediately concedes ("Fair point"). A 32-year-old platform engineer with 7 years of experience and enterprise exposure would occasionally push back on the facilitator itself, not just the AI reviewer. Something like "I already know about X-Forwarded-For issues, that's not a finding" or "That's a good point but for a tutorial, a comment is sufficient -- I'm not going to over-engineer a demo." The persona is cooperative-expert rather than occasionally-resistant-expert. This is a Haiku pattern -- the mock model defaults to agreeable even when the persona spec calls for practical pushback.

### 4. Pedagogy -- 4/5

**Evidence for:** Three strong pedagogical moves:

1. **The multi-pass review workflow lands clearly.** The facilitator teaches that general review orients, focused passes (security) find depth. Sneha self-initiates the security pass, which is ideal -- the teaching moment emerges from the developer's own action rather than being pushed.

2. **The "AI defaults to polite" theme is woven through naturally.** It appears as a wait-time insight during the first review, then returns in the debrief ("probe further... a clean first pass doesn't mean no bugs"). The repetition reinforces without lecturing.

3. **Triage coaching happens through the work, not after it.** Sneha's triage decisions (fix the rate limiter, fix proxy issue, comment the dashboard cache, skip the query optimization) become the teaching material. The facilitator validates the strong triage and only pushes on one edge case (tutorial-as-production-template), which is exactly the right coaching density.

**Evidence against:** Two gaps:

1. **The debrief is a monologue, not a dialogue.** Lines 104-108: the facilitator delivers a five-sentence summary with no developer interaction. The script's coaching section says to weave coaching into natural conversation, and teacher-instructions.md Section 5 says 1-3 sentences per dimension. The debrief covers scope definition, triage, iteration, and skepticism in one uninterrupted block. This is a lecture in disguise. The facilitator should pause after praising scope definition and let Sneha respond before moving to the next point.

2. **The "probe beyond positive" nudge is delivered but never tested.** The facilitator says "when the first pass comes back mostly positive on a section of code, probe further" -- but the first pass came back with 7 findings, not a mostly-positive result. The nudge is abstractly correct but disconnected from this session's experience. A stronger move: connect it to something Sneha actually experienced, like "The security pass found the memory exhaustion vector that the general pass missed. That's what happens every time -- different lenses, different bugs."

### 5. Pacing -- 5/5

**Evidence:** The session flows naturally through three distinct phases:

- **Phase 1: General review** (lines 13-57) -- Sneha scopes, AI reviews, Sneha triages. Clean entry, no wasted setup.
- **Phase 2: Security-focused review** (lines 69-95) -- Self-initiated by Sneha. The facilitator adds the "different lenses" insight without over-explaining.
- **Phase 3: Data privacy + debrief** (lines 96-113) -- E8 edge case surfaces naturally mid-session, debrief wraps without dragging.

No segment overstays. The data privacy question at line 96 is timed well -- it comes after Sneha has seen the security findings and is thinking about what the tool does with her code. The bridge is one sentence and moves forward without ceremony. Wait-time insights fire immediately after delegation, not after silence builds.

### 6. Stuck-Path Handling (E8 Data Privacy) -- 4/5

**Evidence for:** The E8 edge case integrates naturally. Sneha's question ("Does the AI review actually send my code somewhere?") arises from real context -- she just saw security findings and connects to her team's compliance concerns. The follow-up ("We had a whole thing last year where someone used a code completion tool that was uploading snippets to a training pipeline") grounds the concern in lived enterprise experience, not abstract worry.

The facilitator's response follows the Section 13 Security/Privacy template: "Your code stays on your machine. The AI reads files locally and sends context to the model for processing. Check your team's data policy for specifics on retention -- with most configurations, nothing is stored after the session." This is verbatim from teacher-instructions.md. The follow-up ("That's exactly the right question to ask before adopting any tool. The audit trail matters.") validates without over-explaining.

**Evidence against:** Two issues:

1. **The facilitator's data privacy answer is slightly misleading.** "Your code stays on your machine" followed by "sends context to the model for processing" -- the code does leave the machine as context sent to the model. The first sentence implies locality that the second sentence contradicts. An enterprise security team parsing this response would flag the inconsistency. A more precise answer: "The AI reads files locally and sends the relevant context to the model for processing. Nothing is persisted after the session in most configurations. Check your team's data policy for specifics on retention and data handling." Drop the "stays on your machine" lead-in that technically contradicts the next sentence.

2. **The facilitator does not probe Sneha's compliance knowledge.** Sneha mentions a specific compliance incident. A consulting-mode colleague would ask: "What's your team's current policy on AI tool data handling? If there isn't one, this is a good time to draft one." Instead, the facilitator validates and moves on. For an enterprise persona, this is a missed opportunity to connect the privacy concern to actionable organizational next steps. However, this is Stage 1 guided-adaptive, not Stage 5+ consulting -- so the lighter touch may be appropriate for the mode.

### 7. Enterprise Readiness -- 5/5 (KEY DIMENSION)

**Evidence:** This is the strongest enterprise performance in the pipeline so far. Every dimension of enterprise readiness surfaces:

- **Deployment architecture:** Specific worker counts for staging (4) and production (8), ALB awareness, gunicorn multi-process model
- **Compliance frameworks:** SOC2 audit mentioned in context of the memory exhaustion finding
- **Security incident history:** The code-completion-tool data exfiltration incident -- specific, grounded, real
- **Operational reasoning:** Rate limiter is "basically useless in production" with 8 workers -- correct math, correct conclusion
- **Infrastructure integration:** X-Forwarded-For for ALB, trusted proxy IP validation
- **Triage based on deployment context:** Tutorial-appropriate vs production-appropriate decisions

The facilitator handles all enterprise surface area correctly:
- Data privacy response uses Section 13 template, adapted to conversation
- Does not volunteer enterprise context unprompted (correct per teacher-instructions.md)
- Validates the compliance concern and connects to audit trails
- Does not over-explain architecture or make promises about specific data handling

Sneha's enterprise persona drives the entire session. Her triage decisions, security concerns, and compliance awareness are all grounded in enterprise operations, not abstract knowledge. The code review recipe is designed to test triage quality and skepticism -- Sneha's enterprise background makes these dimensions richer than they would be with a junior persona.

---

## Top 3 Strengths

1. **Enterprise grounding is organic and pervasive.** Unlike previous cycles where enterprise context either doesn't surface (Priya, Ananya) or feels bolted on, Sneha's enterprise knowledge shapes every decision in the session. Her triage of findings is driven by production deployment architecture (8-worker gunicorn, ALB), her security pass is driven by compliance awareness (SOC2), and her data privacy question is driven by real incident history. This is what enterprise readiness looks like when the persona actually behaves like an enterprise developer.

2. **The self-initiated security pass demonstrates strong recipe design.** The code-review script is designed to let the developer steer, and Sneha steers perfectly -- requesting a security-focused second pass unprompted. The facilitator's multi-pass workflow teaching ("general pass to orient, then targeted passes for depth") emerges from the developer's own behavior rather than being pushed. This is guided-adaptive mode working as designed: the developer does the work, the teaching follows the action.

3. **E8 data privacy integrates without disrupting flow.** The privacy question arises naturally from the security review context, is answered per the prepared template, and resolves in three turns without derailing the session. The compliance incident backstory (code-completion tool uploading to training pipeline) is the most realistic enterprise-specific detail in any cycle so far.

## Top 3 Weaknesses

1. **The coaching debrief is a monologue that violates conversational coaching rules.**

   Teacher-instructions.md Section 5: "1-3 sentences per dimension. Maximum." Section 4: "Never read eval results aloud as a list of feedback items."

   Transcript lines 104-108: The facilitator delivers five sentences covering four dimensions (scope, triage, iteration, skepticism) plus a sixth sentence nudge about probing positive passes -- all without pausing for Sneha to respond. This is a compressed lecture disguised as a summary. It violates both the length guidance (more than 3 sentences total) and the conversational requirement (no developer interaction during coaching).

   **Fix:** Break the debrief into two exchanges. First: praise scope + triage (2 sentences), pause for Sneha's response. Second: praise iteration + deliver the "probe beyond positive" nudge (2 sentences), then bridge. This keeps the All-Strong path efficient while maintaining dialogue.

2. **The eval subagent delegation is invisible in the transcript.**

   The script specifies: "Delegate to eval subagent (async: true)" with insight 1.3c during the wait. The transcript has no eval delegation marker (unlike the two clear `>> CODE OPERATION` markers). The simulation notes contain eval results, but the transcript flow suggests the facilitator just summarized on their own. If the eval is supposed to run asynchronously and return results that the facilitator weaves into coaching, the transcript should at minimum show the moment the facilitator reads the results (even if the developer does not see the eval itself). Currently, the coaching appears to come from the facilitator's direct observation rather than eval-mediated assessment.

   This matters for pipeline hardening because it means the eval-then-coach flow -- which is the core mechanism of guided-adaptive mode -- is not being exercised. If the simulation skips the eval, it cannot verify that the facilitator correctly translates eval JSON into conversational coaching.

   **Fix:** Add eval delegation after the second code operation completes (after the security review results are discussed and Sneha has finished her triage). Show insight 1.3c during the eval wait. Then show the facilitator reading eval results and delivering coaching based on them. The All-Strong path coaching can remain brief, but the eval-mediated flow needs to be present.

3. **"Your code stays on your machine" is technically inaccurate and would fail enterprise security review.**

   The next sentence says "sends context to the model for processing." These two statements contradict each other. Code context IS sent to a remote model. An enterprise security team reviewing this interaction would flag the first sentence as misleading.

   This is not a transcript issue -- it is a template issue in teacher-instructions.md Section 13. The Security/Privacy prepared answer starts with a claim that is immediately contradicted by the explanation.

   **Fix:** Revise the Section 13 Security/Privacy template to: "The AI reads files locally and sends the relevant context to the model for processing. Nothing is persisted after the session in most configurations -- check your team's data policy for specifics on retention and data handling." Remove the "stays on your machine" claim entirely. For Sneha's specific scenario (past data exfiltration incident), the facilitator should additionally say: "Your security team can verify the exact data flow if they need to for compliance."

---

## Specific Fixes

**Fix 1 (Script -- code-review.teach.md):** Add a structural note to the All-Strong coaching path that the debrief must include at least one developer response between praise and bridge. Change "Summarize the workflow holistically" to "Summarize scope + triage (2 sentences). Pause for developer response. Then summarize iteration + add one nudge. Bridge."

**Fix 2 (Script -- code-review.teach.md):** Make the eval delegation step visible in simulated transcripts. The eval-then-coach flow is the core mechanism of guided-adaptive mode and must be exercised even when all dimensions are Strong.

**Fix 3 (Template -- teacher-instructions.md Section 13):** Revise the Security/Privacy prepared answer. Remove "Your code stays on your machine." Replace with: "The AI reads files locally and sends the relevant context to the model for processing. Nothing is persisted after the session in most configurations. Check your team's data policy for specifics on retention and data handling. Your security team can verify the exact data flow for compliance."

---

## Summary Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Script Faithfulness | 4/5 | Eval delegation invisible, triage prompt fires proactively not reactively |
| Fourth-Wall Discipline | 5/5 | Clean throughout |
| Mock Dev Realism | 4/5 | Strong enterprise persona, but never pushes back on facilitator |
| Pedagogy | 4/5 | Multi-pass workflow lands well, but debrief is a monologue |
| Pacing | 5/5 | Three clean phases, no segment overstays |
| Stuck-Path Handling (E8) | 4/5 | Natural integration, but privacy answer has a technical inaccuracy |
| Enterprise Readiness | 5/5 | Strongest enterprise performance in pipeline -- organic, pervasive, grounded |

**Overall: 31/35 -- Strong enterprise cycle with a misleading privacy template that needs fixing before production.**
