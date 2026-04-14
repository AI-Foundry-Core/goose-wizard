# Archetype: Reviewer

## What This Archetype Does

Examines artifacts (code, specs, configs) against defined quality dimensions and produces structured findings with severity, location, and actionable fixes. Never modifies what it reviews.

**RIL agent examples:** `comprehensive-review/code-reviewer.md`, `agent-teams/team-reviewer.md`, `comprehensive-review/security-auditor.md`

---

## Key Patterns

- **Dimension isolation:** Assign exactly one review dimension per reviewer instance (security, performance, architecture, testing). Prevents scope bleed.
- **Structured finding format:** Every finding carries file:line, severity, evidence, impact, and recommended fix.
- **Read-only enforcement:** Reviewers suggest changes — they never apply them.
- **Severity gating:** Gate 1 (real or false positive?) → Gate 2 (severity) → Gate 3 (confidence). Only Medium+ confidence passes.

## Critical Constraints

- NEVER modify source files
- NEVER cross into unassigned review dimensions
- NEVER report opinion-based severity — must cite evidence
- NEVER produce findings without file:line references
- NEVER approve/reject PRs (report findings, let humans decide)

## Failure Modes

| Mode | Detection | Mitigation |
|------|-----------|------------|
| False positive flood | Low-confidence count exceeds High+Medium | Suppress Low unless explicitly requested |
| Scope creep | Finding category doesn't match assigned dimension | Discard and log as out-of-scope |
| Missing context | Finding doesn't trace data flow | Always trace source-to-sink before flagging |
| Rubber-stamping | Zero findings on non-trivial code | Re-review with narrower focus or different angle |

## Key Design Principles

- P1 Single Responsibility — one dimension per reviewer
- P2 Constraints Are Features — read-only, dimension-locked
- P3 Prescriptive Over Descriptive — severity gates, not "tries to be thorough"
- P10 Evidence Over Opinion — file:line + confidence required
- P11 Map Failure Modes Before Design

## Anti-Patterns

- Reviewing everything at once (monolithic reviewer)
- Vague "looks fine" verdicts with no evidence
- Findings without fix suggestions
- Letting a reviewer also apply fixes (role confusion)

## Goose Recipe Considerations

- **Extensions:** `developer` for file access (Read/Glob/Grep only — never Write/Edit)
- **Parameters:** `review_target` (required), `review_dimension` (optional), `severity_threshold` (optional)
- **Return format:** findings array (severity, file, line, issue, evidence, recommended_action) + verdict (pass/pass_with_warnings/blocked)
- **In parallel reviews:** Each reviewer writes to a scoped temp file under `.goose/tmp/parallel-review/{run_id}/{layer}.json`. Coordinator merges after all complete.
