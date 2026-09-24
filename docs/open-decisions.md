# Open decisions

For current beta planning, resolve consequential first-chapter choices; the S04/S05 entries below retain prototype decisions. “Provisional” is not a requirement to ask the same question again immediately.

| ID | Decision | When needed | Current treatment |
|---|---|---|---|
| O01 | Engine and reproducible local setup | S01 | S01 resolved by engineering judgment: installed Godot 4.6.2 Standard/GDScript, Compatibility renderer; setup and visible launch verified in S02. See technical approach. |
| O02 | Asset/animation technique | S01–S02 | S01 method selected: generated masters, Krita cleanup, Godot rigid cutouts; authored PNG frames fallback. S02 repaired human received permission to continue; A/B cabinet process demonstrated. Pet placeholder hovering tolerated for now; detailed gait and full active production-time comparison remain limitations. |
| O03 | Pet injury/care | Beta implementation | RESOLVED September 21: recoverable injury requiring care, no permanent death. Original prototype remains damage-free; treatment details are implementation design. |
| O04 | AP budget/costs/turn order | S03 | S03 hypothesis: player first, 4 AP; move/shield/dash/control 1, bolt/blast 2; explicit End turn. Runtime checked, pacing and owner preference unassessed. |
| O05 | Pause/focus-loss behavior | S03–S04 | S03 explicit and focus-loss pause freeze all simulation; manual resume. S02 retains explicit-pause-only behavior. Runtime checked; owner ergonomics deferred. |
| O06 | Input/camera controls | S02 | S02 tested: fixed angled view, WASD/arrows eight-way movement with four visible facing groups. Reversible test choices, not owner-approved final camera/animation limits. |
| O07 | Exact pet and first learned behavior | S04 | S04 prototype: immediate fetch lesson at package collection; later physical cache retrieval delivers one recovery kit. Persistent and runtime checked; species/lesson presentation and owner appeal remain open. No training tree. |
| O08 | Autosave timing/mid-turn save policy | S03–S04 | S03 autosaves at choice/start and success; manual at idle player boundaries including partly spent AP. Actual latest valid snapshot retry checked. No saving during actions/enemy/pause/defeat; see S03 contract. |
| O09 | Real-player audience UI versus character knowledge | S04 | S04 real-player-only outside-audience footer; four bounded presentation reactions, no character/AI knowledge coupling. Owner comprehension unassessed. |
| O10 | Reward payloads and persistence | S04 | S04 prototype: two recovery kits / visible field lamp / route to existing cache. Exclusive persisted choice verified; owner value/balance unassessed. No full economy. |
| O11 | Opening geography/shared background | Before story expansion | Test assembly is not permanent canon |
| O12 | Freedom, employment, identity persistence | Later campaign planning | Preserve direction; no early simulation of full system |
| O13 | Ownership/guest/privacy exceptions | Before property mechanics | Shelter not assumed private |
| O14 | Duration, commercial scope, broader platforms | After measured samples | No release date, hours-to-finish, or commercial promise |

Confirmed choices are summarized in current-design.md. Revise a provisional implementation if play evidence warrants it; material creative changes belong to the owner. Numeric tuning and local setup choices may use documented engineering judgment.

S01 source-backed decision: [technical approach](technical-approach.md). No new owner answers or canon were added. S02 human feedback is positive after mask repair; pet hovering tolerated for now. Larger creature action read as moving toward the box; S02 feedback closed with the stated sample limitations. See playtests/S02-owner-feedback.md.

S03 owner steering: continue building without basic check-ins; record minor issues for later review. This does not supply a tactical-play or cue-comprehension verdict. See [S03 owner record](playtests/S03-owner-feedback.md).

## Beta decisions — September 21

Scope resolved: opening chapter through first expedition; connected locations/optional tasks; equipment/power progression; an owned private home; one recruit alongside pet; no tangible audience rewards. Do not re-ask these.

Resolved: home furnishing/upgrades required; pet injuries require care and are recoverable; neither pet nor recruit can die permanently in beta. No further owner scope question is required now. O13 ownership/privacy now matters to the required home: do not infer temporary shelter privacy, guest/joint ownership rules or character access to broadcasts. Numeric tuning and content counts can be documented implementation proposals.

## B1 implementation defaults — September 23

The [chapter packet](chapter-implementation-packet.md) supplies a six-place working route, bounded content counts, initial resource arithmetic, save/party rules and B2 delivery. O11 working geography is now sufficient for implementation without establishing transportation lore or a detailed protagonist biography. O13 is bounded to the player's own-home interior/threshold in B5; guest/joint ownership remains deferred. These are documented production defaults, not a new interview or a reason to hold B2 for basic choices. [B2](slices/B2-playable-foundation.md) is technically complete with owner acceptance pending; S05 feedback remains pending separately. B2 retains the three initial reward payloads, one-map combat rules within the concourse, and supplies a separate chapter-v1 save validator for its two locations and party.

## A1 / A1a direction — September 23

Resolved: modern text-adventure command play is A1; story and gameplay are A1a. The primary surface combines natural requests, exact movement, prompts/choices and narration that operates the actual world. B2.5 is technically complete after B2, with owner review pending. Do not re-ask whether this feature is central or defer it behind B3 expansion. AI or a small local model is a candidate implementation aid for complex intent/context/patterns; provider, model and packaging are not selected. The [B2.5 assessment](B2.5-language-assessment.md) measured the shipped offline interpreter; local-model inference remains untested. Reopen model selection only for demonstrated language gaps.
