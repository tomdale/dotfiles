#!/usr/bin/env python3
"""
Simple iTerm2 Script Template

A one-shot script that performs an action and exits.
Run this script from iTerm2's Scripts menu or via 'python3 script.py'.

Location: ~/Library/Application Support/iTerm2/Scripts/
"""
import iterm2


async def main(connection):
    # Get the application object
    app = await iterm2.async_get_app(connection)

    # Get the current window (the one with keyboard focus)
    window = app.current_terminal_window

    if window is not None:
        # Get the current tab and session
        tab = window.current_tab
        session = tab.current_session

        # === YOUR CODE HERE ===
        # Example: Create a new tab
        # new_tab = await window.async_create_tab()

        # Example: Send text to current session
        # await session.async_send_text("echo 'Hello from script!'\n")

        # Example: Get screen contents
        # contents = await session.async_get_screen_contents()
        # for i in range(contents.number_of_lines):
        #     print(contents.line(i).string)

        pass

    else:
        # No current window - you might want to create one
        print("No current window")
        # window = await iterm2.Window.async_create(connection)


# Run the script
iterm2.run_until_complete(main)
