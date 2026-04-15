# Act 5: Say It Better

*Concept 0.5 — You control the quality*
*Duration: ~5 minutes*
*Prerequisites: Acts 1-4*

> **Path resolution note.** All paths act on the TARGET codebase. The
> function the developer picks lives under `<TARGET>/`. Prepend the parent
> recipe's TARGET PROLOGUE to every `Delegate to subagent` call, and use
> absolute paths starting with `<TARGET>/` when passing file paths.

---

## Step 1: The Vague Request

Say:
"Last exercise — vague vs specific instructions. Pick a function in your project that could be improved — just tell me the file and function name. Or want me to find one that looks like a good candidate?"

Check: Wait for the developer to pick a function.

Say:
"OK. First, I'm going to improve that function with a vague instruction. Watch what happens."

Action: Delegate to subagent:
  "You have been given a deliberately vague instruction. Follow it
  literally — do not overperform.

  Instruction: 'Improve the function [function_name] in [file_path]'

  Make a mediocre, surface-level change. Maybe rename one variable,
  or add a generic comment like '// process data'. Do the minimum
  that technically counts as 'improving.'

  Do NOT actually edit the file. Just return:
  - vague_diff: what the change would look like
  - vague_description: one sentence describing what you did"

Say:
"Here's what I did with 'improve this function':

```
[vague_diff]
```

[vague_description]

Not great, right? The instruction was vague, so the result was vague. Now let's try something different.

This time, YOU write the instruction. Be specific — tell me exactly what you want improved. For example:
- 'Rename the variables to be descriptive'
- 'Add input validation for null values and empty strings'
- 'Break this into two smaller functions: one for X, one for Y'
- 'Add error handling with specific error messages'

What would you like me to do with this function?"

Check: Wait for the developer to write a specific instruction.

**If the instruction is semi-specific** (better than "improve it" but still vague — e.g., "add better error handling" or "make it more readable"):

Say:
"That's a start — but I want to push you a bit. [Ask a targeted question based on their instruction. For error handling: 'What specific errors? What should happen when each one occurs?' For readability: 'What makes it hard to read — the naming, the nesting, the length? Pick one.' For performance: 'Which operation is slow? What's the expected input size?']"

Check: Wait for a revised, more specific instruction.

---

## Step 2: The Specific Request

Action: Delegate to subagent:
  "Apply this instruction to [function_name] in [file_path]:

  '{user_specific_instruction}'

  Do your best work. Make the change to the file.

  Return:
  - specific_diff: the full diff
  - specific_description: what you did and why each change matters"

Say:
"Here's what I did with your specific instruction:

```
[specific_diff]
```

[specific_description]

Before we compare — take a look at that diff. Could this change break anything?"

Check: Wait for the developer's response.

If the developer spots an issue: acknowledge it and fix it. This reinforces Act 4's lesson about reviewing AI output.
If the developer says it looks fine: accept and move on. The review habit is forming — don't force a false finding.

Say:
"Good. Now compare the two:

**Vague instruction** -- [vague_description]
**Your instruction** -- [specific_description]

Same AI, same function, completely different results. The difference was you. The quality of what you get from AI is directly proportional to the quality of what you ask for. This is the single most important skill in AI-assisted development — and you just demonstrated it."

---

## Step 3: Wrap Up and Bridge to Stage 1

Say:
"That's the basic loop. Here's what you've got now:

1. **AI can see your code** — it reads actual files, not guessing from descriptions
2. **You approve every change** — nothing happens without your permission
3. **Git is your undo button** — any change can be reversed instantly
4. **AI makes mistakes** — confident, plausible, wrong. Your job is to catch them
5. **Specific instructions get better results** — how you ask matters more than what you ask

Next time, bring a real bug or some code you've been meaning to clean up. That's where this gets practical — fixing real problems, writing real tests, running real reviews. All with AI doing the heavy lifting. Ready to do it for real?"

Check: Wait for acknowledgement — they may want to stop for the day or keep going. Either answer is fine; this is the end of Stage 0.

---

## Cleanup

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Switch back to the original branch and delete the practice branch in <TARGET>:
  1. Run: git -C <TARGET> checkout [original_branch]
  2. Run: git -C <TARGET> branch -D practice/stage-0

  Write final state to <TARGET>/.goose/state/.stage-0-progress.json:
  {
    \"acts_completed\": [1, 2, 3, 4, 5],
    \"stage_complete\": true,
    \"completed_at\": \"[timestamp]\"
  }

  Return confirmation."

## State Update
Write to ~/.rilgoose/progression.json:
  Set stage 0 status to "complete" with completed_at timestamp.
  Stage 0 has no eval-rated dimensions — completion is based on finishing all 5 acts.
  Do not surface the state update to the developer — it happens silently.
