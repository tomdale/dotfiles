# Status Bar Components

Create custom status bar components that display dynamic information in iTerm2's status bar.

## Overview

Status bar components are registered Python functions that provide content for display. Components can:
- Display text based on session variables (rows, columns, path, etc.)
- Respond to configuration knobs set by the user
- Provide variable-length text that adapts to available space
- Update automatically when bound variables change

## Basic Structure

```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    # 1. Define configuration knobs
    knobs = [
        iterm2.CheckboxKnob("Enable Feature", False, "feature_enabled"),
        iterm2.StringKnob("Label", "default", "label_text")
    ]

    # 2. Create the component
    component = iterm2.StatusBarComponent(
        short_description="My Component",
        detailed_description="What this component does",
        knobs=knobs,
        exemplar="Sample Text",
        update_cadence=None,
        identifier="com.example.my-component"
    )

    # 3. Define the RPC function
    @iterm2.StatusBarRPC
    async def coro(knobs):
        if knobs.get("feature_enabled"):
            return knobs.get("label_text", "default")
        return "Disabled"

    # 4. Register the component
    await component.async_register(connection, coro)

iterm2.run_forever(main)
```

## iterm2.StatusBarComponent

### Constructor Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `short_description` | `str` | Name shown in status bar configuration |
| `detailed_description` | `str` | Tooltip/description for users |
| `knobs` | `list[Knob]` | Configuration options |
| `exemplar` | `str` | Example text (helps sizing) |
| `update_cadence` | `float` or `None` | Seconds between updates, or `None` for event-driven |
| `identifier` | `str` | Unique ID (reverse domain notation) |

### Methods

```python
# Register the component
await component.async_register(connection, callback_function)

# Open a popover (for interactive components)
await component.async_open_popover(
    session_id,
    html_content,
    size=iterm2.Size(200, 100)
)
```

## Knob Types

Configuration options users can adjust in Preferences.

### CheckboxKnob

Boolean on/off setting.

```python
iterm2.CheckboxKnob(
    name="Show Emoji",           # Display label
    default_value=True,          # Initial value
    key="show_emoji"             # Key in knobs dict
)
```

### StringKnob

Text input setting.

```python
iterm2.StringKnob(
    name="Prefix",
    placeholder="Enter prefix",  # Placeholder text
    default_value="$",
    key="prefix"
)
```

### PositiveFloatingPointKnob

Numeric setting (positive float).

```python
iterm2.PositiveFloatingPointKnob(
    name="Update Interval",
    default_value=5.0,
    key="interval"
)
```

### ColorKnob

Color picker setting.

```python
iterm2.ColorKnob(
    name="Text Color",
    default_value=iterm2.Color(255, 255, 255),
    key="text_color"
)
```

## @iterm2.StatusBarRPC Decorator

Marks a function as a status bar callback. The function receives:

1. `knobs` - Dictionary of configuration values
2. Any bound variables via `iterm2.Reference()`

```python
@iterm2.StatusBarRPC
async def coro(
    knobs,
    rows=iterm2.Reference("rows"),
    cols=iterm2.Reference("columns"),
    path=iterm2.Reference("path")
):
    # knobs["my_key"] contains user configuration
    # rows, cols, path contain current session values
    return f"{path} ({rows}x{cols})"
```

## iterm2.Reference

Binds session variables to function arguments. When any referenced variable changes, the function is automatically called.

### Common Variables

| Variable | Description |
|----------|-------------|
| `rows` | Number of rows in session |
| `columns` | Number of columns in session |
| `path` | Current working directory |
| `hostname` | Current hostname |
| `username` | Current username |
| `currentCommand` | Currently running command |
| `jobName` | Name of current job |
| `jobPid` | PID of current job |
| `termid` | Terminal ID |
| `autoName` | Auto-generated session name |
| `profileName` | Current profile name |
| `lastCommand` | Last executed command |
| `user.*` | User-defined variables |

### Using References

```python
@iterm2.StatusBarRPC
async def coro(
    knobs,
    # Question mark suffix makes the variable optional
    command=iterm2.Reference("currentCommand?"),
    host=iterm2.Reference("hostname?")
):
    if command:
        return f"Running: {command}"
    elif host:
        return f"@{host}"
    return "Idle"
```

## Variable-Length Text

Return a list of strings from shortest to longest. iTerm2 will choose the longest one that fits.

```python
@iterm2.StatusBarRPC
async def coro(knobs, path=iterm2.Reference("path")):
    return [
        "~",                           # Shortest
        path.split("/")[-1],           # Just filename
        "/".join(path.split("/")[-2:]),# Last two components
        path                           # Full path (longest)
    ]
```

## Periodic Updates

Use `update_cadence` for components that need regular updates regardless of variable changes.

```python
import datetime

component = iterm2.StatusBarComponent(
    short_description="Clock",
    detailed_description="Shows current time",
    knobs=[],
    exemplar="12:00:00",
    update_cadence=1.0,  # Update every second
    identifier="com.example.clock"
)

@iterm2.StatusBarRPC
async def coro(knobs):
    return datetime.datetime.now().strftime("%H:%M:%S")
```

## Icons

Add an icon to your component.

```python
# Load icon from file
icon = iterm2.StatusBarComponent.Icon(1, "/path/to/icon.png")

component = iterm2.StatusBarComponent(
    short_description="My Component",
    ...,
    icon=icon
)
```

## Complete Examples

### Session Size Display

```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    component = iterm2.StatusBarComponent(
        short_description="Session Size",
        detailed_description="Shows rows x columns",
        knobs=[],
        exemplar="80x24",
        update_cadence=None,
        identifier="com.example.session-size"
    )

    @iterm2.StatusBarRPC
    async def coro(knobs, rows=iterm2.Reference("rows"), cols=iterm2.Reference("columns")):
        return f"{cols}x{rows}"

    await component.async_register(connection, coro)

iterm2.run_forever(main)
```

### Git Branch Display

```python
#!/usr/bin/env python3
import iterm2
import subprocess

async def main(connection):
    knobs = [
        iterm2.CheckboxKnob("Show Icon", True, "show_icon")
    ]

    component = iterm2.StatusBarComponent(
        short_description="Git Branch",
        detailed_description="Shows current git branch",
        knobs=knobs,
        exemplar="main",
        update_cadence=2.0,  # Check every 2 seconds
        identifier="com.example.git-branch"
    )

    @iterm2.StatusBarRPC
    async def coro(knobs, path=iterm2.Reference("path?")):
        if not path:
            return ""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--abbrev-ref", "HEAD"],
                cwd=path,
                capture_output=True,
                text=True,
                timeout=1
            )
            if result.returncode == 0:
                branch = result.stdout.strip()
                if knobs.get("show_icon"):
                    return f" {branch}"
                return branch
        except:
            pass
        return ""

    await component.async_register(connection, coro)

iterm2.run_forever(main)
```

### Weather Display

```python
#!/usr/bin/env python3
import iterm2
import urllib.request
import json

async def main(connection):
    knobs = [
        iterm2.StringKnob("City", "New York", "city")
    ]

    component = iterm2.StatusBarComponent(
        short_description="Weather",
        detailed_description="Shows current weather",
        knobs=knobs,
        exemplar="72°F",
        update_cadence=300.0,  # Update every 5 minutes
        identifier="com.example.weather"
    )

    @iterm2.StatusBarRPC
    async def coro(knobs):
        city = knobs.get("city", "New York")
        try:
            url = f"https://wttr.in/{city}?format=%t"
            with urllib.request.urlopen(url, timeout=5) as response:
                return response.read().decode().strip()
        except:
            return "N/A"

    await component.async_register(connection, coro)

iterm2.run_forever(main)
```

## Installation

1. Save script to `~/Library/Application Support/iTerm2/Scripts/AutoLaunch/`
2. Restart iTerm2 or run the script from Scripts menu
3. Go to **Preferences > Profiles > Session**
4. Enable **Status Bar** and click **Configure Status Bar**
5. Drag your component from the available components list
