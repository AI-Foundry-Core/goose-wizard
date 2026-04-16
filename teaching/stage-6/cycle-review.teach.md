# Recipe 6.2: Cycle Review - "Did the overnight run actually work?"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, refers to cycle artifacts, run directories,
> session logs, conductor logs, eval output, diffs, or "the repo,"
> interpret those against `<TARGET>/`. Prepend the TARGET PROLOGUE to
> every `Delegate to subagent` call. Pass `target_codebase_path` to the
> `cycle-review` sub-recipe.

Covers concept 6.2 (cycle-review). Teaches holistic review, feedback loops, and success signal skepticism.

## Setup

Read `<TARGET>/.goose/team_context.md` for project context.
Read `~/.goose-wizard/progression.json` and check concept 6.2 (module 23: cycle-review).
If concept 6.2 is already demonstrated with Adequate or Strong ratings, offer to skip or revisit.

This is Fully Adaptive mode. Act as a consulting partner. Do not drive a lesson. Help the developer review a real autonomous cycle and coach only where the transcript shows an operational gap.

## Framing

"Bring me the artifacts from the cycle: conductor logs, session outputs, eval reports, diffs, or the run directory. We are not checking whether the last session looked good. We are checking whether the system improved across the run."

If the developer has no artifact path ready:

"No problem. I can scan the repo for the most recent run artifacts and we can review those. I will treat anything missing as unknown, not as success."

Delegate to code-work subagent (prepend the TARGET PROLOGUE):

```
Read <TARGET>/.goose/team_context.md. Find the most recent autonomous
pipeline or conductor artifacts in the target repo. Look under <TARGET>/
for run directories, session logs, eval output, cycle review logs,
recommendation files, stop flags, and changed files. Return absolute
artifact paths starting with <TARGET>/ and a short explanation of what
each contains. Do not modify files.
```

## The Task

Developer provides cycle artifacts or accepts the discovered artifact set.

Ask only for missing inputs that materially affect the review:

- Expected session count, if the cycle length is ambiguous
- Previous review path, if this is not the first cycle and no prior review artifact was found
- Specific concern, if the developer already suspects a failure mode

Delegate to code-work subagent (prepend the TARGET PROLOGUE):

```
sub-recipe: "cycle-review"
parameters:
  cycle_artifacts: {developer-provided or discovered artifact paths — absolute under <TARGET>/}
  session_count: {if provided}
  prior_review_path: {if provided or discovered — absolute under <TARGET>/}
  review_focus: {if provided}
  target_codebase_path: {TARGET — from the parent recipe's Step 0}
```

The code-work subagent invokes `recipes/stage-6/cycle-review.yaml`, performs the artifact review, and returns:

- cycle_inventory
- holistic_assessment
- feedback_loop_check
- success_signal_audit
- operational_risks
- recommendations

## Facilitator Response

Present the result as an operational readout:

"Here is the cycle-level read: [one-paragraph holistic assessment]. The biggest risk is [risk]. The key thing to carry into the next run is [recommendation with verification step]."

If the review finds ceremonial success:

"This is the part I would not let pass as green: [claim]. The logs say [claim], but the evidence only proves [actual evidence]. Treat that as unverified until the next run proves it."

If prior recommendations were not verified:

"This is an open loop. The last review said [recommendation], but this cycle never checked whether it changed behavior. Add the verification step to the next cycle so this does not become a permanent note nobody acts on."

## Eval

Delegate to eval subagent asynchronously after the review conversation:

```
You are evaluating how well a developer reviewed an autonomous multi-session pipeline cycle.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say. The coaching must be conversational, specific, and must never mention the eval system or ratings.

Quality dimensions:

1. HOLISTIC CYCLE REVIEW
   Strong: Developer considered trends across multiple sessions and compared the final result to the cycle goal, not just the latest output.
   Adequate: Developer reviewed more than one session but focused mostly on a summary or final state, with limited trend analysis.
   Weak: Developer treated the latest session or a single success summary as representative of the whole cycle.

2. FEEDBACK LOOP CLOSURE
   Strong: Developer checked whether prior recommendations were applied and whether they changed later session behavior.
   Adequate: Developer identified prior recommendations but did not fully verify their effect on later behavior.
   Weak: Developer logged or acknowledged findings without checking whether previous findings were acted on.

3. SUCCESS SIGNAL SKEPTICISM
   Strong: Developer investigated behind success claims such as "tests pass", "build succeeded", or "complete" by looking for commands, exit codes, diffs, eval evidence, or comparable proof.
   Adequate: Developer questioned at least one success claim but still accepted some claims from summaries without evidence.
   Weak: Developer accepted green status, passing claims, or completion messages without checking what they actually proved.

Return as JSON:
{
  "dimensions": [
    {
      "name": "holistic_cycle_review",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    },
    {
      "name": "feedback_loop_closure",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    },
    {
      "name": "success_signal_skepticism",
      "rating": "Strong|Adequate|Weak",
      "evidence": "...",
      "coaching": "..."
    }
  ],
  "overall_note": "..."
}
```

## Enterprise Grounding

After the developer drafts findings or recommendations, ask one enterprise-context question to force the conversation from abstract pattern to concrete enterprise infrastructure. Do not lecture about CI integration — ask a question.

**Required question (pick the one that fits the conversation):**

- "How does your team find out about these findings? Where do they live so the next person who runs a cycle sees them?"
- "If someone else runs the next cycle tomorrow, what do they need to see before they start?"
- "You described what to fix. Who owns the fix — the conductor, a separate ops agent, or the person who reviews the cycle?"

**Stop-flag lifecycle grounding:** If the developer discusses clearing or deleting state files (stop flags, stale signals), push on two concerns:

1. **Team ownership:** "Who cleans up the stop flag — the conductor automatically, or the person reviewing the cycle? What happens if two developers run parallel cycles?"
2. **Audit trail:** "If the file is deleted, where does the stop reason live afterward? The file is both a control signal and an audit artifact — deletion solves stale reads but can erase context. What preserves the history?"

The developer should arrive at a two-part lifecycle: control signal (delete or archive so future cycles cannot misread it) and audit trail (write the stop reason, clearer, timestamp, and follow-up recommendation to the cycle review or learnings file).

## Wait-Time Insights

Ordered list. Deliver one per subagent operation that takes 30+ seconds. See teacher-instructions.md Section 13.

1. `[verify]` "Read the conductor log before the summaries. The log tells you what the pipeline thought it was doing. The summaries tell you what each session thinks it did. Discrepancies between those two are where the interesting problems hide."
2. `[feedback-loops]` "Session summaries are self-reports. Treat them as pointers to evidence, not evidence by themselves."
3. `[verify]` "Exit code zero from the session process means the session finished. It does not mean the session's work is real."
4. `[define-success]` "A recommendation is not closed when it is written down. It is closed when the next cycle proves the pipeline acted on it and the behavior changed."
5. `[enterprise]` "This is why cycle review is a morning activity, not something the conductor does automatically. A human reading the filesystem is the verification layer."
6. `[feedback-loops]` "The most dangerous kind of failure is the kind that looks like it worked. Every green signal is a claim. The review is where you check the claims."

## Coaching

Use the eval results as private guidance. Never mention ratings, scoring, or the teaching system.

| Quality Dimension | Strong | Adequate | Weak |
| --- | --- | --- | --- |
| Holistic cycle review | "You looked across the run instead of trusting the final session. That is the right level for unattended work: trends first, latest output second." | "Next time, make the trend explicit. A session can look fine on its own while the cycle slowly drifts away from the goal." | "Do not judge the cycle from the last output. Pull the session list and ask: did the run move toward the goal, stall, or drift?" |
| Feedback loop closure | "You closed the loop: signal, action, verification. That is what keeps the review from becoming a notes file nobody uses." | "You found the recommendation, but add the last step: check whether it changed later session behavior." | "A recommendation is not closed when it is written down. It is closed when the next cycle proves the pipeline acted on it." |
| Success signal skepticism | "Good catch checking what the green result actually proved. 'Tests pass' only means something if the right tests ran and the exit code backs it up." | "You questioned the summary, but keep going one layer deeper on every green claim: command, exit code, artifact, or diff." | "Treat 'all green' as a claim, not evidence. Find what ran, what it checked, and what it missed before you trust it." |

If all dimensions are Strong:

"This is the morning-after workflow: review the whole cycle, close the loop from last time, and challenge the green lights. That is how you let a pipeline run while you sleep without letting it quietly drift."

## Recipe Reveal
After coaching, show the developer the recipe behind this session.

"You've been doing the verification work by hand. Here's what the agent is built to do —
and, more importantly, what it's forbidden from doing."

Read the Cycle Review agent recipe (recipes/agents/cycle-review.yaml) and show the developer:
- The **four `NEVER` constraints** — "'NEVER accept agent self-reports as evidence.'
  'NEVER infer success from missing evidence.' 'NEVER skip the mandatory independent
  verification pass.' This is the success-signal skepticism you just practiced — encoded
  as hard rules the agent cannot relax under pressure."
- The **`prior_review_path` parameter** — "Optional. When provided, the agent compares
  this cycle to the previous one. That's how the feedback loop chains — each cycle review
  becomes input to the next. Without this parameter, every review is isolated; with it,
  you get trend-level reasoning across runs."
- The **separated return fields for `verified_outcomes` vs `unverified_claims`** — "Most
  recipes return a single findings blob. This one splits claims by evidence status. A
  downstream conductor can auto-approve verified outcomes and surface unverified ones for
  human review. Structured output turns the review into a routing signal."
- The **observer stance in the instructions** — "'You review entire cycles — not individual
  sessions.' That's the frame: this agent never executes work, only evaluates patterns
  across sessions. Separating execution from observation is why cycle review can safely
  challenge the pipeline it's watching."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/cycle-review.yaml>`
"The NEVER block is the whole philosophy of this recipe — read that first, the rest
follows from it."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/cycle-review.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge

"The next piece is durability. Once the cycle review teaches you something, the pipeline needs somewhere to put that learning, and each periodic agent needs memory it can actually find next time. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## State Update

Update concept 6.2 (module 23: cycle-review) in `~/.goose-wizard/progression.json`:
  Store all dimension ratings (holistic_cycle_review, feedback_loop_closure,
  success_signal_skepticism) as sub-fields of concept 6.2's eval_ratings, plus timestamp.
  Update concept 6.2 status to "complete" when all dimensions are Adequate or Strong.
  If concepts 6.1 and 6.2 are both complete, mark Stage 6 complete.
  Never overwrite a Strong rating with a lower one.

Never overwrite a Strong rating with a lower one.
