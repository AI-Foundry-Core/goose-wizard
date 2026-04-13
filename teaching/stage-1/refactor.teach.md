# Recipe 1.4: Refactor — "AI handles the restructuring you've been putting off"

## Setup
Read .goose/team_context.md for project context (stack, test commands, conventions).
Read .goose/state/progression.json — check if concept 1.4 is already demonstrated.
If already demonstrated (all dimensions adequate+):
  "You've already shown you can do this well. Want to skip ahead to the next set of skills, or run through another refactor to sharpen this one?"
  If skip: jump to Bridge section.
  If revisit: continue normally — update ratings only if they improve.

## Framing
"Got some code that works but makes you cringe every time you open it? Something you've been meaning to clean up but never had the time? Point me at it — and tell me what 'better' looks like for that code."

**Engagement hook:** If the developer names a specific area of the codebase ("the auth module," "the payment flow"), probe the history before starting the refactor: who wrote it, when, what has changed since. Developers who are hostile to the session may still engage with their own codebase's history. Use their domain knowledge as a hook for engagement.

**Stuck path — developer has no code to refactor:**
"No problem. Let me scan your codebase for something that's begging to be cleaned up."
Delegate to code-work subagent:
  "Read .goose/team_context.md. Scan the codebase for a function or small module
  that's a good refactoring candidate — look for: functions longer than 50 lines,
  deeply nested conditionals, duplicated logic, functions doing multiple unrelated
  things, or code with comments like 'TODO: clean this up.' Pick something with
  existing test coverage if possible (so we can verify the refactor). Report:
  where it is, what it does, and why it needs refactoring."

While waiting (insight 1.4b): "'Clean it up' is a vague instruction. 'Split this into two functions — one for validation, one for processing' is a specific one. Same AI, wildly different results. The goal definition is everything."

Present the found target naturally:
"Found one — [function/file] in [location]. It [description of the mess]. Want to clean this up?"

## The Task
Developer identifies the target and states their goal (or accepts the found one).

Note what the developer provides — this is what the eval will assess for goal definition:
- Did they state a specific goal ("split into smaller functions," "make testable by removing the DB dependency")?
- Or did they say something vague ("refactor this," "clean it up")?

**Before the refactor starts — establish baseline:**
"Before we touch anything, let's run the tests so we know the starting point."

Delegate to code-work subagent:
  "Run the project's test suite from .goose/team_context.md. Report pass/fail counts."

Present the baseline:
"[N] tests passing, [M] failing. That's our baseline — if anything changes after the refactor, we'll know."

Note whether the developer ran tests first or needed prompting — this is what the eval assesses for baseline established.

Now run the refactor:

Delegate to code-work subagent:
  sub-recipe: "refactor"
  parameters:
    target: {developer's chosen target}
    goal: {developer's stated goal}
    constraints: {if provided}

While waiting (insight 1.4a): "While it refactors — baseline tests first, always. If you don't know what was passing before, you can't tell what the refactor broke."

[Subagent refactors, runs tests, returns results]

Present results naturally:
"Done. [Brief summary of what was restructured]. Tests: [pass/fail after]. Here's the full diff."

**Watch what the developer does next.** The eval assesses post-refactor verification:
- Do they run tests AND review the diff?
- Do they do only one?
- Or do they accept without checking?

If the developer accepts immediately:
"The tests pass, but take a look at the diff. Refactoring can hide behavioral changes — a restructured conditional might not do exactly what the old one did."

**Important: When pointing out potential behavioral changes, show specific evidence from the diff.** Do not claim a concrete behavior change unless the diff demonstrates it. If you suspect a subtle change but cannot confirm, phrase it as a verification question: "This restructuring often changes subtle behavior — check this path carefully." Hostile or experienced developers will punish overclaiming.

## Eval
Delegate to eval subagent (async: true):

While waiting (insight 1.4c): "Refactoring is the riskiest thing on the AI task ladder. Reading is safe, writing is medium, restructuring can introduce subtle behavioral changes that tests don't catch. That's why you check the diff line by line."

```
You are evaluating how well a developer approached refactoring with AI assistance.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating (quote or paraphrase)
3. Coaching: If not Strong, 1-2 sentences the facilitator should say — conversational, specific, never mentions the eval system or ratings

Dimensions:

1. GOAL DEFINITION
   Strong: Developer stated a clear, specific goal — e.g., "make this more readable by splitting into smaller functions" or "make this testable by removing the database dependency."
   Adequate: Developer gave a general direction like "clean this up" or "make it better" but not a specific structural goal.
   Weak: Developer said "refactor this" with no goal or direction at all.

2. BASELINE ESTABLISHED
   Strong: Developer ran tests and noted the state (all pass, N tests) before the refactor started — either proactively or when prompted.
   Adequate: Developer ran tests but didn't clearly note the baseline count for comparison.
   Weak: Developer didn't run tests before starting and didn't ask about existing test state.

3. POST-REFACTOR VERIFICATION
   Strong: Developer ran tests after AND reviewed the diff for behavioral changes.
   Adequate: Developer ran tests OR reviewed the diff, but not both.
   Weak: Developer accepted the refactor without running tests or reviewing the diff.

4. SCOPE CONTROL
   Strong: Developer targeted one function or a small, coherent unit for refactoring.
   Adequate: Developer's scope was reasonable but broader than ideal — e.g., multiple related functions at once.
   Weak: Developer tried to refactor a whole module or multiple unrelated functions simultaneously.

Return as JSON:
{
  "dimensions": [
    {"name": "goal_definition", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "baseline_established", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "post_refactor_verification", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "scope_control", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

**Goal definition:**
- Strong: "Clear goal — that's why the refactor did exactly what you wanted."
- Adequate: "'Clean it up' worked OK, but compare: 'split this into two functions — one for validation, one for processing.' Specific goals get specific results."
- Weak: "What does 'better' mean for this code? More readable? More testable? Faster? If you can't say, the AI guesses — and it guesses wrong half the time. Define the goal first."

**Baseline established:**
- Strong: "Good — you have a baseline. If anything breaks, you'll know immediately."
- Adequate: "You ran the tests, but note the count: [N] tests passing. After the refactor, if that number changes, something broke."
- Weak: "Always run tests first. That's your baseline — if they pass now and fail after, you know the refactor broke something. Without a baseline, you can't tell."

**Post-refactor verification:**
- Strong: "Good — tests pass and you checked the diff for hidden changes. That's the full verification."
- Adequate: "Tests pass, but did you check the diff? [or] You checked the diff, but did you run the tests? You need both — tests catch regressions, diff review catches behavioral changes that tests don't cover."
- Weak: "Stop — run the tests. A refactor that breaks tests isn't a refactor. And check the diff: this line looks like cleanup but it changed a conditional. Restructuring can hide behavioral changes."

**Scope control:**
- Strong: "Right scope — one function, clean result. This is how you refactor safely."
- Adequate: "This worked, but next time try one function at a time. Smaller refactors are easier to review and less likely to have ripple effects."
- Weak: "Too much at once. Start with one function — the ugliest one. Get it clean, verified, and committed. Then the next one. Small refactors are safe refactors."

**If ALL dimensions are Strong:**
"That's the full refactoring workflow — clear goal, baseline tests, verified the result, kept the scope tight. You just did in 5 minutes what usually takes an afternoon."

**If goal_definition and scope_control are both Weak:** Combine them into one coaching point — show how a specific goal naturally limits scope. "Compare 'clean up auth' to 'flatten the nesting in register() lines 12-30.' The second one is specific enough that you can verify the result in one diff — and narrow enough that if the AI makes a mistake, you've only touched 20 lines." Avoid delivering scope as a separate brief mention that will not register with a disengaged developer.

**Coaching delivery rules:**
- Never mention eval, ratings, scores, or the teaching system
- Weave coaching into natural conversation — not a list of feedback items
- Lead with what was strong before coaching what was weak
- Use contrast examples for weak ratings
- Keep it to 1-3 sentences per dimension — don't lecture

## Wait-Time Insights
Ordered list — deliver during subagent operations per teacher-instructions.md Section 13. Use only when the developer is waiting and no conversation is active.

1. **[specificity]** (during scan): "'Clean it up' is a vague instruction. 'Split this into two functions — one for validation, one for processing' is a specific one. Same AI, wildly different results. The goal definition is everything."
2. **[verify]** (during refactor): "While it refactors — baseline tests first, always. If you don't know what was passing before, you can't tell what the refactor broke."
3. **[verify]** (during eval): "Refactoring is the riskiest thing on the AI task ladder. Reading is safe, writing is medium, restructuring can introduce subtle behavioral changes that tests don't catch. That's why you check the diff line by line."
4. **[enterprise]** (if second wait occurs during eval): "On most teams, refactors touch shared code. The person who reviews your PR needs to see the before and after behavior is identical — not just that the tests pass."
5. **[iteration]** (if additional wait): "The first refactor is rarely the last. Once one function is clean, the mess in the functions that call it becomes more visible. That's normal — do them one at a time."

## Enterprise Grounding
Before the Bridge, connect refactoring to team workflow:

**Required question:** "When you refactor shared code on your team, who needs to review it? Is there a different bar for structural changes vs. feature changes?"

**Optional follow-ups (if the developer engages):**
- "Do you have any shared modules where a refactor would need sign-off from another team?"
- "How does your team handle refactoring that crosses service boundaries — do you coordinate or just let CI catch it?"

## Bridge
"You've been the one catching everything — verifying fixes, evaluating tests, triaging reviews, checking diffs. Imagine if a second AI did that for you."

**If the developer was disengaged throughout and did not perform verification themselves:** Adapt the bridge from "you've been catching everything" to a value proposition tied to the session: "That kind of diff risk — behavioral changes the tests don't catch — is exactly why a second AI is useful. It checks the refactor even when the tests stay green." The bridge should match what the developer experienced, not what the script assumes they experienced.

## Stage 1 Completion Check
Read .goose/state/progression.json.
If all four concepts (1.1, 1.2, 1.3, 1.4) are complete:
  "AI just fixed your bug, wrote your tests, reviewed your PR, and cleaned up your legacy code. You're 10x faster. Now imagine what happens when AI checks AI. That's where it gets really interesting."
  Update stage 1 status to "complete" in progression.json.

## State Update
Write to .goose/state/progression.json:
  concept 1.4 dimensions with eval ratings + timestamp.
  Update concept status to "complete" if all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
