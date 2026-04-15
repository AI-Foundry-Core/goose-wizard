# RILGoose Setup Script
# Installs and configures Goose for RILGoose training recipes.
#
# Phase 1 (bootstrap): installs Node.js, Goose, Claude CLI, and ACP adapter
#                      if they're missing. Bootstraps config.yaml.
# Phase 2 (configure): sets GOOSE_RECIPE_PATH, enables/disables extensions,
#                      patches the ACP adapter, seeds state directories.
#
# Usage: powershell -ExecutionPolicy Bypass -File install\setup-goose.ps1
# Or from PowerShell: .\install\setup-goose.ps1
# Or double-click: install-windows.bat (recommended for new users)
#
# Flags:
#   -SkipBootstrap  Skip prerequisite auto-install (legacy behavior)
#   -IncludeLocal   Also add recipes/local/ to GOOSE_RECIPE_PATH (pipeline/testing recipes)
#   -SkipExtensions Skip updating config.yaml extensions
#   -DryRun         Show what would change without making changes

param(
    [string]$RecipeRoot = "",
    [switch]$SkipBootstrap,
    [switch]$IncludeLocal,
    [switch]$SkipExtensions,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "=== RILGoose Setup ===" -ForegroundColor Cyan

# ================================================================
# PHASE 1: Bootstrap — install prerequisites if missing
# ================================================================
# This block auto-installs Node.js, Goose, Claude CLI, and the ACP
# adapter. Skippable with -SkipBootstrap for users who've already
# set things up manually (legacy setup-goose.ps1 behavior).

if (-not $SkipBootstrap -and -not $DryRun) {
    Write-Host "`n--- Phase 1: Bootstrap prerequisites ---" -ForegroundColor Cyan

    # Helper: check if a command exists on PATH
    function Test-Command($name) {
        return [bool](Get-Command $name -ErrorAction SilentlyContinue)
    }

    # Helper: refresh PATH in the current process after installing something
    function Refresh-Path {
        $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"
    }

    # Helper: treat winget "already installed" / "no upgrade needed" as success
    function Test-WingetResult($exitCode, $binaryName) {
        if ($exitCode -eq 0) { return $true }
        # Winget returns these for "already installed" / "no newer version" cases:
        #   0x8A150010 = APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE (-1978335216)
        #   0x8A15002B = APPINSTALLER_CLI_ERROR_NO_APPLICABLE_UPDATE_FOUND
        # Rather than enumerate codes, fall back to "is the binary reachable?"
        Refresh-Path
        return (Test-Command $binaryName)
    }

    # Helper: preflight connectivity to a required URL; warn if blocked
    function Test-Reachable($url, $label) {
        try {
            $resp = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
            return $true
        } catch {
            Write-Host "  WARNING: cannot reach $label ($url). Error: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "           If this is a corporate laptop, you likely need a proxy/VPN or IT to whitelist GitHub and npm." -ForegroundColor Yellow
            return $false
        }
    }

    # --- Preflight connectivity ---
    Write-Host "`nPreflight: connectivity to GitHub and npm..." -ForegroundColor Yellow
    $ghOk  = Test-Reachable "https://github.com" "GitHub"
    $npmOk = Test-Reachable "https://registry.npmjs.org" "npm registry"
    if (-not ($ghOk -and $npmOk)) {
        Write-Host "  Continuing anyway — some downloads may fail. Check with IT if you hit download errors." -ForegroundColor Yellow
    }

    # --- Node.js ---
    Write-Host "`nChecking Node.js..." -ForegroundColor Yellow
    if (Test-Command "node") {
        $nodeVer = & node --version 2>&1
        Write-Host "  Node.js: $nodeVer (already installed)"
    } else {
        Write-Host "  Node.js not found. Installing via winget..."
        if (-not (Test-Command "winget")) {
            Write-Host "ERROR: winget not available. Install Node.js LTS manually from https://nodejs.org" -ForegroundColor Red
            Write-Host "       Older Windows 11 builds lack winget — update Windows or install the Node LTS .msi yourself, then re-run." -ForegroundColor Red
            exit 1
        }
        & winget install --id OpenJS.NodeJS.LTS --silent --accept-source-agreements --accept-package-agreements
        if (-not (Test-WingetResult $LASTEXITCODE "node")) {
            Write-Host "ERROR: Node.js install failed (winget exit $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "       If GPO or Store restrictions block winget, install Node LTS manually from https://nodejs.org and re-run." -ForegroundColor Red
            exit 1
        }
        Refresh-Path
        if (-not (Test-Command "node")) {
            Write-Host "ERROR: Node.js installed but not on PATH. Close this window and re-run from a new terminal." -ForegroundColor Red
            exit 1
        }
        Write-Host "  Node.js installed: $(& node --version)"
    }

    # Explicitly add %APPDATA%\npm to this session's PATH — it's where npm puts
    # global shims but only gets added to user PATH on first npm invocation,
    # which may not be reflected in our cached Refresh-Path result yet.
    $npmShimDir = Join-Path $env:APPDATA "npm"
    if ($env:Path -notlike "*$npmShimDir*") {
        $env:Path = "$env:Path;$npmShimDir"
    }

    # --- Goose CLI (portable extract from zip) ---
    Write-Host "`nChecking Goose CLI..." -ForegroundColor Yellow
    if (Test-Command "goose") {
        try {
            $gooseVer = & goose --version 2>&1
            if ($LASTEXITCODE -ne 0 -or -not $gooseVer) {
                throw "goose --version failed"
            }
            Write-Host "  Goose: $($gooseVer.Trim()) (already installed)"
        } catch {
            Write-Host "  WARNING: 'goose' is on PATH but --version failed. The existing install may be broken." -ForegroundColor Yellow
            Write-Host "           Continuing — if recipe execution fails later, reinstall Goose manually." -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Goose CLI not found. Downloading latest stable release..."
        $gooseZipUrl = "https://github.com/block/goose/releases/download/stable/goose-x86_64-pc-windows-msvc.zip"
        $gooseTarget = Join-Path $env:USERPROFILE ".local\bin"
        # Unique temp filename to avoid collision with a concurrent installer run
        $tempZip = Join-Path $env:TEMP ("goose-cli-" + [System.Guid]::NewGuid().ToString("N") + ".zip")
        $tempExtract = Join-Path $env:TEMP ("goose-cli-extract-" + [System.Guid]::NewGuid().ToString("N"))

        try {
            Write-Host "  URL: $gooseZipUrl"
            Invoke-WebRequest -Uri $gooseZipUrl -OutFile $tempZip -UseBasicParsing
            New-Item -ItemType Directory -Path $gooseTarget -Force | Out-Null
            New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
            Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

            # Find goose.exe inside the extracted tree (zip may or may not have a
            # single top-level subdirectory like goose-package/).
            $gooseExe = Get-ChildItem -Path $tempExtract -Filter "goose.exe" -Recurse | Select-Object -First 1
            if (-not $gooseExe) {
                throw "goose.exe not found in the extracted archive at $tempExtract"
            }
            $gooseSourceDir = $gooseExe.Directory.FullName

            # Move goose.exe and every file in its directory (DLLs, etc) to the target
            Get-ChildItem -Path $gooseSourceDir -File | ForEach-Object {
                Copy-Item $_.FullName (Join-Path $gooseTarget $_.Name) -Force
            }

            # Clean up temp
            Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
            Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

            # Ensure goose bin dir is on user PATH
            $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$gooseTarget*") {
                $newPath = if ($userPath) { "$userPath;$gooseTarget" } else { $gooseTarget }
                [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
                Write-Host "  Added $gooseTarget to user PATH"
            }
            # Also ensure it's on THIS session's PATH
            if ($env:Path -notlike "*$gooseTarget*") {
                $env:Path = "$env:Path;$gooseTarget"
            }
            if (-not (Test-Command "goose")) {
                Write-Host "ERROR: Goose binary extracted but still not on PATH. Contents of ${gooseTarget}:" -ForegroundColor Red
                Get-ChildItem -Path $gooseTarget | ForEach-Object { Write-Host "    $($_.Name)" }
                exit 1
            }
            Write-Host "  Goose CLI installed: $(& goose --version)"
        } catch {
            Write-Host "ERROR: Goose download/extract failed: $_" -ForegroundColor Red
            Write-Host "       Install manually from https://github.com/block/goose/releases/tag/stable" -ForegroundColor Red
            exit 1
        }
    }

    # --- Goose desktop app ---
    Write-Host "`nChecking Goose desktop app..." -ForegroundColor Yellow
    $desktopInstalled = $false
    # Look in the most common install locations for a Goose desktop app
    $desktopCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Goose\Goose.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\goose\Goose.exe"),
        "C:\Program Files\Goose\Goose.exe",
        (Join-Path $env:USERPROFILE "AppData\Local\Programs\Goose\Goose.exe")
    )
    foreach ($candidate in $desktopCandidates) {
        if (Test-Path $candidate) {
            Write-Host "  Desktop app: found at $candidate"
            $desktopInstalled = $true
            break
        }
    }
    if (-not $desktopInstalled) {
        Write-Host "  Goose desktop app not found. Downloading installer..."
        $desktopZipUrl = "https://github.com/block/goose/releases/download/stable/Goose.zip"
        $tempDesktopZip = Join-Path $env:TEMP ("goose-desktop-" + [System.Guid]::NewGuid().ToString("N") + ".zip")
        $tempDesktopExtract = Join-Path $env:TEMP ("goose-desktop-extract-" + [System.Guid]::NewGuid().ToString("N"))

        try {
            Invoke-WebRequest -Uri $desktopZipUrl -OutFile $tempDesktopZip -UseBasicParsing
            New-Item -ItemType Directory -Path $tempDesktopExtract -Force | Out-Null
            Expand-Archive -Path $tempDesktopZip -DestinationPath $tempDesktopExtract -Force

            # The zip may contain an NSIS installer .exe or a Setup .msi — find and run it.
            $installer = Get-ChildItem -Path $tempDesktopExtract -Include "*.exe","*.msi" -Recurse -File |
                         Where-Object { $_.Name -match "(?i)goose|setup|install" } |
                         Select-Object -First 1
            if (-not $installer) {
                # Fall back to ANY exe in the extracted tree
                $installer = Get-ChildItem -Path $tempDesktopExtract -Filter "*.exe" -Recurse -File | Select-Object -First 1
            }
            if (-not $installer) {
                throw "Goose desktop installer not found in Goose.zip"
            }

            Write-Host "  Running desktop installer: $($installer.Name)"
            Write-Host "  (a Windows install dialog may appear — click through it)"
            if ($installer.Extension -eq ".msi") {
                Start-Process msiexec.exe -ArgumentList "/i `"$($installer.FullName)`" /qb" -Wait
            } else {
                # NSIS/Electron installers usually support /S for silent — try that but fall back to visible
                Start-Process -FilePath $installer.FullName -ArgumentList "/S" -Wait -ErrorAction SilentlyContinue
            }

            Remove-Item $tempDesktopZip -Force -ErrorAction SilentlyContinue
            Remove-Item $tempDesktopExtract -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Goose desktop app installer completed."
        } catch {
            Write-Host "  WARNING: Goose desktop install failed: $_" -ForegroundColor Yellow
            Write-Host "           The CLI is enough to run recipes. Install the desktop app later from:" -ForegroundColor Yellow
            Write-Host "           https://github.com/block/goose/releases/tag/stable" -ForegroundColor Yellow
        }
    }

    # --- Claude CLI ---
    Write-Host "`nChecking Claude CLI..." -ForegroundColor Yellow
    if (Test-Command "claude") {
        Write-Host "  Claude CLI: found (already installed)"
    } else {
        Write-Host "  Claude CLI not found. Installing via npm..."
        Write-Host "  (Note: npm install of @anthropic-ai/claude-code may be deprecated in future releases in favor of https://claude.ai/install.sh — current approach still works.)"
        & npm install -g "@anthropic-ai/claude-code"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Claude CLI install failed (exit $LASTEXITCODE)" -ForegroundColor Red
            Write-Host "       Common cause: npm global prefix not writable. Run 'npm config get prefix' and check permissions." -ForegroundColor Red
            exit 1
        }
        Refresh-Path
        # npm shims land in %APPDATA%\npm — make sure it's on this session's PATH
        if ($env:Path -notlike "*$npmShimDir*") {
            $env:Path = "$env:Path;$npmShimDir"
        }
        if (-not (Test-Command "claude")) {
            Write-Host "ERROR: Claude CLI installed but not on PATH." -ForegroundColor Red
            Write-Host "       Expected at: $npmShimDir\claude.cmd" -ForegroundColor Red
            exit 1
        }
        Write-Host "  Claude CLI installed."
    }

    # --- ACP adapter ---
    Write-Host "`nChecking Claude ACP adapter..." -ForegroundColor Yellow
    if (Test-Command "claude-agent-acp") {
        Write-Host "  ACP adapter: found (already installed)"
    } else {
        Write-Host "  ACP adapter not found. Installing via npm..."
        & npm install -g "@agentclientprotocol/claude-agent-acp"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: ACP adapter install failed (exit $LASTEXITCODE)" -ForegroundColor Red
            exit 1
        }
        Refresh-Path
        if ($env:Path -notlike "*$npmShimDir*") {
            $env:Path = "$env:Path;$npmShimDir"
        }
        Write-Host "  ACP adapter installed."
    }

    # --- Claude authentication ---
    Write-Host "`nChecking Claude authentication..." -ForegroundColor Yellow
    # Check if credentials file exists as a heuristic for "already logged in"
    $claudeCredsPath = Join-Path $env:USERPROFILE ".claude\.credentials.json"
    if (Test-Path $claudeCredsPath) {
        Write-Host "  Found existing Claude credentials at $claudeCredsPath"
        Write-Host "  Assuming you are logged in. If recipes later fail with auth errors, run 'claude' and re-login."
    } else {
        Write-Host "  No existing Claude credentials found."
        Write-Host "  We'll now launch 'claude' — it will open a browser for you to log in with your Claude Max account."
        Write-Host "  After login, type '/exit' or press Ctrl+D to leave the Claude session and return here."
        Read-Host "  Press Enter to launch Claude login"
        # Run 'claude' with no args — this triggers the OAuth browser flow on first run.
        # Start-Process -Wait so the script pauses until the user exits the Claude session.
        try {
            Start-Process -FilePath "claude" -NoNewWindow -Wait
        } catch {
            Write-Host "  WARNING: could not launch 'claude' automatically. Please open a new terminal, run 'claude', complete login, then come back." -ForegroundColor Yellow
            Read-Host "  Press Enter when login is complete"
        }
        # Verify credentials now exist
        if (Test-Path $claudeCredsPath) {
            Write-Host "  Login detected."
        } else {
            Write-Host "  WARNING: credentials file still not found at $claudeCredsPath." -ForegroundColor Yellow
            Write-Host "           Recipe execution will likely fail until you log in. Run 'claude' manually to retry." -ForegroundColor Yellow
        }
    }

    # --- Bootstrap config.yaml if missing ---
    Write-Host "`nChecking Goose config.yaml..." -ForegroundColor Yellow
    $configDir = Join-Path $env:APPDATA "Block\goose\config"
    $configPath = Join-Path $configDir "config.yaml"
    if (-not (Test-Path $configPath)) {
        Write-Host "  config.yaml not found. Creating minimal config for claude-acp..."
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        $minimalConfig = @"
GOOSE_PROVIDER: claude-acp
GOOSE_MODEL: opus
extensions:
  developer:
    enabled: true
    type: builtin
    name: developer
  analyze:
    enabled: true
    type: builtin
    name: analyze
  summon:
    enabled: true
    type: builtin
    name: summon
  skills:
    enabled: true
    type: builtin
    name: skills
  todo:
    enabled: true
    type: builtin
    name: todo
  memory:
    enabled: true
    type: builtin
    name: memory
  orchestrator:
    enabled: true
    type: builtin
    name: orchestrator
  chatrecall:
    enabled: false
    type: builtin
    name: chatrecall
"@
        Set-Content -Path $configPath -Value $minimalConfig -NoNewline
        Write-Host "  Created: $configPath"
    } else {
        Write-Host "  config.yaml exists: $configPath"
    }

    Write-Host "`n--- Phase 1 complete ---" -ForegroundColor Green
    Write-Host "`n--- Phase 2: Configure for RILGoose ---" -ForegroundColor Cyan
}

# --- Locate recipe root ---
if (-not $RecipeRoot) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RecipeRoot = Join-Path (Split-Path -Parent $ScriptDir) "recipes"
}

if (-not (Test-Path $RecipeRoot)) {
    Write-Host "ERROR: Recipe directory not found at $RecipeRoot" -ForegroundColor Red
    Write-Host "Pass -RecipeRoot <path> to specify a different location."
    exit 1
}

Write-Host "Recipe root: $RecipeRoot"

# --- Verify shared/ directory exists ---
$sharedDir = Join-Path $RecipeRoot "shared"
if (-not (Test-Path $sharedDir)) {
    Write-Host "ERROR: recipes/shared/ not found at $sharedDir" -ForegroundColor Red
    exit 1
}

$sharedCount = (Get-ChildItem -Path $sharedDir -Filter "*.yaml").Count
Write-Host "  shared/: $sharedCount training recipes"

# --- Verify agents/ directory exists (sub-recipes reference these) ---
$agentsDir = Join-Path $RecipeRoot "agents"
if (-not (Test-Path $agentsDir)) {
    Write-Host "ERROR: recipes/agents/ not found at $agentsDir" -ForegroundColor Red
    Write-Host "  Agent primitives are required - training recipes call them as sub-recipes."
    exit 1
}
$agentsCount = (Get-ChildItem -Path $agentsDir -Filter "*.yaml" -Recurse).Count
Write-Host "  agents/: $agentsCount agent primitives (top-level + nested subdirs)"

# --- Verify graduated/ directory exists (graduation copies from here) ---
$graduatedDir = Join-Path $RecipeRoot "graduated"
if (-not (Test-Path $graduatedDir)) {
    Write-Host "ERROR: recipes/graduated/ not found at $graduatedDir" -ForegroundColor Red
    Write-Host "  Graduated recipes are required - graduation promotes these to shared/."
    exit 1
}
$graduatedCount = (Get-ChildItem -Path $graduatedDir -Filter "*.yaml").Count
Write-Host "  graduated/: $graduatedCount coordinator recipes"

# Only shared/ goes on GOOSE_RECIPE_PATH (agents/ and graduated/ are
# referenced via relative sub_recipe paths, not scanned by Goose)
$recipeDirs = @($sharedDir)

if ($IncludeLocal) {
    $localDir = Join-Path $RecipeRoot "local"
    if (Test-Path $localDir) {
        $localCount = (Get-ChildItem -Path $localDir -Filter "*.yaml").Count
        Write-Host "  local/: $localCount recipes (included via -IncludeLocal)"
        $recipeDirs += $localDir
    } else {
        Write-Host "  WARNING: recipes/local/ not found, skipping" -ForegroundColor Yellow
    }
}

# --- Check prerequisites ---
Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow

# Goose
$gooseCmd = Get-Command goose -ErrorAction SilentlyContinue
if (-not $gooseCmd) {
    Write-Host "ERROR: goose not found. Install from https://github.com/block/goose" -ForegroundColor Red
    exit 1
}
$gooseVersion = & goose --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: goose --version failed" -ForegroundColor Yellow
} else {
    Write-Host "  Goose: $($gooseVersion.Trim())"
}

# Claude CLI
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host "ERROR: claude CLI not found. Install Claude Code first." -ForegroundColor Red
    exit 1
}
Write-Host "  Claude CLI: found"

# ACP adapter
$acpCmd = Get-Command claude-agent-acp -ErrorAction SilentlyContinue
if (-not $acpCmd) {
    Write-Host "WARNING: claude-agent-acp not found. Install with:" -ForegroundColor Yellow
    Write-Host "  npm install -g @agentclientprotocol/claude-agent-acp"
} else {
    Write-Host "  ACP adapter: found"
}

# --- Set GOOSE_RECIPE_PATH ---
Write-Host "`nSetting GOOSE_RECIPE_PATH..." -ForegroundColor Yellow

$newRecipePath = $recipeDirs -join ";"

$existingPath = [System.Environment]::GetEnvironmentVariable("GOOSE_RECIPE_PATH", "User")
if ($existingPath) {
    Write-Host "  Existing value: $existingPath"
    # Merge: keep any existing paths that aren't under our recipe root
    $existingParts = $existingPath -split ";"
    $extraPaths = @($existingParts | Where-Object {
        $normalized = $_.TrimEnd('\', '/')
        -not $normalized.StartsWith($RecipeRoot.TrimEnd('\', '/'))
    })
    if ($extraPaths.Count -gt 0) {
        $newRecipePath = ($newRecipePath, ($extraPaths -join ";")) -join ";"
        Write-Host "  Merged with external paths: $($extraPaths -join '; ')"
    }
}

if ($DryRun) {
    Write-Host "  [DRY RUN] Would set GOOSE_RECIPE_PATH=$newRecipePath"
} else {
    [System.Environment]::SetEnvironmentVariable("GOOSE_RECIPE_PATH", $newRecipePath, "User")
    Write-Host "  Set GOOSE_RECIPE_PATH (persistent, user-level)"
    Write-Host "  Value: $newRecipePath"
}

# --- Update config.yaml extensions ---
if (-not $SkipExtensions) {
    $configPath = Join-Path $env:APPDATA "Block\goose\config\config.yaml"
    if (Test-Path $configPath) {
        Write-Host "`nUpdating Goose config extensions..." -ForegroundColor Yellow

        $config = Get-Content $configPath -Raw

        # Extensions to ENABLE for teaching
        $enableExtensions = @("memory", "orchestrator")

        foreach ($ext in $enableExtensions) {
            $pattern = "(?m)(  ${ext}:\s*\r?\n\s*enabled:\s*)false"
            if ($config -match $pattern) {
                if ($DryRun) {
                    Write-Host "  [DRY RUN] Would enable: $ext"
                } else {
                    $config = $config -replace $pattern, '${1}true'
                    Write-Host "  Enabled: $ext"
                }
            } else {
                Write-Host "  Already enabled or not found: $ext"
            }
        }

        # Extensions to DISABLE for teaching
        # chatrecall loads summaries from past sessions into new ones. During training,
        # this causes old context (including failed test sessions or design discussions)
        # to bleed into recipe execution, overriding recipe instructions. Disable it
        # so training recipes have full control of the conversation.
        $disableExtensions = @("chatrecall")

        foreach ($ext in $disableExtensions) {
            $pattern = "(?m)(  ${ext}:\s*\r?\n\s*enabled:\s*)true"
            if ($config -match $pattern) {
                if ($DryRun) {
                    Write-Host "  [DRY RUN] Would disable: $ext (prevents context bleeding)"
                } else {
                    $config = $config -replace $pattern, '${1}false'
                    Write-Host "  Disabled: $ext (prevents past sessions from overriding recipes)"
                }
            } else {
                Write-Host "  Already disabled or not found: $ext"
            }
        }

        # Ensure provider is set
        if ($config -notmatch "GOOSE_PROVIDER:\s*claude-acp") {
            Write-Host "  WARNING: GOOSE_PROVIDER is not set to claude-acp" -ForegroundColor Yellow
        } else {
            Write-Host "  Provider: claude-acp (OK)"
        }

        # Set model to Opus — required for instruction-following in recipes.
        # The default model (Sonnet) ignores detailed recipe instructions like
        # act sequences, formatting rules, and interaction gates. Opus follows
        # them reliably. This uses the ACP adapter's alias resolution ("opus"
        # resolves to the full model ID like "claude-opus-4-6").
        $modelPattern = "(?m)^GOOSE_MODEL:\s*\S+"
        if ($config -match "(?m)^GOOSE_MODEL:\s*(\S+)") {
            $currentModel = $Matches[1]
            if ($currentModel -ne "opus") {
                if ($DryRun) {
                    Write-Host "  [DRY RUN] Would set GOOSE_MODEL to opus (currently: $currentModel)"
                } else {
                    $config = $config -replace $modelPattern, "GOOSE_MODEL: opus"
                    Write-Host "  Set GOOSE_MODEL: opus (was: $currentModel)" -ForegroundColor Green
                }
            } else {
                Write-Host "  Model: opus (OK)"
            }
        } else {
            Write-Host "  WARNING: GOOSE_MODEL not found in config" -ForegroundColor Yellow
        }

        if (-not $DryRun) {
            Set-Content -Path $configPath -Value $config -NoNewline
            Write-Host "  Config saved."
        }
    } else {
        Write-Host "`nWARNING: Config not found at $configPath" -ForegroundColor Yellow
        Write-Host "  Run 'goose configure' first, then re-run this script."
    }
}

# --- Patch ACP adapter to prevent CLAUDE.md context pollution ---
# WHY THIS EXISTS (do not remove without understanding):
# The Claude ACP adapter (acp-agent.js) hardcodes settingSources: ["user", "project", "local"]
# which loads ~/.claude/CLAUDE.md, <cwd>/CLAUDE.md, and <cwd>/.claude/CLAUDE.md into every
# Goose session. The "user" and "project" sources bring in the user's personal Claude Code
# config, memory files, and project instructions — which cause the agent to identify as
# Claude Code, refuse to run recipes, and break the teaching flow.
#
# By patching to ["local"], only <cwd>/.claude/CLAUDE.md loads — which we control via the
# project template. This is safe because:
# - RIL users have nothing in ~/.claude/ anyway (new to AI tools)
# - Our .claude/CLAUDE.md in the project template has the Goose override
# - After training graduation, users reinstall the standard adapter to restore full loading
#
# Upstream fix: file issue/PR on @agentclientprotocol/claude-agent-acp for a config option
# to control settingSources. Until then, this patch is the only way.
Write-Host "`nPatching ACP adapter (context isolation)..." -ForegroundColor Yellow

# Locate the ACP adapter via `npm root -g` so we work with any npm prefix
# (default %APPDATA%\npm, nvm-windows, Scoop, Chocolatey, custom prefix).
# Fall back to the historical default if npm isn't on PATH.
$acpAgentFile = $null
try {
    $npmGlobalRoot = (& npm root -g 2>$null).Trim()
    if ($LASTEXITCODE -eq 0 -and $npmGlobalRoot) {
        $candidate = Join-Path $npmGlobalRoot "@agentclientprotocol\claude-agent-acp\dist\acp-agent.js"
        if (Test-Path $candidate) {
            $acpAgentFile = $candidate
        }
    }
} catch {
    # npm not on PATH or failed; fall through to fallback
}
if (-not $acpAgentFile) {
    $fallbackDir = Join-Path $env:APPDATA "npm\node_modules\@agentclientprotocol\claude-agent-acp\dist"
    $acpAgentFile = Join-Path $fallbackDir "acp-agent.js"
}

if (Test-Path $acpAgentFile) {
    $acpContent = Get-Content $acpAgentFile -Raw

    # Patch 1: settingSources — only load .claude/CLAUDE.md from project dir
    $originalLine = 'settingSources: ["user", "project", "local"]'
    $patchedLine  = 'settingSources: ["local"]'

    if ($acpContent.Contains($originalLine)) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would patch settingSources to [""local""] only"
        } else {
            $acpContent = $acpContent.Replace($originalLine, $patchedLine)
            Write-Host "  Patched: settingSources now [""local""] (prevents CLAUDE.md interference)" -ForegroundColor Green
        }
    } elseif ($acpContent.Contains($patchedLine)) {
        Write-Host "  Already patched (settingSources = [""local""])"
    } else {
        Write-Host "  WARNING: Could not find settingSources line in acp-agent.js" -ForegroundColor Yellow
        Write-Host "  The ACP adapter may have been updated. Check line ~1038 manually."
    }

    # Patch 2: autoMemoryEnabled — disable Claude Code's auto-memory system
    # The claude_code preset enables auto-memory by default, which reads from
    # ~/.claude/projects/<hash>/memory/ independently of settingSources. This
    # brings in user-specific rules that override recipe instructions.
    # Tolerant match: settingSources: ["local"] with optional trailing comma.
    if ($acpContent.Contains("autoMemoryEnabled: false")) {
        Write-Host "  Already patched (autoMemoryEnabled = false)"
    } else {
        $memoryPattern = '(settingSources:\s*\[\s*"local"\s*\],?)'
        if ($acpContent -match $memoryPattern) {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would disable autoMemoryEnabled"
            } else {
                $acpContent = [regex]::Replace($acpContent, $memoryPattern, '$1' + "`n            autoMemoryEnabled: false,")
                Write-Host "  Patched: autoMemoryEnabled = false (prevents memory interference)" -ForegroundColor Green
            }
        } else {
            Write-Host "  WARNING: Could not insert autoMemoryEnabled patch (Patch 1 may have failed)" -ForegroundColor Yellow
        }
    }

    # Patch 3: Enable AskUserQuestion tool — required for interactive recipes
    # The ACP adapter disallows AskUserQuestion by default. Without it, the agent
    # cannot stop and wait for user input during multi-step teaching sessions.
    $askOriginal = 'const disallowedTools = ["AskUserQuestion"];'
    $askPatched  = 'const disallowedTools = [];'

    if ($acpContent.Contains($askOriginal)) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would enable AskUserQuestion tool"
        } else {
            $acpContent = $acpContent.Replace($askOriginal, $askPatched)
            Write-Host "  Patched: AskUserQuestion enabled (allows interactive recipes)" -ForegroundColor Green
        }
    } elseif ($acpContent.Contains($askPatched)) {
        Write-Host "  Already patched (AskUserQuestion enabled)"
    } else {
        Write-Host "  WARNING: Could not find disallowedTools line" -ForegroundColor Yellow
    }

    # Patch 4: Disable extended thinking output
    # Claude's extended thinking streams visible "thinking" blocks in the Goose UI,
    # which looks confusing to users. Setting maxThinkingTokens to 0 disables this.
    # Use a regex that tolerates whitespace/line-ending variations across upstream
    # reformatting (prettier, indentation changes, etc.) instead of an exact match.
    $alreadyThinkPatched = ($acpContent -match 'const\s+maxThinkingTokens\s*=\s*0\b')
    if ($alreadyThinkPatched) {
        Write-Host "  Already patched (thinking disabled)"
    } else {
        # Match `const maxThinkingTokens = <anything up to and including undefined>;`
        # across multiple lines of any whitespace. [\s\S] = any char including newline.
        $thinkPattern = '(?s)const\s+maxThinkingTokens\s*=\s*process\.env\.MAX_THINKING_TOKENS[\s\S]*?;'
        if ($acpContent -match $thinkPattern) {
            if ($DryRun) {
                Write-Host "  [DRY RUN] Would disable extended thinking"
            } else {
                $acpContent = [regex]::Replace($acpContent, $thinkPattern, 'const maxThinkingTokens = 0; // thinking disabled for clean recipe output')
                Write-Host "  Patched: extended thinking disabled (no visible thinking blocks)" -ForegroundColor Green
            }
        } else {
            Write-Host "  WARNING: Could not find maxThinkingTokens block" -ForegroundColor Yellow
        }
    }

    # Patch 5: Replace claude_code system prompt with recipe-focused prompt
    # The claude_code preset's system prompt is massive and drowns out recipe
    # instructions. It also tells the agent about memory systems and CLAUDE.md,
    # causing hallucinated memories. A focused prompt lets recipe instructions
    # be the primary authority while keeping tool access intact.
    $promptOriginal = 'let systemPrompt = { type: "preset", preset: "claude_code" };'
    $promptPatched  = 'let systemPrompt = "You are an AI assistant running in the Goose agent platform. Your task comes from a recipe \u2014 follow its instructions exactly. Use the available tools (file read/write/edit, shell commands, code analysis) to do the work. When the recipe says to stop and wait for the user, use AskUserQuestion to pause and get their response before continuing. Write complete paragraphs, not fragments. Never narrate your reasoning process out loud.";'

    if ($acpContent.Contains($promptOriginal)) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would replace system prompt"
        } else {
            $acpContent = $acpContent.Replace($promptOriginal, $promptPatched)
            Write-Host "  Patched: system prompt replaced (recipe-focused)" -ForegroundColor Green
        }
    } elseif ($acpContent.Contains("You are an AI assistant running in the Goose agent platform")) {
        Write-Host "  Already patched (custom system prompt)"
    } else {
        Write-Host "  WARNING: Could not find systemPrompt line" -ForegroundColor Yellow
    }

    # Write all patches at once
    if (-not $DryRun -and ($acpContent -ne (Get-Content $acpAgentFile -Raw))) {
        Set-Content -Path $acpAgentFile -Value $acpContent -NoNewline
        Write-Host "  Patches written to acp-agent.js"
    }
} else {
    Write-Host "  WARNING: acp-agent.js not found at $acpAgentFile" -ForegroundColor Yellow
    Write-Host "  Install the ACP adapter first: npm install -g @agentclientprotocol/claude-agent-acp"
}

# --- Touch gateway recipe so it sorts first in the app ---
Write-Host "`nEnsuring gateway recipe sorts first..." -ForegroundColor Yellow
$gatewayPath = Join-Path $sharedDir "00-start-here.yaml"
if (Test-Path $gatewayPath) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would touch $gatewayPath"
    } else {
        (Get-Item $gatewayPath).LastWriteTime = Get-Date
        Write-Host "  Touched 00-start-here.yaml (newest modified = first in app)"
    }
} else {
    Write-Host "  WARNING: Gateway recipe not found at $gatewayPath" -ForegroundColor Yellow
}

# --- Verify ---
Write-Host "`nVerifying setup..." -ForegroundColor Yellow

# Set for current process so verification works
$env:GOOSE_RECIPE_PATH = $newRecipePath

# Sanity check: recipe counts match expected architecture
# Count now includes nested primitives under recipes/agents/<subdir>/ too
# (progression/, config/, conductor/). Keep the floor conservative — it's a
# smoke check, not a gate.
if ($agentsCount -lt 28) {
    Write-Host "  WARNING: Expected 29+ agent primitives (including nested subdirs), found $agentsCount" -ForegroundColor Yellow
}
if ($graduatedCount -lt 5) {
    Write-Host "  WARNING: Expected 5 graduated coordinators, found $graduatedCount" -ForegroundColor Yellow
}
if ($sharedCount -lt 26) {
    Write-Host "  WARNING: Expected 27 training recipes, found $sharedCount" -ForegroundColor Yellow
}

# Verify gateway recipe exists (reuse $gatewayPath from touch section above)
if (-not (Test-Path $gatewayPath)) {
    Write-Host "  WARNING: Gateway recipe 00-start-here.yaml not found in shared/" -ForegroundColor Yellow
}

# Verify progression state directory exists (or create it)
# NOTE: Per-user progression state lives at ~/.rilgoose/progression.json (below).
# The .goose/state/ dir is still created here for user_config.json + legacy
# progression paths that may need to be migrated on first run.
$projectRoot = Split-Path -Parent $RecipeRoot
$stateDir = Join-Path (Join-Path $projectRoot ".goose") "state"
if (-not (Test-Path $stateDir)) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create .goose/state/ for per-project state"
    } else {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
        Write-Host "  Created .goose/state/ directory for per-project state"
    }
} else {
    Write-Host "  .goose/state/ directory exists"
}

# Per-user RILGoose directory (progression.json, user.json live here).
# Progression is per-USER, so it sits in $HOME and follows the developer across
# every codebase they train on — not tied to this project.
$rilgooseHome = Join-Path $env:USERPROFILE ".rilgoose"
if (-not (Test-Path $rilgooseHome)) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create ~/.rilgoose/ for per-user progression state"
    } else {
        New-Item -ItemType Directory -Path $rilgooseHome -Force | Out-Null
        Write-Host "  Created ~/.rilgoose/ directory for per-user progression state"
    }
} else {
    Write-Host "  ~/.rilgoose/ directory exists"
}

# Seed .goose/PROGRESS.md (the user-facing training checklist)
$progressSource = Join-Path $projectRoot ".goose" "PROGRESS.md"
$progressTarget = Join-Path (Join-Path $projectRoot ".goose") "PROGRESS.md"
if (-not (Test-Path $progressTarget)) {
    # In the RILGoose repo, PROGRESS.md is already there. For external projects,
    # we need to copy from the template. Check if template exists.
    $templateProgress = Join-Path $projectRoot "install" "project-template" ".goose" "PROGRESS.md"
    $repoProgress = Join-Path $projectRoot ".goose" "PROGRESS.md"
    if (Test-Path $templateProgress) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would copy PROGRESS.md from template"
        } else {
            Copy-Item $templateProgress $progressTarget
            Write-Host "  Seeded .goose/PROGRESS.md from template"
        }
    } else {
        Write-Host "  WARNING: .goose/PROGRESS.md not found. Training flow depends on it." -ForegroundColor Yellow
        Write-Host "  Copy it from the RILGoose repo: <repo>/.goose/PROGRESS.md -> <project>/.goose/PROGRESS.md"
    }
} else {
    Write-Host "  .goose/PROGRESS.md exists"
}

$listOutput = & goose recipe list --format text 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  WARNING: goose recipe list failed (exit code $LASTEXITCODE)" -ForegroundColor Yellow
} else {
    $foundRecipes = ($listOutput | Select-String -Pattern "^\s+\w").Count
    if ($foundRecipes -gt 0) {
        Write-Host "  goose recipe list: $foundRecipes recipes visible" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: goose recipe list shows no recipes. Restart your terminal and try again." -ForegroundColor Yellow
    }
}

# --- Summary ---
$totalVisible = $sharedCount
if ($IncludeLocal -and (Test-Path (Join-Path $RecipeRoot "local"))) {
    $totalVisible += (Get-ChildItem -Path (Join-Path $RecipeRoot "local") -Filter "*.yaml").Count
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "What was configured:"
Write-Host "  1. GOOSE_RECIPE_PATH set to $($recipeDirs.Count) directories ($totalVisible visible recipes)"
Write-Host "     - $sharedCount training recipes in shared/ (visible in Goose app)"
Write-Host "     - $agentsCount agent primitives in agents/ (called as sub-recipes)"
Write-Host "     - $graduatedCount graduated coordinators in graduated/ (promoted on completion)"
Write-Host "  2. Extensions: memory + orchestrator enabled, chatrecall disabled"
Write-Host "  3. Provider: claude-acp, Model: opus (Claude Max subscription via ACP)"
Write-Host "  4. ACP adapter patched (context isolation for clean recipe execution)"
Write-Host "  5. Gateway recipe touched (will appear first in app)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart the Goose desktop app (close and reopen)"
Write-Host "  2. Look for '* START HERE - Goose Training' at the top of the recipe list"
Write-Host "  3. Or run from CLI: goose run --recipe start-here"
Write-Host ""
Write-Host "Architecture:"
Write-Host "  - Training recipes (shared/) are what developers see and interact with"
Write-Host "  - Agent primitives (agents/) do the work, called via sub_recipes"
Write-Host "  - Graduated recipes (graduated/) replace training after completion"
Write-Host ""
Write-Host "Note: New terminal windows will pick up GOOSE_RECIPE_PATH automatically."
Write-Host "      Current terminal needs: `$env:GOOSE_RECIPE_PATH = '$newRecipePath'"
