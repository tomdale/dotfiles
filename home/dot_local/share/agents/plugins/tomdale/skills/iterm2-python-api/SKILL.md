---
name: iterm2-python-api
description: Write and debug iTerm2 Python scripts. Use when automating iTerm2 windows, tabs, sessions, status items, event handlers, or RPC-style terminal integrations.
---

# iTerm2 Python API

Use this skill when the task is specifically about automating iTerm2 with its
Python API.

## Object Model

`App -> Window -> Tab -> Session`

- `App`: top-level iTerm2 application object
- `Window`: a terminal window
- `Tab`: a tab inside a window
- `Session`: a pane or terminal session

## Script Styles

### One-shot script

```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window
    if window is None:
        print("No current window")
        return

iterm2.run_until_complete(main)
```

### Long-running daemon

```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)
    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()
            session = app.get_session_by_id(session_id)
            if session is not None:
                pass

iterm2.run_forever(main)
```

## Common Operations

### Get Current Objects

```python
app = await iterm2.async_get_app(connection)
window = app.current_terminal_window
tab = window.current_tab
session = tab.current_session
```

### Create Windows And Tabs

```python
window = await iterm2.Window.async_create(connection)
tab = await window.async_create_tab()
```

### Split Panes

```python
new_session = await session.async_split_pane(vertical=True)
```

### Send Text

```python
await session.async_send_text("echo hello\\n")
```

### Read Screen Contents

```python
contents = await session.async_get_screen_contents()
for i in range(contents.number_of_lines):
    print(contents.line(i).string)
```

## Event-Driven Patterns

Useful monitors include:

- `NewSessionMonitor`
- `FocusMonitor`
- `VariableMonitor`

Use them in long-running scripts with async context managers.

## Good Defaults

- Prefer async helpers from the `iterm2` module over hand-rolled AppleScript
- Use daemon scripts for monitors and status integrations
- Use one-shot scripts for focused automation tasks
- Check `window is None` and similar missing-object cases explicitly

## Working Rules

- Match the script type to the job: one-shot versus daemon
- Handle “no current window/session” cases cleanly
- Keep terminal side effects explicit, especially when sending commands
- When building status or RPC integrations, optimize for reliability over
cleverness
