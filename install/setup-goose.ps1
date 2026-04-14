# RILGoose Setup Script
# Sets up Goose desktop app with all course recipes and correct extensions.
# Prerequisites: Goose installed, Claude CLI authenticated, ACP adapter installed.
#
# Usage: powershell -ExecutionPolicy Bypass -File install\setup-goose.ps1
# Or from PowerShell: .\install\setup-goose.ps1
#
# Flags:
#   -IncludeLocal   Also add recipes/local/ to GOOSE_RECIPE_PATH (pipeline/testing recipes)
#   -SkipExtensions Skip updating config.yaml extensions
#   -DryRun         Show what would change without making changes

param(
    [string]$RecipeRoot = "",
    [switch]$IncludeLocal,
    [switch]$SkipExtensions,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "=== RILGoose Setup ===" -ForegroundColor Cyan

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
$agentsCount = (Get-ChildItem -Path $agentsDir -Filter "*.yaml").Count
Write-Host "  agents/: $agentsCount agent primitives"

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

$acpModuleDir = Join-Path $env:APPDATA "npm\node_modules\@agentclientprotocol\claude-agent-acp\dist"
$acpAgentFile = Join-Path $acpModuleDir "acp-agent.js"

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
    $memoryInsertAfter = 'settingSources: ["local"],'
    $memoryLine = '            autoMemoryEnabled: false,'

    if ($acpContent.Contains("autoMemoryEnabled: false")) {
        Write-Host "  Already patched (autoMemoryEnabled = false)"
    } elseif ($acpContent.Contains($memoryInsertAfter)) {
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would disable autoMemoryEnabled"
        } else {
            $acpContent = $acpContent.Replace($memoryInsertAfter, "$memoryInsertAfter`n$memoryLine")
            Write-Host "  Patched: autoMemoryEnabled = false (prevents memory interference)" -ForegroundColor Green
        }
    } else {
        Write-Host "  WARNING: Could not insert autoMemoryEnabled patch" -ForegroundColor Yellow
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
    # which looks confusing to users ("The user wants me to check..."). Setting
    # maxThinkingTokens to 0 disables this.
    $thinkOriginal = 'const maxThinkingTokens = process.env.MAX_THINKING_TOKENS'
    $thinkPatched  = 'const maxThinkingTokens = 0; // process.env.MAX_THINKING_TOKENS'

    if ($acpContent.Contains($thinkOriginal) -and -not $acpContent.Contains($thinkPatched)) {
        $thinkFullOriginal = @'
        const maxThinkingTokens = process.env.MAX_THINKING_TOKENS
            ? parseInt(process.env.MAX_THINKING_TOKENS, 10)
            : undefined;
'@
        $thinkFullPatched = '        // Configure thinking tokens - disabled for clean recipe output' + "`n" + '        const maxThinkingTokens = 0;'

        if ($DryRun) {
            Write-Host "  [DRY RUN] Would disable extended thinking"
        } else {
            $acpContent = $acpContent.Replace($thinkFullOriginal, $thinkFullPatched)
            Write-Host "  Patched: extended thinking disabled (no visible thinking blocks)" -ForegroundColor Green
        }
    } elseif ($acpContent.Contains("const maxThinkingTokens = 0")) {
        Write-Host "  Already patched (thinking disabled)"
    } else {
        Write-Host "  WARNING: Could not find maxThinkingTokens block" -ForegroundColor Yellow
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
if ($agentsCount -lt 28) {
    Write-Host "  WARNING: Expected 29 agent primitives, found $agentsCount" -ForegroundColor Yellow
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
$stateDir = Join-Path (Join-Path (Split-Path -Parent $RecipeRoot) ".goose") "state"
if (-not (Test-Path $stateDir)) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create .goose/state/ for progression tracking"
    } else {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
        Write-Host "  Created .goose/state/ directory for progression tracking"
    }
} else {
    Write-Host "  .goose/state/ directory exists"
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
