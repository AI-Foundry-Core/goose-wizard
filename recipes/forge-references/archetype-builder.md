# Archetype: Builder

## What This Archetype Does

Implements code changes within strict file ownership boundaries, following a spec or interface contract. Produces working, tested code that integrates through defined interfaces. Reports structured results.

**RIL agent examples:** `agent-teams/team-implementer.md`, `code-refactoring/legacy-modernizer.md`

---

## Key Patterns

- **File ownership protocol:** "Only modify files assigned to you." Interface contracts are immutable — don't implement the other side.
- **Phase workflow:** Understand assignment → Plan implementation → Build → Verify → Report. Each phase has concrete actions.
- **Integration point discipline:** Reference the contract, stub/mock adjacent components, message on completion.
- **Strangler fig pattern:** Incremental replacement — never break existing functionality without a migration path.

## Critical Constraints

- NEVER modify files outside ownership boundary
- NEVER change interface contracts without lead approval
- NEVER implement beyond the spec — note improvements but don't act
- NEVER skip verification (compile, lint, test) before reporting complete
- NEVER suppress errors to make tests pass

## Failure Modes

| Mode | Detection | Mitigation |
|------|-----------|------------|
| Boundary violation | Diff shows changes outside assigned directories | Route to coordinator instead of self-modifying |
| Spec drift | deviations_from_spec field is non-empty | Require explicit approval for any deviation |
| Integration mismatch | Type errors at integration points | Re-read contract before implementation begins |
| Silent failure | Tests pass but behavior changed | Require behavioral diff review alongside code diff |

## Key Design Principles

- P4 Separate Planning from Execution — plan phase before build phase
- P5 Define Success Before Starting — acceptance criteria from spec
- P2 Constraints Are Features — file ownership boundaries
- P8 Teams Need Coordination Protocols — interface contracts
- P12 Graceful Shutdown — report status even if blocked

## Anti-Patterns

- Builder that also reviews its own work (self-verification bias)
- Builder with write access to the entire repo
- Builder that receives unstructured narrative instead of a spec contract
- Builder that refactors adjacent code "while it's there"

## Goose Recipe Considerations

- **Extensions:** `developer` (full — needs Read/Write/Edit/Bash for implementation)
- **Parameters:** `task_spec` (required — the spec contract), `file_ownership` (optional — which files to touch), `test_command` (optional)
- **Return format:** changed_files, implementation_summary, test_commands_run, test_results, deviations_from_spec
- **In pipelines:** Subject to retry limit (2) and circuit breaker (3 same-failure halts). Receives validated spec contract as JSON from upstream.
