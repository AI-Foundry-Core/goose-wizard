# Act 1: See Your Code

*Concept 0.1 — AI reads your actual code*
*Duration: ~5 minutes*
*Prerequisites: None*

---

> **Path resolution note.** Every path referenced in this script is relative
> to the TARGET codebase (the developer's project), NOT RILGoose. The parent
> recipe injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the source code" or "the project," interpret
> it against `<TARGET>/` (the resolved target_codebase_path). Shell commands
> shown to the developer must include `cd <TARGET>` first or use `git -C
> <TARGET>`.

## Setup

Action: Read `<TARGET>/.goose/team_context.md` to learn the project's stack and source directories.

If `<TARGET>/.goose/team_context.md` does not exist:
  Delegate to subagent (prepend the TARGET PROLOGUE from the parent recipe):
    "No team_context.md found at <TARGET>/.goose/team_context.md. Scan
    <TARGET>/ for README.md, pyproject.toml, setup.cfg, package.json,
    Cargo.toml, or go.mod to infer the project's language, framework,
    and source directory structure. Return a brief project summary in
    the same format team_context.md would provide."

---

## Step 1: Facilitator Demonstrates

Say:
"I'm going to pick a file from your project and tell you what it does. One sec."

Action: Delegate to subagent (prepend the TARGET PROLOGUE from the parent recipe):
  "Read <TARGET>/.goose/team_context.md for project context (if missing,
  use the project summary from Setup).
  Find a file under <TARGET>/ in the main source directory that has
  meaningful logic (not a config file, not a test). Pick something a
  developer on this team would recognize — an API endpoint, a data
  model, a utility function, a component.

  Read the file. Return:
  - file_path: which file you chose
  - why: why you picked this one (≤12 words)
  - summary: 2-3 sentences max. What it does. No preamble, no
    section-by-section walkthrough. Peer-level.
  - interesting_detail: one specific thing worth calling out (1 sentence)"

Say:
"[file_path] — [why].

[summary]

One thing: [interesting_detail]."

---

## Step 2: Developer Tries

Say:
"Your turn. Ask me anything about your project — a file, a function, a design decision, a pattern, how a piece fits together, whatever's on your mind. Or want me to pick something interesting and talk about that?"

Check: Wait for the developer to ask ANY substantive question about their project. Interpret engagement broadly — if they ask about a concept, a file, a decision, an architecture piece, a library, or how something works, THAT is the engagement. Do not redirect them back to "pick a file" if they asked a different kind of question. The only reason to re-ask is silence or a clearly off-topic response.

Action: Delegate to subagent:
  "Answer this question from the developer about their project:
  {user_question}.

  Read whatever files, configs, docs, or code are needed to answer it
  well. If the question is abstract (a concept, a pattern, a decision),
  ground your answer in specific files or code from this repo.
  Peer-level, terse. No beginner framing.

  Return:
  - answer: 2-4 sentences, concrete, grounded in the actual codebase
  - follow_up: one observation they might find interesting (1 sentence)"

Say:
"[answer]

[follow_up]"

---

## Step 3: Bridge to Act 2

Say:
"So that's the first big difference from ChatGPT — I'm not guessing about your code from a description. I'm reading the actual files.

Reading is just the start though. Next, I'll make a change to your code. You'll approve everything first, and we'll learn how to undo it right after. Ready?"

Check: Wait for the developer to confirm (any affirmative — "yes", "sure", "go", "ready", a thumbs-up). If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer it briefly and re-offer.
