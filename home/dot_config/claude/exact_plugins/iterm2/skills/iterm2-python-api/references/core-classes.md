# Core Classes

The iTerm2 Python API is built around a hierarchy: App > Window > Tab > Session.

## iterm2.async_get_app(connection)

Get the App singleton. This is typically the first call in any script.

```python
app = await iterm2.async_get_app(connection)
```

## iterm2.App

The application object providing access to all windows.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `current_terminal_window` | `Window` or `None` | Window receiving keyboard input |
| `terminal_windows` | `list[Window]` | All terminal windows |
| `buried_sessions` | `list[Session]` | Sessions hidden in background |
| `broadcast_domains` | `list[BroadcastDomain]` | Input broadcast domains |

### Methods

```python
# Get objects by ID
window = app.get_window_by_id(window_id)
tab = app.get_tab_by_id(tab_id)
session = app.get_session_by_id(session_id)

# Find parent objects
window, tab = app.get_window_and_tab_for_session(session)
window = app.get_window_for_tab(tab)

# Activate iTerm2 (bring to front)
await app.async_activate(raise_all_windows=False, ignoring_other_apps=True)

# Variables
value = await app.async_get_variable("effectiveTheme")
await app.async_set_variable("user.myVar", "value")

# Theme
theme = await app.async_get_theme()  # Returns list like ["dark"] or ["light"]

# Pretty print for debugging
print(app.pretty_str())
```

## iterm2.Window

Represents a terminal window containing tabs.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `window_id` | `str` | Unique identifier |
| `tabs` | `list[Tab]` | All tabs in window |
| `current_tab` | `Tab` | Currently selected tab |

### Methods

```python
# Create new window (class method)
window = await iterm2.Window.async_create(connection)
window = await iterm2.Window.async_create(connection, profile="MyProfile")
window = await iterm2.Window.async_create(connection, command="htop")

# Create new tab
tab = await window.async_create_tab()
tab = await window.async_create_tab(profile="MyProfile")
tab = await window.async_create_tab(command="vim", index=0)  # Insert at beginning

# Reorder tabs
await window.async_set_tabs([tab2, tab1, tab3])

# Frame (position and size)
frame = await window.async_get_frame()  # Returns Frame(origin, size)
await window.async_set_frame(iterm2.Frame(
    iterm2.Point(100, 100),
    iterm2.Size(800, 600)
))

# Fullscreen
is_fullscreen = await window.async_get_fullscreen()
await window.async_set_fullscreen(True)

# Activate window
await window.async_activate()

# Window arrangements
await window.async_save_window_as_arrangement("MyArrangement")
await window.async_restore_window_arrangement("MyArrangement")

# Close window
await window.async_close(force=False)  # force=True skips confirmation

# Tmux integration
tab = await window.async_create_tmux_tab(tmux_connection)

# Variables
await window.async_set_variable("user.myVar", "value")

# Invoke registered function
result = await window.async_invoke_function("my_function()")
```

## iterm2.Tab

Represents a tab containing one or more sessions (split panes).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `tab_id` | `str` | Unique identifier |
| `sessions` | `list[Session]` | All sessions in tab |
| `current_session` | `Session` | Active session in tab |
| `active_session_id` | `str` | ID of active session |
| `root` | `Splitter` | Root of session tree |
| `window` | `Window` | Parent window |
| `tmux_window_id` | `str` or `None` | Tmux window ID if applicable |
| `tmux_connection_id` | `str` or `None` | Tmux connection ID |

### Methods

```python
# Activate tab
await tab.async_activate()

# Select (make current in window)
await tab.async_select()

# Set title
await tab.async_set_title("My Tab Title")

# Navigate between panes
await tab.async_select_pane_in_direction(iterm2.NavigationDirection.LEFT)
await tab.async_select_pane_in_direction(iterm2.NavigationDirection.RIGHT)
await tab.async_select_pane_in_direction(iterm2.NavigationDirection.ABOVE)
await tab.async_select_pane_in_direction(iterm2.NavigationDirection.BELOW)

# Update layout
await tab.async_update_layout(tab.root)

# Move to another window
await tab.async_move_to_window(target_window)

# Close tab
await tab.async_close(force=False)

# Variables
value = await tab.async_get_variable("currentCommand")
await tab.async_set_variable("user.myVar", "value")

# Invoke registered function
result = await tab.async_invoke_function("my_function()")
```

### Splitter

The `root` property returns a `Splitter` representing the pane layout:

```python
def print_layout(node, indent=0):
    if isinstance(node, iterm2.Splitter):
        direction = "vertical" if node.vertical else "horizontal"
        print("  " * indent + f"Splitter ({direction})")
        for child in node.children:
            print_layout(child, indent + 1)
    else:
        print("  " * indent + f"Session: {node.session_id}")

print_layout(tab.root)
```

## iterm2.Session

Represents a terminal session (a single pane).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `session_id` | `str` | Unique identifier |
| `grid_size` | `Size` | Columns x rows |
| `preferred_size` | `Size` or `None` | Preferred dimensions |
| `tab` | `Tab` | Parent tab |
| `window` | `Window` | Parent window |

### Methods

#### Text Input/Output

```python
# Send text (use \n for Enter)
await session.async_send_text("ls -la\n")
await session.async_send_text("password", suppress_broadcast=True)

# Inject text (appears as if received from shell)
await session.async_inject(b"\x1b[31mRed text\x1b[0m")

# Get screen contents
contents = await session.async_get_screen_contents()
for i in range(contents.number_of_lines):
    line = contents.line(i)
    print(line.string)

# Alternative: get contents with history
contents = await session.async_get_contents(
    first_line=-100,  # Negative = scrollback history
    last_line=-1
)
```

#### Pane Management

```python
# Split pane
new_session = await session.async_split_pane(vertical=True)
new_session = await session.async_split_pane(
    vertical=False,
    before=True,           # Split above/left
    profile="MyProfile",
    command="htop"
)

# Set grid size
await session.async_set_grid_size(iterm2.Size(120, 40))

# Activate (focus) session
await session.async_activate()

# Bury/unbury session
await session.async_set_buried(True)

# Close session
await session.async_close(force=False)
```

#### Profile

```python
# Get current profile
profile = await session.async_get_profile()

# Modify session's profile
change = iterm2.LocalWriteOnlyProfile()
change.set_background_color(iterm2.Color(0, 0, 0))
await session.async_set_profile_properties(change)

# Set name (shown in tab title)
await session.async_set_name("My Session")
```

#### Selection

```python
# Get selection
selection = await session.async_get_selection()
for sub in selection.sub_selections:
    print(f"Range: {sub.windowed_coord_range}")

# Get selected text
text = await session.async_get_selection_text(selection)

# Set selection
sub = iterm2.SubSelection(
    iterm2.WindowedCoordRange(
        iterm2.CoordRange(
            iterm2.Coord(0, 0),
            iterm2.Coord(10, 0)
        )
    ),
    iterm2.SelectionMode.CHARACTER
)
await session.async_set_selection(iterm2.Selection([sub]))
```

#### Variables

```python
# Get variable
path = await session.async_get_variable("path")
command = await session.async_get_variable("currentCommand")
hostname = await session.async_get_variable("hostname")

# Set user variable
await session.async_set_variable("user.myVar", "value")
```

#### Other

```python
# Restart session
await session.async_restart(only_if_exited=True)

# Line info
info = await session.async_get_line_info()
print(f"Scrollback lines: {info.scrollback_buffer_height}")
print(f"Screen lines: {info.screen_height}")

# Coprocess (external program connected to session I/O)
await session.async_run_coprocess("/path/to/script")
coprocess = await session.async_get_coprocess()
await session.async_stop_coprocess()

# Add annotation
await session.async_add_annotation("Note", length=10, coord=iterm2.Coord(0, 0))

# Tmux commands (when connected to tmux)
result = await session.async_run_tmux_command("list-windows")

# Screen streamer for real-time updates
async with session.get_screen_streamer() as streamer:
    while True:
        contents = await streamer.async_get()
        # Process screen contents
```

## Coordinates and Ranges

```python
# Point on screen
coord = iterm2.Coord(column=0, line=0)

# Range of coordinates
coord_range = iterm2.CoordRange(
    iterm2.Coord(0, 0),   # Start
    iterm2.Coord(10, 5)   # End
)

# Size
size = iterm2.Size(width=80, height=24)

# Frame (for windows)
frame = iterm2.Frame(
    iterm2.Point(x=100, y=100),
    iterm2.Size(width=800, height=600)
)
```
