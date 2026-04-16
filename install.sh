#!/usr/bin/env bash
# ============================================================
#  goose-wizard installer
#  Usage: curl -fsSL https://raw.githubusercontent.com/AI-Foundry-Core/goose-wizard/main/install.sh | bash
#
#  Installs prerequisites, clones the repo, configures Goose,
#  patches the ACP adapter, and seeds initial state.
#  Idempotent — safe to run multiple times.
# ============================================================

set -euo pipefail

ACP_PINNED_VERSION="0.28.0"
INSTALL_DIR="$HOME/goose-wizard"
REPO_URL="https://github.com/AI-Foundry-Core/goose-wizard.git"

# ---- Color support ----
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    GREEN="$(tput setaf 2)"
    RED="$(tput setaf 1)"
    BOLD="$(tput bold)"
    RESET="$(tput sgr0)"
else
    GREEN=""
    RED=""
    BOLD=""
    RESET=""
fi

# ---- Output helpers ----
info()  { printf "  %s\n" "$1"; }
ok()    { printf "  ${GREEN}[ok]${RESET} %s\n" "$1"; }
err()   { printf "  ${RED}[error]${RESET} %s\n" "$1" >&2; }
fatal() { err "$1"; exit 1; }

COL_WIDTH=42
step() {
    local label="$1"
    shift
    printf "  %-${COL_WIDTH}s" "${label}..."
    local output
    output=$("$@" 2>&1) && true
    local rc=$?
    if [ $rc -eq 0 ]; then
        printf "${GREEN}%s${RESET}\n" "$output"
    else
        printf "${RED}%s${RESET}\n" "$output"
        return $rc
    fi
}

# ---- Detect OS ----
OS="$(uname -s)"
case "$OS" in
    Darwin) PLATFORM="macos" ;;
    Linux)  PLATFORM="linux" ;;
    *)      fatal "Unsupported OS: $OS. This installer supports macOS and Linux." ;;
esac

printf "\n${BOLD}goose-wizard installer${RESET}  (%s)\n\n" "$PLATFORM"

# ================================================================
# Phase 1: Prerequisites
# ================================================================

info "Phase 1: Prerequisites"
echo ""

# ---- 1. Git ----
check_git() {
    if command -v git >/dev/null 2>&1; then
        echo "found ($(git --version | sed 's/git version //'))"
        return 0
    fi
    # attempt install
    if [ "$PLATFORM" = "macos" ]; then
        xcode-select --install 2>/dev/null || true
        # xcode-select is async; wait a moment and recheck
        sleep 2
    else
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -qq && sudo apt-get install -y -qq git >/dev/null
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y -q git >/dev/null
        fi
    fi
    if command -v git >/dev/null 2>&1; then
        echo "installed ($(git --version | sed 's/git version //'))"
        return 0
    fi
    echo "missing"
    return 1
}
step "Checking Git" check_git || fatal "Git is required. Install it and re-run."

# ---- 2. Homebrew (macOS only) ----
if [ "$PLATFORM" = "macos" ]; then
    check_brew() {
        # Source shellenv if brew exists but isn't on PATH (Finder-launched shells)
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        fi
        if command -v brew >/dev/null 2>&1; then
            echo "found ($(brew --version 2>&1 | head -1 | sed 's/Homebrew //'))"
            return 0
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/null >/dev/null 2>&1
        # Re-source after install
        if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
        elif [ -x /usr/local/bin/brew ]; then
            eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        fi
        if command -v brew >/dev/null 2>&1; then
            echo "installed"
            return 0
        fi
        echo "missing"
        return 1
    }
    step "Checking Homebrew" check_brew || fatal "Homebrew is required on macOS. Install from https://brew.sh and re-run."
fi

# ---- 3. Node.js + npm ----
check_node() {
    if command -v node >/dev/null 2>&1; then
        echo "found ($(node --version))"
        return 0
    fi
    if [ "$PLATFORM" = "macos" ]; then
        brew install node >/dev/null 2>&1
    fi
    if command -v node >/dev/null 2>&1; then
        echo "installed ($(node --version))"
        return 0
    fi
    echo "missing"
    return 1
}
step "Checking Node.js" check_node || {
    if [ "$PLATFORM" = "linux" ]; then
        fatal "Node.js is required. Install from https://nodejs.org or via your package manager."
    else
        fatal "Node.js is required. Run 'brew install node' and re-run."
    fi
}

# ---- 4. Goose CLI ----
check_goose() {
    if command -v goose >/dev/null 2>&1; then
        echo "found ($(goose --version 2>&1 | tr -d '[:space:]'))"
        return 0
    fi
    if [ "$PLATFORM" = "macos" ]; then
        brew install block-goose-cli >/dev/null 2>&1
        hash -r 2>/dev/null || true
        if command -v goose >/dev/null 2>&1; then
            echo "installed ($(goose --version 2>&1 | tr -d '[:space:]'))"
            return 0
        fi
    fi
    echo "missing"
    return 1
}
step "Checking Goose CLI" check_goose || {
    if [ "$PLATFORM" = "linux" ]; then
        fatal "Goose CLI is required. Install from https://block.github.io/goose/docs/getting-started/installation"
    else
        fatal "Goose CLI install failed. Run 'brew install block-goose-cli' and re-run."
    fi
}

# ---- 4b. Goose desktop app (for browsing recipe YAML) ----
check_goose_app() {
    if [ "$PLATFORM" = "macos" ] && [ -d "/Applications/Goose.app" ]; then
        echo "found"
        return 0
    fi
    if [ "$PLATFORM" = "macos" ]; then
        brew install --cask block-goose >/dev/null 2>&1
        if [ -d "/Applications/Goose.app" ]; then
            echo "installed"
            return 0
        fi
    fi
    echo "skipped (optional)"
    return 0
}
step "Checking Goose desktop app" check_goose_app

# ---- 5. Claude CLI ----
check_claude() {
    if command -v claude >/dev/null 2>&1; then
        echo "found ($(claude --version 2>&1 | head -1))"
        return 0
    fi
    curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1
    # Ensure ~/.local/bin is on PATH for this session
    if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    hash -r 2>/dev/null || true
    if command -v claude >/dev/null 2>&1; then
        echo "installed ($(claude --version 2>&1 | head -1))"
        return 0
    fi
    echo "missing"
    return 1
}
step "Checking Claude CLI" check_claude || fatal "Claude CLI install failed. Visit https://claude.ai/install.sh"

# ---- 6. ACP adapter ----
check_acp() {
    local installed=""
    local npm_root
    npm_root="$(npm root -g 2>/dev/null || true)"
    if [ -n "$npm_root" ] && [ -f "$npm_root/@agentclientprotocol/claude-agent-acp/package.json" ]; then
        installed="$(node -e "console.log(require('$npm_root/@agentclientprotocol/claude-agent-acp/package.json').version)" 2>/dev/null || true)"
    fi
    if [ "$installed" = "$ACP_PINNED_VERSION" ]; then
        echo "found ($installed)"
        return 0
    fi
    npm install -g "@agentclientprotocol/claude-agent-acp@$ACP_PINNED_VERSION" >/dev/null 2>&1
    hash -r 2>/dev/null || true
    echo "installed ($ACP_PINNED_VERSION)"
    return 0
}
step "Checking ACP adapter" check_acp || fatal "ACP adapter install failed."

echo ""

# ================================================================
# Phase 2: Clone repo
# ================================================================

info "Phase 2: Clone repository"
echo ""

if [ -d "$INSTALL_DIR/.git" ]; then
    step "Updating goose-wizard" bash -c "git -C '$INSTALL_DIR' pull --ff-only 2>&1 | tail -1"
elif [ -d "$INSTALL_DIR" ]; then
    fatal "$INSTALL_DIR exists but is not a git repo. Remove or rename it and re-run."
else
    step "Cloning goose-wizard" bash -c "git clone --depth 1 '$REPO_URL' '$INSTALL_DIR' 2>&1 | tail -1"
fi

echo ""

# ================================================================
# Phase 3: Configure Goose
# ================================================================

info "Phase 3: Configure Goose"
echo ""

# ---- Copy config.yaml if missing ----
CONFIG_DIR="$HOME/.config/goose"
CONFIG_PATH="$CONFIG_DIR/config.yaml"
SOURCE_CONFIG="$INSTALL_DIR/install/config.yaml"

mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_PATH" ]; then
    if [ -f "$SOURCE_CONFIG" ]; then
        cp "$SOURCE_CONFIG" "$CONFIG_PATH"
        ok "Copied config.yaml"
    else
        err "Source config not found at $SOURCE_CONFIG"
    fi
else
    # Config exists — ensure provider/model/mode are set (goose configure
    # creates a config without these, which causes "No provider configured").
    needs_update=false
    grep -q "^GOOSE_PROVIDER:" "$CONFIG_PATH" || needs_update=true
    grep -q "^GOOSE_MODEL:" "$CONFIG_PATH" || needs_update=true
    grep -q "^GOOSE_MODE:" "$CONFIG_PATH" || needs_update=true
    if [ "$needs_update" = true ]; then
        # Merge: append our config keys without clobbering user extensions
        grep -q "^GOOSE_PROVIDER:" "$CONFIG_PATH" || echo "GOOSE_PROVIDER: claude-acp" >> "$CONFIG_PATH"
        grep -q "^GOOSE_MODEL:" "$CONFIG_PATH" || echo "GOOSE_MODEL: opus" >> "$CONFIG_PATH"
        grep -q "^GOOSE_MODE:" "$CONFIG_PATH" || echo "GOOSE_MODE: smart_approve" >> "$CONFIG_PATH"
        ok "Added provider/model/mode to existing config"
    else
        ok "config.yaml already configured"
    fi
fi

# ---- Set GOOSE_RECIPE_PATH in shell rc ----
RECIPE_PATH_VALUE="$INSTALL_DIR/recipes/shared"
USER_SHELL_NAME="$(basename "${SHELL:-/bin/bash}")"

case "$USER_SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash)
        if [ "$PLATFORM" = "macos" ]; then
            RC_FILE="$HOME/.bash_profile"
        else
            RC_FILE="$HOME/.bashrc"
        fi
        ;;
    fish)
        RC_FILE="$HOME/.config/fish/config.fish"
        mkdir -p "$(dirname "$RC_FILE")"
        ;;
    *)
        RC_FILE="$HOME/.profile"
        info "Unrecognized shell '$USER_SHELL_NAME'. Using $RC_FILE."
        ;;
esac

touch "$RC_FILE"

MARKER_START="# >>> goose-wizard (managed) >>>"
MARKER_END="# <<< goose-wizard (managed) <<<"

# Remove existing managed block if present
if grep -qF "$MARKER_START" "$RC_FILE" 2>/dev/null; then
    awk -v start="$MARKER_START" -v end="$MARKER_END" '
        index($0, start) { inblock=1; next }
        index($0, end)   { inblock=0; next }
        !inblock { print }
    ' "$RC_FILE" > "$RC_FILE.tmp" && mv "$RC_FILE.tmp" "$RC_FILE"
fi

# Write the managed block
if [ "$USER_SHELL_NAME" = "fish" ]; then
    cat >> "$RC_FILE" <<EOF

$MARKER_START
set -gx GOOSE_RECIPE_PATH "$RECIPE_PATH_VALUE"
$MARKER_END
EOF
else
    cat >> "$RC_FILE" <<EOF

$MARKER_START
export GOOSE_RECIPE_PATH="$RECIPE_PATH_VALUE"
$MARKER_END
EOF
fi

export GOOSE_RECIPE_PATH="$RECIPE_PATH_VALUE"
ok "Set GOOSE_RECIPE_PATH in $RC_FILE"

# ---- Patch ACP adapter ----
ACP_FILE=""
PKG_PATH="$(npm ls -g --parseable "@agentclientprotocol/claude-agent-acp" 2>/dev/null | head -1 || true)"
if [ -n "$PKG_PATH" ] && [ -d "$PKG_PATH" ]; then
    ACP_FILE="$PKG_PATH/dist/acp-agent.js"
fi
if [ -z "$ACP_FILE" ] || [ ! -f "$ACP_FILE" ]; then
    NPM_ROOT="$(npm root -g 2>/dev/null || true)"
    if [ -n "$NPM_ROOT" ]; then
        ACP_FILE="$NPM_ROOT/@agentclientprotocol/claude-agent-acp/dist/acp-agent.js"
    fi
fi

if [ -f "$ACP_FILE" ]; then
    python3 - "$ACP_FILE" <<'PY_EOF'
import re, sys
from pathlib import Path

acp = Path(sys.argv[1])
content = acp.read_text()
original = content
patches = 0

# Patch 1: settingSources — drop "project" scope
if 'settingSources: ["user", "project", "local"]' in content:
    content = content.replace(
        'settingSources: ["user", "project", "local"]',
        'settingSources: ["user", "local"]',
    )
    patches += 1
elif 'settingSources: ["local"]' in content:
    content = content.replace(
        'settingSources: ["local"]',
        'settingSources: ["user", "local"]',
    )
    patches += 1

# Patch 2: autoMemoryEnabled — disable auto-memory
if "autoMemoryEnabled: false" not in content:
    anchor = re.compile(r'settingSources:\s*\[[^\]]*\],?')
    m = anchor.search(content)
    if m:
        content = content[:m.end()] + "\n            autoMemoryEnabled: false," + content[m.end():]
        patches += 1

# Patch 3: maxThinkingTokens — cap at 4096
thinking_re = re.compile(
    r"(?P<indent>[ \t]*)const\s+maxThinkingTokens\s*=\s*process\.env\.MAX_THINKING_TOKENS\s*\n"
    r"\s*\?\s*parseInt\(process\.env\.MAX_THINKING_TOKENS,\s*10\)\s*\n"
    r"\s*:\s*undefined\s*;"
)
m = thinking_re.search(content)
if m:
    indent = m.group("indent")
    content = content[:m.start()] + (
        f"{indent}const maxThinkingTokens = process.env.MAX_THINKING_TOKENS\n"
        f"{indent}    ? parseInt(process.env.MAX_THINKING_TOKENS, 10)\n"
        f"{indent}    : 4096;"
    ) + content[m.end():]
    patches += 1

if content != original:
    acp.write_text(content)
    print(f"{patches} patch(es) applied")
else:
    print("already patched")
PY_EOF
    step "Patching ACP adapter" echo "done"
else
    info "WARNING: acp-agent.js not found. Skipping ACP patches."
fi

echo ""

# ================================================================
# Phase 4: Claude auth
# ================================================================

info "Phase 4: Claude authentication"
echo ""

# Claude Code stores auth in different locations depending on the auth method.
# Check for OAuth credentials file or test with `claude -p` (quick, non-interactive).
claude_is_authed() {
    [ -f "$HOME/.claude/.credentials.json" ] && return 0
    claude -p "hello" >/dev/null 2>&1 && return 0
    return 1
}

if claude_is_authed; then
    ok "Claude is authenticated"
else
    info "Not authenticated. Launching Claude for login..."
    info "(After login, type /exit to return here.)"
    # Run claude interactively with explicit tty
    claude </dev/tty || true
    if claude_is_authed; then
        ok "Login successful"
    else
        info "WARNING: Auth not detected. Run 'claude' manually to log in."
    fi
fi

echo ""

# ================================================================
# Phase 5: Seed state
# ================================================================

info "Phase 5: Seed state"
echo ""

mkdir -p "$HOME/.goose-wizard"

PROGRESSION_SRC="$INSTALL_DIR/install/project-template/.goose/state/progression.json"
PROGRESSION_DST="$HOME/.goose-wizard/progression.json"
if [ ! -f "$PROGRESSION_DST" ] && [ -f "$PROGRESSION_SRC" ]; then
    cp "$PROGRESSION_SRC" "$PROGRESSION_DST"
    ok "Seeded progression.json"
else
    ok "progression.json already exists"
fi

# Touch gateway recipe so it sorts first in the Goose app
GATEWAY="$INSTALL_DIR/recipes/shared/00-start-here.yaml"
if [ -f "$GATEWAY" ]; then
    touch "$GATEWAY"
fi

echo ""

# ================================================================
# Phase 6: Success
# ================================================================

printf "\n${GREEN}${BOLD}  goose-wizard installed successfully!${RESET}\n"
echo ""

# Source the shell rc so GOOSE_RECIPE_PATH is live in this session
export GOOSE_RECIPE_PATH="$INSTALL_DIR/recipes/shared"

info "Launching training..."
echo ""
cd "$INSTALL_DIR"
exec goose run --recipe 00-start-here --interactive </dev/tty
