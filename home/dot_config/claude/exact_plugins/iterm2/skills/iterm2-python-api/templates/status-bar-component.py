#!/usr/bin/env python3
"""
iTerm2 Status Bar Component Template

Creates a custom status bar component that displays dynamic information.
Place in AutoLaunch folder, then enable via Preferences > Profiles > Session.

Location: ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/

Setup:
1. Run this script
2. Go to Preferences > Profiles > Session
3. Enable "Status bar enabled"
4. Click "Configure Status Bar"
5. Drag your component from the list
"""
import iterm2


async def main(connection):
    # === CONFIGURATION KNOBS ===
    # These appear in the component's settings when user clicks "Configure Component"
    knobs = [
        # Checkbox: iterm2.CheckboxKnob("Label", default_value, "key")
        iterm2.CheckboxKnob("Show Emoji", True, "show_emoji"),

        # Text input: iterm2.StringKnob("Label", "placeholder", "default", "key")
        iterm2.StringKnob("Prefix", "Enter prefix", "", "prefix"),

        # Number: iterm2.PositiveFloatingPointKnob("Label", default, "key")
        # iterm2.PositiveFloatingPointKnob("Update Interval", 5.0, "interval"),

        # Color picker: iterm2.ColorKnob("Label", default_color, "key")
        # iterm2.ColorKnob("Text Color", iterm2.Color(255, 255, 255), "color"),
    ]

    # === COMPONENT DEFINITION ===
    component = iterm2.StatusBarComponent(
        # Name shown in status bar configuration
        short_description="My Component",

        # Tooltip/help text
        detailed_description="Description of what this component shows",

        # Configuration knobs defined above
        knobs=knobs,

        # Example text (helps iTerm2 size the component)
        exemplar="Example Text",

        # Update frequency in seconds (None = only update on variable changes)
        update_cadence=None,

        # Unique identifier (use reverse domain notation)
        identifier="com.example.my-status-bar-component"
    )

    # === STATUS BAR CALLBACK ===
    # This function is called whenever:
    # - Any referenced variable changes
    # - The update_cadence timer fires
    # - Component configuration changes
    @iterm2.StatusBarRPC
    async def coro(
        knobs,
        # Reference session variables that trigger updates
        rows=iterm2.Reference("rows"),
        cols=iterm2.Reference("columns"),
        # Use ? suffix for optional variables
        path=iterm2.Reference("path?"),
    ):
        # Access knob values
        show_emoji = knobs.get("show_emoji", True)
        prefix = knobs.get("prefix", "")

        # Build the status text
        text = f"{prefix}{cols}x{rows}"

        if show_emoji:
            text = f"{text}"

        # Return a string for fixed-width display
        return text

        # Or return a list for variable-length display (longest to shortest)
        # return [
        #     f"Session: {cols}x{rows} in {path}",
        #     f"{cols}x{rows} - {path}",
        #     f"{cols}x{rows}",
        #     f"{cols}x{rows}"
        # ]

    # Register the component
    await component.async_register(connection, coro)


# Run forever (daemon mode)
iterm2.run_forever(main)
