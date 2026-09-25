"""Independent arithmetic over saved original inputs; imports no game rules."""
import json
from pathlib import Path
import sys

def audit(root):
    rows, excluded = [], []
    for path in sorted((root / 'synthetic-saves').rglob('snapshot-*.json')):
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError:
            excluded.append(str(path.relative_to(root)))
            continue  # Intentionally corrupt recovery specimens remain retained.
        p = data['progression']
        earned = (20 if p['kit_claimed'] else 0) + (4 if p['bundle_exchanged'] else 0)
        gear_spend = sum(4 for tier in p['levels'].values() if tier == 1)
        power_spend = 4 if p['power_level'] == 1 else 0
        expected = earned - gear_spend - power_spend
        rows.append(dict(file=str(path.relative_to(root)), earned=earned,
                         gear_spend=gear_spend, power_spend=power_spend,
                         expected=expected, actual=p['material'], passed=expected == p['material']))
    required = dict(start=20, one_gear=4, chosen_power=4, remaining=12,
                    all_three_gear=12, all_gear_and_power_remaining=4,
                    optional_bundle=4, access_reward=0, survey_reward=0,
                    later_planning_only=4+3*2+1)
    result = dict(passed=bool(rows) and all(r['passed'] for r in rows),
                  snapshots=len(rows), excluded_malformed_recovery_samples=excluded,
                  independent_required_route=required, rows=rows)
    (root / 'independent-arithmetic.json').write_text(json.dumps(result, indent=2)+'\n')
    return result

if __name__ == '__main__':
    result = audit(Path(sys.argv[1]))
    print(json.dumps({k:v for k,v in result.items() if k != 'rows'}, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
