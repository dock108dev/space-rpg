#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"
EXPECTED='4.6.2.stable.official.71f334935'
ACTUAL="$("$BIN" --version)"
if [[ "$ACTUAL" != "$EXPECTED" ]]; then
  echo "Godot version mismatch: expected $EXPECTED; received $ACTUAL" >&2
  exit 2
fi
exec "$BIN" --path "$ROOT/game" "$@"
