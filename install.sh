#!/usr/bin/env bash

set -uo pipefail

# Check if the current directory is $HOME/.dotfiles
if [[ "$PWD" != "$HOME/.dotfiles" ]]; then
    echo "Error: Expected dotfiles install.sh to be run from $HOME/.dotfiles" >&2
    exit 1
fi

# Source that will be inserted into ~/.zshenv
read -r -d '' ZSHENV_SOURCE << 'EOF'
export ZDOTDIR="$HOME/.dotfiles/zsh"
source "$ZDOTDIR/_zshenv"
EOF

if grep -qF -- "$ZSHENV_SOURCE" ~/.zshenv 2>/dev/null; then
    echo "~/.zshenv has already been configured. No changes made."
else
    echo "$ZSHENV_SOURCE" >> ~/.zshenv
fi

ln -s "$PWD/git/gitconfig" "$HOME/.gitconfig"
