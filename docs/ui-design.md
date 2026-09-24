# Space Opera RPG UI design

Updated September 23, 2026. B2 adopts Glass Starter 02 hierarchy and wording; presentation-only follow-up UI-02.

## For future contributors

Start with [local design requirements](ui-design-requirements.md), then review the shared [UI Templates gallery](../../ui-templates/index.html) and [template guide](../../ui-templates/README.md). The source folder on the owner's Mac is `/Users/michaelfuscoletti/Desktop/ui-templates`. It contains dashboard, list/table, form/setup, settings, detail, state/dialog, and native Godot starters.

Use light cool glass, slate text, blue actions, restrained depth, rounded controls, and system typography as the default. Do not reintroduce the generic beige/green/yellow template. Preserve explicit semantic success, caution, error, unavailable, and unknown states. Readability and the task's layout outrank decoration.

The shared folder is a design reference, not a runtime dependency. Project assets are checked in locally and can run without the Desktop folder. If you receive this repository alone, this local requirements copy and the implementation describe the baseline. Request the source template folder when you need the full gallery. Template revisions are adopted deliberately, never silently synchronized.

## A1 / A1a interaction design

The primary product surface after B2 is a modern text adventure: readable narrative/action history, natural-language input, contextual multiple-choice actions and the current illustrated scene. Make discovery, story choices, actual movement and outcomes easy to follow. Direct controls remain available. Text focus must capture typing without sending movement shortcuts to the world; Stop remains accessible. Art and chrome serve A1 command play and A1a story/gameplay. [B2.5 contract](slices/B2.5-command-adventure.md).

## This project's adaptation

Working S03/S04 controls use the native template; the HUD uses a cool dark glass adaptation for contrast over the illustrated world. Game art and mechanics remain unchanged. Frozen builds/S04-20260909-01 and Launch Owner Play.command remain the original candidate. Launch S04.command uses the changed working source; no frozen-candidate acceptance transfers. Native surfaces do not use a screen-reading blur shader.

Implementation: shared local theme in `game/scripts/glass_ui.gd`; B2 presentation in `game/scripts/chapter_opening.gd`. The theme originated in Starter 01. UI-02 deliberately adapts Starter 02: objective first, one contextual action row, 44px buttons, keyboard focus, visible recovery, and optional controls/save details in Pause. It does not replace the illustrated world or implement B2.5. Save and Continue stay one click away; New practice moves into the secondary Pause details. The existing source-validation entry point `scripts/validate.sh B2` includes focused UI/input checks.

## Review and status

See [UI adoption verification](ui-verification.md). Source changes and technical/visual checks do not establish owner acceptance, a new release, live-data qualification, or acceptance of an older frozen candidate. Existing project-specific gates remain separate.
