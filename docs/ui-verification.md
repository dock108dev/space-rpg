# Glass UI adoption verification

September 21, 2026 · source implementation and engineering review only.

The project S04 validator passed fresh import, S04 behavior, full restart, S03 behavior, and S02 regression stages. Evidence: evidence/S04/run-20260921T161938Z. A fresh disposable-copy 1280×720 render was inspected; the header backing height was adjusted afterward and the render repeated. The frozen owner candidate remains unchanged.

September 23 audit: the retained 105-file validation manifest differs from current source in `game/scripts/tactical_encounter.gd`, following the documented backing-height adjustment. The prior stage passes belong to the recorded source; the later render does not establish a fresh full regression pass. The frozen S04 candidate still matches all 103 manifest entries and its separate launcher hash.

## Retained review

The shared [review gallery](../../ui-templates/review.html) contains screenshots and browser check results. Browser specimens are local fixtures or isolated startup states. Web review checked representative 1440px/390px layouts, page exceptions, and page-level horizontal overflow; it is not an exhaustive audit of every state, contrast pair, screen reader, browser, installed build, or physical phone.

Template gallery search, form submit feedback, dialog opening, and Escape dismissal were exercised. Shared styles include keyboard focus, reduced-motion, and reduced-transparency handling. Native Godot is a basic translucent fallback, not a true blur material. Native games retain their desktop layout and illustrated artwork.

See [design and future template use](ui-design.md). No owner acceptance or release qualification is inferred. Rebuild/relaunch the appropriate source application to see the change; installed or frozen copies remain their original versions.

## B2 interface review

B2 has its own ordinary chapter controls and pause/recovery panel. Native Mac input found a delivered-event targeting defect; B2 now uses event coordinates transformed into scene coordinates. A moving capture found contextual reward/recruit controls overlapping Pause; they now start at580px, beyond the utility row's558px right edge. Geometry regressions and final native/moving observations are in [B2 evidence](../evidence/B2/README.md). The frozen S04 UI remains unchanged; no owner acceptance is inferred.

## UI-02 — B2 presentation cleanup

September 23, 2026 local date; UTC evidence folders use September 24. **TECHNICALLY COMPLETE; owner acceptance pending.** UI-02 qualified B2 source only. At that delivery B2.5/B3 were unstarted; B2.5 has since completed as recorded below. [Matched comparison](../evidence/UI-02/comparison.html) · [final checks](../evidence/B2/run-20260924T022020Z/results.json).

- Useful task first: objective, relevant state and one action row. At the reward desk, 12 visible buttons became 6; controls end at y=166 rather than y=194 in the same 1280×720 viewport, while button height increased from 38 to 44. Art, camera and floor geometry did not change. There was no scrolling before or after.
- Reward payloads are explained beside the choice. “Travel alone” becomes “Travel with pet,” matching the unchanged party behavior. Defeat is identified correctly instead of “Creature turn,” with Continue emphasized. Save success, failure, empty storage and skipped unusable saves retain different meanings. Raw save notices remain in Pause details.
- Save/Continue stay one click; reward choice stays one click; Pause → Save and quit stays two clicks. Stop walking and Cancel target remain directly available when relevant. New practice, full controls and technical save details use one secondary disclosure. Tab/Space, movement from focus, Escape and return focus are checked.

**Actual checks.** `scripts/validate.sh B2` passed fresh import, all 457 existing gameplay assertions, 65 focused UI/input/journey assertions, a real Save-and-quit process, nine separate-process restart assertions and historical-namespace isolation. [Focused results](../evidence/B2/run-20260924T022020Z/b2-ui-checks.json). Final runtime manifest: `fa8436d995770b62bab5223e9e9170d0fd54b83f721a8c30b7a43923866b551a`; [retained source archive](../evidence/B2/run-20260924T022020Z/runtime-source.tar.gz). No runtime changes followed this run.

Matched rendered states cover initial/disabled power choices, no save, combat, defeat, reward, recruitment, fetch, assigned walking, pause and failed save; the after version also captures expanded details. Both sides use the same retained synthetic B2 fixtures and viewport. The comparison uses **new entry-source renders**, not old B2 screenshots. [Capture harness](../evidence/UI-02/capture.gd), per-size `metrics.json`, and PNGs are retained under `evidence/UI-02`. Inspected 1280×720, 1600×900 and 125% font stress at 1280×720. All reported visible control bounds fit the logical 1280×720 canvas; no scroll, clipping or control overlap was found in the reviewed final states. Normal body/control copy is 17–18px; focus is outlined, with a white outline on blue primary actions.

Native Mac operation exercised all three previews, power choice, Escape, Tab, Space-to-Save, visible success and mouse Save-and-quit, in a separate synthetic directory. The native run used the passing `021704Z` runtime; subsequent changes were a white primary-focus outline and two contextual objective labels. Final rendered captures and automated UI checks cover those changes. The automated journey remains separate from human-operated gameplay. No full new native combat playthrough, VoiceOver assessment, smallest-window qualification, owner review or standalone release qualification was performed. S04 tests were not rerun: its source and shared base scripts were unchanged.

**Preservation.** [Hash comparison](../evidence/UI-02/preservation.json): all 1,165 entry files unchanged, including frozen S04, its launcher, earlier B2/S02–S04 evidence, and artwork masters. No owner saves were inspected or changed. The original B2 candidate is preserved; the current launcher runs this newer source. No commit, push, publication or installed-build replacement occurred.

**Failed attempts retained.** Initial preview had a typed-variable parser error, repaired before rendering. The first behavioral run failed three assertions tied to the audience sentence; the familiar “characters cannot” wording was retained. Focused testing corrected fixture timing and follower-position comparisons, and found a real mouse regression: releasing focus before activation canceled button clicks. Focus release now occurs after activation; focused tests and native clicks verified the repair. Larger-text review widened the expanded pause card. Earlier attempts are not final-candidate passes.

### Follow-up suggestions recorded at UI-02 delivery

| Priority / source | Observation and impact | Status / scope boundary | One bounded next action |
| --- | --- | --- | --- |
| 1 — B2 ordinary play / B2.5 contract | UI-02 had no typed command adventure. | Subsequently implemented and technically checked in B2.5; owner acceptance pending. | Extend the delivered command/story interface through B3. |
| 2 — native B2 accessibility | The Mac accessibility tree exposed the window and menu but no gameplay controls. Screen-reader usability is therefore unestablished despite keyboard focus working. | Observed tree limitation; actual VoiceOver impact needs verification. Native accessibility integration is separate capability work. | Run one bounded VoiceOver review of power choice and Pause before deciding the required engine/accessibility changes. |

## B2.5 command/story interface

The command candidate extends the unchanged UI-02 chapter scene with a visible history, input, contextual actions, activity and Stop below the illustrated world. Logical canvas 1280×980; default native window 1152×882. The original B2 launcher and historical prototypes retain their previous layouts. [B2.5 evidence](../evidence/B2.5/README.md) records native keyboard/mouse checks, final moving review, exact source identity and limitations. Owner acceptance and accessibility qualification remain separate. UI-03 was interrupted after before captures and superseded before runtime implementation; its evidence is preserved.
