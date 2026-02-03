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
# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/latest/
# ───────────────────────────────────────────────────────────────────────────────
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # User data files
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # Persistent state (logs, history)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # User config files
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"       # Non-essential cached data

# ───────────────────────────────────────────────────────────────────────────────
# Locale & Editor
# ───────────────────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export EDITOR="nvim"

# ───────────────────────────────────────────────────────────────────────────────
# Tool Directories
# ───────────────────────────────────────────────────────────────────────────────
export CARGO_HOME="$XDG_DATA_HOME/cargo"     # Rust packages
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"   # Rust toolchain manager
export PNPM_HOME="$XDG_DATA_HOME/pnpm"       # pnpm global packages
export ZSH="$XDG_DATA_HOME/oh-my-zsh"        # Installation directory

# ───────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# Order matters: earlier entries take precedence
# ───────────────────────────────────────────────────────────────────────────────

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

# Homebrew-specific setup (macOS only)
if command -v brew &>/dev/null; then
    # Initialize Homebrew environment (sets HOMEBREW_PREFIX, etc.)
    eval "$(brew shellenv)"
    # Rust toolchain (installed via Homebrew)
    export PATH="$(brew --prefix rustup)/bin:$PATH"
fi
