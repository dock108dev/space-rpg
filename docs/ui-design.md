# Interface conventions

`game/scripts/glass_ui.gd` defines the shared theme: translucent StyleBoxFlat panels, rounded edges, borders and readable text contrast. These are drawn surfaces, not a screen-reading blur shader. Runtime code and art inside the repository are the styling dependencies.

The current player uses a fixed 1280×980 logical canvas, with minimum physical content of 1152×882. Keep world positions and movement coordinates independent of interface enlargement.

The HUD displays the current objective or immediate danger/care task. A combined lower panel holds the outside-audience note when public, current response or History, contextual choices, command input and Stop. Responses begin below the actual audience-note height. Long content remains in History; a concise chapter report distinguishes recorded report conditions from current inventory/health.

The 100%/125% control is available during setup and play. It scales Control font sizes from stored baselines, rounded to whole sizes; repeated toggles must not compound. Setup and Help resize/reflow. Pause uses a foreground layer and backdrop, with recovery controls visible above the game. System font objects are reused during toggles and allow system fallback for character names.

Tab moves focus, Space activates buttons, and Return submits commands. Closing Help restores command focus. Clicking the world returns direct movement controls. Disabled choices communicate prerequisites without replacing the underlying gameplay checks. Stop remains available to cancel future work.

Use the native interface checks in [validation](validation.md) after layout changes. A screenshot or passing layout assertion cannot establish enjoyable play or general accessibility compliance.
