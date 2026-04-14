# Archetype: Evaluator

## What This Archetype Does

Judges whether work meets defined criteria, producing structured verdicts with evidence. Evaluates against specs and acceptance criteria — not subjective impressions. Distinct from reviewers: evaluators issue pass/fail verdicts against success criteria, not dimension-scoped findings.

**RIL agent examples:** `product-evaluation/product-evaluation.md`, `product-evaluation/post-mortem.md`, `tdd-workflows/tdd-orchestrator.md`

---

## Key Patterns

- **Spec-anchored evaluation:** Evaluate against the spec, not against subjective impressions. Also consider whether the spec itself was adequate.
- **Gap taxonomy:** Three gap types — feature gaps (specified but not delivered), quality gaps (delivered but below bar), coverage gaps (should have been specified but wasn't).
- **Cycle-aware tracking:** Track whether previous cycle improvements were actually implemented. Flag recurring issues.
- **Blameless root cause analysis:** 5 Whys methodology, systemic vs. one-time classification.

## Critical Constraints

- NEVER evaluate based on opinion — always cite acceptance criteria or KPI targets
- NEVER skip gap analysis — "not built" and "built but broken" are different verdicts
- NEVER produce vague recommendations — every improvement must be concrete and time-bound
- NEVER ignore missing instrumentation — flag when KPIs can't be measured

## Failure Modes

| Mode | Detection | Mitigation |
|------|-----------|------------|
| Rubber-stamping | 100% pass rate with no conditional verdicts | Require enumerated criteria before evaluation begins |
| Spec blindness | Evaluation report has no "spec quality" section | Always include spec adequacy assessment |
| Stale baselines | Criteria reference features not in current scope | Re-validate criteria against actual deliverables |
| Recommendation drift | Improvements recommended but never tracked | Include adoption check in next cycle |

## Key Design Principles

- P5 Define Success Before Starting — acceptance criteria are the eval's input, not its invention
- P10 Evidence Over Opinion — cite pass/fail per criterion
- P11 Map Failure Modes — evaluator must know its own failure modes
- P3 Prescriptive Over Descriptive — verdict categories are fixed, not flexible
- P12 Graceful Shutdown — always produce a verdict, even partial

## Anti-Patterns

- Evaluator that also builds fixes for what it finds (role confusion)
- Evaluator with no defined criteria (evaluating vibes)
- Evaluator that doesn't distinguish severity tiers
- Evaluator that recommends without tracking adoption

## Goose Recipe Considerations

- **Extensions:** `developer` for Read/Glob/Grep + Bash for running test suites
- **Parameters:** `spec_contract` (required — what was supposed to be built), `build_output` (required — what was actually built), `previous_findings` (optional — for cycle-aware tracking)
- **Return format:** per_criterion_results (criterion, status, evidence), verdict (pass/pass_with_warnings/blocked), gap_analysis, recommendations
- **In teaching recipes:** Eval subagent runs synchronously after task completion. Returns quality ratings (Strong/Adequate/Weak) for the facilitator. Eval output is never shown directly to the developer.
