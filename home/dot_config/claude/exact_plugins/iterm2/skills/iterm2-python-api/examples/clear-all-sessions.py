#!/usr/bin/env python3
"""
Clear All Sessions Example

Registers an RPC function that clears scrollback in all sessions.
Bind to a key in Preferences > Keys with: clear_all_sessions()
"""
import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def clear_all_sessions():
        """Clear scrollback buffer in all sessions."""
        # iTerm2's clear scrollback escape sequence
        clear_code = b'\x1b]1337;ClearScrollback\x07'

        count = 0
        for window in app.terminal_windows:
            for tab in window.tabs:
                for session in tab.sessions:
                    await session.async_inject(clear_code)
                    count += 1

        print(f"Cleared {count} sessions")

    await clear_all_sessions.async_register(connection)
    print("Registered clear_all_sessions() - bind it to a key!")

    # Also register a version that only clears current session
    @iterm2.RPC
    async def clear_session(session_id=iterm2.Reference("id")):
        """Clear scrollback buffer in the current session."""
        session = app.get_session_by_id(session_id)
        if session:
            clear_code = b'\x1b]1337;ClearScrollback\x07'
            await session.async_inject(clear_code)

    await clear_session.async_register(connection)
    print("Registered clear_session() - invoke with: clear_session(session_id: id)")


iterm2.run_forever(main)
