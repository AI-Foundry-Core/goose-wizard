# Recipe 6.1-6.3: Cycle Review - "Did the overnight run actually work?"

## Concepts Covered

- 6.1 Step back and evaluate the whole
- 6.2 Close the feedback loop
- 6.3 Success signals can lie

## Setup

Read `.goose/team_context.md` for project context.
Read `.goose/state/progression.json` and check concepts 6.1, 6.2, and 6.3.
If all three concepts are already demonstrated with Adequate or Strong ratings, offer to skip or revisit.

This is Fully Adaptive mode. Act as a consulting partner. Do not drive a lesson. Help the developer review a real autonomous cycle and coach only where the transcript shows an operational gap.

## Framing

"Bring me the artifacts from the cycle: conductor logs, session outputs, eval reports, diffs, or the run directory. We are not checking whether the last session looked good. We are checking whether the system improved across the run."

If the developer has no artifact path ready:

"No problem. I can scan the repo for the most recent run artifacts and we can review those. I will treat anything missing as unknown, not as success."

Delegate to code-work subagent:

```
Read .goose/team_context.md. Find the most recent autonomous pipeline or conductor artifacts in this repo. Look for run directories, session logs, eval output, cycle review logs, recommendation files, stop flags, and changed files. Return the artifact paths and a short explanation of what each contains. Do not modify files.
```

## The Task

Developer provides cycle artifacts or accepts the discovered artifact set.

Ask only for missing inputs that materially affect the review:

- Expected session count, if the cycle length is ambiguous
- Previous review path, if this is not the first cycle and no prior review artifact was found
- Specific concern, if the developer already suspects a failure mode

Delegate to code-work subagent:

```
sub-recipe: "cycle-review"
parameters:
  cycle_artifacts: {developer-provided or discovered artifact paths}
  session_count: {if provided}
  prior_review_path: {if provided or discovered}
  review_focus: {if provided}
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

## Bridge

"The next piece is durability. Once the cycle review teaches you something, the pipeline needs somewhere to put that learning, and each periodic agent needs memory it can actually find next time."

## State Update

Write to `.goose/state/progression.json` after eval completes:

```json
{
  "stages": {
    "6": {
      "status": "in_progress",
      "concepts": {
        "6.1": {
          "recipe": "cycle-review",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "holistic_cycle_review": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        },
        "6.2": {
          "recipe": "cycle-review",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "feedback_loop_closure": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        },
        "6.3": {
          "recipe": "cycle-review",
          "status": "complete_when_required_dimensions_adequate_or_strong",
          "dimensions": {
            "success_signal_skepticism": {
              "rating": "Strong|Adequate|Weak",
              "assessed_at": "ISO-8601 timestamp"
            }
          }
        }
      }
    }
  }
}
```

Never overwrite a Strong rating with a lower one.
