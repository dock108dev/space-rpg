# S02 — VIS-001 evidence

S02 COMPLETE — bounded visual sample, with recorded limitations. S03 WAITING. T01 appearance and repaired motion received permission to continue. Full sample feedback: “hovering but fine for now”; clarified as the following pet. Larger creature: “it moves towards the box.” Owner feedback requirement closed at sample scope; no polished-game acceptance inferred.

## Run

Double-click [Launch VIS-001.command](../../Launch%20VIS-001.command), or run `scripts/launch_sample.sh` from any directory. WASD/arrows move, E interacts nearby, Space shows shield, R resets, Escape explicitly pauses. `scripts/validate.sh S02` creates a fresh disposable game copy and runs import plus actual behavior tests. `GODOT_BIN` is allowed but must report exactly `4.6.2.stable.official.71f334935`.

## Identity

[review-v3/runtime.sha256](review-v3/runtime.sha256) identifies the exact game/source/launch scripts reviewed live. Manifest digest: `1b36c1c150480fbb15f29af5532dcb8f64210ae5147f5adb6d9f9d38537ed432`. [identity.json](review-v3/identity.json) also records the launch-time production-provenance manifest. Later prose records do not change runtime identity. Generated `.godot` caches excluded; PNG import settings and GDScript UID sidecars included. Desktop parent commit is not sample identity.

Review-v1 and review-v2 source archives preserve the original duplicate-limb defect and focused repair. [Owner record](../../docs/playtests/S02-owner-feedback.md) distinguishes their feedback from the full scene.

## Separate results

| Dimension | Result | Evidence / limits |
|---|---|---|
| Technical behavior | PASS — 23 assertions | [checks.json](checks.json), [behavior log](behavior.log); actual scene/physics code, not a duplicate model |
| Setup | PASS | Exact installed version; disposable fresh import; external-cwd visible launch; override version mismatch exits 2, including binary path with spaces |
| Engineer visual readability | PASS at sample scope, with limitations | Actual Mac window and engine movie inspected; actor directions, prop shapes, interaction cue, held pose/action, shield and doorway route visible. Simple rigid gait and hovering impression remain limitations. |
| Prop recipe repeatability | VISUAL/PROCESS PASS; effort comparison incomplete | Two distinct cabinet silhouettes; A master reused for B; same cleanup/export/import conventions and retained KRA. Full active authoring time not separately measured. |
| Owner feedback | RECORDED — sample-scope continuation with limitations | T01 “fine continuing”; pet “hovering but fine for now”; larger creature “it moves towards the box.” No S03 advancement. |

The 23 assertions cover actual diagonal displacement, stopping/facing, boundary and cabinet collision, pet cornering and doorway reversal, no pet footprint/wall overlap or position warps, blocked-route recovery, range availability/inert out-of-range input, ten-second held preparation, pause of actors/demo/effects/interactions, duplicate action rejection, recovery to idle, 100 repeated effects/interactions without node growth, and full reset. First full run failed reset because the starting pet immediately began following; retained in [failed-reset](failed-reset/). Starting offset repaired; subsequent fresh run passes.

## Visible record

- [Full engine tour](captures/vis-001-tour.mp4): 977 frames / 30 FPS; 32.57 seconds, rendered in visible Compatibility mode. Automated route uses the same controllers and input handlers. Covers cabinet route, doorway entry/reversal, creature pose sequence, shield, pause, terminal and reset. This is engineering observation, not owner play.
- [Tour contact sheet](captures/tour-contact-sheet.png).
- [Focused human repair](captures/t01-repair.mp4): 312 frames / 30 FPS.
- Actual window: 2560×1440 physical pixels, Retina 2× = 1280×720 macOS points; 1280×720 game canvas. Smaller 1920×1080 physical / 960×540 points inspected: controls and silhouettes remain readable. OS display settings unchanged. [Environment](environment.txt), [smaller-window log](smaller-window.log).
- Focus-loss log confirms simulation continues. Explicit Escape pause is implemented; focus-loss semantics remain a later O05 decision.

## Art and effort

[Krita verification](krita-result.txt), [prop verification](krita-props.txt), [asset register](../../docs/asset-register.md), [recipe](../../source-assets/S02/recipe.md), [prompts](../../source-assets/S02/prompts.md), [stage effort](effort.csv), [effort summary](effort-summary.json).

Nine measured generation calls total 188.778 seconds of tool wait. Recorded generation plus timed Krita stages total 202.540 seconds; this is NOT total labor. Agent prompt/script/animation/integration authoring and owner hands-on duration were not separately timed and remain unavailable. No retrospective estimate or claimed productivity ratio. The original 12–23 hour proposal is not a deadline or measured result.

## Remaining limitations and next boundary

Following pet uses whole-image flip/bob; owner tolerates its hovering for now. Human collar is non-urgent. Creature feedback confirms movement toward the nearby control/box, not detailed comprehension of every preparation pose. Engineer observation supplies the separate held-pose check. End-to-end active production-effort comparison remains unavailable; no efficiency claim is made. These limits are retained in the sample completion record.

S02 is complete as this bounded visual sample. S03 remains WAITING for a separate continuation; no full combat, saves, progression, pet care/damage, audience feed or property mechanics were implemented. Next bounded action is a separately requested S03 planning/implementation continuation from its packet; do not start it automatically.
