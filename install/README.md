# goose-wizard Installer

## Install

**Mac / Linux:**
```
curl -fsSL https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.sh | bash
```

**Windows (PowerShell):**
```
irm https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.ps1 | iex
```

The script clones the repo, installs prerequisites, configures Goose,
authenticates with Claude, and launches the gateway tutorial automatically.
One line from install to first training module.

## What the installer does

### Phase 1 — Bootstrap prerequisites (if missing)

| Tool | Windows | Mac / Linux |
|---|---|---|
| Git | `winget install Git.Git` | `xcode-select --install` (Mac) or package manager (Linux) |
| Node.js LTS | `winget install OpenJS.NodeJS.LTS` | `brew install node` |
| Goose CLI | download + extract CLI zip to `~/.local/bin` | `brew install --cask block-goose` |
| Claude CLI | `irm https://claude.ai/install.ps1 \| iex` | `curl -fsSL https://claude.ai/install.sh \| bash` |
| ACP adapter | `npm install -g @agentclientprotocol/claude-agent-acp@0.28.0` | same |
| Homebrew | — | installed if missing (macOS only) |

If a tool is already installed, the installer skips that step.

**Windows-specific: Git Bash path.** Claude Code uses Bash internally on
Windows. The installer writes `CLAUDE_CODE_GIT_BASH_PATH` into
`~/.claude/settings.json` so Claude Code can find `bash.exe` even if Git is
installed in a non-standard location.

**Claude login:** The installer checks for `~/.claude/.credentials.json`. If
absent, it launches `claude` which opens the browser for OAuth. A **Claude Max**
subscription is required.

### Phase 2 — Configure for goose-wizard

- Clones the repo to `~/goose-wizard` (or pulls if already cloned)
- Sets `GOOSE_RECIPE_PATH` so training recipes show up in Goose
- Copies `config.yaml` if none exists (provider=claude-acp, model=opus,
  mode=smart_approve, memory + orchestrator enabled, chatrecall disabled)
- Patches the ACP adapter with 3 edits:
  1. `settingSources: ["user", "local"]` — drops project-scope CLAUDE.md
  2. `autoMemoryEnabled: false` — prevents Claude Code memory leaking into recipes
  3. `maxThinkingTokens: 4096` — caps thinking budget (override with `MAX_THINKING_TOKENS` env var)
- Seeds `~/.rilgoose/progression.json` for training state

## Requirements

- **Windows 10+** or **macOS 13+** or **Linux** (with package manager)
- A **Claude Max subscription**
- Internet access during install

## Troubleshooting

### "Goose recipe list shows no recipes"
Close and re-open your terminal. `GOOSE_RECIPE_PATH` only applies to new
shell sessions.

### "ACP adapter patches failed"
The ACP adapter is pinned to version 0.28.0. Re-run the installer to
reinstall at the pinned version. To use a newer ACP version, update
`ACP_PINNED_VERSION` in `install.sh` / `install.ps1` and re-test the 3
patches against the new source.

### "Homebrew install needs sudo password" (Mac)
Normal on a fresh Mac — Homebrew needs permission to create its directories.
Enter your Mac login password.
