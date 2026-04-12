# Recipe 1.3: Code Review — "AI as tireless reviewer"

## Setup
Read .goose/team_context.md for project context (stack, conventions, architectural patterns).
Read .goose/state/progression.json — check if concept 1.3 is already demonstrated.
If already demonstrated (all dimensions adequate+):
  "You've already shown you can do this well. Want to skip ahead to [next incomplete recipe], or run through another review to sharpen the skill?"
  If skip: jump to Bridge section.
  If revisit: continue normally — update ratings only if they improve.

## Framing
"Got a PR that needs review? Or some code you recently changed that you'd like a second set of eyes on? Could be a PR number, a branch, specific files, or a recent commit. Point me at it."

**Stuck path — developer has no code to review:**
"No problem. Let me find something worth reviewing in your recent changes."
Delegate to code-work subagent:
  "Read .goose/team_context.md. Check recent git history for the most recent
  meaningful commit or branch with changes — something with logic changes, not
  just config or formatting. Ideally 50-200 lines of diff. Report: what the
  changes are, which files were touched, and a one-line summary of the commit
  intent."

While waiting (insight 1.3b): "One thing that makes AI review powerful — you can run it multiple times with different focus areas. Security pass, logic pass, performance pass. Each one finds things the others missed. That's how review scales without adding people."

Present the found target naturally:
"Your most recent meaningful change looks like [commit/branch description] — [files touched]. Want to review that?"

## The Task
Developer identifies the review target (or accepts the found one).

Note what the developer provides — this is what the eval will assess for scope definition:
- Did they point at specific files, a PR, or a commit range?
- Or did they ask for a general review of a broad area?

Delegate to code-work subagent:
  sub-recipe: "code-review"
  parameters:
    review_target: {developer's chosen target}
    review_focus: {if provided}
    context: {if provided}

While waiting (insight 1.3a): "While it reviews — AI defaults to polite. A review that says 'looks good' isn't necessarily a green light. It might just mean you didn't ask the right question. Specific focus gets specific findings."

[Subagent reviews, returns findings]

Present results naturally — organize by severity, not as a raw dump:
"Found [N] things worth looking at. [Critical count] are serious, [warning count] are worth considering, and [suggestion count] are minor improvements."

Walk through the critical and warning findings conversationally:
"The big one is [critical finding in plain language]. [Why it matters]. [Suggested fix]."

**Watch what the developer does next.** The eval assesses multiple dimensions here:

*Triage quality:* Do they distinguish real issues from noise? Do they identify which findings to act on and which to skip? Or do they treat everything equally?

*Iteration and refinement:* Do they ask for a focused follow-up ("now check for security issues" or "ignore style, find logic errors")? Or take the first result as final?

*Healthy skepticism:* If the review is mostly positive, do they probe further? Or accept "looks good" at face value?

If the review comes back mostly clean and the developer accepts it:
"Looks pretty clean. Want me to take another pass focused on [security / error handling / edge cases]? Sometimes a specific focus finds things the general pass missed."

If the developer treats all findings equally without triaging:
Wait for the eval — but if they explicitly say "I'll fix all of these," you can naturally ask:
"Which of these would you actually fix before merging? Not all findings are equal."

## Eval
Delegate to eval subagent (async: true):

While waiting (insight 1.3c): "AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage — which findings matter, which are noise, which are wrong. That judgment is the skill."

```
You are evaluating how well a developer approached code review with AI assistance.

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
   Strong: Developer pointed at specific files, a PR, or a commit range — a clear, bounded review target.
   Adequate: Developer gave a reasonable scope but could be more precise — e.g., a whole directory instead of specific changed files.
   Weak: Developer asked for a general review of a broad area with no specific target.

2. TRIAGE QUALITY
   Strong: Developer distinguished real issues from noise — identified what to fix, what to ignore, what was wrong in the review itself.
   Adequate: Developer engaged with the findings but treated them mostly equally without prioritizing.
   Weak: Developer accepted all findings at face value or dismissed them all without examination.

3. ITERATION AND REFINEMENT
   Strong: Developer refined the review with focused follow-ups — e.g., "focus on security," "ignore style, find logic errors."
   Adequate: Developer did one pass but didn't try to refine or steer the review.
   Weak: Developer took the first result as the final answer.

4. HEALTHY SKEPTICISM
   Strong: Developer probed beyond positive feedback — asked follow-up questions even when the review was mostly clean.
   Adequate: Developer accepted mostly-positive results but didn't blindly trust them — showed some awareness that AI defaults to polite.
   Weak: Developer accepted a positive review without any follow-up questions or skepticism.

Return as JSON:
{
  "dimensions": [
    {"name": "scope_definition", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "triage_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "iteration_and_refinement", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "healthy_skepticism", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

**Scope definition:**
- Strong: "Good scoping — you pointed it at exactly what matters. That's why the findings are relevant."
- Adequate: "This worked, but next time try pointing at just the changed files in the PR, not the whole directory. Tighter scope = less noise."
- Weak: "Point it at a PR or specific files, not the whole repo. What you got back is mostly noise because the scope was too broad."

**Triage quality:**
- Strong: "You triaged well — you caught that finding #3 is a real bug but #5 is just a style preference. That judgment is exactly what makes AI review useful."
- Adequate: "Some of these are real bugs, some are style preferences, and some are just wrong. Don't treat them equally. Which ones would you actually fix before merging?"
- Weak: "AI reviews mix real bugs with style opinions with outright mistakes. You need to triage — which are real issues? Which are noise? That skill is what makes this tool useful."

**Iteration and refinement:**
- Strong: "Smart — you steered it. Each focused pass finds more than one broad pass. This is how you get the most from AI review."
- Adequate: "Good first pass. Try steering it: 'ignore style issues, just find logic errors' or 'focus on security.' Each focused pass finds things the general one missed."
- Weak: "This is a starting point, not the final answer. Try: 'now focus only on security issues' or 'ignore formatting, find logic errors.' You can steer it to find what matters."

**Healthy skepticism:**
- Strong: "Good instinct — you didn't let 'looks good' be the final word. AI defaults to polite. Probing further is how you find what it missed."
- Adequate: "The review says this code is clean. It might be. But AI defaults to polite — a positive review is a starting point. Try asking: 'what could go wrong in production?'"
- Weak: "It said the code looks clean. That doesn't mean there are no bugs. AI defaults to polite. Always probe: 'what are the edge cases?' or 'what could go wrong under load?' Silence from AI isn't a green light."

**If ALL dimensions are Strong:**
"That's how you use AI review — tight scope, triaged the findings, steered for depth, and didn't trust a clean bill of health. You're getting more from one AI review pass than most people get from three."

**Coaching delivery rules:**
- Never mention eval, ratings, scores, or the teaching system
- Weave coaching into natural conversation — not a list of feedback items
- Lead with what was strong before coaching what was weak
- Use contrast examples for weak ratings
- Keep it to 1-3 sentences per dimension — don't lecture

## Bridge
"You've been fixing bugs, writing tests, and reviewing code. One more skill — AI handles the restructuring you've been putting off. Got some ugly code that works but makes you cringe? That's next."

## State Update
Write to .goose/state/progression.json:
  concept 1.3 dimensions with eval ratings + timestamp.
  Update concept status to "complete" if all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
