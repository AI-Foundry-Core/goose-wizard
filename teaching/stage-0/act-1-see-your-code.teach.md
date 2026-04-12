# Act 1: See Your Code

*Concept 0.1 — AI reads your actual code*
*Duration: ~10 minutes*
*Prerequisites: None*

---

## Setup

Action: Read `.goose/team_context.md` to learn the project's stack and source directories.

If `.goose/team_context.md` does not exist:
  Delegate to subagent:
    "No team_context.md found. Scan the project root for README.md,
    pyproject.toml, setup.cfg, package.json, Cargo.toml, or go.mod
    to infer the project's language, framework, and source directory
    structure. Return a brief project summary in the same format
    team_context.md would provide."

---

## Step 1: Facilitator Demonstrates

Say:
"Right now, you're used to AI that works like a search engine — you describe something, it gives you text back. What we're about to do is different. I can actually see your project files, read your code, and understand how your codebase works. Let me show you.

I'm going to send a helper to go browse through your project and pick an interesting file to look at. You might see some activity in your terminal — that's just my helper reading your files. Give me a moment."

Action: Delegate to subagent:
  "Read .goose/team_context.md for project context (if missing, use
  the project summary from Setup).
  Find a file in the main source directory that has meaningful logic
  (not a config file, not a test). Pick something a developer on this
  team would recognize — an API endpoint, a data model, a utility
  function, a component.

  Read the file. Return:
  - file_path: which file you chose
  - why: why you picked this one (1 sentence)
  - explanation: 2-3 paragraph explanation of what this file does,
    written for a developer who works on this project (not a beginner
    tutorial — speak to them as a peer)
  - interesting_detail: one specific thing about the implementation
    worth calling out"

While waiting (insight 0.1): "While it's working — one thing you'll notice is that the first result is rarely the final one. AI is fast, but the real workflow is iterative. First pass, review, adjust, second pass. That cycle is where the quality comes from."

Say:
"I picked [file_path] because [why].

[explanation]

One thing worth noting: [interesting_detail]."

---

## Step 2: Developer Tries

Say:
"Now it's your turn. Pick any file in your project — something you work with regularly — and ask me a question about it. Could be 'what does this function do?' or 'why is this structured this way?' or anything else."

Check: Wait for the developer to name a file and ask a question.

Action: Delegate to subagent:
  "Read {user_specified_file}. Answer this question from the developer
  who works on this code: {user_question}.

  Return:
  - answer: clear, peer-level answer to their question
  - follow_up: one follow-up observation about the file they might
    find interesting"

Say:
"[answer]

[follow_up]"

---

## Step 3: Bridge to Act 2

Say:
"So that's the first big difference from ChatGPT — I'm not guessing about your code from a description. I'm reading the actual files.

But reading is just the start. Next, I'm going to make a change to your code. Don't worry — you'll approve everything first, and we'll learn how to undo it right after."
