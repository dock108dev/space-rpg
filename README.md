# Space Opera RPG

An illustrated single-player command adventure built with Godot. Explore an unfamiliar world with a pet, choose a power, retrieve a package, reach shelter and meet a potential companion. Travel onward through a district hub and expedition approach, recover supplies, restore local access and record a survey. Typed commands, contextual choices and direct movement operate the same game world.

The interpreter is offline and deterministic. It supports bounded English requests and exact movement, not unrestricted natural-language plans. No language model or online service runs.

## Play from source

Requires Godot **4.6.2 Standard**. On macOS, install it at `/Applications/Godot.app`, then run from the repository root:

```sh
bash scripts/launch_b3.sh
```

You can also double-click [Launch B3.command](Launch%20B3.command). Set `GODOT_BIN` to use another engine path. This launches the command-adventure opening; it is a source prototype, not a standalone app bundle.

Type an intention and press Return, or select a contextual choice. WASD/arrows move, E interacts, Enter ends a combat turn and Escape pauses. Leave text input before using movement keys. Stop cancels unfinished work. Save and quit is available in Pause; Continue restores the last successful save.

See the [player guide](docs/B3-player-guide.md) and [command/save contract](docs/B3-runtime-contract.md). Development saves default to `dev-state/B3-practice-v1`; `B3_SAVE_DIR` overrides the location.

## Development

Requires Python 3 in addition to Godot:

```sh
scripts/validate.sh B3
```

The connected-world prototype includes optional tasks and travel between the concourse, shelter, district hub and expedition approach. Equipment progression, an owned home, companion care and the full expedition remain unfinished. No standalone release is provided.

- [Current design](docs/current-design.md) and [world rules](docs/world-rules.md)
- [UI design](docs/ui-design.md) and [art direction](docs/art-direction.md)
- [Validation](docs/validation.md)

Earlier prototypes, delivery records and playtests remain in the repository. Their launchers and save formats are separate from the command-adventure opening.
