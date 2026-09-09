#!/usr/bin/env python3
"""Check the S01 documentation packet; never launch an engine or modify game state."""
import argparse
import hashlib
import json
import re
from datetime import datetime
from pathlib import Path
from urllib.parse import unquote
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[2]
TRACKER = ROOT.parent / 'space_opera_rpg_next_steps.md'
parser = argparse.ArgumentParser()
parser.add_argument('--record', action='store_true', help='Write this document-check result')
args = parser.parse_args()
checks = []
def check(name, passed, detail):
    checks.append({'check': name, 'result': 'PASS' if passed else 'FAIL', 'detail': detail})

files = [ROOT/'README.md', ROOT/'AGENTS.md', *sorted((ROOT/'docs').rglob('*.md')),
         ROOT/'evidence/README.md', ROOT/'evidence/S01/README.md',
         ROOT/'evidence/S01/sources.md', TRACKER]
broken = []
link_count = 0
for path in files:
    content = re.sub(r'```.*?```', '', path.read_text(), flags=re.S)
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', content):
        target = target.strip('<>')
        if re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target) or target.startswith('#'):
            continue
        relative = unquote(target.split('#')[0])
        if not relative:
            continue
        link_count += 1
        if not (path.parent/relative).exists():
            broken.append(f'{path.relative_to(ROOT) if path.is_relative_to(ROOT) else path.name}: {target}')
check('local_markdown_file_links', not broken, {'count': link_count, 'broken': broken, 'anchors': 'not validated'})
s01=(ROOT/'docs/slices/S01-feasibility.md').read_text()
s02=(ROOT/'docs/slices/S02-visual-sample.md').read_text()
board=(ROOT/'docs/slices/README.md').read_text()
check('s01_gate_tasks', s01.count('- [x]') == 5 and 'Status: **COMPLETE' in s01, 'Five S01 tasks marked complete; decision gate only')
check('slice_transition', 'READY — NOT STARTED | S01' in board and '| WAITING | S02' in board and 'Status: **READY — NOT STARTED**' in s02 and 'IN PROGRESS' not in board, 'No active slice; S02 ready; S03 waiting')
check('current_handoff', '# Ready continuation task — S02' in (ROOT/'docs/next-task.md').read_text() and 'S01 COMPLETE' in TRACKER.read_text()[:500], 'Local handoff and Desktop current state agree')
artifacts=[str(p.relative_to(ROOT)) for p in ROOT.rglob('*') if p.is_file() and (p.name=='project.godot' or p.suffix in {'.gd','.tscn','.tres','.kra'})]
check('s02_not_scaffolded', not artifacts and not (ROOT/'game').exists() and not (ROOT/'source-assets').exists(), {'implementation_files':artifacts})
check('no_project_local_git', not (ROOT/'.git').exists(), 'Parent Desktop Git exists; no dedicated project repository created')
check('reference_png', (ROOT/'docs/reference/visual-comparison.png').read_bytes()[:8] == b'\x89PNG\r\n\x1a\n', {'sha256':hashlib.sha256((ROOT/'docs/reference/visual-comparison.png').read_bytes()).hexdigest(), 'visual_inspection':'recorded separately in S01 evidence'})
check('s02_required_sections', all(term in s02 for term in ['Technical','Visual readability','Production repeatability','Owner feedback','Effort checkpoints','Repeatable asset recipe','scripts/validate.sh','cabinet B','No actual encounter deadline']), 'Scope, recipe, validation and separate evidence dimensions present; substantive manual review still required')
approach=(ROOT/'docs/technical-approach.md').read_text()
used=set(re.findall(r'\[([GDKA]\d+)\](?!:)',approach))
defined=set(re.findall(r'^\[([GDKA]\d+)\]:',approach,re.M))
check('official_source_references', used <= defined, {'used':len(used),'unresolved':sorted(used-defined)})
result={'scope':'S01 documentation only; not runtime/visual/owner tests',
        'checked_at':datetime.now(ZoneInfo('America/New_York')).isoformat(),
        'result':'PASS' if all(x['result']=='PASS' for x in checks) else 'FAIL',
        'checks':checks}
if args.record:
    (ROOT/'evidence/S01/document-check.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
raise SystemExit(0 if result['result']=='PASS' else 1)
