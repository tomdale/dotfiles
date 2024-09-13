#!/usr/bin/env sh
git subtree pull --prefix zsh/ohmyzsh git@github.com:ohmyzsh/ohmyzsh.git master --squash --message "Updated oh-my-zsh ($(date "+%a %b %d %Y %H:%M:%S %Z"))"
