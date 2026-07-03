#!/usr/bin/env python3
"""
Create Window Example

Demonstrates creating windows, tabs, and split panes.
"""
import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)

    # Create a new window
    window = await iterm2.Window.async_create(connection)

    if window:
        # Get the initial tab and session
        tab = window.current_tab
        session = tab.current_session

        # Split the session vertically (side by side)
        right_session = await session.async_split_pane(vertical=True)

        # Split the right session horizontally (top and bottom)
        bottom_right = await right_session.async_split_pane(vertical=False)

        # Send commands to each pane
        await session.async_send_text("echo 'Top Left'\n")
        await right_session.async_send_text("echo 'Top Right'\n")
        await bottom_right.async_send_text("echo 'Bottom Right'\n")

        # Create a second tab
        tab2 = await window.async_create_tab()
        await tab2.current_session.async_send_text("echo 'Second Tab'\n")

        print("Created window with split panes and two tabs")
    else:
        print("Failed to create window")


iterm2.run_until_complete(main)
