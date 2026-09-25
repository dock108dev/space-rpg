#!/bin/bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case "${1:-}" in
  S02) exec python3 "$ROOT/scripts/validate_s02.py" ;;
  S03) exec python3 "$ROOT/scripts/validate_s03.py" ;;
  S04) exec python3 "$ROOT/scripts/validate_s04.py" ;;
  M4) exec python3 "$ROOT/scripts/validate_m4.py" ;;
  M3) exec python3 "$ROOT/scripts/validate_m3.py" ;;
  M2) exec python3 "$ROOT/scripts/validate_m2.py" ;;
  M1) exec python3 "$ROOT/scripts/validate_m1.py" ;;
  B9) exec python3 "$ROOT/scripts/validate_b9.py" ;;
  B8) exec python3 "$ROOT/scripts/validate_b8.py" ;;
  B7) exec python3 "$ROOT/scripts/validate_b7.py" ;;
  B6) exec python3 "$ROOT/scripts/validate_b6.py" ;;
  B5) exec python3 "$ROOT/scripts/validate_b5.py" ;;
  B4) exec python3 "$ROOT/scripts/validate_b4.py" ;;
  B3) exec python3 "$ROOT/scripts/validate_b3.py" ;;
  B2.5) exec python3 "$ROOT/scripts/validate_b25.py" ;;
  B2) exec python3 "$ROOT/scripts/validate_b2.py" ;;
  *) echo 'Usage: scripts/validate.sh S02|S03|S04|B2|B2.5|B3|B4|B5|B6|B7|B8|B9|M1|M2|M3|M4' >&2; exit 2 ;;
esac
