# goose-wizard installer for Windows
# Usage: irm https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.ps1 | iex
#
# Installs prerequisites, clones the repo, configures Goose + Claude,
# patches the ACP adapter, and seeds initial state. Idempotent — safe
# to run multiple times.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

$ACP_VERSION = "0.28.0"
$RepoUrl = "https://github.com/AI-Foundry-Core/goose-wizard.git"
$InstallDir = Join-Path $env:USERPROFILE "goose-wizard"

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

function Write-Step([string]$msg) {
    Write-Host "  ${msg}..." -NoNewline
}

function Write-Ok([string]$msg) {
    Write-Host "  $msg" -ForegroundColor Green
}

function Write-Err([string]$msg) {
    [Console]::Error.WriteLine("  $msg")
    Write-Host "  $msg" -ForegroundColor Red
}

function Refresh-Path {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
    # Ensure npm shim dir is always present
    $npmShim = Join-Path $env:APPDATA "npm"
    if ($env:Path -notlike "*$npmShim*") { $env:Path = "$env:Path;$npmShim" }
}

function Test-Cmd([string]$name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# ---------------------------------------------------------------------------
# Phase 1: Prerequisites
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host "  goose-wizard installer" -ForegroundColor Cyan
Write-Host ""

# --- 1a. Git ---
Write-Step "Checking Git"
if (Test-Cmd "git") {
    $v = (& git --version 2>&1).Trim()
    Write-Host " $v" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Installing Git via winget..."
    if (-not (Test-Cmd "winget")) {
        Write-Err "winget not available. Install Git for Windows manually: https://git-scm.com/download/win"
        exit 1
    }
    & winget install Git.Git --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
    Refresh-Path
    if (-not (Test-Cmd "git")) {
        Write-Err "Git install failed. Install manually from https://git-scm.com/download/win and re-run."
        exit 1
    }
    Write-Ok "Git installed: $((& git --version 2>&1).Trim())"
}

# --- 1b. Node.js + npm ---
Write-Step "Checking Node.js"
if (Test-Cmd "node") {
    $v = (& node --version 2>&1).Trim()
    Write-Host " $v" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Installing Node.js LTS via winget..."
    if (-not (Test-Cmd "winget")) {
        Write-Err "winget not available. Install Node.js LTS manually: https://nodejs.org"
        exit 1
    }
    & winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent 2>&1 | Out-Null
    Refresh-Path
    if (-not (Test-Cmd "node")) {
        Write-Err "Node.js install failed. Install manually from https://nodejs.org and re-run."
        exit 1
    }
    Write-Ok "Node.js installed: $((& node --version 2>&1).Trim())"
}

# --- 1c. Goose CLI ---
Write-Step "Checking Goose CLI"
if (Test-Cmd "goose") {
    $v = (& goose --version 2>&1).Trim()
    Write-Host " $v" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Downloading Goose CLI from GitHub..."
    $gooseZipUrl = "https://github.com/block/goose/releases/latest/download/goose-x86_64-pc-windows-msvc.zip"
    $gooseTarget = Join-Path $env:USERPROFILE ".local\bin"
    $tempZip = Join-Path $env:TEMP "goose-installer-$([guid]::NewGuid().ToString('N')).zip"
    $tempDir = Join-Path $env:TEMP "goose-extract-$([guid]::NewGuid().ToString('N'))"

    try {
        Invoke-WebRequest -Uri $gooseZipUrl -OutFile $tempZip -UseBasicParsing
        New-Item -ItemType Directory -Path $gooseTarget -Force | Out-Null
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

        $gooseExe = Get-ChildItem -Path $tempDir -Filter "goose.exe" -Recurse | Select-Object -First 1
        if (-not $gooseExe) { throw "goose.exe not found in archive" }

        Get-ChildItem -Path $gooseExe.Directory.FullName -File | ForEach-Object {
            Copy-Item $_.FullName (Join-Path $gooseTarget $_.Name) -Force
        }
        Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

        # Add to persistent user PATH if not already there
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$gooseTarget*") {
            $newPath = if ($userPath) { "$userPath;$gooseTarget" } else { $gooseTarget }
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        }
        if ($env:Path -notlike "*$gooseTarget*") {
            $env:Path = "$env:Path;$gooseTarget"
        }

        if (-not (Test-Cmd "goose")) {
            Write-Err "Goose extracted to $gooseTarget but not on PATH. Open a new terminal and re-run."
            exit 1
        }
        Write-Ok "Goose CLI installed: $((& goose --version 2>&1).Trim())"
    } catch {
        Write-Err "Goose download failed: $_"
        Write-Err "Install manually: https://github.com/block/goose/releases"
        exit 1
    }
}

# --- 1d. Goose desktop app (for browsing recipe YAML) ---
Write-Step "Checking Goose desktop app"
$gooseAppPath = Join-Path $env:LOCALAPPDATA "Programs\Goose\Goose.exe"
if (Test-Path $gooseAppPath) {
    Write-Host " found" -ForegroundColor Green
} else {
    try {
        $gooseAppUrl = "https://github.com/block/goose/releases/latest/download/Goose.zip"
        $appZip = Join-Path $env:TEMP "goose-app-$([guid]::NewGuid().ToString('N')).zip"
        Invoke-WebRequest -Uri $gooseAppUrl -OutFile $appZip -UseBasicParsing
        $appDir = Join-Path $env:TEMP "goose-app-extract"
        Expand-Archive -Path $appZip -DestinationPath $appDir -Force
        $setup = Get-ChildItem -Path $appDir -Filter "*.exe" -Recurse | Select-Object -First 1
        if ($setup) { Start-Process -Wait $setup.FullName }
        Remove-Item $appZip -Force -ErrorAction SilentlyContinue
        Remove-Item $appDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host " installed" -ForegroundColor Green
    } catch {
        Write-Host " skipped (optional)" -ForegroundColor Yellow
    }
}

# --- 1e. Claude CLI ---
Write-Step "Checking Claude CLI"
if (Test-Cmd "claude") {
    $v = (& claude --version 2>&1).Trim()
    Write-Host " $v" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Installing Claude CLI..."
    try {
        $script = Invoke-RestMethod -Uri "https://claude.ai/install.ps1" -UseBasicParsing -TimeoutSec 30
        if ($script -is [byte[]]) { $script = [System.Text.Encoding]::UTF8.GetString($script) }
        Invoke-Expression $script
        $localBin = Join-Path $env:USERPROFILE ".local\bin"
        if ($env:Path -notlike "*$localBin*") { $env:Path = "$env:Path;$localBin" }
        Refresh-Path
    } catch {
        Write-Err "Claude CLI install failed: $_"
        Write-Err "Install manually: irm https://claude.ai/install.ps1 | iex"
        exit 1
    }
    if (-not (Test-Cmd "claude")) {
        Write-Err "Claude CLI installed but not on PATH. Open a new terminal and re-run."
        exit 1
    }
    Write-Ok "Claude CLI installed: $((& claude --version 2>&1).Trim())"
}

# --- 1e. ACP adapter ---
Write-Step "Checking ACP adapter"
$acpOk = $false
try {
    $npmRoot = (& npm root -g 2>$null).Trim()
    $acpPkg = Join-Path $npmRoot "@agentclientprotocol\claude-agent-acp\package.json"
    if (Test-Path $acpPkg) {
        $installed = (Get-Content $acpPkg -Raw | ConvertFrom-Json).version
        if ($installed -eq $ACP_VERSION) { $acpOk = $true }
    }
} catch {}

if ($acpOk) {
    Write-Host " v$ACP_VERSION" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Installing ACP adapter v${ACP_VERSION}..."
    & npm install -g "@agentclientprotocol/claude-agent-acp@$ACP_VERSION" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Err "ACP adapter install failed. Run manually: npm install -g @agentclientprotocol/claude-agent-acp@$ACP_VERSION"
        exit 1
    }
    Refresh-Path
    Write-Ok "ACP adapter installed (v$ACP_VERSION)"
}

# ---------------------------------------------------------------------------
# Phase 2: Clone repo
# ---------------------------------------------------------------------------

Write-Host ""
Write-Step "Setting up goose-wizard repo"
if (Test-Path (Join-Path $InstallDir ".git")) {
    Write-Host " updating" -ForegroundColor Green
    & git -C $InstallDir pull --ff-only 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Err "git pull failed in $InstallDir. Resolve manually and re-run."
        exit 1
    }
    Write-Ok "Repository updated ($InstallDir)"
} elseif (Test-Path $InstallDir) {
    Write-Host ""
    Write-Err "$InstallDir exists but is not a git repo. Move or remove it and re-run."
    exit 1
} else {
    Write-Host " cloning" -ForegroundColor Green
    & git clone --depth 1 $RepoUrl $InstallDir 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Err "git clone failed. Check your network and re-run."
        exit 1
    }
    Write-Ok "Repository cloned ($InstallDir)"
}

# ---------------------------------------------------------------------------
# Phase 3: Configure Goose
# ---------------------------------------------------------------------------

Write-Host ""

# --- 3a. Copy config.yaml ---
Write-Step "Configuring Goose"
$configDir = Join-Path $env:APPDATA "Block\goose\config"
$configPath = Join-Path $configDir "config.yaml"
$sourceConfig = Join-Path $InstallDir "install\config.yaml"

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
if (-not (Test-Path $configPath)) {
    Copy-Item $sourceConfig $configPath
    Write-Host " created config.yaml" -ForegroundColor Green
} else {
    # Config exists — ensure provider/model/mode are set (goose configure
    # creates a config without these, causing "No provider configured").
    $content = Get-Content $configPath -Raw
    $updated = $false
    if ($content -notmatch '(?m)^GOOSE_PROVIDER:') {
        Add-Content $configPath "`nGOOSE_PROVIDER: claude-acp"
        $updated = $true
    }
    if ($content -notmatch '(?m)^GOOSE_MODEL:') {
        Add-Content $configPath "`nGOOSE_MODEL: opus"
        $updated = $true
    }
    if ($content -notmatch '(?m)^GOOSE_MODE:') {
        Add-Content $configPath "`nGOOSE_MODE: smart_approve"
        $updated = $true
    }
    if ($updated) {
        Write-Host " added provider/model/mode to existing config" -ForegroundColor Green
    } else {
        Write-Host " config.yaml already configured" -ForegroundColor Green
    }
}

# --- 3b. Set GOOSE_RECIPE_PATH ---
Write-Step "Setting GOOSE_RECIPE_PATH"
$recipePath = Join-Path $InstallDir "recipes\shared"
[System.Environment]::SetEnvironmentVariable("GOOSE_RECIPE_PATH", $recipePath, "User")
$env:GOOSE_RECIPE_PATH = $recipePath
Write-Host " done" -ForegroundColor Green

# --- 3c. Detect Git Bash and write to Claude settings ---
Write-Step "Detecting Git Bash"
$bashExe = (Get-Command bash.exe -ErrorAction SilentlyContinue)?.Source
if (-not $bashExe) {
    $defaultPath = "C:\Program Files\Git\bin\bash.exe"
    if (Test-Path $defaultPath) { $bashExe = $defaultPath }
}
if (-not $bashExe) {
    # Try deriving from git.exe location
    try {
        $gitExe = (& where.exe git 2>$null | Select-Object -First 1)
        if ($gitExe) {
            $guess = Join-Path (Split-Path -Parent (Split-Path -Parent $gitExe)) "bin\bash.exe"
            if (Test-Path $guess) { $bashExe = $guess }
        }
    } catch {}
}

if ($bashExe) {
    $claudeDir = Join-Path $env:USERPROFILE ".claude"
    $settingsPath = Join-Path $claudeDir "settings.json"
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null

    if (Test-Path $settingsPath) {
        try { $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json }
        catch { $settings = [pscustomobject]@{} }
    } else {
        $settings = [pscustomobject]@{}
    }
    if (-not $settings.PSObject.Properties["env"]) {
        $settings | Add-Member -MemberType NoteProperty -Name "env" -Value ([pscustomobject]@{}) -Force
    }
    $settings.env | Add-Member -MemberType NoteProperty -Name "CLAUDE_CODE_GIT_BASH_PATH" -Value $bashExe -Force
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -NoNewline

    Write-Host " $bashExe" -ForegroundColor Green
} else {
    Write-Host " not found (Claude Code may need manual config)" -ForegroundColor Yellow
}

# --- 3d. Patch ACP adapter ---
Write-Step "Patching ACP adapter"
$npmRoot = $null
try { $npmRoot = (& npm root -g 2>$null).Trim() } catch {}
if (-not $npmRoot) { $npmRoot = Join-Path $env:APPDATA "npm\node_modules" }
$acpFile = Join-Path $npmRoot "@agentclientprotocol\claude-agent-acp\dist\acp-agent.js"

if (Test-Path $acpFile) {
    $content = Get-Content $acpFile -Raw
    $patched = $false

    # Patch 1: Drop "project" scope from settingSources
    $orig1 = 'settingSources: ["user", "project", "local"]'
    $repl1 = 'settingSources: ["user", "local"]'
    if ($content.Contains($orig1)) {
        $content = $content.Replace($orig1, $repl1)
        $patched = $true
    }

    # Patch 2: Disable auto-memory (insert after settingSources line)
    if (-not $content.Contains("autoMemoryEnabled: false")) {
        $memPattern = '(settingSources:\s*\[[^\]]*\],?)'
        if ($content -match $memPattern) {
            $content = [regex]::Replace($content, $memPattern, '$1' + "`n            autoMemoryEnabled: false,", 1)
            $patched = $true
        }
    }

    # Patch 3: Cap thinking tokens at 4096
    $thinkPattern = '(?m)^(?<indent>[ \t]*)const\s+maxThinkingTokens\s*=\s*process\.env\.MAX_THINKING_TOKENS\s*\r?\n\s*\?\s*parseInt\(process\.env\.MAX_THINKING_TOKENS,\s*10\)\s*\r?\n\s*:\s*undefined\s*;'
    $thinkReplace = @'
${indent}const maxThinkingTokens = process.env.MAX_THINKING_TOKENS
${indent}    ? parseInt(process.env.MAX_THINKING_TOKENS, 10)
${indent}    : 4096;
'@
    if ($content -match $thinkPattern) {
        $content = [regex]::Replace($content, $thinkPattern, $thinkReplace, 1)
        $patched = $true
    }

    if ($patched) {
        Set-Content -Path $acpFile -Value $content -NoNewline
        Write-Host " 3 patches applied" -ForegroundColor Green
    } else {
        Write-Host " already patched" -ForegroundColor Green
    }
} else {
    Write-Host " acp-agent.js not found (skipped)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Phase 4: Claude auth
# ---------------------------------------------------------------------------

Write-Host ""
Write-Step "Checking Claude authentication"
$credsPath = Join-Path $env:USERPROFILE ".claude\.credentials.json"
if (Test-Path $credsPath) {
    Write-Host " credentials found" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  Claude needs a one-time login. Launching Claude CLI now..."
    Write-Host "  A browser window will open. Log in, then type /exit to return here."
    Write-Host ""
    try {
        $claudeCmd = (Get-Command "claude" -ErrorAction SilentlyContinue).Source
        if ($claudeCmd -and (Test-Path $claudeCmd)) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c","`"$claudeCmd`"" -NoNewWindow -Wait
        }
    } catch {}
    if (Test-Path $credsPath) {
        Write-Ok "Claude login complete"
    } else {
        Write-Host "  Credentials not detected. Run 'claude' manually to log in." -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# Phase 5: Seed state
# ---------------------------------------------------------------------------

Write-Step "Seeding progression state"

$progressionTarget = Join-Path $InstallDir "progression.json"
$progressionSource = Join-Path $InstallDir "install\project-template\.goose\state\progression.json"
if (-not (Test-Path $progressionTarget)) {
    if (Test-Path $progressionSource) {
        Copy-Item $progressionSource $progressionTarget
        Write-Host " seeded progression.json" -ForegroundColor Green
    } else {
        Write-Host " template not found (skipped)" -ForegroundColor Yellow
    }
} else {
    Write-Host " progression.json exists (skipped)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Phase 6: Success banner
# ---------------------------------------------------------------------------

Write-Host ""
Write-Host ""
Write-Host "  goose-wizard installed successfully!" -ForegroundColor Green
Write-Host ""

# Ensure GOOSE_RECIPE_PATH is live in this session
$env:GOOSE_RECIPE_PATH = "$InstallDir\recipes\shared"

Write-Host "  Launching training..." -ForegroundColor White
Write-Host ""
Set-Location $InstallDir
& goose run --recipe 00-start-here --interactive
