# Event Monitors

Monitor context managers let daemon scripts respond to events in iTerm2. Use them with `async with` to receive notifications.

## Pattern

All monitors follow the same pattern:

```python
async def main(connection):
    async with SomeMonitor(connection) as mon:
        while True:
            event = await mon.async_get()
            # Handle event

iterm2.run_forever(main)
```

For multiple monitors, use `asyncio.create_task`:

```python
async def monitor_sessions():
    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()
            # Handle new session

async def monitor_focus():
    async with iterm2.FocusMonitor(connection) as mon:
        while True:
            update = await mon.async_get_next_update()
            # Handle focus change

async def main(connection):
    asyncio.create_task(monitor_sessions())
    asyncio.create_task(monitor_focus())

iterm2.run_forever(main)
```

## NewSessionMonitor

Notifies when a new session is created.

```python
async with iterm2.NewSessionMonitor(connection) as mon:
    while True:
        session_id = await mon.async_get()
        session = app.get_session_by_id(session_id)
        if session:
            # New session created
            print(f"New session: {session_id}")
```

## SessionTerminationMonitor

Notifies when a session closes.

```python
async with iterm2.SessionTerminationMonitor(connection) as mon:
    while True:
        session_id = await mon.async_get()
        # Session has closed (can't access it anymore)
        print(f"Session closed: {session_id}")
```

## FocusMonitor

Notifies when focus changes between windows, tabs, or sessions.

```python
async with iterm2.FocusMonitor(connection) as mon:
    while True:
        update = await mon.async_get_next_update()

        # Application activated/deactivated
        if update.application_active is not None:
            active = update.application_active.application_active
            print(f"iTerm2 active: {active}")

        # Window focus changed
        if update.window_changed is not None:
            window_id = update.window_changed.window_id
            reason = update.window_changed.event
            # reason: TERMINAL_WINDOW_BECAME_KEY, TERMINAL_WINDOW_IS_CURRENT,
            #         TERMINAL_WINDOW_RESIGNED_KEY
            print(f"Window {window_id}: {reason}")

        # Tab selection changed
        if update.selected_tab_changed is not None:
            tab_id = update.selected_tab_changed.tab_id
            print(f"Tab selected: {tab_id}")

        # Active session changed
        if update.active_session_changed is not None:
            session_id = update.active_session_changed.session_id
            print(f"Session focused: {session_id}")
```

## VariableMonitor

Notifies when a session variable changes. See [Profile & Colors](profile-colors.md) for common variables.

### Monitor Specific Session

```python
# Monitor path changes in a specific session
async with iterm2.VariableMonitor(
    connection,
    iterm2.VariableScopes.SESSION,
    "path",
    session_id
) as mon:
    while True:
        new_path = await mon.async_get()
        print(f"Path changed to: {new_path}")
```

### Monitor All Sessions

```python
# Monitor hostname changes in all sessions
async with iterm2.VariableMonitor(
    connection,
    iterm2.VariableScopes.SESSION,
    "hostname",
    None  # None = all sessions
) as mon:
    while True:
        hostname = await mon.async_get()
        print(f"Hostname: {hostname}")
```

### Variable Scopes

```python
iterm2.VariableScopes.SESSION  # Session variables
iterm2.VariableScopes.TAB      # Tab variables
iterm2.VariableScopes.WINDOW   # Window variables
iterm2.VariableScopes.APP      # Application variables
```

### Common Variables

| Variable | Scope | Description |
|----------|-------|-------------|
| `path` | Session | Current working directory |
| `hostname` | Session | Remote hostname |
| `username` | Session | Remote username |
| `currentCommand` | Session | Currently running command |
| `lastCommand` | Session | Last completed command |
| `jobName` | Session | Name of foreground job |
| `jobPid` | Session | PID of foreground job |
| `termid` | Session | Terminal ID |
| `autoName` | Session | Auto-generated name |
| `profileName` | Session | Current profile name |
| `rows` | Session | Number of rows |
| `columns` | Session | Number of columns |
| `effectiveTheme` | App | Current theme (dark/light) |

## LayoutChangeMonitor

Notifies when tabs or split panes change.

```python
async with iterm2.LayoutChangeMonitor(connection) as mon:
    while True:
        await mon.async_get()
        # Layout changed - enumerate current state
        for window in app.terminal_windows:
            for tab in window.tabs:
                print(f"Tab {tab.tab_id}: {len(tab.sessions)} sessions")
```

## KeystrokeMonitor

Monitor keystrokes in a session.

```python
async with iterm2.KeystrokeMonitor(connection, session_id) as mon:
    while True:
        keystroke = await mon.async_get()
        print(f"Key: {keystroke.characters}")
        print(f"Modifiers: {keystroke.modifiers}")
        print(f"Keycode: {keystroke.keycode}")
```

### Keystroke Object

| Property | Type | Description |
|----------|------|-------------|
| `characters` | `str` | Characters produced (with modifiers) |
| `characters_ignoring_modifiers` | `str` | Characters without modifiers |
| `modifiers` | `set[Modifier]` | Active modifiers |
| `keycode` | `Keycode` | Physical key code |

### Modifiers

```python
iterm2.Modifier.CONTROL
iterm2.Modifier.OPTION
iterm2.Modifier.COMMAND
iterm2.Modifier.SHIFT
iterm2.Modifier.FUNCTION
iterm2.Modifier.NUMPAD
```

## KeystrokeFilter

Filter (block) specific keystrokes.

```python
# Block Ctrl+C in a session
pattern = iterm2.KeystrokePattern()
pattern.required_modifiers = [iterm2.Modifier.CONTROL]
pattern.characters = "c"

async with iterm2.KeystrokeFilter(
    connection,
    [pattern],
    session_id
) as filter:
    # Ctrl+C is now blocked in this session
    while True:
        keystroke = await filter.async_get()
        # Handle the blocked keystroke
        print("Blocked Ctrl+C")
```

### KeystrokePattern

```python
pattern = iterm2.KeystrokePattern()
pattern.required_modifiers = [iterm2.Modifier.CONTROL, iterm2.Modifier.SHIFT]
pattern.forbidden_modifiers = [iterm2.Modifier.OPTION]
pattern.characters = "a"
# Or use keycode:
pattern.keycodes = [iterm2.Keycode.RETURN]
```

## PromptMonitor

Notifies when shell prompt appears (requires shell integration).

```python
async with iterm2.PromptMonitor(connection, session_id) as mon:
    while True:
        await mon.async_get()
        print("Prompt appeared - command finished")
```

**Note:** Requires [shell integration](https://iterm2.com/documentation-shell-integration.html) to be installed.

## ScreenStreamer

Stream real-time screen content changes.

```python
async with session.get_screen_streamer() as streamer:
    while True:
        contents = await streamer.async_get()
        for i in range(contents.number_of_lines):
            line = contents.line(i)
            print(line.string)
```

### ScreenContents Object

```python
contents = await streamer.async_get()

# Number of lines
num_lines = contents.number_of_lines

# Get specific line
line = contents.line(0)
text = line.string

# Cursor position
cursor = contents.cursor_coord
x, y = cursor.x, cursor.y
```

## CustomControlSequenceMonitor

Respond to custom escape sequences.

```python
async with iterm2.CustomControlSequenceMonitor(
    connection,
    "my-secret-id",          # Identity string
    r"^action:(.+)$"         # Regex for payload
) as mon:
    while True:
        match = await mon.async_get()
        action = match.group(1)
        print(f"Received action: {action}")
```

### Sending Custom Escape Sequence

From the terminal:

```bash
printf "\033]1337;Custom=id=%s:%s\a" "my-secret-id" "action:do-something"
```

## Transaction

Group multiple operations atomically.

```python
async with iterm2.Transaction(connection):
    # All operations here happen atomically
    await session1.async_send_text("command1\n")
    await session2.async_send_text("command2\n")
    # Screen won't update until transaction ends
```

## Complete Example: Auto-Theme

Switch colors based on time of day:

```python
#!/usr/bin/env python3
import iterm2
import datetime
import asyncio

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async def apply_theme():
        hour = datetime.datetime.now().hour
        preset_name = "Solarized Light" if 6 <= hour < 18 else "Solarized Dark"

        try:
            preset = await iterm2.ColorPreset.async_get(connection, preset_name)
            for window in app.terminal_windows:
                for tab in window.tabs:
                    for session in tab.sessions:
                        profile = await session.async_get_profile()
                        await profile.async_set_color_preset(preset)
        except Exception as e:
            print(f"Error: {e}")

    # Apply on startup
    await apply_theme()

    # Check every hour
    while True:
        await asyncio.sleep(3600)
        await apply_theme()

iterm2.run_forever(main)
```

## Complete Example: Command Logger

Log all commands executed:

```python
#!/usr/bin/env python3
import iterm2
import datetime

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async with iterm2.VariableMonitor(
        connection,
        iterm2.VariableScopes.SESSION,
        "lastCommand",
        None  # All sessions
    ) as mon:
        while True:
            command = await mon.async_get()
            if command:
                timestamp = datetime.datetime.now().isoformat()
                with open("/tmp/command_log.txt", "a") as f:
                    f.write(f"{timestamp}: {command}\n")

iterm2.run_forever(main)
```
