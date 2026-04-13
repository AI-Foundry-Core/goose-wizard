# Handoff: Adapt Pipeline to Native Goose Recipe

**Date:** 2026-04-13
**Status:** Paused — resume when ready to convert the pipeline from Python script to Goose-native
**Prerequisites:** Goose app set up and working, at least one recipe tested manually

---

## What Exists Today

A pipeline kit was built with a **deterministic Python script** (`overnight-pipeline/pipeline_runner.py`) that calls `goose run` for each recipe in a sequence. It works but is external to Goose — the team has to run it from a terminal, not from the Goose app.

### Files built:
- `overnight-pipeline/pipeline_runner.py` — the Python loop (~200 lines)
- `overnight-pipeline/recipes/` — 6 Goose YAML recipes (simulate-session, evaluate-transcript, classify-findings, apply-fixes, plan-next-cycle, summarize-run)
- `overnight-pipeline/configs/tonight-untested/` — config for 9 untested recipes
- `overnight-pipeline/pipeline-kit.md` — instructions
- `overnight-pipeline/templates/` — cycle.md, schedule.md, state.json templates

### Known bugs in the Python script (not yet fixed):
1. **`cwd=config_dir` breaks recipe paths** — recipe paths in cycle.md are project-root relative but the runner sets cwd to the config directory. Goose would look in the wrong place.
2. **Runner never reads planner output** — plan-next-cycle writes decisions but the runner doesn't consume them. Cycles past the schedule length run with empty params.

---

## What Needs to Happen

Convert the pipeline from "Python script calling `goose run`" to "one Goose recipe with sub-recipes, triggered by Goose's built-in scheduler."

### Target Architecture

```
goose schedule add --schedule-id overnight --cron "0 22 * * *" --recipe-source overnight-pipeline/pipeline.yaml
```

One parent recipe (`pipeline.yaml`) that:
1. Reads state.json to determine current cycle
2. Calls sub-recipes in sequence (simulate → evaluate → classify → fix → plan)
3. Checks for STOP.md after each sub-recipe
4. Updates state.json
5. If more cycles remain, the recipe could potentially re-invoke itself or the scheduler runs it again

### Key Design Questions to Resolve

1. **Single run vs multi-cycle:** Does the parent recipe run ONE cycle per scheduled invocation (scheduler runs it every 30 min, recipe does one cycle each time)? Or does it loop internally for all cycles in one invocation? The scheduler spawns a fresh agent each time, so internal looping means one long-running agent. External scheduling means many short agents with state handoff via state.json.

2. **Sub-recipe chaining:** Goose sub-recipes return results to the parent. Can the parent read the result from sub-recipe A and pass it to sub-recipe B? Or do they communicate through files like the Python script does?

3. **STOP convention:** In the Python script, recipes write STOP.md and the script checks for it. In a Goose-native pipeline, can a sub-recipe signal the parent to stop? Or does the parent check for STOP.md between sub-recipe calls?

4. **Codex integration:** The evaluate-transcript recipe needs to run twice — once with Opus, once with Codex. Can a single parent recipe invoke the same sub-recipe twice with different `model` params? Research: `delegate(model: "codex-acp/default")` syntax.

5. **State management:** The parent recipe reads/writes state.json. Does this work reliably when the scheduler spawns a fresh agent? The agent needs file access from the start — ensure the `developer` extension loads in scheduled context (known issue #5696: define extensions in top-level config.yaml, not just in the recipe).

### Recommended Approach

**Start with Option A: one cycle per scheduled invocation.**
- Scheduler runs the recipe every 30 minutes
- Recipe reads state.json, runs one cycle, updates state, exits
- Next invocation picks up from state.json
- Simplest to build, most like the Python script, and avoids long-running agent problems

Then if that works, optionally try Option B (internal multi-cycle loop) later.

### Steps to Build

1. Test `goose schedule` on a trivial recipe (confirm it works on Windows)
2. Build a minimal parent recipe that reads state.json and calls ONE sub-recipe
3. Verify sub-recipe results flow back to the parent
4. Add remaining sub-recipes in sequence
5. Add state.json update logic to the parent
6. Test the full single-cycle flow manually with `goose schedule run-now`
7. Schedule it for overnight: `goose schedule add --cron "*/30 * * * *"`

### What to Keep

- All 6 pipeline recipes in `overnight-pipeline/recipes/` — they're valid Goose YAMLs
- The state.json format and STOP.md convention — they work
- The personas.md and edge-cases.md — reusable assets
- Tonight's schedule.md config — the 9 untested recipes

### What to Retire

- `pipeline_runner.py` — replaced by the parent Goose recipe + scheduler
- `pipeline-kit.md` — rewrite for Goose-native approach
- `cycle.md` template — replaced by sub_recipes definition in the parent recipe

---

## Reference

- `HOW_GOOSE_WORKS.md` — scheduler commands, sub-recipe syntax, known issues
- `LEARNINGS.md` — pipeline lessons from 20-cycle run
- `overnight-pipeline/runs/2026-04-13-hardening/` — the completed run for comparison
