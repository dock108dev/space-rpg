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
HAS_SCENE=false
for ARG in "$@"; do
  if [[ "$ARG" == *.tscn ]]; then HAS_SCENE=true; fi
done
if [[ "$HAS_SCENE" == false ]]; then
  set -- res://scenes/visual_sample.tscn "$@"
fi
exec "$BIN" --path "$ROOT/game" --resolution 2560x1440 "$@"
