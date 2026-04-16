# Example Module: Bug Fix (Recipe 1.1)

This is the reference implementation. Every module has up to 3 artifacts: agent primitive (always), training recipe (always), and graduated recipe (multi-agent only). Bug Fix is single-agent, so it has 2.

---

## Part 1: Agent Primitive

See `recipes/agents/bug-fix.yaml` for the actual file. Key structure:

- Title ends with "Agent": `"Bug Fix Agent"`
- `## Constraints` with IMPORTANT + 4 NEVER rules
- `## Process` with numbered steps
- `## Return` with structured output fields
- No teaching content — this is a reusable tool

**Why this recipe works standalone:** After graduation, this primitive replaces the training recipe in `shared/`. A developer running it gets a clean bug-fixing tool: describe the bug → AI investigates → fix → tests → diff.

## Part 2: Training Recipe

See `recipes/shared/02-bug-fix.yaml` for the actual file. Key structure:

- Title ends with "(Training)": `"1.1 Bug Fix (Training)"`
- `sub_recipes:` references `../agents/bug-fix.yaml` and `../agents/graduate-module.yaml`
- 6 rules in `instructions:` (interactive, narrate, never code, never mention eval, coach naturally, lead with strength)
- `prompt:` contains the full teaching flow: runtime isolation, file reads, progression check, teaching script flow, eval, recipe reveal, state update, graduation, bridge

---

## Part 2: Teaching Script

```markdown
# teaching/stage-1/bug-fix.teach.md

# Recipe 1.1: Bug Fix — "AI as investigator"

## Setup
Read .goose/team_context.md for project context.
Read ~/goose-wizard/progression.json — check if concept 1.1 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

## Framing
"Got a bug that's been bugging you? Something you've been meaning to fix, 
or something that's been hard to track down? Tell me about it — what's 
happening, what you expected, and anything you've already tried."

If developer has no current bug:
  "No problem. Let me scan your codebase for something we can work with."
  Delegate to code-work subagent:
    "Read .goose/team_context.md. Find a code smell, potential issue, or 
    TODO/FIXME comment that represents a real problem worth fixing. 
    Describe it as a bug report the developer would recognize."

## The Task
Developer describes the bug (or accepts the found issue).

Delegate to code-work subagent:
  sub-recipe: "bug-fix"
  parameters:
    bug_description: {developer's description}
    suspected_location: {if provided}
    prior_attempts: {if provided}

[Subagent investigates, fixes, returns results]

Facilitator presents the results naturally:
"[Here's what was wrong...] [Here's what I changed...] [Tests: X passing, 0 failing.]"

## Eval
Delegate to eval subagent (async: true):
  [See eval prompt below]

## Coaching
Read eval results. For each dimension:
- Strong: Acknowledge specifically. "[Exact praise from quality dimension table]"
- Adequate: Light suggestion. "[Exact coaching from quality dimension table]"
- Weak: Targeted coaching with contrast. "[Exact coaching from quality dimension table]"

If ALL dimensions are Strong:
"That's the whole workflow — you gave great context, the fix was clean, 
and you verified it. This is what AI-assisted bug fixing looks like 
when you do it right."

## Bridge
"Now imagine applying this speed to test writing — pointing AI at a 
function that has no tests and getting a test suite in 60 seconds. 
That's Recipe 1.2."

## State Update
Write to ~/goose-wizard/progression.json:
  concept 1.1 dimensions with eval ratings + timestamp
```

---

## Part 3: Eval Subagent Prompt

```
You are evaluating how well a developer approached fixing a bug with AI assistance.

Here is the full conversation transcript:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating
3. Coaching: If not Strong, 1-2 sentences the facilitator should say (conversational, never mentions eval)

Dimensions:

1. CONTEXT QUALITY
   Strong: Developer described the symptom AND at least one of: reproduction steps, suspected location, or what they already tried.
   Adequate: Developer described the symptom with some detail but left out all of: reproduction steps, suspected location, prior attempts.
   Weak: Developer gave a minimal description like "X is broken" or "it doesn't work" with no supporting detail.

2. FIX VERIFICATION
   Strong: After the fix, developer checked the diff OR ran tests OR asked what was changed before accepting.
   Adequate: Developer looked at the result but didn't explicitly run tests or inspect the diff.
   Weak: Developer accepted the fix immediately without any verification.

3. REDIRECT ON STRUGGLE (conditional)
   Condition: Only rate this if the AI took 3+ attempts to fix the bug.
   If condition not met: return rating=null, evidence="Not triggered", coaching=null
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

---

## Part 4: Quality Dimension Table (from syllabus)

This is what the facilitator uses to coach. The eval subagent rates; the facilitator speaks.

| Quality Dimension | Strong | Adequate | Weak |
|-------------------|--------|----------|------|
| **Context quality** | Developer described symptom + what they tried / where they suspect / how to reproduce. *"That's exactly the kind of context that makes AI fast — you gave it the symptom, what you ruled out, and a theory. This is why it found the fix in one pass."* | Developer gave some context but left out key info. *"Good start — next time also mention what you already tried, so the AI doesn't retrace your steps."* | Developer said something like "the login is broken" with no detail. *"Compare what you said to: 'login fails after OAuth redirect, I checked the callback URL, I think the session isn't persisting.' The second version gets a fix in one pass. Context is everything."* |
| **Fix verification** | Developer checked diff, ran tests, or asked what changed before accepting. *"Good — you checked what the fix actually did before accepting it. That's the habit."* | Developer glanced but didn't explicitly verify. *"It looks like it worked, but open the diff. AI sometimes hides errors instead of fixing them — wraps things in try/catch. Quick check: did it solve the problem or silence it?"* | Developer just accepted without checking. *"Stop — always check what the fix did. Open the diff. Run the tests. AI confidently 'fixes' bugs by suppressing errors. If you don't verify, you'll ship a hidden problem."* |
| **Redirect on struggle** | *(Only if AI struggled)* Developer changed approach after 2+ failed attempts. *"Smart move — you gave it a different angle when it was stuck. That's the right instinct."* | Developer waited too long but eventually adjusted. *"After 2 failed attempts, switch it up — different context, different file, different theory."* | Developer kept retrying same way. *"When it's going in circles, stop. Give it a completely different angle — a different file to look at, a different theory about the cause."* |

---

## What Makes This a Good Module

1. **Working recipe is genuinely reusable.** A developer would use `goose run bug-fix` daily.
2. **Teaching wraps cleanly.** The teach script invokes the working recipe as a sub-recipe — no duplication.
3. **Quality dimensions are observable.** Eval can tell from the transcript whether context was provided and whether the fix was verified.
4. **Coaching language is specific.** Each rating level has exact words the facilitator says, with contrast examples for weak ratings.
5. **Stuck path handled.** If the developer has no bug, the facilitator finds one.
6. **Bridge connects to next recipe.** Momentum is maintained.
