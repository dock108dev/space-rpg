# Relay receipt — B7 chapter guide

Double-click **Launch B7.command**. Requires installed Godot 4.6.2 Standard. Saves are isolated in `dev-state/B7-practice-v1` (`B7_SAVE_DIR` override). B6 saves and earlier candidates are untouched; there is no migration. This is the complete playable source chapter, not the standalone Mac app planned for B9.

## Start and prepare

Play the ordinary opening: try the three powers, choose one, approach the package, survive the assessment, collect it and reach shelter. Choose a shelter reward. Join the traveler, decline, or leave them waiting; all are viable.

`go to hub then go to bench then claim preparation kit` gives three base items and 20 material once. `equip guard weave` protects against expedition pressure; `equip lens` increases shot/blast impact; `equip rig` increases chosen-dash distance. One slot. Improvements cost four each at the bench; test your chosen power at the harmless approach range before improving it.

Useful optional work:

- `ask pet to fetch supplies` physically retrieves one bundle and chews its label; `go to supplies then collect supplies` preserves the label. At the bench, `exchange supply bundle` explicitly converts it to four material once.
- `go to access then restore access` opens the existing hub shortcut. No currency.
- At the approach, `go to marker then survey the approach` records the dry drainage latch. No currency.
- After a real pet cache/supply retrieval, `go to range then teach pet cover fetch` teaches the existing cover behavior. The healthy trained pet uses it automatically on End turn when a plate is reachable.

At the hub board, `file settlement claim` earns the private home and ten settling material after orientation/kit. `go home`; buy and place chair/lamp/shelf, improve the locker, deposit or withdraw explicitly. Home is optional for expedition access. `rest` at home, or at the shelter desk, freely restores only the protagonist.

## Take the assignment

`What am I preparing for?` explains the relay assignment and its **eight-material payment only after the return report**. `What do we know about the route?` explains current choices. `Check our equipment and condition` inspects actual preparation without spending or acting.

At the approach, `enter expedition` walks to the east barrier and enters the relay yard. Entry stops further queued work for a new decision. The north range remains harmless; the containment breach remains separate optional repeatable danger.

The relay yard contains two different danger situations:

| Situation | Actual play |
|---|---|
| West-court warden | 12 health. Four AP per turn. Cardinal move/guard/shield/dash costs 1; shot/blast costs 2. Bolt range 6, blast 4, clear sight required. `shoot creature`, `use blast`, `raise shield`, `dash right`, `guard`, `end turn`. Power commands require your chosen power. |
| Induction crossing | After the warden, choose the short live lane or longer dry passage. Movement through either energized central square causes a two-pressure pulse per move/dash. Weave/guard/shield reduces protagonist damage; exposed companions suffer recoverable injury/downing. Dry passage avoids these pulses. Removing the core shuts the crossing down. |

End turn gives the healthy joined traveler one actual support shot, then the healthy trained pet its reachable cover fetch, then lets the warden strike. The first exposed warden pulse injures the pet; later pulses can down the traveler. No turns pass automatically. Injured pets cannot fetch; downed travelers cannot shoot. No permanent party death.

A base weave and ordinary shots can clear the warden without optional tasks or a recruit. Lens/improvements speed the fight; weave/shield prevent damage; dash changes actual movement. Check AP: an attempt without enough AP stops and reports partial completion. `end turn` deliberately stops any queued plan so you can read the response.

## Choose and physically follow a crossing route

| Command | Requirement and tradeoff |
|---|---|
| `take the live lane` | No optional preparation. Short central crossing. Readied protection is consumed on the next exposure; passive weave applies to each pulse. A dash crosses multiple cells for one AP and at most one pulse. Every cell must be clear: a five-square dash from (5,3) would hit the solid core at (10,3), so start one square farther west. |
| `take the drainage route` | Completed survey. Opens the long dry north passage immediately, avoiding the local wheel detour and crossing injuries. |
| `go to wheel`, then `turn isolation wheel`, then `take the maintenance route` | No survey required. A local detour opens the same longer dry passage for free. |

For either dry route, use `go to drainage` then `go to core`. With the live route selected, `go to core` follows the short central lane. Walks stop when AP runs out: `end turn`, then repeat your destination. After the warden there is no enemy pulse on End turn. Questions and selecting a route cost no AP/material; actual walking still does. Direct movement uses the same floor, AP and exposure rules.

At the east dais, `recover routing core` takes one real objective and darkens the crossing. No material is paid yet. `inspect core` / `inspect that` describe the actual socket state.

## Retreat, care and retry

`retreat` gathers everyone into the insulated rescue sling and follows a checked exit path to the approach. Impaired members are carried. If floor paths are blocked, `call evacuation` explicitly extracts the group overhead. Waiting travelers remain in shelter. Neither escape heals, pays or resets the warden. Cleared danger, partial warden health, opened wheel, recovered core and report persist.

From the approach, `go to hub then go to shelter then go to desk`. Paid care: `treat the pet` and `help the companion recover`, **two carried material each**. Stored money is never silently spent; withdraw at the home locker first. With no money, `begin assisted pet care` or `begin assisted companion care`, followed by `continue assisted care` twice. Each round takes six attended seconds, is pausable, and never advances offline. The second round restores capability. Cancel explicitly before traveling away mid-care. This free route works repeatedly.

Protagonist defeat uses Continue to restore the latest living snapshot with its actual conditions, progress and funds. No free refill. On retry, use the same approach barrier; the warden does not regenerate or award farmable salvage.

## Return and finish

After taking the core:

`retreat then go to hub then go to board then file relay report`

The board accepts the core, records the shelter's district address and pays eight carried material once. `What did we accomplish?` shows the chapter result: objective, route, optional task/retrieval outcomes, support/retreat counts and party condition at filing. Later care changes current condition while preserving that historical report. `What remains unfinished?` also lists resumable local work.

This closes the delivered opening chapter. Home, care, optional work and cleared-yard travel remain usable; wider freedom/campaign outcomes are not implemented. Re-entry and Continue do not replay rewards or dialogue effects.

`return home` from the yard first rescues the party and then walks the connected route. `save and quit`, relaunch, Continue restores exact state without an active old command. Pause/Stop, text focus and direct control reclaim remain supported. Failed writes roll back the affected transaction and preserve prior valid snapshots.

Known limits: bounded offline English, no audio, rigid illustrated cutouts, hovering pet, simple downed pose/tethered party travel and mixed raster/vector art. Names, eight-material reward, AP and damage are production tuning, not owner-approved balance. B8 owns character setup and full-chapter polish; B9 standalone delivery; B10 owner beta acceptance.
