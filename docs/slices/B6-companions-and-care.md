# B6 — Companion behavior, training and recoverable care

**TECHNICALLY COMPLETE — B6-20260924-01, September 24, 2026. Owner acceptance pending.** B2.5 remains explicitly owner accepted; B3/B4/B5 verdicts remain pending. B7 has since completed technically; see the current handoff for the next scope.

[Delivery/evidence and demonstration](../../evidence/B6/README.md) · [Player guide](../B6-player-guide.md) · [Behavior/condition/care/save contract](../B6-runtime-contract.md) · [Current engineering handoff](../next-task.md).

Implemented: earned cover fetch, bounded autonomous recruit support, actual turn-based breach danger, injury/downing, physical party rescue and blocked-route extraction, paid and repeated no-funds care, exact state Continue. Final checks: 361 gameplay checks, 20 language cases, 10 separate-process states, 273 independently reconciled snapshots, all eight inherited suites, native Mac input review and normal-speed demonstration. Failed attempts remain retained. Engineering verification and visual observations do not establish owner acceptance or full-beta readiness.

The original complete work order follows as the scope record.

Implement B6 in `/Users/michaelfuscoletti/Desktop/space-opera-rpg`. The source-of-truth tracker is `/Users/michaelfuscoletti/Desktop/space_opera_rpg_next_steps.md`. Deliver implementation, integration, relevant verification, documentation and a complete playable handoff.

1. Priorities and entry

A1 is modern text-adventure command play. A1a is story and gameplay. Companion behavior, training, danger, retreat and care must create understandable choices through commands, contextual options and grounded narration, with actual visible world actions.

Read AGENTS.md, README.md, the Desktop tracker, current-design.md, world-rules.md, open-decisions.md, chapter-implementation-packet.md, next-task.md, this work order, the B5 player guide/runtime contract, B5 candidate/evidence and the inherited command, party and combat contracts.

Reinspect current HEAD, dirty source and incoming work. Preserve B5 and earlier archives, evidence, assets and save namespaces. Mark only B6 IN PROGRESS when implementation starts. Resolve routine design and tuning within the confirmed scope; do not repeat the broad interview or invent acceptance.

2. Complete playable outcome

From ordinary progression, prepare the protagonist and party, teach or earn one useful improvement to the pet's existing behavior, enter a bounded dangerous situation, observe useful autonomous recruit/pet behavior, encounter recoverable setbacks, retreat with the party, provide actual care, demonstrate restored capability, then save and Continue the exact state in a new process.

Implement this as a coherent world interaction using existing locations or a bounded extension of the approach. Explain its purpose, entry, risk and return route. Use actual turn-based danger and state changes. The B4 range remains harmless; do not silently turn it into damaging combat. Do not reset the completed opening encounter or label B6 as the full B7 expedition.

The ordinary passing journey must produce real danger/injury/recovery through game actions. Clearly labeled negative fixtures may exercise difficult error states; debug injury injection cannot supply the main playable proof.

3. Autonomous recruit and trained pet

The player controls one protagonist. Give the recruit a useful autonomous role with explicit activation, eligibility, target selection, turn timing, costs and outcomes. High-level supported directions are appropriate; do not introduce direct squad micromanagement or endless actor turns.

Define how the pet helps in or around danger using its actual learned capabilities. Add one useful, earned improvement to existing training, with an observable benefit and a persistent training state. Preserve established fetch, supply recovery and label consequences. Avoid inventing a compulsory feeding/bonding meter.

Define ally collision, pathing, danger eligibility, interruption and party placement. Companions must not attack absent targets, pass through blockers, duplicate rewards or consume an unbounded number of actions. Pause/focus loss freezes them with the rest of the game.

Keep recruited, declined, waiting and rejoined branches viable. The encounter and main progression must remain completable without the optional recruit. Preserve safe waiting behavior and explain when a requested task is unavailable.

4. Recoverable setbacks, retreat and care

No permanent pet or recruit death in beta.

Define explicit condition states, triggers and effects. An injured pet must lose or limit an affected capability until treated. A downed recruit remains recoverable. Make condition, unavailable actions and the recovery route understandable through narration and choices.

Retreat must return the party coherently, including injured/downed members. Define rescue/evacuation behavior and blocked-route handling. A party member cannot disappear, become permanently stranded or be silently converted to healthy during travel.

Care is an actual supported interaction with eligibility, effect, costs if any and saved results. Demonstrate impaired behavior before treatment and restored behavior afterward. Entering shelter/home alone must not erase injury unless an explicit, documented care interaction performs recovery.

Keep ordinary protagonist defeat/reload consistent with the existing save rules. Preserve the exact saved condition/resources rather than granting free items or resetting only convenient fields.

5. Funding and a viable recovery path

Use actual implemented accounting:
- B4 kit: 20 material once.
- Optional B3 bundle exchange: 4 once.
- B5 settling award: 10 once.
- All B4 upgrades: 16 total.
- Three furnishings plus functional storage: 10 total.
- Maximum B4/B5 purchases leave total 4 without optional work; representative one-gear/one-power preparation leaves 12.

Carried and stored material are distinct. The player may have deposited all carried funds. Explain and support withdrawal rather than inventing a shortfall or silently spending stored resources.

B1's one-unit care suggestion is provisional. Define actual B6 prices, supplies, sources and timing before implementation. Account for repeated setbacks and depleted funds, not just one affordable first treatment.

Provide a visible, usable recovery path for zero carried funds, funds stored at home, and exhausted total funds. Choose a bounded alternative consistent with the world, such as explicit assistance or a recovery interaction with a meaningful nonmonetary tradeoff. It must preserve recoverable consequences without forcing optional tasks, farming, owner intervention or a new game.

Keep protagonist rest free. Do not replay settlement/kit awards, grant access/survey currency or count future expedition rewards as present. Record sources, spending and recovery rules; independently reconcile quantities.

6. Command and story integration

Extend the existing target registry, interpreter, dispatcher and contextual narration. Text, choices and direct controls use the same action/state authority.

Support useful requests such as “How is the pet?”, “What can my companion do?”, “Teach the pet [actual skill]”, “Have the companion wait”, “Ask the pet to fetch it”, “Retreat”, “What does treatment cost?”, “Treat the pet”, “Help the companion recover” and “Stop”. Use actual names in guides/tests.

Questions and previews must not spend turns or resources. Clarify ambiguous actors or consequential unspecified choices. Reject ineligible tasks truthfully. Clear supported commands normally execute without repeated confirmation.

Keep exact movement, cross-room context, stale/duplicate guards, typing focus, pause and direct reclaim. Stop cancels future player-directed work at safe action boundaries; it must not fabricate a turn rollback or undo completed damage. Narration reports observed actions and actual partial outcomes.

Write short authored responses for preparation, training, first setback, retreat, treatment and return to capability. Preserve the setting's dark humor without trivializing consequences. Home privacy remains intact; characters and interpreter never gain outside-audience knowledge or rewards.

The bounded offline interpreter remains the baseline. No semantic-model migration is required.

7. State and persistence

Define B6 schema, condition/training/encounter fields, valid combinations, stable save boundaries and compatibility policy before coding. Use a separate B6 development namespace and disposable synthetic tests. Do not scan or migrate owner saves for qualification.

Persist recruitment/waiting, training, conditions, recovery/encounter outcomes, party placement, resource and storage quantities coherently with existing gear, powers, tasks, ownership and furnishings.

Care costs and benefits commit atomically. A failed write must not lose funds, heal for free, erase an actor or claim success. Restore every affected field on rollback. Preserve invalid snapshots and earlier valid recovery material.

Continue must restore exact gameplay state, including injuries, after retreat or treatment. Queues remain inactive and history never replays actions. Preserve B5's numeric-safe furnishing collision checks and privacy-before-render behavior.

8. Verification

Add the actual B6 runner to the project-local entry point. Demonstrate a fresh ordinary command/choice journey through preparation, earned training, actual danger, useful autonomous behavior, real recoverable injury/downing, retreat, care, restored capability, Save and quit, and separate-process Continue.

Check all powers and relevant equipment effects; recruited/declined/waiting/rejoin branches; injured-pet task refusal; recruit downing; solo viability; blocked paths; rescue/return; repeated setbacks; zero/carried/stored-fund recovery; exactly-once costs/outcomes; and no permanent loss.

Check timing and bounded autonomous actions, questions without mutation, clarification, Stop/pause/reclaim, text focus, stale/duplicate requests, invalid condition combinations, transaction rollback and restart before/after care. Separate language interpretation from actual execution.

Independently recompute resource and inventory changes. Run relevant B5 and inherited regressions, including furniture-after-load and home privacy. Preserve failed attempts and rerun affected checks after bounded repairs.

Perform native Mac input review and retain a normal-speed demonstration of actual behavior, setback, retreat, care and restart. Keep current supported-size readability. Bind final evidence to exact source, artwork and launcher. Distinguish technical results, engineering visual observations and owner acceptance.

9. Delivery and later scope

The lead owns integration and the condition/action/save contract. If distributing work, assign bounded ownership for party/encounter state, command/story/care interface and independent verification; agree shared contracts before overlapping edits.

Deliver a named B6 launcher/candidate, player guide, behavior/training/condition/care tables, exact archive and evidence, normal-speed demonstration, known limitations and the next handoff. Update tracker, README, slice board, design, state/economy contracts and validation docs. Keep A1/A1a prominent.

Finish B6 before returning the handoff. B7 owns the full expedition, preparation-dependent approaches and chapter return/resolution. B8 polish, B9 standalone Mac and B10 complete-beta acceptance remain separate.

Stop after B6 delivery. No automatic B7 implementation, commit, push, publication, purchase or external message. Do not infer owner acceptance or full-beta readiness from tests.
