# Recipe 5.4: Eval Design — "Specific checks find problems, vague checks don't"

## Setup
Read .goose/team_context.md for project context.
Read .goose/state/progression.json — check if concept 5.4 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"Tell me about the last time you reviewed code using a checklist. Did it find anything? Most checklists don't — because they say things like 'check for best practices' or 'ensure quality.' That's not a check. That's a wish."

Let the developer reflect.

"The problem is specificity. 'Check quality' tells the evaluator nothing. 'Open 3 test files, rate each assertion as meaningful, weak, or trivial, flag if more than 30% are weak or trivial' — that produces findings every time. Let's take one of your vague eval criteria and make it specific."

## The Task
Developer picks an eval target — something they need to evaluate regularly (generated tests, code review output, refactored code, pipeline output, documentation).

Delegate to code-work subagent:
  sub-recipe: "eval-design"
  parameters:
    eval_target: {developer's chosen eval target}
    current_eval: {their existing checklist or criteria if they have one}
    known_failures: {if they mentioned specific problems they want to catch}

[Subagent analyzes vague criteria, rewrites as specific checks, tests against real artifacts]

Present results naturally:
"Here's what your original criteria looked like vs. the rewritten version. [Show the before/after.] And here's what happened when I ran the specific version against your actual code: [summarize findings]."

Contrast the results:
"The vague version would have produced 'looks good.' The specific version found [number] actual issues — [list them]. Same evaluator, same code, different criteria. Specificity is the variable."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached designing specific evaluation criteria.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. CRITERION SPECIFICITY
   Strong: Developer wrote criteria that specify exactly what to look at, how to categorize what they find, and what threshold triggers a finding. Two different evaluators using these criteria would reach the same conclusion.
   Adequate: Developer's criteria are more specific than "check quality" but still leave room for interpretation (e.g., "check for meaningful tests" without defining what "meaningful" means).
   Weak: Developer's criteria are vague enough to produce rubber stamps (e.g., "review for correctness," "ensure best practices," "check quality").

2. SAMPLING INSTRUCTIONS
   Strong: Developer included explicit sampling instructions — which items to check, how many, how to select them (e.g., "the 5 most-changed files," "3 random test files," "all files over 200 lines").
   Adequate: Developer implied some scoping but didn't give explicit sampling instructions (e.g., "check the test files" without specifying which ones or how many).
   Weak: Developer wrote criteria that imply checking everything (impractical) or didn't specify scope at all.

3. FINDING GRANULARITY
   Strong: Eval criteria produce categorized findings with counts or specifics (e.g., "2 of 5 assertions are trivial," "3 functions have stale docstrings"), not just pass/fail.
   Adequate: Criteria produce some detail but output is mostly pass/fail or good/bad without quantification.
   Weak: Criteria produce only binary output ("quality: acceptable") with no detail about what was good or bad.

4. REAL ARTIFACT TEST
   Strong: Developer tested their criteria against a real artifact from their project and the criteria produced actionable findings.
   Adequate: Developer tested against a real artifact but the criteria didn't produce meaningful findings (suggesting the criteria need tuning).
   Weak: Developer wrote criteria but didn't test them against anything real.

Return as JSON:
{
  "dimensions": [
    {"name": "criterion_specificity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "sampling_instructions", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "finding_granularity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "real_artifact_test", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

### Criterion Specificity
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your criteria are specific enough that two different people would reach the same conclusion. That's the test — if the result depends on who's evaluating, the criteria aren't specific enough." |
| Adequate | "Getting closer, but [specific criterion] still leaves room for interpretation. What does 'meaningful test' mean exactly? Define it: 'tests real behavior with realistic inputs, not implementation details or trivially obvious conditions.' Now an evaluator knows what to look for." |
| Weak | "'Check for best practices' tells the evaluator nothing. What practice? How do they check? What counts as a violation? Rewrite every criterion so it starts with a verb and includes what to look at: 'Open [specific files]. Look for [specific pattern]. Flag if [specific threshold].' That structure forces specificity." |

### Sampling Instructions
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You scoped it — 'check the 5 most-changed files' is practical and targeted. An evaluator can't check everything, and the most-changed files are where problems hide. Good selection strategy." |
| Adequate | "'Check the test files' — which ones? All of them? There might be 200. Scope it: 'the 3 test files with the most recent changes' or '5 randomly selected test files.' Give the evaluator a number and a selection method." |
| Weak | "Without sampling instructions, the evaluator either checks everything (impossible) or picks randomly (inconsistent). Tell them exactly what to look at and how many. The eval is only as good as the sample." |

### Finding Granularity
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Your eval produces counts and categories, not just thumbs-up or thumbs-down. '2 of 5 assertions are trivial' is something you can act on. 'Quality: adequate' is not." |
| Adequate | "Your findings are mostly pass/fail. Push for categories and counts. Instead of 'tests are good,' try 'of 8 assertions: 5 meaningful, 2 weak (test implementation details), 1 trivial (tests a constant).' That level of detail shows you exactly where to improve." |
| Weak | "The eval output says 'acceptable' — what does that mean? Which parts were good? Which were bad? An eval that can't tell you what to fix is an eval that just makes you feel good. Redesign the output to report specific findings, not verdicts." |

### Real Artifact Test
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You tested your criteria against real code and got actionable findings. That's how you know the criteria work — they find things that matter." |
| Adequate | "You ran the criteria but they didn't find much. That either means the code is genuinely good, or the criteria aren't specific enough. Try tightening them — if they still find nothing, great. If they start finding things, the original criteria were too loose." |
| Weak | "You wrote criteria but didn't test them. Criteria that haven't been tested against real artifacts are theoretical. Run them now. If they produce no findings on real code, they're too vague. If they produce findings, you've validated your eval." |

If ALL dimensions are Strong:
"Your eval criteria are specific, scoped, produce detailed findings, and you've proven they work against real artifacts. This is the difference between an eval system that catches problems and one that rubber-stamps everything."

## Bridge
"Specific criteria solve the accuracy problem. But what about reliability? If your eval depends on a live API that's down, the whole gate fails — not because your code is bad, but because Stripe's servers are slow today. That's the isolation problem. Mock your external dependencies and your evals run every time."

## State Update
Write to .goose/state/progression.json:
  concept 5.4 dimensions with eval ratings + timestamp
