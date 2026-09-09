# S04 integrated loop — engineering evidence

September 9, 2026. **S04 TECHNICALLY COMPLETE — READY FOR S05 OWNER PLAY.** S05 preparation only is complete. Owner session NOT STARTED; S03 tactical assessment remains deferred. No owner acceptance or release status is implied.

## Entry reconciliation

Every entry in the final S03 runtime manifest matched current source: [entry identity](entry-identity.json). Actual Git root is `/Users/michaelfuscoletti/Desktop`; this project is untracked there. Read all requested design/slice/validation records and inspected source, scripts, evidence and handoff. No newer S04 implementation existed. [Baseline revalidation](../S03/run-20260909T212258Z/results.json) passed the unchanged S03 and S02 scenes before implementation. The [S04 packet](../../docs/slices/S04-integrated-loop.md) records each starting gap and bounded remainder. Tracker and slice state were updated before coding. No existing saves, assets or evidence were removed.

## Exact reviewed candidate

Candidate **S04-20260909-01** is frozen in `builds/S04-20260909-01/`. [Identity JSON](candidate.json), [per-file runtime manifest](run-20260909T213134Z/runtime.sha256), [source archive](run-20260909T213134Z/runtime-source.tar.gz).

Runtime manifest SHA-256: `9d95ff12d4bbd8936183ad273d67c8e781dbe992eed4e03c510aa891ee6f0e2a`. Technical and visible-tour manifests are byte-identical. The frozen copy matches every file in that manifest, including scripts, assets, import settings and available UID sidecars. Import caches are generated, not source identity. The root owner launcher was added during preparation and is separately hashed in candidate.json; it selects the frozen copy and separate practice save directory. Do not assign a parent Desktop commit to this candidate. No staging/commit/push occurred.

[Owner launcher](../../Launch%20Owner%20Play.command) • [Owner play card](../../docs/playtests/S05-owner-play-card.md).

## Required checks actually run

[Final technical results](run-20260909T213134Z/results.json): fresh import PASS; **138 S04 assertions**, **178 S03 assertions** (includes repeated bounded waits), **23 S02 regression assertions**, all with zero failures. Separate operating-system process restart PASS. Tests exercise the actual scene methods, save files and follower physics; they do not reproduce the game in a separate model.

- Fresh integrated journeys with blast, shield and dash: power demonstration/selection, direct safe movement, package acquisition/learning, actual legal AP fight, shelter assignment/arrival and one reward per journey. Each chosen power is used. No teleport or damage fixture is used for these complete journeys.
- Every reward option persisted; repeated same/different reward rejected with unchanged snapshot. Fetch round trip returns a kit without moving the human, duplicate cache rejected, learning/cache/reward/inventory survive save/load. Recovery kit effect and refusal at full health checked. Focused healing/retry/error tests use explicit fixtures, distinguished in source from whole journeys.
- Pause freezes assigned walking and pet fetch. Paused mutations, in-flight save/load/reset, canceled assignment and manual resumption, application focus-loss notification, actual latest integrated partly spent save after defeat, malformed schema fallback and failed reward-write rollback checked. S03 regressions cover AP, targeting, shield, dash, turn ownership, held creature preparation, failed encounter retry, writer exclusion and invalid saves. S02/S03 checks cover follower traversal/collision/doorway behavior; the S04 assigned shelter route and pet round trip run through actual navigation. Pet has no blocking collision layer.
- A separate fresh Godot process reads the previous process's saved complete state and checks every nested value, learned behavior, cache, reward and duplicate prevention: [restart log](run-20260909T213134Z/s04-full-restart.log). [Retained validation saves](run-20260909T213134Z/validation-saves/) include the test data; no owner saves were used.
- Normal root S04 launcher exercised through native Mac controls: demos, choice, assigned walk and package lesson. Frozen owner launcher separately imported/launched, with the power effect exercised through native input. [Normal window evidence](normal-launch-01/) and [owner-launcher evidence](owner-launcher-check/). Native game windows visibly paused after losing application focus during launch/window discovery; explicit resume/input worked. Later attempted Finder focus changes through automation did not visibly establish a new focus transition; those screenshots are retained as inconclusive, not additional pause passes. The runtime notification freeze checks remain explicit technical evidence.

## Visual/runtime observations

[37.066667-second movie](capture-20260909T213323Z/encounter.mp4), 1112 frames at 30 FPS, 2560×1440 recording; actual visible window 1280×720 on a 3024×1964 Retina display at 2×, Compatibility renderer on Apple M3 Pro. [Metadata](capture-20260909T213323Z/media.json), [tour result](capture-20260909T213323Z/result.json), [sequence overview](capture-20260909T213323Z/sequence-overview.png).

Engineer inspected the native normal game window, input/animation, gameplay-scale stills, and chronological frames spanning the moving tour. The same illustrated actors navigate the floor/cabinet layout, the creature fight resolves, shelter is spatially reached, all three reward labels fit, the opportunity route appears, and the pet travels out/returns with the recovery-kit counter changing 0→1 while the human remains at shelter. The resumed result retains those changes. Text remains readable at inspected scale. No owner aesthetic/playability verdict was supplied.

Representative frames: [before learning](capture-20260909T213323Z/01-before-learning.png), [moving assignment](capture-20260909T213323Z/02-assigned-movement.png), [package lesson](capture-20260909T213323Z/03-package-learning.png), [fight completed](capture-20260909T213323Z/04-encounter-complete.png), [shelter travel](capture-20260909T213323Z/05-shelter-travel.png), [reward choices](capture-20260909T213323Z/06-reward-choices.png), [opportunity route](capture-20260909T213323Z/07-opportunity-route.png), [pet returning](capture-20260909T213323Z/08-pet-fetching.png), [kit delivered](capture-20260909T213323Z/09-pet-delivered.png), [resume](capture-20260909T213323Z/10-resumed-result.png).

## Preserved failed attempts

- First integrated run `run-20260909T212840Z`: 138 behavior checks passed; process-restart equality check failed despite correct loaded values. Second run `run-20260909T212929Z` confirmed string serialization also differed (`3` versus JSON-decoded `3.0`). Both results, logs, manifests and test saves are retained.
- [Focused comparison](restart-comparison-03.log) exposed identical values with numeric representation differences. The restart test now compares nested dictionaries/arrays recursively and numeric values semantically. It does not remove or weaken checks of actual fields. Final fresh-copy run and separate-process restart pass.
- Early normal-window `focus-loss-paused.png` and `focus-loss-paused-02.png` file names describe the intended check, not an observed pass: neither screenshot establishes the requested new focus transition. The initial paused normal/frozen windows and technical pause checks are recorded separately above.

## Separate verdicts

| Evidence dimension | Actual status |
|---|---|
| Engineering | S04 required gate PASS on identified candidate |
| Visual/runtime | Engineer review complete with bounded limitations; normal launch and moving integrated tour inspected |
| Repeatability | S02 cabinet A→B recipe/retained editable masters preserved; same runtime assets reused unchanged. Historical visual/process pass, full active effort comparison incomplete. No new art production or new repeatability claim. [S02 record](../S02/README.md) |
| Owner play | S05 preparation complete; session and feedback NOT STARTED. S03 tactical assessment deferred. No verdict assigned |
| Publication/release | Not performed or implied |

## Known limitations

- One reused illustrated room, symbolic package/cache/doorway markers, fixed camera, rigid cutout gait and hovering pet. The shelter marker is an endpoint, not a furnished room or owned/private property.
- One short assessment; provisional AP, damage, reward names/payloads and pet lesson. Required power demos and repeated one-cell taps remain. No range preview; creature pose/direction and adjacent silhouettes still need owner comprehension assessment.
- Security grants two consumable recovery kits (each restores up to 2 health, never spent at full health); equipment equips a visible field lamp; opportunity draws a route to the existing marked cache. There is no new area, economy or later campaign benefit. Reward appeal/balance is unassessed. The route disappears once the cache is collected; the chosen opportunity remains recorded.
- Fetch learning is immediate at package collection, communicated by the before/after HUD; no bespoke lesson animation. The useful fetch is an actual outbound/return trip after combat, delivering one persistent recovery kit while the human stays in place.
- Append-only development saves, no slots/pruning/migration, no mid-action saves. Window chrome retains the historical VIS-001 debug name; the in-game HUD identifies EXP-001. Godot 4.6.2 must remain installed. This is a local source-backed candidate, not an exported/signed app.

No pet damage, full economy, training tree, recruitment, property/privacy mechanics, jobs, freedom/replay system, campaign expansion or new lore commitments. No art generation, delegation, purchases, external messages or publication. Active authoring/owner hands-on effort was not measured; recorded tool wall time is not an effort estimate.

**Stop boundary:** leave the fresh candidate ready. Do not operate the owner's session, infer feedback, or begin follow-on development. Next owner action is the neutral opening on the play card.

## Final handoff verification

[Handoff check](handoff-check.json): frozen source hashes and separate root-launcher hash match, current documentation links resolve, and the owner launcher runs from an external working directory without engine errors. [Fresh owner window](owner-launcher-check/ready-fresh-window.png) is open at untouched power demonstrations, paused. Escape resumes. No input was sent to this owner practice session and it has zero snapshots. Engineering smoke input used a separate disposable save directory.
