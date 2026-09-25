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
| O13 | Ownership/guest/privacy exceptions | Before property mechanics | B5 own interior/inside threshold private; hub and shelter public. Guests/joint ownership deferred |
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

Resolved: modern text-adventure command play is A1; story and gameplay are A1a. The primary surface combines natural requests, exact movement, prompts/choices and narration that operates the actual world. B2.5 is technically complete after B2 and [explicitly owner-accepted](playtests/B2.5-owner-acceptance.md). Do not re-ask whether this feature is central or defer it behind B3 expansion. AI or a small local model is a candidate implementation aid for complex intent/context/patterns; provider, model and packaging are not selected. The [B2.5 assessment](B2.5-language-assessment.md) measured the shipped offline interpreter; local-model inference remains untested. Reopen model selection only for demonstrated language gaps.

## B3 production defaults — September 24

The connected-world slice is technically complete with owner review pending. [B3 contract](B3-runtime-contract.md) records the implemented one-bundle recovery, manual shortcut and survey discovery, including reversible task refusal and separate world-v1 saves. These are production defaults, not new canon or balanced B4 currency. B4 must explicitly reconcile its arithmetic with actual B3 outcomes; no further broad discovery interview is needed.

## B4 production defaults — September 24

[B4 contract](B4-runtime-contract.md) implements preparation through one equipment slot, three families, earned chosen-power calibration and explicit materials. B1 funding is reconciled to 20 required-route + 4 optional bundle; no access/survey currency. Balance and owner gameplay quality remain unaccepted. B4 is technically complete; B5 must reconcile funding against actual retained balances before adding home spending.

## B5 production defaults — September 24

[Home contract](B5-runtime-contract.md) implements earned ownership, 10 one-time settling material, three 2-material furnishings and a 4-material locker. Maximum B4 spending still leaves 4 total material after all B5 purchases, without optional work. Carried and stored quantities remain distinct. B5 is technically complete; owner gameplay/balance acceptance remains pending. B6 now implements two-material care per patient and free attended assistance; the original one-unit B1 care proposal is superseded by the delivered B6 contract.

## B6 delivered implementation

[Completed work order](slices/B6-companions-and-care.md) delivers autonomous recruit behavior, earned cover fetch, a bounded danger/care loop, retreat and exact persistence. No permanent pet/recruit death; decline/wait remains viable. Paid care costs two carried material per patient; free assistance takes two attended six-second rounds and is repeatable with zero total funds. Stored material must be explicitly withdrawn before paid treatment. B6 is technically complete, with owner acceptance pending; no model selection is implied.

B6 resolves its bounded implementation defaults in [B6-runtime-contract.md](B6-runtime-contract.md): cover fetch after actual retrieval, a single autonomous support shot per turn, recoverable injury/downing, evacuation, two-material care and repeatable attended assistance. No owner scope question was reopened. Owner play/quality acceptance remains a separate gate; B7's full expedition and later balance remain open work.

## B7 delivered implementation

[Relay contract](B7-runtime-contract.md) supplies the complete expedition, two different dangers, surveyed/maintenance/live approaches, core and exactly-once eight-material report. Six-place count is retained; no required duration is invented. All powers and optional-task/recruit skipping remain viable. Names, balance and chapter prose are production choices; owner acceptance remains pending. Character setup, dry-route pacing, text density and companion presentation remain B8 work, not a reason to restart discovery.

## B8 delivered implementation

Bounded name/appearance setup, brief shared shopping opening, contextual help/outcomes, explicit safe dry walking and improved cutout condition/motion presentation are delivered. No broad discovery or model choice was reopened. The [contract](B8-runtime-contract.md) defines schema, separate sessions, Unicode and save recovery; [review](B8-review-and-balance.md) records evidence-backed pacing, unchanged weave balance and silence decision. These production choices do not supply owner acceptance. B9 packaging is technically complete; B10 owner review remains unstarted. See B9-packaging-contract.md.
