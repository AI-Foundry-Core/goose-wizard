# Status

Conductor reads this file when the user asks for project status, track
status, or a progress overview. This covers both the summary view and
detail mode.

## Status Display Flow

### Step 1: Read the registry

Read `.goose/conductor/tracks.md` to get the full list of tracks across
all sections (Active, Paused, Completed, Archived, Deleted).

### Step 2: Read active track details

For each track in the Active Tracks section:
1. Read `metadata.json` for progress numbers and timestamps
2. Read `plan.md` for task-level status markers

### Step 3: Optionally validate context artifacts

If the user asked for a thorough status or there are signs of staleness
(e.g., last updated timestamp is old), run the `context_validate` sub-recipe
to check artifact freshness and consistency. This returns findings like
stale artifacts, missing sections, or inconsistencies.

### Step 4: Compute and display

Assemble the output using the format below.

## Output Format

### Header

```
## Project Status: {project_name}

Kind: {live|sandbox|unknown}
Initialized: {yes|no}
Last activity: {date of most recent commit across all tracks}
```

### Blockers (show only if any exist)

```
### Blockers

- [!] **{track_id}** Task {task_id}: {blocker description}
- VALIDATION: {finding from context_validate, e.g., "tech-stack.md not updated in 14 days"}
- DUPLICATE: Tracks {track_a} and {track_b} appear to cover the same scope
```

If no blockers, omit this section entirely.

### Active Tracks

```
### Active Tracks

| Track | Type | Phase | Tasks | Last Checkpoint | Last Commit |
|---|---|---|---|---|---|
| {track_id} | feature | 2/3 | 8/12 done | 2026-04-15 | 2026-04-16 |
| {track_id} | bug | 1/2 | 2/5 done | — | 2026-04-16 |
```

- **Phase**: `{current}/{total}` (current = highest phase with any `[~]` or `[x]` task; if none started, show `0/{total}`)
- **Tasks**: `{completed}/{total} done` (count `[x]` markers)
- **Last Checkpoint**: date from most recent checkpoint row in plan.md, or `—` if none
- **Last Commit**: date of most recent commit referencing this track ID

### Paused Tracks

```
### Paused Tracks

| Track | Type | Paused Since | Reason |
|---|---|---|---|
| {track_id} | refactor | 2026-04-10 | Waiting for API redesign |
```

If none, omit this section.

### Recently Completed

Show the last 3-5 completed tracks:

```
### Recently Completed

| Track | Type | Completed | Duration |
|---|---|---|---|
| {track_id} | chore | 2026-04-12 | 2 days |
| {track_id} | feature | 2026-04-08 | 5 days |
```

If none, omit this section.

### Warnings

```
### Warnings

- product.md last updated 2026-03-28 (19 days ago) — may be stale
- tech-stack.md references `lodash@4.17.20` but package.json has `4.17.21`
- Track {track_id} has no activity in 7 days
```

Show only if there are findings from `context_validate` or observable
staleness. If none, omit.

### Recommendations

```
### Next Steps

- Track `{track_id}` has all Phase 2 tasks complete — ready for checkpoint verification
- Track `{track_id}` has 1 blocked task in Phase 1 — resolve blocker before continuing
- No active tracks — consider creating a new track
```

Always include at least one recommendation. Derive it from the current state:
- Phase ready for checkpoint? Say so.
- Blocked tasks? Flag them.
- All tracks complete? Suggest creating a new one.
- Stale artifacts? Suggest updating them.

## Detail Mode

When the user asks for detail on a specific track (e.g., "status of
user-auth_20260416" or "show me track details"), show task-level
information:

```
## Track Detail: {track_id}

**Title:** {title}
**Type:** {type}
**Status:** {status}
**Created:** {date}
**Started:** {date}

### Phase 1: {Phase Name} — COMPLETE

- [x] **Task 1.1**: Set up database schema `abc1234`
- [x] **Task 1.2**: Implement user model `def5678`
- [x] **Task 1.3**: Add validation logic `9876543`
- [x] **Verify 1.1**: Phase 1 verification `fff0001`

Checkpoint: `abc9999` (2026-04-15)

### Phase 2: {Phase Name} — IN PROGRESS

- [x] **Task 2.1**: Implement auth endpoints `111aaaa`
- [~] **Task 2.2**: Add token refresh
- [ ] **Task 2.3**: Rate limiting
- [!] **Task 2.4**: OAuth integration (blocked: waiting for provider credentials)

Checkpoint: pending

### Phase 3: {Phase Name} — PENDING

- [ ] **Task 3.1**: Integration tests
- [ ] **Task 3.2**: Documentation
- [ ] **Verify 3.1**: Final verification

Checkpoint: pending

### Dependencies

- None

### Tags

auth, security
```

Phase status labels:
- **COMPLETE**: all tasks `[x]` or `[-]`, checkpoint recorded
- **IN PROGRESS**: at least one `[~]` task, or some `[x]` but not all done
- **PENDING**: no tasks started yet
- **BLOCKED**: all remaining tasks are `[!]`
