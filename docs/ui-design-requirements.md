# Space Opera RPG UI design requirements

## Start with the task

Each screen should make its purpose, current result or state, and next useful action easy to find. The default is one compact heading, useful content, and a clear action. Add descriptions, panels, and statuses only when they help a decision.

- Use familiar words and sentence case. “Continue game” is clearer than “Restore state”. Explain blocked actions in terms of what the player or user can do next.
- Keep useful labels, units, dates and status distinctions. “Remaining action points” is clearer than “Value”.
- Remove repeated titles, filler, decorative category labels, and explanations of obvious controls. Keep teaching, narrative, and consequential explanations that serve the product.
- Show the result or working area early. Prefer compact rows for comparisons and related facts together. Keep controls close to their result. Do not force every value into its own card.
- Put advanced setup, full history, technical identifiers, and lengthy explanations behind named secondary controls. Keep current blockers, meaningful uncertainty, freshness, costs, and destructive consequences visible where they matter.
- Preserve stop, cancel, recovery, and confirmation behavior. Do not replace scrolling with extra steps, nested scrolling, or a maze of tabs and dialogs.

## Appearance and accessibility

Use the implemented dark glass panels, light controls, system typography and blue action emphasis. Use `game/scripts/glass_ui.gd` for the implemented theme.

Use readable text at the supported game window sizes; 44 logical pixels is a target for primary control height, not a claim that every current control meets it. Use compact spacing, not tiny type or cramped targets. Compact headers replace giant hero sections. Avoid widespread uppercase, widely spaced labels, and pills for ordinary information.

Blue indicates action or selection. Success, caution, and errors have meaningful text as well as color. Preserve negative, zero, unknown, stale, and unavailable states. Essential information must not depend on an unexplained icon, clipped text, color, or hover alone.

Design targets: use native semantics, clear labels, visible focus, logical keyboard order, and dialogs that return focus. Target readable contrast: at least 4.5:1 for ordinary text and 3:1 for meaningful control boundaries and large text. Check composited colors on translucent surfaces. Reduced-motion and transparency preference handling are design targets, not currently implemented settings; no general accessibility-compliance claim has been established.

## Before calling a screen improved

Compare representative before/after states at the same viewport and with the same data. Inspect desktop and narrow sizes the product supports; use real supported window sizes for games. Check increased text scale, long content, keyboard access, disclosures, and empty/error/disabled states relevant to the change.

Confirm the important result and action are easier to find without losing meaning or adding routine task steps. Word counts and pixel measurements support the review; they do not establish usability by themselves.

Keep design guidance consistent with the implementation. Preserve data contracts, calculations, permissions, persistence and game rules.
