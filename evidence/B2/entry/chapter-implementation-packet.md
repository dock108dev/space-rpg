# B1 — Opening-chapter implementation packet

Prepared September 23, 2026. **Planning complete; gameplay implementation remains B2–B9. Owner beta acceptance pending.** The owner requested an up-to-date project and the first full slice as a prompt for their lead engineer and team. This packet prepares that handoff; no game, owner session or application validation was run while writing it.

The [Desktop tracker](../../space_opera_rpg_next_steps.md) owns stage status. [Current design](current-design.md), [owner answers](owner-answers.md) and [world rules](world-rules.md) own intent. Counts, working location labels, resource values and mechanics proposed below are implementation defaults, not new owner-approved canon or a delivery-time promise.

## 1. Verified starting point

- Source baseline: `main`, `1eebd4c3daac9f808173765acf4bdd4278e86dff`; live remote `main` matched on September 23. Incoming uncommitted changes are the audit corrections in `docs/ui-design.md` and `docs/ui-verification.md`; preserve them and this planning packet.
- Installed engine version query returns `4.6.2.stable.official.71f334935`. Continue the existing GDScript/Compatibility approach and illustrated cutout workflow. No engine migration or dependency installation is needed for planning.
- Frozen owner candidate: [S04-20260909-01](../evidence/S04/candidate.json), independent of later source. Its 103 manifest entries and separately hashed root owner launcher match. Historical 138 S04 / 178 S03 / 23 S02 assertions are retained results, not fresh tests of this packet or future B2.
- September 21 working-source validation predates a six-pixel header-backing adjustment (`94` to `100`) in `tactical_encounter.gd`. Reconcile this through the first relevant B2 validation; it is not an unexplained gameplay change or a reason to rebuild the frozen owner candidate.
- S05 owner play is NOT STARTED and S03 tactical assessment is deferred. Neither is a claimed pass or a prerequisite to preparing the new engineering slice. Incorporate any actual feedback that arrives; do not require another basic-mechanics interview.
- The old external tracker archive is missing. Repository owner answers, design, source, S02 feedback and S04 evidence are available and sufficient for this bounded handoff; do not reconstruct missing owner testimony.

## 2. Source inventory and design consequences

| Existing owner | Actual behavior | Consequence for the chapter |
| --- | --- | --- |
| [tactical_encounter.gd](../game/scripts/tactical_encounter.gd) | One 12×7 grid; hardcoded scene assembly, AP/health, combat, UI, pause, input and snapshots | Keep tested combat behavior; introduce location/encounter configuration only where the second location requires it. Do not copy the entire controller per location. |
| [integrated_loop.gd](../game/scripts/integrated_loop.gd) | Extends tactical scene; package, immediate fetch learning, assessment, shelter marker, reward and physical fetch | Reuse working interactions, but make shelter an actual place and package danger part of the opening. The old sample collects its package safely before explicit assessment. |
| [tactical_save.gd](../game/scripts/tactical_save.gd) and [integrated_save.gd](../game/scripts/integrated_save.gd) | Immutable sequenced snapshots, writer exclusion, latest-valid recovery; validation embeds the old grid/combat limits | New chapter schema and namespace must validate location-specific state. Reuse suitable storage mechanics without pretending the old validator supports new locations or companions. |
| [pet_follow.gd](../game/scripts/pet_follow.gd) | NavigationAgent follower, nonblocking collision layer, bob/flip motion; fetch controlled by integrated loop | Preserve physical following/fetch; add distinct party spacing and readable movement. No useful additional recruit exists yet. |
| [human_controller.gd](../game/scripts/human_controller.gd) and [asset register](asset-register.md) | Repaired illustrated human rig and retained masters; one pet, creature, floor, doorway and two cabinet variants | A second room and distinguishable recruit need actual integrated art. Existing prop repeatability does not prove a full second location or character. |
| [project.godot](../game/project.godot) and launch scripts | Default remains VIS-001 visual sample; source S04 is explicitly launched; frozen owner launcher is separate | Give B2 an explicitly named launcher/scene. Preserve old launchers and frozen paths; do not imply the project default already launches the chapter. |
| [validator](../scripts/validate.sh), [S04 runner](../scripts/validate_s04.py), [manifest helper](../scripts/s03_evidence.py) | Existing S02/S03/S04 commands import disposable copies, retain source/logs and use isolated test saves | Add the B2 route to this entry point, with applicable inherited regressions and process restart. Avoid a second competing validation system. |

## 3. Counted chapter content plan

Initial production target: **six connected places**, one protagonist, one pet, one recruit, one owned home, three optional tasks, and an expedition with two danger situations and a persistent return outcome. These are bounded planning defaults; revise counts if implementation evidence supports an equally complete chapter, recording the reason. No minimum playtime is invented.

| Working ID | Place and ordinary use | First delivery |
| --- | --- | --- |
| `shopping_concourse` | Familiar neighborhood shopping area disrupted by takeover; demonstrations, contested package pickup, initial danger and a usable shelter exit | B2 |
| `temporary_shelter` | Distinct interior; first reward, optional recruit introduction and safe return. Unowned and nonprivate. | B2 |
| `district_hub` | Connect optional work, equipment/power improvements, home access and expedition preparation | B3 structure; B4–B7 content |
| `owned_home` | Separately acquired property; interior/threshold privacy, furnishings, upgrade and return point | B5 |
| `expedition_approach` | Preparation becomes consequential; optional safer approach, first expedition danger and retreat | B3 connection; B7 content |
| `expedition_objective` | Second danger/objective, recover an ordinary assignment reward, choose return, persist chapter result | B7 |

Travel graph: concourse ↔ shelter ↔ hub; hub ↔ owned home; hub ↔ approach ↔ objective. Clear transitions use actual reachable entrances and landing positions. The chapter does not silently transport the protagonist off Earth or establish alien transportation lore.

The prototype's safe package-before-assessment order is not the chapter contract. B2 places the package in the threatened collection area: power selection → explicit entry into danger → clear the bounded assessment → collect the package/learn fetch → reach shelter. Narrative pressure has no actual countdown. More elaborate tactical approaches belong to later content; preserve the three distinct power options now.

| Content | Initial implementation target | Required meaning |
| --- | --- | --- |
| Powers | Existing blast/shield/dash choice; one earned improvement for each supported choice | Initial choice is not a permanent class claim. Improvement changes an observable effect/cost and persists. |
| Equipment | Three bounded equipment families, each with a base item and one improved tier | Acquisition, equip/unequip and improvement visibly affect preparation or play; no cosmetic-only progression claim. |
| Optional tasks | Recover supplies, restore a local access point, survey an expedition approach | Three independent saved outcomes with distinct benefits; skipping them leaves a viable main route. Names/story are provisional. |
| Home | One ownership award; three placeable furnishings; one functional room/storage improvement | Ownership/privacy, furnishing placement and improvement all work; shelter is never relabeled as owned. |
| Recruit | One optional joinable character, distinguishable from the player; autonomous role | B2 delivers join/decline/follow/wait only. B6 supplies useful dangerous-area behavior and recoverable setbacks. |
| Pet | Existing fetch plus one useful improvement; recoverable injury and care | No compulsory feeding/bonding meter or permanent pet death. Injury/care must be an actual understandable interaction. |
| Expedition | Two danger situations plus objective and return, with at least one preparation-dependent alternative | Complete ordinary route, retreat and failure; chapter result records actual gains, use and unresolved tasks. |
| Character setup | Player name and bounded appearance selection, shared opening background | Deliver by B8; no invented detailed biography. Existing generic actor is an explicit B2 limitation. |

Provisional economy for B4–B7 design: one material resource, 20 units obtainable on the required pre-expedition route plus 4 units from each of the three optional tasks. A representative gear improvement costs 4, chosen power improvement 4, home improvement 4, each of three furnishings 2, and one care treatment 1. The required-route example totals 19 of 20, leaving 1; optional tasks provide alternatives rather than repairing a mandatory funding deficit. Home ownership itself is earned through the main assignment. These are arithmetic-checked planning values, not tested balance or implementation in B2. Record supply timing and avoid counting the same reward twice when implementing. Basic shelter recovery must remain possible without purchasable consumables, so depleted supplies cannot strand the party.

## 4. State and interaction contracts

Use one chapter state authority for stable location ID, per-location completed encounters/interactions, protagonist/power, acquired items and upgrades, task outcomes, party membership, pet learning/condition, home ownership/furnishings and chapter outcome. Add only each slice's implemented fields. Do not maintain separate UI, combat and save copies that can disagree; runtime combat state must have an explicit mapping at a stable checkpoint.

- World transitions validate the destination, completed movement, valid spawn and party placement. Commit location and party together. Re-entering a cleared area cannot respawn rewards, repeat recruitment or reset the encounter.
- Saving is allowed at stable player/safe decision boundaries. Exclude active attacks, enemy resolution, transitions and unfinished assignments/fetch. A pause menu may expose Save and quit when the underlying state is stable; saving must not advance the simulation. Failed saving keeps the session open with a truthful retry/continue choice.
- Autosave after committed milestones and location transitions. Quit/relaunch reads the latest valid chapter snapshot and reports skipped damaged files. Retain original invalid/partial files. No implicit S03/S04/S05 migration or scanning of their saves.
- Ordinary defeat reloads the latest valid snapshot, including its actual resources/choices. Do not create free rewards, refill supplies or reset a chosen power independently of that snapshot. Protagonist permanent-death mode remains out of beta.
- B2 companions join after danger and travel through the cleared area only. B6 introduces injury and recovery: injured pet cannot perform its affected task until treated; downed recruit is recoverable; retreat returns the party together. No permanent pet/recruit loss or treatment dead end.
- Broadcast is presentation for the real player only. B2's concourse/shelter both remain nonprivate. In B5, suppress outside commentary within owned-home boundaries and restore it on exit; characters and AI never consume it. No audience item, money, stat, unlock or progression rewards in beta.
- Basic focus loss and explicit pause freeze combat, movement, following and assignment progress. Resume is explicit. No offline simulation, real-time deadline or autonomous dangerous action is introduced.

## 5. Ordered delivery map

| Stage | Complete deliverable | Boundary / evidence |
| --- | --- | --- |
| B1 | This source-grounded chapter/content/state packet and full B2 work order | Documentation verification only; does not implement gameplay |
| B2 | [Playable opening and two-place party foundation](slices/B2-playable-foundation.md): danger/package → actual shelter → optional join → party return/fetch → save/quit/resume | Ordinary playable source slice, integrated art and bounded technical/moving evidence; not an expedition or full companion system |
| B3 | Extend shared world state/travel to hub and chapter route, persistent optional-task framework | No fake completed locations or rewards; B2 bridge becomes the shared ordinary path |
| B4 | Equipment, power improvements, material accounting and preparation UI | Acquisition/effects/reload verified; independently reconcile quantities and cost timing |
| B5 | Earn home, cross privacy boundary, place/move furnishings and apply improvement | Ownership and furnishings survive leaving/restart; shelter remains nonprivate |
| B6 | Useful autonomous recruit and trained pet across danger, injuries/care/retreat and recovery | No permanent loss; decline remains viable; no party member silently disappears |
| B7 | Author full expedition, three optional tasks and chapter return/result | Complete main route plus alternate preparation/retreat/failure; meaningful saved result |
| B8 | Character setup, complete onboarding, controls, animation, balance and ordinary save experience | Resolve observed comprehension/quality problems across the full chapter; no test-count substitute |
| B9 | Standalone personal Mac package and exact candidate qualification | Independent launch without installed editor, isolated saves, complete journey/restart and known limits |
| B10 | Owner complete-chapter review and bounded repairs | Explicit resulting-candidate beta verdict; public distribution separate |

Each stage includes its own usable UI, assets, save meaning, error feedback and relevant checks. B3/B6 must extend B2 rather than replace it with unrelated demos. S05 remains a historical prepared prototype review; future owner observations are recorded separately on the build actually played.

## 6. Art, integration and review

Keep the selected illustrated style, existing editable masters and foot-based depth/occlusion. For B2, complete a distinct shelter kit (floor/back wall, foreground doorway, readable furnishing props) and a distinguishable recruit with idle/walk/turn poses. Reuse appropriate source masters deliberately; a colored duplicate or a still illustration is not moving-party evidence. Keep new masters and exports separate from the frozen asset set.

Use the shared glass UI for readable interface chrome, not to flatten spatial play into cards. Review walking, stopping, turning, doorway crowding, depth order, creature preparation and action feedback at gameplay scale. Record representative asset authoring/cleanup/integration time when measurable; do not infer active effort from generation waits or render duration. Existing nonurgent collar and pet-hover feedback remains historical, not permission to ignore new visible defects.

The lead may divide bounded work among gameplay/state, art/interface and validation contributors. One integrator owns shared state contracts and source; assign file ownership before parallel edits. Integration is one B2 slice and one usable candidate, with team reviews feeding the same evidence. No separate task creation, messages to teammates or runtime work occurred in preparing this packet.

## 7. Completion and limits of this packet

B1 is complete as planning when its source references, stage coverage, initial arithmetic, B2 work order and tracker/handoff links are checked. Those checks do not certify the design as fun, visually accepted or implemented. The next implementation is B2, not another open-ended discovery phase. Revisit only concrete contradictions or evidence-backed blockers; ordinary reversible design choices remain the lead's responsibility within confirmed scope.

Preparation verification completed September 23: 99 local link targets across 13 active documents resolve; table structure and whitespace checks pass; the 19-of-20 resource example reconciles. All 103 frozen S04 manifest entries, the manifest hash and owner launcher hash match. Installed engine version matches the pinned version. Only documentation changed; application tests, gameplay, owner saves, packaging and owner review were not run.
