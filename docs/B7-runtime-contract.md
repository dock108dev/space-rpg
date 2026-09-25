# B7 — Relay receipt: content and state contract

Defined before implementation, September 24. Production names and tuning are engineering choices, not owner canon or accepted balance. A1 commands and A1a story/gameplay remain primary.

## Content map

| Beat | Play, information and consequence |
|---|---|
| Motivation | The hub board requests the district relay's physical routing core. A working receipt gives the shelter a verifiable district address; the protagonist gains a completed assignment and eight material. The board calls this voluntary infrastructure participation. The player may prepare or postpone freely. |
| Preparation | Finish the opening and claim the kit. No optional task, home purchase, recruit, training or upgrade is required. Inspect barrier/assignment gives danger, escape and reward terms. Supply bundle remains an explicit four-material exchange; access remains a hub shortcut; survey reveals the drainage bypass. |
| First danger | Beyond the barrier, a relay-yard warden holds the west court. Twelve health, ordinary four-AP combat, range/line of sight and shared B4 effects. Healthy joined traveler supplies the B6 one-shot support; healthy trained pet physically fetches cover once. Injuries/downing persist. Clearing this warden opens the inner court permanently and gives no currency. |
| Second danger | A live induction crossing separates the inner court from the routing core. A clear central lane is short but each move/dash across it triggers two pressure, reduced by passive weave and/or prepared guard/shield. Crossing exposes healthy companions to recoverable injury/downing. It is a traversal decision, not another health bar. The player can brace, dash, or take a longer dry maintenance route. Survey completion unlocks a dry drainage bypass immediately; without survey, reach and operate the west isolation wheel to open that same long route. No payment, consumable or hidden mandatory preparation. |
| Objective | Reach the core after clearing the warden and crossing the induction lane or dry passage. Recover the routing core explicitly. Removal shuts the crossing down permanently. No automatic reward. |
| Return | Walk back or explicitly retreat with all joined members; waiting traveler remains at shelter. At the hub board, file relay report. Transfer the core, receive eight carried material exactly once, and freeze the chapter result: routes, tasks and retrieval methods, party condition, support, injuries, retreats, earned reward. The address is recorded; freedom and a wider campaign are not delivered. |
| Afterward | Existing world, tasks, home, care and B6 breach stay usable. Cleared yard and removed core remain cleared. The report does not replay on re-entry or Continue. The result records conditions at filing, while later treatment changes current condition only. |

## Safe boundaries, state and recovery

Separate `B7-practice-v1`, `B7_SAVE_DIR`, `expedition_version: 1`; no migration or owner-save inspection. All prior fields remain authoritative. One `expedition` dictionary contains entered flag, warden health/status/AP/guard/round/cover, crossing route/wheel/crossed state, objective flag, reported flag, support/retreat/exposure counters, and immutable result. No second task ledger. Chapter completion requires a recovered objective and explicit hub report. Reward is exactly `8 * reported`; no material for entry, combat, crossing, retrieval, retreat or audience activity.

Stable player decisions autosave atomically, including motion destination before visual playback. Turn/cover and rescue animations commit as one outcome or roll back all fields/positions on failure. Defeat never overwrites the latest living save. Continue restores full positions, conditions, resources and progress, clears queues and never replays history. Immutable invalid snapshots remain retained.

An unfinished warden retains health and turn progress across retreat/re-entry; no respawn farming. Completed warden, wheel, route history, objective and report persist. Retreat before/after objective returns the entire joined party to the approach landing with unchanged injuries; explicitly requested evacuation can bypass blocked floors. No silent healing. Rest is free for the protagonist; care is two carried material per patient or two attended six-second free rounds. Stored material always requires withdrawal.

Valid combinations: entered requires completed opening/kit; active yard only in objective location; warden cleared iff health zero after entry; crossing/objective requires cleared warden; drainage route requires completed survey; maintenance route requires wheel; objective requires crossing; reported requires objective and complete immutable outcome; no audience data. Conditions/counters use B6 authority and validators. Location-specific grid/party checks precede inherited validation projections.

## Accounting

Carried + stored = 20 kit + 4 explicitly exchanged bundle + 10 settlement + 8 filed relay report − 4 per equipment/power improvement − 2 per furnishing − 4 storage − 2 per paid care. Core is a single assignment item, held between retrieval and reporting; no consumables added. Unclaimed eight material is never current balance. Assistance and resting preserve the zero-funds recovery route.

## Acceptance cases

Fresh ordinary command/choice journey: opening, joined traveler, real pet supply retrieval, explicit exchange/access/survey, equipment and power improvement, furnished home/storage, training, yard with support and recoverable setbacks, retreat/care/retry, surveyed dry approach, core, return report, home, Save and quit and separate-process exact Continue.

Additional complete routes: blast/shield/dash; optional tasks skipped and recruit declined; waiting/rejoin; live lane and maintenance route. Verify actual shared effects, target/AP restrictions, partial progress, all-member rescue, failure-write rollback, ordinary defeat/reload, injured pet restrictions, exhausted funds assisted care, exactly-once report, task resume, immutable outcome, post-completion world and privacy, malformed-state recovery, command questions/ambiguity/stale/duplicate/focus/Stop/pause. Separate parser corpus, original-input accounting and native Mac review. Normal-speed retained movie and source/art/launcher manifest bind delivery; technical/visual observations and owner acceptance remain distinct.

## Delivered field and compatibility details

The implemented dictionary is `entered`, `warden` (0–12), `cleared`, `points` (0–4), `guard` (0–6), `round`, `cover`, `wheel`, `route` (empty/live/drainage/maintenance), `crossed`, `objective`, `reported`, `assists`, `retreats`, `exposures`, `result`. Flags are booleans; counters are bounded nonnegative integers. `result` is empty until filing, then contains objective identity, reward 8, route, task snapshot, supply/cache retrieval methods, pet/recruit conditions, membership, support and retreat counts. Subsequent local tasks/care can change current state without rewriting that historical result.

Location validation checks the relay grid, cleared gate, north route state and party pixels before projecting coordinates solely for inherited validators. Resource hooks retain the inherited exact conservation equality and add only the reported eight-material source; B6's care validator permits condition/treatment counters arising from the entered expedition even if the separate breach remains idle. No projection is saved back to gameplay. Earlier namespaces reject B7 location/reward semantics; B7 rejects snapshots without expedition_version 1. No migration.

Final engineering checks: 360 game/check assertions, 14 parser/ambiguity cases, 12 separate-process checkpoints and 420 independently reconciled snapshots. [Exact retained evidence](../evidence/B7/README.md) supplies the candidate identity. These numbers do not substitute for owner play or accepted balance.
