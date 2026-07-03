#!/usr/bin/env python3
"""
iTerm2 Daemon Script Template

A long-running script that monitors events and responds to them.
Place in AutoLaunch folder to start automatically with iTerm2.

Location: ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/
"""
import asyncio
import iterm2


async def main(connection):
    # Get the application object
    app = await iterm2.async_get_app(connection)

    # === CHOOSE YOUR MONITOR ===
    # Uncomment one of the following monitor patterns:

    # --- Option 1: Monitor new sessions ---
    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()
            session = app.get_session_by_id(session_id)
            if session:
                # Handle new session
                print(f"New session created: {session_id}")
                # Example: Set a custom variable
                # await session.async_set_variable("user.created_by_script", True)

    # --- Option 2: Monitor focus changes ---
    # async with iterm2.FocusMonitor(connection) as mon:
    #     while True:
    #         update = await mon.async_get_next_update()
    #         if update.active_session_changed:
    #             session_id = update.active_session_changed.session_id
    #             print(f"Session focused: {session_id}")

    # --- Option 3: Monitor variable changes ---
    # async with iterm2.VariableMonitor(
    #     connection,
    #     iterm2.VariableScopes.SESSION,
    #     "path",  # Variable to watch
    #     None     # None = all sessions
    # ) as mon:
    #     while True:
    #         new_value = await mon.async_get()
    #         print(f"Path changed to: {new_value}")

    # --- Option 4: Multiple monitors ---
    # async def monitor_sessions():
    #     async with iterm2.NewSessionMonitor(connection) as mon:
    #         while True:
    #             session_id = await mon.async_get()
    #             print(f"New session: {session_id}")
    #
    # async def monitor_terminations():
    #     async with iterm2.SessionTerminationMonitor(connection) as mon:
    #         while True:
    #             session_id = await mon.async_get()
    #             print(f"Session closed: {session_id}")
    #
    # asyncio.create_task(monitor_sessions())
    # asyncio.create_task(monitor_terminations())
    # # Keep main alive
    # while True:
    #     await asyncio.sleep(3600)


# Run forever (daemon mode)
iterm2.run_forever(main)
