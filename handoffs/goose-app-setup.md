# Handoff: Setting Up the Goose App

**Date:** 2026-04-13
**Status:** Ready to start — Goose is installed but needs configuration and first recipe test
**Goal:** Get the Goose desktop app working with your recipes visible, running, and connected to Claude via ACP

---

## Current State

- **Goose installed:** `C:\Users\donid\.local\bin\goose.exe`
- **ACP adapter installed:** `@agentclientprotocol/claude-agent-acp@0.26.0` at `C:\Users\donid\AppData\Roaming\npm\claude-agent-acp.cmd`
- **Config exists:** `C:\Users\donid\AppData\Roaming\Block\goose\config\config.yaml`
- **Provider configured:** `GOOSE_PROVIDER: claude-acp`, `GOOSE_MODEL: default` (Opus)
- **Claude CLI authenticated:** `claude --version` works, uses Max subscription
- **26 course recipes written** in `recipes/stage-0/` through `recipes/stage-7/`
- **6 pipeline recipes written** in `overnight-pipeline/recipes/`
- **All recipes pass `goose recipe validate`** (validated in prior session)

### What You'll See When You Open the App

You said you don't see any recipes when you open the Goose app. This is expected — Goose recipes are YAML files on disk, not registered in the app. You need to either:
1. Run them via CLI: `goose run --recipe recipes/stage-1/bug-fix.yaml`
2. Or open them in the app's recipe runner (if available in your version)

---

## Step 1: Verify Goose Works

Open a terminal and run:

```bash
goose info -v
```

This shows your provider, model, extensions, and version. Confirm:
- Provider: `claude-acp`
- Model: `default` (should map to Opus)
- Extensions: at minimum `developer` should be listed

If provider shows something else or errors, check `C:\Users\donid\AppData\Roaming\Block\goose\config\config.yaml`.

## Step 2: Test a Simple Recipe

Run the simplest recipe to confirm everything connects:

```bash
goose run --recipe recipes/stage-1/bug-fix.yaml --params "bug_description=The login page shows a 500 error when no session cookie exists"
```

This should:
1. Spawn a Goose session
2. Connect to Claude via ACP (uses your Max subscription)
3. Read your project files via the developer extension
4. Investigate the bug and propose a fix

If it works, Goose + ACP + Claude is fully connected.

## Step 3: Understand the Config

### Main config location
`C:\Users\donid\AppData\Roaming\Block\goose\config\config.yaml`

This controls:
- **Provider:** Which LLM to use (`claude-acp` for Claude, `codex-acp` for GPT 5.4)
- **Model:** Which tier (`default`=Opus, `sonnet`, `haiku`)
- **Extensions:** Which tools are available (developer, analyze, github, etc.)

### Project-level config
Each project can have a `.goose/` directory at its root:
- `.goose/team_context.md` — project context injected into every recipe
- `.goose/state/progression.json` — developer progression tracking

RILGoose already has these (created by the overnight pipeline).

## Step 4: Explore the Desktop App

The Goose desktop app provides:
- **Chat interface** — talk to Goose directly
- **Extensions panel** — toggle extensions on/off (you mentioned seeing this)
- **Recipe runner** — load and run recipes (may need to point it at your recipe files)

### To get recipes visible in the app:
The app may look for recipes in a specific location. Check:
1. Whether the app has a "Load Recipe" or "Import Recipe" option
2. Whether recipes need to be in a specific directory (like `~/.config/goose/recipes/`)
3. Whether you can open a recipe YAML file directly from the app

If recipes aren't discoverable in the app, running them from CLI always works:
```bash
goose run --recipe <path-to-recipe.yaml>
```

## Step 5: Set Up Codex Provider (Optional)

To use Codex/GPT 5.4 alongside Claude:

```bash
npm install -g @zed-industries/codex-acp
```

Then in recipes, you can delegate to Codex subagents:
```
delegate(model: "codex-acp/default") to a subagent that...
```

This lets a single recipe use both Claude (main agent) and Codex (subagent) — no provider switching needed.

## Step 6: Test the Scheduler

Goose has a built-in scheduler for running recipes on a cron schedule:

```bash
# See all scheduler commands
goose schedule --help

# List existing scheduled jobs
goose schedule list

# Schedule a recipe to run nightly at 10pm
goose schedule add --schedule-id my-test --cron "0 22 * * *" --recipe-source recipes/stage-1/bug-fix.yaml

# Test it immediately
goose schedule run-now --schedule-id my-test

# Remove when done testing
goose schedule remove --schedule-id my-test
```

### Known scheduler issues:
- Extensions defined only in recipes may not load in scheduled context — make sure extensions are also defined in your top-level config.yaml
- Each scheduled run spawns a fresh agent (no memory between runs) — use state files for persistence
- Check session logs at: `C:\Users\donid\AppData\Roaming\Block\goose\data\sessions\`

## Step 7: Run a Teaching Recipe (Full Test)

Once Goose is working, try a teaching session:

```bash
goose run --recipe teaching/meta/teach-wrapper.yaml --params "stage=1" --params "recipe_name=bug-fix" --params "concept_id=1.1"
```

This runs the full teach-wrapper: facilitator + working recipe + eval subagent. It's the core of what RILGoose does.

---

## Key Files Reference

| File | What It Is |
|------|-----------|
| `HOW_GOOSE_WORKS.md` | Complete Goose reference — scheduler, recipes, subagents, ACP, extensions, CLI |
| `REFERENCES.md` Section 2 | Goose recipe format, sub-recipe syntax, subagent mechanics |
| `LEARNINGS.md` | Goose-specific gotchas from prior sessions (validation rules, config quirks) |
| `config.yaml` | `C:\Users\donid\AppData\Roaming\Block\goose\config\config.yaml` — main Goose config |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "not connected" on first run | Provider not configured — check config.yaml has `GOOSE_PROVIDER: claude-acp` |
| Recipe validation fails | See LEARNINGS.md — common issues: `input_type: text` (use `string`), missing defaults on optional params, file params with defaults |
| Extensions not loading | Define them in top-level config.yaml, not just in the recipe |
| Scheduler not available | May need Goose v1.18.0+ — check `goose --version` |
| ACP connection fails | Ensure `claude --version` works (Claude CLI must be authenticated) |

---

## What This Enables

Once Goose is set up:
1. **Run any recipe** from CLI or app
2. **Schedule recipes** to run overnight with `goose schedule`
3. **Use both Claude and Codex** in the same recipe via ACP adapters
4. **Test teaching sessions** end-to-end with the teach-wrapper
5. **Build the pipeline** as a native Goose recipe (see `handoffs/pipeline-to-goose-recipe.md`)
