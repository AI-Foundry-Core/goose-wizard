# Recipe 1.1: Bug Fix — "AI as investigator"

## Setup
Read .goose/team_context.md for project context (stack, test commands, conventions).
Read .goose/state/progression.json — check if concept 1.1 is already demonstrated.
If already demonstrated (all dimensions adequate+):
  "You've already shown you can do this well. Want to skip ahead to [next incomplete recipe], or run through another bug fix to sharpen the skill?"
  If skip: jump to Bridge section.
  If revisit: continue normally — update ratings only if they improve.

## Framing
"Got a bug that's been bugging you? Something you've been meaning to fix, or something that's been hard to track down? Tell me about it — what's happening, what you expected, and anything you've already tried."

**Stuck path — developer has no current bug:**
"No problem. Let me scan your codebase for something we can work with."
Delegate to code-work subagent:
  "Read .goose/team_context.md. Scan the codebase for a real issue worth fixing —
  look for TODO/FIXME comments, code smells, potential null reference issues, error
  handling gaps, or logic that looks wrong. Pick something the developer would
  recognize as a real problem, not a style nit. Describe it as a bug report:
  what's happening, where it is, why it matters."

While waiting (insight 1.1a): "While it investigates — the quality of the fix usually tracks with the quality of the description you gave it. Symptom, location, what you tried. The more it knows upfront, the fewer passes it needs."

Present the found issue naturally:
"I found something — [description of the issue]. Want to tackle this one?"

## The Task
Developer describes the bug (or accepts the found issue).

Note what the developer provides — this is what the eval will assess for context quality:
- Did they describe the symptom?
- Did they mention what they already tried?
- Did they suggest where the issue might be?
- Did they provide reproduction steps?

Delegate to code-work subagent:
  sub-recipe: "bug-fix"
  parameters:
    bug_description: {developer's description}
    suspected_location: {if provided}
    prior_attempts: {if provided}

While waiting (insight 1.1b): "Something to watch for with bug fixes — AI loves wrapping things in try/catch to make the error go away. That's not fixing the bug, that's hiding it. The diff will tell you which one happened."

[Subagent investigates, fixes, returns results]

Present results naturally — don't list return values mechanically:
"Found it. [Root cause in plain language]. [What was changed and why]. Let me run the tests... [X passing, 0 failing / or report any issues]."

Show the diff:
"Here's exactly what changed — take a look."

**Watch what the developer does next.** This is what the eval will assess for fix verification:
- Do they review the diff?
- Do they ask questions about the fix?
- Do they run tests themselves?
- Or do they just accept it and move on?

If the developer accepts immediately without checking, wait a beat. Don't coach yet — the eval will catch it. But if they explicitly say "looks good" without looking, you can naturally say:
"Want to see the diff? Worth a quick check."

**If the AI struggles (3+ attempts):**
Watch whether the developer adjusts their approach. This triggers the conditional "redirect on struggle" dimension.

## Eval
Delegate to eval subagent (async: true):

While waiting (insight 1.1c): "One pattern you'll see — if AI is going in circles after two or three attempts, the fix isn't 'try again.' It's changing the angle. Different context, different file, different theory about the cause."

```
You are evaluating how well a developer approached fixing a bug with AI assistance.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating (quote or paraphrase)
3. Coaching: If not Strong, 1-2 sentences the facilitator should say — conversational, specific, never mentions the eval system or ratings

Dimensions:

1. CONTEXT QUALITY
   Strong: Developer described the symptom AND at least one of: reproduction steps, suspected location, what they already tried.
   Adequate: Developer described the symptom with some detail but left out all of: reproduction steps, suspected location, prior attempts.
   Weak: Developer gave a minimal description like "X is broken" or "it doesn't work" with no supporting detail.

2. FIX VERIFICATION
   Strong: After the fix, developer checked the diff OR ran tests OR asked what was changed before accepting.
   Adequate: Developer looked at the result but didn't explicitly run tests or inspect the diff.
   Weak: Developer accepted the fix immediately without any verification.

3. REDIRECT ON STRUGGLE (conditional)
   Condition: Only rate this if the AI took 3+ attempts to fix the bug.
   If condition not met: return {"name": "redirect_on_struggle", "rating": null, "evidence": "Not triggered — AI solved in fewer than 3 attempts", "coaching": null}
   Strong: Developer changed their approach — gave different context, suggested a different file, or reframed the problem.
   Adequate: Developer waited too long but eventually adjusted.
   Weak: Developer kept retrying the same approach or just said "try again."

Return as JSON:
{
  "dimensions": [
    {"name": "context_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "fix_verification", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "redirect_on_struggle", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

**Context quality:**
- Strong: "That's exactly the kind of context that makes AI fast — you gave it the symptom, what you ruled out, and a theory. This is why it found the fix in one pass."
- Adequate: "Good start — next time also mention what you already tried, so the AI doesn't retrace your steps."
- Weak: "Compare what you said to: 'login fails after OAuth redirect, I checked the callback URL, I think the session isn't persisting.' The second version gets a fix in one pass. Context is everything."

**Fix verification:**
- Strong: "Good — you checked what the fix actually did before accepting it. That's the habit."
- Adequate: "It looks like it worked, but open the diff. AI sometimes hides errors instead of fixing them — wraps things in try/catch, suppresses the exception. Quick check: did it solve the problem or silence it?"
- Weak: "Stop — always check what the fix did. Open the diff. Run the tests. AI confidently 'fixes' bugs by suppressing errors. If you don't verify, you'll ship a hidden problem."

**Redirect on struggle** (only if triggered):
- Strong: "Smart move — you gave it a different angle when it was stuck. That's the right instinct."
- Adequate: "You let it loop a few rounds before changing approach. After 2 failed attempts, switch it up — different context, different file, different theory."
- Weak: "When it's going in circles, stop. Don't let it loop. Give it a completely different angle — a different file to look at, a different theory about the cause."

**If ALL dimensions are Strong:**
"That's the whole workflow — you gave great context, the fix was clean, and you verified it. This is what AI-assisted bug fixing looks like when you do it right."

**Coaching delivery rules:**
- Never mention eval, ratings, scores, or the teaching system
- Weave coaching into natural conversation — not a list of feedback items
- Lead with what was strong before coaching what was weak
- Use contrast examples for weak ratings (show better vs. what they did)
- Keep it to 1-3 sentences per dimension — don't lecture

## Bridge
"Now imagine applying this speed to test writing — pointing AI at a function that has no tests and getting a test suite in 60 seconds. That's next."

## State Update
Write to .goose/state/progression.json:
  concept 1.1 dimensions with eval ratings + timestamp.
  Update concept status to "complete" if all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
