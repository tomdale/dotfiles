# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║ env.sh - Portable Environment Variables                                   ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║ POSIX-compatible environment variables that can be sourced by both zsh    ║
# ║ and bash. Used by shell config AND chezmoi scripts during setup.          ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Tool Directories (derived from XDG_DATA_HOME)
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export PROTO_HOME="$XDG_DATA_HOME/proto"

# Clear the legacy Oh My Zsh installation path inherited by child shells.
unset ZSH
