#!/bin/bash

set -e

# Source shared environment variables (deployed by chezmoi before scripts run)
# shellcheck source=/dev/null
source "$HOME/.config/zsh/env.sh"

# Brewfile hash: {{ include "dot_config/Brewfile.tmpl" | sha256sum }}

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Homebrew installation skipped: not on macOS"
    exit 0
fi

# Install Homebrew if not present
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew is already installed"
else
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for the current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Install/update Brewfile dependencies
echo "🍺 Installing/updating Homebrew dependencies..."

# Use XDG_CONFIG_HOME at runtime, with fallback to match chezmoi's default
BREWFILE_PATH="${XDG_CONFIG_HOME}/Brewfile"

# Run brew bundle install to install/update dependencies
if command -v brew &> /dev/null; then
    brew bundle install --file="$BREWFILE_PATH"
    echo "✅ Homebrew dependencies updated successfully"
else
    echo "❌ Homebrew not found after installation attempt."
    exit 1
fi