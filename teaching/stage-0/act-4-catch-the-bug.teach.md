# Act 4: Catch the Bug

*Concept 0.4 — AI is confident, not correct*
*Duration: ~10 minutes*
*Prerequisites: Acts 2 and 3 (First Edit, Undo Button)*

---

## Step 1: Introduce the Bug (Privately)

Say:
"Let me add a small feature to your code. I'm sending a helper to find a good spot and make a change — you'll see some activity while it works."

Action: Delegate to subagent:
  "Read .goose/team_context.md for the stack.
  Find a function in the source code that does some logic —
  data processing, validation, calculation, string handling.
  Something with at least a few lines of logic.

  Add a realistic-looking change that contains a SUBTLE bug.
  Good bug types for [detected language]:
  - Wrong comparison operator (< instead of <=)
  - Off-by-one in a loop or slice
  - Missing null/undefined/None check
  - Wrong variable used (using the input instead of the processed version)
  - String concatenation in wrong order

  The change should look plausible — like something a competent
  developer might write quickly without thinking. NOT an obvious
  syntax error.

  Make the change to the file.

  Return (THIS IS PRIVATE — facilitator will not show all of this to the developer):
  - file_path: which file
  - diff: the full diff to show the developer
  - bug_location: exact line number and what's wrong
  - bug_explanation: why this would cause a problem at runtime
  - hint_1: a gentle nudge without giving it away
  - hint_2: a more specific hint pointing at the line
  - fix: what the correct code should be"

While waiting (insight 0.3): "While it's looking — one habit worth building early: after any change, run the tests. AI writes confident code, but confident and correct aren't the same thing."

---

## Step 2: Show the Diff

Say:
"OK, I just made a change to [file_path]. Here's the diff:

```
[diff]
```

Take a look at this. Does everything look correct to you?"

Check: Wait for the developer's response.

---

## Step 3: Guide Based on Response

**If the developer identifies the bug immediately (before being prompted):**

Say:
"You read diffs carefully — that habit is going to save you. [bug_explanation].

Most people skim and say 'looks fine.' You didn't. That's the single most important skill in AI-assisted development — reading what the AI actually wrote, not trusting that it got it right."

[Skip to Step 4: Fix It]

**If the developer identifies the bug after the prompt:**

Say:
"You caught it. [bug_explanation].

This is the most important thing I'm going to teach you today: AI writes confident, plausible, wrong code. It doesn't hesitate or flag uncertainty. It just writes it like it's obviously correct.

Your job — always — is to review what the AI produces. Not skim it. Actually read it and think about whether it's right. You just proved you can do that."

**If the developer says it looks fine:**

Say:
"Take another look, specifically around [hint_1]."

Check: Wait for response.

**If still stuck after first hint:**

Say:
"Look at line [bug_location]. [hint_2]"

Check: Wait for response.

**If still stuck after second hint:**

Say:
"Here's what's wrong: [bug_explanation].

Don't feel bad about missing it — this is exactly the kind of mistake AI makes constantly, and it's exactly why reviewing AI output is a non-negotiable skill. The AI wrote this confidently. It didn't warn you. It never will. That's your job."

---

## Step 4: Fix It

Say:
"Let me fix that."

Action: Delegate to subagent:
  "Fix the bug in [file_path] at line [bug_location].
  The correct code should be: [fix].
  Return the corrected diff."

Say:
"Fixed. In real work, this is the cycle: AI proposes, you review, you catch issues, AI fixes them. The AI is fast but fallible. You are slower but critical. Together, you're better than either alone."

---

## Bridge to Act 5

Say:
"One more thing before we wrap up — I want to show you the single biggest lever you have when working with AI."
