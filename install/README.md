# RILGoose Installer

Click-to-run installers for Windows and Mac. One file per platform - you only need your own.

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

### Phase 1 - Bootstrap prerequisites (if missing)

| Tool | Windows | Mac |
|---|---|---|
| OS minimum | Windows 10 1809+ (build 17763) | macOS 13.0+ |
| Git | `winget install Git.Git` (Claude Code requires Git Bash) | `brew install git` |
| Node.js LTS | `winget install OpenJS.NodeJS.LTS` | `brew install node` |
| Goose CLI | download + extract Windows CLI zip | installed with `--cask block-goose` |
| Goose desktop app | download + run `Goose.zip` installer | installed with `--cask block-goose` |
| Claude CLI | `irm https://claude.ai/install.ps1 \| iex` (native; npm fallback) | `curl -fsSL https://claude.ai/install.sh \| bash` (native; npm fallback) |
| ACP adapter | `npm install -g @agentclientprotocol/claude-agent-acp` | same |
| Homebrew | - | installed if missing |
| python3 | assumed present (PowerShell native) | validated, prompts to install Xcode CLT if missing |
| `claude doctor` | run post-install to verify Claude Code health | same |

**Windows-specific: Git Bash path.** Claude Code runs Bash internally on Windows regardless of which shell launched it. The installer proactively writes `CLAUDE_CODE_GIT_BASH_PATH` into `~/.claude/settings.json` so Claude Code can find `bash.exe` even if Git is installed in a non-standard location (Scoop, PortableGit, user-local). The canonical path is `C:\Program Files\Git\bin\bash.exe`.

If a tool is already installed, the installer skips that step.

**Connectivity preflight:** the installer checks GitHub and the npm registry are
reachable before running anything. If a corporate proxy blocks them you get a
warning - you can still proceed but expect download failures.

**Claude login:** the installer checks for `~/.claude/.credentials.json` (Mac) or
`%USERPROFILE%\.claude\.credentials.json` (Windows). If absent, it launches
`claude` (no subcommand - `claude auth login` does not exist). The browser
opens, you log in, then type `/exit` or Ctrl+D to leave the Claude session and
return to the installer. A **Claude Max** subscription is required.

### Phase 2 - Configure for RILGoose

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

### Windows - skip the bootstrap (legacy behavior)

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
This is normal on a fresh Mac - Homebrew needs permission to create its
`/opt/homebrew` or `/usr/local` directories. Enter your Mac login password.

### "The script file is blocked" (Windows)
Right-click `install-windows.bat` → Properties → check "Unblock" at the bottom → OK.
Then double-click again.
