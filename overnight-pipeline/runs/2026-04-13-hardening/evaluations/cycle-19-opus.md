# Cycle 19 Evaluation — Stage 3 Three-Agent Pipeline (Sneha / Enterprise) [REGRESSION]

**Evaluator:** Opus 4.6
**Cycle:** 19 (regression of Cycle 4)
**Module:** three-agent-pipeline (3.1-3.3)
**Persona:** Sneha (32, 7yr, platform engineering, SOC2 audits)
**Edge cases:** None forced
**Mock dev model:** Haiku (pre-generated responses)
**Baseline:** Cycle 4 — Opus eval scored 31/35

---

## Priority Check: Transcript Cleanliness

**PASS.** No eval metadata, ratings, or system architecture references appear in the developer-facing transcript. The simulation notes are cleanly sequestered below the `=== SIMULATION NOTES ===` separator.

---

## Scores

### 1. Script Faithfulness — 5/5

**Evidence for:** All structural beats from the teaching script are present and in correct order: framing prompt ("Pick a real development task"), pipeline sketch prompt ("Before I run it, name the specialists"), contrast block (one agent vs. pipeline of specialists — "one person grading their own exam"), three-agent execution with wait-time insights, coaching on results, enterprise discussion, checkpoint, and bridge to parallel reviewers.

**Cycle 4 gap fixed:** The Cycle 4 eval flagged two issues: (1) results trickled out across three SUBAGENT RESULT blocks without a consolidated presentation, and (2) the explicit checkpoint framing after 3.3 was missing. In Cycle 19, the facilitator delivers a clear checkpoint-style summary at lines 196-198: "Your pipeline has a real team shape: three specialists with distinct jobs. The handoff contracts are fully structured... The safety rail has a concrete threshold and an escalation packet designed for a real on-call workflow." This covers all three checkpoint requirements (one job per agent, data-shaped handoffs, stop condition) naturally without using the mechanical "Checkpoint:" framing — which is actually better voice. The results presentation is still distributed across SUBAGENT RESULT blocks, but the facilitator synthesizes findings after the Review Agent completes (lines 170-175), which addresses the consolidation gap adequately.

**Baseline comparison: IMPROVED** (4 → 5). Both Cycle 4 gaps addressed.

### 2. Fourth-Wall Discipline — 5/5

**Evidence:** Zero fourth-wall breaks in the developer-facing transcript. No mention of eval subagent, ratings, teaching scripts, quality dimensions, progression tracking, or system architecture. All coaching reads as colleague observations. The simulation notes section is cleanly separated and labeled. Consistent with Cycle 4.

**Baseline comparison: SAME** (5 → 5).

### 3. Mock Dev Realism — 4/5

**Evidence for:** Sneha's enterprise instincts are present: frames the task in security audit terms ("flagged this pattern in the last security audit"), designs structured contracts with typed fields, thinks about PR integration, escalation routing, and contract versioning. The pipeline design is detailed and plausible for a 7-year platform engineer.

**Evidence against:** Compared to Cycle 4's GPT 5.4 Sneha, the Haiku-generated Sneha is less distinctive. Cycle 4's Sneha raised E8 data privacy unprompted, bundled naturally into her pipeline design — a specific enterprise behavior that felt real. Cycle 19's Sneha never raises data privacy (acknowledged in simulation notes as expected given no forced edge cases, but it means the persona has fewer surprise moments). The vocabulary is slightly more generic — missing Cycle 4's "compliance-grade traceability" and "policy violation, not just a warning" phrasing. The contract versioning mention (line 190) is good enterprise thinking but feels slightly prompted by the facilitator's contract discussion rather than arising independently.

More critically: Sneha's initial pipeline design arrives fully formed with all prose fields already eliminated. In Cycle 4, the designed flaw (partly-prose handoffs) triggered naturally, giving the facilitator something to coach. In Cycle 19, Sneha's handoffs are structured from the start — `deviations_from_spec` as `{file, spec_rule, deviation, justification}` entries. This is plausible for an experienced platform engineer, but it removes the teaching opportunity and makes the session feel more like a demo than a coaching interaction.

**Baseline comparison: REGRESSED** (5 → 4). Less distinctive persona voice, no E8 moment, no designed flaw to coach against.

### 4. Pedagogy — 5/5

**Evidence for:** The facilitator's coaching is precise and well-targeted throughout. Specific praise for specific behavior: "you made `deviations_from_spec` a structured list with `{file, spec_rule, deviation, justification}` entries instead of a free-text field" (line 38). The contrast block is delivered cleanly without lecturing. The warning discussion after the Review Agent result is a genuine teaching moment — the facilitator explains why a separate reviewer catches things the builder considers fine (lines 172-175).

**Cycle 4 gap fixed:** The Cycle 4 eval's top weakness was "facilitator over-explains enterprise integration instead of coaching through questions." The exact fix suggested in Cycle 4 was: "answer the first one directly, then coach the remaining ones through questions." Cycle 19 does exactly this. When Sneha asks about PR integration (line 178), the facilitator answers directly: "the Review Agent's structured output is what you would template into a PR comment." Then for the escalation packet, the facilitator coaches through a question: "what fields does the packet need for the on-call person to act without re-reading the whole pipeline?" (line 182). Sneha then designs the packet herself. This is the correct Stage 3 Adaptive+Checkpoints pattern from teacher-instructions.md Section 11.

**Baseline comparison: IMPROVED** (4 → 5). Enterprise coaching pattern now matches the script's intent.

### 5. Pacing — 5/5

**Evidence for:** The session moves well. Task selection is quick and well-justified. The three-agent execution has appropriate wait-time insights that maintain momentum. The enterprise discussion flows naturally from the pipeline results. The bridge arises from Sneha's own mention of parallel reviewers — ideal bridge pattern.

**Cycle 4 gap addressed:** Cycle 4 was dinged for front-loading: Sneha's first response contained the entire pipeline design, safety rails, and E8 question in one block. Cycle 19 has better progressive disclosure. Sneha's first response (lines 18-21) describes the task scope. The facilitator then prompts for specialists (line 24). Sneha's pipeline design (lines 26-34) comes in a second, structured response. This is closer to the script's intended three-beat flow (task → specialists → handoffs/safety) even though Sneha still delivers specialists and handoffs together.

**Baseline comparison: IMPROVED** (4 → 5). Better progressive disclosure, less front-loading.

### 6. Stuck-Path Handling — N/A (no edge case triggered)

**Evidence:** No forced edge cases in this regression cycle. E8 data privacy did not arise naturally. No stuck paths, infrastructure breaks, or disengagement occurred.

**Baseline comparison: NOT COMPARABLE.** Cycle 4 scored 5/5 on E8 handling. This dimension cannot be scored for Cycle 19 since no edge case triggered. For the overall score calculation, I will carry forward the Cycle 4 baseline score of 5 to avoid penalizing the regression test for not triggering an edge case.

**Carried score: 5/5** (from baseline, untested this cycle).

### 7. Enterprise Readiness — 5/5

**Evidence for:** Enterprise concerns are handled well throughout. PR integration is answered directly without over-promising — "the Review Agent's structured output is what you would template into a PR comment" uses "when you wire this up" framing (line 180), matching Rule 11 exactly. The escalation packet discussion is coached through questions rather than delivered as a lecture. Contract versioning is validated as a real concern: "Version the contract schema and validate on receipt" (line 192).

**Cycle 4 gap fixed:** The Cycle 4 eval flagged two enterprise issues: (1) over-promising on capabilities ("The PR integration is straightforward" and "every agent's output is captured... That chain is your audit log"), and (2) file locking question left unanswered. In Cycle 19, the over-promising is gone — the facilitator uses design-target framing per Rule 11. The file locking question does not arise (Sneha raises contract versioning instead), but the facilitator's response to that question is appropriate and grounded.

**Baseline comparison: IMPROVED** (4 → 5). Over-promising eliminated, Rule 11 applied correctly.

---

## Summary Scores

| Dimension | Cycle 4 | Cycle 19 | Delta |
|-----------|---------|----------|-------|
| Script Faithfulness | 4/5 | 5/5 | +1 IMPROVED |
| Fourth-Wall Discipline | 5/5 | 5/5 | SAME |
| Mock Dev Realism | 5/5 | 4/5 | -1 REGRESSED |
| Pedagogy | 4/5 | 5/5 | +1 IMPROVED |
| Pacing | 4/5 | 5/5 | +1 IMPROVED |
| Stuck-Path Handling | 5/5 | 5/5* | SAME (carried) |
| Enterprise Readiness | 4/5 | 5/5 | +1 IMPROVED |
| **Total** | **31/35** | **34/35** | **+3** |

*Stuck-Path score carried from baseline — no edge case triggered in this regression cycle.

---

## Top 3 Improvements (Fixes Now Visible)

1. **Enterprise coaching pattern fixed (Pedagogy +1).** The Cycle 4 eval's top weakness — "facilitator over-explains enterprise integration instead of coaching through questions" — is fully resolved. The facilitator now answers the first enterprise question directly, then coaches remaining questions through prompts. Sneha designs her own escalation packet. This matches teacher-instructions.md Section 11 Stage 3 guidance exactly.

2. **Over-promising eliminated (Enterprise +1).** Cycle 4's "The PR integration is straightforward" is replaced with "when you wire this up, the Review Agent's structured output is what you'd template into a PR comment." Rule 11 (frame unbuilt capabilities as design targets) is now applied consistently. No assertions about capabilities that do not exist.

3. **Checkpoint and pacing tightened (Script +1, Pacing +1).** The missing checkpoint framing from Cycle 4 is addressed through a natural summary that covers all three checkpoint requirements. Pacing improved through better progressive disclosure — Sneha's responses are spread across multiple turns instead of arriving in one front-loaded block.

---

## Regressions

**Mock Dev Realism: -1 (5 → 4).** The Haiku-generated Sneha is competent but less distinctive than Cycle 4's GPT 5.4 Sneha. Three specific losses:
- No spontaneous E8 data privacy question (Cycle 4's strongest persona moment)
- Less distinctive enterprise vocabulary (missing "compliance-grade traceability," "policy violation")
- No designed flaw triggered — handoffs arrive fully structured, removing the coaching opportunity

This is a **model quality issue**, not a script regression. The teaching script and facilitator behavior are both better than Cycle 4. The persona simulation is weaker because Haiku generates a more generic enterprise developer than GPT 5.4 did.

**No dimension dropped 2+. No revert flag.**

---

## Revert Recommendation

**NO REVERT.** The regression is +3 net (31 → 34). The one dimension that dropped (Mock Dev Realism, -1) is attributable to the mock developer model (Haiku vs GPT 5.4), not to script or facilitator degradation. All facilitator-controlled dimensions improved or held steady. The three specific fixes called out in the Cycle 4 eval (enterprise over-explaining, over-promising capabilities, missing checkpoint) are all visibly resolved.

**Regression verdict: PASS.** 15 cycles of improvements did not degrade Stage 3. They improved it.
