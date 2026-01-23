# Environment variables and PATH setup
# Sourced from .zshenv for all shell types

# XDG Base Directory Specification
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Locale
export LANG="en_US.UTF-8"

# Editor
export EDITOR="cursor --wait"

# Tool directories (XDG-compliant)
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"

# PATH setup
if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

export PATH="$(brew --prefix rustup)/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
eval "$(brew shellenv)"
