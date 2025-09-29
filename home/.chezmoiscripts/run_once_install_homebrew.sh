#!/bin/bash

set -e

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Homebrew installation skipped: not on macOS"
    exit 0
fi

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