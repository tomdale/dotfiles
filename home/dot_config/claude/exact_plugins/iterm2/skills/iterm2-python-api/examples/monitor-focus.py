#!/usr/bin/env python3
"""
Monitor Focus Example

Monitors focus changes between windows, tabs, and sessions.
Useful for triggering actions when the user switches context.
"""
import iterm2


async def main(connection):
    app = await iterm2.async_get_app(connection)

    print("Monitoring focus changes... (press Ctrl+C to stop)")

    async with iterm2.FocusMonitor(connection) as mon:
        while True:
            update = await mon.async_get_next_update()

            # Application became active/inactive
            if update.application_active is not None:
                active = update.application_active.application_active
                status = "active" if active else "inactive"
                print(f"[App] iTerm2 became {status}")

            # Window focus changed
            if update.window_changed is not None:
                window_id = update.window_changed.window_id
                reason = update.window_changed.event

                # Reason can be:
                # - TERMINAL_WINDOW_BECAME_KEY (window got focus)
                # - TERMINAL_WINDOW_IS_CURRENT (window is current)
                # - TERMINAL_WINDOW_RESIGNED_KEY (window lost focus)
                print(f"[Window] {window_id} - {reason.name}")

            # Tab selection changed
            if update.selected_tab_changed is not None:
                tab_id = update.selected_tab_changed.tab_id
                tab = app.get_tab_by_id(tab_id)
                if tab:
                    # Get tab info
                    num_sessions = len(tab.sessions)
                    print(f"[Tab] Switched to {tab_id} ({num_sessions} sessions)")

            # Active session changed
            if update.active_session_changed is not None:
                session_id = update.active_session_changed.session_id
                session = app.get_session_by_id(session_id)
                if session:
                    # Get session info
                    path = await session.async_get_variable("path")
                    print(f"[Session] Focused {session_id}")
                    if path:
                        print(f"          Path: {path}")


iterm2.run_forever(main)
