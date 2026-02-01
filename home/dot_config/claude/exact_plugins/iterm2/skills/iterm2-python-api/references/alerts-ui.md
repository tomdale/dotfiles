# Alerts and UI

Display dialogs and create custom toolbelt tools.

## iterm2.Alert

Display a simple alert dialog with buttons.

### Basic Alert

```python
alert = iterm2.Alert("Title", "Message text", window_id)
await alert.async_run(connection)
```

### Alert with Buttons

```python
alert = iterm2.Alert("Confirm Action", "Are you sure?", window_id)
alert.add_button("Yes")
alert.add_button("No")
alert.add_button("Cancel")

# Returns index of clicked button (0-based)
selected = await alert.async_run(connection)
if selected == 0:
    print("User clicked Yes")
elif selected == 1:
    print("User clicked No")
else:
    print("User clicked Cancel")
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `str` | Alert title |
| `subtitle` | `str` | Message text |

### Methods

```python
alert.add_button("Button Label")  # Add a button
result = await alert.async_run(connection)  # Show and wait for response
```

## iterm2.TextInputAlert

Display an alert with a text input field.

### Basic Text Input

```python
alert = iterm2.TextInputAlert(
    "Enter Name",           # Title
    "Please enter your name:",  # Subtitle
    "Your name here",       # Placeholder
    "",                     # Default value
    window_id
)

# Returns entered text, or None if cancelled
result = await alert.async_run(connection)
if result is not None:
    print(f"User entered: {result}")
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `title` | `str` | Alert title |
| `subtitle` | `str` | Message text |
| `placeholder` | `str` | Placeholder text |
| `default_value` | `str` | Initial value |
| `window_id` | `str` | Parent window ID |

## iterm2.PolyModalAlert

Display a complex dialog with multiple input types.

### Basic PolyModalAlert

```python
alert = iterm2.PolyModalAlert(
    "Configuration",        # Title
    "Configure settings:",  # Subtitle
    window_id
)

# Add input fields
alert.add_text_field("name", "Enter your name:", "John Doe")
alert.add_checkboxes("options", ["Enable feature", "Show notifications"], [True, False])
alert.add_combobox("color", ["Red", "Green", "Blue"], "Green")

# Add buttons
alert.add_button("Save")
alert.add_button("Cancel")

result = await alert.async_run(connection)
```

### Result Structure

```python
result = await alert.async_run(connection)

# Button index (0-based)
button = result["button"]

# Text field values
name = result.get("name")

# Checkbox values (list of bools)
options = result.get("options")  # e.g., [True, False]

# Combobox value (selected string)
color = result.get("color")  # e.g., "Green"
```

### Methods

#### add_text_field

```python
alert.add_text_field(
    "field_key",        # Key in result dict
    "Label text:",      # Label shown to user
    "default value"     # Initial value
)
```

#### add_checkboxes

```python
alert.add_checkboxes(
    "checkboxes_key",           # Key in result dict
    ["Option 1", "Option 2"],   # Checkbox labels
    [True, False]               # Default values
)

# Or add one at a time:
alert.add_checkbox_item("Single checkbox", True)
```

#### add_combobox

```python
alert.add_combobox(
    "combo_key",                    # Key in result dict
    ["Choice 1", "Choice 2"],       # Options
    "Choice 1"                      # Default selection
)

# Or add items one at a time:
alert.add_combobox("combo_key", [], "")
alert.add_combobox_item("Choice 1")
alert.add_combobox_item("Choice 2")
```

#### add_button

```python
alert.add_button("OK")
alert.add_button("Cancel")
```

#### set_width

```python
alert.set_width(400)  # Width in pixels
```

### Complete Example

```python
async def show_config_dialog(connection, window_id):
    alert = iterm2.PolyModalAlert(
        "Script Configuration",
        "Configure your preferences:",
        window_id
    )

    alert.add_text_field("name", "Your name:", "")
    alert.add_text_field("email", "Email address:", "")
    alert.add_checkboxes(
        "notifications",
        ["Email notifications", "Desktop alerts"],
        [True, True]
    )
    alert.add_combobox(
        "theme",
        ["Light", "Dark", "System"],
        "System"
    )
    alert.add_button("Save")
    alert.add_button("Cancel")

    result = await alert.async_run(connection)

    if result["button"] == 0:  # Save clicked
        return {
            "name": result.get("name"),
            "email": result.get("email"),
            "email_notifications": result["notifications"][0],
            "desktop_alerts": result["notifications"][1],
            "theme": result.get("theme")
        }
    return None
```

## Custom Toolbelt Tools

Create custom tools in iTerm2's toolbelt (the sidebar panel).

### Web View Tool

Register a web view that appears in the toolbelt:

```python
async def main(connection):
    await iterm2.async_register_web_view_tool(
        connection,
        "My Tool",              # Display name
        "com.example.mytool",   # Unique identifier
        False,                  # Reveal on registration
        "https://example.com"   # URL to display
    )

iterm2.run_forever(main)
```

### Local HTML Tool

Serve local HTML content:

```python
import http.server
import threading

# Start a simple HTTP server
def start_server():
    handler = http.server.SimpleHTTPRequestHandler
    server = http.server.HTTPServer(('localhost', 8080), handler)
    server.serve_forever()

threading.Thread(target=start_server, daemon=True).start()

async def main(connection):
    await iterm2.async_register_web_view_tool(
        connection,
        "Local Tool",
        "com.example.localtool",
        True,
        "http://localhost:8080/tool.html"
    )

iterm2.run_forever(main)
```

### Enabling Toolbelt

1. View > Show Toolbelt (or Cmd+Shift+B)
2. View > Toolbelt > [Your Tool Name]

## Example: Confirmation Before Close

```python
#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def confirm_close(session_id=iterm2.Reference("id")):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        window = session.window
        alert = iterm2.Alert(
            "Close Session?",
            "Are you sure you want to close this session?",
            window.window_id
        )
        alert.add_button("Close")
        alert.add_button("Cancel")

        result = await alert.async_run(connection)
        if result == 0:
            await session.async_close(force=True)

    await confirm_close.async_register(connection)

iterm2.run_forever(main)
```

## Example: Quick Note Dialog

```python
#!/usr/bin/env python3
import iterm2
import os

NOTES_FILE = os.path.expanduser("~/notes.txt")

async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def add_note(session_id=iterm2.Reference("id")):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        window = session.window
        alert = iterm2.TextInputAlert(
            "Quick Note",
            "Enter your note:",
            "Type here...",
            "",
            window.window_id
        )

        note = await alert.async_run(connection)
        if note:
            with open(NOTES_FILE, "a") as f:
                f.write(f"{note}\n")

            confirm = iterm2.Alert("Saved", "Note saved!", window.window_id)
            await confirm.async_run(connection)

    await add_note.async_register(connection)

iterm2.run_forever(main)
```

## Example: SSH Connection Dialog

```python
#!/usr/bin/env python3
import iterm2

HOSTS = ["server1.example.com", "server2.example.com", "dev.local"]

async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def ssh_connect(session_id=iterm2.Reference("id")):
        session = app.get_session_by_id(session_id)
        if not session:
            return

        window = session.window
        alert = iterm2.PolyModalAlert(
            "SSH Connect",
            "Choose a host to connect to:",
            window.window_id
        )

        alert.add_combobox("host", HOSTS, HOSTS[0])
        alert.add_text_field("user", "Username:", os.environ.get("USER", ""))
        alert.add_checkboxes("options", ["Use key auth", "Forward agent"], [True, False])
        alert.add_button("Connect")
        alert.add_button("Cancel")

        result = await alert.async_run(connection)

        if result["button"] == 0:
            host = result["host"]
            user = result["user"]
            key_auth = result["options"][0]
            forward = result["options"][1]

            cmd = f"ssh"
            if forward:
                cmd += " -A"
            cmd += f" {user}@{host}\n"

            await session.async_send_text(cmd)

    await ssh_connect.async_register(connection)

iterm2.run_forever(main)
```
