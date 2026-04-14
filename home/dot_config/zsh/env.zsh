# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ env.zsh - Environment Variables & PATH                                    ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║ Defines environment variables, tool directories, and PATH configuration.  ║
# ║ Sourced from .zshenv so these are available to all programs and scripts,  ║
# ║ not just interactive shells.                                              ║
# ║                                                                           ║
# ║ This is the right place for:                                              ║
# ║   - XDG base directories (where apps store data/config/cache)             ║
# ║   - Tool home directories (CARGO_HOME, PNPM_HOME, etc.)                   ║
# ║   - PATH modifications (order matters - earlier entries take precedence)  ║
# ║   - EDITOR, LANG, and other environment variables                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# ───────────────────────────────────────────────────────────────────────────────
# Portable Environment Variables
# Shared with chezmoi scripts - see env.sh for definitions
# ───────────────────────────────────────────────────────────────────────────────
source "${ZDOTDIR:-$HOME/.config/zsh}/env.sh"

# ───────────────────────────────────────────────────────────────────────────────
# Locale & Editor
# ───────────────────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export EDITOR="nvim"

# ───────────────────────────────────────────────────────────────────────────────
# Resource Limits
# ───────────────────────────────────────────────────────────────────────────────
# Raise open file descriptor limit (default 256 is often too low for dev servers,
# Node.js, etc.). Caps at system hard limit if 65536 isn't allowed.
ulimit -n 65536 2>/dev/null || true

# ───────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# Order matters: earlier entries take precedence
# ───────────────────────────────────────────────────────────────────────────────
# Prevent duplicate PATH entries. typeset -U is a zsh array attribute and is
# not inherited by child shells, so it must be set in every shell's env setup.
typeset -U path

# Homebrew (Apple Silicon path, must be first to shadow system tools)
if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Local user scripts (~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"

# Cargo-installed binaries
export PATH="$CARGO_HOME/bin:$PATH"

# pnpm global binaries
export PATH="$PNPM_HOME:$PATH"

# Proto toolchain manager
# Interactive shells get dynamic version switching via chpwd hook in .zshrc.
# Non-interactive shells (scripts, sandboxed commands) need the tool
# directories added to PATH here since .zshrc never runs for them.
export PATH="$PROTO_HOME/bin:$PATH"
if [[ ! -o interactive ]] && command -v proto &>/dev/null; then
    eval "$(proto activate zsh --no-shim --export)"
fi

# Homebrew-specific setup (macOS only)
if command -v brew &>/dev/null; then
    # Initialize Homebrew environment (sets HOMEBREW_PREFIX, etc.)
    eval "$(brew shellenv)"
    # Rust toolchain (installed via Homebrew)
    export PATH="$(brew --prefix rustup)/bin:$PATH"
fi
