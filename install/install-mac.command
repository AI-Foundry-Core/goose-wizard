#!/usr/bin/env bash
# ============================================================
#  RILGoose Installer - macOS
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

set -E  # inherit ERR trap into functions and subshells
trap 'say_err ""; say_err "Installation failed (command: $BASH_COMMAND) on or near line $LINENO."; say_err "Scroll up to see what went wrong."; read -p "Press Enter to close this window." _; exit 1' ERR

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
# PHASE 1: Bootstrap - install prerequisites if missing
# ================================================================

say_phase "Phase 1: Bootstrap prerequisites"

# --- OS version check ---
# Claude Code requires macOS 13.0+.
say_step "Checking macOS version..."
MACOS_VER="$(sw_vers -productVersion 2>/dev/null || echo "0.0.0")"
MACOS_MAJOR="$(echo "$MACOS_VER" | cut -d. -f1)"
if [ "$MACOS_MAJOR" -lt 13 ] 2>/dev/null; then
    say_err "  ERROR: macOS $MACOS_VER is below the minimum (13.0)."
    say_err "         Claude Code will not run. Update macOS and re-run."
    exit 1
fi
echo "  macOS: $MACOS_VER (OK - 13.0+ required)"

# --- Preflight: python3 (needed for config.yaml + ACP patches later) ---
say_step "Checking python3..."
if command -v python3 >/dev/null 2>&1; then
    echo "  python3: $(python3 --version 2>&1)"
else
    say_err "  python3 not found."
    say_err "  macOS 12+ ships a python3 stub that triggers Xcode Command Line Tools install."
    say_err "  Run 'xcode-select --install' in Terminal, accept the dialog, wait for it to finish,"
    say_err "  then re-run this installer."
    exit 1
fi

# --- Preflight: connectivity ---
say_step "Checking network reachability..."
check_url() {
    local url="$1" label="$2"
    if curl --head --silent --fail --max-time 10 "$url" >/dev/null 2>&1; then
        echo "  $label reachable: $url"
        return 0
    else
        echo "  WARNING: cannot reach $label ($url). Check your network / VPN / proxy."
        return 1
    fi
}
GH_OK=1; NPM_OK=1
check_url "https://github.com" "GitHub" || GH_OK=0
check_url "https://registry.npmjs.org" "npm registry" || NPM_OK=0
if [ $GH_OK -eq 0 ] || [ $NPM_OK -eq 0 ]; then
    echo "  Continuing anyway - some downloads may fail."
fi

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

# --- Git (required by Claude Code for repo operations) ---
# On macOS, Git usually ships with Xcode Command Line Tools - but some
# minimal setups don't have it until a brew formula or xcode-select pulls it.
say_step "Checking Git..."
if command -v git >/dev/null 2>&1; then
    echo "  Git: $(git --version) (already installed)"
else
    echo "  Git not found. Installing via brew..."
    brew install git
    if ! command -v git >/dev/null 2>&1; then
        say_err "  Git install failed. Install manually:"
        say_err "    brew install git"
        say_err "  or accept the Xcode Command Line Tools install prompt."
        exit 1
    fi
    say_ok "  Git installed: $(git --version)"
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

# --- Check npm global prefix writability ---
# Intel Homebrew / migrated Macs / locked-down /usr/local commonly EACCES on
# global npm installs. If the prefix isn't writable, switch to a per-user
# prefix at ~/.npm-global instead of failing.
say_step "Checking npm global prefix..."
NPM_PREFIX="$(npm config get prefix)"
echo "  npm prefix: $NPM_PREFIX"
if [ ! -w "$NPM_PREFIX" ] && [ ! -w "$(dirname "$NPM_PREFIX")" ]; then
    echo "  npm global prefix is not writable - switching to per-user prefix at ~/.npm-global"
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    # Persist in rc file so future shells see it
    PERUSER_LINE='export PATH="$HOME/.npm-global/bin:$PATH"'
fi

# --- Claude CLI (native installer; auto-updating, no Node needed) ---
# Anthropic's official installer places the binary at ~/.local/bin/claude.
# Falls back to npm if the native installer fails (e.g. curl blocked).
say_step "Checking Claude CLI..."
if command -v claude >/dev/null 2>&1; then
    echo "  Claude CLI: $(claude --version 2>&1 | head -1) (already installed)"
else
    echo "  Claude CLI not found. Installing via Anthropic native installer..."
    NATIVE_OK=0
    if curl -fsSL https://claude.ai/install.sh | bash; then
        # Ensure ~/.local/bin is on this session's PATH
        if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
        hash -r
        if command -v claude >/dev/null 2>&1; then
            NATIVE_OK=1
            say_ok "  Claude CLI installed via native installer: $(claude --version 2>&1 | head -1)"
        fi
    fi

    if [ "$NATIVE_OK" -eq 0 ]; then
        echo "  WARNING: native installer failed. Falling back to: npm install -g @anthropic-ai/claude-code"
        echo "  (npm install is deprecated by Anthropic but still functional.)"
        npm install -g "@anthropic-ai/claude-code"
        hash -r
        if ! command -v claude >/dev/null 2>&1; then
            say_err "Claude CLI install failed on both native and npm paths."
            say_err "Install manually: curl -fsSL https://claude.ai/install.sh | bash"
            exit 1
        fi
        say_ok "  Claude CLI installed via npm."
    fi
fi

# --- ACP adapter ---
say_step "Checking Claude ACP adapter..."
if command -v claude-agent-acp >/dev/null 2>&1; then
    echo "  ACP adapter: found (already installed)"
else
    echo "  ACP adapter not found. Installing via npm..."
    npm install -g "@agentclientprotocol/claude-agent-acp"
    hash -r
    say_ok "  ACP adapter installed."
fi

# --- Claude auth ---
# Check for existing creds file first; if present, skip the login prompt.
say_step "Checking Claude authentication..."
CLAUDE_CREDS="$HOME/.claude/.credentials.json"
if [ -f "$CLAUDE_CREDS" ]; then
    echo "  Found existing Claude credentials at $CLAUDE_CREDS"
    echo "  Assuming you are logged in. If recipes fail with auth errors later, run 'claude' and re-login."
else
    echo "  No existing Claude credentials found."
    echo "  We'll launch 'claude' - it will open a browser for you to log in with your Claude Max account."
    echo "  After login, type '/exit' or press Ctrl+D to leave the Claude session and return here."
    read -p "  Press Enter to launch Claude login. " _
    claude || true  # interactive; may exit non-zero on /exit
    if [ -f "$CLAUDE_CREDS" ]; then
        say_ok "  Login detected."
    else
        echo "  WARNING: credentials file still not at $CLAUDE_CREDS."
        echo "           Recipe execution will likely fail until you log in. Open a new terminal and run 'claude' to retry."
    fi
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
GOOSE_MODE: smart_approve
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

# --- Claude doctor (verify Claude Code install is healthy) ---
say_step "Running 'claude doctor' to verify install..."
# Use bash's built-in timeout pattern (no `timeout` on stock macOS)
(
    claude doctor 2>&1 &
    DOCTOR_PID=$!
    SECONDS=0
    while kill -0 "$DOCTOR_PID" 2>/dev/null; do
        if [ "$SECONDS" -ge 45 ]; then
            kill "$DOCTOR_PID" 2>/dev/null || true
            echo "  WARNING: 'claude doctor' timed out after 45s. Run it manually later."
            break
        fi
        sleep 1
    done
    wait "$DOCTOR_PID" 2>/dev/null || true
) | sed 's/^/    /' || true
echo "  'claude doctor' completed."

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

# Only shared/ goes on the path - agents/ and graduated/ are invoked as sub_recipes.
RECIPE_PATH_VALUE="$RECIPE_ROOT/shared"

# Pick the right rc file based on the user's LOGIN shell ($SHELL).
# Note: $BASH_VERSION / $ZSH_VERSION reflect the script's interpreter (bash),
# NOT the user's interactive Terminal shell. On macOS Catalina+ the default
# Terminal shell is zsh, so we must prefer $SHELL over *_VERSION vars.
USER_SHELL_NAME="$(basename "${SHELL:-/bin/zsh}")"
case "$USER_SHELL_NAME" in
    zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    bash)
        # On macOS, .bash_profile takes precedence over .bashrc for login shells
        RC_FILE="$HOME/.bash_profile"
        ;;
    fish)
        RC_FILE="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$RC_FILE")"
        ;;
    *)
        echo "  WARNING: unrecognized login shell '$USER_SHELL_NAME'. Falling back to ~/.profile."
        echo "           You may need to set GOOSE_RECIPE_PATH manually for your shell."
        RC_FILE="$HOME/.profile"
        ;;
esac

if [ ! -w "$HOME" ]; then
    say_err "HOME directory $HOME is not writable. Aborting."
    exit 1
fi

touch "$RC_FILE"

# Remove any prior RILGoose-managed block, then append the current one.
# Use substring matching so a marker merged onto another line still triggers
# block removal (prevents duplicate blocks on repeated installs).
RILGOOSE_MARKER_START="# >>> RILGoose (managed) >>>"
RILGOOSE_MARKER_END="# <<< RILGoose (managed) <<<"

if grep -qF "$RILGOOSE_MARKER_START" "$RC_FILE"; then
    awk -v start="$RILGOOSE_MARKER_START" -v end="$RILGOOSE_MARKER_END" '
        index($0, start) { inblock=1; next }
        index($0, end)   { inblock=0; next }
        !inblock { print }
    ' "$RC_FILE" > "$RC_FILE.tmp" && mv "$RC_FILE.tmp" "$RC_FILE"
fi

# Fish uses different syntax - emit the right form for the shell
if [ "$USER_SHELL_NAME" = "fish" ]; then
    cat >> "$RC_FILE" <<EOF

$RILGOOSE_MARKER_START
set -gx GOOSE_RECIPE_PATH "$RECIPE_PATH_VALUE"
${PERUSER_LINE:+set -gx PATH \$HOME/.npm-global/bin \$PATH}
$RILGOOSE_MARKER_END
EOF
else
    cat >> "$RC_FILE" <<EOF

$RILGOOSE_MARKER_START
export GOOSE_RECIPE_PATH="$RECIPE_PATH_VALUE"
${PERUSER_LINE:+$PERUSER_LINE}
$RILGOOSE_MARKER_END
EOF
fi

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

# Set GOOSE_MODE to smart_approve. Default "auto" is too aggressive for
# developers learning to trust the AI; smart_approve auto-approves reads
# and small writes but prompts for destructive actions.
mode_match = re.search(r"^GOOSE_MODE:\s*(\S+)", content, re.M)
if mode_match:
    current = mode_match.group(1)
    if current != "smart_approve":
        content = re.sub(r"^GOOSE_MODE:\s*\S+", "GOOSE_MODE: smart_approve", content, count=1, flags=re.M)
        print(f"  Set GOOSE_MODE: smart_approve (was: {current})")
    else:
        print("  Mode: smart_approve (OK)")
else:
    # Append GOOSE_MODE if missing
    if not content.endswith("\n"):
        content += "\n"
    content += "GOOSE_MODE: smart_approve\n"
    print("  Added GOOSE_MODE: smart_approve (not previously set)")

config_path.write_text(content)
print("  Config saved.")
PY_EOF

# --- Patch ACP adapter (5 patches for clean recipe execution) ---
# Locate acp-agent.js using `npm ls -g --parseable` first (handles nvm / volta /
# version-specific global dirs that `npm root -g` misses), falling back to
# `npm root -g` as a last resort.
say_step "Patching ACP adapter (context isolation)..."

ACP_FILE=""
# Ask npm directly for the package path it knows about
PKG_PATH="$(npm ls -g --parseable "@agentclientprotocol/claude-agent-acp" 2>/dev/null | head -1 || true)"
if [ -n "$PKG_PATH" ] && [ -d "$PKG_PATH" ]; then
    ACP_FILE="$PKG_PATH/dist/acp-agent.js"
fi
# Fallback: compose from npm root -g
if [ -z "$ACP_FILE" ] || [ ! -f "$ACP_FILE" ]; then
    NPM_ROOT="$(npm root -g 2>/dev/null || true)"
    if [ -n "$NPM_ROOT" ]; then
        ACP_FILE="$NPM_ROOT/@agentclientprotocol/claude-agent-acp/dist/acp-agent.js"
    fi
fi

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

# Patch 1: settingSources - only load .claude/CLAUDE.md from project dir
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

# Patch 2: autoMemoryEnabled - disable Claude Code auto-memory
# Tolerate whitespace variations + optional trailing comma in the anchor.
if "autoMemoryEnabled: false" in content:
    print("  Already patched (autoMemoryEnabled = false)")
else:
    anchor_re = re.compile(r'settingSources:\s*\[\s*"local"\s*\],?')
    m = anchor_re.search(content)
    if m:
        content = content[:m.end()] + "\n            autoMemoryEnabled: false," + content[m.end():]
        print("  Patched: autoMemoryEnabled = false (prevents memory interference)")
    else:
        print("  WARNING: Could not insert autoMemoryEnabled patch (Patch 1 may have failed)")

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

# Patch 4: Ensure extended thinking is ENABLED.
# Earlier RILGoose versions disabled thinking (maxThinkingTokens = 0) to hide
# "thinking" blocks. For a teaching audience, visible thinking IS the pitch
# ("look how much the AI reasons through this"), so we re-enable it.
#   - If the upstream env-var expression is still in place, leave it alone
#   - If an earlier RILGoose install set it to 0, restore the upstream
#   - Otherwise, warn but don't fail
if re.search(r"const\s+maxThinkingTokens\s*=\s*process\.env\.MAX_THINKING_TOKENS", content):
    print("  Thinking: already at upstream default (enabled / env-var gated)")
elif re.search(r"const\s+maxThinkingTokens\s*=\s*0\b", content):
    restored = (
        "        const maxThinkingTokens = process.env.MAX_THINKING_TOKENS\n"
        "            ? parseInt(process.env.MAX_THINKING_TOKENS, 10)\n"
        "            : undefined;"
    )
    content = re.sub(
        r"(?m)^[ \t]*const\s+maxThinkingTokens\s*=\s*0[^;]*;\s*(?://[^\n]*)?",
        restored,
        content,
        count=1,
    )
    print("  Patched: re-enabled extended thinking (reverted prior RILGoose patch)")
else:
    print("  Thinking: maxThinkingTokens block not found; leaving upstream behavior untouched")

# Patch 5: replace claude_code preset system prompt with recipe-focused prompt.
# MUST include the pre-tool-call announcement line - Goose's approval dialog
# renders the model's natural-language preface before "approve this tool?".
# Without that line, users see a generic prompt with no context about what
# the tool call will actually do.
# Use a tolerant regex so we can re-patch over any previous RILGoose version.
prompt_re = re.compile(
    r'let\s+systemPrompt\s*=\s*(\{[^}]*\}|"(?:[^"\\]|\\.)*")\s*;',
    re.DOTALL,
)
prompt_patched_value = (
    'let systemPrompt = "You are an AI assistant running in the Goose agent platform. '
    'Your task comes from a recipe \\u2014 follow its instructions exactly. '
    'Use the available tools (file read/write/edit, shell commands, code analysis) to do the work. '
    'Before running any tool, write one short sentence (under 20 words) naming the tool and what you are about to do with it, '
    'so the user knows what they are approving when the permission dialog appears. '
    'When the recipe says to stop and wait for the user, use AskUserQuestion to pause and get their response before continuing. '
    'Write complete paragraphs, not fragments.";'
)
# Marker text that only exists in the CURRENT prompt - distinguishes
# "already up-to-date" from "patched with an older version that needs upgrade".
current_marker = "user knows what they are approving"
if current_marker in content:
    print("  Already patched (current prompt with pre-tool announcement)")
elif prompt_re.search(content):
    content = prompt_re.sub(prompt_patched_value, content, count=1)
    print("  Patched: system prompt replaced (recipe-focused, with pre-tool announcement)")
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
RECIPE_CHECK_TMP="/tmp/rilgoose-recipe-check-$$"
if goose recipe list --format text >"$RECIPE_CHECK_TMP" 2>&1; then
    # `grep -c` returns exit 1 on no-match, which would trigger the ERR trap
    # inside `$(...)`. Capture into a plain var, defaulting to 0 if empty.
    FOUND=$(grep -c '^  [[:alpha:]]' "$RECIPE_CHECK_TMP" 2>/dev/null || true)
    FOUND="${FOUND:-0}"
    rm -f "$RECIPE_CHECK_TMP"
    if [ "$FOUND" -gt 0 ] 2>/dev/null; then
        say_ok "  goose recipe list: $FOUND recipes visible"
    else
        echo "  WARNING: goose recipe list shows no recipes. Open a new terminal and try again."
    fi
else
    rm -f "$RECIPE_CHECK_TMP"
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
