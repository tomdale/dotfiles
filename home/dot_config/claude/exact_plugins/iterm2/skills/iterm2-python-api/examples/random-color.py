#!/usr/bin/env python3
"""
Random Color Example

Assigns a random color preset to each new session.
Place in AutoLaunch folder for automatic startup.
"""
import iterm2
import random


async def main(connection):
    app = await iterm2.async_get_app(connection)

    # Get list of available color presets
    preset_names = await iterm2.ColorPreset.async_get_list(connection)
    print(f"Available presets: {preset_names}")

    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            # Wait for a new session
            session_id = await mon.async_get()
            session = app.get_session_by_id(session_id)

            if session:
                try:
                    # Pick a random preset
                    preset_name = random.choice(preset_names)
                    preset = await iterm2.ColorPreset.async_get(
                        connection, preset_name
                    )

                    # Apply it to the session
                    profile = await session.async_get_profile()
                    await profile.async_set_color_preset(preset)

                    print(f"Applied '{preset_name}' to session {session_id}")
                except Exception as e:
                    print(f"Error: {e}")


iterm2.run_forever(main)
