# Recipe 5.1: Eval Foundation — "Never trust self-reported results"

## Setup
Read .goose/team_context.md for project context.
Read .goose/state/progression.json — check if concept 5.1 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. You are a consulting resource — available when needed, not driving. The developer at this stage has built pipelines, managed agent teams, and written specs. They know how to work with AI. Your role is to spot gaps in their eval strategy that they haven't thought of.

## Framing
"You've been building pipelines that produce results — tests pass, builds succeed, code looks good. But how do you know the pipeline is telling the truth? Have you ever had a pipeline claim success when something was actually broken?"

Let the developer reflect. If they have a story, build on it. If not:

"It happens more than people expect. An agent says 'all 47 tests pass' but it only ran 30 of them. A build reports success but silently skipped a step. Let's take one of your pipeline outputs and verify it independently."

## The Task
The developer chooses a pipeline output to verify — or you suggest one from their current project.

Delegate to code-work subagent:
  sub-recipe: "eval-foundation"
  parameters:
    pipeline_output: {developer's chosen output or recent pipeline result}
    verification_scope: {if developer specified a focus area}
    project_path: {if needed}

[Subagent independently verifies claims, returns comparison]

Present results naturally:
"Here's what the pipeline claimed vs. what actually happened when we checked independently. [Summarize matches and discrepancies.]"

If discrepancies were found:
"See that? The pipeline said [X] but the actual result was [Y]. This is exactly why independent verification matters — you can't trust the reporter to audit itself."

If everything matched:
"Everything checked out this time. But the point isn't that it failed today — the point is that you now have a verification step that would catch it when it does. The check takes 30 seconds. The silent failure it prevents could cost hours."

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
| Adequate | "You mentioned automating this later. Do it now — while the checks are fresh. A verification script that takes an hour to write saves you from the silent failure you won't catch manually at 2am." |
| Weak | *(Not used — this is a conditional dimension that's only rated if triggered.)* |

If ALL dimensions are Strong:
"You've got the core instinct — verify independently, decompose claims, flag what you can't check, and automate it. That's the foundation everything else in this stage builds on."

## Bridge
"Now you have independent verification for one pipeline output. But one layer of checking isn't enough — different types of checks catch different types of problems. That's eval layers, and it's where we go next."

## State Update
Write to .goose/state/progression.json:
  concept 5.1 dimensions with eval ratings + timestamp
  Never overwrite a Strong rating with a lower one. If the developer re-runs this recipe, update ratings only if they improve.
