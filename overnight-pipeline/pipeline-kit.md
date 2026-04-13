# Pipeline Kit — Run Any Series of Goose Recipes Overnight

## What This Is

A deterministic Python script that runs Goose recipes in a loop. You list your recipes, set a max cycle count, and run it. The script calls `goose run` for each recipe, checks for a stop signal, and repeats. No LLM in the loop — pure automation.

## Quick Start (5 minutes)

### 1. Create a config folder

```bash
mkdir overnight-pipeline/configs/my-run
```

### 2. Create cycle.md — your recipe checklist

```markdown
# Cycle Steps

| Step | Recipe | Timeout | Name |
|------|--------|---------|------|
| 1 | recipes/stage-1/bug-fix.yaml | 300 | bug-fix |
| 2 | recipes/stage-1/test-writer.yaml | 300 | test-writer |
| 3 | recipes/stage-1/code-review.yaml | 300 | code-review |
```

### 3. Copy state.json

```bash
cp overnight-pipeline/templates/state.json overnight-pipeline/configs/my-run/
```

Edit `max_cycles` to your desired count.

### 4. Run it

```bash
python overnight-pipeline/pipeline_runner.py overnight-pipeline/configs/my-run/
```

That's it. The script runs until max_cycles or a recipe writes STOP.md.

## How It Works

```
pipeline_runner.py (Python — deterministic)
  └─ Reads cycle.md for recipe list
  └─ Reads state.json for current progress
  └─ For each cycle:
      └─ Calls goose run recipe-1.yaml
      └─ Calls goose run recipe-2.yaml
      └─ Calls goose run recipe-3.yaml
      └─ Checks for STOP.md
      └─ Updates state.json
      └─ Sleeps, repeats
```

- Every recipe runs through **real Goose** — extensions, subagents, Codex (via codex-acp), everything.
- The Python script just calls `goose run` and manages the sequence. No AI decisions.
- Any recipe can halt the pipeline by writing a `STOP.md` file.

## Config Files

Each run is a folder with 2-3 files:

| File | Required | What It Does |
|------|----------|-------------|
| `cycle.md` | Yes | Lists recipes to run each cycle (markdown table) |
| `state.json` | Yes | Pipeline state: current cycle, max cycles, status |
| `schedule.md` | No | Per-cycle variation: what changes each cycle (persona, target, etc.) |

### cycle.md

A markdown table. Each row is a recipe to run. Order matters — they run top to bottom.

| Column | What It Is |
|--------|-----------|
| Step | Execution order (1, 2, 3...) |
| Recipe | Path to Goose recipe YAML |
| Timeout | Max seconds before step is killed |
| Name | Short name for output files |

### schedule.md (optional)

A markdown table with per-cycle params. Each column header becomes a recipe parameter.

```markdown
| Cycle | Persona | Teaching Script |
|-------|---------|----------------|
| 1 | priya_eager | stage-2/review-gate |
| 2 | vikram_senior | stage-3/parallel-reviewers |
```

If absent, every cycle runs identically.

### state.json

```json
{
  "current_cycle": 1,
  "max_cycles": 15,
  "status": "ready",
  "sleep_seconds": 30,
  "completed_cycles": [],
  "consecutive_failures": 0
}
```

## Writing Pipeline-Compatible Recipes

Any Goose recipe can run in the pipeline. To participate in the data flow:

### Receiving params
Every recipe automatically gets `run_dir` (config folder path) and `cycle_number` (current cycle). Plus any schedule.md columns for this cycle. Declare them in your recipe's `parameters:` section.

### Writing output
Write your output to: `{{ run_dir }}/cycle-{{ cycle_number }}/YOUR-NAME-output.md`

### Reading prior step output
Read from the same cycle directory: `{{ run_dir }}/cycle-{{ cycle_number }}/STEP-NAME-output.md`

### Stopping the pipeline
Write a file called `STOP.md` in the `{{ run_dir }}` directory:
```markdown
# Pipeline Stop
Reason: Your reason here.
Stopped by: your-recipe-name (cycle N)
```

## Checking Progress

- **Is it running?** Check `state.json` → `last_heartbeat` timestamp
- **What cycle?** Check `state.json` → `current_cycle`
- **Any failures?** Check `state.json` → `consecutive_failures` or look for `*-error.md` files in cycle directories
- **Did it stop?** Check for `STOP.md` in the config directory, or `state.json` → `status: "complete"`

## Crash Recovery

If the script crashes (power failure, terminal closed, etc.):

```bash
# Same command — it reads state.json and picks up where it left off
python overnight-pipeline/pipeline_runner.py overnight-pipeline/configs/my-run/
```

## Circuit Breaker

3 consecutive recipe failures → the script writes STOP.md and halts. This prevents burning cycles on a broken recipe.

## Example Pipelines

### Simple: Run 3 recipes 5 times
```
cycle.md: 3 recipes
state.json: max_cycles = 5
No schedule.md needed
```

### Hardening: Test teaching scripts with different personas
```
cycle.md: simulate → evaluate → classify → apply-fixes → plan-next
schedule.md: 9 rows with different personas/recipes
state.json: max_cycles = 15
```

### Audit: Review all teaching scripts for consistency
```
cycle.md: audit-script → log-findings
schedule.md: one row per teaching script
state.json: max_cycles = (number of scripts)
```
