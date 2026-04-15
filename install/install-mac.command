#!/usr/bin/env bash
# ============================================================
#  RILGoose Installer — macOS
#  Double-click this file in Finder to install and configure Goose.
# ============================================================
#
# This installer will:
#   - Install Homebrew if missing
#   - Install Node.js, Goose, Claude CLI, and the ACP adapter if missing
#   - Configure Goose for RILGoose training recipes
#   - Patch the ACP adapter for clean recipe execution
#   - Seed state directories
#
# You'll be prompted to log in to Claude (browser opens) during setup.
# A Claude Max subscription is required.
# ============================================================

set -e

# ------------------------------------------------------------
# Setup: move into the install/ directory (where this script lives)
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RECIPE_ROOT="$PROJECT_ROOT/recipes"

cd "$SCRIPT_DIR"

# Color helpers (no emoji per project convention)
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

say_header()  { printf "\n${CYAN}=== %s ===${NC}\n" "$1"; }
say_phase()   { printf "\n${CYAN}--- %s ---${NC}\n" "$1"; }
say_step()    { printf "\n${YELLOW}%s${NC}\n" "$1"; }
say_ok()      { printf "${GREEN}%s${NC}\n" "$1"; }
say_err()     { printf "${RED}%s${NC}\n" "$1" 1>&2; }

trap 'say_err ""; say_err "Installation failed on line $LINENO."; say_err "Scroll up to see what went wrong."; read -p "Press Enter to close this window." _; exit 1' ERR

say_header "RILGoose Installer (macOS)"

cat <<'EOF'

This installer will:
  - Install Homebrew if missing
  - Install Node.js if missing (via Homebrew)
  - Install Goose if missing (brew install --cask block-goose)
  - Install Claude CLI if missing (npm install -g @anthropic-ai/claude-code)
  - Install the Claude ACP adapter (npm install -g @agentclientprotocol/claude-agent-acp)
  - Configure Goose for RILGoose training recipes
  - Patch the ACP adapter for clean recipe execution

You will be prompted to log in to Claude (browser opens) during setup.
A Claude Max subscription is required.

EOF
read -p "Press Enter to continue, or Ctrl+C to cancel. " _

# ================================================================
# PHASE 1: Bootstrap — install prerequisites if missing
# ================================================================

say_phase "Phase 1: Bootstrap prerequisites"

# --- Homebrew ---
say_step "Checking Homebrew..."
if command -v brew >/dev/null 2>&1; then
    echo "  Homebrew: $(brew --version | head -1) (already installed)"
else
    echo "  Homebrew not found. Installing from the official install script..."
    echo "  (You may be prompted for your Mac password.)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrew on Apple Silicon installs to /opt/homebrew; on Intel to /usr/local.
    # Make sure the current shell can find brew immediately.
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if ! command -v brew >/dev/null 2>&1; then
        say_err "Homebrew installed but 'brew' not on PATH. Close this window and re-run."
        exit 1
    fi
    say_ok "  Homebrew installed."
fi

# --- Node.js ---
say_step "Checking Node.js..."
if command -v node >/dev/null 2>&1; then
    echo "  Node.js: $(node --version) (already installed)"
else
    echo "  Node.js not found. Installing via brew..."
    brew install node
    if ! command -v node >/dev/null 2>&1; then
        say_err "Node.js installed but 'node' not on PATH."
        exit 1
    fi
    say_ok "  Node.js installed: $(node --version)"
fi

# --- Goose ---
say_step "Checking Goose..."
if command -v goose >/dev/null 2>&1; then
    echo "  Goose: $(goose --version 2>&1 | tr -d '[:space:]') (already installed)"
else
    echo "  Goose not found. Installing via brew cask..."
    # --cask block-goose installs both the desktop app and the CLI
    brew install --cask block-goose
    if ! command -v goose >/dev/null 2>&1; then
        # Some setups put the CLI under /Applications/Goose.app/...; retry with hash
        hash -r
        if ! command -v goose >/dev/null 2>&1; then
            say_err "Goose installed but 'goose' not on PATH. Re-open your terminal and re-run, or install manually:"
            say_err "  brew install --cask block-goose"
            exit 1
        fi
    fi
    say_ok "  Goose installed: $(goose --version)"
fi

# --- Claude CLI ---
say_step "Checking Claude CLI..."
if command -v claude >/dev/null 2>&1; then
    echo "  Claude CLI: found (already installed)"
else
    echo "  Claude CLI not found. Installing via npm..."
    npm install -g "@anthropic-ai/claude-code"
    if ! command -v claude >/dev/null 2>&1; then
        say_err "Claude CLI installed but 'claude' not on PATH."
        exit 1
    fi
    say_ok "  Claude CLI installed."
fi

# --- ACP adapter ---
say_step "Checking Claude ACP adapter..."
if command -v claude-agent-acp >/dev/null 2>&1; then
    echo "  ACP adapter: found (already installed)"
else
    echo "  ACP adapter not found. Installing via npm..."
    npm install -g "@agentclientprotocol/claude-agent-acp"
    say_ok "  ACP adapter installed."
fi

# --- Claude auth ---
say_step "Checking Claude authentication..."
echo "  Have you already logged in to Claude with your Claude Max account?"
echo "  (If not, we'll open the login flow now.)"
read -p "  Logged in? [y/N] " AUTH_ANSWER
if [[ ! "$AUTH_ANSWER" =~ ^[Yy] ]]; then
    echo "  Launching Claude login. A browser will open — log in, then come back here."
    claude auth login || true
    read -p "  Press Enter when login is complete. " _
fi

# --- Bootstrap config.yaml if missing ---
say_step "Checking Goose config.yaml..."
CONFIG_DIR="$HOME/.config/goose"
CONFIG_PATH="$CONFIG_DIR/config.yaml"
if [ ! -f "$CONFIG_PATH" ]; then
    echo "  config.yaml not found. Creating minimal config for claude-acp..."
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_PATH" <<'YAML_EOF'
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
YAML_EOF
    say_ok "  Created: $CONFIG_PATH"
else
    echo "  config.yaml exists: $CONFIG_PATH"
fi

say_ok "--- Phase 1 complete ---"

# ================================================================
# PHASE 2: Configure for RILGoose
# ================================================================

say_phase "Phase 2: Configure for RILGoose"

# --- Verify recipe directories ---
say_step "Verifying recipe directories..."
if [ ! -d "$RECIPE_ROOT/shared" ]; then
    say_err "  ERROR: $RECIPE_ROOT/shared not found."
    exit 1
fi
SHARED_COUNT=$(find "$RECIPE_ROOT/shared" -maxdepth 1 -name "*.yaml" | wc -l | tr -d '[:space:]')
AGENTS_COUNT=$(find "$RECIPE_ROOT/agents" -name "*.yaml" 2>/dev/null | wc -l | tr -d '[:space:]')
GRADUATED_COUNT=$(find "$RECIPE_ROOT/graduated" -maxdepth 1 -name "*.yaml" 2>/dev/null | wc -l | tr -d '[:space:]')

echo "  shared/:    $SHARED_COUNT training recipes"
echo "  agents/:    $AGENTS_COUNT agent primitives"
echo "  graduated/: $GRADUATED_COUNT coordinator recipes"

# --- Set GOOSE_RECIPE_PATH in shell rc ---
say_step "Setting GOOSE_RECIPE_PATH..."

# Only shared/ goes on the path — agents/ and graduated/ are invoked as sub_recipes.
RECIPE_PATH_VALUE="$RECIPE_ROOT/shared"

# Pick the right rc file based on the user's current shell
if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$(basename "$SHELL")" = "bash" ]; then
    RC_FILE="$HOME/.bash_profile"
else
    RC_FILE="$HOME/.profile"
fi

touch "$RC_FILE"

# Remove any prior RILGoose-managed block, then append the current one
RILGOOSE_MARKER_START="# >>> RILGoose (managed) >>>"
RILGOOSE_MARKER_END="# <<< RILGoose (managed) <<<"

# Portable in-place delete between markers (BSD sed requires -i '')
if grep -qF "$RILGOOSE_MARKER_START" "$RC_FILE"; then
    # Delete everything between the markers, inclusive
    awk -v start="$RILGOOSE_MARKER_START" -v end="$RILGOOSE_MARKER_END" '
        $0 == start {inblock=1; next}
        $0 == end {inblock=0; next}
        !inblock {print}
    ' "$RC_FILE" > "$RC_FILE.tmp" && mv "$RC_FILE.tmp" "$RC_FILE"
fi

cat >> "$RC_FILE" <<EOF

$RILGOOSE_MARKER_START
export GOOSE_RECIPE_PATH="$RECIPE_PATH_VALUE"
$RILGOOSE_MARKER_END
EOF

export GOOSE_RECIPE_PATH="$RECIPE_PATH_VALUE"
say_ok "  Set GOOSE_RECIPE_PATH in $RC_FILE"
echo "  Value: $RECIPE_PATH_VALUE"

# --- Edit config.yaml: ensure memory + orchestrator on, chatrecall off, model=opus ---
say_step "Updating config.yaml extensions and model..."
python3 - "$CONFIG_PATH" <<'PY_EOF'
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
content = config_path.read_text()

# Enable memory + orchestrator
for ext in ("memory", "orchestrator"):
    pattern = rf"(  {ext}:\s*\n\s*enabled:\s*)false"
    new_content, n = re.subn(pattern, r"\1true", content, count=1)
    if n:
        content = new_content
        print(f"  Enabled: {ext}")
    else:
        print(f"  Already enabled or not found: {ext}")

# Disable chatrecall (prevents cross-session context bleed)
pattern = r"(  chatrecall:\s*\n\s*enabled:\s*)true"
new_content, n = re.subn(pattern, r"\1false", content, count=1)
if n:
    content = new_content
    print("  Disabled: chatrecall (prevents past sessions from overriding recipes)")
else:
    print("  Already disabled or not found: chatrecall")

# Provider check
if "GOOSE_PROVIDER: claude-acp" not in content:
    print("  WARNING: GOOSE_PROVIDER is not claude-acp")
else:
    print("  Provider: claude-acp (OK)")

# Set GOOSE_MODEL to opus
model_match = re.search(r"^GOOSE_MODEL:\s*(\S+)", content, re.M)
if model_match:
    current = model_match.group(1)
    if current != "opus":
        content = re.sub(r"^GOOSE_MODEL:\s*\S+", "GOOSE_MODEL: opus", content, count=1, flags=re.M)
        print(f"  Set GOOSE_MODEL: opus (was: {current})")
    else:
        print("  Model: opus (OK)")
else:
    print("  WARNING: GOOSE_MODEL not found in config")

config_path.write_text(content)
print("  Config saved.")
PY_EOF

# --- Patch ACP adapter (5 patches for clean recipe execution) ---
say_step "Patching ACP adapter (context isolation)..."

NPM_ROOT="$(npm root -g)"
ACP_FILE="$NPM_ROOT/@agentclientprotocol/claude-agent-acp/dist/acp-agent.js"

if [ ! -f "$ACP_FILE" ]; then
    say_err "  WARNING: acp-agent.js not found at $ACP_FILE"
    say_err "  Skipping ACP patches. The recipes may behave unexpectedly without them."
else
    python3 - "$ACP_FILE" <<'PY_EOF'
import re
import sys
from pathlib import Path

acp_path = Path(sys.argv[1])
content = acp_path.read_text()
original = content

# Patch 1: settingSources — only load .claude/CLAUDE.md from project dir
if 'settingSources: ["user", "project", "local"]' in content:
    content = content.replace(
        'settingSources: ["user", "project", "local"]',
        'settingSources: ["local"]',
    )
    print('  Patched: settingSources now ["local"] (prevents CLAUDE.md interference)')
elif 'settingSources: ["local"]' in content:
    print('  Already patched (settingSources = ["local"])')
else:
    print('  WARNING: Could not find settingSources line')

# Patch 2: autoMemoryEnabled — disable Claude Code auto-memory
if "autoMemoryEnabled: false" in content:
    print("  Already patched (autoMemoryEnabled = false)")
elif 'settingSources: ["local"],' in content:
    content = content.replace(
        'settingSources: ["local"],',
        'settingSources: ["local"],\n            autoMemoryEnabled: false,',
    )
    print("  Patched: autoMemoryEnabled = false (prevents memory interference)")
else:
    print("  WARNING: Could not insert autoMemoryEnabled patch")

# Patch 3: enable AskUserQuestion tool
if 'const disallowedTools = ["AskUserQuestion"];' in content:
    content = content.replace(
        'const disallowedTools = ["AskUserQuestion"];',
        'const disallowedTools = [];',
    )
    print("  Patched: AskUserQuestion enabled (allows interactive recipes)")
elif 'const disallowedTools = [];' in content:
    print("  Already patched (AskUserQuestion enabled)")
else:
    print("  WARNING: Could not find disallowedTools line")

# Patch 4: disable extended thinking output
think_orig = (
    "        const maxThinkingTokens = process.env.MAX_THINKING_TOKENS\n"
    "            ? parseInt(process.env.MAX_THINKING_TOKENS, 10)\n"
    "            : undefined;"
)
think_patch = (
    "        // Configure thinking tokens - disabled for clean recipe output\n"
    "        const maxThinkingTokens = 0;"
)
if "const maxThinkingTokens = 0" in content:
    print("  Already patched (thinking disabled)")
elif think_orig in content:
    content = content.replace(think_orig, think_patch)
    print("  Patched: extended thinking disabled (no visible thinking blocks)")
else:
    print("  WARNING: Could not find maxThinkingTokens block")

# Patch 5: replace claude_code preset system prompt with recipe-focused prompt
prompt_orig = 'let systemPrompt = { type: "preset", preset: "claude_code" };'
prompt_patched_marker = "You are an AI assistant running in the Goose agent platform"
prompt_patched_value = (
    'let systemPrompt = "You are an AI assistant running in the Goose agent platform. '
    'Your task comes from a recipe \\u2014 follow its instructions exactly. '
    'Use the available tools (file read/write/edit, shell commands, code analysis) to do the work. '
    'When the recipe says to stop and wait for the user, use AskUserQuestion to pause and get their response before continuing. '
    'Write complete paragraphs, not fragments. Never narrate your reasoning process out loud.";'
)
if prompt_orig in content:
    content = content.replace(prompt_orig, prompt_patched_value)
    print("  Patched: system prompt replaced (recipe-focused)")
elif prompt_patched_marker in content:
    print("  Already patched (custom system prompt)")
else:
    print("  WARNING: Could not find systemPrompt line")

if content != original:
    acp_path.write_text(content)
    print("  Patches written to acp-agent.js")
else:
    print("  No changes needed (all patches already applied)")
PY_EOF
fi

# --- Touch gateway recipe so it sorts first in the app ---
say_step "Ensuring gateway recipe sorts first..."
GATEWAY="$RECIPE_ROOT/shared/00-start-here.yaml"
if [ -f "$GATEWAY" ]; then
    touch "$GATEWAY"
    say_ok "  Touched 00-start-here.yaml (newest modified = first in app)"
else
    echo "  WARNING: Gateway recipe not found at $GATEWAY"
fi

# --- State directories ---
say_step "Ensuring state directories..."
PROJECT_STATE="$PROJECT_ROOT/.goose/state"
RILGOOSE_HOME="$HOME/.rilgoose"
mkdir -p "$PROJECT_STATE" "$RILGOOSE_HOME"
echo "  .goose/state/:  $PROJECT_STATE"
echo "  ~/.rilgoose/:   $RILGOOSE_HOME"

# --- Seed .goose/PROGRESS.md if missing ---
PROGRESS_TARGET="$PROJECT_ROOT/.goose/PROGRESS.md"
PROGRESS_TEMPLATE="$PROJECT_ROOT/install/project-template/.goose/PROGRESS.md"
if [ ! -f "$PROGRESS_TARGET" ]; then
    if [ -f "$PROGRESS_TEMPLATE" ]; then
        cp "$PROGRESS_TEMPLATE" "$PROGRESS_TARGET"
        echo "  Seeded .goose/PROGRESS.md from template"
    else
        echo "  WARNING: .goose/PROGRESS.md template not found at $PROGRESS_TEMPLATE"
    fi
else
    echo "  .goose/PROGRESS.md exists"
fi

# --- Verify recipe list ---
say_step "Verifying recipes are visible to Goose..."
if goose recipe list --format text >/tmp/rilgoose-recipe-check 2>&1; then
    FOUND=$(grep -c '^  \w' /tmp/rilgoose-recipe-check || echo "0")
    rm -f /tmp/rilgoose-recipe-check
    if [ "$FOUND" -gt 0 ]; then
        say_ok "  goose recipe list: $FOUND recipes visible"
    else
        echo "  WARNING: goose recipe list shows no recipes. Open a new terminal and try again."
    fi
else
    echo "  WARNING: goose recipe list failed. You may need to open a new terminal."
fi

# ================================================================
# Summary
# ================================================================
say_header "Setup Complete"

cat <<EOF

What was configured:
  1. Prerequisites installed/verified: Homebrew, Node.js, Goose, Claude CLI, ACP adapter
  2. GOOSE_RECIPE_PATH set in $RC_FILE
  3. Extensions: memory + orchestrator enabled, chatrecall disabled
  4. Provider: claude-acp, Model: opus
  5. ACP adapter patched (5 patches for clean recipe execution)
  6. Gateway recipe touched (appears first in app)
  7. State directories created

Next steps:
  1. Open a NEW terminal window (so GOOSE_RECIPE_PATH loads)
  2. Open the Goose desktop app
  3. Look for "START HERE - Goose Training" at the top of the recipe list
  4. Or from the new terminal:  goose run --recipe start-here

Architecture:
  - Training recipes (shared/) are what developers interact with
  - Agent primitives (agents/) do the work, called via sub_recipes
  - Graduated recipes (graduated/) replace training after completion

EOF

read -p "Press Enter to close this window. " _
