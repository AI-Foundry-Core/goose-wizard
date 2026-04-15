# RILGoose Installer

Click-to-run installers for Windows and Mac. One file per platform — you only need your own.

## Windows

1. Double-click **`install-windows.bat`**.
2. Click "Yes" if Windows asks for permission.
3. Follow the prompts. Log in to Claude when the browser opens.
4. When it finishes, open the Goose desktop app and look for "START HERE" at the top.

> The `.bat` is a thin wrapper. It runs `setup-goose.ps1` with the right
> execution policy so PowerShell lets the script run by double-click.

## Mac

1. Double-click **`install-mac.command`** in Finder.
2. If macOS blocks it the first time ("cannot be opened because it is from an
   unidentified developer"), right-click the file → **Open** → confirm.
3. Follow the prompts. Log in to Claude when the browser opens.
4. When it finishes, open the Goose desktop app and look for "START HERE" at the top.

## What the installers do

Both installers run the same two phases.

### Phase 1 — Bootstrap prerequisites (if missing)

| Tool | Windows | Mac |
|---|---|---|
| Node.js LTS | `winget install OpenJS.NodeJS.LTS` | `brew install node` |
| Goose | download + extract Windows CLI zip | `brew install --cask block-goose` |
| Claude CLI | `npm install -g @anthropic-ai/claude-code` | same |
| ACP adapter | `npm install -g @agentclientprotocol/claude-agent-acp` | same |
| Homebrew | — | installed if missing |

If a tool is already installed, the installer skips that step.

The installer will also open the Claude login flow in a browser if you aren't
already logged in. A **Claude Max** subscription is required.

### Phase 2 — Configure for RILGoose

- Sets `GOOSE_RECIPE_PATH` so the `shared/` recipes show up in Goose
- Writes a minimal `config.yaml` if none exists
- In `config.yaml`: enables `memory` + `orchestrator`, disables `chatrecall`,
  sets provider to `claude-acp` and model to `opus`
- Patches the ACP adapter with 5 edits for clean recipe execution
  (settingSources, autoMemoryEnabled, AskUserQuestion, thinking tokens, system prompt)
- Touches `00-start-here.yaml` so the gateway recipe sorts first
- Creates `.goose/state/` and `~/.rilgoose/` directories
- Seeds `.goose/PROGRESS.md` from the project template

## Advanced usage

### Windows — skip the bootstrap (legacy behavior)

If you've already installed everything manually and just want the configuration
phase:

```powershell
powershell -ExecutionPolicy Bypass -File install\setup-goose.ps1 -SkipBootstrap
```

### Flags (both scripts)

| Flag | Effect |
|---|---|
| `-DryRun` | Show what would change without making changes (Windows only) |
| `-IncludeLocal` | Also add `recipes/local/` to `GOOSE_RECIPE_PATH` (Windows only) |
| `-SkipExtensions` | Skip updating `config.yaml` extensions (Windows only) |
| `-SkipBootstrap` | Skip Phase 1 prerequisite installs (Windows only) |

Mac script runs all phases unconditionally. For granular control, run the
individual steps in the script manually.

## Requirements

- **Windows 10 or 11** (for `winget`) or **macOS 12+** (for Homebrew)
- A **Claude Max subscription**
- Internet access during install (for npm, brew, GitHub releases)

## Troubleshooting

### "Goose recipe list shows no recipes"
Close and re-open your terminal. The installer sets `GOOSE_RECIPE_PATH` at the
user/shell-rc level, which only applies to **new** shell sessions.

### "ACP adapter patches failed"
The adapter's source may have changed in a newer version. Re-run the installer
after upgrading (`npm install -g @agentclientprotocol/claude-agent-acp`) and
check the warnings in the output.

### "Homebrew install needs sudo password" (Mac)
This is normal on a fresh Mac — Homebrew needs permission to create its
`/opt/homebrew` or `/usr/local` directories. Enter your Mac login password.

### "The script file is blocked" (Windows)
Right-click `install-windows.bat` → Properties → check "Unblock" at the bottom → OK.
Then double-click again.
