# Cycle 19 Evaluation -- Codex

**Cycle:** 19
**Type:** Regression against Cycle 4
**Module:** Stage 3.1-3.3 three-agent-pipeline
**Persona:** Sneha, practical/enterprise platform engineer
**Edge cases:** None forced
**Evaluator stance:** Independent evaluator, regression-focused, using the stricter artifact-level standard from the Cycle 4 Codex eval

## Score

**Overall: 27/35. Regression verdict: PASS, no revert.**

The facilitator-controlled parts of the Stage 3 session improved: enterprise integration is framed as design work instead of current capability, the escalation-packet question is handed back to Sneha, the file-scope contradiction from Cycle 4 is repaired by explicitly exempting test files, and the final checkpoint summary covers role separation, structured handoffs, and stop rules.

The main problems are not new script regressions. The transcript artifact still includes internal eval ratings and dimension names inside `=== SIMULATION NOTES ===`, which remains a fourth-wall artifact leak under the Cycle 4 Codex standard. The mock developer also became too clean for the regression harness: the overnight loop explicitly says Stage 3 mock developers should include at least one subtle pipeline flaw, but Sneha's design is nearly perfect from the start.

## Regression Scores

| Dimension | Cycle 4 Codex | Cycle 19 Codex | Delta | Notes |
|---|---:|---:|---:|---|
| Script Faithfulness | 3/5 | 4/5 | +1 | Stage 3 beats are present and the checkpoint is now synthesized. Deduction: the regression harness's Stage 3 mistake instruction is not really exercised. |
| Fourth-Wall Discipline | 3/5 | 3/5 | 0 | Dialogue is clean, but the transcript file still contains internal ratings, dimension names, concept status, and wait-time insight metadata after `=== SIMULATION NOTES ===`. Same artifact-level issue as Cycle 4. |
| Mock Dev Realism | 4/5 | 3/5 | -1 | Sneha is credible but too polished. She designs fully structured handoffs immediately, raises no natural enterprise objection like E8, and leaves little for the facilitator to coach. |
| Pedagogy | 3/5 | 4/5 | +1 | Enterprise coaching pattern improved: answer the PR-comment shape, then ask Sneha what the escalation packet needs. Deduction: the session is more demonstration than coaching because the mock developer supplies an all-strong design. |
| Pacing | 4/5 | 4/5 | 0 | Smooth and less front-loaded than Cycle 4, but Sneha still supplies specialists, handoffs, scoped context, and safety rails in one major response. |
| Stuck-Path Handling | 3/5 | 4/5* | +1 | No edge case triggered. Carried as a neutral/improved score because Cycle 4's E8 overclaiming problem did not recur, but this dimension is not directly tested. |
| Enterprise Readiness | 3/5 | 5/5 | +2 | The Cycle 4 overclaiming is fixed. "When you wire this up" frames PR integration correctly, and Sneha designs escalation-packet fields and contract versioning herself. |

*Stuck-path handling is not directly comparable because Cycle 19 forced no edge case. I would not use it as evidence of E8 quality.

## Key Checks

**Does the Cycle 4 scope-contract bug recur? No.**

Cycle 4's contract said only `auth.py` and `blog.py` were allowed, then the build changed test files and the review still claimed no scope violation. Cycle 19 changes the acceptance criterion to "No changes to files outside auth.py and blog.py (test files excepted)." The Review Agent then treats `test_auth.py` and `test_blog.py` as allowed test changes. That specific contradiction is repaired.

**Does enterprise overclaiming recur? No.**

Cycle 4 used phrasing like "The PR integration is straightforward" and implied current audit-log behavior. Cycle 19 says, "when you wire this up, the Review Agent's structured output is what you would template into a PR comment." That matches teacher-instructions Rule 11: frame unbuilt capabilities as design targets, not current facts. The escalation discussion is also better: the facilitator asks what packet fields the on-call person needs, and Sneha designs the answer.

**Does transcript cleanliness pass? No.**

The developer-facing turns are clean, but `ideas/overnight-pipeline/transcripts/cycle-19.md` still includes internal material after the transcript:

- `**Eval Ratings (internal - not shown to developer):**`
- Dimension names such as `ROLE SPECIALIZATION`, `HANDOFF CONTRACTS`, `SAFETY RAILS`, and `SCOPED CONTEXT`
- Rating labels such as `Strong`
- `Concept status after session`
- `Wait-time insights used`
- `Regression verdict`

This is the same kind of artifact leak the Cycle 4 Codex eval flagged. It is not a new regression, but it is still not fixed.

**Does the Stage 3 regression harness test the intended failure mode? Not really.**

The loop prompt says Stage 3 mock developers should "Design a pipeline with at least one flaw - roles that overlap, missing handoff contracts, or no escalation path. Don't make it obviously wrong." Cycle 19 does not do that. Sneha gives distinct roles, typed handoff contracts, scoped context, retry/escalation policy, out-of-scope blocking, PR-comment expectations, escalation-packet fields, and contract versioning. The only warning is a low-severity message-order edge case from the Review Agent. That makes the session look strong, but it weakens the regression test because the facilitator is not forced to coach a real Stage 3 miss.

## Top Strengths

1. **Enterprise coaching is materially better than Cycle 4.** The facilitator answers the first integration question directly, then asks Sneha to design the escalation packet. This is exactly the Stage 3 guidance from `teacher-instructions.md`.

2. **The file-scope contradiction is fixed.** The contract now distinguishes production file scope from test file exceptions, so the Review Agent's "no out-of-scope modifications" claim is internally consistent.

3. **The Stage 3 summary lands naturally.** The final stock-taking names the real concepts: specialist roles, structured handoffs, a thresholded escalation route, and team-scale contract versioning.

## Top Weaknesses

1. **Internal eval metadata still lives in the transcript artifact.**

This is not visible to the developer in the simulated dialogue, but evaluators and future pipeline steps read the transcript file. Keeping ratings and dimension names there continues the artifact hygiene problem from Cycle 4 and Cycle 6. The fix is still to move simulation notes with eval ratings, concept status, and wait-time insight metadata into `logs/cycle-N-simulator.md`, leaving `transcripts/cycle-N.md` as developer-visible dialogue plus code-operation/result blocks only.

2. **The mock developer violates the Stage 3 mistake-realism instruction.**

Sneha's pipeline is essentially all-strong before the facilitator does any meaningful coaching. For a regression harness, that is too easy. The next Stage 3 regression should force one subtle flaw, such as a prose-only deviation field, missing schema version, ambiguous test-file allowlist, or an escalation threshold without packet fields. Then the facilitator can prove it catches and coaches the gap.

3. **The advertised mock model is ambiguous.**

The transcript says "Haiku (pre-generated responses)" while the simulator log says "Haiku (simulated by Opus)." The cycle plan says odd cycles should use a Haiku subagent at each interaction point. If Opus simulated Haiku rather than actually invoking Haiku, the model-diversity claim for the regression is weaker and should be logged honestly.

## Specific Fixes Needed

1. **Fix transcript artifact hygiene in the simulator harness.** Move internal eval ratings, dimension evidence, concept status, wait-time insight usage, and regression verdict metadata out of transcript files and into simulator logs.

2. **Enforce Stage 3 mistake realism in mock-developer generation.** For Stage 3 runs, require one subtle but coachable pipeline flaw. The flaw should appear in the developer's proposed design, not only in a synthetic Review Agent warning after the pipeline is already running.

3. **Clarify actual mock model provenance.** If Haiku was not actually invoked, label the cycle as Opus-simulated Haiku and do not count it as a true Haiku model-diversity run.

## Revert Recommendation

**No revert.** No score drops by 2+ points against the stricter Cycle 4 Codex baseline. The only material regression-like concern is mock developer realism at -1, and that is a simulator/test-harness issue rather than a Stage 3 teaching-script degradation. The enterprise and scope-contract fixes from Cycle 4 are visibly improved.

## Bottom Line

Cycle 19 passes as a Stage 3 regression: the teaching script did not degrade, and the Cycle 4 enterprise-overclaiming and scope-contract issues are better. It should not be treated as a full clean bill of health because the transcript metadata leak still exists and the mock developer did not exercise the intended Stage 3 failure mode.
