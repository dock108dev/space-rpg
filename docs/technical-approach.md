# S01 technical approach

Decision recorded September 7, 2026 (America/New_York). **S01 decision complete; runtime and visual feasibility NOT TESTED.** This is engineering judgment for the next sample, not owner approval of a camera, animation style, character or species.

## Recommendation

Use the **installed Godot 4.6.2 Standard, GDScript, Compatibility renderer**, with a fixed angled 2D scene inspired by reference C. Produce illustrated source images with the available built-in image-generation tool, clean and separate them in **Krita 5.3.3 (proposed installation)**, then animate rigid illustrated parts with Godot's AnimationPlayer. Keep floor, rear walls, sortable props and doorway foreground separate. Save reusable masters and import transparent PNG parts; do not attempt to animate a flattened illustration of the whole scene.

This puts movement, collisions, depth order and animation in one editor, while avoiding the need to draw every walking frame. It does not eliminate art work: source selection, painting hidden joints, matching direction views, alpha cleanup and animation tuning are the largest risks. Generated images are candidate material, not automatically consistent or usable sprites. Test a turning human before completing the room. Godot's documented cutout approach and current AnimationPlayer/CanvasItem references support this construction; the tutorial itself carries an outdated-content notice, so use current class APIs rather than copying its old editor steps. [G2], [G3], [G4]

**Fallback:** keep Godot and the same scene contract, but replace visibly stiff or broken cutout character motion with cleaned, individually authored PNG animation frames. Krita exports image sequences and Godot AnimatedSprite2D plays them. Reuse the master palette, proportions and direction templates. If those frames require skills the solo workflow cannot supply, prepare a small illustrator/animator brief for one human walk/idle set before asking for a quote/contact/purchase authorization. No vendor, price or asset pack has been selected. Changing engines will not fix inconsistent drawings. [K3], [G10]

## Actual environment

| Finding | Evidence and consequence |
|---|---|
| Project | `/Users/michaelfuscoletti/Desktop/space-opera-rpg`; documentation and one reference PNG only at entry. No `project.godot`, game implementation or project-local `.git`. |
| Git boundary | `git rev-parse --show-toplevel` returns `/Users/michaelfuscoletti/Desktop`. This project is untracked there. Do not stage the Desktop, create a nested repository implicitly, or assign its commit to this document packet. Use file hashes. |
| Machine | MacBook Pro Mac15,6; Apple M3 Pro, 11 CPU / 14 GPU cores; 18 GB RAM; arm64. |
| OS/display | macOS 26.6.2, build 25G83; built-in 3024 × 1964 Retina display; Metal 4 reported. Logical scaling, brightness, frame rate and input ergonomics were not measured. |
| Space | Approximately 90 GiB available on the project volume when inspected; a snapshot, not a reserved allocation. |
| Godot | `/Applications/Godot.app/Contents/MacOS/Godot --version` reports `4.6.2.stable.official.71f334935`. PATH alias points there. `--help` confirms planned CLI switches. No game/editor window was launched. |
| Other tools | Python 3.14.5 and Git 2.49.0 verified by version commands. Node and ImageMagick resolve on PATH. Blender wrapper resolves to Homebrew `blender@lts/4.5.10`; that is a path observation, not a successful Blender runtime/version test. Unity Hub cask metadata exists; no Unity editor was verified. |
| Missing proposed tools | Krita and Defold were not found in `/Applications`, `~/Applications`, relevant Homebrew cask names or PATH checks. This is a bounded search, not an exhaustive disk inventory. |
| Compatibility judgment | Official Godot 4.6 requirements and macOS universal archive support this hardware/OS family. Actual renderer operation on this Mac remains an S02 check. Krita's download page lists 5.3.3 and macOS 10.15 minimum; launch on this Mac is untested. [G1], [G5], [K1] |

Pin the observed Godot build for S02; **4.6.2 is not asserted to be the latest release**. Avoid changing the shared installation. If a reproduced defect needs a newer version, record the defect and compare a separately installed official build in a later authorized continuation. Export templates are not needed for the proposed editor-binary launch; an exported Mac app and signing are separate work. [G6]

## Three candidate combinations

All cells below are engineering assessments based on the documented primitives, not benchmark results. Two combinations share an engine deliberately: the production method is the leading uncertainty.

| Criterion | A: Godot + generated/cleaned cutouts (selected) | B: Godot + authored PNG frames (fallback) | C: Defold + authored PNG frames |
|---|---|---|---|
| C-style spatial illustration | Layered PNGs with foot-based Y sorting; fixed view preserves illustrated perspective | Same layout and depth structure as A | PNG sprites/atlases fit; explicit depth ordering must be implemented |
| Human walking and turning | Reusable parts, but separate front/back views and joint repair; risk of a paper-puppet appearance | Better control of each silhouette; drawing/cleanup cost multiplies by views and actions | Same drawing cost as B; atlas/flipbook integration |
| Occlusion and interaction | CanvasItem ordering plus separate foreground and collision shapes; indicators independent of art | Same as A | Sprite depth, collision and interaction logic; ordering discipline still required |
| Autonomous pet | Script following with collision-aware route; animation independent of travel; no pet damage | Same logic; frames replace presentation | Lua following/path logic; not a turnkey pet system |
| Creature cue and power | Body pose held until player advances demo; property animation for shield and recoil | Authored preparation/action frames; shield still animated in engine | Flipbook/property animation and scripted demonstration states |
| Turn/AP design | Later pure GDScript state transitions, presentation observes results | Same as A | Pure Lua state transitions; no inherent combat disadvantage |
| Save/load | FileAccess + explicit JSON schema later; encode vectors, validate data and define save boundaries | Same as A | `sys.save`/`sys.load` table support; documented size/row limits; schema and retry still custom |
| Tests/local launch | Installed executable supports headless scripts/import and visible local project launch | Same as A | Editor build/run and Bob command-line builder; engine not installed, current Bob docs require OpenJDK 25 |
| Second matching element | Reuse layered master, line weight, palette, camera and import template; test a different silhouette | Same environment recipe; character production remains more expensive | Same environment recipe; atlas integration adds another setup step |
| Solo effort | Lowest proposed repeated drawing load; hidden cleanup and rigging cost must be measured | More predictable poses, highest ongoing frame-authoring burden | Credible engine, but new toolchain offers no demonstrated art-production saving |

Godot capability basis: [G2], [G3], [G4], [G5], [G6], [G7], [G8], [G10], [G11]. Defold basis: sprites and flipbooks [D3], save/load [D4], build tooling [D5], platform/download [D1]. Following, combat design and the relative effort judgments are our implementation hypotheses, not built-in game features.

Defold **1.13.0** is a verified official release used as the comparison baseline; it is not installed or claimed newest. Defold's current manuals are rolling and were not proven against that exact binary. This limits the alternative comparison but does not block selecting the version-verified Godot installation. [D2]

## Concrete architecture for the first experiment

S02 uses a fixed camera, eight-way keyboard travel and four displayed facing groups as reversible test choices. Distinct toward-camera and away-camera drawings are essential: rotating a single portrait cannot prove directional production. Left/right mirroring is allowed only on this deliberately symmetric placeholder, with lighting and limb order inspected. The owner has not accepted four-view limits for the finished game.

Use CharacterBody2D for the human, foot-origin actor roots sorted as units, static collision footprints, a small explicitly walkable navigation region and a pet follower. NavigationAgent2D is documented as experimental and requires navigation data and per-physics-frame updates; isolate it behind the follower script and test corners and doorway recovery. Pet and protagonist do not collide with each other, but both respect walls. No visible teleport through walls as a success shortcut. [G4], [G8]

Creature demonstration is `idle → prepare-and-hold → action → recover`, advanced deliberately by the player. The held pose communicates preparation without a timer or intent label. Choose **protective shield** as the representative S02 effect: it tests alpha, actor overlap and silhouette readability without building targeting or combat. It does not select the protagonist's eventual power. Force blast and short dash remain options in S03.

S03 should keep AP, turn ownership, chosen power and outcomes in explicit data, separate from visual animation completion. Use versioned save records with stable entity IDs, numeric position components and validated loads. Define manual/autosave ordering and interrupted-write recovery there. The documented save tutorial establishes I/O primitives, not correct latest-save retry or migration. S02 must not implement the combat or save systems merely to justify the engine. [G7]

## Asset production judgment

The actual bottom-left C panel has ink-like contours, muted stone/olive colors, restrained shading and a readable angled floor plane. Those are observed reference qualities, not a requirement to copy its scene, people or implied lore. C contains no proof of walking or hidden surfaces.

Use generation for a small set of master illustrations, then preserve and edit those masters. Do not independently generate a new character for every frame. The built-in generation tool is available in this session, but its underlying model/version and remaining account allowance were not exposed or tested. Local imagegen guidance selects the built-in path without an API key; do not introduce a paid API or claim a pinned model. The OpenAI image guide warns about recurring-character consistency; this is a documented risk, not proof that a particular output will fail. [A1]

The S02 recipe specifies separation, pivots, alpha checks, directional views and a second prop. Asset work must record active generation/prompting, wait time, cleanup, animation, import and rework separately. No inference of repeatability from two independently attractive pictures. The second element must reuse the first master and template without a new bespoke process.

## Installation, spending and terms

- **Engine:** no installation or upgrade needed for the selected baseline. Godot is MIT-licensed; preserve its notice and applicable bundled-component notices if later redistributing the engine. Engine terms do not grant rights to third-party art. [G9]
- **Cleanup editor:** proposed official Krita 5.3.3 macOS download, free direct download. No install performed. Krita permits commercial art creation; its GPL applies to the software, not a demand to GPL artwork. Preserve editable `.kra` files and PNG exports. [K1], [K2]
- **Generation:** use available built-in access in S02 and record usage actually incurred. No new subscription, credits or API spending authorized or assumed necessary. If access is exhausted, report the actual dependency; do not silently switch to a billed service.
- **Source rights:** the checked OpenAI individual Terms of Use (effective January 1, 2026) assign output rights as between the user and OpenAI to the extent law permits, require rights to inputs, and warn output may be similar to others'. This is not exclusivity or third-party-rights clearance. Verify the account's applicable terms at actual asset creation; business/API terms may differ. Record source, date, reference, prompt, original and edits per asset. [A2]
- **Fallback cash need:** a coherent commissioned human set only if measured solo cleanup/animation fails. Obtain an actual bounded quote and rights to edit/use source files before any purchase. Cost is unknown; no invented ceiling or implied commissioning authorization.
- **Defold alternative:** free use for games under the Defold License, with required notice and restrictions on commercializing the engine itself. No Defold, Bob or JDK installation proposed unless an actual Godot blocker warrants revisiting the engine. [D1], [D6]

No asset pack, paid animation package, graphics tablet, external service integration, engine plugin or 3D pipeline is required by this decision. A drawing tablet may help an artist; it is not an evidenced need for this sample.

## Remaining risks and decisions

| Risk / assumption | Next evidence and response |
|---|---|
| Cutouts look stiff or separate at joints | Early human turn/walk clip at gameplay scale; revise one representative rig, then use B if the method remains unacceptable |
| Generated back view changes identity | Compare proportions/clothing across front/back; repair masters before rig replication |
| First and second props do not match | Side-by-side in-engine placement; compare outline, perspective, scale, palette and elapsed cleanup; stop content expansion if recipe changes fundamentally |
| Four facing groups feel too coarse | Owner sees actual turns; adjust directional coverage only with evidence, keeping movement spatial |
| Follow or occlusion fails despite supported APIs | Reproduce doorway/corner case; repair navigation/depth before adding a room |
| Mac renderer/import behavior differs from documentation | Visible S02 launch; log exact errors and renderer, do not call a headless run visual proof |
| Solo art time dominates available effort | Separate agent/engineering time from owner hands-on hours; reassess at the first-motion checkpoint; consider bounded art assistance only with an actual need |

No owner answer is required to finish S01. Camera, sample placeholder and shield are reversible engineering proposals to show in motion, not new canon. Owner aesthetic feedback belongs to S02. Pet injury remains deferred and excluded; temporary shelter implies neither ownership nor privacy. Outside-only feed access, ordinary latest-save retry, turn-based danger, power choice, dark comedy and the shopping-area opening remain unchanged. Freedom, organizational employment, replay identities and safer later participation remain in long-term planning without implementation.

Official source register and inspection record: [S01 evidence](../evidence/S01/README.md). Exact implementation packet: [S02](slices/S02-visual-sample.md).

[G1]: https://godotengine.org/download/archive/4.6.2-stable/
[G2]: https://docs.godotengine.org/en/4.6/tutorials/animation/cutout_animation.html
[G3]: https://docs.godotengine.org/en/4.6/classes/class_animationplayer.html
[G4]: https://docs.godotengine.org/en/4.6/classes/class_canvasitem.html#class-canvasitem-property-y-sort-enabled
[G5]: https://docs.godotengine.org/en/4.6/about/system_requirements.html
[G6]: https://docs.godotengine.org/en/4.6/tutorials/editor/command_line_tutorial.html
[G7]: https://docs.godotengine.org/en/4.6/tutorials/io/saving_games.html
[G8]: https://docs.godotengine.org/en/4.6/classes/class_navigationagent2d.html
[G9]: https://godotengine.org/license/
[G10]: https://docs.godotengine.org/en/4.6/classes/class_animatedsprite2d.html
[G11]: https://docs.godotengine.org/en/4.6/tutorials/assets_pipeline/importing_images.html
[K1]: https://krita.org/en/download/
[K2]: https://krita.org/en/about/license/
[K3]: https://docs.krita.org/en/reference_manual/render_animation.html
[K4]: https://docs.krita.org/en/reference_manual/layers_and_masks.html
[D1]: https://defold.com/download/
[D2]: https://defold.com/2026/06/22/Defold-1-13-0/
[D3]: https://defold.com/manuals/sprite/
[D4]: https://defold.com/ref/sys/
[D5]: https://defold.com/manuals/bob/
[D6]: https://defold.com/license/
[A1]: https://developers.openai.com/api/docs/guides/image-generation
[A2]: https://openai.com/policies/row-terms-of-use/
