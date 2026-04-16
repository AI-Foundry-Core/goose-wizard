# Recipe 4.4: Spec to Pipeline - "Can the pipeline run this?"

Covers concept:
- 4.4 Every requirement must be testable

Mode: Adaptive + Checkpoints

This wrapper can run in two positions:
- As the focused 4.4 module after persona decomposition
- As a Stage 4 capstone after spec review, using the latest reviewed decomposed spec

> **Path resolution note.** All paths, spec reads, test spec writes, and
> skeleton test writes in this script act on the TARGET codebase (the
> developer's project). The parent recipe injected a TARGET PROLOGUE —
> whenever this script says `.goose/team_context.md`, "the repo," "the
> codebase," or "the spec," interpret those against `<TARGET>/`.
> Skeleton tests and coverage matrices belong under `<TARGET>/tests/`
> and `<TARGET>/specs/`, never in goose-wizard. Prepend the TARGET PROLOGUE
> to every `Delegate to subagent` call. Pass `target_codebase_path` to
> every sub-recipe.

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context, including stack, test framework, test commands, and conventions.

Read ~/.rilgoose/progression.json and check concepts 4.1 through 4.4.

Before starting, confirm concepts 4.1, 4.2, and 4.3 are complete or that the developer has an equivalent decomposed spec with persona-driven acceptance criteria. If those prerequisites are missing, bridge back to idea-to-spec or spec-decomposition before running this wrapper.

If concept 4.4 is already complete with all required dimensions adequate or strong:
"You've already shown the core testability move: requirements tracing to tests. Want to run this as a capstone on the latest spec, or skip ahead?"

If the developer skips:
- If concepts 4.1-4.3 are not all complete, bridge to the next incomplete module.
- If concepts 4.1 through 4.4 are all complete, bridge to Stage 5.

Prerequisite: The developer should have a decomposed spec with acceptance criteria, ideally from spec-decomposition. If they do not, either run spec-decomposition first or use an existing project spec with clear requirements.

If this is being run as a capstone after spec-review, use the reviewed version of the decomposed spec rather than the pre-review draft.

---

## Framing

"Can an AI pipeline actually execute against this spec? Let's turn the requirements into test specs, a coverage matrix, and an implementation plan."

Ask:
"Which spec should we use? Point me at the decomposed spec or the reviewed spec if you already ran the quality gate — or want me to scan the repo for the latest Stage 4 output?"

If the developer does not know the test framework:
"No problem. I can read the project context and infer the default test framework from the repo."

---

## Stuck Path

If the developer has no spec ready:
"No ready spec is fine. I can look for the latest Stage 4 output or a requirements doc we can use."

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  "Read <TARGET>/.goose/team_context.md and scan <TARGET>/ for recent Stage 4 spec artifacts, requirements docs, or decomposed specs with acceptance criteria. Prefer files that include persona use cases and Given/When/Then criteria. Return the best candidate absolute path under <TARGET>/, why it is usable, and any gaps that might block spec-to-pipeline conversion."

If no usable spec exists:
"We need a decomposed spec before this step has anything real to translate. Let's run spec-decomposition first, then come back to pipeline translation."

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "spec-decomposition"
  parameters:
    spec_path: {absolute path under <TARGET>/ — developer-provided requirements doc or best available spec}
    personas: {developer-provided personas, if any}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

Then continue with the produced decomposed spec (also under <TARGET>/).

---

## Phase 1: Preflight Testability Check

Before delegating to the recipe, ask the developer to inspect three acceptance criteria:

"Pick three acceptance criteria from the spec. For each one, tell me what kind of test it wants: unit, integration, e2e, or manual. Then name the setup, the action, and the expected result."

Listen for:
- Does each criterion have a clear pass/fail outcome?
- Does the developer distinguish automated tests from manual checks?
- Does the developer notice subjective language like "easy," "seamless," "professional," "fast," or "intuitive"?
- Does the developer choose the right test level, or make every test an e2e test by default?

If the developer gives a vague test idea:
"That's the direction, but make it executable. What state exists before the test, what action does the test perform, and what exact result proves it passed?"

If the developer says a subjective criterion is fine:
"An AI pipeline cannot test 'feels intuitive.' Rewrite it into an observable outcome: completion rate, number of steps, error rate, time threshold, or a binary accessibility check."

If the developer resists or tries to skip Phase 1 entirely:
Scale down to one criterion instead of skipping: "Just one. Pick the rate threshold — or whichever criterion feels most concrete. What exact test proves it works: what kind of test, what setup, what action, what result?"
Do NOT skip Phase 1. If the developer will not engage with even one criterion, note it and proceed, but flag test_specificity as untested in the eval context.

---

## Phase 2: Convert Spec to Pipeline Artifacts

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "spec-to-pipeline"
  parameters:
    spec_path: {absolute path under <TARGET>/ to decomposed or reviewed spec}
    test_framework: {developer preference or inferred project default}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent returns test specifications, non-automatable criteria, pipeline execution plan, skeleton test files, and coverage matrix.]

Present the result naturally:
"The conversion produced [N] test specs from [M] requirements. [K] criteria need attention because they are not fully automatable. The coverage matrix is the important artifact: it tells us whether every requirement has a test behind it."

Then ask:
"Let's inspect the matrix. Which requirement has the weakest trace to a test?"

If every requirement maps cleanly:
"Good. No orphan requirements. Now we check whether the tests are specific enough to run without another conversation."

If any requirement has no test:
"That's an orphan requirement. Either the requirement is not testable and needs rewriting, or the test plan missed it. We do not hand this to a build pipeline until every requirement traces to at least one test."

If the developer finds a weak trace (requirement maps to a test that does not fully prove it):
Do NOT proceed to the execution plan yet. Ask the developer to choose the repair: add a stronger test, split the requirement, or mark a manual gate. Then delegate a narrow matrix/test-spec revision to the code-work subagent covering only the changed traces. Re-present only the changed trace and ask whether it now proves the requirement.

"That trace is the gap. Before we hand this to a build agent, fix it. You have three moves: add a test that actually covers the requirement, split the requirement so each part has a real test, or mark it as a manual gate with an owner and pass/fail condition. Which one?"

Do not proceed to Phase 4 until every requirement traces to at least one test that would actually prove it. A build agent will execute the plan exactly as written — a known weak trace becomes a known weak build.

---

## Phase 3: Handle Non-Automatable Criteria

If the recipe returns non-automatable criteria:
"These are the weak points. A manual check is sometimes legitimate, but 'needs human judgment' is not a free pass. For each one, decide: rewrite it into an automated check, keep it as an explicit manual gate, or remove it because it is not really a requirement."

Ask the developer to choose one non-automatable criterion and rewrite it.

If the developer rewrites it well:
"That's now test-shaped: setup, action, measurable outcome. The pipeline can execute against that."

If the developer keeps it manual:
"That's fine as long as it is explicit. Write the manual gate with who performs it, what evidence they collect, and what pass/fail means."

If the developer ignores non-automatable criteria:
"Leaving these vague means the pipeline will either guess or skip them. Both are bad. Pick one and make the decision visible."

Optionally delegate a narrow revision (prepend the TARGET PROLOGUE):
  "Revise only the non-automatable criteria selected by the developer in the spec at <absolute path under <TARGET>/>. Write the update back to the same file under <TARGET>/. Convert them into automated criteria where possible. For true manual gates, define owner, evidence, and pass/fail condition. Preserve the rest of the spec."

---

## Phase 4: Pipeline Execution Plan Review

Ask:
"Would you hand this execution plan to a build agent now? Check three things: task order, dependencies, and which tests validate each task."

Listen for:
- Does each implementation task map back to one or more test IDs?
- Are dependency-heavy tasks ordered before dependent work?
- Are independent tasks identified for parallel work?
- Are side effects and teardown needs visible?
- Are skeleton test files organized by persona or use case, not random file names?

If the developer reviews the plan carefully:
"That is the handoff. A build agent can now take task [X], know which tests prove it, and know what depends on it."

If the developer accepts the plan without inspection:
"Pause before build. A pipeline plan can look complete while hiding a bad dependency. Check one task: what must exist before it starts, and which test proves it is done?"

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer turned acceptance criteria into a test-ready pipeline plan.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say - conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. TRACEABILITY DISCIPLINE (Concept 4.4)
   Strong: Developer inspected the coverage matrix or equivalent mapping and confirmed every requirement traces to at least one test. They noticed or asked about orphan requirements, duplicate/overbroad tests, or missing mappings.
   Adequate: Developer looked at the coverage matrix or test mapping but did not inspect it deeply. They accepted the main mapping without checking for weak traces or orphan requirements.
   Weak: Developer accepted the generated test plan without checking whether every requirement maps to a test.

2. TEST SPECIFICITY (Concept 4.4)
   Strong: Developer evaluated or wrote tests with explicit setup, steps/actions, expected results, and measurable pass/fail outcomes. They avoided subjective language and chose appropriate test levels such as unit, integration, e2e, or manual.
   Adequate: Developer made tests more concrete or identified obvious vague tests, but left some missing setup, ambiguous expected results, or unclear test levels.
   Weak: Developer accepted vague test descriptions such as "should work," "should be fast," or "user should have a good experience" without pushing for executable detail.

3. NON-AUTOMATABLE HANDLING (Concept 4.4)
   Strong: Developer engaged with criteria that could not be automated, rewrote at least one into a measurable automated check or explicitly marked it as a manual gate with owner, evidence, and pass/fail condition.
   Adequate: Developer acknowledged non-automatable criteria and discussed possible rewrites, but left the final handling partly vague or unresolved.
   Weak: Developer ignored non-automatable criteria, accepted "needs human judgment" without defining a manual gate, or treated subjective requirements as acceptable.

4. PIPELINE READINESS (conditional)
   Condition: Only rate this if the developer reviewed the pipeline execution plan or discussed handing it to a build agent.
   If condition not met: return rating=null, evidence="Not triggered - developer did not review the execution plan", coaching=null
   Strong: Developer checked task order, dependencies, test mappings, and parallelization or sequencing before treating the plan as build-ready.
   Adequate: Developer reviewed task order or test mappings but missed dependencies, sequencing risks, or parallelization constraints.
   Weak: Developer treated the execution plan as build-ready because it looked complete, without checking dependencies or which tests validate each task.

Return as JSON:
{
  "dimensions": [
    {"name": "traceability_discipline", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "test_specificity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "non_automatable_handling", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "pipeline_readiness", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. Coach naturally; do not list ratings.

Brevity rule: 1-3 sentences per dimension. Maximum. Pick one specific praise, one sharpening note, and the bridge. Do not recap what the developer did (they were there). Do not touch dimensions rated Adequate unless the coaching changes behavior. A colleague would not deliver six paragraphs of feedback after a working session.

### Traceability Discipline

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "You checked the matrix instead of trusting the generated plan. That is the habit: every requirement needs at least one test, and every test should point back to the requirement it proves." |
| Adequate | "You looked at the matrix, which is good. Next time go one level deeper: find the weakest requirement-to-test trace and ask whether that test would actually prove the requirement." |
| Weak | "Do not accept a test plan just because it is long. The coverage matrix is the proof. If a requirement has no test behind it, the pipeline can build the wrong thing and still look successful." |

### Test Specificity

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "Your test shape was executable: setup, action, expected result, and a clear pass/fail line. That is what lets a pipeline run without stopping to ask what 'done' means." |
| Adequate | "The test is close, but [specific missing part] is still doing too much work in the reader's head. Add the exact setup or expected result so two agents would write the same test." |
| Weak | "A test like '[quote vague test]' is not executable. Compare it to: 'Given a new user with an empty cart, when they add item X and check out, then the order is created and the total equals Y.' The second one can become a test." |

### Non-Automatable Handling

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "Good handling of the manual edge. You either rewrote it into something measurable or made the manual gate explicit. The pipeline knows what it can automate and what needs a human decision." |
| Adequate | "You spotted the non-automatable bit. Now close the loop: either rewrite it into a measurable check or define the manual gate with owner, evidence, and pass/fail condition." |
| Weak | "'Needs human judgment' is not a requirement yet. If it stays manual, say who judges it and what evidence they use. If it should be automated, rewrite the subjective word into a number or binary outcome." |

### Pipeline Readiness

| Rating | Facilitator Says |
|--------|------------------|
| Strong | "That is build-ready: tasks are ordered, dependencies are visible, and each task has tests that prove it. A build agent can execute that without guessing." |
| Adequate | "The order looks reasonable, but check the dependency line before handing it off. A good pipeline plan says what must already exist and which tests prove each task is done." |
| Weak | "A complete-looking plan is not the same as a build-ready plan. Pick one task and ask: what does it depend on, what can run in parallel, and which test proves it passed?" |

---

## Enterprise Grounding

Before bridging, ask one enterprise workflow question. Choose the most natural fit for the session:

- "Where would this coverage matrix live for your team: in the spec PR, the test plan, or a CI artifact?"
- "On your team, who would need to sign off on this spec before you built from it?"
- "Do your existing tests follow a naming convention or directory structure that these skeleton files should match?"

One question. One follow-up at most. Do not turn this into a workflow design session.

---

## Wait-Time Insights

Ordered list of insights to share during subagent operations. Use one per code operation. Do not repeat. Do not share during challenge assessments (teacher-instructions.md rule 8).

1. [define-success] "The spec is not documentation. It is the input the pipeline reads. If the spec is vague, the pipeline guesses."
2. [verify] "Coverage matrices are the contract between spec and implementation. A requirement without a test is a promise nobody checks."
3. [specificity] "Setup, action, expected result. If a test does not have all three, two agents will write two different tests from the same spec."
4. [feedback-loops] "The review agent checks alignment, not correctness. It can confirm the build matches the spec — it cannot confirm the spec is right."
5. [enterprise] "In a team, the coverage matrix is also a review artifact. It tells a reviewer what is tested without reading every test file."
6. [iteration] "A weak trace found before build is a two-minute fix. The same gap found after build is a rework cycle."

---

## Checkpoint

This is the concept 4.4 checkpoint and can also serve as a Stage 4 completion checkpoint if concepts 4.1 through 4.4 are all complete.

If all required 4.4 dimensions are Adequate or Strong:
"You have the requirement-to-test move now. The spec is no longer just a document; it is a pipeline input with traceability, executable tests, and a build plan."

If any required 4.4 dimension is Weak:
Coach the weak dimensions, then ask the developer to fix one requirement-to-test trace before closing:
"Let's tighten one trace before we move on. Pick the weakest requirement, rewrite the test spec until it has setup, action, expected result, and a clear pass/fail condition."

If Stage 4 is not yet complete (concepts 4.1-4.3 still incomplete):
"There are earlier spec modules to complete. Check your progress with Start Here."

If all Stage 4 concepts are complete:
"That closes the spec stage. You can now turn an idea into a spec an AI team can build from: concrete, persona-driven, testable, reviewed, and honest about when to stop."

---

## Recipe Reveal
After the checkpoint, show the developer the recipe behind this session.

"Fifteenth recipe. Final one in the Stage 4 chain — and the one that makes everything
before it actionable. It takes the reviewed spec and produces the artifacts a build
pipeline needs to execute."

Read the Spec to Pipeline recipe (recipes/agents/spec-to-pipeline.yaml) and show the developer:
- The **'NEVER leave a requirement without a corresponding test' constraint** — "Look
  at Constraints. That's the traceability-discipline dimension you were rated on, as a
  hard rule the agent won't break. Every acceptance criterion gets a test spec, or the
  agent flags it as non-automatable. No orphan requirements, period."
- The **`coverage_matrix` return field** — "The return block has `coverage_matrix:
  Requirement-to-test traceability matrix.` That matrix you were coached to inspect
  isn't a nice-to-have output — it's a required return value. The agent can't finish
  without producing it. That's why 'which requirement has the weakest trace' is
  always a question you can ask."
- The **`non_automatable` flagged separately from tests** — "Look at the returns:
  `test_specifications` and `non_automatable: Criteria needing human judgment +
  suggested rewrites` are separate fields. The agent doesn't silently skip the
  untestable criteria or pretend it can automate them — it surfaces them with a
  suggested rewrite so you can decide: rewrite into an automated check, keep as an
  explicit manual gate, or drop the requirement. That's the non-automatable-handling
  dimension, enforced as a structured output."
- The **`pipeline_plan` with dependencies and parallelization** — "Process step 4:
  'ordered tasks, test mappings, dependencies, parallelization opportunities.' That's
  the full execution plan for a build pipeline — not just 'here's what to build,' but
  what depends on what and what can run in parallel. This is the handoff artifact to
  Stage 5 and beyond: the build agents in later stages take this plan as input."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open recipes/agents/spec-to-pipeline.yaml`
"Trace the Stage 4 chain end-to-end: idea-to-spec produces the spec, spec-decomposition
restructures it by persona, spec-review rates it, spec-to-pipeline turns it into
executable artifacts. Four recipes, one pipeline."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/spec-to-pipeline.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge

If continuing to spec-review:
"Now that every requirement can trace to a test, the next question is whether the spec itself is worth building. We review it before the pipeline spends time on implementation. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

If continuing to Stage 5:
"Next is trust but verify. The pipeline can now build from the spec; Stage 5 is about proving the pipeline's claims are true instead of trusting its own report. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/.rilgoose/progression.json:
  concept 4.4 dimensions with eval ratings and timestamp:
    - traceability_discipline
    - test_specificity
    - non_automatable_handling
    - pipeline_readiness (conditional; rating null does not block completion)

Mark concept 4.4 complete when traceability_discipline, test_specificity, and non_automatable_handling are all Adequate or Strong. If pipeline_readiness is triggered, record it, but do not block concept completion on a null rating.

If concepts 4.1 through 4.4 are complete, mark Stage 4 complete with completed_at timestamp.

Never overwrite a Strong rating with a lower one. If the developer re-runs this module, update ratings only if they improve.
