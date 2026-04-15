# Act 3: The Undo Button

*Concept 0.3 — The AI can reverse its own work*
*Duration: ~2 minutes*
*Prerequisites: Act 2 (Your First Edit)*

> **Path resolution note.** All shell commands in this script act on the
> TARGET codebase. Use `git -C <TARGET>` when delegating. When delegating
> to a subagent, prepend the parent recipe's TARGET PROLOGUE.

---

## Framing

The audience is a working developer. They know git. Do NOT explain
`git diff`, `git checkout`, branches, or reverts. The point of this act
is a single demonstration: **if the AI makes a change you don't want,
the AI can revert it on demand.** That's it. Keep it short.

---

## Step 1: Show the Change

Say:
"Quick one — what if you hadn't liked that edit? Here's what's on the branch right now:"

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Run: git -C <TARGET> diff
  Return the full diff output."

Say:
"```
[diff output]
```

Say the word and I'll revert it. Want me to?"

Check: Wait for the developer's answer. Accept any form of yes/no.

---

## Step 2: Revert the Change

If the developer says yes (or any form of "go ahead"):

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Run: git -C <TARGET> checkout -- [file_path from Act 2]
  Then run: git -C <TARGET> diff
  Return both the checkout confirmation and the new (expected empty)
  diff output."

Say:
"Reverted. Diff is empty — file is back to where it started. Any change I make, I can undo the same way."

If the developer says no (wants to keep the edit):

Say:
"Fair. Point was just to show it's reversible — same command works any time. Moving on."

---

## Step 3: Re-apply for Later Acts

Say:
"I'll put the edit back so we have something to work with in the next act."

(Skip Step 3 if the developer chose to keep the edit in Step 2.)

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Re-apply the same edit from Act 2: [file_path], [current_code] to
  [proposed_code]. Confirm it was applied."

Say:
"Back in place. Next act is where it gets more interesting — what happens when the AI gets something wrong. Ready?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State: Write Progress

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Write to <TARGET>/.goose/state/.stage-0-progress.json:
  {
    \"acts_completed\": [1, 2, 3],
    \"files_touched\": [\"[file_path]\"],
    \"branch\": \"practice/stage-0\"
  }"
