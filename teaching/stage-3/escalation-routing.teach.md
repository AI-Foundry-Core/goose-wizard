# Recipe 3.3: Escalation Routing - "Know when to stop"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the codebase," interpret those against
> `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `escalation-routing` sub-recipe.
> Pipeline ownership and external state references should reference the
> developer's project, not Goose Wizard.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context (stack, test commands, ownership model, external systems, temp file patterns).
Read ~/.goose-wizard/progression.json and check concept 3.3 (module 11: escalation-routing).
Also check concept 3.1 (module 9: three-agent-pipeline) as a prerequisite.

If concept 3.1 is not complete:
  "Before we add escalation, the pipeline needs a team shape and handoff contracts. Let's run the three-agent pipeline first, then put safety rails around it."
  Route back to `three-agent-pipeline`.

If concept 3.3 is already complete with adequate or strong ratings:
  "You've already shown safety rails for a multi-agent pipeline. Want to skip to parallel reviewers, or revisit escalation against a fresh failure scenario?"
  If skip: jump to Bridge.
  If revisit: continue normally and only update ratings that improve.

## Framing
"Your pipeline runs cleanly when each agent does its job. Now the important case: what happens when it doesn't?"

Ask the developer for the pipeline and failure path:
"Use the pipeline you just built, or describe another you care about — or let me reconstruct the one from your last three-agent run. What failure do you most want to route safely — malformed output, repeated test failure, review rejection, timeout, shared-state conflict, or unclear requirements? Pick one, or I'll pick the most likely failure for your pipeline."

If the developer has no pipeline ready:
  "No problem. I'll use the pipeline from the previous three-agent run as the base and pick the most likely failure route."
  Delegate to code-work subagent (prepend the TARGET PROLOGUE):
    "Read `<TARGET>/.goose/team_context.md` and any available output from
    the previous three-agent-pipeline run in the current conversation or
    progression notes. Reconstruct a bounded pipeline with agents, handoff
    contracts, and likely failure points. If no prior run is available,
    propose a small default Spec Agent -> Build Agent -> Review Agent
    pipeline for a real task under `<TARGET>/`. Return the pipeline
    description and one realistic failure scenario."

Present the candidate naturally:
"Let's route this: [failure scenario]. It matters because [specific loop or state risk]."

## The Task
Before running the recipe, ask the developer to make the safety policy explicit:
"Before I run the escalation pass, give me three things: the failure classes you want to distinguish, the retry threshold for each one, and who receives the escalation packet when the breaker opens."

Capture what the developer provides:
- Did they identify distinct failure classes instead of one generic "it failed" bucket?
- Did they define concrete thresholds with numbers?
- Did they define a breaker state or stop condition?
- Did they route each failure class to a plausible owner?
- Did they include packet fields the next owner can act on?
- If the failure can dirty files, data rows, temp state, queues, or external systems, did they say what must be cleaned before rerun?

If the developer treats all failures the same:
"Split the failure classes. A malformed contract goes back to the producer once; repeated test failure goes to an implementer or human; shared-state conflict goes to a coordinator before anyone retries."

If the developer uses vague thresholds:
"Make the threshold a number. 'Retry a few times' is not a safety rail. Try: malformed output gets 2 retries, review rejection gets 2 build-review loops, repeated no-progress opens after 3 identical failures."

If the developer proposes escalation without evidence:
"The next owner needs a packet, not a panic message. Include failure type, attempts, command or validation output, changed files, dirty state, and the recommended next action."

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "escalation-routing"
  parameters:
    pipeline_description: {developer's pipeline or reconstructed pipeline}
    failure_scenario: {developer's failure scenario or selected likely failure}
    escalation_target: {developer's preferred escalation target, or default human plus specialist-agent}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent maps the pipeline, defines failure classes, breaker rules, escalation routes, cleanup actions, safety_config, and simulates one failure path.]

Present results naturally:
"Here is the route: [failure] gets [N] retries, then the breaker moves to [OPEN/HALF_OPEN/CLOSED behavior] and sends [owner] a packet with [key fields]. The important stop point is [threshold], because after that the pipeline is no longer learning from retries."

If cleanup is needed:
"There is also state to repair before rerun: [artifact/state]. Do that before the half-open retry, otherwise the next run is debugging polluted state."

If the route is weak or overbroad:
"This route is still too broad at [specific point]. Tighten that before relying on it unattended: [concrete fix]."

## Checkpoint After 3.3
Pause after the escalation routing run.

"Checkpoint: the pipeline now has a stop rule. I am looking for three things: different failure classes, numeric thresholds, and an escalation packet with enough evidence for the next owner to act."

Ask three concrete questions:
"Which failure opens the breaker first?"
"What does the next owner receive that lets them act without rereading the whole conversation?"
"Are there failures your current classes don't cover?"

If the developer's failure classes are incomplete (e.g., missing timeout, shared-state conflict, or repeated no-progress), do not proceed to the bridge. Coach: "Your classes cover the common cases. What about timeout — the agent hangs and never returns? Or repeated no-progress — valid output three times in a row but the same wrong output? Those are different from test failure because more retries won't help." The developer must add the missing classes to the policy before the checkpoint is satisfied.

If the developer cannot answer:
- Failure classification gap: "Name the failure class first. Malformed output, test failure, timeout, and shared-state conflict need different routes."
- Threshold gap: "A breaker needs a number. After 2 malformed outputs or 3 repeated no-progress failures, stop and escalate."
- Evidence gap: "Escalation needs a packet: what failed, what was tried, the exact evidence, dirty state, and the recommended owner."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer added escalation routing and circuit breakers to a multi-agent pipeline.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript (quote or paraphrase what the developer said/did)
3. If not Strong, write 1-2 sentences of coaching the facilitator should say - conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. FAILURE CLASSIFICATION
   Strong: Developer identified distinct failure classes and routed them differently, such as malformed_output, execution_failure, review_rejection, timeout, state_conflict, repeated_no_progress, or unclear_requirements.
   Adequate: Developer identified more than one failure type, but the categories overlap, omit an important likely failure, or route several different failures through the same generic path.
   Weak: Developer treated failure as one generic bucket like "if it fails, retry" or "send it to a human" with no classification.

2. THRESHOLD SPECIFICITY
   Strong: Developer defined concrete numeric thresholds and stop conditions, such as 2 malformed-output retries, 2 build-review loops, 3 repeated no-progress failures, or explicit CLOSED/OPEN/HALF_OPEN breaker behavior.
   Adequate: Developer included some threshold or retry limit, but at least one important path uses vague language like "a few times" or does not say exactly when the breaker opens.
   Weak: Developer left the pipeline free to retry indefinitely or used only vague instructions like "try again until it works."

3. ESCALATION EVIDENCE
   Strong: Developer defined an escalation packet with enough evidence for the next owner to act, including failure type, attempts, validation error or command output, changed files or artifacts, dirty state if relevant, recommended owner, and next action.
   Adequate: Developer named an escalation owner and included some evidence, but the packet is missing details the next owner would need, such as exact command output, validator error, changed files, or recommended action.
   Weak: Developer escalated by saying to notify a human or specialist without defining the evidence packet.

4. CLEANUP AWARENESS
   Condition: Only rate this if the discussed failure scenario could leave dirty files, temp artifacts, data rows, queues, staging folders, or other polluted external state.
   If condition not met: return {"name": "cleanup_awareness", "rating": null, "evidence": "Not triggered - failure scenario did not create dirty state", "coaching": null}
   Strong: Developer identified the polluted state and defined a cleanup or reset action that must happen before rerun or HALF_OPEN retry.
   Adequate: Developer mentioned cleanup generally, but did not specify the exact artifact, owner, or timing before rerun.
   Weak: Developer ignored polluted state or allowed the pipeline to keep retrying against dirty state.

Return as JSON:
{
  "dimensions": [
    {"name": "failure_classification", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "threshold_specificity", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "escalation_evidence", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "cleanup_awareness", "rating": "Strong|Adequate|Weak|null", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. Coach naturally; do not list ratings.

**Failure classification:**
- Strong: "Good failure split. Malformed output, test failure, timeout, and state conflict are different problems, so they should not all take the same route."
- Adequate: "You have more than one bucket, which is the right direction. Tighten it by separating contract failures from execution failures; one goes back to the producer, the other goes to someone who can debug the run."
- Weak: "Right now every failure becomes 'try again' or 'ask a human.' Compare that to: malformed contract gets one repair retry, repeated test failure goes to the implementer, and shared-state conflict stops at the coordinator. Different failures need different routes."

**Threshold specificity:**
- Strong: "That is a real breaker: the loop has numbers and an open state. The pipeline knows when another retry is just burning cycles."
- Adequate: "You have a retry idea, but make every path numeric. 'A couple tries' should become '2 retries, then OPEN with this packet.'"
- Weak: "Without a number, the loop can run forever. Use a concrete stop rule: after 2 malformed outputs or 3 repeated no-progress failures, stop and escalate."

**Escalation evidence:**
- Strong: "Good packet. The next owner gets the failure type, attempts, evidence, changed files, and next action, so they can act without reconstructing the whole run."
- Adequate: "The owner is clear, but the packet is still thin. Add the exact validator error or command output, changed files, and what you want that owner to decide."
- Weak: "Escalation is not just 'tell a human.' The handoff should include what failed, what was tried, the exact evidence, dirty state if any, and the recommended next action."

**Cleanup awareness:**
- Strong: "Good cleanup gate. You caught that a rerun against polluted state would produce misleading results, so the reset happens before HALF_OPEN."
- Adequate: "You noticed cleanup, but make it exact. Name the artifact, who resets it, and whether cleanup happens before retry or before escalation."
- Weak: "Do not debug against dirty state. If a failed attempt wrote rows, temp files, or staging artifacts, reset that state before rerunning the same sample."

If all required dimensions are Strong:
"That is the version you can leave running: distinct failure routes, numeric breakers, and escalation packets that carry enough evidence to be useful."

## Enterprise Grounding
After coaching and before the bridge, ask one enterprise-context question:
"On your team, who signs off on a new escalation route before it goes live?"

If the developer engages, follow up with one more: "When the pipeline opens a breaker and sends an escalation packet, where is that decision recorded — just the archived artifacts, or somewhere a compliance audit could find it?"

Do not ask more than two questions. The goal is to connect the exercise to enterprise reality (design review, audit trails), not to design the full integration.

## GooseForge Connection
After coaching, connect the exercise to GooseForge:

"You just added safety rails to a pipeline — failure classes, circuit breakers, escalation packets. Pipeline Forge builds this in automatically. Look at Phase 7 in recipes/graduated/pipeline-forge.yaml: every coordinator it generates includes circuit breakers (2 consecutive failures halt) and escalation routing (each failure class maps to an owner with an evidence packet)."

"That means every pipeline you design with Pipeline Forge gets the safety layer you just learned, without you having to remember every threshold and packet field."

Ask: "Want to try Pipeline Forge to design a new pipeline with built-in safety rails? Or are you ready to move on."

If yes: direct them to run `goose run --recipe recipes/graduated/pipeline-forge.yaml --interactive`. When it asks about failure handling, they'll recognize the same patterns.
If no: proceed to Recipe Reveal.

## Recipe Reveal
After the GooseForge connection, show the developer the recipe behind this session.

"Eleventh recipe. This one is different — it's not a coordinator and it doesn't build
anything. It's an *analyzer* that adds safety rails to a pipeline you already have."

Read the Escalation Routing recipe (recipes/agents/escalation-routing.yaml) and show the developer:
- The **enumerated failure classes** — "Look at Process step 2: `malformed_output`,
  `execution_failure`, `review_rejection`, `timeout`, `state_conflict`, `repeated_no_progress`.
  Those are the exact failure buckets you were coached to separate. They're not
  suggestions in the instructions — they're the canonical list the agent uses every time
  it analyzes a pipeline."
- The **explicit CLOSED / OPEN / HALF_OPEN breaker states** — "Process step 3 names the
  three circuit breaker states and the numeric thresholds: '2 consecutive failures -> halt',
  '2 rejected loops -> halt', '3 same failures -> halt'. Those aren't the developer's
  numbers — they're the recipe's defaults. The 'make the threshold a number' coaching
  you got is baked in as a default policy."
- The **hard constraints against 'try harder'** — "Look at Constraints: 'NEVER define a
  safety rail as \"try harder\" — it must define when to stop.' 'NEVER hide escalation —
  include enough evidence for the next owner to act.' Those are the exact failure modes
  you were coached on — encoded as constraints the agent refuses to violate."
- The **`cleanup_actions` return field** — "The return block includes `cleanup_actions:
  State or artifacts to repair before rerun.` Most recipes return what was done. This one
  returns what needs *undoing* before the next attempt — because a retry against dirty
  state is worse than no retry at all."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open recipes/agents/escalation-routing.yaml`
"This recipe is a pure analyzer — note how the whole output is structured data, no
source edits. That's what makes it safe to bolt onto any pipeline."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/escalation-routing.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

## Bridge
"Safety rails answer what the team does when it gets stuck. The next big jump is what you feed that team: specs precise enough that agents can build without guessing."

"If you continue through the rest of Stage 3 first, parallel reviewers are the coordination exercise: multiple agents checking different layers at the same time without corrupting shared state. Ready to keep going?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## Wait-Time Insights

Ordered list for use during subagent operations (see teacher-instructions.md Section 13):

1. `[specialization]` "Different failures need different routes — a malformed contract and a timeout are not the same problem, even if both stop the pipeline."
2. `[verify]` "The escalation packet is only useful if the next owner can act on it without reconstructing the run. Think about what you'd need at 2 AM on a PagerDuty alert."
3. `[feedback-loops]` "A breaker that opens but never reports why it opened is a dead end. The loop only closes when the next owner knows what to try differently."
4. `[enterprise]` "In a team environment, the person who designed the escalation route is rarely the person who gets woken up by it. Design for the reader, not the writer."
5. `[risk-ladder]` "Cleanup before retry is the part most people skip. Retrying against dirty state produces misleading results — the second run is debugging the first run's mess."
6. `[specificity]` "Vague thresholds feel safe because they give you room to interpret. That is exactly why they fail — every developer interprets 'a few times' differently."

## State Update
Write to ~/.goose-wizard/progression.json:
  concept 3.3 with eval ratings and timestamp.
  Map failure_classification, threshold_specificity, and escalation_evidence to concept 3.3.
  Record cleanup_awareness when triggered. If not triggered, store rating null with the note from eval and do not block completion.
  Update concept 3.3 status to "complete" when failure_classification, threshold_specificity, and escalation_evidence are Adequate or Strong, and cleanup_awareness is either null or Adequate/Strong when triggered.
  Never overwrite a Strong rating with a lower one.
  Do not mark Stage 3 complete from this module unless concepts 3.1 and 3.2 are already complete.
