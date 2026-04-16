# Track Management

Conductor reads this file when the user wants to create a new track,
manage the track registry, or perform lifecycle operations (archive,
restore, delete, rename, cleanup).

## Track Types

| Type | When to Use |
|---|---|
| `feature` | New functionality: user-facing features, API endpoints, integrations, significant enhancements |
| `bug` | Defect fixes: incorrect behavior, error conditions, performance regressions, security vulnerabilities |
| `chore` | Maintenance: dependency updates, configuration changes, documentation updates, cleanup tasks |
| `refactor` | Code improvement without behavior change: restructuring, pattern adoption, tech debt reduction, performance optimization with same behavior |

## Track ID Format

Pattern: `{shortname}_{YYYYMMDD}`

- **shortname**: 2-4 word kebab-case description
- **YYYYMMDD**: UTC creation date

Examples: `user-auth_20260416`, `fix-login-error_20260416`, `upgrade-deps_20260416`

## Creating a New Track — Interactive Q&A Flow

Follow these steps in order. Do not skip steps.

### Step 1: Determine track type

If the user already stated the type (feature, bug, chore, refactor), use it.
Otherwise ask:

> What type of track is this? (feature / bug / chore / refactor)

### Step 2: Get shortname

Ask:

> Give a short kebab-case name for this track (2-4 words, e.g., `user-auth`, `fix-cart-total`).

Validate: lowercase, hyphens only, 2-4 words. Reject and re-ask if invalid.

### Step 3: Get title

Ask:

> One-line title describing what this track accomplishes.

### Step 4: Get requirements brief

Ask:

> Describe the requirements in a few sentences. What needs to happen, what are the acceptance criteria, what's in scope vs out of scope?

If the response is vague (fewer than two concrete requirements or no testable criteria), refine:

> That's a bit vague. Can you be more specific about:
> 1. What exactly needs to change?
> 2. How will you know it's done?
> 3. What's explicitly NOT in scope?

Allow up to 3 refinement attempts. If still vague after 3, stop and tell the user:

> I don't have enough detail to write a good spec. Please think through the requirements and come back with specific acceptance criteria.

### Step 5: Ask about phases (optional)

> Do you have specific phases in mind, or should I break this down based on the requirements? (Describe phases, or say "auto")

### Step 6: Ask about dependencies (optional)

> Does this track depend on any other tracks, external APIs, or pending decisions? (List them, or say "none")

### Step 7: Generate artifacts

Generate all four artifacts in this order:
1. `spec.md` — from the requirements brief
2. `plan.md` — from the spec, with phases and tasks
3. `metadata.json` — initial metadata
4. `index.md` — track dashboard

Present each to the user for review before writing to disk.

### Step 8: Register the track

1. Create the track directory: `.goose/conductor/tracks/{track_id}/`
2. Write all four artifacts into that directory
3. Add the track to `.goose/conductor/tracks.md` under Active Tracks
4. Confirm creation to the user

## Artifact Templates

### spec.md

```markdown
# {Track Title}

## Overview

{Brief description of what this track accomplishes and why.}

## Functional Requirements

### FR-1: {Requirement Name}

{Description of the functional requirement.}

- Acceptance: {How to verify this requirement is met}

### FR-2: {Requirement Name}

{Description.}

- Acceptance: {Verification method}

## Non-Functional Requirements

### NFR-1: {Requirement Name}

{Description of the non-functional requirement (performance, security, etc.)}

- Target: {Specific measurable target, e.g., "response < 200ms"}
- Verification: {How to test against the target}

## Acceptance Criteria

- [ ] {Criterion 1: specific, testable condition}
- [ ] {Criterion 2: specific, testable condition}
- [ ] {Criterion 3: specific, testable condition}

## Scope

### In Scope

- {Explicitly included item}
- {Feature to implement}
- {Component to modify}

### Out of Scope

- {Explicitly excluded item}
- {Future consideration}
- {Related but separate work}

## Dependencies

### Internal

- {Other tracks or components this depends on}
- {Required context artifacts}

### External

- {Third-party services or APIs}
- {External dependencies}

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| {Risk description} | High/Medium/Low | {Mitigation strategy} |

## Open Questions

- [ ] {Question that needs resolution}
```

### plan.md

```markdown
# Implementation Plan: {Track Title}

Track ID: `{track_id}`
Created: {YYYY-MM-DD}
Status: pending

## Overview

{Brief description of implementation approach.}

## Phase 1: {Phase Name}

### Tasks

- [ ] **Task 1.1**: {Task description}
- [ ] **Task 1.2**: {Task description}
- [ ] **Task 1.3**: {Task description}

### Verification

- [ ] **Verify 1.1**: {Verification step for this phase}

## Phase 2: {Phase Name}

### Tasks

- [ ] **Task 2.1**: {Task description}
- [ ] **Task 2.2**: {Task description}

### Verification

- [ ] **Verify 2.1**: {Verification step for this phase}

## Checkpoints

| Phase | Checkpoint SHA | Date | Status |
|---|---|---|---|
| Phase 1 | | | pending |
| Phase 2 | | | pending |
```

### metadata.json

```json
{
  "id": "{track_id}",
  "title": "{Track Title}",
  "type": "feature|bug|chore|refactor",
  "status": "pending",
  "priority": "medium",
  "created": "YYYY-MM-DDTHH:MM:SSZ",
  "updated": "YYYY-MM-DDTHH:MM:SSZ",
  "started": null,
  "completed": null,
  "assignee": null,
  "phases": {
    "total": 0,
    "current": 0,
    "completed": 0
  },
  "tasks": {
    "total": 0,
    "completed": 0,
    "in_progress": 0,
    "pending": 0
  },
  "checkpoints": [],
  "dependencies": [],
  "tags": []
}
```

Populate `phases.total` and `tasks.total`/`tasks.pending` from the generated plan. Set `created` and `updated` to current UTC timestamp.

### index.md

```markdown
# {Track Title}

**Track ID:** `{track_id}`
**Type:** {type}
**Status:** pending
**Created:** {YYYY-MM-DD}

## Summary

{One-paragraph summary from spec overview.}

## Files

- [Specification](spec.md)
- [Implementation Plan](plan.md)
- [Metadata](metadata.json)

## Quick Status

| Metric | Value |
|---|---|
| Phase | 0 / {total_phases} |
| Tasks Done | 0 / {total_tasks} |
| Last Checkpoint | — |
| Last Commit | — |
```

## Status Markers

Use these markers consistently in plan.md:

| Marker | Meaning | Usage |
|---|---|---|
| `[ ]` | Pending | Task not started |
| `[~]` | In Progress | Currently being worked |
| `[x]` | Complete | Task finished (include SHA) |
| `[-]` | Skipped | Intentionally not done (include reason) |
| `[!]` | Blocked | Waiting on dependency (include blocker) |

Examples:
```
- [x] **Task 1.1**: Set up database schema `abc1234`
- [~] **Task 1.2**: Implement user model
- [ ] **Task 1.3**: Add validation logic
- [!] **Task 1.4**: Integrate auth service (blocked: waiting for API key)
- [-] **Task 1.5**: Legacy migration (skipped: not needed)
```

## Track Registry — tracks.md

Located at `.goose/conductor/tracks.md`. Contains five sections, each with
its own table.

```markdown
# Track Registry

## Active Tracks

| Track | Type | Status | Phase | Started | Assignee |
|---|---|---|---|---|---|
| [{track_id}](tracks/{track_id}/) | feature | in-progress | 2/3 | 2026-04-16 | @developer |

## Paused Tracks

| Track | Type | Paused Since | Reason |
|---|---|---|---|
| [{track_id}](tracks/{track_id}/) | refactor | 2026-04-10 | Waiting for API redesign |

## Completed Tracks

| Track | Type | Completed | Duration |
|---|---|---|---|
| [{track_id}](tracks/{track_id}/) | chore | 2026-04-12 | 2 days |

## Archived Tracks

| Track | Reason | Archived |
|---|---|---|
| [{track_id}](_archive/{track_id}/) | Superseded | 2026-04-05 |

## Deleted Tracks

| Track ID | Reason | Deleted |
|---|---|---|
| old-feature_20260301 | Requirements changed, work discarded | 2026-04-08T14:30:00Z |
```

When a section has no entries, keep the table header row but leave the body
empty. Never remove a section.

## Track Lifecycle Operations

### Archive

1. Move the track directory from `tracks/{track_id}/` to `_archive/{track_id}/`
2. Update `tracks.md`: remove from Active (or Paused or Completed), add to Archived with reason and date
3. Update `metadata.json`: set `status` to `"archived"`, update `updated` timestamp

### Restore

Reverse of archive:
1. Move from `_archive/{track_id}/` back to `tracks/{track_id}/`
2. Update `tracks.md`: remove from Archived, add back to Active (or previous section)
3. Update `metadata.json`: restore previous status, update `updated` timestamp

### Delete

Destructive operation — the conductor's kernel handles the kind-gate confirmation.

1. Remove the track directory from disk entirely
2. Remove the entry from whichever section of `tracks.md` it was in
3. Add an entry to the Deleted Tracks section with: track ID (plain text, no link), reason, UTC timestamp

### Rename

1. Create the new track directory `tracks/{new_track_id}/`
2. Move all files from the old directory to the new one
3. Update every reference inside the moved files: track ID in `plan.md` header, `metadata.json` id field, `index.md` header
4. Update `tracks.md`: change the link and track ID in the appropriate section
5. Record the mapping in `metadata.json`: add `"renamed_from": "{old_track_id}"` field
6. Remove the old empty directory

### Cleanup Audit

Check for two kinds of orphans:

1. **Disk without registry**: directories under `tracks/` that have no matching row in any `tracks.md` section. Report each with path and whether it contains valid artifacts.
2. **Registry without disk**: rows in `tracks.md` whose link target does not exist on disk. Report each with the track ID and which section it was in.

Present findings to the user. Do not auto-fix — the user decides what to do
with each orphan.
