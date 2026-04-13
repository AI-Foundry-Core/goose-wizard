# Overnight Pipeline

An autonomous pipeline framework that runs multi-cycle test-evaluate-fix loops while you sleep. Each run targets a specific activity — simulating teaching sessions, auditing content, stress-testing recipes, or anything else that benefits from repeated cycles with independent evaluation.

## How It Works

Every run follows the same core loop:

1. **Execute** — Do the activity (simulate a session, audit a document, test a recipe)
2. **Evaluate** — Two independent evaluators score the output (Opus + Codex/GPT 5.4)
3. **Decide** — Classify findings as Bucket A (fix now) or Bucket B (log for later)
4. **Apply** — Make safe fixes, commit them individually
5. **Plan** — Design the next cycle based on what was learned
6. **Repeat** — Schedule the next wake and loop

The activity in Step 1 is pluggable. Everything else is the framework.

## Folder Structure

```
overnight-pipeline/
├── README.md              ← You are here
├── personas.md            ← Reusable mock developer personas (9 defined)
├── edge-cases.md          ← Reusable edge case scenarios (14 defined)
├── templates/
│   ├── loop-prompt.md     ← Generic loop prompt template — copy and customize per run
│   └── state.json         ← Starting state template
└── runs/
    └── YYYY-MM-DD-name/   ← Each completed run gets its own folder
        ├── HANDOFF.md     ← What happened, what to read, what needs decisions
        ├── state.json     ← Final state (cycle history, bucket B tracking)
        ├── morning-brief.md
        ├── changelog.md   ← Every fix applied + proposed (before/after/why)
        ├── cycle-plan.md  ← The N-cycle schedule
        ├── loop-prompt.md ← The actual prompt used for this run
        ├── transcripts/   ← Per-cycle output
        ├── evaluations/   ← Per-cycle eval reports (opus + codex)
        └── logs/          ← Full agent output for every step
```

## Starting a New Run

1. **Create the run folder:** `overnight-pipeline/runs/YYYY-MM-DD-name/`
2. **Copy templates:** Copy `templates/loop-prompt.md` and `templates/state.json` into your run folder
3. **Customize the loop prompt:** Replace the `{ACTIVITY}` sections with your specific activity steps
4. **Write a cycle plan:** Define how many cycles, what to target each cycle
5. **Launch:** Start a `/loop` session with the customized loop prompt

## Activity Types That Work Well

| Activity | What Step 1 Does | What Evaluators Score |
|----------|-------------------|----------------------|
| **Teaching simulation** | Simulate a facilitator + mock developer session | Script faithfulness, pedagogy, persona realism |
| **Content audit** | Review documents for consistency, contradictions, gaps | Accuracy, completeness, voice consistency |
| **Recipe stress-test** | Run recipes against edge cases and hostile inputs | Robustness, error handling, output quality |
| **Eval calibration** | Run the same transcript through different eval prompts | Inter-rater agreement, dimension coverage |
| **Documentation review** | Check docs against current code state | Accuracy, staleness, missing sections |

## Key Learnings from First Run (2026-04-13)

See `runs/2026-04-13-hardening/` for the complete 20-cycle run. Key takeaways:

- **Batch-fix structural gaps immediately.** When you find the same gap in every module, fix them all at once — don't fix one per cycle.
- **Planner agents should never touch `current_cycle`.** Only set `next_planned`. The decision-maker owns the counter.
- **Match mock models in regressions.** Using Haiku to regression-test a GPT 5.4 baseline introduces model noise.
- **GPT 5.4 holds hostile personas longer than Haiku.** Both fade after ~60% of sessions, but GPT 5.4 is better for stress-testing.
- **Tighten Codex eval prompts.** Tell it "write evaluation only, don't explore" — otherwise it spends 30-60 seconds exploring the repo.
- **"Facilitator drives in fully adaptive" is the #1 bug class.** Check all Stage 5+ scripts for this before testing.

## Reusable Assets

- **`personas.md`** — 9 developer archetypes (eager junior, hostile senior, anxious newcomer, etc.) for simulation runs
- **`edge-cases.md`** — 14 scenarios (refuses edits, data privacy questions, "Copilot does this," etc.) to force during testing
