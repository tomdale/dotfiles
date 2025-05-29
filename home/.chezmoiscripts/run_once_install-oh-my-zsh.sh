#!/bin/bash

set -euo pipefail

# Source zshenv to get XDG Base Directory paths
source "$HOME/.zshenv"

echo "Installing Oh My Zsh...!"

# Check if Oh My Zsh is already installed
if [ -d "$ZSH" ] && [ -f "$ZSH/oh-my-zsh.sh" ]; then
    echo "Oh My Zsh is already installed at $ZSH"
    exit 0
fi

# Download and install Oh My Zsh
echo "Downloading Oh My Zsh..."
if command -v curl >/dev/null 2>&1; then
    # Use curl if available
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
elif command -v wget >/dev/null 2>&1; then
    # Fallback to wget
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "Error: Neither curl nor wget is available. Cannot download Oh My Zsh."
    exit 1
fi

echo "Oh My Zsh installation completed!"
echo "Installed at: $ZSH"

# Verify installation
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    echo "✓ Oh My Zsh successfully installed"
else
    echo "✗ Oh My Zsh installation may have failed"
    exit 1
fi
