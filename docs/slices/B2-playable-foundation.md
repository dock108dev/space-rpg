# B2 — Playable opening and two-place party foundation

Implemented September 23, 2026 (local date). **TECHNICALLY COMPLETE; OWNER REVIEW PENDING.** See [exact candidate, acceptance A–G and moving evidence](../../evidence/B2/README.md). [B2.5 command adventure](B2.5-command-adventure.md) is next, before B3; both are unstarted. The implementation instructions below retain B2's completed contract; current work is governed by [the handoff](../next-task.md).

UI-02 is a completed presentation-only follow-up on the working source. The original B2 candidate/evidence are preserved; [current UI verification](../ui-verification.md#ui-02--b2-presentation-cleanup) identifies the newer source. B2.5 remains unstarted.

Original contract prepared September 23, 2026. B1 planning is complete in the [chapter packet](../chapter-implementation-packet.md). This is the first full implementation handoff for the chapter. Preparation did not run gameplay or supply owner acceptance.

## Player outcome

From one clearly named local launcher, a player can inspect and choose a power, enter the threatened package area, survive the opening encounter, collect the package, learn the pet's fetch behavior, and physically enter a distinct temporary shelter. They choose one ordinary orientation reward and may recruit or decline a companion. They can return with the pet and any recruited companion to the cleared shopping area, use fetch once, return to shelter, save and quit, then continue the exact state in a new process.

This complete slice includes playable interactions, two locations, moving actors, party state, save/recovery, readable controls and an identified delivery. The shelter remains unowned and nonprivate. Full hub/expedition, home ownership, equipment/power improvements, pet injury care and dangerous recruit behavior remain later stages.

## Entry and preservation

1. Read `AGENTS.md`, the README, current design, world rules, open decisions, B1 packet, this contract, S02/S03 feedback and the Desktop tracker. Recheck HEAD/dirty state; the preparation baseline is `1eebd4c3daac9f808173765acf4bdd4278e86dff` plus the audit/planning documentation. Preserve all incoming work.
2. Mark only B2 IN PROGRESS in the Desktop tracker and slice board. Keep B1 planning completion, S05 NOT STARTED and B3–B10 not started distinct. Preparation for this handoff is not actual B2 execution.
3. Preserve `builds/S04-20260909-01`, `Launch Owner Play.command`, S02–S04 evidence, editable masters and every existing save namespace. Record entry hashes of the frozen candidate and launcher. Do not read or migrate owner practice saves to establish isolation.
4. Work in the current repository, using a new chapter scene/launcher and `dev-state/B2-practice-v1` for manual B2 development; automated checks override with a unique disposable directory. New schema defaults must never resolve to S03/S04/S05 paths. No automatic commit, push, publication, purchase or owner play.

## Complete implementation scope

| Workstream | Required ordinary behavior |
| --- | --- |
| Opening | Brief spatial context for takeover; understandable power previews and one choice; enter actual danger before collecting the package. Reuse the existing bounded assessment and three powers; no countdown, class lock or explicit enemy-intent labels. |
| Two places | Shopping concourse and a visually distinct furnished shelter interior with different geometry/composition. Reachable door interaction travels both ways with valid spawn, camera/depth and party placement. No text-only location switch or recolored copy counted as the second place. |
| Persistent journey | Encounter completion, package/learning, exclusive reward, cache, power, health and location survive re-entry/restart. All three reward choices retain their honest current payloads; no audience rewards. Return does not reset danger or duplicate gains. |
| Recruit | One distinguishable NPC in shelter; short join/decline interaction. Join gives an autonomous follower alongside the pet; wait/rejoin at shelter persists. Decline/wait leaves the journey completable and rejoining remains available. The player controls only the protagonist. B2 does not claim companion combat, injuries or the full B6 role. |
| Pet/party | Both followers traverse doorways without trapping the protagonist or clipping through blocking geometry. Distinct spacing, readable walk/turn/stop motion, correct location/target after travel. Pet fetch produces one actual outbound/return journey and one reward; reject duplicate or ineligible use. |
| Interaction and pause | Direct movement and cancelable assigned safe walking coexist. Dangerous actions require player control. Pause/focus loss freeze all actors/actions; explicit resume works. Invalid targets, blocked routes and busy actions produce useful feedback without spending resources. |
| Save/quit/continue | Stable-boundary autosaves and manual save, visible success/failure, ordinary quit/relaunch and Continue. Save and quit from a pause menu is allowed only if underlying state is stable; no forced action advancement. A failed write keeps the game open. New practice preserves earlier snapshots. |
| Presentation and launch | B2-specific window/title/launcher, concise controls and objective, legible 1280×720 layout and actual Retina review. New art is integrated into gameplay with editable masters retained. Show the slice endpoint honestly. |

Retain current HP/AP/power values as starting tuning defaults; adjust only for a demonstrated B2 problem and record the effect. The future chapter economy in B1 is not implemented here. Minimal name/appearance options may wait for B8; identify that limitation rather than implying character creation already works.

## Implementation ownership

Extend the existing Godot product. A chapter controller/state and location definitions are appropriate new owners; exact file names are the lead's choice. Reuse combat, rigs, effects, interaction rules and snapshot storage where suitable. Do not create per-location copies of the tactical controller or a second simulation for tests.

The old save validator hardcodes the old map and combat limits. Give chapter state a versioned validator with location-specific positions and consistent membership/journey fields; do not loosen old S04 validation to accept arbitrary new data. Save transitions and consequential choices as one coherent state. UI derives from that state. Keep inherited S03/S04 defaults working when shared seams change.

The B2 scene, `scripts/launch_b2.sh`, `Launch B2.command`, `scripts/validate_b2.py`, `scripts/validate.sh B2` and `evidence/B2/` now exist in working source. Their presence does not establish completed qualification; record final candidate-bound results. Separate modules for location state or party behavior are useful when they remove concrete coupling; avoid an unrelated controller rewrite.

## Acceptance and evidence

| Case | Required observation |
| --- | --- |
| A — Full journey | From fresh B2 state, each power can complete the real assessment/package/shelter route. At least one complete ordinary-control journey includes join, two-way travel, physical fetch, return, quit and Continue. No debug teleport/state injection supplies the passing journey. |
| B — Choices | Each reward applies once; join/decline/wait/rejoin stay consistent across travel/load. The no-recruit path works. Negative cases may use clearly labeled fixtures, never relabeled as ordinary progression. |
| C — Actual persistence | A separate process resumes location, chosen power, health/resources, resolved encounter, reward, cache/learning and party state exactly. Re-entering cleared locations does not repeat gains. |
| D — Recovery | Unwritable destination or interrupted/invalid snapshot leaves prior saves intact, produces truthful feedback and supports a valid retry/latest-save recovery. No exit after failed Save and quit. No writes outside the isolated test roots. |
| E — Movement/control | Both actors follow through doors/obstacles; blocked assigned walking stops; manual reclaim and pause/resume work during relevant movement/fetch/combat. No party duplication, disappearing follower or stuck transition. |
| F — Information and appearance | Shelter stays visibly temporary/nonprivate; audience has no character/AI/gameplay influence. Inspect actual moving protagonist/pet/recruit, creature cue and second room; no duplicate limbs, missing assets or unreadable controls in supported view. Record remaining nonblocking motion limits. |
| G — Preservation | Frozen S04 manifest and owner launcher unchanged, incoming work preserved, historical evidence retained, applicable inherited regressions pass or a concrete pre-existing failure is reported. |

Use the existing `scripts/validate.sh S04` for applicable shared-source regression; it already covers S03/S02 and process restart. Add `scripts/validate.sh B2` for the new scene/state and restart. Avoid rerunning overlapping suites separately after their relevant checks pass. Inspect runners before use; isolate synthetic saves and preserve the first failing attempt, then repair the bounded cause and rerun affected checks.

Normal Mac launch/input and a short normal-speed moving tour are required because location/party/art behavior changes. Headless tests cannot supply those observations. Captures must identify source, display size, synthetic setup and any automation/time scaling; owner feedback remains blank. Reconcile final manifests after the last source/art change, including UI changes made after tests. Do not declare a fresh complete test pass from a later screenshot alone.

## Team execution and final handoff

The lead owns the state contract and integration. Optional bounded parallel roles: gameplay/state; scene/art/interface; independent validation. Assign file ownership and agree transition/save fields before overlapping work. Contributors deliver into one B2 runtime and one evidence record. Routine decisions do not require repeated owner questions; a missing owner verdict cannot be invented by the team.

Deliver a named launchable B2 candidate, exact commit plus complete dirty-source/art manifest, relevant retained checks, moving review, known issues and a brief ordinary-use guide. Update the README, Desktop tracker, slice board and current handoff. Distinguish implemented/technically verified/visually reviewed/owner-unreviewed. End with [B2.5 modern text-adventure play](B2.5-command-adventure.md) as the next major scope: A1 command experience and A1a story/gameplay, before B3 world expansion. B2.5 is a separate implementation after this completed delivery; B2 completion does not mark the beta ready.
