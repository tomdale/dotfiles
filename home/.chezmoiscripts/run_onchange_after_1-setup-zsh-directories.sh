#!/bin/bash

set -euo pipefail

# Source shared environment variables (deployed by chezmoi before scripts run)
# shellcheck source=/dev/null
source "$HOME/.config/zsh/env.sh"

# ZDOTDIR is set in .zshenv, define here for this script
ZDOTDIR="$XDG_CONFIG_HOME/zsh"

echo "Setting up zsh directories..."

# Create XDG base directories
mkdir -p "$XDG_DATA_HOME"
mkdir -p "$XDG_STATE_HOME"
mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CACHE_HOME"

# Create zsh-specific directories
mkdir -p "$ZDOTDIR"                          # ~/.config/zsh
mkdir -p "$XDG_STATE_HOME/zsh"              # for history file
mkdir -p "$XDG_CACHE_HOME/zsh"              # for zsh cache

echo "✓ All zsh directories created successfully"
