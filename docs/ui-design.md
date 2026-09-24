# Space Opera RPG UI design

Use the [design requirements](ui-design-requirements.md) and `game/scripts/glass_ui.gd` when changing the interface.

## Layout and behavior

The primary interface combines readable narrative/action history, bounded natural-language input, contextual choices and the illustrated scene. Direct controls remain available. Text focus must capture typing without sending movement shortcuts to the world; Stop remains accessible.

The HUD uses cool dark translucent surfaces for contrast over the world. Put the objective first, followed by contextual actions. Save and Continue stay directly available; secondary controls and save details live in Pause. Native surfaces do not use a screen-reading blur shader.

`game/scripts/chapter_opening.gd` implements the opening interface; `command_adventure.gd` adds command/story interaction. Preserve illustrated assets, game rules and save compatibility.

## Visual checks

Check the affected screens at supported sizes, including keyboard focus, long content, disabled actions and error recovery. Existing review records are in [UI verification](ui-verification.md).
