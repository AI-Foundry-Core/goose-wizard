# Revert

Conductor reads this file when the user wants to undo implementation work.
Reverts are always plan-first: generate and display the plan, get typed
confirmation, then execute.

## Plan-First-Always Pattern

NEVER execute a revert without showing the plan first. Always:
1. Generate the revert plan (dry run)
2. Display it to the developer
3. Wait for typed confirmation
4. Execute only after confirmation

## Revert Granularity

Three levels of revert, from narrowest to broadest:

| Granularity | What It Reverts |
|---|---|
| `task` | All commits belonging to a single task (implementation + plan updates) |
| `phase` | All commits belonging to all tasks in one phase (including the checkpoint commit) |
| `track` | All commits belonging to all phases in the entire track |

## Step 1: Generate the Revert Plan

Call the `revert_by_unit` sub-recipe with `execute: false` and these inputs:
- `track_id`: the track to revert
- `kind`: `task`, `phase`, or `track`
- `unit_id`: the task ID (for task), phase number (for phase), or omit (for track)

The sub-recipe returns a plan containing:
- Ordered list of commits to revert (newest first)
- For each commit: SHA, subject line, which unit (task/phase) it belongs to
- List of files that will be affected
- Potential merge conflicts (if any)

## Step 2: Display the Plan

Present the plan clearly:

```
## Revert Plan

### Granularity: {task|phase|track}
### Target: {track_id} {unit detail}

### Commits to revert (newest first):

| # | SHA | Subject | Unit |
|---|---|---|---|
| 1 | def5678 | docs: update plan — task 2.3 complete | Task 2.3 |
| 2 | abc1234 | feat(auth): implement token refresh | Task 2.3 |
| 3 | 9876543 | docs: start task 2.3 — token refresh | Task 2.3 |

### Affected files:

- src/auth/tokens.py
- tests/test_tokens.py
- .goose/conductor/tracks/user-auth_20260416/plan.md

### Potential conflicts: none detected
```

If conflicts are detected, show them and warn:

```
### Potential conflicts:

- src/auth/tokens.py — modified by later commits outside this track
- WARNING: Manual conflict resolution may be required
```

## Step 3: Wait for Typed Confirmation

The confirmation string depends on the granularity. The developer must type
the EXACT string (case-sensitive).

| Granularity | Required confirmation string |
|---|---|
| Task | `revert {track_id} task {task_id}` |
| Phase | `revert {track_id} phase {phase_number}` |
| Track | `revert {track_id}` |

Examples:
- `revert user-auth_20260416 task 2.3`
- `revert user-auth_20260416 phase 2`
- `revert user-auth_20260416`

If the developer types anything else, do NOT execute. Ask them to confirm
with the exact string, or say "cancel" to abort.

## Step 4: Execute the Revert

After receiving the correct confirmation string, call `revert_by_unit` with
`execute: true` and:
- `track_id`, `kind`, `unit_id` — same as the plan step
- `live_confirmed` — set based on the conductor's kernel kind-gate (the
  kernel handles this; the skill does not make the determination)

## Step 5: Handle Execution Results

| Status | Action |
|---|---|
| `reverted` | Success. Proceed to Step 6. |
| `plan_only` | Should not occur after Step 4 (execute was true). Log error. |
| `conflicts_present` | Revert hit merge conflicts. Stop. Tell the developer they must resolve conflicts manually. Show which files conflict. |
| `unit_not_found` | The specified task, phase, or track has no matching commits. Stop. Explain what was searched and found nothing. |
| `history_drift` | Commit history has changed since the plan was generated (e.g., someone pushed). Stop. Tell the developer to re-run the plan step. |
| `dirty_working_tree` | Uncommitted changes exist. Stop. Tell the developer to commit or stash changes first, then retry. |

## Step 6: Post-Revert State Update

After a successful revert:

1. Re-read `plan.md` — reset affected task markers:
   - Reverted tasks: change from `[x]` back to `[ ]`
   - Remove SHA references from reverted tasks
   - If an entire phase was reverted, clear that phase's checkpoint row
2. Re-read `metadata.json` — update task counts and phase progress
3. Re-read `tracks.md` — update status if track-level revert changed it
4. Commit the state updates:
   ```
   docs: update plan — revert {kind} {unit_id}

   Track: {track_id}
   ```
5. Show the developer the updated state:
   - Which tasks are now pending again
   - Current phase and task counts
   - What to do next (e.g., "Phase 2 has been reverted. You can re-implement from Task 2.1.")
