# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ env.zsh - Environment Variables & PATH                                    ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║ SOURCED: From .zshenv (all shell types)                                   ║
# ║ PURPOSE: Define environment variables, tool directories, and PATH         ║
# ║                                                                           ║
# ║ Variables here are available to all programs, not just interactive shells.║
# ║ This is the right place for PATH, EDITOR, and tool home directories.      ║
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
export EDITOR="cursor --wait"  # --wait keeps terminal blocked until file is closed

# ───────────────────────────────────────────────────────────────────────────────
# Tool Home Directories (XDG-compliant locations)
# ───────────────────────────────────────────────────────────────────────────────
export CARGO_HOME="$XDG_DATA_HOME/cargo"     # Rust packages
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"   # Rust toolchain manager
export PNPM_HOME="$XDG_DATA_HOME/pnpm"       # pnpm global packages

# ───────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# Order matters: earlier entries take precedence
# ───────────────────────────────────────────────────────────────────────────────

# Homebrew (Apple Silicon path, must be first to shadow system tools)
if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Rust toolchain
export PATH="$(brew --prefix rustup)/bin:$PATH"

# Local user scripts (~/.local/bin)
export PATH="$HOME/.local/bin:$PATH"

# Cargo-installed binaries
export PATH="$CARGO_HOME/bin:$PATH"

# pnpm global binaries
export PATH="$PNPM_HOME:$PATH"

# Initialize Homebrew environment (sets HOMEBREW_PREFIX, etc.)
eval "$(brew shellenv)"
