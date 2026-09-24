# Connected world: player guide

Double-click **Launch B3.command**. Installed Godot 4.6.2 is required. B3 has its own practice saves; Continue does not read B2.5 or owner saves. The supported native window is 1152 × 882.

Start with the ordinary opening. Try the three powers, choose one, approach the package and interact to enter the assessment. Use combat choices and deliberately end turns. Once cleared, collect the package and reach shelter. Choose an orientation reward at the desk. The traveler may join, decline, or wait in shelter; return beside them to change that decision.

Type an intention, press Return, or click a contextual choice. Characters carry it out in the illustrated world. WASD/arrows and E remain available after leaving text input with Tab or clicking the world. Escape pauses; Stop cancels unfinished work, including pet retrieval. Completed actions stay completed.

## Explore

- `go to shelter` — from the concourse, after collecting the package.
- `go to hub then inspect board` — from shelter; discovers what optional work offers.
- `inspect the access panel` or `inspect supplies` — read the local interaction and tradeoff.
- `go to approach then inspect marker` — travels, then resolves the new-room target.
- `what work is unfinished?` — current task states and bundle inventory; spends nothing.
- `go to hub then go to shelter` — returns from the approach.

Only directly connected destinations resolve in each clause. `go to hub` from the concourse explains that shelter comes first. A bare `doorway` in a two-door room asks for clarification. Room changes clear references: name `marker` after traveling instead of assuming `it` still identifies something.

## Optional work

| Work | Working commands | Result |
|---|---|---|
| Recover supplies, hub | `go to supplies then collect supplies` **or** `inspect supplies then ask pet to fetch it` | One sealed bundle, once. Carrying preserves the label; the pet makes a physical round trip while you stay put and chews the label. |
| Restore access, hub | `go to access then restore access panel` | Opens the central partition shortcut. The perimeter route always remains open. |
| Survey, approach | `go to marker then survey the approach` | Records the visible drainage path; examination changes. No expedition is completed. |

`skip supplies`, `decline access`, or `skip survey` leaves that work unfinished and travel open. `resume supplies`, `resume access`, or `resume survey` makes skipped work available again at its location. Completed work cannot pay twice. The sealed bundle is an ordinary task item; spending and upgrades are not implemented.

The concourse cache is separate: it still yields its original one healing kit and preserves the accepted personal-versus-pet story consequence. The traveler comments on both retrievals.

## Control and save

`move 5 up and 8 right` attempts those exact steps in order. Walls, bounds and combat AP can stop it; the game reports the completed portion and never routes around an exact-step obstruction. `actually, inspect board` replaces unfinished work. `Stop` cancels it. Questions do not move you.

Use `save and quit`, or Escape → Save and quit, at a stable boundary. Relaunch and choose Continue. Location, placement, party, task decisions and rewards return; old intentions remain inactive. A failed write keeps the session open with retry/recovery controls. No automatic save migration is offered.

The interpreter supports bounded English and `then` clauses, not unrestricted plans, conditional reasoning or arbitrary objects. An unsupported later clause stops after earlier completed actions, with an explanation. No online or local language model runs.

Shelter remains shared, unowned and nonprivate. Home ownership, equipment progression, companion combat/care and the full expedition are not implemented. A standalone Mac app is not provided.
