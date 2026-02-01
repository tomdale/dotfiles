#!/usr/bin/env python3
"""
iTerm2 Title Provider Template

Creates a custom session title provider that appears in Profile settings.
Place in AutoLaunch folder to make it available.

Location: ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/

Setup:
1. Run this script
2. Go to Preferences > Profiles > General
3. Click the "Title" dropdown
4. Select your custom title provider
"""
import iterm2


async def main(connection):
    # === TITLE PROVIDER FUNCTION ===
    # This function is called whenever any referenced variable changes.
    # It should return a string to display as the session title.
    @iterm2.TitleProviderRPC
    async def custom_title(
        # Reference variables that should trigger title updates
        # Use ? suffix for optional variables (returns None if undefined)
        auto_name=iterm2.Reference("autoName?"),
        path=iterm2.Reference("path?"),
        hostname=iterm2.Reference("hostname?"),
        username=iterm2.Reference("username?"),
        command=iterm2.Reference("currentCommand?"),
    ):
        # === YOUR TITLE LOGIC HERE ===

        # Example 1: Simple upper-case name
        # if auto_name:
        #     return auto_name.upper()
        # return ""

        # Example 2: Show hostname for SSH sessions
        if hostname and hostname != "localhost":
            title = f"{username}@{hostname}" if username else hostname
            if command:
                title += f": {command}"
            return title

        # Example 3: Show current directory
        if path:
            # Show just the last component
            return path.split("/")[-1]

        # Example 4: Show running command
        if command:
            return command

        # Fallback to auto-generated name
        return auto_name or ""

    # === REGISTER THE TITLE PROVIDER ===
    await custom_title.async_register(
        connection,
        # Name shown in Preferences > Profiles > General > Title dropdown
        display_name="My Custom Title",

        # Unique identifier (persists across code changes)
        # Use reverse domain notation
        unique_identifier="com.example.my-custom-title"
    )


# Run forever (daemon mode)
iterm2.run_forever(main)
