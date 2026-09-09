# S02 — Navigable illustrated visual sample

Status: **COMPLETE — bounded VIS-001, technical checks PASS, visual/process observations and owner feedback recorded with limitations.** S03 remains WAITING.

Current evidence: [S02 results](../../evidence/S02/README.md), [owner feedback](../playtests/S02-owner-feedback.md). T01 repaired human received “fine continuing”; collar non-urgent. Full scene: “hovering but fine for now,” clarified as the following pet. Its simple whole-image movement is tolerated for this sample. Larger creature feedback: “it moves towards the box”; held-pose behavior separately observed by engineer. All sample choices remain hypotheses.

## Result and boundary

Build sample **VIS-001**: one small fixed-view illustrated shopping-area corner containing a short exterior path, one obstacle, a doorway and a shallow sheltered recess. Show a moving human, an autonomous alien placeholder pet, one creature preparation/action sequence, a protective-shield demonstration and one usable interaction. Match the illustrated qualities of reference C at actual gameplay scale. The place, species, costume and layout are disposable test assembly, not canon.

Use [technical approach](../technical-approach.md): installed Godot `4.6.2.stable.official.71f334935`, Standard/GDScript, Compatibility renderer; built-in image generation for master illustrations, proposed Krita 5.3.3 cleanup, transparent PNG parts and AnimationPlayer. Keep one slice active and update the Desktop tracker/local board before beginning.

No full combat/AP system, saves, death, character creation, selected-power persistence, pet training or damage, package/reward loop, audience feed, property/privacy system, added companions or campaign. No actual encounter deadline. Shield demonstration does not replace the later choice of force blast, shield or dash. Freedom, employment and replay identities remain later intentions.

## Exact sample contract — proposed test values

These dimensions and controls are engineering starting hypotheses, not accepted balance or final presentation requirements.

- One 1280 × 720 logical canvas in a resizable window; preserve aspect ratio. Start at a 1280 × 720 logical window on the built-in display. Record actual macOS scaling, window size and renderer in evidence. Recheck at a smaller window; do not change OS settings to make the sample pass.
- Fixed angled view with no rotation or zoom. Walkable ground is a 2D plane with explicit footprints; painted perspective supplies depth. Art and collision must agree. Do not introduce a 3D scene or imply a strict isometric grid.
- Human approximately 100 logical pixels tall initially; eight-way travel via WASD/arrows, normalized diagonals. Four visible facing groups: toward, away, left, right. Keep last facing while idle; diagonal travel selects the nearest group consistently. Show front/back art, not just one flipped view.
- Pet approximately half human height; follows autonomously at a short offset and stops near the human. It respects walls, does not block the player, never takes damage and is not directly controllable. Prove cornering and reversing through the doorway. Final species/behavior remains O07 for S04.
- One waist-high obstacle with routes on both sides. One doorway wide enough for the actor footprint and a separate foreground lintel/canopy. Show actor and pet in front of, behind and through it; collision follows posts/walls, not the whole decorative PNG rectangle.
- One orientation-terminal placeholder: nearby highlight plus `E` prompt, absent out of range. E produces a brief local response. This tests spatial interaction only; no feed, ownership, reward or story-state implication.
- Creature in a visible demonstration area. E at its nearby demo control advances idle → preparation held → action → recovery → idle. Preparation uses lowered stance/weight shift, then a short lunge in the same direction. Hold until input; no countdown or explicit enemy-intent label. No damage or AP spending. Input help may describe demo controls but must not explain what the creature intends.
- Space demonstrates a protective shield around the human, then it fades. Keep face, feet, doorway and interaction indicator readable. Repeated input must not accumulate orphan effects. R resets sample positions/demo state; Escape pauses and resumes, with no simulated progress while paused. Focus-loss behavior is still O05; record what happens rather than silently settling it.

## Original proposed layout — actual files indexed in S02 evidence

```text
space-opera-rpg/
  game/
    project.godot
    scenes/visual_sample.tscn
    scenes/actors/{human,pet,creature}.tscn
    scenes/props/{doorway,terminal,cabinet_a,cabinet_b}.tscn
    scenes/effects/shield.tscn
    scripts/{sample_controller,human_controller,pet_follow,creature_demo}.gd
    scripts/{interaction,occlusion,shield}.gd
    art/{environment,human,pet,creature,effects}/
    tests/run_s02.gd
  source-assets/S02/
    recipe.md
    prompts.md
    masters/{human,pet,creature,environment,cabinet_a,cabinet_b}.kra
    originals/                    # selected original generation outputs
    exports/manifest.json         # IDs, pivots, sizes, directions, hashes
  scripts/launch_sample.sh
  scripts/validate.sh
  docs/playtests/S02-owner-feedback.md
  evidence/S02/{README.md,environment.txt,checks.json,effort.csv,manifest.sha256}
  evidence/S02/captures/
```

Keep imported game assets separate from editable sources. Include PNG import settings and Godot resource UID sidecars in source identity; exclude generated `.godot/` caches. Do not create or stage a nested Git repository implicitly: this folder currently inherits Desktop Git. Use hashes until a deliberate project repository decision. No new framework, plugin, build service or asset store dependency.

## Setup and launch approach — executed; results in S02 evidence

1. Verify folder, instructions, slice state and exact Godot binary version again. Set S02 IN PROGRESS, leaving S03 WAITING. Preserve existing work and the reference PNG.
2. Reuse the existing engine. For the selected art recipe, install the official free Krita 5.3.3 macOS build in the S02 continuation, record download/version and verify opening/saving a disposable `.kra` plus RGBA PNG export. Recheck compatibility if the offered build differs. Do not purchase a store edition. No engine installation, paid generation API, template download or signing is needed for this local launch.
3. Create `game/project.godot` with its main scene, input map and `gl_compatibility` renderer. Set a distinct project name. Use local assets; no runtime generation or network dependency.
4. Implement `scripts/launch_sample.sh` so it resolves the project relative to itself, quotes paths, checks the expected Godot version and launches the main scene with the absolute binary. Allow an explicit `GODOT_BIN` override, but fail clearly on an unexpected version until the recorded baseline is deliberately revised.
5. Implement `scripts/validate.sh` as the single project-local validation entry point. `./scripts/validate.sh S02` runs import and bounded nonvisual checks, records actual exits and errors, and returns nonzero for failed checks. It must not label visual/owner checks passed. Include `--visual` for launching the manual scenario if useful, not for fabricating automatic visual results.

Commands the scripts will use after the project exists (supported switches checked in the installed binary's help; these commands have NOT been run against a project):

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --import
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/run_s02.gd
/Applications/Godot.app/Contents/MacOS/Godot --path game
```

Resolve `game` to an absolute path in scripts so launch works from another working directory. The test runner extends SceneTree, reports explicit assertions and exits on completion; wrapper timeout prevents hangs and preserves logs. An exported `.app` is not required by this gate. Test fresh import in a disposable copy without `.godot`, never by deleting retained owner state.

## Work order

- [x] **T01 — setup and first motion.** Create the minimal room floor and human rig. Before detailed scenery, import the real illustrated human and show idle, walk, stop, toward/away turns and mirrored side views. Check foot contact, joint gaps, outfit consistency and alpha edges at gameplay scale. Technical placeholders can establish controls, but do not satisfy this motion checkpoint.
- [x] **T02 — space and interaction.** Add obstacle, doorway pieces, collision, foot-origin Y sorting and terminal. Keep each actor rig sorted as one unit under a shared sortable root; do not Y-sort individual limbs. Keep a consistent Z band for things that need to sort together. Where the lintel hides the actor, test a local fade; ensure the effect does not imply x-ray knowledge of unrelated spaces.
- [x] **T03 — companion and demonstrations.** Add NavigationAgent2D-backed following over an explicitly authored navigation region; wait for map synchronization before querying routes. Use separate wall/actor collision masks. Add the held creature preparation/action sequence, shield and pause/reset. A stuck pet is a defect, not permission to warp it through a wall.
- [x] **T04 — repeatability.** Produce cabinet B from cabinet A's locked production recipe; give it a different height/door silhouette, not just a recolor or duplicated PNG. Integrate both with identical scale/pivot/import conventions and their own matching footprints. Record full effort for both.
- [x] **T05 — evidence and owner review.** Run relevant checks, inspect at actual scale, capture motion, record exact source/asset identity and ask for the owner's aesthetic/readability response separately. Revise failed dimensions before considering S03.

## Repeatable asset recipe

1. Read the actual C panel and freeze a short style sheet: angled camera, dark drawn contours, restrained textured shading, muted stone/olive palette and one light direction. Record the chosen palette, outline thickness at gameplay size and scale guide with the first master. Those settings are proposed sample values until reviewed.
2. Use the built-in imagegen workflow in S02, with the local reference marked as a style reference and the first retained master as the identity reference for later views. Generate one subject/element at a time. Ask for an isolated full subject, consistent camera/light, no cast shadow baked across detachable parts and actual transparent background. Save selected original outputs locally, exact prompts, returned model identity if exposed and generation date; otherwise mark model identity unavailable. Preserve the original comparison image unchanged.
3. For the human, obtain toward, away and side masters with matching costume/proportions and a neutral pose whose limbs can be separated. Mirror the side master only for this symmetric test costume, checking lighting. Do not claim independent generations are a coherent sprite sheet. If a view changes the character, edit/repair the master before animation.
4. In Krita, keep reference separate from export layers. Separate head, torso/pelvis, near/far arms and near/far legs; paint overlapping joint coverage and hidden body areas. Keep the shoe contact point and joint pivots recorded in a manifest. Use rigid transforms initially; no mesh deformation or external rig plugin. Make pet/creature parts from the same outline/palette recipe, without approving a permanent species.
5. Export individual RGBA PNG parts in sRGB, with consistent source scale and preserved transparent margins. Inspect over both light and dark backgrounds for fringes, missing pixels or a painted checkerboard. Verify dimensions and anchors before import. Keep `.kra` masters so cleanup is editable; no full background extraction deferred to runtime.
6. In Godot use lossless texture import, initially linear texture filtering and no mipmaps at fixed sample scale. Record actual settings. Set foot-origin actor roots and part offsets explicitly. Animate contact/passing poses, slight body motion and counter-swing in AnimationPlayer; tune walk timing against travel to avoid sliding. Layer swaps must match facing. Use an engine-drawn translucent shield with restrained outline/pulse; no extra generated VFX dependency.
7. Environment master separates floor, rear structure, prop silhouettes and doorway foreground; paint behind parts that can become hidden/revealed. Cabinet A is a waist-high freestanding storage cabinet. Freeze its palette, line width, angle, texture treatment, source-to-game scale, bottom pivot and import record. Cabinet B is a taller two-door cabinet built by editing the same layered master using those settings. Reuse materials and construction steps while changing silhouette. Both are test props, not approved shopping-area lore.
8. Record per asset: source/rights, prompt/reference hash, original, editable master, export hashes, displayed height, pivot, facing, import settings; active prompting, generation wait, cleanup, animation, integration, rework minutes; agent/operator versus owner hands-on time. Report missing/unobserved time honestly. Compare total active production time and repair causes for A/B. A fast generation followed by long repair is not a cheap asset.

Fallback trigger: if the early human still has unacceptable seams, sliding or stiffness after one focused repair pass, stop broader art production. Retain a clip and effort record, then test authored frame animation for that same human. If producing those poses requires external art help, prepare the bounded asset brief and ask about the actual quote/contact need before proceeding. Do not purchase or lower C's visual target silently.

## Separate evidence criteria

| Dimension | Required observation | Gate treatment |
|---|---|---|
| Technical | Exact-version import; fresh-copy import; launch from outside project directory; controls/diagonals/stop; wall collision; corner and doorway pet following in both directions; blocked route recovery; pause/reset; repeated interactions/effects leave no duplicates or growing node count | Record assertions for state/geometry and a manual visible route. No unexplained errors or blocked required action at completion. Missing coverage stays NOT RUN. |
| Visual readability | Human direction/contact stays readable; no joint gaps or identity changes; pet identifiable and not lost behind scenery; creature preparation distinguishable from idle/action without explanatory labels; shield preserves human/interaction visibility; doorway depth agrees with movement | Actual gameplay-scale stills plus short in-engine motion clip or live observation record. Headless checks cannot pass this dimension. Note defects and exact examples. |
| Production repeatability | Cabinet B is a distinct integrated silhouette made from A's recipe; matching outline, palette, perspective and scale; editable originals, exported assets and stage-by-stage effort for both | Report whether B required a new process. No arbitrary time ratio as a success rule. If bespoke rework dominates, revise recipe before content expansion. This proves a prop recipe only, not a second whole location or character. |
| Owner feedback | Exact reviewed artifact; neutral goal and actual owner words; continue/revise/stop verdict; interventions recorded | Separate from engineer visual assessment. Pending feedback remains pending; unacceptable or unreviewed aesthetics do not silently authorize S03. |

Nonvisual checks should assert real behavior: player displacement stops at collision, diagonal speed is normalized, pet can traverse the known route without exceeding obstacles, prepare state stays held without input, reset restores expected state, repeated effects retire and pause halts movement/demo progression. Do not test a second reimplementation of the same logic. Manual inspection covers interpolation, sort order, alpha and cue comprehension.

Suggested owner prompt, once the build is available: “Walk around this corner and through the doorway, then try what you find.” Observe first, then ask what the creature seemed to be doing and how the moving illustration felt. Do not explain the intended cue before asking. If a consequential creative choice remains, show the actual alternatives and use four useful suggestions plus add-your-own when appropriate; no renewed broad discovery interview.

## Effort checkpoints — estimates, not promises

| Checkpoint | Proposed active engineering/art effort | Evidence before continuing |
|---|---|---|
| Setup + human first motion | 4–8 hours | Version/launch record and actual turning/walking human; revise workflow here if necessary |
| Small scene + pet + demonstrations | 5–9 hours | Complete required motion route and readable doorway/effect/cue |
| Second element + validation + review packet | 3–6 hours | Repeatability comparison, checks and identified sample for owner |

Total proposed active effort: **12–23 hours**, excluding generation waits, owner scheduling and any fallback art commissioning. Confidence is low before the first human. This is not measured productivity or a delivery date. Reserve an estimated 30–60 minutes of owner review per checkpoint; do not assume the owner spends all 5–10 weekly hours drawing. Log actual owner effort separately and revise the forecast at each checkpoint. At an estimate overrun, record cause and remaining bounded work rather than silently expanding content or treating elapsed time as approval.

## Completion and handoff

Complete only with an identifiable locally runnable sample, reproducible setup, actual motion/readability evidence, second-element recipe and separate owner-feedback record. Open aesthetic rejection or unreviewed visuals prevent S03 expansion. Technical pass, engineer visual assessment, production repeatability and owner verdict remain separate fields.

Write `evidence/S02/README.md` with actual steps, machine/display, defects, pass/fail/not-run and source/asset hashes. Owner notes identify the same artifact and are never inferred from screenshots. Update README, board, decisions, Desktop tracker and next-task with the result. Stop at S02; S03 remains a separate continuation.

## Current implementation deviations and limits

The compact sample assembles nodes in GDScript rather than creating one `.tscn` per prop; `game/scenes/visual_sample.tscn` is the main scene. Navigation uses an explicitly authored convex-cell NavigationPolygon with shared vertices and footprint clearance; NavigationAgent2D queries wait for map synchronization. Same geometry list creates physical obstacles and navigation exclusions. No extra framework/plugin.

Retina requires a 2560×1440 physical window to show the proposed 1280×720 logical-point view. The smaller 960×540-point window was inspected without changing OS settings. Cabinet B opens A's KRA and retains its source layer hidden while adding the cleaned, reference-edited taller two-door design.

Pet uses a whole illustrated placeholder with flip/bob, not an articulated walk; owner tolerates its hovering for now. Human collar also non-urgent. Full end-to-end active authoring time was not instrumented; stage records mark missing durations unavailable. Generated model/seed/credits unavailable. No measured productivity claim.

Completion basis: local exact-version launch, fresh import and 23 technical checks, in-engine motion/readability record, second distinct cabinet using the retained recipe, and actual owner feedback. Pet hovering and collar remain tolerated sample limitations; missing authoring-time measurements remain explicit. Completion is not a claim of polished game acceptance and does not authorize S03.
