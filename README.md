# Space Opera RPG

Updated September 9, 2026. Working label; final title undecided.

**S04 TECHNICALLY COMPLETE — READY FOR S05 OWNER PLAY.** S05 preparation complete; owner session not started. S03 tactical assessment remains deferred.

Double-click [Launch Owner Play.command](Launch%20Owner%20Play.command). It opens the frozen **S04-20260909-01** candidate with separate fresh practice saves. If paused, Escape resumes. **Opening goal: Choose a power, then find your way to temporary shelter.**

Try all three power demonstrations and choose one. WASD/arrows step; E interacts; Enter ends a combat turn; right-click cancels targeting; Escape pauses/resumes. Click action buttons and their floor/creature targets in combat. Assign walk lets you watch safe movement and can be canceled with a movement key or Stop assignment. Save/Load latest operate at idle boundaries; finish movement/fetch assignments first. Focus loss pauses. No countdown. [Owner play card](docs/playtests/S05-owner-play-card.md).

S04 connects package retrieval/learning, the existing tactical encounter, temporary shelter and one persistent reward. A learned pet fetch delivers a useful recovery kit without moving the player. Outside-audience reactions explicitly belong to the real player's view, not character knowledge. Reward names/payloads, geography and lesson are provisional. No pet damage or broader campaign systems.

Personal single-player Mac prototype using installed Godot 4.6.2 Standard/GDScript/Compatibility and the existing illustrated cutouts. This project has its own Git repository at [dock108dev/space-rpg](https://github.com/dock108dev/space-rpg). Raw AVI captures, generated caches, editor backups and local practice saves stay local; compressed review videos, evidence records, editable artwork and the frozen candidate are versioned. Reviewed runtime manifest: `9d95ff12d4bbd8936183ad273d67c8e781dbe992eed4e03c510aa891ee6f0e2a`. The root owner launcher is separately hashed. [Candidate and evidence](evidence/S04/README.md).

Validate working source through `scripts/validate.sh S04`. Required checks passed: 138 S04 assertions, separate-process restart, 178 S03 assertions and 23 S02 regressions. Engineer reviewed the normal Mac launch and 37.07-second moving integrated tour. These results do not imply owner acceptance. Known limitations include one reused room/symbolic markers, rigid gait/hovering pet, creature cue uncertainty, narrow reward effects and development save ergonomics.

The source S04 scene remains runnable through [Launch S04.command](Launch%20S04.command); the owner launcher uses the frozen copy. Historical S03 remains available through [Launch S03.command](Launch%20S03.command) and `scripts/validate.sh S03`.

VIS-001 remains reproducible through [Launch VIS-001.command](Launch%20VIS-001.command), `scripts/launch_sample.sh` and `scripts/validate.sh S02`. Its historical [evidence](evidence/S02/README.md) and [owner feedback](docs/playtests/S02-owner-feedback.md) are preserved.

## Start here

1. Read the [product brief](docs/product-brief.md) and [current design](docs/current-design.md).
2. Check [open decisions](docs/open-decisions.md), then the [slice board](docs/slices/README.md).
3. Read the [S04 contract](docs/slices/S04-integrated-loop.md), [owner play card](docs/playtests/S05-owner-play-card.md) and [current handoff](docs/next-task.md); stop before operating owner play.
4. Record evidence and update this hub, the slice board, and the [Desktop tracker](../space_opera_rpg_next_steps.md) when state changes.

Read the [technical recommendation](docs/technical-approach.md) and [S01 evidence](evidence/S01/README.md) for the selected workflow, official sources, actual Mac inspection and untested risks. S01 is historical; current runtime results and feedback are in S02 evidence.

## Documents

- [Owner answers 1–48](docs/owner-answers.md): exact answers and explicitly superseded interpretations.
- [Current design](docs/current-design.md): active choices; this supersedes earlier interview summaries.
- [World rules](docs/world-rules.md): canon and information boundaries.
- [Visual direction](docs/art-direction.md): selected C reference and what must be demonstrated.
- [First experiment](docs/first-experiment.md): bounded scope and exclusions.
- [Open decisions](docs/open-decisions.md): dependencies, provisional choices, and deferred questions.
- [Slice board](docs/slices/README.md): tasks, sequencing, and completion gates.
- [Validation plan](docs/validation.md): technical, visual, owner-play, and later-player evidence.
- [Asset register](docs/asset-register.md): provenance and production recipe records.
- [Evidence index](evidence/README.md): runtime evidence and owner feedback.

The Desktop tracker retains the large research and question library. Do not treat its conditional features as committed scope. Current design lives here; exact owner answers are evidence, not another independently maintained design specification. Document completion, technical completion, visual acceptance, and enjoyable play are separate states.
