# S03 — Tactical encounter evidence

**TECHNICALLY COMPLETE at the bounded S03 gate. Engineer motion assessment complete with limitations. Owner tactical play assessment deferred at the owner’s request. S04 WAITING.** No full-game acceptance or release verdict.

## Launch and rules

Double-click [Launch S03.command](../../Launch%20S03.command), or run `scripts/launch_encounter.sh` from any directory. Try all three power demonstrations, then explicitly choose one. Select an action and click its floor/creature target; tap WASD/arrows to step, Enter ends the turn, right-click cancels and Escape pauses/resumes. Focus loss pauses. Use the green control from a cardinally adjacent floor cell. Save/Load latest are in the window. Returning to demonstrations preserves saves.

Provisional engineering rules: 4 AP per player turn; move/shield/dash/control cost 1, bolt/blast cost 2. Bolt deals 2 at range 4; blast deals 3 at range 3. Dash crosses exactly two clear straight cells; shield absorbs 2 then expires after the next enemy turn. Player/creature start at 6 health. The one-use control deals 2. Creature approaches up to two cells, then prepares and later lunges for 3 at its fixed adjacent target cell. Numeric tuning and cue comprehension are not owner-confirmed. [Full contract](../../docs/slices/S03-tactical-encounter.md).

Autosave: after selection/start and success. Manual save: any idle player decision boundary, including partially spent AP, shield and creature preparation. No save during action animation, enemy turn, defeat or pause. Defeat loads actual latest valid manual/auto snapshot. Development saves live in `dev-state/S03/`; append-only JSON, atomic temporary-file rename and writer lock. Malformed/unsupported/interrupted snapshots are preserved and visibly skipped. See the contract’s interrupted-lock recovery notes. Tests and captures use disposable state.

## Exact candidate

Runtime manifest digest: **`581d066406d115200c200e5311c04eab72549b0c5d8cb2a2cf0a21a984cd5026`**.

- [Per-file manifest](run-20260908T013851Z/runtime.sha256) and [source archive](run-20260908T013851Z/runtime-source.tar.gz).
- The [visible capture manifest](capture-20260908T013852Z/runtime.sha256) is byte-identical to the technical-run manifest. Both runs use fresh copies; PNGs, import settings, UID sidecars, project settings, scenes, tests and launch/validation tools are included. Generated caches/development saves are excluded.
- [Identity record](identity.json). Installed Godot `4.6.2.stable.official.71f334935`, Compatibility/OpenGL on Apple M3 Pro. Parent Git root is Desktop; project remains untracked. No nested repository, staging, commit or push.
- Entry [verification](entry.txt): every S02 review-v3 entry and its supplied manifest digest matched. At completion the sole changed previously recorded runtime file is `scripts/validate.sh`, extended to dispatch S03. S02 controllers, scene, tests, assets and original launch path remain unchanged. New source files and import-created UID sidecars are additions. All historical S02 evidence is preserved; old manifest is historical, not a claim that the changed wrapper still matches.

## Actual checks

[Final run](run-20260908T013851Z/results.json): fresh import PASS; S03 actual-scene suite PASS; S02 regression PASS. **178 S03 assertions** (including repeated bounded-wait assertions) and **23 S02 assertions**. [S03 checks](run-20260908T013851Z/checks.json), [behavior log](run-20260908T013851Z/s03-behavior.log), [S02 checks](run-20260908T013851Z/s02-checks.json).

Scenarios verified: demonstrations do not select/change encounter state; each power is used in a full actual start-to-success run; AP cost/exhaustion/explicit end turn; invalid range, sight, occupancy and boundaries; safe cancellation; echoed and rapid repeated input; turn ownership; blocked enemy BFS and recovery; fixed-cell strike misses after movement; shield absorption/expiration; dash path collision; one-use spatial interaction; success/autosave resume; partly spent manual resume including shield/preparation; actual manual-save and start-autosave defeat retry; cold scene load; empty, malformed, unsupported and interrupted-save fallback; invalid numeric/position/preparation state; writer exclusion; pause/focus-loss/retry timers; reset without snapshot deletion; pet following and cabinet avoidance. S02 checks cover unchanged doorway/navigation, follower, collision, pause/reset and interaction behavior.

Tests call the real scene’s action/input/save/physics functions, not a duplicated combat model. Complete victories use legal start-state actions; focused invalid-state/blocked-path cases use explicit fixtures. The suite is technical evidence, not proof that the fight is enjoyable or that owner input/cue comprehension is established.

## Engineer visual record

[Final motion tour](capture-20260908T013852Z/encounter.mp4) • [preparation](capture-20260908T013852Z/preparation.png) • [strike sequence](capture-20260908T013852Z/strike-sequence.png) • [defeat](capture-20260908T013852Z/defeat.png) • [actual save restored](capture-20260908T013852Z/retry-loaded.png) • [success](capture-20260908T013852Z/success.png).

The visible Compatibility tour demonstrates all previews, movement/following, held preparation, shield/strike, manual save, defeat, automatic restoration of manual save 2 with 5 health / 2 AP / creature 4 health / turn 4, then victory. Final MP4 is **1598 frames, 30 FPS, 53.266667 seconds, 2560×1440**, verified by [media metadata](capture-20260908T013852Z/media.json). Engine capture window reports 1280×720 pixels on a Retina 2× screen; gameplay-canvas stills are 1280×720. Final normal launcher uses inherited 2560×1440 physical pixels / 1280×720 macOS points. OS display settings unchanged. [Capture result/log](capture-20260908T013852Z/result.json).

Engineer inspected actual windows, full-canvas stills and consecutive strike frames extracted from the movie (25–27 seconds, 4 FPS). Creature visibly holds its crouched/backward offset then travels toward the struck cell; shield ring disappears after resolution. Resizing cabinets to their blocked floor footprint repaired the observed creature occlusion. Whole-image creature direction and overlapping adjacent silhouettes remain limited; no owner cue interpretation is inferred.

## Retained failures and repairs

- [First runtime](first-runtime.log): GDScript could not infer terminal type; explicit Node2D type repaired it before early play launch.
- [First behavioral run](run-20260908T013100Z/s03-behavior.log): malformed JSON produced engine parser errors despite safe fallback, and pet-follow assertion failed. Switched to parser error-return handling without suppressing engine errors. [Second run](run-20260908T013144Z/s03-behavior.log) isolated pet starting drift after the dash demonstration; selection now explicitly settles pet beside player. Subsequent full runs passed.
- [First capture](captures-v1/result.json): 120-second timeout, partial movie retained. Screenshots exposed oversized cabinet occlusion; local prop scaling repaired it. [Intermediate complete tour](capture-20260908T013621Z/result.json) predates final save-writer/evidence tooling and is not the final candidate proof.
- Final source-bound tests and capture both pass. Failed runs were not overwritten or relabeled as current passes.

## Owner and effort

[Exact owner record](../../docs/playtests/S03-owner-feedback.md): early playable goal offered; owner requested continuing routine work and writing down minor issues for later. No observed/reported tactical choices, enjoyment, pacing or cue-understanding verdict. Owner assessment deferred; no further basic question blocks engineering completion.

Prospective entry timestamp is in entry.txt; each validation/capture result records its measured tool wall time. These are not active authoring time or owner hands-on time. Both remain unavailable. No new art generation, purchase, publication, external message or delegation occurred.

## Minor issues / next bounded action

- AP bookkeeping and repeated one-cell taps need later pacing review; held keys do not repeat movement.
- Returning to demos requires viewing all three again; no friendly range preview.
- Whole-image creature cue/directional clarity, adjacent silhouette overlap, rigid human gait/non-urgent collar and hovering pet remain prototype limitations.
- Window chrome may retain VIS-001’s debug title; the actual scene HUD identifies S03.
- Append-only development saves have no pruning/slots. An interrupted writer lock needs the documented empty-lock recovery after closing game windows.

**Next bounded action:** retain this candidate and minor-issue list for deferred S03 play/pacing review when requested. No remaining known failed technical gate. Stop before S04.
