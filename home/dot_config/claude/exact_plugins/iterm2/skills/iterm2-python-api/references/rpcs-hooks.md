# RPCs and Hooks

Register Python functions that can be invoked by iTerm2 key bindings, triggers, or hooks.

## @iterm2.RPC

Register a function callable from key bindings, triggers, or other scripts.

### Basic RPC

```python
async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def clear_all_sessions():
        code = b'\x1b]1337;ClearScrollback\x07'
        for window in app.terminal_windows:
            for tab in window.tabs:
                for session in tab.sessions:
                    await session.async_inject(code)

    await clear_all_sessions.async_register(connection)

iterm2.run_forever(main)
```

### RPC with Session Context

Use `iterm2.Reference` to access session variables:

```python
@iterm2.RPC
async def clear_session(session_id=iterm2.Reference("id")):
    session = app.get_session_by_id(session_id)
    if session:
        code = b'\x1b]1337;ClearScrollback\x07'
        await session.async_inject(code)

await clear_session.async_register(connection)
```

### RPC with Arguments

```python
@iterm2.RPC
async def send_text_to_session(text, session_id=iterm2.Reference("id")):
    session = app.get_session_by_id(session_id)
    if session:
        await session.async_send_text(text)

await send_text_to_session.async_register(connection)
```

### Invocation from Key Binding

1. Go to **Preferences > Keys**
2. Click **+** to add a new key binding
3. Select **Invoke Script Function** as the action
4. Enter the function call:

```
clear_all_sessions()
```

or with arguments:

```
send_text_to_session(text: "ls -la\n", session_id: id)
```

### Function Invocation Syntax

iTerm2 uses a language-agnostic syntax:

```
function_name(arg1: value1, arg2: value2)
```

**Value types:**
- Variables: `id`, `path`, `hostname`, `user.myvar`
- Numbers: `123`, `3.14`, `-5`
- Strings: `"hello"`, `"line1\nline2"`
- Function calls: `other_function(arg: value)`

### Optional Variables

Add `?` to allow `None` when variable is undefined:

```python
@iterm2.RPC
async def my_func(
    session_id=iterm2.Reference("id"),
    path=iterm2.Reference("path?")  # Optional
):
    if path is None:
        path = "unknown"
    # ...
```

### Timeout

Set a custom timeout (default is 5 seconds):

```python
await my_function.async_register(connection, timeout=10)  # 10 seconds
```

### Composition

Functions can call other functions:

```python
@iterm2.RPC
async def add(a, b):
    return a + b

@iterm2.RPC
async def multiply(a, b):
    return a * b

@iterm2.RPC
async def display(value, session_id=iterm2.Reference("id")):
    session = app.get_session_by_id(session_id)
    if session:
        await session.async_inject(str(value).encode())

await add.async_register(connection)
await multiply.async_register(connection)
await display.async_register(connection)
```

Invoke with:
```
display(value: add(a: 1, b: multiply(a: 2, b: 3)), session_id: id)
```

## @iterm2.TitleProviderRPC

Create custom session title providers that appear in Profile settings.

### Basic Title Provider

```python
@iterm2.TitleProviderRPC
async def upper_case_title(auto_name=iterm2.Reference("autoName?")):
    if not auto_name:
        return ""
    return auto_name.upper()

await upper_case_title.async_register(
    connection,
    display_name="Upper-case Title",
    unique_identifier="com.example.upper-case-title"
)
```

### Registration Parameters

| Parameter | Description |
|-----------|-------------|
| `display_name` | Name shown in Preferences > Profiles > General > Title |
| `unique_identifier` | Unique ID (persists across code changes) |

### Using in Profile

1. Run the script (place in AutoLaunch for persistence)
2. Go to **Preferences > Profiles > General**
3. Click the **Title** dropdown
4. Select your custom title provider

### Dynamic Titles with User Variables

Force title updates by changing a user variable:

```python
async def main(connection):
    app = await iterm2.async_get_app(connection)
    tasks = {}

    async def update_timer(session_id):
        try:
            count = 0
            session = app.get_session_by_id(session_id)
            while True:
                await asyncio.sleep(1)
                await session.async_set_variable("user.counter", count)
                count += 1
        except:
            del tasks[session_id]

    @iterm2.TitleProviderRPC
    async def timer_title(
        session_id=iterm2.Reference("id"),
        counter=iterm2.Reference("user.counter?")
    ):
        if session_id not in tasks:
            tasks[session_id] = asyncio.create_task(update_timer(session_id))
        return f"Session: {counter or 0}s"

    await timer_title.async_register(
        connection,
        display_name="Timer Title",
        unique_identifier="com.example.timer-title"
    )

iterm2.run_forever(main)
```

### Common Variables for Titles

| Variable | Description |
|----------|-------------|
| `autoName` | Default session name |
| `termid` | Terminal ID |
| `path` | Current directory |
| `hostname` | Remote hostname |
| `username` | Remote username |
| `currentCommand` | Running command |
| `jobName` | Current job name |
| `profileName` | Profile name |

## @iterm2.ContextMenuProviderRPC

Add custom items to the right-click context menu.

### Basic Context Menu Item

```python
@iterm2.ContextMenuProviderRPC
async def hello_world():
    print("Hello world")

await hello_world.async_register(
    connection,
    "Say Hello",  # Menu item title
    "com.example.hello-world"  # Unique identifier
)
```

### With Selection

Access selected text:

```python
@iterm2.ContextMenuProviderRPC
async def search_selection(
    session_id=iterm2.Reference("id"),
    selection=iterm2.Reference("selection?")
):
    if selection:
        import webbrowser
        webbrowser.open(f"https://google.com/search?q={selection}")

await search_selection.async_register(
    connection,
    "Search Selection",
    "com.example.search-selection"
)
```

## @iterm2.StatusBarRPC

See [Status Bar](status-bar.md) for complete documentation.

```python
component = iterm2.StatusBarComponent(
    short_description="My Component",
    detailed_description="Description",
    knobs=[],
    exemplar="Example",
    update_cadence=None,
    identifier="com.example.component"
)

@iterm2.StatusBarRPC
async def coro(knobs, path=iterm2.Reference("path?")):
    return path or "No path"

await component.async_register(connection, coro)
```

## iterm2.Reference

Bind session/tab/window/app variables to function arguments.

### Syntax

```python
iterm2.Reference("variable_name")     # Required (error if undefined)
iterm2.Reference("variable_name?")    # Optional (None if undefined)
```

### Common Variables

**Session scope:**
- `id` - Session ID
- `path` - Current working directory
- `hostname` - Remote host
- `username` - Remote user
- `currentCommand` - Running command
- `lastCommand` - Previous command
- `jobName` - Job name
- `jobPid` - Job PID
- `rows`, `columns` - Dimensions
- `autoName` - Auto-generated name
- `profileName` - Profile name
- `termid` - Terminal ID
- `selection` - Selected text
- `mouseReportingMode` - Mouse mode (-1 = off)

**User-defined:**
- `user.variableName` - Custom variables set via `async_set_variable`

### Setting User Variables

```python
# From a session
await session.async_set_variable("user.myVar", "value")

# From shell (control sequence)
# printf "\033]1337;SetUserVar=%s=%s\007" "myVar" $(echo -n "value" | base64)
```

## Complete Example: Command Palette

```python
#!/usr/bin/env python3
import iterm2

COMMANDS = {
    "clear": "clear\n",
    "list": "ls -la\n",
    "git status": "git status\n",
    "git log": "git log --oneline -10\n",
}

async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def run_command(name, session_id=iterm2.Reference("id")):
        session = app.get_session_by_id(session_id)
        if session and name in COMMANDS:
            await session.async_send_text(COMMANDS[name])

    await run_command.async_register(connection)

    # Now bind keys in Preferences:
    # run_command(name: "clear", session_id: id)
    # run_command(name: "git status", session_id: id)

iterm2.run_forever(main)
```

## Installation

1. Save daemon scripts to `~/Library/Application Support/iTerm2/Scripts/AutoLaunch/`
2. Restart iTerm2 or run from Scripts menu
3. Configure key bindings in **Preferences > Keys**
4. For title providers, select in **Preferences > Profiles > General > Title**
5. For status bar, enable in **Preferences > Profiles > Session > Status Bar**
