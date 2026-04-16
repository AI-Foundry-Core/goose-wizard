# Recipe 2.3: Spec First — "Define Success Before Building"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the codebase," interpret those against
> `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `spec-first` sub-recipe. Spec
> files written by the agent live under `<TARGET>/` (e.g.,
> `<TARGET>/specs/`), not in the goose-wizard repo.

Covers concept 2.3 (spec-first). Teaches defining success before building.
Mode: Adaptive + Checkpoints. Stage 2 completion checkpoint.

---

## Quality Dimensions

### Concept 2.4 — Define Success Before Building

| Quality Dimension | Strong | Adequate | Weak |
|-------------------|--------|----------|------|
| **Spec before code** | Developer wrote acceptance criteria before any code was generated — defined what "done" looks like before the builder started. *"You defined success before the first line of code. The builder had a target instead of guessing what you wanted. That's the difference between 'build me something' and 'build me this.'"* | Developer started to describe what they wanted but blurred the line between spec and implementation — mixed 'what it should do' with 'how to build it,' or defined criteria during building rather than before. *"You described what you wanted, but it happened while the builder was already working. Write the criteria first, then build. Otherwise the builder fills in the gaps with its own assumptions — and you won't know what it assumed until something breaks."* | Developer jumped straight to asking the AI to build without defining acceptance criteria. Let the AI decide what 'done' meant. *"You asked the AI to build the feature without defining what success looks like. The AI decided on its own — and its definition of 'done' might not match yours. Next time: write what 'done' means first. Expected behavior. Edge cases. What shouldn't change. Then build."* |
| **Criteria specificity** | Developer wrote concrete, testable acceptance criteria — specific behaviors, edge cases, and boundaries, not vague goals. Criteria could be directly translated into tests. *"Your criteria were specific enough to turn straight into tests. 'Returns empty array when input is null' is testable. 'Handles edge cases well' is not. You gave the AI something it could actually verify."* | Developer wrote acceptance criteria but they were partially vague — some concrete behaviors, some hand-wavy goals like "should work correctly" or "handle errors properly." *"Some of your criteria were great — '[specific one]' is testable. But 'handles errors properly' isn't. What errors? What's proper? If you can't write a test for it, the AI can't verify it. Make every criterion as specific as '[specific one].'"* | Developer wrote vague or no acceptance criteria — goals like "should work" or "be robust" that cannot be turned into tests. *"'Should work correctly' isn't a criterion — it's a wish. Compare that to: 'Returns 404 when user ID doesn't exist. Returns 400 when email format is invalid. Does not modify existing user records.' Now the AI has something to build against and you have something to verify. Specific criteria are the difference."* |
| **Tests-first verification** | Developer engaged with the tests-before-code pattern — checked that tests fail before building (confirming they're real checks), then verified they pass after building. Understood the cycle. *"You verified the tests failed first — that's the key step most people skip. A test that passes before you build anything is a tautology. Fail first, then make it pass. Now you know the tests are real."* | Developer understood the tests were written before code but didn't verify they failed first, or didn't engage with why the fail-then-pass cycle matters. *"The tests were written before the code — good. But did you check they actually failed before building? That step proves the tests are real. If they pass before any code exists, they're not testing anything. Always verify: fail first, then build until they pass."* | Developer didn't engage with the tests-first pattern — either didn't notice tests were written before code, or treated the test-then-build order as arbitrary. *"The tests were written before the code for a reason. If you write tests after code, you write tests that confirm what exists — not tests that verify what should exist. The spec said '[criterion].' The test checked for it. The code was built to pass it. That order matters."* |
| **Spec as contract** (conditional) | Condition: Only rate this if the AI's implementation deviated from the spec or if the developer had to course-correct the builder. If condition not met: return rating=null, evidence="Not triggered — implementation matched spec on first pass", coaching=null. Strong: Developer caught the deviation and pointed back to the spec — used the criteria to hold the builder accountable. *"The builder drifted from your spec and you caught it. That's the spec working as a contract — it's not just a wish list, it's what the builder agreed to deliver."* | Adequate: Developer noticed the deviation but didn't explicitly reference the spec as the authority — fixed the problem without connecting it to the criteria they defined. *"You caught that the builder went off track, but you fixed it by describing what you wanted again. Instead, point to the spec: 'Criterion 3 says X, you did Y.' The spec is the contract. Use it."* | Weak: Developer didn't catch the deviation or accepted an implementation that didn't match their spec. *"The builder was supposed to [spec criterion] but instead did [what it actually did]. Your spec defined the target, but you didn't check the result against it. After every build, go back to your criteria and check each one."* |
| **Spec ownership** | Developer actively owned the acceptance criteria — wrote them in their own words, pushed back on AI-suggested criteria that didn't match their intent, or refined AI suggestions to match what they actually needed. The spec reflected the developer's judgment, not the AI's defaults. *"Those criteria were yours. You didn't just accept what the AI suggested — you defined what success means for your project. That's the difference between directing the AI and following it."* | Developer wrote some criteria but accepted AI-suggested criteria without evaluating whether they matched the actual need. Mixed their own judgment with uncritical adoption of AI defaults. *"Some of those criteria were yours, but you accepted a few of the AI's suggestions without questioning them. Ask: does this criterion match what I actually need, or is it just what the AI thought I meant? Your spec should reflect your judgment, not the AI's best guess."* | Developer let the AI define the acceptance criteria entirely — accepted AI-generated criteria without modification, or deferred to the AI when asked what success looks like. The spec reflected the AI's assumptions, not the developer's intent. *"The AI wrote the spec and you accepted it. But the AI doesn't know your project the way you do. It guessed what success looks like — and its guess might be wrong. Next time, write the criteria yourself. If the AI suggests some, evaluate each one: does this match what I actually need?"* |

---

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/goose-wizard/progression.json — check concept 2.3.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.
Verify concepts 2.1, 2.2, and 2.3 are complete. If not, flag it — 2.4 assumes the developer has the build-then-test and review gate patterns.

## Framing

"So far everything's been reactive — the builder picks what to build, the tester checks it. If the builder solves the wrong problem, the tester confirms the wrong solution works perfectly. We fix that by defining success first: acceptance criteria, then tests, then build to pass them."

"What's a small feature or change you need — something with clear expected behavior? Or want me to find one in your codebase that's spec-shaped?"

If developer has no current task:
  "Let me find something."
  Delegate to code-work subagent (prepend the TARGET PROLOGUE):
    "Read `<TARGET>/.goose/team_context.md`. Scan source code under
    `<TARGET>/` for a missing feature, a requested enhancement from
    TODOs, or a gap in the codebase that would benefit from a spec-first
    approach. Pick something with at least 3 distinct behaviors that could
    be acceptance criteria. Describe it as a feature the developer would
    recognize as useful."

## The Task

Developer describes the feature (or accepts the found task).

**Do NOT delegate to the code-work subagent yet.** The spec must come first.

Step 1 — Facilitate the spec:
"Before we build anything — what does 'done' look like? Not how to build it, but what it should do when it's working. Give me the acceptance criteria: expected behaviors, edge cases, and anything that should NOT change."

Let the developer write criteria. Guide them toward specificity:

If criteria are vague ("should handle errors"):
  "That's a start, but 'handle errors' isn't testable yet. What specific
  errors? What should happen for each? Give me something I can write a
  test for."

If criteria are incomplete (missing edge cases):
  "Good behaviors listed. What about edge cases — empty input? Huge input?
  Invalid format? Concurrent access? What should NOT change in the rest
  of the system?"

If developer tries to jump to implementation:
  "Hold on — we're not building yet. The spec comes first. What does
  success look like? Once we agree on that, the builder has a target
  and the tests have a checklist."

**Watch for spec ownership.** If the AI suggests criteria (e.g., in response to a vague request), observe whether the developer evaluates and modifies the suggestions or just accepts them:

If the developer accepts AI-suggested criteria without review:
  "Those are reasonable suggestions, but — do they match what you actually
  need? Read through each one. Are there any that don't apply to your case,
  or any missing that you know matter?"

Step 2 — Run spec-first recipe:
Once the developer has concrete criteria, delegate to code-work subagent
(prepend the TARGET PROLOGUE):
  sub-recipe: "spec-first"
  parameters:
    feature_description: {developer's feature}
    context: {any relevant context}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

  Pass the developer's acceptance criteria as part of the feature description context.

[Subagent runs the spec-first workflow: writes tests from criteria (fail) -> builds -> tests pass]

Step 3 — Present results:
"Here's what happened: Your criteria became [X] tests. Before building, they all failed — confirming they're real checks, not rubber stamps. Then the builder implemented the feature. [Y of X tests pass]. [Summary of what was built]."

If all tests pass:
"Every test passes. And here's the key — those tests existed before the code. The builder didn't write tests to match its code. It wrote code to match your tests. Your spec was the contract."

If some tests fail:
"[Y] tests pass, but [Z] fail. Go back to your acceptance criteria and check each one against the test results. Tell me which are met and which aren't."

Do NOT name the failing test or criterion. The developer must do the full criterion-by-criterion sweep — that is the verification habit this module teaches. Only narrow to a specific failure if the developer cannot identify it after a genuine attempt.

After the developer identifies the unmet criterion:
"Would you approve this build as done?"

The developer must practice explicitly rejecting incomplete work. If they say yes or hedge, redirect: "One of your own criteria isn't met. The spec is the contract — if the contract isn't satisfied, the build isn't done."

**Reject-and-repair loop:**
Once the developer rejects the build, delegate a targeted repair (prepend
the TARGET PROLOGUE):
  sub-recipe: "spec-first-repair"
  parameters:
    failing_criterion: {the criterion the developer identified}
    instruction: "Fix only the failing criterion. Do not broaden scope. Rerun the full acceptance suite."
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

Present the rerun result. If all tests pass, proceed to coaching. If the same test fails twice, treat it as an implementation stuck path and escalate.

Do not bridge or coach until the acceptance suite is fully green or explicitly blocked.

## Eval

Delegate to eval subagent (async: true):
  [See eval prompt below]

## Coaching

Read eval results. For each dimension:
- Strong: Acknowledge specifically using the coaching language from the quality dimension table.
- Adequate: Light suggestion using the coaching language from the quality dimension table.
- Weak: Targeted coaching with contrast using the coaching language from the quality dimension table.

**Brevity rule:** 1-3 sentences per dimension. Maximum. Do not make the same point multiple ways. If the developer already demonstrated understanding (e.g., identified the gap themselves), one sentence of confirmation is enough. Let the learning breathe — over-explaining dilutes the insight.

## Checkpoint (after 2.4 — Stage 2 completion)

This is the stage completion checkpoint. It is NOT optional and must NOT be folded into the bridge.

Read ~/goose-wizard/progression.json for all Stage 2 concept ratings.

**Checkpoint question (required):** After summarizing the four capabilities below, ask:
"Which of these would you rely on to stop a wrong-but-working implementation?"

This question tests whether the developer has internalized spec-first as the answer. If they point to the tester or reviewer instead, coach: "The tester confirms the wrong solution works perfectly. The spec is the only thing that defines 'right.'"

If any concept has Weak dimensions:
  "Before we close out Stage 2, let's revisit [weak area]. [Specific coaching].
  Want to run through another example focused on that?"
  Run the appropriate recipe again with targeted coaching.
  Do NOT bridge to Stage 3 until the Weak dimension is Adequate or better.

If all concepts are Adequate or Strong:

"Let's take stock of what you've built in Stage 2:"
"- Two agents that don't trust each other's work — builder builds, tester catches what it missed"
"- Role separation — specialists focused on their job, not sharing assumptions"
"- A review gate backed by execution evidence, not opinions"
"- A spec-first workflow where success is defined before anyone starts building"

"One AI builds, another AI tests. Neither trusts the other's work. Your code is more reliable than when you checked everything yourself."

## Enterprise Grounding

After the acceptance suite is green (or explicitly blocked) and before the bridge, ask one enterprise-context question:

"In your team, who else would review these acceptance criteria before you start building?"

If the developer engages, follow up with one more:
"These tests will run on every future PR — that's the spec protecting the feature as the codebase evolves. Where would they run for your team — local only, PR checks, or CI before deploy?"

Keep it to two questions maximum. Do not design the CI workflow — just connect the exercise to enterprise reality.

## Recipe Reveal

After enterprise grounding, show the developer the recipe behind this session.

"Seventh recipe, and the last of Stage 2. This is the one that flips the workflow — tests before code, not after."

Read the Spec-First agent recipe (recipes/agents/spec-first.yaml) and show the developer:
- The **order of the Process block** — "Look at the four-step process: Spec → Tests from spec → Build to spec → Verify. Compare that to Build-Then-Test where the order was build first, test second. This recipe literally inverts the ordering. The sequence in the YAML is the sequence you experienced — spec before tests, tests before code."
- The **'tests should fail before build' constraint** — "Read this line: 'Do NOT skip running tests before implementation — new tests should fail when they cover behavior that doesn't exist yet.' That's the fail-then-pass cycle you just did, written as a hard rule. The recipe won't let the agent write tests that already pass — because a test that passes before the code exists is a tautology."
- The **`NEVER weaken or remove tests to make them pass` constraint** — "This is the anti-cheat rule. Without it, an agent that can't make the test pass can just soften the test. The recipe forbids it. Tests and spec are the contract — the agent can change the code until tests pass, but can't change the tests to lower the bar."
- The **`approved_criteria` and `spec_coverage` return fields** — "Notice the return block doesn't just give you a diff. It returns `approved_criteria` (the spec used), `initial_test_run` (proof the tests failed first), `final_test_run` (proof they pass now), and `spec_coverage` (which criteria are covered, partial, or missed). The recipe hands you the evidence to verify the spec-as-contract yourself."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/spec-first.yaml>`
"Compare the Process block to build-then-test — same agents, reversed order, entirely different discipline."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/spec-first.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge to Stage 3

"Right now you have two agents — a builder and a tester. That's the minimum for reliable work. But what happens when the task is bigger? When you need a builder, a tester, a reviewer, and maybe a specialist for the database layer? Stage 3 is about building a team of AI specialists — multiple agents with defined roles, file ownership, and coordination. The patterns you learned here — separation, independence, execution verification — are the foundation. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## Wait-Time Insights

Deliver one insight per code operation wait. Use in order. Do not repeat.

1. **[define-success]** "The spec you wrote is doing something important right now. It's a contract. The builder doesn't decide what done means anymore — your acceptance criteria do."
2. **[verify]** "Every test that fails before code exists proves it's a real check. A test that passes before you build anything is a tautology — it confirms nothing."
3. **[feedback-loops]** "When the repair finishes, the same six tests run again. The spec doesn't care whether it's the first build or the fifth — it checks the same criteria every time. That consistency is what makes it a contract, not a one-time checklist."
4. **[enterprise]** "In a team, these acceptance criteria outlive the feature. Next quarter, someone changes the endpoint — these tests enforce your original intent. The spec protects the feature long after you move on."
5. **[specificity]** "Notice the difference between 'should handle caching' and 'returns cached response within 50ms for same user within 5-minute window.' The second one is a test. The first one is a hope."
6. **[iteration]** "Each repair cycle narrows the gap. The spec tells you exactly what's left — no guessing, no 'it seems close enough.' When the last test goes green, done means done."

## State Update

Write to ~/goose-wizard/progression.json:
  concept 2.3 dimensions with eval ratings + timestamp.
  If all Stage 2 concepts are complete, set stage 2 status to "complete".
  Never overwrite a Strong rating with a lower one. If the developer re-runs this recipe, update ratings only if they improve.

---

## Eval Subagent Prompt

```
You are evaluating how well a developer approached spec-first development with AI. This covers concept 2.3 (Define success before building).

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. SPEC BEFORE CODE
   Strong: Developer wrote acceptance criteria before any code was generated. Defined what "done" looks like — expected behaviors, edge cases, boundaries — before the builder started working.
   Adequate: Developer described what they wanted but blurred the line between spec and implementation, mixed "what it should do" with "how to build it," or defined criteria while building was already happening.
   Weak: Developer jumped straight to asking the AI to build without defining acceptance criteria. Let the AI decide what "done" meant.

2. CRITERIA SPECIFICITY
   Strong: Developer wrote concrete, testable acceptance criteria — specific behaviors ("returns empty array when input is null"), edge cases, and boundaries. Criteria could be directly translated into test assertions.
   Adequate: Developer wrote acceptance criteria but some were vague — mixed concrete behaviors with hand-wavy goals like "should work correctly" or "handle errors properly" that cannot become test assertions.
   Weak: Developer wrote vague or no acceptance criteria. Goals like "should work" or "be robust" that have no testable definition.

3. TESTS-FIRST VERIFICATION
   Strong: Developer engaged with the tests-before-code pattern — verified or acknowledged that tests fail before building (confirming they are real checks), then verified they pass after building. Understood why the fail-then-pass cycle matters.
   Adequate: Developer understood tests were written before code but did not verify they failed first, or did not engage with why the fail-then-pass ordering is important.
   Weak: Developer did not engage with the tests-first pattern — didn't notice the ordering, treated it as arbitrary, or showed no understanding of why tests before code matters.

4. SPEC AS CONTRACT (conditional)
   Condition: Only rate this if the AI's implementation deviated from the spec or if the developer had to course-correct the builder based on the criteria.
   If condition not met: return {"name": "spec_as_contract", "rating": null, "evidence": "Not triggered — implementation matched spec on first pass", "coaching": null}
   Strong: Developer caught the deviation and referenced the spec as the authority — used the criteria to hold the builder accountable.
   Adequate: Developer noticed the deviation but fixed it by re-describing what they wanted rather than pointing to the spec as the contract.
   Weak: Developer did not catch the deviation or accepted an implementation that did not match their defined spec.

5. SPEC OWNERSHIP
   Strong: Developer actively owned the acceptance criteria — wrote them in their own words, pushed back on or refined AI-suggested criteria, evaluated each criterion against their actual needs. The final spec reflected the developer's judgment, not the AI's defaults.
   Adequate: Developer wrote some criteria independently but accepted AI-suggested criteria without evaluating whether they matched the actual need. Mixed their own judgment with uncritical adoption of AI defaults.
   Weak: Developer let the AI define the acceptance criteria entirely — accepted AI-generated criteria without modification, or deferred to the AI when asked what success looks like. The spec reflected the AI's assumptions, not the developer's intent.

Return as JSON:
{
  "dimensions": [
    {"name": "spec_before_code", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "criteria_specificity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "tests_first_verification", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "spec_as_contract", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "spec_ownership", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "Any cross-cutting observation about how the developer is internalizing the spec-first pattern"
}
```
