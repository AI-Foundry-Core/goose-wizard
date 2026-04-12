# Act 2: Your First Edit

*Concept 0.2 — AI edits your actual code*
*Duration: ~10 minutes*
*Prerequisites: Act 1 (See Your Code)*

---

## Step 1: Create Safety Branch

Say:
"Before I touch anything, let's create a practice branch. Everything we do today happens here — your main branch stays untouched."

Action: Delegate to subagent:
  "Run: git checkout -b practice/stage-0
  Return confirmation that the branch was created."

Say:
"Done — we're on a practice branch now. Nothing we do here affects your real code. Think of it like a scratch pad."

---

## Step 2: Find and Propose a Change

Say:
"Let me look through your code and find a small improvement I could make."

Action: Delegate to subagent:
  "Read .goose/team_context.md for project context (if missing, use
  the project summary from Setup — scan README.md, pyproject.toml,
  setup.cfg, package.json, Cargo.toml, or go.mod to infer the stack).
  Find a small, safe improvement in the source code. Good candidates:
  - A variable with a vague name (x, data, temp, result) that could
    be more descriptive
  - A branch condition that could be clearer or more explicit
  - A log or error message that could include more useful context

  Avoid trivial changes like adding a comment — the change should be
  something the developer needs to actually evaluate, not rubber-stamp.

  Do NOT make the change yet. Return:
  - file_path: which file
  - line_number: which line
  - current_code: the current code (just the relevant lines)
  - proposed_code: what it would look like after the change
  - diff: a readable diff showing the change
  - rationale: one sentence explaining why this is better"

While waiting (insight 0.2): "Something to keep in mind — the more specific you are when you ask for something, the better the result. That's true for every AI tool. Vague in, vague out."

Say:
"I found something in [file_path] on line [line_number].

Here's what's there now:
```
[current_code]
```

Here's what I'd change it to:
```
[proposed_code]
```

[rationale]

This is a small change, but it's a real one — I'm going to edit your actual file. Want me to go ahead?"

Check: Wait for the developer to approve.

---

## Step 3: Apply the Change

Action: Delegate to subagent:
  "Edit [file_path]: replace [current_code] with [proposed_code].
  Confirm the edit was applied. Return the file path."

Say:
"Done. Open [file_path] in your editor and look at line [line_number] — you should see the change.

This is the core loop of AI-assisted development: I propose, you review, you approve, I apply. You're always in control."

Check: Wait for the developer to confirm they see the change.

---

## Step 4: Bridge to Act 3

Say:
"Now here's the thing — what if you didn't like that change? What if I made a bad suggestion? Let me show you how easy it is to undo anything I do."
