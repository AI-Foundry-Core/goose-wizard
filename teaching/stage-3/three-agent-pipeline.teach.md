# Recipe 3.1-3.3: Three-Agent Pipeline - "Build a team of specialists"

## Setup
Read .goose/team_context.md for project context (stack, test commands, conventions, ownership model).
Read .goose/state/progression.json and check concepts 3.1, 3.2, and 3.3.
If all three concepts are already complete with adequate or strong ratings:
  "You've already shown this workflow: specialist roles, explicit handoffs, and safety rails. Want to skip to parallel reviewers, or run another pipeline design against a real task?"
  If skip: jump to Bridge.
  If revisit: continue normally and only update ratings that improve.

## Framing
"Pick a real development task that is big enough for more than one AI. Not a one-line change - something where a spec pass, an implementation pass, and an independent review pass would each add value."

If the developer has no task ready:
  "No problem. I can find a candidate in the repo."
Delegate to code-work subagent:
  "Read .goose/team_context.md. Scan recent git changes, TODO/FIXME notes, and small feature-shaped gaps. Find one task that would benefit from a three-agent pipeline. It should be real, bounded, and small enough for one session. Return a short task description, likely files, and why it needs separate spec/build/review roles."

Present the candidate naturally:
"I found a good candidate: [task]. It touches [likely area], and it is large enough that separate spec, build, and review passes make sense. Want to use that?"

## The Task
Developer chooses the task.

Before running the recipe, ask the developer to sketch the pipeline:
"Before I run it, name the specialists you want. For each one, give it one job. Then tell me what each agent passes to the next one."

Capture what the developer provides:
- Did they define at least three distinct roles?
- Did each role have one clear responsibility?
- Did they define a handoff format, not just "pass the result"?
- Did they include a failure threshold, retry limit, timeout, or escalation route?

If the developer gives an all-purpose role like "the coding agent does everything":
"Split that role. One AI should not own spec, implementation, and review. Try: one agent decides what to build, one builds it, one checks it."

**Show the contrast — pipeline of specialists vs. one agent with helpers:**

"Here's the difference. One approach: a single 'coding agent' that plans, builds, and reviews its own work — maybe it calls a helper to run tests, but it's still one mind making all the decisions. The other approach: a Spec Agent that writes acceptance criteria and hands them to a Build Agent that only writes code, which hands its output to a Review Agent that only checks work it didn't write. The first approach is one person grading their own exam. The second is three people who each see the work fresh."

"Which one do you trust more when the task is complex? That's why we split roles."

If the developer describes handoffs only as prose:
"That is the idea. Now make the handoff explicit: what fields does the next agent receive?"

Delegate to code-work subagent:
  sub-recipe: "three-agent-pipeline"
  parameters:
    task_description: {developer's task}
    role_plan: {developer's role sketch}
    handoff_contracts: {developer's handoff sketch}
    safety_policy: {developer's safety thresholds and escalation routes, if provided}

[Subagent designs and runs the pipeline, then returns roles, contracts, execution log, final result, safety events, and any escalation packet.]

Present results naturally:
"Here is the team that ran: [roles]. The important bit is the handoff: [one concise contract example]. The build made [summary], and the reviewer [passed / blocked / escalated] it based on [evidence]."

If the pipeline halted:
"This is a useful halt, not a failure. The breaker stopped the loop at [threshold], and the escalation packet says [owner] needs [specific next action]."

## Checkpoint After 3.3
Pause after the three-agent pipeline and escalation routing work.

"Checkpoint: does this pipeline have a real team shape? I am looking for three things: each AI has one job, each handoff has a data shape, and the loop knows when to stop."

If any of those are missing, coach the missing point before moving on:
- Missing role specialization: "Right now one agent still owns too much. Split it by decision type: spec, build, review."
- Missing contracts: "The next agent needs a contract, not vibes. Give it fields like changed_files, acceptance_criteria, test_results, and deviations_from_spec."
- Missing safety rails: "Add a stop rule. Without a threshold, a failing agent can burn cycles forever."

Optionally run the escalation-only recipe if the safety design is weak or unclear:
Delegate to code-work subagent:
  sub-recipe: "escalation-routing"
  parameters:
    pipeline_description: {pipeline design returned by three-agent-pipeline}
    failure_scenario: {most likely failure from the run, or developer-provided concern}
    escalation_target: {developer preference, default human}

Present the safety patch:
"Now the failure route is explicit: [failure] retries [N] times, then routes to [owner] with [packet fields]."

## Wait-Time Insights

Share one insight per subagent wait, in order. Adapt to what just happened in conversation.

1. `[specialization]` — "The Spec Agent only writes acceptance criteria — it never sees the implementation. That constraint is the point. A spec writer who also builds will unconsciously write specs that match what they plan to build."
2. `[specialization]` — "The Build Agent gets a scoped context: the spec contract and the files it's allowed to touch. It doesn't see the reviewer's logic or the spec agent's reasoning. That's what keeps each agent's judgment independent."
3. `[verify]` — "The Review Agent checks the build against the spec — not against what the builder intended. That separation is what makes the review real instead of a rubber stamp."
4. `[feedback-loops]` — "When the reviewer rejects, the builder gets specific fields: which criteria failed, which tests broke. Not a paragraph of feedback — structured data it can act on without guessing."
5. `[enterprise]` — "In a team setting, these contracts become the API between agent roles. Different developers can own different agents and evolve them independently, as long as the contract holds."
6. `[define-success]` — "The safety rail is not about preventing failure — it's about making failure bounded. Three rejected reviews cost you three cycles. Without the rail, a subtle bug can burn fifty."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer designed a multi-agent pipeline with specialist roles, explicit contracts, and safety rails.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating (quote or paraphrase)
3. Coaching: If not Strong, 1-2 sentences the facilitator should say - conversational, specific, never mentions the eval system or ratings

Dimensions:

1. ROLE SPECIALIZATION
   Strong: Developer defined 3 or more agents with distinct jobs and scoped knowledge; no agent owns spec, implementation, and review together.
   Adequate: Developer defined 3 or more agents but at least one role is broader than ideal or context scope is not fully clear.
   Weak: Developer used one general agent or roles overlap so much that agents are not meaningfully specialized.

2. HANDOFF CONTRACTS
   Strong: Developer defined explicit data shapes between agents, including fields the receiving agent can validate.
   Adequate: Developer described what passes between agents but the format is partly narrative or missing validation fields.
   Weak: Developer relied on "pass the result along" or unstructured conversation with no contract.

3. SAFETY RAILS
   Strong: Developer defined retry limits, circuit breaker thresholds, and escalation routes with enough evidence for the next owner to act.
   Adequate: Developer included at least one safety rail, such as a retry limit or human escalation, but the thresholds or packets are incomplete.
   Weak: Developer left the pipeline free to retry indefinitely or did not define what happens after repeated failure.

4. SCOPED CONTEXT
   Strong: Developer limited each agent to the context needed for its role and avoided passing all reasoning to every agent.
   Adequate: Developer showed awareness of scoped context but left some agents with more context than they need.
   Weak: Developer planned to give every agent the full transcript or full repo context without a reason.

Return as JSON:
{
  "dimensions": [
    {"name": "role_specialization", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "handoff_contracts", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "safety_rails", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "scoped_context", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. Coach naturally; do not list ratings.

**Role specialization:**
- Strong: "That team shape is clean: one agent decides what to build, one builds it, one checks it. Each AI has a job instead of everyone doing everything."
- Adequate: "This works, but tighten the broad role. If one agent is both planner and reviewer, split it - those jobs need different judgment."
- Weak: "Right now this is one generalist wearing three hats. Compare that to: Spec Agent writes acceptance criteria, Build Agent changes code, Review Agent runs checks. The first design is one person grading their own exam — they'll always find their own work reasonable. The second design is three people who each see the work fresh. A reviewer that never sees the builder's reasoning can't unconsciously confirm what the builder intended — it can only check what the spec required."

**Handoff contracts:**
- Strong: "Good - the handoff is concrete. The next agent can validate fields like changed_files, test_results, and deviations_from_spec instead of guessing what the previous agent meant."
- Adequate: "The handoff idea is there, but make it a shape. Define the fields the next agent expects; that is what prevents format drift."
- Weak: "Right now your agents pass prose summaries. Compare: Agent A sends 'I made some changes to the auth module' versus Agent A sends `{changed_files: ['auth.py', 'middleware.py'], tests_added: 2, acceptance_criteria_met: [1,2,4], acceptance_criteria_failed: [3]}`. The first one forces Agent B to guess. The second one lets Agent B validate before it starts working. Contracts prevent the telephone game."

**Safety rails:**
- Strong: "Good safety rail: the loop has a stop point and an owner. That is what lets the pipeline run without you babysitting every retry."
- Adequate: "You have a safety idea, but add the exact threshold and packet. For example: after 2 rejected reviews, stop and send changed_files, failing_tests, and reviewer_notes to a human."
- Weak: "Without a stop rule, a failing agent loops forever. Here's what that looks like in practice: the builder submits, the reviewer rejects, the builder 'fixes' by making a different mistake, the reviewer rejects again, and this continues for 47 cycles until you notice your API bill. Compare that to: after 3 rejected reviews, stop, package the last attempt with all reviewer feedback, and route to a human. The pipeline costs you 3 cycles instead of 47."

**Scoped context:**
- Strong: "Good context control. The reviewer got the spec and changed files, not the builder's whole reasoning, so it can check independently."
- Adequate: "The scoping is close. Trim the context further: each agent should receive only the contract it needs to do its job."
- Weak: "If every agent sees everything, they start copying each other's assumptions. Here's the problem: the builder writes a comment saying 'this handles the edge case.' The reviewer sees that comment and thinks 'oh, that edge case is handled' — without actually checking. That's not review, that's confirmation bias. Instead: pass the spec to the builder and the build artifact to the reviewer. The reviewer shouldn't know what the builder intended — only what the spec required."

If all dimensions are Strong:
"That is a real AI team: specialist roles, contracts between them, scoped context, and a breaker that knows when to stop. This is the point where the system can do more than a single prompt."

## Bridge
"Now that you have a team pipeline, the next problem is coordination under parallel work. Multiple reviewers can catch different classes of issues at the same time, but shared files and temp state need discipline."

## State Update
Write to .goose/state/progression.json:
  concepts 3.1, 3.2, and 3.3 with eval ratings and timestamp.
  Map role_specialization and scoped_context to concept 3.1.
  Map handoff_contracts to concept 3.2.
  Map safety_rails to concept 3.3.
  Update each concept status to "complete" when its required dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
