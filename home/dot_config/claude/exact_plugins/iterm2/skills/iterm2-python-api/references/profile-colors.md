# Profiles and Colors

Profiles control the appearance and behavior of sessions. Colors can be managed via profiles or color presets.

## iterm2.Profile

Represents a session's profile with all settings.

### Getting Profiles

```python
# Get profile for a session
profile = await session.async_get_profile()

# Get profile by name
profile = await iterm2.Profile.async_get(connection, "MyProfile")

# Get default profile
profile = await iterm2.Profile.async_get_default(connection)

# Make a profile the default
await profile.async_make_default()
```

### Reading Properties

```python
profile = await session.async_get_profile()

# Colors
bg_color = profile.background_color      # iterm2.Color
fg_color = profile.foreground_color
cursor_color = profile.cursor_color
selection_color = profile.selection_color
tab_color = profile.tab_color

# Fonts
font = profile.normal_font               # e.g., "Monaco 12"
non_ascii_font = profile.non_ascii_font

# Behavior
scrollback = profile.scrollback_lines    # int
unlimited = profile.unlimited_scrollback # bool
transparency = profile.transparency      # float 0.0-1.0
blur = profile.blur                      # bool
blur_radius = profile.blur_radius        # float

# Name and GUID
name = profile.name
guid = profile.guid
```

### Modifying Profiles

Use `LocalWriteOnlyProfile` to modify a session's profile without affecting the underlying profile definition:

```python
# Create change object
change = iterm2.LocalWriteOnlyProfile()

# Set properties
change.set_background_color(iterm2.Color(30, 30, 30))
change.set_foreground_color(iterm2.Color(200, 200, 200))
change.set_transparency(0.1)
change.set_blur(True)
change.set_blur_radius(10.0)
change.set_normal_font("Menlo 14")

# Apply to session
await session.async_set_profile_properties(change)
```

To modify the actual profile definition (affects all sessions using it):

```python
profile = await session.async_get_profile()
await profile.async_set_background_color(iterm2.Color(0, 0, 0))
await profile.async_set_normal_font("Monaco 12")
```

### Common Profile Properties

#### Colors

| Property | Setter | Type |
|----------|--------|------|
| `background_color` | `set_background_color` | `Color` |
| `foreground_color` | `set_foreground_color` | `Color` |
| `bold_color` | `set_bold_color` | `Color` |
| `cursor_color` | `set_cursor_color` | `Color` |
| `cursor_text_color` | `set_cursor_text_color` | `Color` |
| `selection_color` | `set_selection_color` | `Color` |
| `selected_text_color` | `set_selected_text_color` | `Color` |
| `tab_color` | `set_tab_color` | `Color` |
| `underline_color` | `set_underline_color` | `Color` |
| `badge_color` | `set_badge_color` | `Color` |
| `link_color` | `set_link_color` | `Color` |
| `ansi_0_color` through `ansi_15_color` | `set_ansi_N_color` | `Color` |

#### Fonts

| Property | Setter | Type |
|----------|--------|------|
| `normal_font` | `set_normal_font` | `str` |
| `non_ascii_font` | `set_non_ascii_font` | `str` |
| `use_non_ascii_font` | `set_use_non_ascii_font` | `bool` |
| `horizontal_spacing` | `set_horizontal_spacing` | `float` |
| `vertical_spacing` | `set_vertical_spacing` | `float` |
| `use_bold_font` | `set_use_bold_font` | `bool` |
| `use_italic_font` | `set_use_italic_font` | `bool` |
| `ascii_ligatures` | `set_ascii_ligatures` | `bool` |
| `non_ascii_ligatures` | `set_non_ascii_ligatures` | `bool` |

#### Appearance

| Property | Setter | Type |
|----------|--------|------|
| `transparency` | `set_transparency` | `float` (0.0-1.0) |
| `blur` | `set_blur` | `bool` |
| `blur_radius` | `set_blur_radius` | `float` |
| `blend` | `set_blend` | `float` (0.0-1.0) |
| `minimum_contrast` | `set_minimum_contrast` | `float` |
| `cursor_type` | `set_cursor_type` | `CursorType` |
| `blinking_cursor` | `set_blinking_cursor` | `bool` |
| `use_cursor_guide` | `set_use_cursor_guide` | `bool` |
| `cursor_guide_color` | `set_cursor_guide_color` | `Color` |
| `use_tab_color` | `set_use_tab_color` | `bool` |
| `background_image_location` | `set_background_image_location` | `str` |
| `background_image_mode` | `set_background_image_mode` | `BackgroundImageMode` |

#### Scrollback

| Property | Setter | Type |
|----------|--------|------|
| `scrollback_lines` | `set_scrollback_lines` | `int` |
| `unlimited_scrollback` | `set_unlimited_scrollback` | `bool` |

#### Badge

| Property | Setter | Type |
|----------|--------|------|
| `badge_text` | `set_badge_text` | `str` |
| `badge_color` | `set_badge_color` | `Color` |
| `badge_font` | `set_badge_font` | `str` |
| `badge_max_width` | `set_badge_max_width` | `float` |
| `badge_max_height` | `set_badge_max_height` | `float` |

#### Command

| Property | Setter | Type |
|----------|--------|------|
| `command` | `set_command` | `str` |
| `use_custom_command` | `set_use_custom_command` | `bool` |
| `custom_directory` | `set_custom_directory` | `str` |
| `initial_directory_mode` | `set_initial_directory_mode` | `InitialWorkingDirectory` |

### Enums

```python
# Cursor types
iterm2.CursorType.CURSOR_TYPE_UNDERLINE
iterm2.CursorType.CURSOR_TYPE_VERTICAL
iterm2.CursorType.CURSOR_TYPE_BOX

# Background image modes
iterm2.BackgroundImageMode.STRETCH
iterm2.BackgroundImageMode.TILE
iterm2.BackgroundImageMode.ASPECT_FILL
iterm2.BackgroundImageMode.ASPECT_FIT

# Initial directory
iterm2.InitialWorkingDirectory.USE_STARTUP_OPTIONS
iterm2.InitialWorkingDirectory.HOME_DIRECTORY
iterm2.InitialWorkingDirectory.REUSE_PREVIOUS_DIRECTORY
iterm2.InitialWorkingDirectory.CUSTOM_DIRECTORY
```

## iterm2.Color

Represents an RGB color.

```python
# Create color (0-255 for each component)
color = iterm2.Color(red=255, green=128, blue=0)
color = iterm2.Color(255, 128, 0)

# With alpha
color = iterm2.Color(255, 128, 0, alpha=200)

# Access components
r = color.red
g = color.green
b = color.blue
a = color.alpha
```

## iterm2.ColorPreset

Named collections of colors that can be applied to profiles.

### List Available Presets

```python
preset_names = await iterm2.ColorPreset.async_get_list(connection)
# Returns: ["Solarized Dark", "Solarized Light", "Tango Dark", ...]
```

### Get a Preset

```python
preset = await iterm2.ColorPreset.async_get(connection, "Solarized Dark")
```

### Apply Preset to Session

```python
profile = await session.async_get_profile()
preset = await iterm2.ColorPreset.async_get(connection, "Solarized Dark")
await profile.async_set_color_preset(preset)
```

### Inspect Preset Colors

```python
preset = await iterm2.ColorPreset.async_get(connection, "Solarized Dark")
for color in preset.values:
    print(f"{color.key}: RGB({color.red}, {color.green}, {color.blue})")
```

Color keys include: `Foreground Color`, `Background Color`, `Bold Color`, `Cursor Color`, `Cursor Text Color`, `Selected Text Color`, `Selection Color`, `Ansi 0 Color` through `Ansi 15 Color`, etc.

## Example: Random Color on New Session

```python
#!/usr/bin/env python3
import iterm2
import random

async def main(connection):
    app = await iterm2.async_get_app(connection)
    presets = await iterm2.ColorPreset.async_get_list(connection)

    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()
            session = app.get_session_by_id(session_id)
            if session:
                preset_name = random.choice(presets)
                preset = await iterm2.ColorPreset.async_get(connection, preset_name)
                profile = await session.async_get_profile()
                await profile.async_set_color_preset(preset)

iterm2.run_forever(main)
```

## Example: Set Tab Color Based on Host

```python
#!/usr/bin/env python3
import iterm2

HOST_COLORS = {
    "production": iterm2.Color(255, 0, 0),      # Red
    "staging": iterm2.Color(255, 165, 0),       # Orange
    "development": iterm2.Color(0, 255, 0),     # Green
}

async def main(connection):
    app = await iterm2.async_get_app(connection)

    async with iterm2.VariableMonitor(
        connection,
        iterm2.VariableScopes.SESSION,
        "hostname",
        None  # Monitor all sessions
    ) as mon:
        while True:
            hostname = await mon.async_get()
            for name, color in HOST_COLORS.items():
                if name in hostname.lower():
                    # Find the session and set tab color
                    for window in app.terminal_windows:
                        for tab in window.tabs:
                            for session in tab.sessions:
                                h = await session.async_get_variable("hostname")
                                if h == hostname:
                                    change = iterm2.LocalWriteOnlyProfile()
                                    change.set_tab_color(color)
                                    change.set_use_tab_color(True)
                                    await session.async_set_profile_properties(change)
                    break

iterm2.run_forever(main)
```
