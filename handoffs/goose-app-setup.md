# Handoff: Setting Up the Goose App

**Date:** 2026-04-13
**Status:** Config done, recipes visible — next: restart app and test a real recipe run
**Goal:** Get the Goose desktop app working with your recipes visible, running, and connected to Claude via ACP

---

## What Was Done This Session

### 1. Config extensions enabled
Updated `C:\Users\donid\AppData\Roaming\Block\goose\config\config.yaml`:
- `memory`: false → **true** (preferences across sessions)
- `chatrecall`: false → **true** (session history search)
- `orchestrator`: false → **true** (subagent management for multi-agent recipes)

### 2. Recipe discovery configured
Set `GOOSE_RECIPE_PATH` as a persistent user environment variable with all 8 stage directories:
```
C:\Users\donid\ClaudeProjects\goose-wizard\recipes\stage-0;...;stage-7
```
- `goose recipe list` now shows all 26 recipes
- `goose recipe open bug-fix` successfully opens in the desktop app
- Key learning: `GOOSE_RECIPE_PATH` does NOT recurse subdirectories — each `stage-N/` must be listed explicitly

### 3. Automated setup script written
`install/setup-goose.ps1` — automates everything above for RIL teams:
- Checks prerequisites (Goose, Claude CLI, ACP adapter)
- Auto-discovers `stage-N/` directories under `recipes/`
- Sets `GOOSE_RECIPE_PATH` persistently
- Enables memory/chatrecall/orchestrator extensions in config.yaml
- Verifies with `goose recipe list`
- Supports `-DryRun` flag for testing

---

## Current State

- **Goose version:** 1.30.0
- **Provider:** `claude-acp` → Claude Max subscription (Opus)
- **26 recipes visible** via `goose recipe list`
- **Extensions enabled:** developer, analyze, skills, summon, todo, tom, extensionmanager, apps, memory, chatrecall, orchestrator
- **Extensions disabled:** code_execution, summarize, computercontroller, autovisualiser, tutorial
- **Project registered:** `projects.json` has Goose Wizard at last_accessed 2026-04-13

---

## What Needs Testing Next

### Immediate: Restart app and verify recipes
1. Close and reopen the Goose desktop app
2. Check if recipes appear in the recipe browser/list
3. If not visible in app UI, they still work via CLI: `goose recipe open bug-fix`

### First real recipe run
```bash
goose run --recipe bug-fix --params "bug_description=The login page shows a 500 error when no session cookie exists"
```
This tests the full chain: Goose → ACP → Claude → developer extension → code operations.

### Teaching recipe test
```bash
goose run --recipe stage-0-welcome
```
This is the Stage 0 scripted onboarding — simplest full teaching recipe.

---

## Recipe Sync — How It Works

Recipes are read directly from disk via `GOOSE_RECIPE_PATH`. No copying, no importing, no registry.

- **Edit a recipe YAML** → next `goose run` picks up the changes automatically
- **Add a new recipe** to an existing `stage-N/` directory → visible immediately
- **Add a new stage directory** (e.g., `stage-8/`) → must add to `GOOSE_RECIPE_PATH` (the setup script handles this automatically if re-run)

---

## Key Files

| File | Purpose |
|------|---------|
| `install/setup-goose.ps1` | Automated setup script for new machines |
| `AppData/Roaming/Block/goose/config/config.yaml` | Goose global config (extensions, provider) |
| `.goose/team_context.md` | Project context injected into every recipe |
| `.goose/state/progression.json` | Developer progression tracking (empty, not yet used) |
| `LEARNINGS.md` | Technical gotchas from setup (recipe discovery, config quirks) |

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `GOOSE_RECIPE_PATH` | `recipes/stage-0;...;stage-7` (full paths) | Recipe discovery for CLI and desktop app |
| `GOOSE_PROVIDER` | Set in config.yaml, not env var | `claude-acp` |
| `GOOSE_MODEL` | Set in config.yaml, not env var | `default` (Opus) |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Recipes not in app after restart | New terminal needed — env vars don't propagate to running processes. Close app completely, open new terminal, run `goose recipe list` to verify, then launch app. |
| `goose recipe list` shows nothing | Check `echo $env:GOOSE_RECIPE_PATH` in PowerShell. Re-run `install/setup-goose.ps1` if missing. |
| Recipe opens but won't connect | Run `claude --version` to verify Claude CLI auth. Check `goose info -v` for provider status. |
| Extensions not loading in recipes | Extensions must be enabled in global config.yaml, not just declared in recipe YAML. |
