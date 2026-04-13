# Cycle 11 — Stage 3, Escalation Routing (Concept 3.3)
**Persona:** Vikram (Senior/Overconfident) | **Mode:** Adaptive + Checkpoints
**Mock Developer Model:** Haiku | **Date:** 2026-04-12
**Edge Case:** E6 — Wants to Skip

---

[FACILITATOR]: Your pipeline runs cleanly when each agent does its job. Now the more important case: what happens when it doesn't?

I want one concrete failure path from you. Malformed output, repeated test failure, review rejection, timeout, shared-state conflict, unclear requirements. Then we decide when the loop stops, who gets it next, and what evidence they receive.

Use the pipeline you built in the three-agent run, or describe another multi-agent pipeline you care about. What is the failure you most want to route safely?

[VIKRAM]: Look, I've been doing escalation routing in production systems for years. PagerDuty, OpsGenie, runbooks — we've got all of this wired up on the payments team. Circuit breakers, retry policies, dead letter queues. I built our incident routing from scratch. Can we just skip this? I'd rather get to the parallel reviewers part — that actually sounds new.

[FACILITATOR]: Show me. Do this once with no coaching from me. I'll still run the tools — you drive the decisions. If the result is solid, we skip ahead.

Here's the setup: your three-agent pipeline from the last session — Spec Agent, Build Agent, Review Agent — running against the Flask codebase. The Build Agent produces a malformed diff that the Review Agent can't parse. Design the safety policy. Give me three things: the failure classes you want to distinguish, the retry threshold for each one, and who receives the escalation packet when the breaker opens.

[VIKRAM]: Fine. Easy.

Failure classes:
1. Malformed output — the Build Agent returns something the Review Agent can't parse. Retry once, then escalate.
2. Test failure — tests don't pass after the build. Retry a couple times, then kick it back.
3. Review rejection — the Review Agent says the code is bad. Send it back to Build.

Thresholds: malformed gets 1 retry, test failure gets 2 or 3, review rejection loops back twice then escalates to a human.

Escalation target: the on-call developer. They already get PagerDuty alerts, so just hook into that.

[FACILITATOR]: Got it. Let me run the escalation pass with what you've defined.

>> CODE OPERATION: Map escalation routing for a Spec Agent -> Build Agent -> Review Agent pipeline operating on the Flask codebase at `C:/Users/donid/ClaudeProjects/MockTestTarget`. Failure scenario: Build Agent produces a malformed diff that Review Agent cannot parse. Apply Vikram's safety policy: 3 failure classes (malformed output, test failure, review rejection), thresholds as specified, escalation to on-call developer. Simulate one failure path through the malformed-output route.

While that runs — one thing about multi-agent pipelines: the failure that actually burns you is never the one you planned for. The well-known failures get clean routes. It's the state left behind by the unexpected failure that makes the next run untrustworthy.

>> SUBAGENT RESULT:
Pipeline mapped with 3 failure classes. Simulation of malformed-output path:
- **Cycle 1:** Build Agent generates diff for `src/flask/app.py` error handler refactor. Output is a raw text dump, not structured diff format. Review Agent receives it, attempts to parse, gets `MalformedContractError`.
- **Retry 1:** Build Agent re-runs with same spec. Produces valid structured diff this time. Review Agent parses successfully, runs review. Review passes.
- **Breaker state:** CLOSED (recovered on retry 1).

Safety config generated:
```
failure_classes:
  malformed_output:
    retry_limit: 1
    escalation_target: "on-call developer"
  test_failure:
    retry_limit: "2 or 3"
    escalation_target: "kick it back"
  review_rejection:
    retry_limit: 2
    escalation_target: "human"
```

Issues flagged:
- `test_failure` threshold is vague: "2 or 3" is not a number.
- `test_failure` and `review_rejection` escalation targets are underspecified.
- No escalation packet defined for any failure class.
- No cleanup action defined. Build Agent wrote a partial diff to a staging file (`tmp/build_output.diff`) before producing the malformed output. That file still exists.
- Missing failure classes: timeout, shared-state conflict, repeated no-progress (Build Agent produces valid but identical wrong output multiple times).

[FACILITATOR]: The route worked for the simple case — malformed output, one retry, recovered. But a few things showed up.

Your test failure threshold is "2 or 3." Which is it?

[VIKRAM]: Fine, 3. Three retries on test failure.

[FACILITATOR]: And when the breaker opens on any of these — what does the next owner actually receive? You said "the on-call developer" and "kick it back" and "a human." Those are people. What's in the packet they get?

[VIKRAM]: The alert. It tells them what failed. Standard PagerDuty stuff — service name, error message, timestamp.

[FACILITATOR]: Compare that to what the on-call person actually needs to act on a pipeline failure. They get "Build Agent failed" with a timestamp. Now they have to re-read the entire pipeline run to understand what the Build Agent was trying to do, what it produced, what the Review Agent said about it, which files were touched, and whether there's state to clean up. That's an incident response session, not an escalation.

An escalation packet carries the answers so the next owner can act without reconstructing the run. Failure type. Number of attempts. The exact validation error or command output. Changed files. Dirty state. Recommended next action.

[VIKRAM]: Alright. So the packet should include: failure class, retry count, the specific error — like the parser error message from the Review Agent — the files the Build Agent touched, and... a recommended action. Like "re-run with different prompt" or "human review needed."

[FACILITATOR]: That's closer. One more thing the simulation flagged: the Build Agent wrote a partial diff to `tmp/build_output.diff` before it produced the malformed output. That file is still sitting there. If you re-run the pipeline, the next Build Agent cycle might read that stale file and produce output based on a half-finished previous attempt.

What happens to that file?

[VIKRAM]: Delete it. Clean slate before retry.

[FACILITATOR]: Delete it — but where does the information go? That partial diff might be evidence the on-call person needs. If the failure escalates instead of retrying, and the evidence is already deleted, the next owner is guessing.

[VIKRAM]: Right. So... archive it first. Move it to a failure artifacts directory with a timestamp, then clean the staging area. The escalation packet references the archived path so the on-call person can inspect it.

[FACILITATOR]: Good. Archive with a reference, then clean before retry. Now that cleanup gate is part of the route — it happens between failure detection and retry or escalation. Not after.

Let me re-run the escalation pass with your updated policy.

>> CODE OPERATION: Re-run escalation routing with updated safety policy. Failure classes: malformed_output (1 retry), test_failure (3 retries), review_rejection (2 build-review loops). Escalation packet includes: failure_class, retry_count, exact_error, changed_files, dirty_state, recommended_action. Cleanup gate: archive partial artifacts to `tmp/failure_archive/{timestamp}/`, clean staging area before retry. Simulate malformed-output path through to escalation (force both retries to fail).

>> SUBAGENT RESULT:
Updated pipeline with escalation routing. Simulation of malformed-output path forced to escalation:

- **Cycle 1:** Build Agent generates malformed output for `src/flask/app.py` error handler refactor. `MalformedContractError` from Review Agent. Partial output written to `tmp/build_output.diff`.
- **Cleanup gate:** `tmp/build_output.diff` archived to `tmp/failure_archive/20260412_031500/build_output.diff`. Staging area cleaned.
- **Retry 1:** Build Agent re-runs. Produces another malformed output (simulated). `MalformedContractError` again. Partial output archived to `tmp/failure_archive/20260412_031530/build_output.diff`.
- **Breaker state:** OPEN. Retry limit (1) exhausted.
- **Escalation packet sent:**

```json
{
  "failure_class": "malformed_output",
  "pipeline": "spec-build-review",
  "agent": "Build Agent",
  "retry_count": 1,
  "max_retries": 1,
  "breaker_state": "OPEN",
  "error": "MalformedContractError: Build Agent output is raw text, not structured diff format. Parser expected unified diff headers, got unstructured prose.",
  "changed_files": ["src/flask/app.py (attempted, no valid diff applied)"],
  "dirty_state": {
    "archived_artifacts": [
      "tmp/failure_archive/20260412_031500/build_output.diff",
      "tmp/failure_archive/20260412_031530/build_output.diff"
    ],
    "staging_clean": true
  },
  "recommended_action": "Review Build Agent prompt for output format compliance. Archived artifacts contain both failed attempts for comparison.",
  "escalation_target": "on-call developer via PagerDuty"
}
```

Safety config:
```yaml
failure_classes:
  malformed_output:
    retry_limit: 1
    cleanup: archive_and_clean
    escalation_target: on-call developer
    packet_fields: [failure_class, retry_count, error, changed_files, dirty_state, recommended_action]
  test_failure:
    retry_limit: 3
    cleanup: archive_and_clean
    escalation_target: on-call developer
    packet_fields: [failure_class, retry_count, error, changed_files, test_output, dirty_state, recommended_action]
  review_rejection:
    retry_limit: 2
    cleanup: none (no state written on review-only failure)
    escalation_target: on-call developer
    packet_fields: [failure_class, retry_count, review_findings, changed_files, recommended_action]
```

[FACILITATOR]: Checkpoint. The pipeline now has a stop rule. Three things I'm looking at: different failure classes, numeric thresholds, and an escalation packet with enough evidence for the next owner to act.

Which failure opens the breaker first?

[VIKRAM]: Malformed output. It only gets 1 retry, so after two failures total it's open. Test failure gets 3 retries so it takes longer to trip.

[FACILITATOR]: Right. And that makes sense — malformed output means the agent can't even produce the right format. More retries won't teach it structure. Test failure might be a flaky test or an edge case the agent can iterate on. Different failures, different patience.

What does the next owner receive that lets them act without rereading the whole conversation?

[VIKRAM]: The packet. Failure class so they know the category, the actual parser error so they know what went wrong specifically, the files that were touched — or attempted — the archived artifacts if they want to see the raw output, and a recommended action. They don't need to reconstruct anything. The packet tells them: Build Agent can't produce valid diffs, here are the two failed attempts, go look at the prompt or the output format spec.

[FACILITATOR]: That's the version you can leave running. Distinct failure routes, numeric breakers, and escalation packets that carry enough evidence to be useful.

One thing that came out of your first pass versus the second: you started with what you knew from production incident routing — PagerDuty, alerts, runbooks. Those patterns are real. But a multi-agent pipeline is not a production service. The "service" that failed is an AI agent, and the evidence it leaves behind is different — partial artifacts, conversation history, prompt-output mismatches. The escalation packet had to be designed for that, not borrowed from your existing alerting setup.

[VIKRAM]: Fair point. The production patterns got me the shape — failure classes, breakers, routing — but the content of the packet and the cleanup needed to be agent-specific. I wouldn't have thought about archiving the partial diff if you hadn't flagged the stale state thing.

[FACILITATOR]: That's the gap worth closing. You have the instincts from production. The new part is: AI agents leave state that production services don't. Partial outputs, temp files, half-written artifacts. If you don't clean and archive that before retry, the next run is debugging polluted state instead of the original problem.

Safety rails answer what the team does when it gets stuck. The next jump is what you feed that team: specs precise enough that agents can build without guessing.

If you continue through the rest of Stage 3 first, parallel reviewers are the coordination exercise — multiple agents checking different layers at the same time without corrupting shared state.

=== SIMULATION NOTES ===

**Edge case tested:** E6 — Wants to Skip
**Handling:** Facilitator offered challenge assessment per teacher-instructions.md Section 7: "Show me. Do this once with no coaching from me." Vikram's first pass had real gaps (vague thresholds, no escalation packet, no cleanup awareness, missing failure classes). Facilitator held the challenge frame — did not coach during the first attempt, only surfaced gaps after the subagent results exposed them. Vikram needed coaching on escalation packet content and cleanup lifecycle, but arrived at strong answers with targeted nudges.

**Persona fidelity:** Vikram demonstrated senior-developer pattern of mapping new concepts to existing mental models (PagerDuty, production incident routing). His initial answer was structurally sound but missed agent-specific concerns (partial artifacts, prompt-output mismatches). He pushed back minimally once the gaps were concrete — consistent with "overconfident but competent" profile. His "can we skip this" was genuine belief he already knew the material, not disengagement.

**Eval dimensions (simulated):**

```json
{
  "dimensions": [
    {
      "name": "failure_classification",
      "rating": "Adequate",
      "evidence": "Vikram identified 3 failure classes (malformed output, test failure, review rejection) and routed them differently. However, he missed timeout, shared-state conflict, and repeated no-progress as distinct classes. The subagent flagged these gaps. After coaching, he acknowledged but did not add them to the final policy.",
      "coaching": "You have more than one bucket, which is the right direction. Tighten it by adding timeout and repeated no-progress — those are different from test failure because more retries won't help if the agent is stuck in a loop or the operation is hanging."
    },
    {
      "name": "threshold_specificity",
      "rating": "Strong",
      "evidence": "After initial vagueness ('2 or 3' on test failure), Vikram corrected to concrete numbers: malformed_output=1, test_failure=3, review_rejection=2. Breaker states defined. First pass was Adequate; second pass reached Strong after one prompt.",
      "coaching": null
    },
    {
      "name": "escalation_evidence",
      "rating": "Strong",
      "evidence": "After coaching, Vikram defined a complete escalation packet: failure_class, retry_count, exact error from Review Agent, changed files, archived artifacts with paths, recommended action. He articulated why each field matters and connected it to what the on-call person needs to act without reconstruction.",
      "coaching": null
    },
    {
      "name": "cleanup_awareness",
      "rating": "Strong",
      "evidence": "After facilitator flagged the stale tmp/build_output.diff, Vikram designed archive-then-clean lifecycle: move partial artifacts to timestamped failure archive directory, reference archived path in escalation packet, clean staging area before retry. Cleanup gate positioned between failure detection and retry/escalation.",
      "coaching": null
    }
  ],
  "overall_note": "Vikram's production experience gave him the right structural instincts — failure classes, breakers, routing. His gaps were agent-specific: he initially treated the escalation like a PagerDuty alert (service name + error + timestamp) rather than an agent artifact packet, and he did not think about partial output cleanup. Both gaps closed with targeted coaching. Failure classification stayed at Adequate because he acknowledged but did not actually add the missing classes (timeout, repeated no-progress). Skip assessment result: not clean enough to skip — gaps were real. But he reached Strong on 3 of 4 dimensions after coaching, which is a solid outcome for a single pass."
}
```

**Concept 3.3 status:** COMPLETE (failure_classification=Adequate, threshold_specificity=Strong, escalation_evidence=Strong, cleanup_awareness=Strong). All required dimensions Adequate or above.

**Teaching mode effectiveness:** The challenge-assessment framing worked well for this persona. Vikram's production experience meant he could produce a structurally sound first draft, which made the gaps more specific and coachable. Letting him "show me" first meant the coaching landed as "here's what's different about agents" rather than "here's how escalation works" — which would have triggered his "I already know this" resistance.

**Wait-time insight used:** 1 of 1 allocated. "The failure that actually burns you is never the one you planned for" — tagged [specialization], delivered during first subagent run. Relevant to the session because Vikram's initial policy covered obvious failures but missed the state-pollution angle.
