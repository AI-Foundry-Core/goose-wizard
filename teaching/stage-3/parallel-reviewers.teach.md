# Recipe 3.2: Parallel Reviewers - "Many eyes, clean merge"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md` or "the codebase," interpret those against
> `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `parallel-reviewers` sub-recipe.
> Reviewer temp directories live under `<TARGET>/.goose/tmp/`, not in
> RILGoose.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context (test commands, lint/typecheck commands, review conventions, temp file patterns).
Read ~/.rilgoose/progression.json and check concept 3.2 (module 10: parallel-reviewers).
If concept 3.2 is already complete with adequate or strong ratings:
  "You've already shown layered parallel review and safe coordination. Want to skip ahead to Stage 4, or run another review against fresh changes?"
  If skip: jump to Bridge.
  If revisit: continue normally and only update ratings that improve.

## Framing
"Now we are going to use parallel agents for review. The goal is not three copies of the same reviewer. Each reviewer should catch a different class of error - execution failures, contract drift, behavior bugs, or syntax/type issues."

Ask the developer for a real review target:
"Point me at something worth reviewing: recent changes, a branch, a PR, or a few files — or want me to dig through your recent git activity and find a good target?"

If the developer has no target:
  "No problem. I can find a review target in your recent changes."
Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  "Read `<TARGET>/.goose/team_context.md`. Inspect git status and recent
  commits with `git -C <TARGET> status` and `git -C <TARGET> log`. Find
  a bounded review target with real logic changes under `<TARGET>/`,
  ideally 50-300 lines of diff. Return the target, files involved
  (absolute paths under `<TARGET>/`), and why layered parallel review
  would add value."

Present the candidate naturally:
"Your recent change in [area] is a good target. It has [files/concern], so different reviewers can check different layers."

## The Task
Before running the recipe, ask the developer to choose at least two layers:
"Which review layers do you want? Pick at least two — or want me to pick defaults? Good defaults are execution, contract, behavior, and syntax."

Then ask about coordination:
"Where should parallel reviewers write their findings? I want unique temp paths per reviewer, then one coordinator merges results."

Capture what the developer provides:
- Did they choose two or more distinct review layers?
- Did each layer catch a different class of error?
- Did they keep reviewer outputs read-only and scoped?
- Did they define unique temp paths or run IDs?
- Did they define how findings are merged and deduplicated?

If the developer proposes several reviewers with the same focus:
"Make the layers different. Three behavior reviewers are less useful than one behavior reviewer, one contract reviewer, and one execution reviewer."

If the developer proposes shared output files:
"Give each reviewer its own output file. Concurrent writes to the same file corrupt state."

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "parallel-reviewers"
  parameters:
    review_target: {developer's review target}
    review_layers: {developer-selected layers, or defaults}
    merge_strategy: {developer-selected merge strategy, or union/blocking-first}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent runs parallel reviewers, returns layers executed, merged findings, execution results, coordination log, cleanup result, and final verdict.]

Present results naturally:
"The layers split cleanly: [layer summary]. [Execution/contract/behavior] found [notable finding], while [other layer] found [different finding or no issue]. The coordinator merged [N] findings and cleaned [temp path/run id]."

If coordination had issues:
"The review found a coordination issue too: [issue]. Fix that before using this pattern in a longer pipeline."

## Checkpoint After Parallel Review
Pause after the parallel review run.

"Checkpoint: this is the full Stage 3 pattern. You have specialist agents, contracts, safety rails, layered testing, and coordination for parallel work."

Ask two concrete questions:
"Which layer caught something the others would have missed?"
"What prevents these parallel agents from corrupting each other's state?"

If the developer cannot answer:
- Layered testing gap: "One layer catches one class of error. Execution catches 'does it run'; contract catches 'does it match the promised shape'; behavior catches 'does it do the right thing.'"
- Coordination gap: "The guardrail is scoped state: unique temp files per reviewer, read-only source access, and one coordinator that merges."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer ran layered parallel reviewers and coordinated shared state safely.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each, return:
1. Rating: "Strong", "Adequate", or "Weak"
2. Evidence: What specifically in the transcript supports this rating (quote or paraphrase)
3. Coaching: If not Strong, 1-2 sentences the facilitator should say - conversational, specific, never mentions the eval system or ratings

Dimensions:

1. LAYERED TESTING
   Strong: Developer selected at least two distinct layers that catch different classes of errors, such as execution plus contract or behavior plus syntax.
   Adequate: Developer selected multiple layers but the difference between layers is partly overlapping or not tied to specific failure classes.
   Weak: Developer used one review layer or several reviewers doing the same kind of review.

2. EXECUTION EVIDENCE
   Strong: Developer included an execution-oriented layer or asked for command outputs, exit codes, test results, lint/typecheck results, or equivalent evidence.
   Adequate: Developer mentioned running checks but did not make the expected evidence explicit.
   Weak: Developer relied only on inspection or "looks good" review with no execution evidence.

3. PARALLEL COORDINATION
   Strong: Developer used read-only reviewers, unique temp paths or run IDs, scoped findings files, and a single merge step.
   Adequate: Developer avoided direct source edits but left temp paths, run IDs, or merge ownership partly unclear.
   Weak: Developer allowed parallel agents to write shared files or did not define how concurrent outputs are isolated.

4. RESULT MERGE
   Strong: Developer defined how findings are merged, deduplicated, ranked, and traced back to the layer that found them.
   Adequate: Developer planned to combine findings but did not define deduplication, severity ranking, or layer attribution clearly.
   Weak: Developer treated outputs as separate reports with no merge strategy.

Return as JSON:
{
  "dimensions": [
    {"name": "layered_testing", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "execution_evidence", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "parallel_coordination", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."},
    {"name": "result_merge", "rating": "Strong|Adequate|Weak", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. Coach naturally; do not list ratings.

**Layered testing:**
- Strong: "Good layer split. Execution, contract, and behavior are different nets; each one catches a different class of miss."
- Adequate: "You have multiple reviewers, but make their jobs more different. Ask one to run the code, one to check the contract, and one to look for behavior bugs."
- Weak: "Three reviewers doing the same review is just repetition. Layer it: parse, structure, contract, execution. One layer catches what another misses."

**Execution evidence:**
- Strong: "Good - one layer produced hard evidence: command, exit code, and output. That is stronger than a reviewer saying the code looks fine."
- Adequate: "You mentioned running checks. Make the evidence explicit: which command ran, what exit code came back, and which tests passed or failed."
- Weak: "Inspection is not enough here. Add an execution layer. Checking that a test file exists is not checking that the tests pass."

**Parallel coordination:**
- Strong: "That coordination is safe: read-only reviewers, unique temp paths, and one merge owner. Parallel agents cannot stomp each other's output."
- Adequate: "You avoided source edits, which is good. Now tighten the temp state: each reviewer needs a unique run id and output file."
- Weak: "Concurrent writes corrupt state. Do not let parallel agents share one output file. Give each reviewer its own path and have one coordinator merge."

**Result merge:**
- Strong: "Good merge plan: dedupe, rank severity, and keep layer attribution. That tells you both what to fix and which layer caught it."
- Adequate: "Combining reports is not quite enough. Add dedupe and severity ranking, and keep which layer found each issue."
- Weak: "Separate reports leave you doing the coordination manually. Define one merged output with severity, source layer, evidence, and recommended action."

If all dimensions are Strong:
"That is the robust version: layered reviewers running at the same time, each isolated, with one clean merge. This is how parallel agents give you more coverage without corrupting state."

## GooseForge Connection
After coaching, connect the exercise to GooseForge:

"You just designed parallel reviewers with layer separation and safe coordination. Recipe Forge can help you design new reviewer layers. Each layer is just a code-review agent with a different focus — Recipe Forge would ask what class of error this layer catches, what evidence it produces, and what constraints keep it read-only."

"If you ever need a custom review layer — say, a security reviewer or a performance reviewer — Recipe Forge scaffolds it in minutes instead of writing the YAML from scratch."

Ask: "Want to try Recipe Forge to design a custom review layer for your project? Or move on."

If yes: direct them to run `goose run --recipe recipes/graduated/recipe-forge.yaml --interactive`. Tell them to specify a reviewer archetype with a specific focus area.
If no: proceed to Bridge.

## Bridge
"Stage 3 gives you the team. Stage 4 is about what you feed that team: specs precise enough that the agents can build without guessing. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## Stage 3 Completion Check
Read ~/.rilgoose/progression.json.
If concepts 3.1 (three-agent-pipeline), 3.2 (parallel-reviewers), and 3.3 (escalation-routing) are all complete:
  "You have the full specialist-team pattern now: roles, contracts, safety rails, layered checks, and safe parallel coordination. The next jump is giving that team better specs."
  Update stage 3 status to "complete" in progression.json.

## State Update
Write to ~/.rilgoose/progression.json:
  Update concept 3.2 (module 10: parallel-reviewers) with eval ratings and timestamp.
  Store all four dimension ratings (layered_testing, execution_evidence,
  parallel_coordination, result_merge) as sub-fields of concept 3.2's eval_ratings.
  Update concept 3.2 status to "complete" when all four dimensions are Adequate or Strong.
  Never overwrite a Strong rating with a lower one.
