# Module V1 Codex Evaluation: Opus vs. Codex

## Executive Summary

If Stage 5 is excluded as requested, Codex is the stronger operational module set by a narrow but real margin. Its best work is not prettier prose; it is better runnable scaffolding: safer Stage 0 branch handling, richer Stage 3 handoff contracts and scoped context, execution evidence in parallel review, and stronger Stage 7 metrics and self-edit recipes. Codex is more likely to produce reusable recipes that a developer would run after training.

If choosing a complete 8-stage package today, Opus wins by default because Codex has no Stage 5. Stage 5 is not a small omission; it is the verification stage that makes later autonomy defensible. A training sequence that jumps from spec/pipeline work to overnight operation without the eval layer would teach the wrong progression.

The best answer is a hybrid. Start from Opus for completeness and richer facilitator coaching in Stages 1, 2, and 6. Cherry-pick Codex's operational improvements in Stages 0, 3, and 7. The two sets are too similar in multiple places to treat them as fully independent alternatives; several files are byte-identical or structurally identical except for punctuation.

## Stage-by-Stage Comparison

### Stage 0: See What AI Can Do

Winner: Codex, narrowly.

Codex has the stronger working recipe. `stage-0-welcome.yaml` checks git status, creates a unique practice branch if `practice/stage-0` already exists, preserves pre-existing user changes, forbids whole-repo resets, writes structured progress state, and asks before deleting the branch. That is the right operational posture for a first-time AI-coding experience. Opus creates `practice/stage-0` and then deletes it after Act 5, which is cleaner but less defensive.

Opus has the richer teaching scripts. Its Act 4 script names the concept, duration, prerequisites, and bridge to Act 5, and the private bug-generation prompt is more detailed. Codex compresses the same flow and adds useful `# tier: reasoning` / `# tier: fast` annotations, but it loses some of the facilitator scaffolding and bridge language. The Codex version is better to run; the Opus version is slightly better to teach from.

Recommendation: Use Codex `stage-0-welcome.yaml`; use Opus act scripts or restore Opus's bridges/prerequisite notes into the Codex scripts.

### Stage 1: Get Real Work Done

Winner: Opus, narrowly.

Opus is stronger as teaching material. Across `bug-fix`, `test-writer`, `code-review`, and `refactor`, it gives fuller stuck paths, richer examples, and more specific weak-rating coaching. The test-writer script includes the concrete trivial-test contrast (`true == true`) and has a more complete sequence around scope, execution, quality, and iteration. The refactor script also explicitly separates baseline testing from post-refactor verification in a way that reads like a facilitator can execute it immediately.

Codex is stronger in several standalone recipes. Its `code-review.yaml` adds residual risks and impact fields, and it explicitly warns against treating architecture preferences as defects. Its teaching scripts also do something useful: they prompt earlier. For example, Codex test-writer asks the developer to inspect whether assertions would catch a real bug before the eval step. That is better live facilitation than waiting until the end.

The weakness in Codex Stage 1 is compression. It often keeps the same dimensions but removes detail that makes coaching natural. For example, Codex code-review keeps "healthy skepticism" but shortens weak coaching to "Always probe," while Opus gives concrete follow-ups such as asking about edge cases or production failure. That specificity matters for a teaching wrapper.

Recommendation: Use Opus teaching scripts. Cherry-pick Codex's stronger recipe return fields, residual risk handling, and proactive assertion-quality prompt.

### Stage 2: Two AIs Are Better Than One

Winner: Opus, with Codex pieces to keep.

The Stage 2 working recipes are byte-identical across both versions, so the difference is entirely in teaching design. Opus is more complete. Its spec-first script includes four dimensions, including the conditional "spec as contract" dimension for cases where the builder drifts from the acceptance criteria. That is an important teaching moment: the spec is not just a planning artifact, it is how the developer holds the builder accountable.

Codex has two good improvements. First, its spec-first script adds "spec ownership," which directly evaluates whether the developer approved or clarified the definition of done instead of letting AI invent it. Second, its review-gate dimensions are slightly cleaner operationally: "outcome verification," "evidence quality," and "gate decision discipline" are observable and map well to the goal of making a gate block on evidence rather than tone.

Opus still wins because it provides more complete facilitator language and deeper checkpoint framing. The richer quality-dimension tables give the facilitator concrete language for Strong, Adequate, and Weak cases. Codex's shorter version is easier to read but sometimes thins out the mental model.

Recommendation: Start from Opus Stage 2 teaching. Add Codex's "spec ownership" dimension and the review-gate "gate decision discipline" framing.

### Stage 3: Build a Team of AI Specialists

Winner: Codex, clearly.

Codex is better both as a working recipe set and as a teaching set. `three-agent-pipeline.yaml` adds explicit parameters for `role_plan`, `handoff_contracts`, and `safety_policy`, which match the teaching flow where the developer designs the pipeline before execution. It also defines concrete JSON handoff shapes such as `task_summary`, `affected_files`, `constraints`, `acceptance_criteria`, `changed_files`, `test_results`, and `deviations_from_spec`. Opus describes contracts conceptually; Codex makes them executable.

Codex also adds "scoped context" as a first-class quality dimension. That is not a minor wording change. Multi-agent systems fail when every agent sees the full transcript and inherits the same assumptions. Codex evaluates whether each agent gets only the context needed for its role.

For `parallel-reviewers`, Codex again improves the operational design. It adds an execution layer, captures command/exit-code evidence, records scoped temp paths under a run ID, returns cleanup status, and evaluates result merging as its own dimension. Opus has good coaching language around layered testing and temp-file collisions, but Codex's recipe is closer to something I would trust in a real parallel run.

Recommendation: Use Codex Stage 3. Bring over a few Opus coaching examples where they are more vivid, especially the "pipeline vs. one agent with helpers" contrast.

### Stage 4: From Idea to Buildable Spec

Winner: Tie.

These files are effectively the same. The working recipes have the same structure, parameters, one-pager requirement, persona-oriented requirements guidance, success criteria, kill criteria, and "do not skip the one-pager" rule. `spec-review.teach.md` is byte-identical. The other teaching files differ mostly by punctuation and encoding style.

The shared design is solid: six concrete one-pager questions, quality dimensions for concreteness and completeness, progressive elaboration discipline, and bridges into persona decomposition and spec review. But because the versions are so similar, there is no meaningful model-level winner.

Recommendation: Use either. Treat this stage as a provenance warning rather than an A/B decision.

### Stage 5: Trust But Verify

Winner: Opus by existence, but not scored head-to-head.

Codex Stage 5 is missing, so it cannot be evaluated under the "both versions exist" rule. This is still a major product gap. Stage 5 is where the program teaches eval design, eval layers, isolation, ratchets, gates, and verification discipline before autonomous operation. Opus has the full Stage 5 set; Codex has none.

Recommendation: Use Opus Stage 5 until Codex regenerates this stage in a focused pass.

### Stage 6: Let It Run While You Sleep

Winner: Opus.

The Stage 6 working recipes are identical, so the difference is in teaching usability. Opus is better because it gives direct facilitator language where Codex often gives meta-instructions. In `cycle-review.teach.md`, Opus says: "Here is the cycle-level read..." and "This is the part I would not let pass as green..." Codex says to start with a one-paragraph assessment and name the success claim. The Codex version is understandable, but it requires the facilitator to translate instructions into user-facing speech.

The same pattern appears in `continuous-dev.teach.md`. Opus gives a direct operational handoff: "I made three things durable..." Codex says to name the learning, memory, and lifecycle. For a fully adaptive consulting mode, the facilitator still benefits from concrete phrasing.

Recommendation: Use Opus Stage 6 teaching scripts. Recipes are identical, so no recipe decision is needed.

### Stage 7: The System Gets Smarter Over Time

Winner: Codex, with one safety caveat.

Codex is stronger in `metrics-dashboard.yaml`. It explicitly searches for pre-change and post-change data, handles missing historical data by creating a baseline without pretending a before/after verdict exists, and prevents comparing two current snapshots from the same run. That last rule is important; otherwise the dashboard can manufacture a meaningless comparison.

Codex is also stronger in `metrics-dashboard.teach.md`. It evaluates metric selection, baseline discipline, data skepticism, and side-effect awareness. Opus evaluates a similar area, but Codex's side-effect awareness dimension is sharper because pipeline changes often improve the intended metric while damaging another one.

For `pipeline-self-edit.yaml`, Codex moves from audit-only to safe consolidation edits plus verification. That improves reusability, but it is also the safety caveat: instruction-file edits should remain conservative and ideally opt-in when the developer is still learning the pattern. Codex does include safeguards: do not remove potentially outdated guardrails automatically, do not resolve conflicts without evidence, and run verification if available.

`skill-evolution` is essentially the same between versions except for punctuation/encoding. The deciding differences are in metrics and self-edit operationalization.

Recommendation: Use Codex Stage 7 recipes and metrics teaching. Keep Opus's more conservative audit-first stance as a mode or flag for `pipeline-self-edit` when running in teaching mode.

## Specific Strengths of Each Version

### Opus Strengths

- Stronger facilitator language in several teaching scripts, especially Stages 1, 2, and 6.
- More complete coaching examples for Weak/Adequate cases, with concrete contrast examples instead of generic prompts.
- Better direct usability for facilitators: more "say this" language and fewer meta-instructions.
- Complete Stage 5 coverage.
- More conservative in Stage 7 `pipeline-self-edit`, which is safer for an audit-first teaching flow.

### Codex Strengths

- Better operational safety in Stage 0: unique branch fallback, no whole-repo reset, explicit preservation of pre-existing changes, and approval before branch deletion.
- Stronger standalone recipes in Stage 1, especially richer review outputs with impact and residual risks.
- Better Stage 3 architecture: explicit role plan, handoff contract, safety policy parameters, concrete JSON handoff schemas, scoped context as an eval dimension, execution evidence in parallel review, and result-merge discipline.
- Better Stage 7 measurement logic: baseline handling, no fake same-run comparisons, side-effect awareness, and clearer metrics-to-change mapping.
- More reusable late-stage recipes because they include verification and operational artifacts, not just reports.

## Common Weaknesses

- Neither module set appears to be runtime-validated against Goose. The recipes are plausible YAML, but there is no evidence that parameter templating, sub-recipe invocation, extension behavior, or structured return formats were executed.
- Progression-state updates are underspecified. Both sets write to `.goose/state/progression.json`, but neither provides a robust schema migration story, concurrency handling, corruption recovery, or an actual state update helper.
- Teaching and working layers still depend on convention rather than enforcement. The recipes tell agents not to share context, not to edit source in parallel, and not to trust self-reports, but the enforcement mechanism is mostly prompt-level.
- Later-stage scripts sometimes combine multiple concepts into a long session. Stage 3 and Stage 6 are conceptually coherent, but they stretch the "one skill" scorecard criterion.
- Several stage transitions assume the developer has real artifacts available. Stuck paths exist, but the quality of the substitute task depends heavily on the code-work subagent finding a good example.
- The two module sets are not independent enough to serve as strong cross-validation. Identical files and repeated structure reduce the value of "both versions agree."

## Recommendations

| Stage | Use | What to cherry-pick |
| --- | --- | --- |
| 0 | Codex recipe + Opus teaching text | Keep Codex branch/state safety; restore Opus bridges and fuller private bug prompt. |
| 1 | Opus teaching, Codex recipe improvements | Add Codex residual-risk fields and proactive assertion-quality prompt. |
| 2 | Opus base | Add Codex spec ownership and gate decision discipline. |
| 3 | Codex | Add a few Opus coaching examples, but keep Codex contracts, scoped context, and parallel merge design. |
| 4 | Either | Treat as shared baseline; no meaningful cherry-pick needed. |
| 5 | Opus | Regenerate Codex Stage 5 separately before any full Codex rollout. |
| 6 | Opus teaching | Recipes are identical; keep Opus direct facilitator language. |
| 7 | Codex | Add an audit-only mode for `pipeline-self-edit` during teaching. |

Overall hybrid: use Opus as the complete scaffold, then replace or patch Stages 0, 3, and 7 with Codex's operational improvements. Do not ship a Codex-only package until Stage 5 exists.

## Cross-Contamination Assessment

The two sets do not look fully independently generated.

Evidence for strong shared influence:

- Stage 2 working recipes are byte-identical across Opus and Codex.
- Stage 6 working recipes are byte-identical across Opus and Codex.
- `teaching/stage-4/spec-review.teach.md` is byte-identical.
- Stage 4 files and Stage 7 `skill-evolution` content are nearly the same except for punctuation/encoding changes.
- Multiple teaching scripts share the same dimensions, order, coaching structure, and examples.

Some differences are real and model-specific: Codex Stage 3 has different parameters and explicit JSON contracts; Codex Stage 7 metrics has additional baseline and same-run-comparison safeguards; Opus Stage 1 and Stage 6 have richer facilitator speech. Those are not just punctuation changes.

My assessment: the similarity is too high to treat this as a clean blind comparison. The most likely explanation is a mix of a highly prescriptive shared blueprint plus possible root-directory influence during generation. For stages where files are identical or almost identical, agreement should not be counted as independent validation. For Stages 0, 1, 3, and 7, the differences are substantive enough to support selective cherry-picking.
