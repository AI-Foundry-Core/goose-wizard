# Recipe 5.3: Eval Layers — "Layered eval strategy"

## Setup
Read .goose/team_context.md for project context.
Read .goose/state/progression.json — check if concept 5.3 is already demonstrated.
If already demonstrated (all dimensions adequate+): offer to skip or revisit.

This is **Fully Adaptive** mode. Consulting role — the developer leads, you spot gaps.

## Framing
"You've got independent verification running. But right now it's probably all one type of check — running tests and parsing results. What happens when the tests all pass but the code is unreadable? Or the code looks clean but doesn't handle edge cases? Different types of checks catch different types of problems."

Let the developer think about what their current eval misses.

"There are three layers that cover most failure modes: deterministic checks that catch the obvious, behavioral tests that catch the functional, and model-based grading that catches the subjective. Most teams only have one. Let's build all three."

## The Task
The developer picks a component or pipeline to build a layered eval for.

Delegate to code-work subagent:
  sub-recipe: "eval-layers"
  parameters:
    target_component: {developer's chosen component}
    existing_evals: {what they already have}
    quality_concerns: {if they mentioned specific worries}

[Subagent audits existing layers, identifies gaps, builds missing checks]

Present results naturally:
"Here's what you had and what was missing. [Summarize the layer audit.] I added [new checks] to fill the gaps. Your eval runner now executes all three layers — deterministic first for fast failure, then behavioral, then model-based."

Walk through a concrete example:
"Watch what happens when I introduce a subtle problem — [describe the defect]. The deterministic checks pass because the syntax is fine. The behavioral tests pass because the main path works. But the model-based eval catches it because [specific reason]. That's why you need layers."

## Eval
Delegate to eval subagent (async: true):

```
You are evaluating how well a developer approached building a multi-layered evaluation strategy.

Here is the full conversation transcript between the developer and the facilitator:

---
{transcript}
---

Rate each quality dimension below. For each dimension:
1. Rate as "Strong", "Adequate", or "Weak"
2. Cite specific evidence from the transcript
3. If not Strong, write 1-2 sentences of coaching the facilitator should say — conversational, specific, never mentions the eval system or ratings

Quality dimensions:

1. LAYER DIVERSITY
   Strong: Developer's eval system has checks in at least two distinct layers (deterministic, behavioral, model-based) with clear understanding of what each layer catches that others miss.
   Adequate: Developer has multiple checks but they're mostly in the same layer (e.g., all behavioral tests, no deterministic or model-based).
   Weak: Developer's eval is essentially one type of check repeated (e.g., "run the tests" is the entire eval strategy).

2. FAILURE MODE MAPPING
   Strong: Developer articulated specific failure modes and mapped each to the layer that catches it (e.g., "syntax errors → deterministic, logic bugs → behavioral, readability → model-based").
   Adequate: Developer has a general sense that different layers catch different things but didn't explicitly map failure modes to layers.
   Weak: Developer couldn't articulate what types of failures each layer catches or treated all checks as equivalent.

3. EXECUTION ORDER
   Strong: Developer organized layers to fail fast — cheapest/fastest checks first, expensive checks last, with early termination on failure.
   Adequate: Developer has all layers but didn't think about execution order or runs expensive checks even when cheap ones fail.
   Weak: Developer runs checks in arbitrary order or doesn't have a runner that orchestrates them.

4. LAYER INDEPENDENCE
   Strong: Each layer runs independently — you can run deterministic checks without behavioral tests, or model-based without either. Layers are composable.
   Adequate: Layers mostly independent but some coupling exists (e.g., model-based eval depends on behavioral test output).
   Weak: Layers are tightly coupled — can't run one without the others, or they share state in ways that create dependencies.

Return as JSON:
{
  "dimensions": [
    {"name": "layer_diversity", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "failure_mode_mapping", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "execution_order", "rating": "...", "evidence": "...", "coaching": "..."},
    {"name": "layer_independence", "rating": "...", "evidence": "...", "coaching": "..."}
  ],
  "overall_note": "..."
}
```

## Coaching
Read eval results. For each dimension:

### Layer Diversity
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Three distinct layers, each catching what the others miss. That's the structure. Most eval systems are one-dimensional — yours isn't." |
| Adequate | "Your checks are solid but they're mostly the same type. You've got good [behavioral/deterministic] coverage, but you're missing [the layer they lack]. That's a blind spot — [specific failure type] will slip through." |
| Weak | "'Run the tests' is one layer, not a strategy. Tests catch functional regressions. They don't catch unreadable code, they don't catch missing edge cases in the logic, and they definitely don't catch architectural drift. You need at least two distinct types of check." |

### Failure Mode Mapping
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "You mapped each failure type to the layer that catches it. That's how you know your eval is complete — every failure mode has a home. When something slips through, you know which layer to strengthen." |
| Adequate | "You have a general sense, but get specific. Write it down: 'deterministic catches X, behavioral catches Y, model-based catches Z.' When a bug escapes your eval, that map tells you which layer needs work." |
| Weak | "Think about the last three bugs that made it to production. Which of your current checks would have caught each one? If you can't answer that, your eval has blind spots you haven't mapped. Start there." |

### Execution Order
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Fast checks first, expensive checks last. If linting fails, why waste time running a full test suite? That ordering saves minutes per run and hours per week." |
| Adequate | "Your layers run but the order isn't optimized. Put the cheapest checks first — linting, type checks, format validation. If those fail, kill the run immediately. No point running a 5-minute test suite when a 2-second lint check already found problems." |
| Weak | "Right now your checks run in whatever order they happen to be in. Structure it: deterministic first (seconds), then behavioral (minutes), then model-based (expensive). Fail fast — don't waste compute on downstream checks when upstream ones already failed." |

### Layer Independence
| Rating | Facilitator Says |
|--------|-----------------|
| Strong | "Each layer runs on its own. That means you can run just the fast checks in a pre-commit hook, the full suite in CI, and the model-based eval on a schedule. Composability is how you scale this." |
| Adequate | "Most of your layers are independent, but [specific coupling]. Decouple that — you should be able to run any layer without the others. It makes the whole system more flexible." |
| Weak | "Your layers depend on each other — if one breaks, they all break. Each layer needs to run independently against the same artifacts. Think of them as three reviewers looking at the same document, not a chain where each reviewer reads the previous one's notes." |

If ALL dimensions are Strong:
"You've built a layered eval that catches different failure types at different costs, runs in the right order, and each layer stands on its own. That's a real evaluation system, not just 'run the tests.'"

## Bridge
"You've got layers that catch problems. But what prevents quality from slowly sliding backward between checks? That's ratchets — quality thresholds that only go up. Once you have 200 passing tests, the number should never drop below 200."

## State Update
Write to .goose/state/progression.json:
  concept 5.3 dimensions with eval ratings + timestamp
  Never overwrite a Strong rating with a lower one. If the developer re-runs this recipe, update ratings only if they improve.
