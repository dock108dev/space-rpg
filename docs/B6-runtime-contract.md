# B6 contract — implementation defaults

A1 command play; A1a story/gameplay. Engineering tuning, not owner-approved balance.

## State and save policy (defined before implementation)

`care_version: 1`, `care` dictionary supplements every B5 field. Separate B6-practice-v1 namespace; reject earlier formats without scanning/migration. Stable player decisions only; no active animations, fetch or evacuation saves. Conditions persist through ordinary travel/rest/home. Continue restores all state; commands never replay. Protagonist defeat does not overwrite the last living save.

| Field | Meaning / valid values |
|---|---|
| trained | boolean; cover fetch earned after a real successful pet cache/supply retrieval and an explicit lesson at the harmless range |
| pet | healthy / injured; injured cannot fetch or provide cover |
| recruit | healthy / downed; only a recruited joined/waiting traveler can be downed |
| paid, assisted | nonnegative cumulative treatments; paid costs 2 carried material each |
| aid_actor, aid_steps | empty/0 or pet/recruit with 1 or 2 remaining attended care rounds; injured/downed until final round |
| encounter | idle / active / retreated / cleared |
| threat, round, points, guard | threat 0–12, resolved rounds, 0–4 action points, temporary 0–6 guard |
| cover, assists, retreats, victories | per-attempt cover boolean; cumulative recruit actions, evacuations and victories |

Home validator projects paid expenditure back into the inherited conserved wallet, then runs all B5 numeric-safe placement, privacy and prior state checks. Paid treatment and benefit commit in one immutable snapshot. All mutation failures restore full prior state and positions. Earlier invalid snapshots and valid recovery material remain untouched.

## Bounded danger: containment breach at the approach

A loose assessment creature guards a damaged containment latch, distinct from the harmless north range and the closed B7 expedition barrier. Enter explicitly beside the breach marker at (6,3). Entry requires the kit and completed opening, not recruitment, training or optional work. No reward/currency. Repeatable after retreat or clearance. The creature has 12 health at (9,3). Player starts where they walked; companions use their actual collision-safe positions. Four AP per turn. Cardinal step 1; bolt/blast 2; guard/shield/dash 1. Bolt range 6, blast 4, line of sight required. B4 derived lens/weave/rig and power effects apply. Guard/weave reduces the creature's 2-pressure protagonist pulse. Dash follows every clear cardinal cell. End turn resolves exactly one recruit action, one trained-pet opportunity, then one enemy pulse. No offline/time-driven damage. Killing it prevents that pulse.

The joined healthy recruit automatically fires one 1-impact shot at the present creature within 6 cells and clear sight per End turn; no player AP cost, no second action. Healthy trained pet retrieves a nearby loose cover plate once per attempt along an actual clear route and returns it, absorbing 1 pressure on that pulse. The first surviving creature pulse injures an exposed pet; the second downs an exposed recruit. Exposure requires range 6 and clear sight. Neither is removed. Damaged actors cannot help until treated. No permanent deaths. Ally bodies do not block one another but share terrain collision. During combat, companions hold their actual positions except the bounded retrieval; no background following turns.

Retreat carries impaired members and follows a clear route to the west exit; healthy members evacuate with the protagonist. If the route is blocked, ordinary retreat refuses without changing state. Explicit `call evacuation` requests an overhead rescue, bypassing the floor obstruction by documented extraction (not wall walking), forfeiting the attempt. Both return all joined members to valid hub cells with unchanged conditions; waiting members stay in shelter. No payment or reward. The opening and north range never reset.

## Recovery and economy

`Treat the pet` / `Help the companion recover` at the shelter desk cost **2 carried material per actor**. Supplies are provided by the desk, not an inventory grant. Healthy targets refuse without charge. Stored funds are never silently used: return home, go to locker, withdraw the required material, return to the desk. Questions disclose carried/stored totals.

`Begin assisted pet care` or `Begin assisted companion care` is always available at the desk with no payment. Tradeoff: two explicitly attended care rounds, each a six-second noncombat procedure; remain at the desk until finished or cancel assistance. `Continue assisted care` performs one round, pausable; Stop cancels future rounds, not an already committed round. Recovery commits only on the second completed round. Progress is saved between rounds, never advances offline, and travel/other care requires `cancel assistance` first. Cancellation leaves the injury and discards attended progress. Repeated injuries can always use this path without optional work, farming, kits, owner intervention or new game. Protagonist rest is free and never heals companions.

Conservation: carried + stored = 20 kit + 4 bundle + 10 settlement − 4*(gear upgrades + power upgrade) − 2*furnishings − 4*locker − 2*paid treatments. No care currency source. Maximum B4/B5 spending leaves 4: two treatments; subsequent setbacks use assistance or remaining legitimately held funds. Representative preparation plus full home leaves 12: six treatments. No future expedition rewards counted.

## Behavior and condition reference

| Actor/behavior | Activation and turn budget | Eligibility / target | Cost / outcome |
|---|---|---|---|
| Protagonist | Direct command, choice or control; four AP per turn | Adjacent clear steps; bolt range 6 / blast range 4 with room-specific line of sight | Move/guard/shield/dash 1 AP; shot/blast 2 AP; existing gear effects derived once |
| Traveler support | Automatic once per explicit End turn | Joined, healthy, present threat, distance ≤6 and clear sight | No material or protagonist AP; exactly 1 impact, cumulative assist counter |
| Pet cover fetch | Automatic once per breach before pulse; actual outward/return path | Healthy, trained, reachable plate within seven path segments | No item/currency reward; absorbs one pressure for that pulse only |
| Cover fetch lesson | Explicit command beside north range | Learned original fetch and successful pet cache/supply delivery | Free, exactly once; training persists |
| Waiting traveler | Explicit healthy wait at shelter | Joined; no leaving downed actor in danger | Safe shelter membership/position persists; can rejoin |
| Rescue | Explicit retreat, or explicit overhead extraction for blocked floor routes | Active breach; return includes all joined actors | Attempt forfeited; no money/reward; conditions unchanged |

| Condition | Trigger | Lost capability | Recovery |
|---|---|---|---|
| Healthy pet | Initial state or completed care | None | No treatment charge permitted |
| Injured pet | First exposed surviving creature pulse | Cache/supply fetch and cover fetch | Paid or assisted pet care at desk |
| Healthy traveler | Initial state or completed care | None | No treatment charge permitted |
| Downed traveler | Exposed pulse from second resolved round onward | Autonomous shot; cannot be left waiting before care | Rescued with party, paid or assisted companion care |
| Protagonist defeat | Actual health reaches zero | Further actions and saving | Continue latest living snapshot; no fabricated resource/condition reset |

## Presentation and integration

B6 reuses the retained cutout actors, approach/shelter/home artwork and shared follower/pathing implementation. New breach/cover/condition marks and pulse/shot effects are drawn by the B6 controller. Rescue gathers actors along checked routes before carrying them down the exit path; overhead evacuation fades the extracted group. A downed traveler is shown horizontally and remains visibly with the party after return. These are engineering presentation choices, not new art-direction acceptance.

The offline interpreter and dispatcher remain shared. B6 adds named care/training/breach actions and a bounded correction for action plans whose last `then` clause is a question. Contextual care and approach menus fit the existing supported layout. Stop allows the current committed turn/round/rescue to finish, cancels future work and does not undo injury. Focus loss and pause freeze the whole action, including care time. No outside-audience text enters interpretation, actor knowledge or accounting.
