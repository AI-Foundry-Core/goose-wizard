# Progression State File Format

## Location

`~/.goose-wizard/progression.json` — the canonical per-USER progression state file.
Progression travels with the developer across every codebase they train on; it
is NOT per-project. Created on first use of any module.

The legacy per-project location was `.goose/state/progression.json`. Recipes
migrate it automatically on first read this session: if the canonical file is
missing but the legacy file exists, COPY it (atomic: write tmp + rename) to
the canonical path, verify it's readable, then rename the legacy file to
`.goose/state/progression.json.migrated`. All subsequent reads and writes use
the canonical path. (See `recipes/agents/progression/migrate-progression.yaml`
for the shared helper and `recipes/RECIPE-PREAMBLE.md`'s Progression State
Stanza for the inline fallback every training recipe uses.)

## Schema

The file is a flat object with a top-level `sequence` array of 26 module
entries. This is the real schema used by `graduate-module` and
`check-progress`; the `install/project-template/.goose/state/progression.json`
template is the canonical seed.

```json
{
  "schema_version": 1,
  "developer_id": "pending",
  "modules_total": 26,
  "modules_completed": 0,
  "current_module": 1,
  "last_updated": null,
  "sequence": [
    {
      "number": 1,
      "concept": "0.1",
      "stage": 0,
      "recipe": "see-what-ai-can-do",
      "title": "See What AI Can Do",
      "status": "not_started",
      "completed_at": null
    },
    {
      "number": 2,
      "concept": "1.1",
      "stage": 1,
      "recipe": "bug-fix",
      "title": "Bug Fix",
      "status": "not_started",
      "completed_at": null
    }
    // ... 24 more entries, through { number: 26, concept: "7.3", ... }
  ]
}
```

### Top-level fields

| Field                | Type           | Purpose                                                                                                              |
| -------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------- |
| `schema_version`     | integer        | Schema version. Currently `1`. Bump on breaking changes.                                                             |
| `developer_id`       | string         | `"pending"` until Start Here asks the developer.                                                                     |
| `modules_total`      | integer        | Constant `26` in v1.                                                                                                  |
| `modules_completed`  | integer        | Derived count of entries where `status == "complete"`. Writers must recompute on every write.                         |
| `current_module`     | integer        | `number` of the current / most recently touched entry. Advances when the next entry moves to `in_progress`.          |
| `last_updated`       | string or null | ISO 8601 UTC timestamp (e.g. `2026-04-15T17:30:42Z`). Updated on every write.                                         |
| `sequence`           | array          | 26 entries. Indexed 0 to 25; `number` matches `index + 1`.                                                            |

### `sequence` entry fields

| Field          | Type           | Values                                                                                                                  |
| -------------- | -------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `number`       | integer        | 1 to 26. Matches the training-recipe filename prefix (`01-see-what-ai-can-do.yaml`).                                     |
| `concept`      | string         | Dotted curriculum concept ID (e.g. `"0.1"`, `"1.3"`, `"5.6"`). Matches the syllabus.                                    |
| `stage`        | integer        | 0 to 7.                                                                                                                 |
| `recipe`       | string         | Slug matching the agent primitive / graduated recipe filename (`"bug-fix"`, `"build-then-test"`, etc.).                 |
| `title`        | string         | Human-readable module title.                                                                                            |
| `status`       | string         | One of `"not_started"`, `"in_progress"`, `"complete"`.                                                                 |
| `completed_at` | string or null | ISO 8601 UTC timestamp when status flipped to `complete`; `null` otherwise.                                             |

## Rules

- **Advancement is sequence-index-based.** `graduate-module` finds the entry
  at `sequence[module_number - 1]` and verifies the entry's `recipe` slug
  matches the `module_name` argument. Mismatches fail loudly.
- **Next-incomplete search scans the full array.** `graduate-module`
  step 9 scans `sequence[0..]` for the first entry with
  `status != "complete"`. This handles out-of-order completion (if a
  developer jumps ahead and graduates module 5 before 4, the next-module
  pointer still points back at 4).
- **A module's `status` is `"complete"` when the eval subagent returns
  overall pass.** There are no per-dimension rating fields in the file.
  The eval subagent's per-dimension ratings are evaluated inside the
  teaching-script session and rolled up into a single `complete` / not
  decision by the facilitator before writing.
- **Best-rating-so-far is tracked elsewhere.** The file above carries only
  coarse status. Per-dimension ratings, if the teaching model wants to
  record them for future analysis, belong in a separate artifact (not yet
  designed — do not add nested `dimensions` to this schema without an
  explicit migration).
- **`modules_completed` is derived.** Recompute from the array on every
  write. Never trust a stale value.
- **All writes atomic per `recipes/RECIPE-PREAMBLE.md`'s Backup Rotation
  Convention.** Write `progression.json.tmp` in the same directory, back up
  the existing file as `progression.json.bak.<UTC compact timestamp>`
  (format `YYYYMMDDTHHMMSSZ`), then rename `.tmp` → canonical.
- **Never write to the legacy path.** Even if you see
  `.goose/state/progression.json` in the project, do not write to it.
  Migrate once (copy → rename legacy to `.migrated`) on first read, then
  only touch the canonical per-user file.

## Historical note

An earlier draft of this document described a nested
`stages[].concepts[].dimensions[]` structure. That structure was never
implemented. The real code (`graduate-module.yaml`, `check-progress.yaml`,
and the seeded template) uses the flat `sequence` array documented above.
This file was reconciled with the real schema on 2026-04-15.
