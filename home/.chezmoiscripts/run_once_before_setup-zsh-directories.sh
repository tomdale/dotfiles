#!/bin/bash

set -euo pipefail

# Source zshenv to get XDG Base Directory paths
source "$HOME/.zshenv"

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
mkdir -p "$XDG_DATA_HOME/oh-my-zsh"           # for oh-my-zsh installation
mkdir -p "$ZDOTDIR/custom/themes"   # for custom themes
mkdir -p "$ZDOTDIR/custom/plugins"  # for custom plugins

echo "✓ All zsh directories created successfully"
