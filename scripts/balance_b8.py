from pathlib import Path
import os,subprocess,json,tempfile,shutil,time
from s03_evidence import record_runtime
root=Path(__file__).resolve().parents[1];out=root/'evidence/B8'/('balance-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));out.mkdir(parents=True)
source=Path(os.environ['B8_BALANCE_SOURCE'])
fixture=None
for p in sorted((source/'synthetic-saves/case-1').glob('snapshot-*.json')):
 d=json.loads(p.read_text())
 if d['location']=='objective' and d['expedition']['cleared'] and not d['expedition']['objective'] and not d['expedition']['route']:
  fixture=d;break
if fixture is None:raise SystemExit('Missing ordinary route fixture')
(out/'fixture.json').write_text(json.dumps(fixture,ensure_ascii=False));(out/'fixture-source.txt').write_text(str(p.resolve()))
with tempfile.TemporaryDirectory(prefix='b8-balance-') as temp:
 game=Path(temp)/'game';shutil.copytree(root/'game',game,ignore=shutil.ignore_patterns('.godot'));record_runtime(out,game)
 binary='/Applications/Godot.app/Contents/MacOS/Godot'
 with (out/'import.log').open('w') as log:
  imported=subprocess.run([binary,'--headless','--path',str(game),'--import'],stdout=log,stderr=subprocess.STDOUT,timeout=150)
 if imported.returncode or 'ERROR:' in (out/'import.log').read_text():raise SystemExit('Import failed; see '+str(out/'import.log'))
 env=dict(os.environ,B8_SAVE_DIR=str(out/'synthetic'),B8_BALANCE_FIXTURE=str(out/'fixture.json'),B8_BALANCE_OUTPUT=str(out/'comparison.json'))
 with (out/'run.log').open('w') as log:run=subprocess.run([binary,'--headless','--fixed-fps','60','--path',str(game),'--script','res://tests/balance_b8.gd'],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=120)
print(out);raise SystemExit(run.returncode)
