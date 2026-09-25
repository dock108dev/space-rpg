# Architecture and state ownership

The application is one offline Godot scene tree. It has no server, workers, scheduler, database or external gameplay integration. Timed movement and companion behavior run through Godot's process loop; pausing freezes simulation. Progress does not advance while the application is closed.

## Commands and state changes

`game/project.godot` starts `player_experience.tscn`. The exported bootstrap in `b9_boot.gd` starts that same player scene for ordinary play.

Typed text enters `command_adventure.gd::submit`. `adventure_language.gd` parses supported requests into bounded actions; the controller queues and dispatches them to domain handlers. Those handlers validate current targets, state and costs before changing anything. Questions return authored explanations without spending action points. Contextual choices use the same commands or controller actions as direct controls.

Stop cancels future queued work; a committed animation finishes. Ending a danger turn stops the old plan, lets eligible companions and the enemy respond, then restores action points. Loading restores saved state with command queues inactive.

## Controller and rules map

| Responsibility | Authoritative code |
| --- | --- |
| Character setup, session selection, Help/History, text size and final layout | `game/scripts/player_experience.gd` |
| Parsing, queue, submission and Stop | `adventure_language.gd`, `command_adventure.gd` |
| Opening encounter, chapter transitions and pause/recovery controls | `tactical_encounter.gd`, `chapter_opening.gd` |
| Connected locations and jobs | `connected_world.gd`, `world_locations.gd` |
| Equipment and harmless training | `preparation.gd`, `preparation_rules.gd` |
| Private home, furnishings and storage | `owned_home.gd`, `home_rules.gd` |
| Companion support, recoverable conditions and treatment | `companions_care.gd`, `care_rules.gd` |
| Relay expedition, crossing and report | `expedition.gd`, `expedition_rules.gd` |
| Shared panel/button styling and world art | `glass_ui.gd` and the art/controller tree |

Paths after the first rows are relative to `game/scripts`. Inheritance combines these live capabilities; similarly named methods often implement different encounter rules. Pure rule/location modules also supply geometry and constraints to their save validators.

## Persistence contract

Chapter initialization calls the most-derived `create_save_store` once. The current player chooses `ExperienceSave`; explicit prototype scenes select their declared schemas. New-character and Earlier-character actions can subsequently change the selected session.

Validation follows the same domain chain: `experience_save.gd` → expedition → care → home → preparation → world → adventure → chapter → tactical save. Each module validates its added fields and delegates. Character validation owns sanitized names, appearance and facing. Expedition validation checks exact numeric ranges before normalizing a local copy for initial-state comparison; it does not mutate input data.

`tactical_save.gd` owns snapshot scanning, immutable sequence allocation and atomic writes. `chapter_save.gd` owns writer markers and recovery. A successful temporary-file write/flush followed by rename commits the snapshot. Domain transaction code rolls back failed snapshot writes; selector or cleanup failure after commit is reported as partial success rather than undoing an already committed save.

Snapshots include schema versions, character identity, position, action points, equipment/material state, home/storage, companion conditions, expedition progress and authored history. Versions are validated; unsupported or malformed snapshots are skipped with a notice. Sequence numbers must agree with filenames. Loading never executes save-file content. No automatic migration is provided.

The chapter report stores historical conditions at filing, separately from current companion conditions. Subsequent treatment does not rewrite that report; the report reward is paid once. Outside-audience text is presentation only and supplies no character knowledge or rewards. An owned home suppresses that presentation; temporary shelter remains public.

## Boundaries

The current source entry and exported entry share the player implementation but use different save roots; see [configuration](development.md). Test seams and prototype scenes are explicit supported callers, not fallback paths for current character data. [Security](security.md) and [error handling](error-handling.md) define the file-access limits. Changing a schema or retiring a prototype requires checking real callers and persisted compatibility, not simply renaming historical identifiers.
