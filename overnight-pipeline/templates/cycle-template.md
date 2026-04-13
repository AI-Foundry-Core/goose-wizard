# Cycle Steps

List the recipes to run each cycle, in order. The pipeline runner calls `goose run` on each one.

| Step | Recipe | Timeout | Name |
|------|--------|---------|------|
| 1 | path/to/first-recipe.yaml | 300 | first-recipe |
| 2 | path/to/second-recipe.yaml | 300 | second-recipe |
| 3 | path/to/third-recipe.yaml | 300 | third-recipe |

**Columns:**
- **Step** — Execution order (1, 2, 3...)
- **Recipe** — Path to the Goose recipe YAML (relative to project root)
- **Timeout** — Max seconds before the step is killed (default: 600)
- **Name** — Short name used for output files (e.g., `cycle-1/first-recipe-output.md`)

**Every recipe receives these params automatically:**
- `run_dir` — path to the config directory (where cycle outputs go)
- `cycle_number` — which cycle is running (1, 2, 3...)
- Plus any columns from schedule.md for this cycle
