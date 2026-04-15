# Progression State File Format

## Location

`~/.rilgoose/progression.json` — the canonical per-USER progression state file.
Progression travels with the developer across every codebase they train on; it
is NOT per-project. Created on first use of any module.

The legacy per-project location was `.goose/state/progression.json`. Recipes
migrate it automatically on first read this session: if the canonical file is
missing but the legacy file exists, move it (atomic: write tmp + rename) to
the canonical path and rename the legacy file to
`.goose/state/progression.json.migrated`. All subsequent reads and writes use
the canonical path.

## Schema

```json
{
  "developer_id": "auto-detected-or-asked",
  "last_updated": "2026-04-12T10:30:00Z",
  "stages": {
    "0": {
      "status": "complete",
      "completed_at": "2026-04-12T10:30:00Z"
    },
    "1": {
      "status": "in_progress",
      "concepts": {
        "1.1": {
          "recipe": "bug-fix",
          "status": "complete",
          "dimensions": {
            "context_quality": {
              "rating": "strong",
              "assessed_at": "2026-04-12T11:00:00Z"
            },
            "fix_verification": {
              "rating": "adequate",
              "assessed_at": "2026-04-12T11:00:00Z"
            },
            "redirect_on_struggle": {
              "rating": null,
              "note": "Not triggered — AI solved in first attempt"
            }
          }
        },
        "1.2": null,
        "1.3": null,
        "1.4": null
      }
    }
  }
}
```

## Rules

- A concept's status is `"complete"` when all required dimensions are Adequate or Strong
- A stage's status is `"complete"` when all concepts are complete
- Dimensions with `"rating": null` are conditional (not triggered) — they don't block completion
- The facilitator reads this at session start to know what to skip or revisit
- The teach-wrapper writes this after the eval subagent returns results
- Never overwrite a Strong rating with a lower one — track best rating per dimension
- If a developer re-runs a recipe (e.g., via `/teach`), update ratings only if they improved
- ALL writes go to `~/.rilgoose/progression.json`. Never write to the legacy
  per-project path. If you see the legacy file, migrate it once and move on.
