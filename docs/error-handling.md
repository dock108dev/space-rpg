# Save errors and recovery

## Snapshot commit and loading

Snapshots are immutable, schema-validated JSON. A writer lock serializes creation. A successful temporary write/flush and rename commits a snapshot. Failed snapshot writes preserve transaction rollback; malformed, interrupted and snapshot-shaped directory entries still reserve their sequence numbers.

Loading chooses the highest valid sequence and reports skipped oversized, unreadable, malformed or unsupported entries without deleting them. Missing history means first use; an unreadable directory produces an access error rather than silently appearing empty. Absence is established through a readable ancestor listing when platform open errors cannot distinguish missing files from denied access.

## Interrupted writers

Writer markers are flushed before snapshot creation. Restore save access refuses a live writer or unknown process status. Fresh missing/partial/malformed markers get a ten-second settling interval. Old malformed markers and confirmed dead writers are archived by rename, preserving interrupted material.

After a committed snapshot, a cleanup problem remains a warning rather than changing the operation into a failed transaction. This prevents retrying an already committed reward or action as though it never occurred.

## Character selection and partial success

Continue selection rejects invalid, oversized, linked or unreadable pointers with an explicit notice. Earlier characters provides explicit selection rather than silently choosing another character. Starting a new character preserves prior sessions.

If the snapshot commits but updating `current-session.txt` fails, the game reports that the chapter was saved but Continue selection did not update. Save and quit leaves the session open so the player can retry or choose the character explicitly on a later launch.

## Preferences and startup

Text-size preferences are optional. Missing preferences use defaults. Read/parse failures warn and keep a usable interface; a failed preference write applies the size for the current session and displays a warning. Chapter saving is independent of this optional setting.

The exported bootstrap reports `B9_STARTUP_FAILED` and exits with code 2 when the required player scene or selected diagnostic cannot load. An unsupported diagnostic request also exits with code 2. Ordinary source validation checks startup separately from save assertions.

## Player actions

When saving fails, the session remains open. Use Pause to retry saving or Restore save access for an interrupted writer. Do not delete a live writer's lock. Restore folder access before retrying a permission failure. [Security](security.md) explains trusted roots and symlink limits; [configuration](development.md) identifies the active save directory.
