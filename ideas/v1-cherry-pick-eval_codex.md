# V1 Cherry-Pick Evaluation: Claude vs Codex

Static review only: I compared the requested 9 pairs against the module-designer scorecard, the Bug Fix reference module, the eval prompt template, and the relevant originals for the 6 cherry-pick patches. I did not runtime-validate the Goose YAML.

## Pair 1: test-writer.teach.md
**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8/10
**Key differences:**
- Both versions apply the intended patch in the right place: after test results and before eval/coaching.
- Claude adds a fuller proactive assertion-quality moment: why the check matters, how to respond if the developer engages, and what to do if they dismiss it too quickly.
- Codex is cleaner and less intrusive, but it is mostly a single prompt and gives the facilitator less help adapting the moment.
**If Hybrid, take from each:** Use Claude's branching guidance, but consider Codex's shorter opening sentence if the teaching script needs to stay lean.
**Risks/issues in winner:** Claude's added block is somewhat long and mentions eval as private facilitator context. That is acceptable inside the script, but keep the user-facing phrasing free of eval references.

## Pair 2: code-review.yaml
**Winner:** Claude
**Score:** Claude 9/10 vs Codex 7.5/10
**Key differences:**
- Both add the requested `residual_risks` and `impact_classification` return fields without disturbing the rest of the recipe.
- Claude defines residual risks as non-blocking tracked items with location, risk description, and follow-up action; this is more directly usable.
- Claude's impact taxonomy - critical, significant, moderate, cosmetic - is closer to a real change-impact classification than Codex's "critical/warning/suggestion-only/no material impact," which mostly mirrors finding severity.
**If Hybrid, take from each:** Use Claude's field definitions. No Codex element is necessary beyond its shorter wording if brevity is desired.
**Risks/issues in winner:** Claude's `residual_risks` field is verbose for a return schema. If the recipe runner or downstream parser expects compact fields, shorten the description without changing the schema.

## Pair 3: spec-first.teach.md
**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8.5/10
**Key differences:**
- Both add the fifth "Spec Ownership" dimension to the quality table, eval prompt, and JSON return.
- Claude also adds a task-time watch prompt for AI-suggested criteria, which helps the facilitator coach ownership before the end-of-task eval.
- Codex places the dimension cleanly in the eval order and uses concise criteria, but it lacks Claude's live observation/repair hook.
**If Hybrid, take from each:** Use Claude as the base; optionally adopt Codex's concise "AI can draft criteria, but cannot know the product truth unless you confirm it" coaching phrasing.
**Risks/issues in winner:** Claude's Strong criterion may over-index on "wrote them in their own words." A developer can own AI-drafted criteria by editing, rejecting, or explicitly approving them, so keep that interpretation broad.

## Pair 4: review-gate.teach.md
**Winner:** Claude
**Score:** Claude 9/10 vs Codex 8/10
**Key differences:**
- Both sharpen the evidence-backed verdict dimension around execution evidence versus confident prose.
- Claude adds an explicit mid-task contrast block: test counts/exit codes are evidence; "well-structured" or "looks correct" is opinion. This is a stronger teaching move.
- Codex is more surgical and readable, but it only updates the quality table and eval criteria; it misses the live facilitator intervention.
**If Hybrid, take from each:** Use Claude's task-time contrast block and eval criteria. If length matters, use Codex's shorter table wording.
**Risks/issues in winner:** Claude's added contrast example is long. The facilitator should use it selectively when the gate output actually mixes execution output with prose opinions.

## Pair 5: three-agent-pipeline.teach.md
**Winner:** Hybrid
**Score:** Claude 8.5/10 vs Codex 7.5/10
**Key differences:**
- Claude better satisfies the patch intent: it adds vivid contrast examples not just for the role-specialization moment, but also for handoff contracts, retry loops, and scoped context.
- Codex's changes are cleaner but too narrow; they mostly improve the "one agent with helpers vs pipeline of specialists" wording.
- Claude's examples are more coachable, but one sentence in its role-specialization Weak coaching appears conceptually off: "A builder that never sees the spec..." should likely refer to the reviewer not seeing the builder's reasoning.
**If Hybrid, take from each:** Use Claude's richer contrast examples for handoff contracts, safety rails, and scoped context. Use Codex's cleaner role-specialization framing, or fix Claude's role-specialization Weak line to say the reviewer should not inherit the builder's reasoning or assumptions.
**Risks/issues in winner:** The hybrid needs one manual cleanup pass to remove the confusing builder/spec sentence and keep the expanded examples from making coaching feel like a lecture.

## Pair 6: pipeline-self-edit.yaml
**Winner:** Codex
**Score:** Claude 8.5/10 vs Codex 9/10
**Key differences:**
- Both add an `audit_only` boolean parameter with default `true` and adjust instructions so audit-only mode does not modify files.
- Claude is explicit about skipping edit and verification steps and changes the description to "optionally apply" edits.
- Codex gives the more useful output contract for audit-only runs: it reports proposed changes, a verification plan, and projected post-edit rule counts instead of only omitting applied-edit fields.
**If Hybrid, take from each:** Use Codex's `proposed_changes` and verification-plan return shape; consider Claude's `{{ audit_only | default: true }}` prompt default for extra template resilience.
**Risks/issues in winner:** Codex reports `rules_after` as projected when `audit_only` is true. That field should be named or documented clearly so downstream consumers do not treat projected counts as applied state.

## Pair 7: teacher-instructions.md
**Winner:** Codex
**Score:** Claude 8.5/10 vs Codex 9/10
**Key differences:**
- Both cover all 4 teaching modes, coaching voice rules, stuck paths, progression state, and all 8 stages.
- Codex is stronger as runtime facilitator guidance: it adds clear agent-role boundaries, delegation convention, dynamic content handling, missing-evidence handling, corrupt-state caution, and external-state repair.
- Claude is richer in stage-by-stage prose and concrete examples, but it is less compact and has more reference-manual texture than operational runtime guidance.
**If Hybrid, take from each:** Use Codex as the base. Cherry-pick Claude's fuller Stage 0, Stage 2, Stage 6, and Stage 7 guidance where the table form feels too compressed.
**Risks/issues in winner:** Codex's stage-specific guidance is concise. If this file is the only reference a facilitator loads, some of Claude's detailed stage nuance should be restored.

## Pair 8: escalation-routing.teach.md
**Winner:** Codex
**Score:** Claude 8.2/10 vs Codex 9/10
**Key differences:**
- Both follow the required teaching-wrapper structure and use observable dimensions: failure classification, threshold specificity, escalation evidence, and conditional cleanup awareness.
- Codex aligns more tightly with the working recipe: it names breaker states, failure classes, dirty-state risks, `safety_config`, cleanup actions, and failure packet fields.
- Codex adds a checkpoint after 3.3 and a safer state update rule: do not mark Stage 3 complete unless later concepts are already complete.
**If Hybrid, take from each:** Use Codex as the base. Borrow Claude's slightly fuller threshold-rationale coaching if the facilitator needs to explain why a retry number matters.
**Risks/issues in winner:** Codex's bridge includes two possible next paths - Stage 4 or continuing Stage 3. That is useful, but the wrapper should choose based on progression state rather than saying both every time.

## Pair 9: spec-to-pipeline.teach.md
**Winner:** Codex
**Score:** Claude 7.5/10 vs Codex 9/10
**Key differences:**
- Codex matches the syllabus: `spec-to-pipeline` is concept 4.4, "Every requirement must be testable." Claude labels it `Recipe 4.7` and treats it as a final Stage 4 capstone, which creates a progression mismatch.
- Codex has the clearer teaching flow: preflight testability check, conversion, coverage-matrix inspection, non-automatable handling, and pipeline execution-plan review.
- Claude's Stage 4 completion review is useful, but its concept numbering and "final module" framing make it risky as the base file.
**If Hybrid, take from each:** Use Codex as the base. Borrow Claude's broader Stage 4 completion recap only when the progression state confirms all Stage 4 concepts are complete.
**Risks/issues in winner:** Codex's eval dimension names differ from Claude's and from some likely state names (`traceability_discipline` instead of `traceability`). Ensure the state schema and any dashboard/reporting code use the Codex names.

## Summary Table

| Pair | File | Winner | Claude | Codex | Keep / Patch |
| --- | --- | --- | ---: | ---: | --- |
| 1 | `teaching/stage-1/test-writer*.teach.md` | Claude | 9 | 8 | Keep Claude; optionally shorten opening prompt. |
| 2 | `recipes/stage-1/code-review*.yaml` | Claude | 9 | 7.5 | Keep Claude field definitions. |
| 3 | `teaching/stage-2/spec-first*.teach.md` | Claude | 9 | 8.5 | Keep Claude; optionally adopt Codex phrasing. |
| 4 | `teaching/stage-2/review-gate*.teach.md` | Claude | 9 | 8 | Keep Claude; trim if needed. |
| 5 | `teaching/stage-3/three-agent-pipeline*.teach.md` | Hybrid | 8.5 | 7.5 | Claude examples + Codex/fixed role-specialization line. |
| 6 | `recipes/stage-7/pipeline-self-edit*.yaml` | Codex | 8.5 | 9 | Keep Codex; consider Claude prompt default. |
| 7 | `teaching/meta/teacher-instructions*.md` | Codex | 8.5 | 9 | Keep Codex; cherry-pick Claude stage nuance. |
| 8 | `teaching/stage-3/escalation-routing*.teach.md` | Codex | 8.2 | 9 | Keep Codex; optional Claude threshold-rationale coaching. |
| 9 | `teaching/stage-4/spec-to-pipeline*.teach.md` | Codex | 7.5 | 9 | Keep Codex; borrow Claude capstone recap only conditionally. |

## Overall Recommendation

Use a hybrid, but the split is not even:

- Keep Claude for the four narrow coaching-oriented cherry-picks in Pairs 1-4.
- Use a small hybrid for Pair 5 because Claude best satisfies the vivid-example intent but needs one conceptual cleanup.
- Keep Codex for the operational/runtime-oriented files in Pairs 6-9.

Net result: Claude is better when the task is to enrich facilitator coaching around an existing script. Codex is better when the task is to preserve operational contracts, state safety, concept numbering, and reusable runtime guidance.
