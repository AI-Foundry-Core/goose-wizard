# Implementation

Conductor reads this file when implementing tasks from a track's plan.md.
This covers the TDD lifecycle, task loop, phase completion, and stop_after
modes.

## 11-Step TDD Lifecycle (Per Task)

Follow these steps in exact order for every task. Do not skip or reorder.

### Step 1: Select next pending task

Read `plan.md` and find the next `[ ]` task in the current phase. Select
tasks in order within the phase. Do not skip ahead to later phases.

### Step 2: Mark in-progress

Update `plan.md` to change the task marker from `[ ]` to `[~]`:

```markdown
- [~] **Task 2.1**: Implement user validation
```

Commit this change:
```
docs: start task 2.1 — {short description}

Track: {track_id}
```

### Step 3: RED — write failing tests

Write tests that define expected behavior BEFORE writing implementation:
- Create test file if needed
- Cover happy path, edge cases, and error conditions
- Run the tests — they MUST fail
- If tests pass without implementation, the tests are wrong. Fix them.

### Step 4: GREEN — implement minimum code

Write the minimum code to make all tests pass:
- Focus on making tests green, not perfection
- Avoid premature optimization
- Run tests — they MUST pass

### Step 5: REFACTOR — improve clarity

With green tests, improve the code:
- Extract common patterns
- Improve naming
- Remove duplication
- Simplify logic
- Run tests after EACH change — they must remain green

If refactoring breaks tests: revert to the GREEN state immediately. Record
`status: refactor_broke_green` and stop. Do not attempt to fix forward.

### Step 6: Verify coverage

Check test coverage meets the target (default: 80%):
- Identify uncovered lines
- Add tests for missing paths if below target
- Re-check until target is met or user decides to accept the gap

### Step 7: Document deviations

If the implementation deviated from the spec or plan:
- Note deviations as comments under the task in `plan.md`
- Update `spec.md` if requirements changed
- After adding new dependencies, update `tech-stack.md`

### Step 8: Commit implementation

Create a commit with this exact format:

```
{type}({scope}): {subject}

{body — bullet points of what changed}

Task: {task_id}
Track: {track_id}
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

Example:
```
feat(user): implement email validation

- Add validate_email method to User class
- Handle empty and malformed emails
- Add comprehensive test coverage

Task: 2.1
Track: user-auth_20260416
```

### Step 9: Attach git notes

Add a rich task summary as a git note on the implementation commit. Failure
to attach the note is non-fatal — log it and continue.

```
git notes add -m "Task 2.1: Implement user validation

Summary:
- Added email validation using regex pattern
- Handles edge cases: empty, no @, no domain
- Coverage: 94% on validation module

Files changed:
- src/models/user.py (modified)
- tests/test_user.py (modified)

Decisions:
- Used simple regex over email-validator library
- Reason: No external dependency for basic validation"
```

### Step 10: Update plan with SHA

Update `plan.md` to mark the task complete with the commit SHA:

```markdown
- [x] **Task 2.1**: Implement user validation `abc1234`
```

### Step 11: Commit plan update

```
docs: update plan — task 2.1 complete

Track: {track_id}
```

## stop_after Modes

The conductor's kernel sets a `stop_after` mode that controls how far
implementation proceeds before pausing for the developer.

| Mode | Behavior |
|---|---|
| `task` | Pause after completing every single task. Present results and wait. |
| `phase` | Run through all tasks in the current phase. Pause at checkpoint. |
| `track` | Continue through all phases, pausing only at each phase checkpoint for approval. |

When pausing, always show:
- What was just completed (task ID, SHA, test results)
- What comes next
- Current progress (tasks done / total in phase)

## Task Loop Status Routing

After completing each task's TDD cycle, the outcome determines what happens
next.

| Status | Action |
|---|---|
| `ok` | Task complete. Proceed to next task (or pause per stop_after mode). |
| `red_not_red` | Tests did not fail in the RED step. Coach the developer on writing proper failing tests. Re-attempt RED. |
| `green_unreachable` | Tests cannot be made to pass with reasonable effort. Stop. Ask the user whether to skip the task, revise the spec, or get help. |
| `refactor_broke_green` | Refactoring broke passing tests. Revert to GREEN state. Mark task `[~]` (still in-progress). Stop and explain what happened. |
| `coverage_gap` | Coverage is below the target after best effort. Show the gap (which lines, what percentage). Ask the user: accept the gap, or write more tests? |
| `blocked` | Task cannot proceed due to external dependency. Mark `[!]` with reason. Skip to next non-blocked task in the phase, or stop if all remaining tasks are blocked. |
| `deviation` | Implementation required changes to spec. Document the deviation (Step 7), then continue normally. |

## Phase Completion

When all tasks in a phase are marked `[x]` (complete), `[-]` (skipped), or
`[!]` (blocked with user acknowledgment):

1. Verify no `[ ]` or `[~]` tasks remain in the phase
2. Trigger checkpoint verification (see the verification skill)
3. Wait for checkpoint approval before starting the next phase

If any blocked `[!]` tasks exist, present them to the user and ask whether
to proceed to checkpoint with those tasks unresolved, or wait.

## Context Update Triggers

Certain implementation events require updating context artifacts:

| Event | Update |
|---|---|
| New dependency added | Update `tech-stack.md` with package, version, rationale |
| Feature completed (all acceptance criteria met) | Update `product.md` feature status |
| Workflow convention discovered/changed | Update `workflow.md` |
| Scope changed during implementation | Update `spec.md` scope section |

Make these updates as part of the task's implementation commit when possible,
or as a separate `docs:` commit immediately after.
