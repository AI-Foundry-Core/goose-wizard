# Recipe 1.3: Code Review — "AI as tireless reviewer"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the codebase," interpret those against
> `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `code-review` sub-recipe.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context (stack, conventions, architectural patterns).
Read ~/goose-wizard/progression.json — check if concept 1.3 is already demonstrated.
If already demonstrated (all dimensions adequate+):
  "You've already shown you can do this well. Want to skip ahead to [next incomplete recipe], or run through another review to sharpen the skill?"
  If skip: jump to Bridge section.
  If revisit: continue normally — update ratings only if they improve.

## Framing
"Got a PR that needs review? Or some code you recently changed that you'd like a second set of eyes on? Could be a PR number, a branch, specific files, or a recent commit. Point me at it — or want me to grab your most recent meaningful change?"

**Stuck path — developer has no code to review:**
"No problem. Let me find something worth reviewing in your recent changes."
Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  "Read <TARGET>/.goose/team_context.md. Check recent git history in
  <TARGET>/ (use `git -C <TARGET> log`) for the most recent meaningful
  commit or branch with changes — something with logic changes, not
  just config or formatting. Ideally 50-200 lines of diff. Report: what
  the changes are, which files were touched (absolute paths under
  <TARGET>/), and a one-line summary of the commit intent."

Present the found target naturally:
"Your most recent meaningful change looks like [commit/branch description] — [files touched]. Want to review that?"

## The Task
Developer identifies the review target (or accepts the found one).

Note what the developer provides — this is what the eval will assess for scope definition:
- Did they point at specific files, a PR, or a commit range?
- Or did they ask for a general review of a broad area?

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "code-review"
  parameters:
    review_target: {developer's chosen target}
    review_focus: {if provided}
    context: {if provided}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

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
   Strong: Developer shows they are not accepting the review at face value — challenges questionable findings, asks for evidence or focused follow-up, or probes beyond positive feedback when the review is mostly clean.
   Adequate: Developer engaged with findings but didn't challenge any or request deeper investigation — showed some awareness that AI defaults to polite but didn't act on it.
   Weak: Developer accepted the review output without any follow-up questions, challenges, or skepticism.

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
- Strong: "Good instinct — you challenged the findings instead of taking them at face value. That judgment call is exactly what makes AI review useful instead of noisy."
- Adequate: "Some of those findings deserved pushback. When you see something that looks wrong or noisy, say so — challenge it, ask for a focused follow-up, or reject it. The review is a starting point, not a verdict."
- Weak: "Don't take the review at face value — positive or negative. Challenge findings that seem off. Ask for evidence. Request a focused pass on what matters. The skill isn't reading the output, it's deciding what's real."

**If ALL dimensions are Strong:**
Deliver in two exchanges, not one block:

First: "You scoped this tightly and triaged the findings against your actual context. That's why the review stayed useful instead of turning into a grab bag."

[Pause — wait for the developer to respond before continuing.]

Second: "The focused follow-up found a different class of issue than the general pass. That's the habit: broad pass to orient, focused pass for the risks that matter."

Then bridge. Do NOT compress all four dimensions into a single uninterrupted turn. The developer must speak at least once during the debrief.

**Note:** Only use a "probe beyond a positive review" nudge when the first pass was actually mostly clean. If the review returned multiple findings, the relevant nudge is about iteration and focused passes, not about probing positive feedback.

**Coaching delivery rules:**
- Never mention eval, ratings, scores, or the teaching system
- Weave coaching into natural conversation — not a list of feedback items
- Lead with what was strong before coaching what was weak
- Use contrast examples for weak ratings
- Keep it to 1-3 sentences per dimension — don't lecture

## Wait-Time Insights

Ordered list for this module. Use per teacher-instructions.md Section 13 rules.

1. (1.3a) `[review-scales]` "While it reviews — AI defaults to polite. A review that says 'looks good' isn't necessarily a green light. It might just mean you didn't ask the right question. Specific focus gets specific findings."
2. (1.3b) `[iteration]` "One thing that makes AI review powerful — you can run it multiple times with different focus areas. Security pass, logic pass, performance pass. Each one finds things the others missed. That's how review scales without adding people."
3. (1.3c) `[specificity]` "AI reviews mix real bugs with style opinions with outright mistakes. Your job is triage — which findings matter, which are noise, which are wrong. That judgment is the skill."
4. `[verify]` "A finding without evidence is an opinion. When the reviewer flags something, check: did it cite the line? Can you reproduce the concern? That's the difference between a useful review and noise."
5. `[enterprise]` "In a team setting, AI review doesn't replace human review — it front-loads it. Your reviewers spend less time on the obvious issues and more time on design and architecture."

## Enterprise Grounding

When the developer mentions team workflows, PR processes, CI/CD integration, or compliance during the review, answer the first question directly. Then connect: "How does your team currently handle review coverage for PRs that touch multiple services?"

Keep it to one question unless the developer wants to go deeper. Do not volunteer enterprise context unprompted unless the developer raises a team or process concern.

## Recipe Reveal
After enterprise grounding, show the developer the recipe behind this session.

"Third recipe reveal — let me show you what's different about this one."

Read the Code Review agent recipe (recipes/agents/code-review.yaml) and show the developer:
- The **`review_focus` parameter** — "Remember when we said you can run review multiple
  times with different lenses? That's literally one optional parameter. Empty = general review,
  'security' = security pass, 'performance' = performance pass. The iteration pattern you just
  used is encoded in a single field."
- The **severity categorization** — "See how the return block has `critical_count`,
  `warning_count`, `suggestion_count`? That's not just for your eyes. Later, when pipelines
  coordinate multiple agents, a downstream agent can say 'only proceed if critical_count is 0'.
  Structured output unlocks automation."
- The **read-only constraint** — "This recipe says 'this agent is read-only' three separate
  times. That's intentional. Review is safe to run 5 times in a row because it can never touch
  your code. Bug Fix and Refactor edit files — Code Review never does."
- Compare to Bug Fix and Test Writer — "Same four sections: parameters, constraints, process,
  return. Different content, same skeleton. That's the pattern you'll see for every recipe."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/code-review.yaml>`
"Open in the app — notice how much of what you just learned is right there in the YAML."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/code-review.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge
"You've been fixing bugs, writing tests, and reviewing code. One more skill — AI handles the restructuring you've been putting off. Got some ugly code that works but makes you cringe? That's next. Ready to keep going?"

Check: Wait for acknowledgement — they may want to stop for the day or keep going. If they have a clarifying question, answer briefly and re-offer.

## State Update
Write to ~/goose-wizard/progression.json:
  concept 1.3 dimensions with eval ratings + timestamp.
  Update concept status to "complete" if all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
