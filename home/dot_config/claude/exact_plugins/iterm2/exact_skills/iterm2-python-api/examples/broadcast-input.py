#!/usr/bin/env python3
"""
Broadcast Input Example

Creates multiple panes and demonstrates sending the same input to all of them.
Useful for running the same command on multiple servers.
"""
import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)

    # Create a new window
    window = await iterm2.Window.async_create(connection)

    if window:
        tab = window.current_tab
        session1 = tab.current_session

        # Create a 2x2 grid of panes
        session2 = await session1.async_split_pane(vertical=True)
        session3 = await session1.async_split_pane(vertical=False)
        session4 = await session2.async_split_pane(vertical=False)

        # All sessions in this tab
        all_sessions = [session1, session2, session3, session4]

        # Label each pane
        for i, session in enumerate(all_sessions, 1):
            await session.async_send_text(f"echo 'Pane {i}'\n")

        # Function to send to all sessions
        async def broadcast(text):
            for session in all_sessions:
                await session.async_send_text(text)

        # Send the same command to all panes
        await broadcast("echo 'This message appears in all panes'\n")

        print("Created 4 panes and broadcast a message to all")


iterm2.run_until_complete(main)
