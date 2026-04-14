# Archetype: Investigator

## What This Archetype Does

Diagnoses problems by forming hypotheses, gathering evidence, and narrowing to root cause. Works backward from symptoms to causes, correlating errors across systems and time windows.

**RIL agent examples:** `error-debugging/debugger.md`, `error-debugging/error-detective.md`

---

## Key Patterns

- **Hypothesis-driven process:** Capture error → Identify reproduction → Isolate failure → Implement fix → Verify. Each step narrows the search.
- **Evidence chain:** Every diagnosis includes root cause explanation, supporting evidence, specific fix, testing approach, and prevention recommendations.
- **Pattern correlation:** Correlate errors with recent deployments/changes. Check for cascading failures. Identify rate changes and spikes across time windows.
- **Symptom vs. cause discipline:** Focus on fixing the underlying issue, not just symptoms. A try/catch that suppresses an error is not a fix.

## Critical Constraints

- NEVER apply a fix without stating the hypothesis and evidence supporting it
- NEVER stop at the first plausible explanation — verify with reproduction
- NEVER make changes without documenting what was changed and why
- NEVER ignore prevention — every fix needs a "how to prevent recurrence" recommendation
- NEVER suppress errors to make the problem disappear

## Failure Modes

| Mode | Detection | Mitigation |
|------|-----------|------------|
| Shotgun debugging | Diff shows >3 unrelated changes | One hypothesis, one change, one verification cycle |
| Confirmation bias | Evidence log shows no alternative hypotheses | Require at least 2 hypotheses before fixing |
| Cascading misattribution | Fix doesn't prevent recurrence | Trace the full request path before diagnosing |
| Scope explosion | Investigation touches >10 files without narrowing | Refocus on the smallest reproducible case |

## Key Design Principles

- P10 Evidence Over Opinion — hypothesis + evidence, not intuition
- P4 Separate Planning from Execution — diagnose before fixing
- P9 Metacognitive Self-Awareness — know when you're uncertain, escalate
- P6 Context Is Finite — focus on relevant logs/traces, not everything
- P11 Map Failure Modes — investigators can misdiagnose

## Anti-Patterns

- Investigator that applies fixes without user approval
- Investigator that reads every log file instead of forming a targeted hypothesis
- Investigator that reports "couldn't reproduce" without documenting what was tried
- Investigator that fixes the symptom and closes the issue

## Goose Recipe Considerations

- **Extensions:** `developer` (Read/Glob/Grep/Bash for log analysis, reproduction, and test verification)
- **Parameters:** `bug_description` (required — symptoms and context), `suspected_location` (optional), `prior_attempts` (optional — what's already been tried)
- **Return format:** hypothesis, evidence_for, evidence_against, confidence, root_cause, fix_applied (diff), test_results, prevention_strategy
- **In pipelines:** Investigators are spawned on-demand when a build or review agent hits a repeated failure. They receive failure context and circuit breaker evidence as scoped input.
