# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an iTerm2 AutoLaunch Python script that propagates session-level user variables up to tab-level variables. When a pane sets `user.currentGoal` or `user.currentActivity`, the script sets `user.lastGoal` or `user.lastActivity` on the containing tab. This allows each pane to maintain its own state while the tab title reflects whichever pane changed most recently.

## Project Structure

```
Sync Title/
├── Sync Title/
│   └── Sync Title.py    # Main script (required nested structure for iTerm2)
├── metadata.json        # iTerm2 AutoLaunch configuration
├── setup.cfg            # iTerm2 script metadata (auto-generated)
└── iterm2env/           # Bundled Python environment (do not modify)
```

## Development

### Running the Script

The script runs automatically when iTerm2 launches (AutoLaunch). To manually reload:
1. Scripts menu → Manage → Reload
2. Or restart iTerm2

### Testing Changes

Use iTerm2's Script Console (Scripts → Script Console) to view logs. The script logs at INFO level for its own messages while suppressing library noise at WARNING level.

### Key Architecture

- **Variable watchers**: Each session gets `VariableMonitor` tasks watching `user.currentGoal` and `user.currentActivity`
- **Tab propagation**: When a session variable changes, the corresponding tab variable (`user.lastGoal` / `user.lastActivity`) is updated via `VARIABLE_MAP`
- **Session lifecycle**: `NewSessionMonitor` starts watchers for new sessions; `SessionTerminationMonitor` cleans up cancelled tasks

### Python Environment

iTerm2 manages a bundled Python environment in `iterm2env/`. The `setup.cfg` specifies Python 3.8. Do not modify `iterm2env/` or `setup.cfg` directly.

## iTerm2 Python API

This script uses the `iterm2` package. Key classes:
- `iterm2.VariableMonitor` - watches for variable changes in a session
- `iterm2.NewSessionMonitor` - notifies when sessions are created
- `iterm2.SessionTerminationMonitor` - notifies when sessions close
- `iterm2.run_forever(main)` - keeps the script running as a daemon
