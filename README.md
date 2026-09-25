# Space Opera RPG

An offline, single-player Mac command adventure with illustrated spatial play. Create a character, choose a power, find shelter, prepare a private home, care for companions and recover a relay core. Typed commands and contextual choices control movement and turn-based encounters.

## Quickstart

Install [Godot 4.6.2 Standard for macOS](https://github.com/godotengine/godot-builds/releases/tag/4.6.2-stable). Place Godot.app in Applications, then run from this repository:

```sh
bash scripts/launch_b8.sh
```

Alternatively, open `game/project.godot` in Godot and Run. No account, model download or online service is required. Python is needed for development checks, not play.

Create a character and try `look around`, `inspect package` or `move 2 up and 3 right`. Help explains commands, Stop cancels queued work, and Escape opens Pause and Save and quit. [Player guide](docs/player-guide.md).

## Development

With Python 3.14.5 and the same Godot installation:

```sh
bash scripts/validate.sh M4
```

This checks an isolated source copy with synthetic data. [Setup and configuration](docs/development.md) · [Architecture](docs/ssot.md) · [Testing](docs/validation.md) · [CI](docs/ci.md) · [Documentation index](docs/README.md).

## Support limits

The supported target is a personal macOS desktop game with a minimum content window of 1152×882. The command interpreter recognizes defined actions and named targets, not arbitrary goals. Presentation is silent. There is no multiplayer, cloud save, automatic save migration or offline progression. Current CI validates source; it does not publish an installer or establish packaged release readiness.
