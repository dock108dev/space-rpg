# Untitled Space Opera RPG — Path to Personal Beta

Updated: 2026-09-23. **B1 CHAPTER PACKET COMPLETE; B2 TECHNICALLY COMPLETE; B2.5 COMMAND ADVENTURE NEXT; NOT BETA READY.** B2 engineering delivery is complete; owner review is pending. Owner acceptance and beta readiness remain unestablished.

[Chapter implementation packet](space-opera-rpg/docs/chapter-implementation-packet.md) · [Full B2 work order](space-opera-rpg/docs/slices/B2-playable-foundation.md) · [Lead/team handoff](space-opera-rpg/docs/next-task.md).

B2 now delivers the playable opening across a shopping area and a distinct temporary shelter, an optional recruit alongside the pet, return/fetch, integrated art/controls and save/quit/Continue. It is one complete engineering slice. S05 remains a separate prepared prototype review; its missing verdict is not a blocker to this handoff and is not inferred as acceptance.

## Product priorities — A1 / A1a

**A1 — Modern text-adventure command experience. A1a — Story and gameplay.** This is the key feature and primary way to play: type naturally, give precise movement such as “move 5 up and 8 right,” choose contextual options or prompts, and see actual characters act. Scene narration, meaningful choices, discovery, multiple approaches and persistent consequences ship alongside it. Visuals and technology support these priorities.

The next major work after B2 is [B2.5 — Modern text-adventure play](space-opera-rpg/docs/slices/B2.5-command-adventure.md), before B3 expansion. AI or a small local model may assist complicated requests, context or pattern recognition; no backend is selected or installed by this update. B2 continues within its bounded foundation scope; later expansion waits for the command/story slice.

## Current verification — September 23, 2026

- Checkout was clean at `1eebd4c3daac9f808173765acf4bdd4278e86dff`; live remote `main` matches. The exact-commit hosted [Push on main](https://github.com/dock108dev/space-rpg/actions/runs/35626346394) check passed. This repository has no checked-in application CI workflow; that hosted result is not a Godot gameplay regression run.
- All 103 frozen S04 runtime manifest entries, the manifest hash and the separate owner launcher hash still match. The retained S04 technical results pass; `candidate.json` and the S05 slice still record owner play NOT STARTED. No owner save or live session was inspected.
- The September 21 working-source UI validation passed its recorded stages, but current `game/scripts/tactical_encounter.gd` differs from that run's 105-file manifest. Its documented later presentation adjustment is separate from those test results; current-source qualification must account for that difference before replacing the frozen candidate. No new application test pass is claimed by this audit.
- The source audit established B1 planning as the next step; this task has now completed its packet and prepared B2. S05 remains the separately prepared prototype review. The missing `next_steps_history/space_opera_rpg-20260921-before-beta-plan.md` cannot supply its claimed research archive. [Owner answers](space-opera-rpg/docs/owner-answers.md), [world rules](space-opera-rpg/docs/world-rules.md) and [open decisions](space-opera-rpg/docs/open-decisions.md) remain available in the repository. Shared-gallery paths now point to `ui-templates`.

## B1 handoff preparation — September 23

The completed packet maps inspected runtime/save/art ownership to six proposed connected places, three optional tasks, bounded equipment/power/home/party content, recovery rules and an ordered chapter delivery. Counts and resource values are production defaults, not new owner-approved canon. Initial resource arithmetic is explicit; actual balance remains untested. It also preserves name/appearance creation for B8 and distinguishes the first expedition from the B2 opening slice.

The B2 contract defined the ordinary journey and has now been implemented. The source baseline is `1eebd4c…` plus preserved incoming audit/planning documents and uncommitted B2 source/assets. Exact identity and new engineering evidence are in [B2 delivery](space-opera-rpg/evidence/B2/README.md). B3–B10 remain unstarted; no prior technical or owner evidence is promoted.

UI-01 remains a retained September 21 source presentation delivery with the qualification limit recorded in [UI verification](space-opera-rpg/docs/ui-verification.md). Its frozen S04 review candidate is preserved.

## Confirmed beta promise

Play a complete opening chapter: survive the takeover, establish a foothold, prepare and finish a first substantial expedition beyond temporary shelter. Several connected locations and optional tasks, equipment/power acquisition and improvement, a first owned private home, and a recruitable autonomous companion alongside the trainable alien pet are required. The chapter must finish with a persistent outcome and a clear sense of progress; it does not need to deliver ultimate freedom or the entire campaign.

Personal single-player Mac first. Preserve one directly controlled protagonist, turn-based danger, physical movement plus assigned routine tasks, illustrated spatial play and outside-audience-only broadcasts. Ordinary death reloads the latest valid save; permanent-death mode remains separately deferred. The owner has not specified a playtime or location count; do not invent those as approved constraints.

## Owner decisions — September 21

| Decision | Answer / beta consequence |
| --- | --- |
| Opening chapter through first expedition beyond shelter | YES — required endpoint |
| Several connected locations and optional tasks | YES — required world/content breadth |
| Acquire and improve equipment and powers | YES — required progression, not only initial power selection |
| First owned private home | YES — required ownership and privacy, distinct from temporary shelter |
| Recruit another companion alongside the pet | YES — required autonomous companion, not direct squad control |
| Tangible audience rewards during beta | NO — reactions only; no audience-driven items, money, bonuses or progression |

These decisions settle beta inclusion, not acceptance of any existing prototype. Earlier world rules and the 48-answer record remain the source of existing intent. There is no need to repeat the interview.

### Home and harm decisions — confirmed

- **Home furnishing and upgrades: required.** Ownership/privacy alone is insufficient; the player must be able to furnish and improve the home during the opening chapter.
- **Pet injuries require care.** Injury is recoverable and must lead to an understandable treatment/recovery interaction; no permanent pet death. Exact injury effects, supplies, costs and recovery timing are design parameters, not newly requested owner decisions.
- **No permanent recruit death in beta.** Dangerous outcomes must preserve a recoverable route for the recruited companion; this does not settle permanent-loss rules for a later campaign.

No further owner scope questions are required now. Numeric balance, content counts and concrete implementation details can be proposed and tested within these boundaries.

## B2 delivery — September 23, 2026 (local date)

Launch [Launch B2.command](space-opera-rpg/Launch%20B2.command). [Play guide](space-opera-rpg/docs/B2-player-guide.md) · [B2 identity and evidence](space-opera-rpg/evidence/B2/README.md) · [B2.5 and following B3 scope](space-opera-rpg/docs/next-task.md).

- Complete assessment/package/learning → distinct furnished shelter → exclusive reward and optional recruit → two-way party travel and physical fetch → save/quit/Continue.
- Independent chapter-v1 save validation, B2-only namespace, immutable snapshots, failure feedback/retry and interrupted-writer preservation. Historical saves and the frozen S04 owner candidate remain intact.
- Final actual-scene validation: 457 assertions, real Save-and-quit process, nine restart checks across three complete saved states, and historical-namespace write isolation. Final S04 route also passed 138 S04, 178 S03, 23 S02 checks plus S04 restart.
- Engineer operated native Mac mouse/keyboard through the journey and a new-process Continue. Final moving evidence is an 88.6-second, 30 fps synthetic tour at normal simulation/playback speed. Exact manifests and failed/repaired attempts are retained; owner review was not operated.
- Known limits: installed Godot dependency, intentionally silent launcher, generic protagonist, stiff human/pet motion, more graphic vector shelter/recruit, no companion combat/care/upgrades/home/expedition in B2. Those remain mapped to B3–B10.

## Implemented

- B2 supplies two distinct places, an optional autonomous recruit alongside the pet, ordinary input and party/reward/event persistence. See the delivery above for current evidence; following bullets preserve prototype history.

- S04 integrates power choice/package/learning, the existing tactical encounter, shelter and one of three persistent rewards.
- Pet fetch, cancelable safe assigned walking, outside-only audience presentation and save/restart behavior exist.
- Retained engineering evidence: 138 S04, 178 S03 and 23 S02 assertions plus a short integrated moving tour.
- Candidate `S04-20260909-01` exists as a frozen local build. Its 103 manifest entries and owner launcher matched on September 23; current source baseline is the later `1eebd4c`, separate from that frozen candidate.
- S05 owner session remains NOT STARTED; S03 tactical assessment is deferred. No complete-game or owner quality acceptance is claimed.

## To implement and establish before beta

| Required capability | Existing foundation | Remaining work / acceptance condition |
| --- | --- | --- |
| A1 command-adventure play | B2 movement/action/state owners delivered; no completed conversational adventure | B2.5: natural commands, exact steps, named interactions, questions/corrections, choices and truthful visible outcomes |
| A1a story/gameplay | Existing opening fiction and bounded prototype decisions | Interesting scenes/characters, discoverable alternatives and persistent consequences delivered alongside the command experience |
| Complete opening chapter | Package → encounter → shelter prototype | Opening context, preparation, expedition and persistent resolution connected in ordinary play |
| Connected explorable world | B2 concourse ↔ furnished temporary shelter with party travel | Distinct readable locations, travel, optional tasks, discoverable routes and persistent task outcomes |
| Equipment progression | Narrow initial reward payloads | Acquire/equip/improve gear; costs/benefits affect encounters and survive saves |
| Power progression | Choose force blast, shield or dash | Earn and apply meaningful improvements; explain effects without imposing a permanent class lock |
| First owned private home | Temporary shelter only | Obtain actual ownership, enter/leave, use as a return point, and enforce the owner's broadcast privacy; furnishing/upgrades required, with persistent placement and improvement state |
| Recruitable companion | B2 optional join/decline/wait/rejoin and safe autonomous travel with persistent party state | Useful dangerous-area role and recoverable setbacks in B6; no permanent death |
| Useful pet progression | Immediate fetch lesson and one retrieval | Readable learning/choice and useful application within chapter; recoverable injuries requiring care, no permanent pet death |
| Expedition and setbacks | One tactical encounter and retry | Preparation, risk/reward, retreat or failure, resources and meaningful return outcome; consistent reload/recovery rules |
| Audience reactions | Real-player-only footer | Contextual reactions outside owned privacy; no tangible audience reward or in-world feed access |
| Complete player experience | B2 named launcher, onboarding, input, pause, safe save/quit/Continue and recovery | Onboarding, readable input/targeting, saves/continue/recovery, suitable animation and usable Mac build |

## Proposed chapter structure

This is a production outline, not new canon or a locked tutorial sequence. Exact geography, writing, costs and content counts belong in the first implementation packet.

1. **Takeover and orientation:** establish the neighborhood situation through actual spatial play; introduce powers, the pet, package retrieval and danger. Retain no actual first-encounter countdown.
2. **Foothold and exploration:** connect shelter to a small hub and explorable places; expose optional tasks and preparation resources. Shelter remains unowned/nonprivate unless and until an explicit ownership event occurs.
3. **Build a life and capability:** provide opportunities to obtain, furnish and upgrade a private home, recruit the companion, improve gear/powers and teach/apply useful pet behavior. Include understandable care for recoverable pet injuries. Make the required features available before the chapter ends without forcing every player choice into one order.
4. **Prepare and undertake the first expedition:** choose equipment and a route/approach; use tactical decisions, companion autonomy and meaningful risk. Optional preparation should affect choices or outcomes rather than merely check boxes.
5. **Return and resolve:** persist rewards, losses, task consequences, upgrades, party and property state; communicate the completed chapter and what was achieved. Show the complete beta boundary rather than promising unfinished later play as if already built.

A full review must exercise every required system on an ordinary route. Separate branch checks cover declined recruitment, skipped optional work, alternate power choices, retreat/failure and the selected harm rules. Player choice does not excuse missing required content; a failure test does not replace a complete chapter.

## Backlog / beta exclusions

- **Excluded from beta:** tangible audience rewards, sponsorship bonuses and audience-driven progression. Ordinary task/expedition rewards remain required and must not be mislabeled as audience rewards.
- **Later campaign:** ultimate freedom/death/negotiated endings, organizational employment and safer replay identities. Preserve their direction without building the whole campaign in the first chapter.
- **Proposed later scope:** large party management, broad property economy, multiplayer, commercial release and wider platforms. One required recruit and one owned home must not be deferred with these larger systems.
- Permanent-death mode remains deferred. Permanent pet death and permanent recruit death are excluded from beta. Home furnishing/upgrades and pet injury care are required, not backlog items.

## Potential issues and limits

| Issue | Why it matters / planned response |
| --- | --- |
| Broader world remains unfinished | B2 has two distinct places; B3/B7 must extend them into a coherent connected world and complete expedition |
| Shelter versus owned privacy | Explicit ownership and crossing boundaries must control broadcast presentation; characters still cannot access feeds |
| Recruit and pet coexistence | B2 safe pathing/travel/persistence verified; useful dangerous roles, turns and recovery remain B6 |
| Real progression absent | Initial power selection/reward choice is insufficient evidence of equipment and power improvement |
| Motion/readability | Rigid gait, hovering pet, creature cues, instant lessons and narrow rewards remain prototype limits; sample tolerance is not beta acceptance |
| Production repeatability | S02 asset recipe exists but complete effort comparison is incomplete; prove an additional representative location and moving party before scaling content |
| Save semantics expand | B2 chapter-v1 preserves opening/party/two-place state; later tasks, improvements and ownership need explicit schema evolution and verification |
| Injury care and recoverable loss not implemented | Define clear consequences/treatment and preserve recovery across saves; avoid pet/recruit permanent-loss states and unwinnable recovery dead ends |
| Current review unrun | S05 and deferred tactical assessment remain pending; no gameplay approval inferred from planning answers |
| Packaging | Installed-engine dependency and debug window/save ergonomics still need a proper personal Mac beta path |

## Full path to beta

| Stage | Deliverable | Exit condition | State |
| --- | --- | --- | --- |
| B0 — Beta scope | Opening chapter, world/progression, furnished/upgradable private home, recruit, pet care and audience limits | All asked scope decisions recorded; required/excluded features explicit | SCOPE DEFINED |
| B1 — Concrete chapter packet | [Packet](space-opera-rpg/docs/chapter-implementation-packet.md): inspected source, counted chapter, content/asset ownership, progression, loss/save rules and B2 contract | Planning references, scope coverage and initial arithmetic checked; no gameplay claim | COMPLETE — documentation only |
| B2 — Core play and visual foundation | [Full work order](space-opera-rpg/docs/slices/B2-playable-foundation.md): danger/package → distinct shelter → optional recruit → party return/fetch → save/quit/Continue; incorporate actual feedback if supplied | Complete ordinary journey, two places and moving party, exact-source checks and preserved S04; owner review separate | TECHNICALLY COMPLETE — owner review pending |
| B2.5 — Modern text-adventure play | [Command/story slice](space-opera-rpg/docs/slices/B2.5-command-adventure.md): natural language, precise commands, contextual choices, grounded narration and meaningful approaches on the B2 world; assess local AI if useful | Complete ordinary command-driven journey and a multi-approach situation with actual saved consequences; A1 and A1a both demonstrated | NEXT AFTER B2 — not started |
| B3 — World and chapter state | Travel, locations, task state, opening-to-hub continuity and persistence | Distinct connected places and optional outcomes survive return/reload | NOT STARTED |
| B4 — Progression and preparation | Inventory/equipment acquisition and improvement; power upgrades; resource costs and preparation | Benefits/costs change actual play; progression persists; no audience reward coupling | NOT STARTED |
| B5 — Home and privacy | Ownership acquisition, furnishing, upgrades, usable return point and privacy transitions | Temporary shelter and ownership distinguished; furnishings/upgrades persist and remain usable; outside feeds respect privacy without giving characters feed access | NOT STARTED |
| B6 — Companion and pet | Recruitment/autonomous behavior, useful pet learning, pet injuries/care, recoverable recruit setbacks and party saves | Both companions work together across travel/combat/reload; pet treatment works; neither pet nor recruit can be permanently lost in beta | NOT STARTED |
| B7 — Full expedition and chapter content | Complete encounters, optional approaches/tasks, rewards, retreat/failure and return resolution | Whole promised chapter playable without development shortcuts; all required systems available | NOT STARTED |
| B8 — Player experience and balance | Onboarding, UI/controls, motion/readability, difficulty/resources, saves/recovery and chapter-end presentation | Unassisted ordinary play is understandable; viable approaches and meaningful consequences; no blocking experience gaps | NOT STARTED |
| B9 — Mac candidate qualification | Usable package, exact build identity, relevant technical/visual/persistence/branch checks | Fresh launch through complete chapter and restart pass; limits recorded; no test-count proxy for completeness | NOT STARTED |
| B10 — Owner beta review | Review complete chapter and repair actual findings | Explicit beta-readiness decision on complete scope and resulting build; public distribution separate | NOT STARTED |

B1 planning and B2 engineering delivery are complete; B2 owner acceptance is pending. B2.5 is the next major slice; B2.5 and B3–B10 are not started. Prioritize A1 command play and A1a story/gameplay before expanding content. Stage order may be adjusted for dependencies within the confirmed scope; relevant UI/art/save behavior is integrated throughout rather than added only at the end. No runtime implementation is authorized merely by recording the roadmap.

## Evidence and next action

[Project hub](space-opera-rpg/README.md), [product brief](space-opera-rpg/docs/product-brief.md), [handoff](space-opera-rpg/docs/next-task.md), [candidate](space-opera-rpg/evidence/S04/candidate.json), [play card](space-opera-rpg/docs/playtests/S05-owner-play-card.md).

Current engineering: B2 is closed with actual delivery evidence; no engineering slice is active. Next major implementation: B2.5 modern command-adventure play with A1a story/gameplay, before B3. No further broad owner scope interview is needed. Existing S05 remains a separate prepared prototype review; no owner verdict is inferred. The repository retains all 48 owner answers, world rules and open decisions. The separate prior-tracker/research archive is currently missing; current project documents supersede provisional historical proposals.

The prior tracker archive is unavailable at its formerly linked path; the available S04 evidence is linked directly above. Historical readiness labels do not override this current assessment.
