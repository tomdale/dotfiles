#!/usr/bin/env python3
"""
iTerm2 RPC Function Template

Registers a function that can be invoked from key bindings or triggers.
Place in AutoLaunch folder, then bind to a keystroke in Preferences.

Location: ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/

Setup:
1. Run this script
2. Go to Preferences > Keys (or Profiles > Keys)
3. Click + to add a new key binding
4. Set "Action" to "Invoke Script Function"
5. Enter: my_function(session_id: id)
"""
import iterm2


async def main(connection):
    # Get app reference (needed to look up sessions)
    app = await iterm2.async_get_app(connection)

    # === BASIC RPC FUNCTION ===
    @iterm2.RPC
    async def my_function(session_id=iterm2.Reference("id")):
        """
        Example function that operates on the current session.

        Invocation: my_function(session_id: id)
        """
        session = app.get_session_by_id(session_id)
        if not session:
            return

        # === YOUR CODE HERE ===
        # Example: Send text
        await session.async_send_text("echo 'Hello from RPC!'\n")

        # Example: Clear scrollback
        # code = b'\x1b]1337;ClearScrollback\x07'
        # await session.async_inject(code)

        # Example: Change profile colors
        # change = iterm2.LocalWriteOnlyProfile()
        # change.set_background_color(iterm2.Color(30, 30, 40))
        # await session.async_set_profile_properties(change)

    await my_function.async_register(connection)

    # === RPC WITH CUSTOM ARGUMENTS ===
    @iterm2.RPC
    async def send_command(command, session_id=iterm2.Reference("id")):
        """
        Send a specific command to the session.

        Invocation: send_command(command: "ls -la", session_id: id)
        """
        session = app.get_session_by_id(session_id)
        if session:
            await session.async_send_text(command + "\n")

    await send_command.async_register(connection)

    # === RPC THAT OPERATES ON ALL SESSIONS ===
    @iterm2.RPC
    async def clear_all_sessions():
        """
        Clear scrollback in all sessions.

        Invocation: clear_all_sessions()
        """
        code = b'\x1b]1337;ClearScrollback\x07'
        for window in app.terminal_windows:
            for tab in window.tabs:
                for session in tab.sessions:
                    await session.async_inject(code)

    await clear_all_sessions.async_register(connection)

    # === RPC WITH RETURN VALUE (for composition) ===
    @iterm2.RPC
    async def get_session_path(session_id=iterm2.Reference("id")):
        """
        Get the current path of a session.

        Invocation: get_session_path(session_id: id)
        Can be composed: other_func(path: get_session_path(session_id: id))
        """
        session = app.get_session_by_id(session_id)
        if session:
            return await session.async_get_variable("path")
        return None

    await get_session_path.async_register(connection)


# Run forever (daemon mode)
iterm2.run_forever(main)
