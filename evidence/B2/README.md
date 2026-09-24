# B2-20260923-01 — playable opening and two-place party foundation

**TECHNICALLY COMPLETE; engineer visual/input review performed; OWNER REVIEW NOT RUN.** This closes B2 only. S05 remains unrun and the full beta is not ready. September 23 is the local delivery date; evidence directories use September 24 UTC timestamps.

Double-click [Launch B2.command](../../Launch%20B2.command). [Player guide](../../docs/B2-player-guide.md) · [runtime/state contract](../../docs/B2-runtime-contract.md) · [art production and editable masters](../../docs/B2-art-production.md) · [next handoff](../../docs/next-task.md).

The candidate reuses the existing combat, rigs, effects and immutable storage. Its chapter-v1 validator handles two locations and party consistency without changing historical validation. Ordinary play now completes power demonstrations/choice → actual assessment → package/fetch lesson → distinct furnished shelter → one reward and optional recruit → return and physical fetch → shelter → Save and quit → new-process Continue. Join, decline, wait and rejoin are persistent. Safe walking can be reclaimed; pause/focus freezes the simulation. Failed saves keep the session open and expose retry/recovery.

## Exact identity

The preparation/current HEAD is `1eebd4c3daac9f808173765acf4bdd4278e86dff`. B2 is an uncommitted source candidate; HEAD alone does not identify it. [candidate.json](candidate.json) records the complete source/art manifest and archive hashes, launcher hash, evidence hashes, Desktop tracker snapshot and current dirty status.

The final 194-file runtime manifest is **`19fc03bfa7e1871f3cf12294aa6a7f5ee9bea532b01e7773de02429841d5ad06`**, shared by the [B2 checks](run-20260924T014030Z/runtime.sha256), [moving tour](capture-20260924T014234Z/runtime.sha256) and [S04 regression](../S04/run-20260924T014326Z/runtime.sha256). A retained [runtime archive](run-20260924T014030Z/runtime-source.tar.gz) contains that source. [source-art.sha256](source-art.sha256) includes the complete working source, documentation and editable art after final documentation reconciliation; generated caches, saves, evidence and historical frozen builds are deliberately excluded and accounted for separately. No runtime/art/launcher change followed the final checks.

Installed Godot `4.6.2.stable.official.71f334935` is required. The launcher is deliberately silent (`Dummy` audio driver); B2 has no authored audio. Manual use defaults to `dev-state/B2-practice-v1`; all engineering checks/captures used distinct disposable synthetic directories. No owner save was read, migrated or used as evidence.

## Acceptance A–G

| Case | Actual evidence and result |
| --- | --- |
| A — complete journey | PASS: [457 actual-scene assertions](run-20260924T014030Z/b2-checks.json) include fresh real assessment/package/shelter journeys for blast, shield and dash. Passing journeys use ordinary actions/input without debug progression. The final tour completes join/travel/fetch/return/actual quit. [Native review](native-final/review.md) covers real Mac input and process restart, with the precise pre-repair/final-runtime boundary recorded. |
| B — choices | PASS: each reward once; duplicate reward/cache rejected; joined, declined and waiting branches; decline-to-join and wait/travel/rejoin. Security stores kits, equipment supplies the visible lamp, opportunity reveals the existing route. Payloads and numbers remain implementation defaults. |
| C — actual persistence | PASS: real Save-and-quit process exit followed by [nine restart checks](run-20260924T014030Z/b2-separate-process-continue.log) across three complete saved states. Exact-state comparisons preserve health/AP/resources/power, location, encounter/package/learning/cache/reward and party positions/status; return does not duplicate rewards. Native restart also produced an [exact gameplay comparison](native-final/restart-comparison.json). |
| D — recovery | PASS: malformed/partial/latest snapshots, invalid chapter/location/membership fields, unwritable file-ancestor destination, live/current/external/stale writer locks, failure feedback/no exit, recovery and retry. Earlier snapshot hashes remain intact. Negative fixtures are explicitly labeled and synthetic. [Runner results](run-20260924T014030Z/results.json) also verify no historical-namespace writes. |
| E — movement/control | PASS: blocked walking and fetch before/during travel, cancellation/retry, manual reclaim, freeze/resume during movement/fetch/combat, separate follow targets, valid party placement and both doorway directions. Geometry is sampled during actual paths. Normal Mac keys/mouse and focus pause were exercised; see native review. |
| F — information/appearance | Engineer review performed: actual 1280×720 logical Retina window, [88.6-second moving tour](capture-20260924T014234Z/b2-tour.mp4), 15 phase frames, [review record](moving-review.md), supplemental [creature cue/strike](creature-cue/cue.mp4). Two distinct rooms and all three moving party actors were inspected. Controls fit after the recorded overlap repair; no missing assets or duplicated limbs were observed. Motion/cue/style limitations below remain; owner quality acceptance is separate. |
| G — preservation | PASS: [504 entry files unchanged](preservation.json), including frozen S04, owner launcher, historical evidence and editable masters. Frozen runtime still has its 103 matching entries. [Final S04 route](../S04/run-20260924T014326Z/results.json) passes 138 S04, 178 S03 and 23 S02 assertions plus S04 process restart on the same runtime manifest. Incoming audit/planning and concurrent product-direction documentation are preserved. |

Reproduce the relevant checks with `scripts/validate.sh B2` and `scripts/validate.sh S04`. The former is now implemented. Headless fixed-fps checks run faster than wall time; they are behavioral evidence, not motion review. The movie uses simulation time scale 1 and 30 fps playback; capture throughput is independently reported.

## Retained failed attempts and bounded repairs

- `run-20260924T012639Z`: live external writer was incorrectly treated as stale because Godot's process helper was unsuitable for non-child Mac processes. B2 now checks PID presence and preserves live locks; historical storage/validation is unchanged.
- `run-20260924T012829Z`: recovery assertion assumed damage before a real strike; the journey now waits for the actual strike. File-ancestor write failure now has an explicit preflight with truthful feedback rather than an expected engine error. Earlier passing intermediate runs remain retained.
- `native-attempt-01`: inherited window title and CoreAudio device error. B2 sets its own title and explicitly uses silent audio. `native-attempt-02` detached launch supplied no gameplay evidence. `native-attempt-03` and `native-targeting` exposed the real event-position mouse bug; B2 now transforms the delivered mouse event instead of polling an unrelated system cursor.
- `run-20260924T013837Z`, `013921Z`, `013941Z`: new mouse regression harness used incorrect headless viewport coordinates. The harness projects scene positions through the viewport transform; final input checks pass.
- `capture-20260924T013124Z`: contextual reward/recruit row overlapped Pause. The row was moved and the complete final checks/tour were recaptured. The failed capture and review are retained.
- Art production retains its failed `draw_ellipse` helper-name collision attempt; the helper was renamed before integration and final import.

These attempts are not relabeled as final-candidate passes. [Native source reconciliation](native-final/source-reconciliation.json) identifies the only later native-manifest differences as test/runner changes; runtime, art and launcher match the final evidence.

## Limits and next stage

Human cutout gait remains stiff; the pet bobs/flips without articulated feet. The illustrated vector shelter/recruit are more graphic than the inherited raster actors. Party paths can briefly overlap visually when crossing; stable follow positions are distinct and do not trap the player. Creature posture changes and damage exist, but unassisted recognition of its cue remains an owner-review question. No polished-game or enjoyable-play verdict is inferred.

There is one generic protagonist, no character creation, no authored sound and an installed-engine dependency. There is no full expedition, owned/private home, upgrades, pet injury care or companion combat. Their B3–B10 ownership remains in the chapter packet. Shelter stays explicitly shared/unowned/nonprivate; audience text grants nothing and is never character knowledge.

The product documents received a new A1 command-adventure / A1a story-and-gameplay direction during delivery. It is preserved as **B2.5 next, not started**, before B3. [B3's concrete following scope](../../docs/next-task.md) is district hub and expedition-approach travel plus persistent optional-task outcomes, using the same chapter state/party/save authority. Neither later slice was implemented here. No commit, push, publication, purchase, owner review or beta acceptance occurred.
