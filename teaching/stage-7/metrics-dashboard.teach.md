# Recipe 7.1: Metrics Dashboard - "Measure, don't guess"

> **Path resolution note.** All paths and code operations in this script
> act on the TARGET codebase (the developer's project). The parent recipe
> injected a TARGET PROLOGUE — whenever this script says
> `.goose/team_context.md`, refers to baseline or comparison data,
> pipeline outputs, metric snapshots, or "the pipeline," interpret those
> against `<TARGET>/`. Prepend the TARGET PROLOGUE to every `Delegate to
> subagent` call. Pass `target_codebase_path` to the `metrics-dashboard`
> sub-recipe.

Covers:
- 7.1 Measure, don't guess (metrics-dashboard)

Mode: Fully Adaptive. Facilitator is pure consulting - available when the developer asks, not driving.

---

## Setup

Read <TARGET>/.goose/team_context.md for project context.
Read ~/.goose-wizard/progression.json - check concept 7.1.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

Check prerequisites:
- Developer should have made at least one recent pipeline change (instruction
  edit, rule consolidation, new agent, changed workflow) - they need something
  to measure. Stage 6 pipeline work provides natural candidates.
- If no recent change exists, the developer can use this recipe to establish
  a baseline for future comparisons.

---

## Wait-Time Insights

Ordered list. Use at least one per code operation per teacher-instructions.md Section 13.
For all-strong developers, use insights that deepen rather than teach — colleague sharing
a related observation, not explaining a concept.

1. `[define-success]` "A dashboard is only useful if the metric maps to the behavior you changed. Generic health numbers are background noise."
2. `[verify]` "Keep raw counts next to percentages. '50% improvement' from 2 to 3 is not the same signal as 200 to 300."
3. `[feedback-loops]` "Thresholds need a consequence. Decide whether a miss blocks the cycle, creates a review item, or just posts an alert."
4. `[enterprise]` "If other people depend on the pipeline, terminal output is not a dashboard. Put the gate where the team already looks."
5. `[specificity]` "Aggregates hide the next fix. When the total improves, break it down by module to find what still needs instruction context."
6. `[iteration]` "A metric that does not move is still data. It tells you the change did not touch the behavior you thought it would."

---

## Framing

"You changed the builder prompt last week. You consolidated rules across three
files. You removed a guardrail. Is any of that actually better? Without numbers,
you're going on feel. And feel is unreliable - a pipeline that's 10% worse
doesn't feel different until it's 40% worse."

Pause for developer response. Follow their lead.

If developer asks what metrics matter:
  "Depends on what you changed. If you edited an instruction, track the behavior
  it was supposed to fix - does the builder still write trivial tests, or did the
  new instruction actually stop it? If you removed a guardrail, track what it was
  guarding against - are you seeing more of that failure mode, or was the guardrail
  unnecessary? The metric should directly measure the thing you changed."

If developer says they don't have historical data:
  "That's common - and it's exactly why this recipe exists. Start by collecting a
  baseline snapshot now. Run your pipeline, measure everything you care about, and
  save it. Then when you make your next change, you'll have something to compare
  against. The first snapshot is the most valuable one."

---

## Task

The developer drives. The facilitator is available for questions.

**What the developer needs to do:**

1. Choose a pipeline change to measure (or establish a baseline if no change
   is pending)
2. Identify which metrics would show whether that change helped or hurt
3. Use the metrics-dashboard recipe to collect and compare data
4. Interpret the results - including unexpected side effects

Delegate to code-work subagent when the developer is ready (prepend the TARGET PROLOGUE):
  sub-recipe: "metrics-dashboard"
  parameters:
    change_description: {what the developer wants to measure}
    metrics_to_track: {if developer has specific metrics in mind}
    baseline_data: {if developer has a previous metrics snapshot — absolute path under <TARGET>/}
    comparison_data: {if developer has post-change data — absolute path under <TARGET>/}
    target_codebase_path: {TARGET — from the parent recipe's Step 0}

[Subagent identifies metrics, collects data, compares, generates report]

Facilitator presents results naturally:
"[Here's what we measured...] [Here's how it changed...] [Watch out for this...]"

**After the metrics report:**

**Metrics conflict handling:** If the developer cites numbers that conflict with
the metrics report, pause and resolve the source of truth before interpreting the
result. Ask which dataset gates the decision and why: "The report says X; you're
seeing Y. Which one is the decision source?" Do not continue with contradictory
dashboard values — in a recipe about disciplined measurement, conflicting numbers
are the teaching moment, not a wrinkle to smooth over.

Guide the developer through interpretation if they ask. Key things to watch for:
- Small sample sizes that make percentages misleading
- Metrics that moved in unexpected directions (side effects)
- Metrics that didn't move at all (change had no effect)
- The difference between "better" and "meaningfully better"

**If the developer's change made things worse:**
This is a valuable learning moment - not a failure. The metrics caught a
problem that intuition missed. That's the whole point.
  "The numbers say it got worse. Good - you caught that with data instead of
  discovering it three weeks from now. Revert and try a different approach,
  or investigate why the metrics moved that way."

---

## Eval

Delegate to eval subagent (async: true):

```
You are evaluating how well a developer used metrics to assess pipeline changes
instead of relying on intuition.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say  - 
   conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. METRIC SELECTION
   Strong: Developer chose metrics that directly measure the impact of their specific change. The metric connects logically to the change - e.g., measuring test assertion quality after editing the builder's testing instructions.
   Adequate: Developer chose reasonable metrics but they're generic rather than targeted - e.g., "test pass rate" for any change, without considering what specifically would show improvement.
   Weak: Developer couldn't identify what to measure, or chose vanity metrics that don't connect to the change (e.g., "lines of code" for a quality improvement).

2. BASELINE DISCIPLINE
   Strong: Developer either had a pre-change baseline or established one before making comparisons. Understood that "better than before" requires knowing what "before" looked like.
   Adequate: Developer compared to a rough memory of how things were ("I think it used to fail more") rather than actual recorded data.
   Weak: Developer claimed improvement without any baseline - "it seems better" with no reference point.

3. DATA SKEPTICISM
   Strong: Developer questioned the data - checked sample sizes, noticed when percentages were misleading, flagged unexpected movements, or asked whether the improvement was meaningful or just noise.
   Adequate: Developer accepted the metrics report at face value without questioning methodology, sample size, or statistical significance.
   Weak: Developer cherry-picked metrics that supported their desired conclusion and ignored metrics that told a different story.

4. SIDE EFFECT AWARENESS (conditional)
   Condition: Only rate this if the metrics report showed at least one metric that moved in an unexpected direction (including no change when change was expected).
   If condition not met: return rating=null, evidence="All metrics moved as expected - no side effects to evaluate", coaching=null
   Strong: Developer investigated the unexpected metric movement - asked why, looked at the data, and either explained it or flagged it as something to watch.
   Adequate: Developer noticed the unexpected movement but didn't investigate - acknowledged it and moved on.
   Weak: Developer ignored or dismissed the unexpected metric movement entirely.

Return as JSON:
{
  "dimensions": [
    {"name": "metric_selection", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "baseline_discipline", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "data_skepticism", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "side_effect_awareness", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

---

## Coaching

Read eval results. For each dimension:

### Metric Selection

| Rating | Coaching |
|--------|----------|
| **Strong** | "That's the right metric for that change. You measured the thing the change was supposed to affect, not just a general health indicator. That precision is what makes metrics actionable." |
| **Adequate** | "Test pass rate is fine as a general signal, but it doesn't tell you whether your specific change helped. If you edited the builder's testing instructions, track assertion quality - are the tests actually testing behavior now? The metric should be as specific as the change." |
| **Weak** | "You need a metric that connects directly to what you changed. Ask: if this change worked perfectly, what number would move? That's your metric. Everything else is noise." |

### Baseline Discipline

| Rating | Coaching |
|--------|----------|
| **Strong** | "Having a recorded baseline is what makes 'better' mean something. You can point to real numbers, not a feeling. Keep saving snapshots - they compound in value over time." |
| **Adequate** | "Memory is unreliable for metrics. Next time, run the metrics-dashboard recipe before making the change and save the output. 'I think it used to fail more' becomes '14 failures in baseline, 6 after the change.' Night and day difference in confidence." |
| **Weak** | "'It seems better' is not a measurement. Before your next change, snapshot the metrics first. Without a baseline, you literally cannot know if you improved things or made them worse." |

### Data Skepticism

| Rating | Coaching |
|--------|----------|
| **Strong** | "Good instinct - questioning the data is as important as collecting it. A 50% improvement from 2 to 3 is not the same as a 50% improvement from 200 to 300. You caught that." |
| **Adequate** | "The report says improvement, and you accepted it. But look at the sample size - is this 3 data points or 300? Look at the other metrics - did anything get worse while this got better? The report gives you data. Your job is to interrogate it." |
| **Weak** | "You looked at the metric that supported your conclusion and stopped. What about the ones that didn't move, or moved the wrong way? Pipeline changes have side effects. If you only look at the metric you want to see, you'll miss the one that matters." |

### Side Effect Awareness (if triggered)

| Rating | Coaching |
|--------|----------|
| **Strong** | "You caught the side effect and investigated. That's how you avoid trading one problem for another - which is exactly what happens when people change pipeline settings without measuring broadly." |
| **Adequate** | "You noticed something moved unexpectedly but didn't dig in. That's worth investigating - unexpected metric movements are often more informative than the expected ones. They reveal dependencies you didn't know existed." |
| **Weak** | "A metric moved in the wrong direction and you didn't address it. That's a signal. Maybe the change had an unintended consequence. Maybe two things are coupled in a way you didn't expect. Ignoring it doesn't make it go away." |

If ALL dimensions are Strong:
  "You're measuring changes, questioning the data, and watching for side effects.
  That's the difference between a pipeline that someone hopes is improving
  and one that demonstrably is."

  Note: Use "watching for" not "catching" — if side_effect_awareness was null
  (all metrics moved as expected), the developer did not catch a side effect.
  "Watching for" is accurate regardless of whether one appeared.

  Do NOT suggest additional metrics, tracking approaches, or extensions. The
  developer drove the session and got everything right. Confirm, connect to
  outcomes, and bridge. For E10 (all-strong), one sentence is enough — do not
  prescribe where the developer can decide.

---

## Enterprise Grounding

When the developer proposes automatic dashboard gating or pipeline-integrated
metrics, ask one enterprise question to ground the design in team workflow:

  "Where does the team see these numbers — PR comment, CI job, Slack alert,
  cycle review file, or a team dashboard?"

Follow the developer's answer. If they want design help, assist. If they have
a clear answer, confirm and move on. Keep it to one question unless the developer
wants to go deeper.

For threshold-gated automation specifically, also ask what happens on failure:
  "When a threshold is breached — does it block the merge, create a review item,
  post an alert, or something else?"

These questions are not lectures. They are the minimum to make the dashboard
operationally real instead of conceptually complete.

---

## Recipe Reveal
After enterprise grounding, show the developer the recipe behind this session — the
last recipe reveal of the curriculum.

"This is the recipe that closes the improvement loop. Metrics in, honest comparison out.
The design is almost entirely about what it's forbidden from doing."

Read the Metrics Dashboard agent recipe (recipes/agents/metrics-dashboard.yaml) and show the developer:
- The **four `NEVER` constraints** — "'NEVER show percentages without the raw numbers
  alongside them.' 'NEVER ignore small sample sizes — flag them prominently.' 'NEVER hide
  metrics that moved in the wrong direction.' 'NEVER compare snapshots taken from the
  same run as before/after.' Every wait-time insight you heard today is encoded here as
  a hard constraint. The anti-spin discipline is the recipe."
- The **separated `improved` vs `regressed` vs `insufficient_data` return fields** —
  "The recipe literally cannot return 'things got better' without also reporting what
  got worse and what's inconclusive. That structure is what makes the output honest —
  the agent has nowhere to hide a regression by omission."
- The **`baseline_data` and `comparison_data` parameters** — "Both required. You can't
  run this recipe against a single snapshot and get a 'looks good.' No baseline, no
  dashboard. That's the baseline discipline you just practiced, enforced at the parameter
  level."
- The **feedback loop from here back to Skill Evolution** — "When the metrics say a
  change regressed, you feed that back into the Curator as a finding. Measure →
  evolve → measure again. These last three recipes — Metrics, Skill Evolution, and
  Pipeline Self-Edit — are the self-improvement loop you've been building toward."

Keep it to 3-4 highlighted snippets. Do NOT dump the whole file.

Open it for them. First try the desktop app:
Run: `goose recipe open <path to recipes/agents/metrics-dashboard.yaml>`
"Last recipe — read the NEVER block and then look back across Stage 7. The same pattern
repeats: structured output, required fields, hard-coded honesty. Now you know how to read
any recipe YAML and predict what it will do."

If `goose recipe open` errors or the desktop app does not respond, tell the developer: "Open `recipes/agents/metrics-dashboard.yaml` directly in your editor (VS Code, etc.) — same content, same discussion." Known upstream issue when the CLI and desktop app both run on this project simultaneously.

WAIT for any questions about the recipe structure.

---

## Bridge

"You can now measure whether a pipeline change actually improved things. But
the measurement will only stay useful if the rules driving the pipeline stay
clean. Right now, after a few cycles of adding constraints, your rules are
probably duplicated, contradictory, or accumulating dead weight. Next: auditing
and pruning the rules themselves — deduplication, conflict resolution, and
explicit guardrail review. Ready to move on?"

Check: Wait for the developer to confirm. If they decline or hesitate, ask what's holding them back. If they ask a clarifying question, answer briefly and re-offer.

---

## State Update

Write to ~/.goose-wizard/progression.json:
  concept 7.1 dimensions:
    - metric_selection: {rating from eval}
    - baseline_discipline: {rating from eval}
    - data_skepticism: {rating from eval}
    - side_effect_awareness: {rating from eval, may be null}
  With timestamps.

If all Stage 7 concepts (7.1-7.3) are now complete:
  Set stage 7 status to "complete" with timestamp.
  This marks the full 8-stage progression as complete.
