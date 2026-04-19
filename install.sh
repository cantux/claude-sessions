#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$REPO_DIR/bin/claude-sessions"
BIN_LINK="$HOME/.local/bin/claude-sessions"
PYTHON_MIN_MAJOR=3
PYTHON_MIN_MINOR=6

# ── colours ──────────────────────────────────────────────────────────────────
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
info()  { printf '  %s\n' "$*"; }

# ── helpers ───────────────────────────────────────────────────────────────────
die() { red "Error: $*"; exit 1; }

check_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        info "OS: $PRETTY_NAME"
    fi
    if [[ "$(uname -s)" != "Linux" ]]; then
        die "This installer targets Linux (detected: $(uname -s))"
    fi
}

check_python() {
    local python_bin=""
    for candidate in python3 python; do
        if command -v "$candidate" &>/dev/null; then
            local ver
            ver=$("$candidate" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
            local major="${ver%%.*}"
            local minor="${ver##*.}"
            if [[ "$major" -ge "$PYTHON_MIN_MAJOR" && "$minor" -ge "$PYTHON_MIN_MINOR" ]]; then
                python_bin="$candidate"
                info "Python: $("$candidate" --version)  [$("$candidate" -c 'import sys; print(sys.executable)')]"
                break
            fi
        fi
    done

    if [[ -z "$python_bin" ]]; then
        yellow "Python $PYTHON_MIN_MAJOR.$PYTHON_MIN_MINOR+ not found."
        if command -v conda &>/dev/null; then
            echo "  conda detected — creating a 'claude-sessions' environment with Python 3.12"
            conda create -y -n claude-sessions python=3.12
            # shellcheck source=/dev/null
            source "$(conda info --base)/etc/profile.d/conda.sh"
            conda activate claude-sessions
            info "conda env: claude-sessions (Python $(python3 --version))"
        else
            die "Python $PYTHON_MIN_MAJOR.$PYTHON_MIN_MINOR+ required. Install it with:\n  sudo dnf install python3   (CentOS/RHEL)\n  or install conda: https://docs.conda.io/en/latest/miniconda.html"
        fi
    fi
}

check_claude() {
    # Check common install locations
    local found=""
    for candidate in \
        "$HOME/.local/bin/claude" \
        "$HOME/.local/share/claude/versions/"* \
        /usr/local/bin/claude \
        /usr/bin/claude
    do
        if [[ -x "$candidate" ]]; then
            found="$candidate"
            break
        fi
    done

    if command -v claude &>/dev/null; then
        info "claude: $(command -v claude)"
    elif [[ -n "$found" ]]; then
        yellow "claude found at $found but not in PATH (PATH will be fixed below)"
    else
        yellow "claude CLI not found."
        echo
        echo "  Install it with Anthropic's installer:"
        echo "    curl -fsSL https://claude.ai/install.sh | sh"
        echo
        echo "  claude-sessions will be installed, but 'claude-sessions run/resume'"
        echo "  will not work until claude is installed."
        echo
    fi
}

install_symlink() {
    mkdir -p "$HOME/.local/bin"

    if [[ -L "$BIN_LINK" ]]; then
        local current_target
        current_target=$(readlink "$BIN_LINK")
        if [[ "$current_target" == "$BIN_SRC" ]]; then
            info "Symlink already up to date: $BIN_LINK"
            return
        fi
        yellow "Replacing existing symlink: $BIN_LINK -> $current_target"
        rm "$BIN_LINK"
    elif [[ -f "$BIN_LINK" ]]; then
        die "$BIN_LINK exists as a regular file; remove it manually first"
    fi

    chmod +x "$BIN_SRC"
    ln -s "$BIN_SRC" "$BIN_LINK"
    info "Installed: $BIN_LINK -> $BIN_SRC"
}

ensure_path() {
    local shell_rc=""
    if [[ -f "$HOME/.bashrc" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        shell_rc="$HOME/.bash_profile"
    fi

    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        yellow "~/.local/bin not in current PATH"
        if [[ -n "$shell_rc" ]]; then
            cat >> "$shell_rc" <<'EOF'

# Added by claude-sessions installer
if ! [[ "$PATH" =~ "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
EOF
            info "Added ~/.local/bin to PATH in $shell_rc"
            info "Run: source $shell_rc"
        else
            yellow "Add ~/.local/bin to your PATH manually"
        fi
    else
        info "PATH: ~/.local/bin already present"
    fi
}

create_exports_dir() {
    mkdir -p "$HOME/.claude/exports"
    info "Export dir: $HOME/.claude/exports"
}

# ── main ──────────────────────────────────────────────────────────────────────
echo
echo "Installing claude-sessions"
echo "─────────────────────────"

check_os
check_python
check_claude
install_symlink
ensure_path
create_exports_dir

echo
green "Done. Run: claude-sessions --help"
echo
