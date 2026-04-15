# Recipe 7.3: Skill Evolution - "Fix the instruction, not the output"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, refers to findings files, `LEARNINGS.md`,
> cycle review logs, skill/instruction files, or "the pipeline,"
> interpret those against `<TARGET>/` (e.g., `<TARGET>/LEARNINGS.md`,
> `<TARGET>/.goose/`, `<TARGET>/agents/`). Prepend the TARGET PROLOGUE
> to every `Delegate to subagent` call. Pass `target_codebase_path` to
> the `skill-evolution` sub-recipe.

Covers concept 7.3 (skill-evolution). Teaches the curator loop and instruction evolution.

Mode: Fully Adaptive. Facilitator is pure consulting - available when the developer asks, not driving.

---

## Setup

Read <TARGET>/.goose/team_context.md for project context.
Read ~/.rilgoose/progression.json - check concept 7.3 (module 26: skill-evolution).
If both already demonstrated (all dimensions adequate+): offer to skip or revisit.

Check prerequisites:
- Stage 6 must be complete (developer has a running pipeline with cycle reviews)
- Confirm pipeline has generated at least one cycle review with actionable findings
  (need real findings to feed the Curator - synthetic ones defeat the purpose)

If no cycle review findings exist:
  "Your pipeline needs to have run enough cycles to produce review findings.
  Run a few cycles first, then come back - the Curator needs real data to work with."

---

## Framing

"Your pipeline builds, tests, and reviews. You've been running cycles and catching
issues in cycle review. But what happens to those findings? Right now they sit in
a log. The next step is closing that loop - turning findings into actual changes
to how your agents behave."

Pause for developer response. This is consulting mode - if they want to steer
the conversation, follow their lead.

If developer asks what this means practically:
  "When your cycle review says 'the builder keeps writing trivial tests,' the fix
  isn't rewriting the tests every cycle. The fix is changing the builder's
  instruction file so it stops writing trivial tests in the first place. That's
  what a Curator agent does - reads findings, edits instructions, verifies the
  edit actually helped."

---

## Task

The developer drives. The facilitator is available for questions but does not
direct the work step by step.

**What the developer needs to do:**

1. Identify findings from their cycle review or LEARNINGS.md that represent
   recurring agent behavior problems
2. Trace each finding to the instruction that caused (or failed to prevent) it
3. Use the skill-evolution recipe to turn those findings into instruction edits
4. Verify the edits actually improve behavior

Delegate to code-work subagent when the developer is ready (prepend the TARGET PROLOGUE):
  sub-recipe: "skill-evolution"
  parameters:
    findings_source: {developer's chosen findings file — absolute path under <TARGET>/}
    skill_files: {developer's chosen skill files — absolute paths under <TARGET>/}
    verification_command: {if developer provides one — should run from within <TARGET>/}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent analyzes findings, classifies them, drafts edits, applies them]

After discovery results return, present the raw findings without diagnostic
commentary. Do not name the finding-to-instruction connection for the developer.
Ask: "What do you notice?" or "What patterns do you see?" Let the developer
trace each finding to its instruction source. If the developer misses a
connection, hint with a question ("Where did that escalation rule actually
land?") rather than stating the answer.

Before the developer edits instructions based on review findings, have them
sample-check at least one finding against the source. Ask: "Before we tune
the instruction around these findings, which of these are actually correct?
Pick one and check the code." The Curator loop should not optimize from
untrusted reviewer output.

Facilitator presents results naturally:
"[Here's what it found...] [These findings mapped to instruction gaps...] 
[Here are the edits it made...] [Verification: ...]"

**If the developer wants to do a second pass** (common - first pass rarely
catches everything): encourage it. The Curator pattern is iterative.

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached evolving their pipeline's
agent instructions based on performance findings.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say  - 
   conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. FINDING-TO-INSTRUCTION TRACING
   Strong: Developer identified which specific instruction (or missing instruction) caused each behavior problem. Connected "the builder writes trivial tests" to "the builder prompt never defines what a meaningful assertion looks like."
   Adequate: Developer identified the right skill file but was vague about which part of the instruction was responsible. Pointed at the file, not the line.
   Weak: Developer treated the finding as an output problem, not an instruction problem. Wanted to fix the latest output instead of preventing the pattern.

2. EDIT SPECIFICITY
   Strong: Developer's instruction edits were precise - added or changed specific language that directly addresses the finding. Edits are minimal and targeted.
   Adequate: Developer made relevant edits but they were broader than needed - rewrote large sections when a sentence would have sufficed, or added vague guidance like "be more careful."
   Weak: Developer made no instruction edits, or the edits don't actually address the finding (e.g., adding a rule about formatting when the problem was test quality).

3. VERIFICATION INTENT
   Strong: Developer ran (or asked to run) a verification step after the instruction change - re-ran the pipeline, ran tests, or used the metrics-dashboard recipe to compare before/after.
   Adequate: Developer acknowledged that verification matters but didn't actually run it in this session.
   Weak: Developer applied the edit and moved on without any thought of verification.

4. CURATOR LOOP UNDERSTANDING (conditional)
   Condition: Only rate this if the developer discussed or demonstrated the full Generator-Reflector-Curator pattern - not just instruction editing, but the closed loop where findings automatically feed back into improvements.
   If condition not met: return rating=null, evidence="Not triggered", coaching=null
   Strong: Developer articulated or built a system where review findings flow automatically into instruction updates - a true closed loop, not a manual process.
   Adequate: Developer understands the concept but implemented it as a manual workflow - reads findings, manually decides what to edit.
   Weak: Developer edited instructions but doesn't see this as a repeatable loop - treated it as a one-time cleanup.

Return as JSON:
{
  "dimensions": [
    {"name": "finding_to_instruction_tracing", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "edit_specificity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "verification_intent", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "curator_loop_understanding", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Finding-to-Instruction Tracing

| Rating | Coaching |
|--------|----------|
| **Strong** | "You went straight to the instruction that caused the behavior. That's the key insight - when an agent keeps doing something wrong, the root cause is almost always in its prompt, not in the specific output." |
| **Adequate** | "You found the right file, but get more specific. Which sentence in the instruction let the agent think that behavior was acceptable? The more precisely you can point to the gap, the more targeted your fix." |
| **Weak** | "You're fixing outputs when you should be fixing instructions. Compare: manually rewriting trivial tests every cycle vs. adding 'every assertion must verify behavior, not existence' to the builder prompt. The second one fixes it permanently." |

### Edit Specificity

| Rating | Coaching |
|--------|----------|
| **Strong** | "Clean, minimal edit. You changed exactly what needed changing and nothing else. That's how instruction files stay manageable over time." |
| **Adequate** | "The edit addresses the problem, but it's broader than it needs to be. Rewriting a whole section when you could add one sentence risks breaking things that were working. Smallest effective change." |
| **Weak** | "The instruction change doesn't match the finding. Go back to what actually went wrong and write a rule that specifically prevents that. 'Be more careful' is not an instruction - 'verify every import path exists before committing' is." |

### Verification Intent

| Rating | Coaching |
|--------|----------|
| **Strong** | "Good - you checked whether the edit actually helped. That's what separates real improvement from hopeful tinkering." |
| **Adequate** | "You know verification matters - now do it. Run a few cycles with the new instruction and compare. The metrics-dashboard recipe can show you the before/after." |
| **Weak** | "You changed the instruction and moved on. How do you know it's actually better? Run the pipeline again and compare. Without verification, you're guessing." |

### Curator Loop Understanding (if triggered)

| Rating | Coaching |
|--------|----------|
| **Strong** | "That's the full loop - findings flow into instruction changes, verification confirms they worked, and the system actually gets smarter. Most teams never close this loop. You just did." |
| **Adequate** | "You're doing the right thing manually. The next level is making this automatic - a Curator agent that reads the cycle review log and proposes instruction edits without you initiating it." |
| **Weak** | "This isn't a one-time cleanup - it's a pattern. Every cycle generates findings. Every finding might point to an instruction gap. Build a loop, not a to-do list." |

If ALL dimensions are Strong:
  "You've got the full Curator pattern - findings become instruction edits,
  edits get verified, and the loop repeats. This is how pipelines actually
  improve instead of just running."

---

## Wait-Time Insights

Use these during code-work subagent operations. One per wait, in order.

1. [feedback-loops] "Most teams log findings but never close the loop back to instructions. The log grows, the behavior stays the same."
2. [specificity] "The difference between a vague instruction and a precise one is whether the agent can violate it accidentally. 'Be careful with tests' vs 'every assertion must verify behavior, not existence.'"
3. [verify] "An instruction edit without verification is a hypothesis, not an improvement. Run the pipeline and compare."
4. [enterprise] "On your team, who would review an instruction change before it goes live? Same person who reviews code, or different?"
5. [iteration] "The first Curator pass rarely catches everything. The pattern is iterative — edit, verify, discover what you missed, edit again."
6. [define-success] "A good instruction file is one where every rule exists because a specific failure taught you it was needed."

---

## Enterprise Grounding

Before Bridge. Ask at least one:
- "On your team, who reviews instruction changes to agent behavior — same as code review, or a different process?"
- "Where do these instruction files live — same repo as the code, separate config repo, or somewhere else?"
- Optional follow-up: "If two developers edit the same agent's instructions in the same sprint, how do you resolve conflicts?"

Maximum two questions unless the developer wants to go deeper.

---

## Recipe Reveal
After enterprise grounding, show the developer the recipe behind this session.

"This is the Curator. It's the recipe that edits other recipes based on what cycle review
finds. The safety rails are where the design lives."

Read the Skill Evolution agent recipe (recipes/agents/skill-evolution.yaml) and show the developer:
- The **five-way classification in the process block** — "INSTRUCTION_GAP,
  INSTRUCTION_VAGUE, INSTRUCTION_MISSING, INSTRUCTION_OUTDATED, NOT_INSTRUCTION. Every
  finding gets one label before any edit happens. That last one is the important one —
  'NOT_INSTRUCTION' means the root cause isn't in a prompt, so no edit is warranted.
  Without that category, the Curator would try to turn every finding into an edit."
- The **'NEVER combine multiple findings into one edit' constraint** — "One finding,
  one change. That's the traceability rule — if an edit breaks something, you can revert
  exactly the finding it came from. Batch edits look efficient and wreck the audit trail."
- The **'NEVER fix the output instead of the instruction' constraint** — "This is the
  whole philosophy in one line. The temptation is to patch the latest broken output. The
  discipline is to trace back to the instruction that allowed it. The recipe enforces
  that at the constraint level, not as a suggestion."
- The **`not_instruction` return field** — "Separate from `edits_applied`. The Curator
  is required to report what it DIDN'T fix and why. A curator that only shows its wins
  is a curator that's quietly skipping the hard findings."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/skill-evolution.yaml>`
"Read the classification step and the constraints block together — that's where the
Curator pattern actually lives."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/<file>.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge

This is the final recipe in the final stage. The bridge connects to the
ongoing practice, not to another module.

"That's the full arc. You started by watching AI fix a bug. Now you have a
development system that builds, tests, reviews, runs cycles while you sleep,
captures learnings, measures its own improvement, audits its own rules, and
evolves its own instructions.

The system doesn't need another stage. It needs you to keep doing what you've
been doing — running cycles, reviewing findings, letting the Curator turn
those findings into instruction changes, auditing the rule set, and measuring
the results. Every cycle makes it a little smarter.

The recipes are yours. Use them, edit them, author new ones. If you want
to design your own recipe or pipeline from scratch, the GooseForge recipes
(`recipes/graduated/recipe-forge.yaml` and `pipeline-forge.yaml`) walk
through that end-to-end.

Make sense — or want to hold here and let it soak before you go run a cycle?"

Check: Wait for the developer to respond. If they want to reflect or ask questions, engage. If they're ready to close, acknowledge and let them go. There's no next module — this is the end of the curriculum.

---

## State Update

Write to ~/.rilgoose/progression.json:
  Update concept 7.3 (module 26: skill-evolution) with all dimension ratings
  (finding_to_instruction_tracing, curator_loop_understanding,
  edit_specificity, verification_intent) as sub-fields of concept 7.3's eval_ratings,
  plus timestamp.
  Update concept 7.3 status to "complete" when all required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
