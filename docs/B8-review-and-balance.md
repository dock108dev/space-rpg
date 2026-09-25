# B8 engineering review and balance

A1 command play and A1a story/gameplay remain primary. Production writing, names and numbers are engineering choices, not owner-approved canon or balance. No owner verdict is supplied.

## Main changes and observed limits

| Before B8 | Implemented change | Review evidence / remaining scope |
|---|---|---|
| Generic character; no setup | Name, three torso/jacket palettes, actual rig preview; separate generated sessions; Earlier characters | Blank, Unicode, long and literal-markup names; appearance and facing restored through early and full-chapter Continue. No mechanical appearance advantage. |
| Full histories compete with the immediate result | Pinned objective and current outcome; optional History; arrival replaces stale Stop text | Long responses explicitly direct to History. Full histories remain bounded to inherited save limits. Compact world/header labels remain smaller than enlarged body text. |
| Opening assumes knowledge of the chapter | Brief shared shopping/takeover opening, contextual objective, help with named targets and turn/recovery rules | Native fresh start, trials, destination, Help, query and Continue operated. Offline named-action grammar remains bounded. |
| Dry route repeatedly stalls at zero AP | Explicit Walk safely on cleared, unenergized yard floor | Matched route check below. No invisible End turn, spending, enemy action or live-floor travel. Ordinary AP walking/dash unchanged. |
| Rigid moving protagonist | Continuous phase-driven stride, torso/head settle and action-arm pose on the existing rig | Motion and stationary/turn states reviewed. Four-view cutout limits remain; this is not full skeletal animation. |
| Hovering pet | Lower contact position, compressed step bob, ground shadow and injured posture | Readable at ordinary scale. The retained full-body pet cutout does not have independent leg articulation. |
| Horizontal downed traveler | Seated, bent-leg pose, explicit care condition and visible sling/tether | Distinct from healthy walking; all-member rescue/care rules unchanged. The sitting pose is still a simple cutout assembly. |
| Floating party labels crowd nearby actors | Suppress overlapping party labels near the protagonist; permanent HUD retains conditions | Tall sprites can still occlude a pet one cell north at the yard doorway and in narrow approaches. This is sprite overlap, not traversal through a blocking cell. |
| Transient facing after load | Persist committed facing and restore before render | New-process early and late saves; no old queue replay. |
| Fresh practice competes with existing progress | New session per character; Continue/Earlier characters; save/quit refuses on write or pointer failure | Immutable previous saves retained. Snapshot success followed by pointer failure stays durable and does not roll back economy. |
| Small/dense choices | Scrollable choices, response/history disclosure, larger body/input/choice text | Native minimum 1152×882. Setup, long name, care/furnishing/inventory/result/help/pause/failure states inspected. No phone or arbitrary-small-window support. |
| Early saved character could be rejected | Normalize validated integral expedition fields before inherited initial-state comparison | JSON float versus integer dictionary equality was reproduced and fixed only in B8. Early Continue now explicitly checked. B7 archive/source retains its historical behavior. |

## Matched dry-route pacing

Starting from the same actually played, cleared-yard snapshot: protagonist health 4, 4 AP, injured pet/downed joined traveler, 8 carried material, survey complete, no route/core yet. The maintenance case deliberately uses the wheel despite that information to measure the detour. No state refill or damage bypass was injected between route decisions.

| Route | B7 typed commands / AP refreshes | B8 typed commands / AP refreshes | Observed result |
|---|---:|---:|---|
| Surveyed drainage | 9 / 3 | 3 / 0 | Both physically reach/recover core, zero exposure, same health, conditions and funds |
| Wheel + maintenance | 14 / 4 | 5 / 0 | Wheel detour retained; same core, health, conditions and funds |
| Unprotected live lane | 6 / 1 | 6 / 1 | Two exposures kill the already 4-health protagonist in both; core unrecovered, no reward |

The short live lane is a deliberate danger decision, not a free substitute for the dry route. The negative live result above is retained. Full game branches separately demonstrate live crossing with preparation, all three powers, declined/waiting companions and skipped optional work. The dry convenience trades explicit opt-in and a longer physical route for fewer repeated input/refresh actions; it preserves AP rather than fabricating refresh turns. Dangerous turns remain deliberate.

Improved weave remains at 2 passive protection. Against two-pressure pulses it can prevent protagonist damage, a useful four-material preparation payoff. It does not cure or protect exposed companions from their actual condition rules; the full route still has targeting, movement, support, route and return decisions. Base weave plus trained cover also prevents one otherwise remaining pressure in its one-cover turn. Improved impact and powers shorten the warden fight; dash changes movement reach/cost. No balance number was weakened simply because an upgrade works.

Main-route funding remains 20 kit + 10 home + 8 report, with optional explicit bundle +4. Gear/power improvements cost 4 each, furnishings 2 each, storage 4, care 2 per patient. Stored material is distinct. Maximum earlier purchases leave a viable free-rest and repeatable attended-care recovery route. Actual full journeys, reward uniqueness, retreat/retry, low funds and malformed/failure recovery are retained separately from parser checks.

## Sound and support decision

Retain silent presentation for B8. The play is deliberate and turn-based; visible attack/protection/pulse effects, condition poses, current feedback and completion text communicate the reviewed outcomes without requiring sound. No soundtrack or new asset dependency was needed to complete the ordinary loop. The launcher deliberately uses Godot's Dummy audio driver; no audio device/mixer behavior or audible accessibility support is claimed. Optional audio remains a future preference, not a B8 missing core control.

Native Godot exposes the window/menu but no useful gameplay controls in the observed accessibility tree. Keyboard navigation and focus were exercised; screen-reader usability is unqualified. System-font fallback is used for Unicode display without redistributing Apple fonts; arbitrary scripts/emoji are not comprehensively verified. B9 must qualify the exact packaged Mac environment, source assets, fonts and supported window dimensions.

## First-use-style engineering walkthrough

Reviewer: the implementing Codex agent, familiar with the rules and source. It operated native controls using the visible screen and retained the following prompts/observations. This was not an unassisted owner playtest and supplies no enjoyment verdict. The full normal-speed journey is a separate scripted command/controller demonstration, with no debug progression; automated branch fixtures are labeled separately.

| Prompt used in engineering review | Observation |
|---|---|
| Create a character and find the first objective | Name field, jacket preview and Start visible; long Unicode name persisted. Native review prompted repairs to modal backing, font fallback and obsolete New practice narration. |
| Choose a power using the interface | Typed the three trials and a power choice; harmless effects and the next package objective appeared. Input requires field focus after clicking other controls. |
| Go to the named package, then stop or ask what next | Actual position/facing changed. The first current-outcome filter incorrectly retained prior Stop text; final repair now shows arrival. |
| Find out why End turn stops a plan | Help explains AP, ally/enemy response, explicit new command and distinctions among range, breach and full expedition. Escape returned typing focus; a follow-up question acted only as information. |
| Enlarge text, pause, save and quit, then continue | Larger command/response/choice text remained usable. Pause Save and quit closed the native process; new-process Continue restored the long name, plum clothing, position and facing. |
| Locate an earlier character | Earlier characters listed the saved session; inspection caught and repaired selector width/font fallback. No older namespace was inspected or migrated. |
| Inspect full-chapter action and recovery states | Scripted ordinary journey and matched fixtures cover walking/turns/attacks, cover fetch, injury/downing, rescue, paid care, route choice, core/report, furniture/private home and exact restart. Scenarios are engineering-operated, not owner testimony. |

Retained attempts document the parser/runtime signal mistake in the first session selector, the inherited pre-expedition load defect, a presentation fixture whose deliberately long name was not initially normalized, the single/current selector item initially not accepting reselection, and a test-runner restart-directory collision between the main and ergonomics suites. These were bounded repairs; malformed specimens and earlier attempts remain retained. The final runner uses a separate ergonomics subtree.

Final retention note: overlapping late capture/check runs timed out and were preserved. A later standalone presentation run was stopped after excessive idle-frame rendering; its capture-only waits were shortened. The full chapter movie retains original 1x timing, including idle pauses. The gameplay runner passed sequentially; no successful result is inferred from an interrupted attempt.

Matched renders use direct synthetic snapshot injection; the home fixture can retain the preceding rescue message in the upper transient strip while showing the completed result below. This is capture-harness context, not an ordinary travel sequence. The actual ordinary journey is retained separately. The presentation tool disables vertical sync and explicitly draws the screenshot frame. Waiting for a spontaneous frame-post-draw signal could stall on an idle scene; explicit drawing completed every case. Original failed/stopped attempts are retained.

The same idle-frame wait was found in the restart movie screenshot step: the restored state was already correct, but the idle movie continued recording. That interrupted attempt is retained; the final restart explicitly draws its screenshot frame. The full-journey capture helper now uses the same bounded method for future captures; the retained chapter movie predates that harness-only fix and keeps its idle pauses. Production gameplay bytes are identical.
