# Recipe 3.3: Escalation Routing - "Know when to stop"

## Setup
Read .goose/team_context.md for project context (stack, test commands, ownership model, external systems, temp file patterns).
Read .goose/state/progression.json and check concepts 3.1, 3.2, and 3.3.

If concepts 3.1 and 3.2 are not complete:
  "Before we add escalation, the pipeline needs a team shape and handoff contracts. Let's run the three-agent pipeline first, then put safety rails around it."
  Route back to `three-agent-pipeline`.

If concept 3.3 is already complete with adequate or strong ratings:
  "You've already shown safety rails for a multi-agent pipeline. Want to skip to parallel reviewers, or revisit escalation against a fresh failure scenario?"
  If skip: jump to Bridge.
  If revisit: continue normally and only update ratings that improve.

## Framing
"Your pipeline runs cleanly when each agent does its job. Now let's handle the more important case: what happens when it doesn't?"

"I want one concrete failure path: malformed output, repeated test failure, review rejection, timeout, shared-state conflict, or unclear requirements. Then we'll decide when the loop stops, who gets it next, and what evidence they receive."

Ask the developer for the pipeline and failure path:
"Use the pipeline you just built, or describe another multi-agent pipeline you care about. What is the failure you most want to route safely?"

If the developer has no pipeline ready:
  "No problem. I'll use the pipeline from the previous three-agent run as the base and pick the most likely failure route."
  Delegate to code-work subagent:
    "Read .goose/team_context.md and any available output from the previous three-agent-pipeline run in the current conversation or progression notes. Reconstruct a bounded pipeline with agents, handoff contracts, and likely failure points. If no prior run is available, propose a small default Spec Agent -> Build Agent -> Review Agent pipeline for a real task in this repo. Return the pipeline description and one realistic failure scenario."

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

Delegate to code-work subagent:
  sub-recipe: "escalation-routing"
  parameters:
    pipeline_description: {developer's pipeline or reconstructed pipeline}
    failure_scenario: {developer's failure scenario or selected likely failure}
    escalation_target: {developer's preferred escalation target, or default human plus specialist-agent}

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

Ask two concrete questions:
"Which failure opens the breaker first?"
"What does the next owner receive that lets them act without rereading the whole conversation?"

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

## Bridge
"Safety rails answer what the team does when it gets stuck. The next big jump is what you feed that team: specs precise enough that agents can build without guessing."

"If you continue through the rest of Stage 3 first, parallel reviewers are the coordination exercise: multiple agents checking different layers at the same time without corrupting shared state."

## State Update
Write to .goose/state/progression.json:
  concept 3.3 with eval ratings and timestamp.
  Map failure_classification, threshold_specificity, and escalation_evidence to concept 3.3.
  Record cleanup_awareness when triggered. If not triggered, store rating null with the note from eval and do not block completion.
  Update concept 3.3 status to "complete" when failure_classification, threshold_specificity, and escalation_evidence are Adequate or Strong, and cleanup_awareness is either null or Adequate/Strong when triggered.
  Never overwrite a Strong rating with a lower one.
  Do not mark Stage 3 complete from this module unless concepts 3.4 and 3.5 are already complete.
