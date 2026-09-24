#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case "${1:-}" in
  S02) exec python3 "$ROOT/scripts/validate_s02.py" ;;
  S03) exec python3 "$ROOT/scripts/validate_s03.py" ;;
  S04) exec python3 "$ROOT/scripts/validate_s04.py" ;;
  B2.5) exec python3 "$ROOT/scripts/validate_b25.py" ;;
  B2) exec python3 "$ROOT/scripts/validate_b2.py" ;;
  *) echo 'Usage: scripts/validate.sh S02|S03|S04|B2' >&2; exit 2 ;;
esac
