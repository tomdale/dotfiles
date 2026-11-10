#!/bin/sh
set -eu

# Removes the npm token cache daemon and the registry token wiring that earlier
# dotfiles installed. Reads now authenticate to the Socket Firewall registry from
# ~/.npmrc alone, so none of these have a consumer left.
#
# launchd holds a loaded job in memory, so deleting the plist and program leaves
# the agent running: bootout it first. chezmoi does not delete a target whose
# source disappeared, so the generated pnpm config files are removed here too.
#
# Safe to run repeatedly; run_onchange re-runs it whenever this content changes.
LABEL="com.tomdale.pnpm-npm-token-cache"

launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

rm -f "${HOME}/Library/LaunchAgents/${LABEL}.plist" \
      "${HOME}/.local/libexec/pnpm-npm-token-cache" \
      "${HOME}/.local/libexec/pnpm-npm-token-cache.swift" \
      "${HOME}/.config/pnpm/auth.ini" \
      "${HOME}/.config/pnpm/config.yaml" \
      "${HOME}/.config/pnpm/rc"
rm -rf "${HOME}/.local/state/pnpm-npm-token-cache"
