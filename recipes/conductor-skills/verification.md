# Verification

Conductor reads this file when running checkpoint verification at the end
of a phase. This covers the full verification flow, gate details, baseline
SHA resolution, and the approval protocol.

## Checkpoint Verification Flow

Follow these steps in exact order. Do not skip any step.

### Step 1: Confirm phase completeness

Read `plan.md` and check every task in the current phase. If any task is
marked `[ ]` (pending) or `[~]` (in-progress), stop immediately.

Return `status: phase_incomplete` with a list of the unfinished tasks.
Do not proceed to verification.

Tasks marked `[!]` (blocked) are acceptable only if the user has already
acknowledged them during implementation. If unacknowledged blocked tasks
exist, stop and ask.

### Step 2: Resolve baseline SHA

The baseline SHA is the starting point for "what changed in this phase."

Resolution order:
1. Look in the Checkpoints table in `plan.md` for the previous phase's
   checkpoint SHA. If found, use it.
2. If this is Phase 1 (no previous checkpoint), find the oldest
   `docs: start task` commit that references this track ID. Use that
   commit's parent.
3. If no track commits exist at all, use `HEAD` (meaning: verify
   everything currently in the working tree).

### Step 3: Run automated gates

Call the `checkpoint_verify` sub-recipe with these inputs:
- `track_id`: the current track ID
- `phase`: the phase number being verified
- `last_checkpoint_sha`: the baseline SHA from Step 2

The sub-recipe runs four automated gates and returns results for each.

### Step 4: Interpret gate results

The four gates and what they return:

#### Tests

- **Command**: project's test runner (e.g., `pytest -v --tb=short`)
- **Pass condition**: exit code 0
- **Results**: total tests, passed, failed, errors, skipped
- **Failure detail**: names of failing tests with error messages

#### Coverage

- **Command**: coverage tool (e.g., `pytest --cov=src --cov-report=term-missing`)
- **Pass condition**: coverage percentage >= target (default 80%)
- **Results**: overall percentage, per-file percentages, uncovered lines
- **Failure detail**: files below target with line numbers

#### Lint

- **Command**: project's linter (e.g., `ruff check src/ tests/`)
- **Pass condition**: zero errors (warnings are acceptable)
- **Results**: error count, warning count
- **Failure detail**: each error with file, line, rule, message

#### Type Check

- **Command**: type checker (e.g., `mypy src/`)
- **Pass condition**: zero errors
- **Results**: error count
- **Failure detail**: each error with file, line, message

If a gate's tool is not configured for the project (no linter, no type
checker), that gate is marked `skipped` — not `failed`.

### Step 5: Present results to the developer

Display results clearly. Use this format:

```
## Checkpoint Verification — Phase {N}: {Phase Name}

### Automated Gates

| Gate | Status | Detail |
|---|---|---|
| Tests | PASS (47/47) | All tests passing |
| Coverage | PASS (87%) | Target: 80% |
| Lint | PASS (0 errors) | 3 warnings (acceptable) |
| Type Check | SKIPPED | No type checker configured |

### Summary

3 of 3 active gates passed. 1 gate skipped.
```

### Step 6: Handle gate failures

If ANY gate returned `FAIL`, show the specifics and stop.

```
### FAILED: Tests

2 tests failed:
- test_user_validation.py::test_empty_email — AssertionError: expected False, got True
- test_user_validation.py::test_unicode_email — UnicodeDecodeError

Fix these failures before checkpoint can proceed.
```

Do NOT proceed to manual verification. Do NOT ask for approval.
The developer must fix the failures and re-run verification.

### Step 7: Present manual verification checklist

Only reached when all automated gates pass (or are skipped).

The `checkpoint_verify` sub-recipe returns a manual verification checklist
derived from the phase's verification tasks in `plan.md`. Present it:

```
### Manual Verification

Please verify each item and type exactly "approved" when done.

- [ ] {Verification item 1 from plan.md}
- [ ] {Verification item 2 from plan.md}
- [ ] {Verification item 3 from plan.md}
```

### Step 8: Wait for approval

Wait for the developer to type exactly `approved` (case-sensitive, exact
match, no extra text).

- `approved` — proceed to Step 9
- Anything else — treat as feedback. Ask what needs to change. Do not
  proceed.

The conductor's kernel enforces this gate. Do not bypass it.

### Step 9: Create checkpoint commit

After approval, create the checkpoint commit:

```
chore(checkpoint): phase {N} complete — {track_title}

Verified:
- Tests: {count} passing
- Coverage: {percent}%
- Lint: {error_count} errors
- Type check: {error_count} errors
- Manual verification: approved

Phase {N} tasks:
- [x] Task {N}.1: {description}
- [x] Task {N}.2: {description}
- [-] Task {N}.3: {description} (skipped)

Track: {track_id}
```

Include all tasks in the phase with their final status markers.

### Step 10: Update checkpoints table

Update the Checkpoints table in `plan.md`:

```markdown
| Phase | Checkpoint SHA | Date | Status |
|---|---|---|---|
| Phase 1 | abc1234 | 2026-04-16 | verified |
| Phase 2 | def5678 | 2026-04-16 | verified |
| Phase 3 | | | pending |
```

### Step 11: Commit plan update

```
docs: update plan — phase {N} checkpoint recorded

Track: {track_id}
```

## Checkpoint Rejection

If the developer does not type `approved` and instead reports issues:

1. Note the rejection reason as a comment in `plan.md` under the phase's
   verification section
2. Create new tasks in the current phase to address the issues
3. Return to implementation (the implementation skill handles the new tasks)
4. When the new tasks are complete, re-run this verification flow from Step 1
