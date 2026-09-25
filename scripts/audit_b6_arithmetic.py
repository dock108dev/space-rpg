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
        h = data['home']
        earned += 10 if h['owned'] else 0
        furnishing_spend = 2 * sum(v >= 0 for v in h['furniture'].values())
        storage_spend = 4 if h['storage'] else 0
        expected = earned - gear_spend - power_spend - furnishing_spend - storage_spend - h['stored'] - 2 * data['care']['paid']
        placement = [int(v) for v in h['furniture'].values() if v > 0]
        items_ok = set(h['furniture']) == {'chair', 'lamp', 'shelf'} and len(placement) == len(set(placement))
        items_ok = items_ok and all(v in (-1,0,1,2,3,4) for v in h['furniture'].values())
        rows.append(dict(furnishing_count=sum(v >= 0 for v in h['furniture'].values()),
                         placed_count=len(placement), stored_material=h['stored'],
                         furnishing_spend=furnishing_spend, storage_spend=storage_spend,
                         held_bundle=int(data['tasks']['supplies']=='completed' and not p['bundle_exchanged']),
                         item_quantities_valid=items_ok, file=str(path.relative_to(root)), earned=earned,
                         gear_spend=gear_spend, power_spend=power_spend,
                         expected=expected, actual=p['material'], passed=expected == p['material'] and items_ok))
    required = dict(start=20, one_gear=4, chosen_power=4, remaining=12,
                    all_three_gear=12, all_gear_and_power_remaining=4,
                    optional_bundle=4, access_reward=0, survey_reward=0,
                    settlement_award=10, furniture_total=6, storage_cost=4, maximum_B4_plus_B5_remaining=4, representative_remaining=12, care_price=2, assisted_cost=0)
    result = dict(passed=bool(rows) and all(r['passed'] for r in rows),
                  snapshots=len(rows), excluded_malformed_recovery_samples=excluded,
                  independent_required_route=required, rows=rows)
    (root / 'independent-arithmetic.json').write_text(json.dumps(result, indent=2)+'\n')
    return result

if __name__ == '__main__':
    result = audit(Path(sys.argv[1]))
    print(json.dumps({k:v for k,v in result.items() if k != 'rows'}, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
