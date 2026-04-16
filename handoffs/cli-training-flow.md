# Handoff: CLI Training Flow — ACP Patches, Recipe Iteration, Next Steps

**Date:** 2026-04-13
**Status:** Core infrastructure working. Recipe UX needs iteration. Design pivot identified.
**Prior handoff:** `handoffs/two-mode-recipes.md`

---

## What Was Done This Session

### 1. Solved ACP Context Pollution (the big one)

The Claude ACP adapter (`acp-agent.js`) injects CLAUDE.md, memory files, and the full `claude_code` system prompt into every Goose recipe session. This caused the agent to identify as Claude Code, refuse to run recipes ("per the memory, I should never simulate recipes"), and ignore recipe instructions.

**Five patches applied to `acp-agent.js`** (at `%APPDATA%\npm\node_modules\@agentclientprotocol\claude-agent-acp\dist\`):

| Patch | Line | What it does |
|-------|------|-------------|
| `settingSources: ["local"]` | 1038 | Only loads `.claude/CLAUDE.md` from project dir — no global CLAUDE.md or project-level CLAUDE.md |
| `autoMemoryEnabled: false` | 1039 | Disables Claude Code's auto-memory system (loaded independently of settingSources) |
| `disallowedTools: []` | 1028 | Re-enables `AskUserQuestion` tool so agent can pause for user input |
| Custom `systemPrompt` | 1007 | Replaces `claude_code` preset with focused recipe-execution prompt (see note below) |
| (Reverted) `maxThinkingTokens` | — | Tried setting to 0 to hide thinking output. Reverted — makes the model dumber. Thinking display is a Goose rendering issue. |

**IMPORTANT: The custom systemPrompt is overridden by Goose.** Line 1008-1017 shows that `params._meta.systemPrompt` (sent by Goose) replaces whatever we set as default. Our custom prompt is only a fallback for when Goose doesn't send one. In practice, Goose ALWAYS sends the system prompt (its `system.md` template), so our custom prompt rarely takes effect. The recipe instructions are the primary way to control agent behavior.

### 2. Approaches Tried and Discarded

| Approach | Why it failed |
|----------|--------------|
| **Recipe isolation preamble** ("ignore CLAUDE.md") | Agent absorbs CLAUDE.md at system level before reading recipe. Specific rules ("never simulate") beat generic overrides ("follow the recipe"). |
| **`.claude/CLAUDE.md` with override clause** | Loaded alongside other sources. One voice among many — loses the argument. |
| **Override clause mentioning "never simulate"** | Ironic failure: the override TAUGHT the agent the rule it was trying to suppress. Lesson: never mention what you want the agent to ignore. |
| **Tom extension (`GOOSE_MOIM_MESSAGE_FILE`)** | Injected per-turn but still couldn't override CLAUDE.md/memory rules already in context. |
| **`CLAUDE_CONFIG_DIR` env var** | Process-wide — works for CLI wrapper but NOT for desktop app. Setting persistently breaks normal Claude Code. |
| **Forking the ACP adapter npm package** | Overkill for a few-line patch. Setup script patch + reinstall-to-revert is simpler. |
| **Disabling `maxThinkingTokens`** | Setting to 0 hides thinking but makes the model dumber. The thinking DISPLAY is a Goose UI issue, not an ACP issue. |
| **Replacing "Use Markdown formatting" in system prompt** | Goose system prompt comes via `_meta.systemPrompt` which replaces our default. We patched both string and append branches but the replacement string didn't match (Goose may send it in a different format). For CLI, markdown is fine anyway. |

### 3. Goose Config Changes

- **`chatrecall` disabled** — was loading summaries from past sessions where "never simulate" was discussed, poisoning new sessions
- **`GOOSE_MODE: smart_approve`** — Doni changed from autonomous to smart_approve for better interaction control
- **Sessions DB must be wiped** between test iterations — `%APPDATA%\Block\goose\data\sessions\sessions.db` (locked while Goose runs, close app first)

### 4. Project Template Created

`install/project-template/` — standard test project deployed to user's machine:

```
GooseTestProject/
├── .claude/CLAUDE.md           ← Minimal project info only (no override clauses!)
├── .goose/
│   ├── state/progression.json  ← Fresh 0/26
│   ├── team_context.md         ← Project info for recipes
│   └── tom-context.md          ← Tom extension context (not currently effective)
├── src/
│   ├── models.py               ← Task + TaskStore (has empty-file crash bug)
│   ├── cli.py                  ← CLI interface
│   └── formatting.py           ← Has off-by-one, duplicate logic, zero-task crash
├── tests/
│   └── test_tasks.py           ← 6 tests (intentionally incomplete)
└── data/tasks.json             ← 5 sample tasks
```

### 5. Setup Script Updated

`install/setup-goose.ps1` now handles:
- Recipe path discovery (shared/ + optional local/)
- Extension enable/disable (memory on, chatrecall off)
- ACP adapter patching (all 4 patches above)
- Gateway recipe touch (sort order)
- Existing path merging

### 6. Recipe Iteration (00-start-here.yaml)

Went through ~8 iterations. Current state:
- Interactive WAIT gates work (agent stops, waits for user reply)
- 5-act Stage 0 pattern scripted inline (no external teaching scripts needed)
- `--interactive` flag required for CLI multi-turn
- Agent follows recipe flow (reads progression, runs correct module)

**Remaining UX issues:**
- Agent still shows 26-module table despite "do not show a table"
- Still says "Would you like me to..." despite "be directive"
- Goose's `system.md` says "Use Markdown formatting for all responses" — overrides recipe formatting rules
- Thinking blocks visible in output (Goose renders them)
- CLI streaming is chunky (known Goose issue, PR #7233 helped but not fully fixed)

### 7. Key Discovery: VS Code Extension

The Goose VS Code extension (`block.vscode-goose`) does NOT support recipes. It's a basic chat sidebar only. Not viable for recipe-based training. The extension is experimental with ~4,600 installs and known Windows bugs.

---

## Design Pivot: Teach Goose Recipes, Not Just AI

**Doni's insight:** The training currently teaches AI-assisted development generically. It should teach Goose recipes specifically. Developers need to understand what a recipe IS, see the recipe that powered their session, and learn to use recipes independently.

### Proposed Flow

1. **CLI runs the training interactively** — `goose run --recipe ... --interactive`
2. **At the end of each module**, the CLI explains: "That whole session was powered by a Goose recipe. Here's what it looks like..."
3. **CLI opens the recipe in the desktop app**: `goose recipe open <path>`
4. **Developer sees the recipe YAML** — the blueprint behind what they just experienced
5. **Progressive recipe literacy** — by Stage 2-3, developers understand recipes well enough to modify them

### Why This Matters

- RIL teams need to become self-sufficient with Goose, not just AI
- Recipes are the unit of knowledge transfer — developers need to read/write them
- The desktop app becomes the "recipe viewer" while CLI is the "training runner"
- Side-by-side experience: do the task in CLI, see the blueprint in the app

---

## What Needs Doing Next

### Priority 1: Rewrite Module 1 (Start Here) with Recipe Teaching

The 5-act pattern needs updating to include recipe awareness:

**Act 0 (new) — What is a Goose Recipe?**
Before doing anything with code, briefly explain what a recipe is:
"Everything in Goose runs from a recipe — a YAML file that tells AI what to do. This training session is itself a recipe. After we finish, I'll show it to you."

**Act 1-5** — Keep the existing interactive code demo flow, but after Act 5:

**Act 6 (new) — See the Recipe**
"Everything you just experienced was powered by this recipe:"
- Show the recipe YAML (or key sections)
- Point out: instructions, extensions, prompt
- Open it in the desktop app: `goose recipe open <path>`
- Say: "Every module in this training works the same way. As you progress, you'll start recognizing recipe patterns."

### Priority 2: Rewrite Module 2 (Bug Fix) with Recipe Reveal

After the developer completes the bug fix exercise:
- Show them the Bug Fix recipe YAML
- Point out how it's structured differently from Start Here
- Have them compare the two recipes
- Open it in the app

### Priority 3: Rewrite Module 3 (Test Writer) Same Pattern

Same recipe-reveal pattern. By module 3, the developer should start anticipating "there's a recipe behind this."

### Priority 4: Fix Remaining UX Issues

- **Table dump** — The agent ignores "do not show a table" because Goose's system.md says "Use Markdown formatting." Try moving the no-table instruction into the `prompt:` field instead of `instructions:` — the prompt is the last thing the agent sees.
- **"Would you like"** — Same cause. Try putting the directive rule in the prompt field.
- **Thinking display** — File upstream issue on Goose for hiding thinking blocks in CLI output. No client-side fix available.
- **GOOSE_WORKING_DIR** — Setup script should set this persistently to GooseTestProject (or the user's project). The Goose desktop app ignores `projects.json` for initial directory and uses Electron localStorage instead.

---

## Key Files

| File | Purpose |
|------|---------|
| `recipes/shared/00-start-here.yaml` | Gateway recipe — current working version with 5-act flow |
| `install/setup-goose.ps1` | Setup script with all ACP patches |
| `install/project-template/` | Deployable test project template |
| `C:\Users\donid\ClaudeProjects\GooseTestProject\` | Live test project (deployed from template) |
| `%APPDATA%\npm\node_modules\@agentclientprotocol\claude-agent-acp\dist\acp-agent.js` | Patched ACP adapter |
| `%APPDATA%\Block\goose\config\config.yaml` | Goose config (chatrecall off, smart_approve mode) |
| `handoffs/two-mode-recipes.md` | Previous session's handoff (two-mode pattern, project structure) |

## Current ACP Patch State

These are the EXACT patches currently applied to `acp-agent.js`. A fresh `npm install -g @agentclientprotocol/claude-agent-acp` reverts all of them.

```
Line 1007: systemPrompt = "You are an AI assistant in an interactive chat session..."
           (was: { type: "preset", preset: "claude_code" })
           NOTE: Goose overrides this via _meta.systemPrompt — our default rarely takes effect

Line 1028: const disallowedTools = [];
           (was: const disallowedTools = ["AskUserQuestion"];)

Line 1038: settingSources: ["local"],
           (was: settingSources: ["user", "project", "local"])

Line 1039: autoMemoryEnabled: false,
           (new line, inserted after settingSources)
```

## CLI Command for Testing

```
cd C:\Users\donid\ClaudeProjects\GooseTestProject
goose run --recipe C:\Users\donid\ClaudeProjects\goose-wizard\recipes\shared\00-start-here.yaml --interactive
```

## Reset Procedure (between test runs)

1. Close Goose desktop app
2. Delete `%APPDATA%\Block\goose\data\sessions\sessions.db`
3. Copy template files to GooseTestProject:
   - `progression.json` (reset to 0/26)
   - `models.py`, `formatting.py`, `test_tasks.py` (restore bugs)
