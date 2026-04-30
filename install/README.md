# goose-wizard Installer

## Install

**Mac / Linux:**

```shell
curl -fsSL https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.ps1 | iex
```

The script installs prerequisites, clones or updates the repo, configures
Goose, authenticates with Claude, applies the required ACP adapter patches, and
launches the gateway tutorial automatically.

## What The Installer Does

### Phase 1 - Bootstrap Prerequisites

If a tool is already installed, the installer skips that step.

| Tool | Windows | Mac / Linux |
|---|---|---|
| Git | `winget install Git.Git` | `xcode-select --install` on macOS, or package manager on Linux |
| Node.js LTS | `winget install OpenJS.NodeJS.LTS` | `brew install node` on macOS, or package manager on Linux |
| Goose CLI | Downloads the latest Windows CLI zip from GitHub releases | `brew install block-goose-cli` on macOS; manual Goose install on Linux |
| Goose desktop app | Downloads latest `Goose.zip` from GitHub releases, optional | `brew install --cask block-goose` on macOS, optional |
| Claude CLI | `irm https://claude.ai/install.ps1 \| iex` | `curl -fsSL https://claude.ai/install.sh \| bash` |
| ACP adapter | `npm install -g @agentclientprotocol/claude-agent-acp@0.28.0` | same |
| Homebrew | not used | installed if missing on macOS |

**Windows-specific Git Bash path.** Claude Code uses Bash internally on
Windows. The installer writes `CLAUDE_CODE_GIT_BASH_PATH` into
`~/.claude/settings.json` so Claude Code can find `bash.exe` even if Git is
installed in a non-standard location.

**Claude login.** The installer checks whether Claude is authenticated. If not,
it launches `claude` for the one-time browser login. A Claude Max subscription
is required for the default `claude-acp` setup.

### Phase 2 - Configure goose-wizard

The installer:

- Clones the repo to `~/goose-wizard`, or runs `git pull --ff-only` if it is already cloned.
- Copies `install/config.yaml` into Goose config if no config exists.
- Ensures existing Goose config has `GOOSE_PROVIDER: claude-acp`, `GOOSE_MODEL: opus`, and `GOOSE_MODE: smart_approve`.
- Sets `GOOSE_RECIPE_PATH` to `~/goose-wizard/recipes/shared`.
- Sets `GOOSE_PLUGIN_PATH` to `~/.agents`.
- Creates the `~/.agents/.claude-plugin/plugin.json` manifest for the `goose-skills` plugin.
- Copies repo skills from `install/skills/` into `~/.agents/skills/`.
- Seeds `~/goose-wizard/progression.json` from the project template if missing.
- Launches `goose run --recipe 00-start-here --interactive`.

### ACP Adapter Patches

The installer pins `@agentclientprotocol/claude-agent-acp` to `0.28.0` and
patches its installed `dist/acp-agent.js` in place. Re-running the installer is
idempotent and reapplies these patches if a later `npm install -g` overwrites
the package.

Required patches:

1. `settingSources: []` - prevents Claude user, project, and local memory files
   from leaking into Goose recipe runs.
2. `autoMemoryEnabled: false` - disables Claude Code automatic memory.
3. `maxThinkingTokens: 4096` - caps default thinking token budget unless
   `MAX_THINKING_TOKENS` is explicitly set.
4. `GOOSE_PLUGIN_PATH` plugin injection - lets `claude-acp` discover
   Goose-canonical skills under `~/.agents/skills/`, including
   `goose-skills:model-selection`.
5. `CLAUDE_ACP_DROP_DEFAULT_SYSTEM_PROMPT` support - when that environment
   variable is set to `1`, the adapter omits the default `claude_code`
   system-prompt preset. Default behavior is unchanged when the variable is
   not set.

Patch 7 is intentionally environment-variable-gated. The installer makes the
adapter capable of this behavior, but it does not globally set
`CLAUDE_ACP_DROP_DEFAULT_SYSTEM_PROMPT`; launchers or harnesses opt in when
they need to avoid the default Claude Code local-command caveat layer.

## Requirements

- Windows 10+, macOS 13+, or Linux with a package manager.
- Internet access during install.
- Browser access for Claude OAuth login.
- Claude Max subscription for the default Claude-backed runtime.
- Permission to install npm global package
  `@agentclientprotocol/claude-agent-acp@0.28.0`.
- Network access to GitHub, GitHub release assets, npm registry, `claude.ai`,
  and Claude/Anthropic runtime endpoints.

## Troubleshooting

### "Goose recipe list shows no recipes"

Close and re-open your terminal. `GOOSE_RECIPE_PATH` applies to new shell
sessions. The installer also exports it for the current install session before
launching the gateway tutorial.

### "goose-skills:model-selection is missing"

Re-run the installer. The most common cause is a later global npm install
overwriting the patched ACP adapter, or the `GOOSE_PLUGIN_PATH` environment
variable not being visible in the current shell.

### "Goose recipe content is treated like untrusted command output"

Confirm the installer has been re-run after Patch 7 landed. For launcher or
harness sessions that need the reduced Claude ACP system prompt, set
`CLAUDE_ACP_DROP_DEFAULT_SYSTEM_PROMPT=1` on the spawning process.

### "ACP adapter patches failed"

The adapter is pinned to version `0.28.0`. Re-run the installer to reinstall
and repatch that version. Do not upgrade the ACP adapter without retesting the
patches against the new source.

### "Homebrew install needs sudo password" on macOS

That is normal on a fresh Mac. Homebrew may need permission to create its
directories. Enter the Mac login password, then re-run the installer if needed.
