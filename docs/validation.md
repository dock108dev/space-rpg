# Validation and evidence

S02 has a runnable sample and 23 passing technical assertions. Actual-window and engine-movie evidence are separate from owner feedback. See evidence/S02/README.md. Documentation checks are not game tests.

## Slice evidence

Record slice, date, exact source/build identity, command or reproducible steps, actual environment, pass/fail/not-run, artifact paths, defects, and next action. Once Git exists record commit plus dirty state; before then identify the actual files/artifact with hashes. A later candidate cannot inherit earlier acceptance automatically.

## Relevant functional checks

- Navigation: blocked routes, doorways, selection, pet following without obstruction.
- Combat: costs match display; insufficient AP/invalid targets do not spend resources; canceled/repeated input does not duplicate actions; enemy turns terminate; visible cues are readable.
- Powers: demonstrate and choose one; blast/shield/dash produce distinct bounded effects.
- State: fresh start, defined save boundary, load/resume, failed encounter reload, reward applied once, pet learning survives reload; document unsupported mid-turn save behavior.
- Routine/pause: assigned activity can be observed; manual control resumes predictably; no progression during explicit pause; chosen focus-loss behavior verified.
- Information: audience reaction cannot feed enemy/character knowledge; no intent-label overlay; shelter does not silently switch privacy.
- Packaging: local Mac launch from documented setup; report machine/display conditions and measured issues, not invented performance targets.

## Visual evidence

Inspect at actual gameplay scale. Human/pet movement, creature cue, power effect, occlusion and interaction readability. Record first/second matching-asset production and integration effort. Owner visual verdict is distinct from technical function and repeatability.

## Owner session

Provide the build and a short neutral goal, observe without coaching, record interventions. Ask what they understood, remembered, disliked, and wanted to do next. Record owner words and continue/revise/stop verdict; do not assume silence is approval. No actual camera/microphone recording required.

## Later outside testing

After a working and owner-reviewed loop, define a specific research question and intended testers. Contact/distribution is a separate action. Beta or release readiness requires later complete-playthrough evidence; it is not implied by this experiment.

## Current validation entry points

S01 document-only check: `python3 evidence/S01/check_documents.py` from the project root; results and file hashes live in [S01 evidence](../evidence/S01/README.md). This does not test the game.

S02 entry point: `scripts/validate.sh S02`. It verifies the exact binary, imports a disposable copy excluding `.godot`, then runs the actual-scene tests from an external working directory with bounded timeouts and preserved logs. A zero exit covers technical checks only; it does not establish visual or owner acceptance. `scripts/launch_sample.sh` and `Launch VIS-001.command` run the local sample. See [S02 evidence](../evidence/S02/README.md).

## S03 entry points and limits

`scripts/validate.sh S03` pins Godot 4.6.2, imports a disposable runtime, runs the actual tactical scene and S02 regression suite, and saves each run to a new evidence/S03/run-* directory. Runtime manifests and source archives include PNG import settings, GDScript UID sidecars, project settings, scenes, tests and launch/validation scripts. Generated caches and owner development saves are excluded. The S02 regression output lives in the S03 run and does not overwrite historical S02 results.

`python3 scripts/capture_s03.py` makes a fresh copy with disposable saves and records a visible Compatibility-renderer tour plus gameplay-scale stills. It records an independent manifest/archive and fails visibly on timeout or engine errors. This is an automated engineer tour, not an owner playtest. Consult actual engine logs and media metadata for frame count/dimensions; rendering wall time is not play duration or active authoring effort.

Owner requested continued building and later minor-issue review. Keep technical results, engineer observations and deferred owner-play assessment separate. S03 does not inherit S02 visual acceptance.

## S04 integrated validation and S05 preparation

`scripts/validate.sh S04` pins the same engine, archives/hashes a disposable fresh copy, imports it, runs actual integrated journeys and focused error/pause/persistence checks, starts a separate process to resume saved state, then runs S03/S02 regressions. Results and validation saves live in a unique `evidence/S04/run-*` directory. Test timeouts/errors fail the gate; historical failures remain retained.

`python3 scripts/capture_s04.py` records a fresh visible integrated tour using disposable state, actual scene operations and the existing illustrated actors. The visible tour disables automatic focus pause only for deterministic engineering capture; normal launch retains focus pause. Inspect native launcher input and movie/stills separately. Capture is engineering evidence, never owner play.

The tested runtime is frozen at `builds/S04-20260909-01`, identified by its own `runtime.sha256` and `evidence/S04/candidate.json`. Root `Launch Owner Play.command` is separately hashed and selects this copy with fresh independent practice state. Runtime caches were imported on this Mac and the launcher verified. To restore the archived source, extract it to the candidate folder and import with `/Applications/Godot.app/Contents/MacOS/Godot --headless --path builds/S04-20260909-01/game --import` before launch; compare each source byte against `runtime.sha256`. Generated import caches/UID files do not overwrite recorded source. Validation of the frozen copy can be run with `builds/S04-20260909-01/scripts/validate.sh S04`; it writes its own new evidence beneath that copy.

[S04 evidence](../evidence/S04/README.md) keeps engineering, visual/runtime, historical art repeatability and unrun owner-play status separate. S05 preparation does not complete S05's owner session, revision or verdict tasks.
