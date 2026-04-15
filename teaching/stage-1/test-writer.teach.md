# Recipe 1.2: Test Writer — "AI writes the tests you never get around to"

## Setup
Read .goose/team_context.md for project context (stack, test commands, test framework, conventions).
Read ~/.rilgoose/progression.json — check if concept 1.2 is already demonstrated.
If already demonstrated (all dimensions adequate+):
  "You've already shown you can do this well. Want to skip ahead to [next incomplete recipe], or write another test suite to sharpen the skill?"
  If skip: jump to Bridge section.
  If revisit: continue normally — update ratings only if they improve.

## Framing
"Got a function or module that should have tests but doesn't? Something you've been meaning to cover, or something that broke recently and made you think 'we should have had a test for that'? Point me at it."

**Stuck path — developer has no untested code in mind:**
"No problem. Let me scan your codebase for something that needs coverage."
Delegate to code-work subagent:
  "Read .goose/team_context.md. Scan the codebase for functions or modules that
  have no corresponding test file, or that have meaningful logic with no test
  coverage. Prioritize: functions with branching logic, error handling, or data
  transformation — not simple getters/setters. Pick one that's important enough
  to test but small enough for a focused session. Report: what the function does,
  where it is, and why it needs tests."

While waiting (insight 1.2b): "Scope matters a lot here. Pointing AI at one function gets you focused, meaningful tests. Pointing it at a whole module gets you shallow coverage of everything and deep coverage of nothing."

Present the found target naturally:
"I found something — [function/module name] in [file]. It [what it does] and has no tests. Good candidate?"

## The Task
Developer identifies the target (or accepts the found one).

Note what the developer provides — this is what the eval will assess for scope definition:
- Did they target a specific function or small module?
- Or did they ask for "tests for everything"?

Delegate to code-work subagent:
  sub-recipe: "test-writer"
  parameters:
    target: {developer's chosen target}
    test_focus: {if provided}
    test_framework: {if provided}

While waiting (insight 1.2a): "While it writes — one thing to watch: AI-generated tests that all pass on the first try aren't always a good sign. Sometimes they pass because they don't actually test anything meaningful. A test that can't fail is worse than no test."

[Subagent writes tests, runs them, returns results]

Present results naturally:
"Done — wrote [N] tests for [target]. [X passing, Y failing]. Here's what's covered: [brief summary of test scenarios]."

If there are failures:
"[Y] tests are failing. Here's what's going wrong: [failure summaries]. This is normal for a first pass — want to iterate?"

**Proactive assertion-quality prompt:**
Before the eval runs, surface assertion quality as a natural part of the conversation:

"All right, tests are in. Before we move on — look at what these tests actually assert. Would these tests catch a real bug? If you changed the function's core logic tomorrow, would any of these fail? Pick one test and tell me what it's really checking."

This gives the developer a moment to inspect assertion quality themselves. If they engage (question a weak assertion, identify a test that only checks return type, notice a tautology), that's signal the eval will pick up. If they say "looks fine" without looking, that's signal too.

If the developer engages meaningfully:
  Let them lead. If they spot a weak assertion, ask: "What would a stronger assertion look like for that case?"

If the developer dismisses quickly ("yeah they look fine"):
  Pick a specific test: "Look at this one — [test name]. What happens if you swap the function's return value? Does this test fail?" Don't lecture — just make it concrete.

**Disengagement check:** If the developer has given only one-word or one-phrase answers through the target selection and assertion review (e.g., "Sure," "OK," "They look fine" — no questions, no volunteered information), ask one explicit usefulness check before proceeding to iteration:

  "Is this useful, or would you rather tackle something different?"

If they choose to continue, proceed with one small iteration. If they redirect, follow their lead. Do not skip this check — "Want to add one?" is a task continuation prompt, not an engagement check. Per teacher-instructions.md Section 7: persistent minimal responses are the signal.

**Watch what the developer does next.** The eval assesses multiple dimensions here:

*Test execution:* Do they look at the test results? Do they examine failure messages? Or just glance and move on?

*Quality evaluation:* Do they question whether the tests are meaningful? Do they notice weak assertions? Or do they accept all passing tests without scrutiny?

*Iteration:* Do they ask for a second round? Fix failures? Add edge cases? Or stop after the first pass?

**No-overclaim rule:** Credit only what the developer actually did. If the facilitator supplied an edge case and the developer agreed it was missing, say they "checked" or "accepted" the gap — not that they "caught it" or "found it themselves." Accurate praise builds trust; inflated praise undermines it.

If all tests pass on the first try and the developer accepts immediately, you can naturally surface:
"All passing. Take a look at this one though — [pick a test with a weak assertion if one exists]. What do you think it's actually checking?"

If the developer doesn't iterate after failures, wait for the eval. Don't force a second round — but if they explicitly say "that's fine" with failing tests, you can say:
"Want to take one more pass to clean up those failures? Usually takes 30 seconds."

## Eval
Delegate to eval subagent (async: true):

While waiting (insight 1.2c): "The first round of tests is a starting point, not the finished product. The real coverage comes from the iteration — fix the failures, add the edge cases, tighten the assertions. Second pass is always better."

If a second code operation occurs (iteration pass), use the next insight:
While waiting (insight 1.2d): "Think of test writing as defining what 'correct' means before you ship. The tests are the spec — if the test doesn't break when the behavior changes, nobody agreed on what correct was."

```
You are evaluating how well a developer approached writing tests with AI assistance.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating (quote or paraphrase)
3. Coaching: If not Strong, 1-2 sentences the facilitator should say — conversational, specific, never mentions the eval system or ratings

Dimensions:

1. SCOPE DEFINITION
   Strong: Developer targeted a specific function or small module with clear boundaries.
   Adequate: Developer targeted a reasonable scope but could be tighter — e.g., an entire file rather than a specific function.
   Weak: Developer asked for "tests for everything" or a very broad scope with no specific target.

2. TEST EXECUTION
   Strong: Developer ran the tests and looked at results — checked pass/fail counts, read error messages for failures.
   Adequate: Developer ran tests but didn't look closely at the results or examine failure details.
   Weak: Developer looked at the test code but never ran the tests.

3. QUALITY EVALUATION
   Strong: Developer questioned whether tests check real behavior — noticed weak assertions, trivial tests, or tests that can't fail.
   Adequate: Developer accepted the tests but asked a general question about quality or coverage.
   Weak: Developer accepted all passing tests without questioning whether they test anything meaningful.

4. ITERATION
   Strong: Developer did a second round — fixed failures, added edge cases, or improved weak tests.
   Adequate: Developer acknowledged the need for iteration but stopped after one round.
   Weak: Developer stopped after the first pass regardless of quality or failures.

Return as JSON:
{
  "dimensions": [
    {"name": "scope_definition", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "test_execution", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "quality_evaluation", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "iteration", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

**Scope definition:**
- Strong: "Perfect scope — tight and specific. AI writes much better tests when it's focused on one thing."
- Adequate: "This is OK, but you'd get better tests if you narrowed it to just [specific function]. Smaller scope = better tests."
- Weak: "Start with one function, not the whole module. AI writes better tests when the scope is tight. Pick the most important function and start there."

**Test execution:**
- Strong: "Good — you ran them. That's the difference between tests that exist and tests that work."
- Adequate: "You ran them, which is good. But look at the output — which ones failed? Why? The failure messages tell you what to fix next."
- Weak: "These look right but you never ran them. Always run them. AI writes tests that look correct but fail on execution. That's where the real iteration starts."

**Quality evaluation:**
- Strong: "You caught that — this assertion just checks the function returns something, not the right thing. That's the skill: distinguishing meaningful tests from padding."
- Adequate: "Good instinct to ask. Look at this specific test — would it catch a real bug? If you changed the function's logic, would this test fail? If not, it's not testing anything meaningful."
- Weak: "These all pass. But look at this one — it asserts `true == true`. That passes no matter what. A test that can't fail is worse than no test. Ask: would this test catch a real bug?"

**Iteration:**
- Strong: "Great — the second round is always better. You went from [X] to [Y] passing tests, and the new ones test real edge cases. That iteration cycle is the real workflow."
- Adequate: "First pass is a starting point. Try one more round — fix the failures and add an edge case. The iteration cycle (write, run, fix, run) is where the quality comes from."
- Weak: "You've got a first draft. But test writing is iterative — write, run, fix, run. Each round gets better. Try again with the failures and one edge case you can think of."

**If ALL dimensions are Strong:**
"That's the full test-writing workflow — tight scope, ran them, checked the quality, iterated to improve. This is how you go from 'no tests' to 'real coverage' in minutes."

**Coaching delivery rules:**
- Never mention eval, ratings, scores, or the teaching system
- Weave coaching into natural conversation — not a list of feedback items
- Lead with what was strong before coaching what was weak
- Use contrast examples for weak ratings
- Keep it to 1-3 sentences per dimension — don't lecture

## Enterprise Grounding
After the tests pass, ask one team-workflow question to connect the session to the developer's real environment:

"These tests cover the function now. Where would your team see these results — local pytest only, CI, PR checks, or a coverage report?"

Keep it to one question unless the developer wants to go deeper. If the developer has a CI or coverage setup, acknowledge it. If they don't, plant the seed: "Something to think about — tests that only run locally tend to rot. Getting them into CI is the difference between tests that exist and tests that protect you."

Do not turn this into a lecture. One question, one follow-up at most.

## Recipe Reveal
After enterprise grounding, show the developer the recipe behind this session.

"You know the drill by now — there's a recipe behind this. Let me show you
what's different about this one."

Read the Test Writer agent recipe (recipes/agents/test-writer.yaml) and show the developer:
- The **parameters** — "Notice the inputs are different from Bug Fix: target, test focus,
  test framework. Each recipe defines what context it needs."
- The **process** — "Happy path, edge cases, error handling — that's the
  structure it follows every time. You saw it do exactly that."
- Compare to Bug Fix — "Same structure, but the process steps and constraints
  are completely different. Bug Fix cares about root cause. Test Writer cares
  about coverage. The recipe defines what good looks like for each task."
- The pattern forming — "By now you're seeing the pattern: every agent recipe has
  parameters, constraints, process, and a return block. They're all readable YAML.
  By Stage 2, you'll know what a recipe does just by skimming it."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it in the desktop app:
Run: `goose recipe open <path to recipes/agents/test-writer.yaml>`
"Open in the app. Compare it side-by-side with the Bug Fix recipe if you're curious —
you'll see the pattern clearly."

WAIT for any questions.

## Bridge
"You've been fixing bugs and writing tests — both times, you were the one checking the quality. Now imagine pointing AI at someone else's PR and getting a full review in 30 seconds. That's next."

## State Update
Write to ~/.rilgoose/progression.json:
  concept 1.2 dimensions with eval ratings + timestamp.
  Update concept status to "complete" if all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
