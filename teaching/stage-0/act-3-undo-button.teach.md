# Act 3: The Undo Button

*Concept 0.3 — Everything is reversible*
*Duration: ~5 minutes*
*Prerequisites: Act 2 (Your First Edit)*

---

## Adaptive Shortcut

If the developer has demonstrated git understanding unprompted during Acts 1-2 — used terms like "branch," "commit," "checkout," "diff," or "revert" in context that shows comprehension (not just mentioning the word, but using it correctly in a sentence about their workflow):

Say:
"You already know git. Quick check — if I made a change you didn't like, how would you undo it?"

Check: Wait for response. If they mention git checkout, git restore, or git reset:

Say:
"Exactly. Same tools you already trust. The edit from Act 2 is still on the branch, so we're good to keep going."

Skip to State: Write Progress, then bridge to Act 4:
"Now comes the most important lesson — what happens when the AI writes something wrong."

---

## Step 1: Show the Change

Say:
"Let's see what's changed in your project right now."

Action: Delegate to subagent:
  "Run: git diff
  Return the full diff output."

Say:
"Here's everything that's different from your original code:

```
[diff output]
```

One command shows you every change. This is your first safety tool — `git diff` lets you see exactly what the AI changed before you commit anything."

---

## Step 2: Undo It (Developer Does This)

Say:
"Now let's undo that change. This time, you run the command. Type this in your terminal:

```
git checkout -- [file_path that was edited in Act 2]
```

Then run `git diff` to confirm the change is gone."

Check: Wait for the developer to run the commands themselves. If they ask you to do it instead, say: "I could, but this one's worth doing yourself — it's the muscle memory that matters. If I make a bad change at 2am, you want 'git checkout' in your fingers, not in mine."

If the developer runs the commands:

Say:
"See that? Empty diff — the file is back to its original state. That's your safety net. Between `git diff` (see what changed) and `git checkout` (undo it), you can always get back to where you started. The AI can never make a change you can't reverse."

If the developer struggles with the command (wrong syntax, wrong path):

Say:
"Close — here's the exact command:" and show the correct command. Let them try again.

---

## Step 3: Re-apply for Later Acts

Say:
"Let me re-apply that change so we have something to work with going forward."

Action: Delegate to subagent:
  "Re-apply the same edit from Act 2: [file_path], [current_code] to [proposed_code].
  Confirm it was applied."

Say:
"Change re-applied. Now comes the most important lesson — what happens when the AI writes something wrong."

---

## State: Write Progress

Action: Delegate to subagent:
  "Write to .goose/state/.stage-0-progress.json:
  {
    \"acts_completed\": [1, 2, 3],
    \"files_touched\": [\"[file_path]\"],
    \"branch\": \"practice/stage-0\"
  }"
