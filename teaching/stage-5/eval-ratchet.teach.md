# Recipe 5.6: Eval Ratchet — "Eval ratchets prevent regression"

> **Path resolution note.** All paths, eval command runs, baseline
> writes, and ratchet-check scripts in this script act on the TARGET
> codebase (the developer's project). The parent recipe injected a
> TARGET PROLOGUE — whenever this script says `.goose/team_context.md`,
> "your eval," "the codebase," or "the repo," interpret those against
> `<TARGET>/`. Baseline files, ratchet check scripts, and CI wiring all
> live under `<TARGET>/` (typically `<TARGET>/evals/`), never in
> RILGoose. Prepend the TARGET PROLOGUE to every `Delegate to subagent`
> call. Pass `target_codebase_path` to the `eval-ratchet` sub-recipe.

## Setup
Read `<TARGET>/.goose/team_context.md` for project context.
Read ~/.rilgoose/progression.json — check if concept 5.6 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"Your eval catches problems today. But what about the slow erosion? A team has 200 passing tests on Monday. By Friday someone deleted 3 'flaky' tests and disabled 2 more. Nobody noticed because the test suite still 'passes.' In a month you're down to 180 and nobody can point to when it happened."

Let the developer connect this to their own experience.

"A ratchet is simple: record the high-water mark, and block any change that drops below it. The bar only goes up. Once you have 200 passing tests, 199 is a failure. Let's set one up — pick a metric (test count, coverage, lint score, something else meaningful), or want me to suggest one from your repo?"

## The Task
Developer picks a metric to ratchet — test count, coverage percentage, lint score, or something else meaningful in their project.

**Let the developer set the threshold.** If the developer guesses or rounds (e.g., "three hundred something"), do NOT correct them. Let them build the ratchet with their guessed value. Run the check. If the real value is far above the threshold, the gap will be visible — ask: "The ratchet says OK. But [actual] tests pass and your floor is [guess]. How many tests can disappear before this catches it?" The developer discovers the problem through execution, not instruction. This is Fully Adaptive — the consequence teaches, not the facilitator.

Delegate to code-work subagent (prepend the TARGET PROLOGUE):
  sub-recipe: "eval-ratchet"
  parameters:
    metric_to_ratchet: {developer's chosen metric}
    current_value: {developer's stated value — even if it's a guess}
    ratchet_file: {if one exists — absolute path under <TARGET>/}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent measures current value by running the eval command inside <TARGET>/, creates ratchet config under <TARGET>/, builds check script under <TARGET>/]

If developer used a guess as the threshold:
  Run the check script. It will pass (real value exceeds guess). Show the output.
  "The ratchet says OK. But [real value] tests pass and your floor is [guessed value]. What does that gap mean?"
  Let the developer reach the conclusion: the floor is too low, you need the real number.
  "What command gives you the number you'd trust?"
  Developer measures. Update the ratchet with the precise value.

If developer measured first (unprompted):
  Present results naturally:
  "Your [metric] is currently at [value]. I've set that as the floor."

Present the check script:
"Here's the check script — it measures the metric, compares against the stored threshold, and fails with a specific message if it drops. When the metric improves, the threshold ratchets up automatically."

Demonstrate the ratchet:
"Let me show you what happens when it catches a regression. [Simulate or describe a drop.] See that error? '[Metric] dropped from 203 to 198. 5 tests were removed or broken.' That's specific enough to act on immediately."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached building quality ratchets that prevent regression.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. METRIC SELECTION
   Strong: Developer chose a metric that is meaningful (reflects real quality), measurable (can be computed programmatically), and monotonic (should only improve over time). Developer articulated why this metric matters.
   Adequate: Developer chose a reasonable metric but didn't articulate why it's the right one to ratchet, or chose a metric that's measurable but not strongly correlated with quality.
   Weak: Developer chose a metric that's easy to game (e.g., lines of code), not reliably measurable, or not clearly connected to quality.

2. THRESHOLD PRECISION
   Strong: Ratchet uses the actual measured value as the baseline (not a round number or guess), and the check script parses real tool output to get the current value.
   Adequate: Ratchet has a reasonable threshold but it was set manually or rounded rather than measured precisely.
   Weak: Threshold is arbitrary (e.g., "let's say 80%") without measuring the actual current value first.

3. FAILURE MESSAGE QUALITY
   Strong: When the ratchet triggers, the failure message says exactly what regressed, by how much, and ideally points toward what changed (e.g., "Test count dropped from 203 to 198. 5 tests removed.").
   Adequate: Failure message indicates regression occurred but lacks specifics (e.g., "Quality check failed").
   Weak: Failure is a generic error or exit code with no human-readable explanation of what regressed.

4. OVERRIDE STRATEGY (conditional)
   Condition: Only rate this if the developer discussed what happens when you legitimately need to lower the threshold.
   If condition not met: return {"name": "override_strategy", "rating": null, "evidence": "Not triggered — developer did not discuss overrides", "coaching": null}
   Strong: Developer designed an explicit override mechanism that requires justification (e.g., a commit message flag, a PR comment, an entry in a decisions log) — not silent editing of the config.
   Adequate: Developer acknowledged overrides might be needed but didn't design a mechanism.
   Weak: Developer planned to just edit the ratchet file directly when needed, with no tracking or justification.

Return as JSON:
{
  "dimensions": [
    {"name": "metric_selection", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "threshold_precision", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "failure_message_quality", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "override_strategy", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. Deliver coaching as a holistic summary, not dimension by dimension. 1-3 sentences per dimension maximum. Lead with what's Strong, weave in what's Weak. Do not recap conclusions the developer already reached during the session.

### Metric Selection
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Good choice — [metric] is measurable, meaningful, and should only go up. That's exactly what makes a good ratchet target." |
| Adequate | "[Metric] is reasonable, but think about what it actually measures. Is it possible to improve the number without improving the code? If yes, the ratchet can be gamed. The best ratchet metrics are hard to cheat." |
| Weak | "Be careful with [metric] — it's easy to inflate without improving anything real. Coverage percentage, for example, can go up by adding trivial tests. Test count can go up by splitting one test into three. Pick a metric where gaming it is harder than just doing the right thing." |

### Threshold Precision
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You measured the actual value and used that as the baseline. That's the right approach — the ratchet reflects reality, not aspiration." |
| Adequate | "Your threshold is reasonable but you rounded it or guessed. Measure it. If your test count is 203, the ratchet should be 203, not 200. Rounding down gives you a regression budget you didn't intend." |
| Weak | "You picked a number out of the air. Run the actual command, read the actual output, and use that number. A ratchet based on a guess doesn't protect against real regression — it protects against imaginary regression." |

### Failure Message Quality
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your failure message tells someone exactly what happened and how much it dropped. That's the difference between 'something broke' and 'fix these 5 missing tests.' Actionable messages get fixed. Vague ones get ignored." |
| Adequate | "The ratchet catches regression, but the failure message doesn't say enough. When this fires at 2am or in a CI log, the developer needs to know: what metric, what was the threshold, what's the current value, and how big is the gap." |
| Weak | "A generic failure message is almost as bad as no ratchet. Nobody investigates 'check failed.' They investigate 'Test count dropped from 203 to 198 — 5 tests removed or broken since last baseline.' Make the message do the diagnostic work." |

### Override Strategy
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Smart — you planned for legitimate exceptions with a tracked override. The ratchet stays honest because lowering it requires a reason on the record." |
| Adequate | "You know overrides will happen. Design the mechanism now — a flag in the commit, an entry in a log, something that makes lowering the bar a deliberate, visible decision rather than a quiet edit to a config file." |
| Weak | *(Not used — this is a conditional dimension that's only rated if triggered.)* |

If ALL dimensions are Strong:
"The ratchet is solid — right metric, precise baseline, clear failure messages, and a deliberate override mechanism. Quality can only go up from here. Literally."

## Wait-Time Insights
Deliver one insight per qualifying code operation (30+ seconds). Use colleague voice, 1-2 sentences. Suppress during challenge assessments (teacher-instructions.md Section 13 Rule 8).

1. [define-success] "Ratchets work because they encode a decision you already made. The hard part was choosing the metric — the automation just remembers it."
2. [specificity] "The failure message is the ratchet's user interface. If someone at 2am can't act on it without reading the code, the message needs more detail."
3. [feedback-loops] "The override log solves a problem most teams discover the hard way — someone quietly lowers the bar and nobody notices until quality is gone."
4. [enterprise] "In a team, the ratchet config file is a contract. Where it lives, who can change it, and whether changes need review are governance decisions."
5. [verify] "A ratchet that passes on a bad threshold is worse than no ratchet — it gives false confidence. The measured value is the only honest baseline."
6. [iteration] "Start with one ratchet on one metric. Once the team trusts it, adding a second is easy. Starting with five means nobody maintains any of them."

## Enterprise Grounding
After the override mechanism discussion (or after the regression demo if overrides are not triggered), ask one or two enterprise questions. Maximum two. Do not turn the session into process design.

Required question: "On your team, who is allowed to lower this threshold — and does that change need a PR approval?"

Optional follow-up (pick the most relevant):
- "Where does the ratchet config live in your repo — root, a config directory, or somewhere the team has a convention for?"
- "You're working on three projects. If ratchets work here, would you set them up the same way in the other two — or does each project need different metrics?"

## Bridge
"The ratchet prevents regression on metrics you can count. But what about evaluation criteria that aren't numbers? 'Check quality' produces rubber stamps. 'Rate each assertion as meaningful, weak, or trivial' produces findings. That's eval design — making your criteria specific enough to actually catch problems. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

## State Update
Write to ~/.rilgoose/progression.json:
  concept 5.6 dimensions with eval ratings + timestamp
