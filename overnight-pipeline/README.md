# Overnight Pipeline

A pipeline kit for running any series of Goose recipes overnight. A deterministic Python script calls `goose run` for each recipe in your checklist, tracks state, handles errors, and repeats. No LLM in the loop — pure automation.

## Quick Start

```bash
python overnight-pipeline/pipeline_runner.py overnight-pipeline/configs/tonight-untested/
```

See `pipeline-kit.md` for full instructions.

## Architecture

```
pipeline_runner.py (Python — deterministic)
  └─ goose run recipe-1.yaml
  └─ goose run recipe-2.yaml
  └─ goose run recipe-3.yaml
  └─ checks STOP.md
  └─ updates state.json
  └─ sleeps, repeats
```

- **Goose** runs all recipes (extensions, subagents, Codex via codex-acp)
- **Python script** handles sequencing, state, errors, sleep
- **No LLM in the loop.** Completely deterministic.

## Folder Structure

```
overnight-pipeline/
├── pipeline_runner.py              # The loop script (~200 lines Python)
├── pipeline-kit.md                 # Instructions: how to build a pipeline
├── README.md                       # This file
├── personas.md                     # 9 reusable mock developer personas
├── edge-cases.md                   # 14 reusable edge case scenarios
├── recipes/                        # Pipeline-specific Goose recipes
│   ├── simulate-session.yaml       # Run one mock teaching session
│   ├── evaluate-transcript.yaml    # Score one transcript
│   ├── classify-findings.yaml      # Bucket A/B/C classification
│   ├── apply-fixes.yaml            # Apply fixes + git commit
│   ├── plan-next-cycle.yaml        # Decide what's next or stop
│   └── summarize-run.yaml          # Write morning brief
├── configs/                        # Run configurations
│   └── tonight-untested/           # Example: 9 untested recipes
│       ├── cycle.md                # Recipe checklist
│       ├── schedule.md             # Per-cycle variation
│       └── state.json              # Pipeline state
├── templates/                      # Copy to start a new run
│   ├── cycle-template.md
│   ├── schedule-template.md
│   └── state.json
└── runs/                           # Archived completed runs
    └── 2026-04-13-hardening/       # 20 cycles, 72 fixes, all regressions passed
```

## Key Learnings from First Run (2026-04-13)

See `runs/2026-04-13-hardening/` for the complete 20-cycle run. Key takeaways:

- **Batch-fix structural gaps immediately.** Same gap in every module? Fix all at once.
- **Match mock models in regressions.** Using a different model to regression-test introduces noise.
- **GPT 5.4 holds hostile personas longer than Haiku.** Both fade after ~60%, but GPT 5.4 is better for stress-testing.
- **"Facilitator drives in fully adaptive" is the #1 bug class.** Check all Stage 5+ scripts.
- **Deterministic loops beat LLM loops.** The first run used Claude Code /loop — the new runner is a Python script for reliability.

## Two Types of Recipes

- **Course recipes** (`recipes/stage-0/` through `recipes/stage-7/`) — what developers run to learn
- **Pipeline recipes** (`overnight-pipeline/recipes/`) — infrastructure that tests and hardens course recipes

These never mix. Pipeline recipes are tools for the team, not for developers learning the system.
