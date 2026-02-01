---
name: iterm2-python-api
description: Write and debug iTerm2 Python scripts. Use when the user wants to automate iTerm2, create terminal windows/tabs/sessions, build status bar components, handle keyboard events, monitor terminal activity, or integrate with iTerm2's scripting system. Covers the full iterm2 Python module including App, Window, Tab, Session, Profile, and event monitoring.
---

# iTerm2 Python API

Write Python scripts to control and extend iTerm2.

## Architecture

**Object Hierarchy:** App > Window > Tab > Session

- `App` - Application singleton, provides access to all windows
- `Window` - Terminal window containing tabs
- `Tab` - Contains sessions (split panes)
- `Session` - Individual terminal pane

## Script Types

1. **Simple scripts** - Run once and exit (`iterm2.run_until_complete(main)`)
2. **Long-running daemons** - Run forever, handle events (`iterm2.run_forever(main)`)

## Essential Boilerplate

### Simple Script
```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window
    if window is not None:
        # Your code here
        pass
    else:
        print("No current window")

iterm2.run_until_complete(main)
```

### Daemon Script
```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()
            session = app.get_session_by_id(session_id)
            if session:
                # Handle new session
                pass

iterm2.run_forever(main)
```

## Quick Reference

### Getting Objects
```python
app = await iterm2.async_get_app(connection)
window = app.current_terminal_window      # Current window or None
tab = window.current_tab                   # Current tab
session = tab.current_session              # Current session

# By ID
session = app.get_session_by_id(session_id)
tab = app.get_tab_by_id(tab_id)
window = app.get_window_by_id(window_id)

# All windows
for window in app.terminal_windows:
    for tab in window.tabs:
        for session in tab.sessions:
            pass
```

### Creating Windows/Tabs/Sessions
```python
# Create new window
window = await iterm2.Window.async_create(connection)

# Create new window with profile
window = await iterm2.Window.async_create(connection, profile="MyProfile")

# Create new tab in window
tab = await window.async_create_tab()

# Split session
new_session = await session.async_split_pane(vertical=True)
new_session = await session.async_split_pane(vertical=False)  # horizontal
```

### Sending Commands
```python
await session.async_send_text("ls -la\n")
await session.async_send_text("echo hello")  # No newline = no execute
```

### Getting Screen Contents
```python
contents = await session.async_get_screen_contents()
for line_num in range(contents.number_of_lines):
    line = contents.line(line_num)
    print(line.string)
```

### Profile Operations
```python
profile = await session.async_get_profile()

# Modify profile for this session only
change = iterm2.LocalWriteOnlyProfile()
change.set_background_color(iterm2.Color(255, 0, 0))
await session.async_set_profile_properties(change)

# Apply color preset
presets = await iterm2.ColorPreset.async_get_list(connection)
preset = await iterm2.ColorPreset.async_get(connection, "Solarized Dark")
await profile.async_set_color_preset(preset)
```

## Event Monitors

Use async context managers for daemon scripts:

### NewSessionMonitor
```python
async with iterm2.NewSessionMonitor(connection) as mon:
    while True:
        session_id = await mon.async_get()
        # Handle new session
```

### FocusMonitor
```python
async with iterm2.FocusMonitor(connection) as mon:
    while True:
        update = await mon.async_get_next_update()
        if update.window_changed:
            print(f"Window: {update.window_changed.window_id}")
        if update.selected_tab_changed:
            print(f"Tab: {update.selected_tab_changed.tab_id}")
        if update.active_session_changed:
            print(f"Session: {update.active_session_changed.session_id}")
```

### VariableMonitor
```python
async with iterm2.VariableMonitor(
    connection,
    iterm2.VariableScopes.SESSION,
    "path",
    session_id
) as mon:
    while True:
        new_value = await mon.async_get()
```

### All Monitors
- `NewSessionMonitor` - New session creation
- `SessionTerminationMonitor` - Session closing
- `LayoutChangeMonitor` - Tab/window layout changes
- `FocusMonitor` - Focus changes
- `VariableMonitor` - Variable value changes
- `KeystrokeMonitor` / `KeystrokeFilter` - Keyboard events
- `PromptMonitor` - Shell prompt detection
- `ScreenStreamer` - Real-time screen updates
- `CustomControlSequenceMonitor` - Custom escape sequences

## RPC Functions

Register functions callable from key bindings or triggers:

```python
@iterm2.RPC
async def my_function(session_id=iterm2.Reference("id")):
    session = app.get_session_by_id(session_id)
    if session:
        await session.async_send_text("echo 'Hello'\n")

await my_function.async_register(connection)
```

Call from Preferences > Keys with: `my_function()`

## Status Bar Components

```python
component = iterm2.StatusBarComponent(
    short_description="My Component",
    detailed_description="What this does",
    knobs=[],
    exemplar="Example",
    update_cadence=None,
    identifier="com.example.my-component")

@iterm2.StatusBarRPC
async def coro(knobs):
    return "Status text"

await component.async_register(connection, coro)
```

## Script Locations

- **Simple scripts:** `~/Library/Application Support/iTerm2/Scripts/`
- **AutoLaunch daemons:** `~/Library/Application Support/iTerm2/Scripts/AutoLaunch/`
- **Script Console:** Scripts > Script Console (view output/errors)

## Detailed Documentation

- [Core Classes](references/core-classes.md) - App, Window, Tab, Session
- [Profile & Colors](references/profile-colors.md) - Profile settings and color presets
- [Status Bar](references/status-bar.md) - Creating custom status bar components
- [Events](references/events.md) - All monitor types and notifications
- [RPCs & Hooks](references/rpcs-hooks.md) - Registering functions and title providers
- [Alerts & UI](references/alerts-ui.md) - Dialogs and user interaction
