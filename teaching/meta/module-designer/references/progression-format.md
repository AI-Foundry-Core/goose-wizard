# Progression State File Format

## Location

`.goose/state/progression.json` in the project directory. Read at session start, written after eval completes.

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
