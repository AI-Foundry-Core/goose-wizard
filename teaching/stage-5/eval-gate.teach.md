# Recipe 5.4: Eval Gate — "Evals must run before autonomy"

> **Path resolution note.** All paths, pipeline reads, gate writes, and
> defect simulations in this script act on the TARGET codebase (the
> developer's project). The parent recipe injected a TARGET PROLOGUE —
> whenever this script says `.goose/team_context.md`, "the pipeline,"
> "your repo," or "the gate," interpret those against `<TARGET>/`.
> Preflight gate scripts, wiring, and evidence logs all live under
> `<TARGET>/` (typically `<TARGET>/scripts/preflight/`), never in
> goose-wizard. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `eval-gate` sub-recipe.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json — check if concept 5.4 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"Would you let your pipeline run overnight unattended right now? Only if every check you've built runs as a gate that blocks the pipeline on failure — not a report you read in the morning. Let's wire everything together — pick a pipeline you want to run autonomously, or want me to look at your repo and suggest the closest candidate?"

Let the developer think about what's stopping them.

## The Task
Developer identifies a pipeline they want to run autonomously — or the closest thing to an autonomous workflow in their current project.

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "eval-gate"
  parameters:
    pipeline_description: {developer's chosen pipeline or workflow — absolute entrypoint path under <TARGET>/}
    existing_evals: {what they've built in 5.1-5.5 — paths under <TARGET>/}
    autonomy_level: {what they're targeting — overnight, continuous, event-triggered}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent maps pipeline outputs under <TARGET>/, builds independent eval checks, creates gate runner under <TARGET>/, tests with a deliberate defect inside <TARGET>/]

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

## Recipe Reveal
After coaching, show the developer the recipe behind this session — this is the final
recipe of Stage 5 and the one that ties everything together.

"Last recipe of Stage 5. This one is the capstone — it's how the five pieces you've
built become something the pipeline literally can't bypass."

Read the Eval Gate agent recipe (recipes/agents/eval-gate.yaml) and show the developer:
- The **'fail-closed' design** — "Step 3 of the process: 'Make the gate fail-closed: any
  eval failure blocks execution.' The default when something goes wrong has to be STOP,
  not CONTINUE. A gate that fails open is worse than no gate — it teaches the team to
  trust a signal that isn't doing anything."
- The **'NEVER let the pipeline grade its own output' constraint** — "You'll recognize this
  from Stage 2 — the builder can't be the reviewer. Now it's applied to the whole pipeline.
  The gate is a separate script that reads pipeline artifacts and runs its own checks. The
  pipeline never finds out whether it passed."
- The **`bypass_risk` return field** — "Most recipes return only what was built. This one
  asks: 'Any remaining ways the gate could be skipped?' That's the paranoid question —
  because a gate with a bypass is a theater prop. Forcing the agent to enumerate bypasses
  is how you catch the obvious ones (env variable flags, skip-ci comments, direct script
  invocation) before they become 2am footguns."
- The **`evidence_location` return field** — "The gate doesn't just decide — it writes a
  record of what it checked, what passed, what failed, against which artifacts, and when.
  That record is the audit trail you read Monday morning. 'The pipeline ran' is a claim.
  The evidence log is proof."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/eval-gate.yaml>`
"This recipe is the one you'll actually run before switching on autonomy in Stage 6 — read
the constraints carefully. Each one is a failure mode someone found the hard way."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/eval-gate.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge (Stage 5 → Stage 6)
"You've built the system that proves a pipeline works. Independent verification, layered checks, ratchets, specific criteria, isolated dependencies, and a blocking gate. That's the safety net. Now it's time to use it — let the pipeline run while you sleep, review what it did in the morning, and tune the feedback loops. That's Stage 6: autonomous operation with human oversight at the cycle boundary, not the execution boundary. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## State Update
Write to ~/.rilgoose/progression.json:
  concept 5.4 dimensions with eval ratings + timestamp

Check all Stage 5 concepts (5.1-5.6). If all are complete:
  Update stage 5 status to "complete" with timestamp.
  "Stage 5 complete. You have a verified evaluation system. Stage 6 is where you let the pipeline run autonomously — overnight builds, multi-session work, continuous operation — and use everything you built here to know it's working."
