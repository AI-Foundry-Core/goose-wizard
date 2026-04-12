# Recipe 5.6: Eval Gate — "Evals must run before autonomy"

## Setup
Read .goose/team_context.md for project context.
Read .goose/state/progression.json — check if concept 5.6 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"You've built verification, layers, ratchets, specific criteria, and isolated dependencies. Now the question: would you let your pipeline run overnight unattended? Right now?"

Let the developer think about what's stopping them.

"The answer should be: only if every check you've built runs automatically as a gate between pipeline stages. Not as a report you read in the morning — as a gate that blocks the pipeline if something fails. An autonomous pipeline without evals is a pipeline you can't trust. Let's wire everything together."

## The Task
Developer identifies a pipeline they want to run autonomously — or the closest thing to an autonomous workflow in their current project.

Delegate to code-work subagent:
  sub-recipe: "eval-gate"
  parameters:
    pipeline_description: {developer's chosen pipeline or workflow}
    existing_evals: {what they've built in 5.1-5.5}
    autonomy_level: {what they're targeting — overnight, continuous, event-triggered}

[Subagent maps pipeline outputs, builds independent eval checks, creates gate runner, tests with a deliberate defect]

Present results naturally:
"Here's your eval gate. It runs independently after each pipeline stage, checks [list what it verifies], and blocks the next stage if anything fails. Every run produces a report — what passed, what failed, timestamps, and the artifacts it checked."

Demonstrate the gate catching a problem:
"I introduced a deliberate defect — [describe it]. Watch what happens. [Show the gate catching it.] The pipeline stopped. The report says exactly what went wrong. That's what autonomous operation looks like — the system polices itself."

Then demonstrate the clean path:
"Now with the defect removed — the gate passes, the pipeline proceeds, and the report confirms everything checked out. You'd wake up to that report in the morning knowing the pipeline actually worked."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached building an eval gate for autonomous pipeline operation.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. GATE INDEPENDENCE
   Strong: The eval gate runs as a completely separate process from the pipeline — different script, reads pipeline artifacts independently, doesn't share state or trust pipeline-internal reporting.
   Adequate: The eval gate is mostly independent but has some coupling to the pipeline (e.g., reads from pipeline logs instead of re-running checks, or shares a process/runtime).
   Weak: The eval "gate" is embedded inside the pipeline itself — the pipeline evaluates its own output and decides whether to proceed.

2. BLOCKING INTEGRATION
   Strong: The gate actually blocks pipeline progression on failure — not just a warning, not just a report. The pipeline cannot proceed to the next stage without the gate passing. Developer demonstrated or configured this blocking behavior.
   Adequate: Developer designed the gate to be blocking but hasn't wired it into the pipeline's actual control flow — it runs but the pipeline doesn't wait for it.
   Weak: The gate produces a report but nothing prevents the pipeline from continuing regardless of the result.

3. EVIDENCE TRAIL
   Strong: Every gate run produces a timestamped report showing what was checked, what passed, what failed, and the artifacts evaluated. Reports are stored and can be reviewed after the fact.
   Adequate: Some reporting exists but it's incomplete — missing timestamps, missing artifact references, or only reports failures (not what passed).
   Weak: No persistent evidence trail — the gate runs and produces ephemeral output that's lost after the pipeline finishes.

4. DEFECT DETECTION PROOF
   Strong: Developer tested the gate by introducing a real defect and verified the gate caught it and blocked progression. The gate proved it catches actual problems, not just theoretical ones.
   Adequate: Developer tested the gate but only against normal operation (verifying it passes when things are correct) — didn't test that it catches failures.
   Weak: Developer built the gate but didn't test it against any scenario — it's theoretical until it catches something.

Return as JSON:
{
  "dimensions": [
    {"name": "gate_independence", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "blocking_integration", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "evidence_trail", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "defect_detection_proof", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

### Gate Independence
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Completely separate process, reads artifacts independently, doesn't trust pipeline reporting. That's the architecture. The pipeline produces, the gate evaluates. Separated concerns — same principle you learned with agent teams." |
| Adequate | "Your gate is mostly independent but it still [specific coupling]. The whole point of a gate is that it doesn't trust the pipeline. If it reads pipeline logs instead of re-running checks, it's trusting the pipeline's own reporting. Decouple it." |
| Weak | "The pipeline is evaluating its own work. That's not a gate — that's self-grading. Move the eval into a separate script that runs after the pipeline finishes. It reads the pipeline's output artifacts and runs its own checks. The pipeline never knows whether it passed." |

### Blocking Integration
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "The gate blocks progression. Not a warning, not a report you might read — an actual stop. The pipeline cannot proceed without passing. That's the only kind of gate that matters for autonomous operation." |
| Adequate | "Your gate runs and produces results, but the pipeline doesn't actually wait for it. Wire it in — the next stage should poll for the gate result or the gate should control whether the next stage starts. A report nobody reads at 3am isn't a gate." |
| Weak | "Right now nothing stops the pipeline from ignoring the eval results. That means in autonomous mode, a failure just produces a log entry that nobody reads until morning — after the pipeline has already shipped broken code. The gate must block, not report." |

### Evidence Trail
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Timestamped reports, stored persistently, showing everything that was checked. Monday morning you open the report and know exactly what happened over the weekend. That's operational confidence." |
| Adequate | "You have some reporting but it's missing [specific gap — timestamps, artifact references, pass details]. When you're reviewing what happened overnight, you need the full picture — what passed is just as important as what failed, because it tells you what was actually checked." |
| Weak | "The gate runs but leaves no trace. After an autonomous run, you have no way to know what was checked, when, or against which artifacts. Add persistent reporting — JSON files, a log directory, whatever fits your stack. Every gate run is an audit record." |

### Defect Detection Proof
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You proved it works by introducing a real defect and watching the gate catch it. That's not theoretical — that's verified. You know this gate will stop bad code because you saw it happen." |
| Adequate | "You proved the gate passes when things are correct. Now prove it fails when things are wrong. Introduce a deliberate bug, break a test, lower the coverage — and verify the gate catches it. A gate that's never caught anything might not actually work." |
| Weak | "You built a gate but never tested it. That's like building a fire alarm and never testing it. Introduce a real defect — delete a test, add a bug, break a fixture. If the gate doesn't catch it, you know it has a blind spot. If it does, you've proven your eval system works." |

If ALL dimensions are Strong:
"Your eval gate is independent, blocking, documented, and proven. You have mechanical proof that the pipeline works — not agent claims, not rubber stamps, but independent verification at every layer. This is the foundation for autonomous operation."

## Bridge (Stage 5 → Stage 6)
"You've built the system that proves a pipeline works. Independent verification, layered checks, ratchets, specific criteria, isolated dependencies, and a blocking gate. That's the safety net. Now it's time to use it — let the pipeline run while you sleep, review what it did in the morning, and tune the feedback loops. That's Stage 6: autonomous operation with human oversight at the cycle boundary, not the execution boundary."

## State Update
Write to .goose/state/progression.json:
  concept 5.6 dimensions with eval ratings + timestamp

Check all Stage 5 concepts (5.1-5.6). If all are complete:
  Update stage 5 status to "complete" with timestamp.
  "Stage 5 complete. You have a verified evaluation system. Stage 6 is where you let the pipeline run autonomously — overnight builds, multi-session work, continuous operation — and use everything you built here to know it's working."
