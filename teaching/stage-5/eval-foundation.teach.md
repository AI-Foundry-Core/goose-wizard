# Recipe 5.1: Eval Foundation — "Never trust self-reported results"

> **Path resolution note.** All verification in this script acts on the
> TARGET codebase (the developer's project). The parent recipe injected
> a TARGET PROLOGUE — whenever this script says `.goose/team_context.md`,
> "the pipeline," "the codebase," or "your repo," interpret those against
> `<TARGET>/`. Re-run test and build commands from within `<TARGET>/`;
> read pipeline artifacts under `<TARGET>/`. Prepend the TARGET PROLOGUE
> to every `Delegate to subagent` call. Pass `target_codebase_path` to
> the `eval-foundation` sub-recipe, and default `project_path` to the
> TARGET when the developer doesn't specify one.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json — check if concept 5.1 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. You are a consulting resource — available when needed, not driving. The developer at this stage has built pipelines, managed agent teams, and written specs. They know how to work with AI. Your role is to spot gaps in their eval strategy that they haven't thought of.

## Framing
"Have you ever had a pipeline claim success when something was actually broken? Let's take one of your pipeline outputs and verify it independently."

Let the developer reflect. If they have a story, build on it.

## The Task
The developer chooses a pipeline output to verify — or you suggest one from their current project.

### Developer-Driven Verification Design (Stage 5: developer leads)

Once the developer has identified the pipeline output and its claims, **stop and ask them to design the verification approach before any code operation runs.**

Ask: "You've got [N] claims there. If you were going to verify each one independently, what commands would you run — and what source would you trust more than the pipeline summary?"

**Let the developer propose the verification plan.** They should name the commands or tools for each claim.

- If the developer proposes correct independent checks (e.g., running pytest directly, parsing coverage output, checking build artifacts): delegate their plan to the code-work subagent.
- If the developer proposes re-reading the pipeline output or asking the agent to confirm: that IS the teaching moment. "That's reading the report again, not verifying it. What command produces the actual number?"
- If the developer gets some right and misses others: acknowledge what they got, then ask about the gaps. "That covers test count. What about the coverage claim — same source or different?"

Only after the developer has articulated a verification approach:

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "eval-foundation"
  parameters:
    pipeline_output: {developer's chosen output or recent pipeline result}
    verification_plan: {developer's proposed verification commands/approach}
    verification_scope: {if developer specified a focus area}
    project_path: {absolute path under <TARGET>/, or <TARGET> itself when unspecified}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent re-runs the developer's verification plan inside <TARGET>/, returns comparison]

### Presenting Results (Socratic, not declarative)

Show the raw numbers. Then ask the developer to interpret — do not explain for them.

"Here's what the pipeline claimed vs. what your checks actually found. [Present the numbers side by side.] What do you make of that?"

Let the developer draw conclusions. If they identify the discrepancy correctly, build on it. If they miss something:

"The summary says [X]. Fresh run says [Y]. What does that tell you about the summary?"

If discrepancies were found and the developer has articulated why:
Reinforce their conclusion. Add one sentence connecting it to the principle: "You can't trust the reporter to audit itself."

If everything matched:
"Everything checked out this time. But the point isn't that it failed today — the point is that you now have a verification step that would catch it when it does. The check takes 30 seconds. The silent failure it prevents could cost hours."

### Enterprise Grounding (connect to developer's workflow)

After the verification results are discussed, ground the pattern in the developer's real infrastructure. Use questions, not statements — the developer designs the integration.

If the developer mentions CI, deploys, team processes, or time pressure:
- "That table is a CI step. Where in your pipeline would it run — after the test stage, or as a separate verification stage?"
- "When a row fails, does it block the merge or just alert? Who gets the notification?"
- If the developer mentions multiple projects or deploy verification: "Same table, different claims. One verification stage can check both test truth and deploy truth."

For unverifiable claims, push for ownership (REQUIRED — do not skip this):
- "You flagged [claim] as unverifiable. Who owns the known-gaps log? If the answer is 'someone,' it means nobody. Assign an owner and a review trigger."
- If the developer gives a vague answer ("the team" or "we'll figure it out"): "That means nobody. Name one person. What triggers them to review it — a calendar reminder, a pipeline event, or a PR label?"
- If no unverifiable claims were surfaced: "Were there any claims you couldn't independently verify? Even 'the build completed successfully' sometimes means 'the build script exited 0 but skipped three steps.' What would you put on the known-gaps list?"

Do NOT deliver these as a block. Weave them into the conversation when the developer surfaces the relevant context. If the developer does not mention enterprise workflow, ask one grounding question: "Where would this check live in your actual pipeline?"

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached building independent verification for pipeline results.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. VERIFICATION INDEPENDENCE
   Strong: Developer designed verification that runs commands independently and parses actual outputs (exit codes, tool output) rather than reading agent-generated summaries.
   Adequate: Developer ran some independent checks but still relied on agent summaries for some claims.
   Weak: Developer's "verification" consisted of re-reading the agent's own output or asking the agent if it really passed.

2. CLAIM DECOMPOSITION
   Strong: Developer identified multiple distinct claims in the pipeline output and verified each one separately (e.g., test count, coverage number, build status as separate checks).
   Adequate: Developer verified the main claim but missed secondary claims (e.g., checked "tests pass" but not "coverage at 85%").
   Weak: Developer treated the pipeline output as a single pass/fail without decomposing individual claims.

3. UNVERIFIABLE AWARENESS
   Strong: Developer explicitly identified claims that couldn't be independently verified and flagged them as gaps rather than trusting them.
   Adequate: Developer noticed some unverifiable claims but didn't explicitly flag them or plan for them.
   Weak: Developer assumed all claims were verified or didn't consider that some claims might be unverifiable.

4. AUTOMATION INSTINCT (conditional)
   Condition: Only rate this if the developer discussed making verification repeatable or automated.
   If condition not met: return {"name": "automation_instinct", "rating": null, "evidence": "Not triggered — developer did not discuss automation", "coaching": null}
   Strong: Developer immediately thought about automating the verification — scripting it, adding it to CI, or making it run on every pipeline execution.
   Adequate: Developer mentioned automation as a future step but didn't take action.
   Weak: Developer treated verification as a one-time manual check with no plan for repeatability.

Return as JSON:
{
  "dimensions": [
    {"name": "verification_independence", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "claim_decomposition", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "unverifiable_awareness", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "automation_instinct", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

**Stage 5 Socratic rule:** For every coaching point below, convert the first sentence to a question. Deliver the answer only if the developer does not reach it themselves. The developer at this stage can articulate principles — let them. Your role is to prompt, not to explain.

### Verification Independence
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You went straight to the source — ran the commands yourself and parsed the actual output. That's the core habit. The agent's report is a summary, not evidence." |
| Adequate | "You ran some checks independently, which is good. But you still took the agent's word on [specific claim]. Run that command yourself next time — it takes 10 seconds and closes the gap." |
| Weak | "You verified by re-reading what the agent told you. That's not verification — that's reading the same report twice. Verification means running `pytest` yourself and parsing the exit code. The agent could say 'all pass' while 5 tests silently errored out." |

### Claim Decomposition
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Good instinct breaking the output into separate claims. 'Tests pass' and 'coverage at 85%' are different claims that need different checks. Most people treat pipeline output as one blob." |
| Adequate | "You checked the main result but there were other claims in that output — [specific missed claim]. Each one is a separate thing that can be independently wrong." |
| Weak | "The pipeline made several distinct claims: [list them]. Each one can independently be wrong. 'Tests pass' doesn't mean coverage is where it should be. Break it apart, verify each piece." |

### Unverifiable Awareness
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Smart — you flagged [specific claim] as unverifiable. Knowing what you can't check is just as important as checking what you can. That's a gap you can plan around." |
| Adequate | "You caught most of it, but [specific claim] slipped through. When you can't verify something independently, at least flag it. Known unknowns are manageable. Unknown unknowns aren't." |
| Weak | "Some of those claims can't actually be verified from the outside — [specific example]. When you can't check something, don't just trust it. Flag it as a gap. The worst failures come from claims nobody thought to question." |

### Automation Instinct
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You're already thinking about making this automatic — that's the right move. A manual check you run once is a learning exercise. A scripted check that runs every time is a safety net." |
| Adequate | "You described the structure. What's stopping you from writing it right now? Pick the first row — which claim, which command, what does pass look like?" |
| Weak | *(Not used — this is a conditional dimension that's only rated if triggered.)* |

If ALL dimensions are Strong:
"You've got the core instinct — verify independently, decompose claims, flag what you can't check, and automate it. That's the foundation everything else in this stage builds on."

## Recipe Reveal
Before bridging, show the developer the recipe that powered this session.

"First recipe of Stage 5. The framing shift is worth a minute — this one exists
because self-reported results aren't evidence."

Read the Eval Foundation agent recipe (recipes/agents/eval-foundation.yaml) and show the developer:
- The **three-bucket return structure** — "Look at the return block: `verified_claims`,
  `failed_claims`, `unverifiable_claims`. Not just pass/fail. The third bucket is the one
  most evals skip — claims that can't be checked at all. Naming them explicitly is how you
  prevent silent trust from creeping back in."
- The **'NEVER accept agent self-reported results as evidence' constraint** — "This is the
  whole philosophy of Stage 5 compressed into one line. Same principle as separating builder
  from reviewer in Stage 2 — now applied to pipeline output. The reporter can't audit itself."
- The **'Check exit codes, not just stdout text' step** — "Step 4 of the process. Agents love
  to read 'tests pass' in stdout and call it verified. Exit codes are the only claim the OS
  itself signs off on. The recipe forces the agent to treat text and exit code as two different
  sources of truth."
- The **read-only + re-run constraint** — "The working-directory block says this primitive
  is read-only with respect to the codebase, but DOES re-run commands. That distinction
  matters. Verification has to execute — reading artifacts isn't enough. But it must never
  mutate what it's verifying."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it in the desktop app:
Run: `goose recipe open <path to recipes/agents/eval-foundation.yaml>`
"Read the constraints block carefully — every Stage 5 recipe has one, and they're where the
eval philosophy is encoded."

WAIT for any questions about the recipe structure.

## Bridge
"Now you have independent verification for one pipeline output. But one layer of checking isn't enough — different types of checks catch different types of problems. That's eval layers, and it's where we go next. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## Wait-Time Insights

Ordered list for this module. Use per teacher-instructions.md Section 13 rules.

1. `[verify]` "The verification has to go to a different source than the thing it's checking. If the pipeline says 47 tests passed, you run pytest yourself — you don't re-read the summary."
2. `[verify]` "Stale artifacts are the silent killer. Coverage reports from a previous run, build logs from the wrong branch — the numbers are real, they're just not from now."
3. `[define-success]` "Not every claim can be verified independently. 'Code quality looks good' has no command that produces a number. Knowing what you can't check is half the work."
4. `[feedback-loops]` "A manual verification you run once is a learning exercise. A scripted check that runs on every pipeline execution is a safety net. The difference is whether it catches the problem at 2am."
5. `[enterprise]` "In a CI pipeline, this verification table becomes a stage that runs after your test job. Each row is a command, an expected value, and a pass/fail — same structure whether you're checking tests, coverage, or deploy health."
6. `[specialization]` "The agent that produced the result should never be the agent that verifies it. Same principle as code review — the author can't be the reviewer."

## State Update
Write to ~/.rilgoose/progression.json:
  concept 5.1 dimensions with eval ratings + timestamp
  Never overwrite a Strong rating with a lower one. If the developer re-runs this recipe, update ratings only if they improve.
