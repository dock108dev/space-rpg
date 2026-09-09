# S04 — Package, shelter, pet learning and reward

Status: **S04 TECHNICALLY COMPLETE — READY FOR S05 OWNER PLAY.** September 9, 2026. S04 was missing at entry and was implemented under the owner’s bounded authorization. S03 owner assessment remains deferred.

## Purpose

Join the encounter into EXP-001 with a useful pet and persistent visible result.

## Tasks

- [x] S04-T01: Connect package retrieval and shelter endpoint without a countdown; keep exact story geography provisional.
- [x] S04-T02: Implement three distinguishable reward choices for security, equipment or opportunity; persist a single applied choice.
- [x] S04-T03: Propose and implement one small pet learned behavior, with an observable before/after difference; no damage model.
- [x] S04-T04: Demonstrate direct movement plus one assigned routine action; pet must not block traversal.
- [x] S04-T05: Add outside-audience reactions only; distinguish real-player UI from character knowledge.
- [x] S04-T06: Check fresh start, objective completion, resume, reward idempotency and learned behavior persistence across supported saves.

## Completion gate

EXP-001 can be completed from fresh state and resumed with a visible reward and useful pet behavior. Scope and unknowns remain explicit.

## Scope boundary

No full economy, training tree, additional recruitment, property privacy, jobs, freedom/replay system or actual deadline.

## Evidence and handoff

[S04 evidence](../../evidence/S04/README.md) records the exact candidate, required checks, retained failed attempts, visual/runtime review and separate owner/production status. S05 preparation is complete; owner session has not started.

## Reconciled starting position — September 9

| Requirement | Source/runtime at entry | Evidence / remaining work |
|---|---|---|
| T01 package → encounter → shelter | Incomplete: tactical scene stops at victory; no package/shelter state or scene | Entry manifest matches S03; implement spatial safe phases around existing encounter |
| T02 three rewards, one persistent | Incomplete: no reward controls/state | Add mutually exclusive persisted outcomes and duplicate checks |
| T03 useful learned behavior | Incomplete: pet only follows; no learning/save fields | Teach fetch at package; later retrieve a recovery cache with visible travel and result |
| T04 movement + assigned routine | Partial: direct movement and collision-free follower exist; no assigned routine in encounter | Add cancelable safe-area walk assignment; validate traversal |
| T05 outside reactions | Incomplete: no audience UI | Bounded real-player-only panel; no character knowledge coupling |
| T06 integrated persistence | Unverified: S03 save policy exists but cannot encode integrated state | Separate S04 save schema/directory; restart, reward, learning, pause and retry checks |

No newer S04 source/evidence or handoff was found. Git root is Desktop and this project is untracked there; no staging or repository creation. Existing assets, S02/S03 samples, evidence and saves remain preserved. Baseline revalidation is being retained under S03. Remaining work is only T01–T06 plus S05 candidate preparation. All geography, learning method, item names and payload numbers are disposable prototype decisions, not canon. No art generation, pet damage or broader systems.

## Delivered contract and final requirement mapping

All values and names below are provisional engineering choices. A separate `integrated_loop.tscn` extends the preserved tactical scene. Its single shared change is an overridable post-action completion hook; the full S03 regression gate passes.

| Requirement | Implemented source / actual result | Evidence |
|---|---|---|
| T01 | `integrated_loop.gd`: safe package marker at (1,3), explicit assessment entry after collection, inherited fight, safe walk to shelter at (11,1), explicit shelter interaction. No deadline. | Actual fresh journeys with every power; visible tour 01–06 |
| T02 | `choose_reward`: exactly one enum; security two recovery kits, equipment a visible field lamp, opportunity cache-route dots. Atomic save failure rolls back choice/payload. | All choices and repeated/cross-choice rejection; failure/retry test; reward stills |
| T03 | Package collection teaches fetch, immediate HUD difference. `fetch_cache`: outbound/return physical follower to cache (9,5); one recovery kit delivered without human movement. | Before/after rejection/result, frozen pet pause, persisted lesson/cache; visible 03,08,09 |
| T04 | Safe direct cardinal steps without AP, assigned package/shelter BFS walk; manual keys/Stop cancel after committed step. Pet collision layer zero. | Actual assigned traversal, pause/cancel, direct input, inherited navigation regressions |
| T05 | Four bounded presentation reactions in explicitly outside-audience real-player UI. No audience field in character state or AI. | Source dataflow and runtime panel assertion; visible captures |
| T06 | Independent `integrated_save.gd` schema and directory; autosave after choice, learning, encounter start/end, shelter, reward, fetch and kit use. | 138 S04 checks, separate process restart, 178 S03 + 23 S02 regressions |

## S04 save and routine policy

Root S04 source launcher defaults to `dev-state/S04-practice`. Frozen owner launcher uses the separate `dev-state/S05-20260909-01`. Existing S03 and historical saves remain untouched. S04 save payload adds `loop_version=1`, journey, package, learning, cache, kit count and reward to the validated S03 combat state. No implicit migration from S03.

Manual saves at idle safe/player decision boundaries, including partly spent encounter AP. Reject saves during animation, enemy/retry phase, pause, assigned walking and pet fetching. Finish/stop an assignment first. Latest is the greatest valid immutable sequence; failed/interrupted snapshots remain preserved and are visibly skipped. Fresh practice returns to demonstrations without deleting saves; Load latest resumes explicitly. Ordinary defeat uses the same latest loader. No offline progression.

If an interrupted `.writing` lock blocks saving, close all windows using that save directory, remove only the empty lock directory, then retry; preserve every snapshot and temporary file. This inherited development recovery policy is not a polished slot system.

## Final boundaries

Candidate and full manifest are in [S04 evidence](../../evidence/S04/README.md). Engineering PASS; engineer visual/runtime review complete with stated limitations; art repeatability inherited from S02 with effort limitation; owner assessment remains unrun. S05-T01 preparation only is complete. Stop before owner play; do not start further engineering without new owner steering.
