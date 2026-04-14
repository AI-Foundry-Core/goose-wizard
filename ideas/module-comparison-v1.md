# Module V1 Comparison: Claude Opus vs Codex (GPT 5.4)

## Summary

The two module sets are remarkably similar -- far more similar than one would expect from two different models working independently. Across all 8 stages, the recipes (YAML files) are often nearly identical in structure, parameters, instructions, and return formats. The teaching scripts share the same framing language, coaching phrases, eval dimensions, and facilitator delivery rules. The degree of convergence suggests both agents closely followed the module-designer skill and syllabus as their primary source material, producing outputs that are more like two transcriptions of the same blueprint than two independent interpretations.

Where differences exist, they are subtle and tend toward operational detail rather than conceptual divergence. Codex modules are slightly more concise and occasionally add a useful operational refinement (tier annotations in subagent prompts, explicit structured output specs in recipes, a fourth eval dimension for scoped context in Stage 3). Opus modules tend toward richer coaching language with more concrete contrast examples and slightly more prescriptive facilitator behavior descriptions. Neither version is clearly superior overall -- the differences are marginal.

The most significant finding is structural: Codex Stage 5 is entirely missing (timed out), leaving only Opus content for the "Trust But Verify" stage. For all other stages, the practical difference between versions is small enough that choosing a "winner" per stage is less useful than identifying the handful of specific improvements each version contributes to a best-of-both hybrid.

## Scorecard by Stage

### Stage 0: See What AI Can Do

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 8 | 8 | Both have 5 scripted acts with clear step boundaries, each 2-4 interactions |
| 2 | Clear I/O | 8 | 8 | Both define what the developer will experience before each act |
| 3 | Verifiable success | 7 | 7 | Scripted acts have observable outcomes (diff shown, undo verified, bug caught) but no eval subagent -- appropriate for scripted mode |
| 4 | One skill | 8 | 8 | Each act teaches exactly one concept (read, edit, undo, review, instruct) |
| 5 | Watch then do | 9 | 9 | Both follow demo-then-try pattern in every act |
| 6 | Minimal domain | 8 | 8 | Both use the developer's own code, avoiding external domain knowledge |
| 7 | Tool is the aha | 9 | 9 | The "wow" moment is AI reading/editing real code, not the code itself |
| 8 | Real code | 9 | 9 | Uses developer's actual codebase throughout |
| 9 | Relatable task | 8 | 8 | Reading code, making edits, undoing changes -- daily activities |
| 10 | Reusable recipe | 6 | 6 | Stage 0 is inherently a one-time experience; the working recipe is the onboarding flow itself |
| | **Total** | **80** | **80** | |

**Key difference:** Codex recipe adds explicit tier annotations (`# tier: reasoning`, `# tier: fast`) on subagent prompts and more granular safety rules (unique branch naming, never reset whole repo, preserve pre-existing changes). Codex also adds structured output at session end and defers branch deletion to developer approval rather than auto-deleting. Opus recipe is cleaner but less operationally defensive.

### Stage 1: Get Real Work Done

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 8 | 8 | Both: framing, task, results presentation, eval, coaching -- 3-5 developer interactions |
| 2 | Clear I/O | 8 | 8 | Both define what the developer provides (bug report, test target, PR, code smell) and what they get back |
| 3 | Verifiable success | 9 | 8 | Both have strong eval dimensions with Strong/Adequate/Weak rubrics. Opus coaching examples are slightly more concrete |
| 4 | One skill | 9 | 9 | Each recipe teaches one workflow (bug fix, test writing, code review, refactoring) |
| 5 | Watch then do | 8 | 8 | AI does the work first, developer evaluates -- appropriate for guided-adaptive mode |
| 6 | Minimal domain | 8 | 8 | Works on developer's own bugs, untested code, PRs -- no external domain needed |
| 7 | Tool is the aha | 9 | 9 | Speed of AI investigation/test generation/review is the impressive part |
| 8 | Real code | 9 | 9 | All four recipes operate on the developer's actual codebase |
| 9 | Relatable task | 9 | 9 | Bug fixing, test writing, code review, refactoring -- core developer activities |
| 10 | Reusable recipe | 9 | 9 | All four recipes are genuinely useful standalone tools post-training |
| | **Total** | **86** | **85** | |

**Key difference:** Opus test-writer teaching script has richer "stuck path" fallback instructions and more specific weak-rating coaching examples (e.g., "`true == true` passes no matter what"). Codex test-writer is more concise and directly prompts the developer to inspect assertion quality upfront rather than waiting for eval to catch it -- a subtle but useful facilitation improvement. Bug fix recipes are essentially identical between versions. Codex bridge language says "Recipe 1.2" explicitly where Opus says "next" -- minor consistency issue in Codex.

### Stage 2: Two AIs Are Better Than One

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 8 | 7 | Opus spec-first teaching is longer with more guided steps; Codex is tighter. Both add a stage completion checkpoint that extends turns but adds value |
| 2 | Clear I/O | 8 | 8 | Both define acceptance criteria as input and verified implementation as output |
| 3 | Verifiable success | 9 | 8 | Opus has 4 eval dimensions for spec-first (including conditional "spec as contract"). Codex has 3 dimensions -- simpler but misses the spec-as-contract scenario |
| 4 | One skill | 8 | 8 | Each recipe teaches one concept (builder-tester separation, review gating, spec-first) |
| 5 | Watch then do | 8 | 8 | Developer sees the two-agent pattern in action before being asked to design criteria |
| 6 | Minimal domain | 8 | 8 | Works on developer's real features/changes |
| 7 | Tool is the aha | 8 | 8 | Two agents catching each other's mistakes is the revelatory moment |
| 8 | Real code | 9 | 9 | Uses developer's actual codebase |
| 9 | Relatable task | 8 | 8 | Building features with tests, having work reviewed -- familiar activities |
| 10 | Reusable recipe | 8 | 8 | Spec-first, build-then-test, and review-gate are useful standalone workflows |
| | **Total** | **82** | **80** | |

**Key difference:** Opus spec-first teaching includes a full quality dimension table with inline coaching language for all three ratings per dimension, plus a conditional "spec as contract" dimension that triggers when the AI deviates from the spec. This is a richer evaluation framework. Codex spec-first adds a useful checkpoint question ("What's the practical difference between asking AI to build first and writing acceptance criteria first?") that tests conceptual understanding rather than just behavioral observation. Codex also adds "spec ownership" as an eval dimension -- a good addition that Opus handles less explicitly.

### Stage 3: Build a Team of AI Specialists

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 7 | 7 | Both cover 3 concepts in one teaching script, making them longer -- but concepts are naturally linked |
| 2 | Clear I/O | 8 | 8 | Both clearly define: developer designs pipeline roles/contracts, gets execution results back |
| 3 | Verifiable success | 8 | 9 | Both have strong eval dimensions. Codex adds "scoped context" as a 4th dimension -- a meaningful addition |
| 4 | One skill | 7 | 7 | Covers 3 concepts (roles, contracts, safety) in one teaching session -- justified by tight coupling but tests the boundary |
| 5 | Watch then do | 7 | 7 | Developer designs first, then sees execution -- reversed from earlier stages. Appropriate for this level |
| 6 | Minimal domain | 8 | 8 | Pipeline design is the skill being taught, not domain knowledge |
| 7 | Tool is the aha | 8 | 8 | Seeing a multi-agent pipeline execute on real code is impressive |
| 8 | Real code | 9 | 9 | Pipeline runs on the developer's actual codebase |
| 9 | Relatable task | 7 | 7 | Pipeline design is less immediately relatable than bug fixing, but scoped to a real development task |
| 10 | Reusable recipe | 8 | 8 | Three-agent-pipeline recipe is useful for ongoing multi-agent development |
| | **Total** | **77** | **78** | |

**Key difference:** Codex three-agent-pipeline recipe includes additional parameters (role_plan, handoff_contracts, safety_policy) that let the developer pass in their design directly -- better alignment with the teaching flow where the developer designs first. Codex recipe also specifies explicit JSON contract schemas in the instructions (fields like `task_summary`, `affected_files`, `constraints`, etc.) where Opus is more general. Codex eval adds "scoped context" as a quality dimension that Opus omits -- this is a genuine improvement since context scoping is critical for multi-agent work.

### Stage 4: From Idea to Buildable Spec

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 8 | 8 | Both have a clean two-phase flow (one-pager then elaboration) |
| 2 | Clear I/O | 9 | 9 | Both use the 6-question framework to define clear input expectations |
| 3 | Verifiable success | 8 | 8 | Both have identical eval dimensions with strong rubrics |
| 4 | One skill | 8 | 8 | Combines two tightly coupled concepts (concreteness + progressive elaboration) |
| 5 | Watch then do | 8 | 8 | Developer writes the spec, AI structures it -- developer drives throughout |
| 6 | Minimal domain | 8 | 8 | Uses developer's own feature ideas |
| 7 | Tool is the aha | 7 | 7 | The aha is the spec discipline, not the AI capability -- slightly weaker on this criterion |
| 8 | Real code | 8 | 8 | Connects to real codebase through TODO/feature gap scanning |
| 9 | Relatable task | 8 | 8 | Turning ideas into actionable specs is a recognized need |
| 10 | Reusable recipe | 7 | 7 | Idea-to-spec recipe is useful but might not be a daily tool |
| | **Total** | **79** | **79** | |

**Key difference:** These are functionally identical. The only textual differences are em-dash vs. hyphen formatting (Opus uses `--`, Codex uses `-`). Coaching language, eval dimensions, facilitation flow, and bridge text are the same word-for-word except for punctuation.

### Stage 5: Trust But Verify

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 8 | -- | Codex Stage 5 is missing (timed out) |
| 2 | Clear I/O | 8 | -- | |
| 3 | Verifiable success | 9 | -- | Strong eval dimensions including conditional "automation instinct" |
| 4 | One skill | 8 | -- | Each recipe teaches one eval concept (independence, layers, isolation, ratchets, gates, design) |
| 5 | Watch then do | 7 | -- | Fully adaptive mode -- less structured demo, more consulting |
| 6 | Minimal domain | 8 | -- | |
| 7 | Tool is the aha | 8 | -- | Independent verification catching discrepancies is a powerful moment |
| 8 | Real code | 9 | -- | Uses developer's actual pipeline outputs |
| 9 | Relatable task | 8 | -- | Verifying pipeline claims is immediately practical |
| 10 | Reusable recipe | 8 | -- | Eval-foundation and eval-layers recipes are useful ongoing tools |
| | **Total** | **81** | **N/A** | |

**Note:** Opus produced 6 recipes and 6 teaching scripts for Stage 5. This is the most comprehensive single-stage output in the entire set. Codex produced nothing -- the generation timed out.

### Stage 6: Let It Run While You Sleep

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 7 | 7 | Both cover 3 concepts in one teaching flow; consulting mode reduces unnecessary turns |
| 2 | Clear I/O | 8 | 7 | Opus facilitator response is more concrete ("Here is the cycle-level read..."). Codex uses meta-instructions ("Start with a one-paragraph assessment...") telling the facilitator what to do rather than showing it |
| 3 | Verifiable success | 8 | 8 | Identical eval dimensions and rubrics |
| 4 | One skill | 7 | 7 | Three related concepts in one session |
| 5 | Watch then do | 7 | 7 | Developer brings artifacts, facilitator reviews -- consulting mode |
| 6 | Minimal domain | 8 | 8 | |
| 7 | Tool is the aha | 7 | 7 | Catching "ceremonial success" is the revelatory moment |
| 8 | Real code | 8 | 8 | Reviews actual pipeline artifacts |
| 9 | Relatable task | 7 | 7 | Reviewing overnight runs is a real operational need |
| 10 | Reusable recipe | 8 | 8 | Cycle-review recipe is a genuinely useful operational tool |
| | **Total** | **75** | **74** | |

**Key difference:** Opus cycle-review teaching uses concrete facilitator language ("This is the part I would not let pass as green: [claim]...") while Codex uses meta-directives ("Name the success claim you would not let pass as green..."). The Opus approach is more immediately usable by a facilitator agent. Codex state update section is more concise and readable, listing rules in plain text rather than JSON. Recipes are identical.

### Stage 7: The System Gets Smarter

| # | Criterion | Opus | Codex | Notes |
|---|-----------|------|-------|-------|
| 1 | Few turns | 7 | 7 | Consulting mode; developer drives |
| 2 | Clear I/O | 8 | 8 | Both clearly define: findings in, instruction edits out |
| 3 | Verifiable success | 8 | 8 | Identical eval dimensions including conditional "curator loop understanding" |
| 4 | One skill | 8 | 8 | Covers curator pattern + instruction evolution as tightly coupled concepts |
| 5 | Watch then do | 7 | 7 | Fully adaptive -- developer initiates |
| 6 | Minimal domain | 8 | 8 | |
| 7 | Tool is the aha | 7 | 7 | The pipeline improving its own instructions is the aha |
| 8 | Real code | 8 | 8 | Uses developer's actual pipeline findings and skill files |
| 9 | Relatable task | 7 | 7 | System improvement is recognized as valuable but less frequently practiced |
| 10 | Reusable recipe | 8 | 8 | Skill-evolution recipe is a useful ongoing tool |
| | **Total** | **76** | **76** | |

**Key difference:** These are functionally identical. The only differences are punctuation (em-dash vs. hyphen) and Codex using a trailing extra space in one coaching line. Coaching language, eval dimensions, facilitator flow, and state update logic match word-for-word.

## Key Findings

### Where Opus is Stronger

1. **Stage 5 exists.** Opus produced 6 complete recipes and 6 teaching scripts for Stage 5. This is the single largest differentiator -- Codex has nothing here.

2. **Coaching language specificity.** In Stages 1 and 2, Opus teaching scripts include slightly richer contrast examples in coaching (e.g., the `true == true` example for weak test assertions, the detailed OAuth redirect example for weak bug context). These concrete examples make the coaching more immediately usable.

3. **Stage 2 spec-first depth.** Opus includes a "spec as contract" conditional dimension that triggers when the AI deviates from the developer's spec. This captures a real scenario that Codex misses.

4. **Stage 6 facilitator language.** Opus uses concrete facilitator speech ("This is the part I would not let pass as green: [claim]...") rather than meta-directives telling the facilitator what to say. This is more directly executable by a facilitator agent.

### Where Codex is Stronger

1. **Stage 0 operational safety.** Codex recipe includes tier annotations on subagent prompts, unique branch naming fallbacks, explicit "never reset whole repo" rules, developer-approved branch deletion, and structured end-of-session output. These are practical improvements for a real deployment.

2. **Stage 3 scoped context dimension.** Codex adds "scoped context" as a fourth eval dimension for the three-agent pipeline -- an important quality signal that Opus omits. Context scoping is critical for multi-agent reliability.

3. **Stage 3 recipe parameters.** Codex three-agent-pipeline recipe accepts role_plan, handoff_contracts, and safety_policy as explicit parameters, better supporting the teaching flow where the developer designs the pipeline before execution.

4. **Stage 3 explicit contract schemas.** Codex recipe instructions include specific JSON field definitions for agent handoffs (e.g., `task_summary`, `affected_files`, `constraints`, `acceptance_criteria`), making the "explicit contracts" concept concrete rather than abstract.

5. **Stage 2 spec ownership dimension.** Codex adds "spec ownership" as an eval criterion -- whether the developer actively owned the acceptance criteria vs. letting the AI define success. This is a valuable addition.

6. **Proactive facilitation in Stage 1.** Codex test-writer teaching prompts the developer to inspect assertion quality immediately ("Would these tests catch a real bug, or are any of them just checking that something exists?") rather than waiting for the eval to flag it. This is better teaching practice -- coach in the moment when possible.

### Common Weaknesses

1. **Extreme similarity masks independent validation.** The two versions are so similar that they cannot serve as independent quality checks of each other. Wherever both agree, it may reflect shared source material rather than convergent quality judgment.

2. **Later-stage reusable recipe scores are weaker.** Stages 5-7 recipes (eval-foundation, cycle-review, skill-evolution) are useful but less likely to be daily-use tools compared to Stage 1 recipes (bug-fix, test-writer). This is inherent to the subject matter, not a design flaw.

3. **Multi-concept teaching scripts stretch "one skill" criterion.** Stages 3, 6, and 7 combine 2-3 concepts into single teaching sessions. While the concepts are tightly coupled, this makes individual sessions longer and testing whether the developer has internalized each concept becomes harder.

4. **"Tool is the aha" weakens in later stages.** By Stage 4+, the impressive part shifts from "AI can do this" to "this discipline/process matters." The aha becomes organizational rather than tool-driven. This is expected given the progression, but it means later stages score lower on this criterion.

5. **No Goose-specific runtime validation.** Neither version has been tested against the actual Goose recipe runner. YAML syntax, parameter handling, sub-recipe invocation, and extension declarations are structurally plausible but unverified against Goose's actual parsing.

6. **State management is described but not enforced.** Both versions describe writing to `.goose/state/progression.json` but neither version includes schema validation, concurrent write handling, or recovery from corrupted state.

## Recommendations

| Stage | Recommendation |
|-------|---------------|
| 0 | Use **Codex** recipe (better operational safety), **Opus** teaching scripts (functionally identical but Opus has slightly more natural formatting) |
| 1 | Use **Opus** (marginally richer coaching examples). Cherry-pick Codex's proactive quality prompting in test-writer |
| 2 | **Hybrid.** Use Opus spec-first teaching (4 eval dimensions vs. 3). Add Codex's "spec ownership" dimension and checkpoint question |
| 3 | Use **Codex** (scoped context dimension, explicit contract schemas, better recipe parameters). Add Opus's detailed coaching language tables |
| 4 | **Either** -- they are functionally identical |
| 5 | **Opus only** -- Codex has nothing |
| 6 | Use **Opus** teaching (concrete facilitator language vs. Codex meta-directives). Recipe is identical |
| 7 | **Either** -- functionally identical |

**Overall strategy:** Create a hybrid "V2" that starts from the Opus set (which has complete Stage 5 coverage) and applies Codex improvements: Stage 0 operational safety, Stage 3 scoped context dimension and explicit contracts, Stage 2 spec ownership, and the proactive facilitation pattern from Stage 1 test-writer.

## Cross-Contamination Note

Stages 2-7 have potential cross-contamination because both agents wrote to the same root `recipes/` and `teaching/` directories. Opus was copied to `modules-v1-opus/` before Codex ran for most stages. After Codex completed, its output was copied to `modules-v1-codex/`. However, because the files are so similar across both versions -- often identical except for punctuation -- it is difficult to determine whether any cross-contamination occurred or whether the similarity is simply the result of both agents faithfully following the same detailed source material (syllabus + module-designer skill).

For Stages 4, 6, and 7, the teaching scripts and recipes are nearly word-for-word identical between Opus and Codex (differing only in em-dash vs. hyphen formatting). This could indicate: (a) both agents produced the same output independently, (b) one agent's output was still in the directory when the other ran and it influenced the result, or (c) the copied files are actually from the same source. Without version-controlled timestamps on each file, the provenance cannot be confirmed.

## Stage 5 Gap

Codex Stage 5 timed out during generation. The `modules-v1-codex/recipes/stage-5/` and `modules-v1-codex/teaching/stage-5/` directories exist but are empty. Only Opus content is available for Stage 5 ("Trust But Verify"), which includes 6 recipes (eval-design, eval-foundation, eval-gate, eval-isolation, eval-layers, eval-ratchet) and 6 corresponding teaching scripts. This is the most recipe-heavy stage in the entire system and may have been too large for Codex to complete within the timeout window.

If Codex Stage 5 is needed, it should be regenerated in a separate session with either a longer timeout or the stage split into smaller batches.

## Score Summary

| Stage | Opus Total | Codex Total | Delta |
|-------|-----------|-------------|-------|
| 0 | 80 | 80 | 0 |
| 1 | 86 | 85 | +1 Opus |
| 2 | 82 | 80 | +2 Opus |
| 3 | 77 | 78 | +1 Codex |
| 4 | 79 | 79 | 0 |
| 5 | 81 | N/A | Codex missing |
| 6 | 75 | 74 | +1 Opus |
| 7 | 76 | 76 | 0 |
| **Average** | **79.5** | **78.9** | **+0.6 Opus** |

All stages in both versions score above 70/100 and all individual criteria score 6 or above, meeting the quality gate from the module-designer skill.
