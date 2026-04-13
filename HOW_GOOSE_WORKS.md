# How Goose Works — Operational Learnings

Technical discoveries about Goose's runtime, recipe system, scheduler, extensions, and configuration. This file is the single source for "how does Goose actually work?" questions.

---

## Scheduler (Built-in Cron)

Goose has a native scheduler that runs recipes on cron schedules. No external orchestration needed.

### Commands
```bash
goose schedule add --schedule-id <name> --cron "<expr>" --recipe-source <path>
goose schedule run-now --schedule-id <name>    # test immediately
goose schedule list                             # see all jobs
goose schedule remove --schedule-id <name>
goose schedule cron-help                        # cron syntax reference
```

### Cron Expressions
- Nightly at 10pm: `0 22 * * *`
- Every 2 hours: `0 */2 * * *`
- Shortcuts: `@hourly`, `@daily`, `@weekly`, `@monthly`

### Key Behaviors
- Each scheduled run spawns a fresh Agent — no persistent state between runs
- State tracking must be external (JSON files in the project)
- Runs in headless mode — no UI interaction during execution
- Session logs go to `C:\Users\<user>\AppData\Roaming\Block\goose\data\sessions\`

### Known Issues
- Background jobs can block tool execution in older versions — fixed in v1.18.0+ (Issue #3882)
- Extensions specified only in recipes may not load in scheduled contexts — define them in top-level config.yaml too (Issue #5696)
- Linux AARCH64 headless mode has "Scheduler not available" error (Issue #6405, not relevant for Windows)

### Pipeline Implications
The scheduler can replace an external Python loop for overnight recipe runs. A parent recipe with sub-recipes runs the pipeline sequence. The scheduler triggers it on a cron schedule. State tracking (which cycle, what's done) lives in project files that recipes read/write.

---

## Recipe System

### Format
```yaml
version: 1.0.0
title: "Recipe Name"
description: "What it does"

parameters:
  - key: param_name
    input_type: string        # Valid: string, number, boolean, date, file
    requirement: required     # or: optional
    default: ""               # Required for optional params
    description: "What this param is"

instructions: |
  Multi-line instructions for the agent.
  Use {{ param_name }} for template substitution.

extensions:
  - type: builtin
    name: developer

prompt: |
  Starting prompt with {{ param_name }} template vars.
```

### Validation Rules (from actual testing)
- `input_type: text` is INVALID — use `string`
- `input_type: select` is INVALID — use `string`
- File params cannot have defaults (security restriction)
- Optional params MUST have a `default:` field
- Template syntax: `{{ param }}` only — NO `{{ if }}...{{ endif }}` conditionals
- Validate with: `goose recipe validate <path>`

### Running Recipes
```bash
goose run --recipe <path> --params "key=value" --params "key2=value2"
goose run --recipe <path> --no-session -q    # headless, quiet
```

---

## Sub-Recipes

Parent recipes can invoke child recipes:

```yaml
sub_recipes:
  - name: "task_name"
    path: "./subrecipes/task.yaml"
    description: "What it does"
    values:
      param: "value"
```

Invocation in instructions: `subagent(subrecipe: "task_name", parameters: {...})`

### Key Constraints
- Sub-recipes run sequentially by default
- Sub-recipes cannot invoke other sub-recipes (no nesting)
- Parameters from parent are passed as concrete values (templates resolved first)
- Results return as tool call results (text or JSON)

---

## Subagents

Two systems for spawning child agents:

### summon (main system)
`delegate(instructions, extensions, provider, model, max_turns, async)`
- Creates fresh Agent + Session
- Runs full conversation
- Returns result as tool call response
- Supports `async: true` for background execution

### orchestrator (conversational)
- Creates named agent session
- Parent sends messages iteratively
- Child persists across messages

### Constraints
- Subagents CANNOT spawn subagents (hard blocked)
- Subagents forced to Auto permission mode
- Up to 5 concurrent background tasks (configurable via GOOSE_MAX_BACKGROUND_TASKS)
- Extension scoping: `extensions: ["developer"]` limits subagent tools
- Different model/provider per subagent is supported

---

## Provider System (ACP)

### Claude (via Claude Max subscription)
```bash
npm install -g @agentclientprotocol/claude-agent-acp@0.26.0
# Config:
GOOSE_PROVIDER: claude-acp
GOOSE_MODEL: default    # default=Opus, also: sonnet, haiku
```
Binary: `C:\Users\<user>\AppData\Roaming\npm\claude-agent-acp.cmd`

### Codex / GPT 5.4 (via Codex subscription)
```bash
npm install -g @zed-industries/codex-acp
# Config:
GOOSE_PROVIDER: codex-acp
GOOSE_MODEL: default
```

### How ACP Works
ACP spawns CLI tools as subprocesses, communicates via JSON-RPC over stdin/stdout. Uses existing CLI authentication (`claude auth login` / Codex login). No API keys, no per-token billing — subscription rate limits apply.

### Per-Subagent Model Routing
Recipes can specify different models per subagent:
```
delegate(model: "codex-acp/default") to a subagent that...
delegate(model: "claude-acp/haiku") to a subagent that...
```

---

## Extensions (MCP)

### Built-in Extensions (from config.yaml)
- `developer` — file read/write/edit, shell commands, git
- `analyze` — code structure analysis via tree-sitter
- `summon` — knowledge loading and subagent delegation
- `skills` — load and provide skill instructions
- `todo` — task tracking
- `tom` (Top Of Mind) — inject context via environment variables

### Extension Management
- Enable/disable in `C:\Users\<user>\AppData\Roaming\Block\goose\config\config.yaml`
- 3,000+ MCP servers available in the ecosystem
- Extensions in the Goose desktop app can be toggled on/off
- Per-session extension scoping limits what subagents can access

### Custom Extensions
MCP extensions are Python or JS servers. Can provide custom tools to Goose.

---

## Configuration

### Config File Location
`C:\Users\<user>\AppData\Roaming\Block\goose\config\config.yaml`

### Key Settings
```yaml
GOOSE_PROVIDER: claude-acp
GOOSE_MODEL: default
extensions:
  - type: builtin
    name: developer
  - type: builtin
    name: analyze
  # ... etc
```

### Project-Level Config
Each project can have `.goose/` at its root:
- `.goose/team_context.md` — project context injected into recipes
- `.goose/state/progression.json` — developer progression tracking

---

## Session Data
- Session logs: `C:\Users\<user>\AppData\Roaming\Block\goose\data\sessions\`
- Config: `C:\Users\<user>\AppData\Roaming\Block\goose\config\config.yaml`
- Binary: `C:\Users\<user>\.local\bin\goose.exe`

---

## Goose CLI Reference

```bash
goose run --recipe <path>                    # Run a recipe
goose run --recipe <path> --params "k=v"     # With parameters
goose run --recipe <path> --no-session -q    # Headless + quiet
goose recipe validate <path>                 # Validate recipe YAML
goose schedule add --schedule-id <id> --cron "<expr>" --recipe-source <path>
goose schedule run-now --schedule-id <id>    # Test immediately
goose schedule list                          # List scheduled jobs
goose schedule remove --schedule-id <id>     # Remove a job
goose info -v                                # Show config and version
```
