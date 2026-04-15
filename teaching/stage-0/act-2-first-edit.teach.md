# Act 2: Your First Edit

*Concept 0.2 — AI edits your actual code*
*Duration: ~5 minutes*
*Prerequisites: Act 1 (See Your Code)*

---

> **Path resolution note.** All paths and shell commands in this script act
> on the TARGET codebase. Prepend the parent recipe's TARGET PROLOGUE to
> every `Delegate to subagent` call. Use `git -C <TARGET>` or `cd <TARGET>`
> for shell commands.

## Step 1: Create Safety Branch

Say:
"Before I touch anything, let's create a practice branch. Everything we do today happens here — your main branch stays untouched."

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Run: git -C <TARGET> checkout -b practice/stage-0
  Return confirmation that the branch was created."

Say:
"Done — we're on a practice branch now. Nothing we do here affects your real code. Think of it like a scratch pad."

---

## Step 2: Find and Propose a Change

Say:
"Let me find a small improvement I could make. One sec."

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Read <TARGET>/.goose/team_context.md for project context (if missing,
  scan <TARGET>/ for README.md, pyproject.toml, setup.cfg, package.json,
  Cargo.toml, or go.mod to infer the stack).
  Find a small, safe, FUNCTIONAL improvement in source code under <TARGET>/.
  The change must do something real at runtime — not a rename, not a
  comment, not reformatting. Good candidates, in order of preference:
  - An error or log message that swallows context the caller needs to
    debug (e.g., 'conversion failed' with no file path or reason)
  - A missing guard for a value that could plausibly be None / empty /
    missing, where the current code would crash or misbehave
  - An over-broad `except Exception` that hides real errors and should
    catch a specific exception type
  - A magic number or literal that controls behavior and should be a
    named constant
  - A branch that silently does the wrong thing in an edge case

  Explicitly avoid: variable renames, docstring additions, formatting
  changes, type-hint-only changes. The developer needs to see the AI
  doing something useful, not cosmetic. If the only candidate you can
  find is cosmetic, keep looking or pick a different file.

  Do NOT make the change yet. Return:
  - file_path: which file
  - line_number: which line
  - current_code: the current code (just the relevant lines)
  - proposed_code: what it would look like after the change
  - diff: a readable diff showing the change
  - rationale: one sentence, ≤15 words, what this fixes or improves at
    runtime"

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

Want me to apply it?"

Check: Wait for the developer to approve.

---

## Step 3: Apply the Change

Action: Delegate to subagent (prepend the TARGET PROLOGUE):
  "Edit [file_path]: replace [current_code] with [proposed_code].
  Confirm the edit was applied. Return the file path."

Say:
"Done — [file_path] line [line_number]. Take a look."

Check: Wait for the developer to confirm they see the change. If they say "ok" or "done" without comment, move on. Do not prompt them to justify or evaluate the change — they're a developer, they can read a diff.

---

## Step 4: Bridge to Act 3

Say:
"Now here's the thing — what if you didn't like that change? What if I made a bad suggestion? Let me show you how easy it is to undo anything I do. Ready?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.
