#!/usr/bin/env python3

from __future__ import annotations

import asyncio
import logging
import iterm2

logging.basicConfig(
    level=logging.WARNING,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Track tasks per session for cleanup
session_tasks: dict[str, list[asyncio.Task]] = {}

WATCHED_VARS = ["currentGoal", "currentActivity"]


def find_tab_for_session(app, session_id):
    """Find the tab containing a given session."""
    for window in app.terminal_windows:
        for tab in window.tabs:
            for session in tab.sessions:
                if session.session_id == session_id:
                    return tab
    return None


async def main(connection):
    app = await iterm2.async_get_app(connection)
    logger.info("Sync Title script started")

    async def update_tab_from_session(session, tab):
        """Read both variables from a session and update the tab atomically."""
        logger.info(f"update_tab_from_session called for session={session.session_id}, tab={tab.tab_id}")
        try:
            goal = await session.async_get_variable("user.currentGoal") or ""
            activity = await session.async_get_variable("user.currentActivity") or ""
        except iterm2.RPCException as e:
            logger.error(f"Failed to read session variables: {e}")
            return

        last_update = f"{goal} - {activity}" if activity else goal

        logger.info(
            f"Session {session.session_id} -> Tab {tab.tab_id}: "
            f"lastGoal='{goal}', lastActivity='{activity}', lastUpdate='{last_update}'"
        )

        try:
            await tab.async_set_variable("user.lastGoal", goal)
            logger.info(f"Set user.lastGoal on tab {tab.tab_id}")
            await tab.async_set_variable("user.lastActivity", activity)
            logger.info(f"Set user.lastActivity on tab {tab.tab_id}")
            await tab.async_set_variable("user.lastUpdate", last_update)
            logger.info(f"Set user.lastUpdate on tab {tab.tab_id}")
        except iterm2.RPCException as e:
            logger.error(f"Failed to set tab variable on {tab.tab_id}: {e}")

    async def watch_variable(session_id, var_name):
        """Watch a session variable and propagate changes to the containing tab."""
        session = app.get_session_by_id(session_id)
        if not session:
            return

        try:
            async with iterm2.VariableMonitor(
                    connection,
                    iterm2.VariableScopes.SESSION,
                    f"user.{var_name}",
                    session_id) as mon:
                while True:
                    new_value = await mon.async_get()
                    logger.info(f"Watcher fired: session={session_id}, var=user.{var_name}, value='{new_value}'")

                    session = app.get_session_by_id(session_id)
                    if not session:
                        logger.warning(f"Session {session_id} gone after watcher fired")
                        return

                    tab = find_tab_for_session(app, session_id)
                    if not tab:
                        logger.warning(f"No tab found for session {session_id}")
                        return

                    await update_tab_from_session(session, tab)

        except asyncio.CancelledError:
            raise
        except Exception as e:
            logger.error(f"Error in watcher for {session_id}/{var_name}: {e}")

    async def monitor_new_sessions():
        async with iterm2.NewSessionMonitor(connection) as mon:
            while True:
                session_id = await mon.async_get()
                logger.info(f"New session detected: {session_id}")

                tasks = [
                    asyncio.create_task(watch_variable(session_id, var_name))
                    for var_name in WATCHED_VARS
                ]
                session_tasks[session_id] = tasks

    async def monitor_session_termination():
        async with iterm2.SessionTerminationMonitor(connection) as mon:
            while True:
                session_id = await mon.async_get()
                logger.info(f"Session terminated: {session_id}")

                if session_id in session_tasks:
                    for task in session_tasks[session_id]:
                        task.cancel()
                    del session_tasks[session_id]

    await asyncio.gather(
        monitor_new_sessions(),
        monitor_session_termination(),
    )


iterm2.run_forever(main)
