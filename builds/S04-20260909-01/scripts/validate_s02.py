"""Bounded fresh-copy import and real-behavior validation; never clears owner caches."""
import os,subprocess,tempfile,shutil,json,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1]
out=root/'evidence/S02';out.mkdir(exist_ok=True,parents=True)
bin=os.environ.get('GODOT_BIN','/Applications/Godot.app/Contents/MacOS/Godot')
expected='4.6.2.stable.official.71f334935'
version=subprocess.check_output([bin,'--version'],text=True,timeout=20).strip()
if version!=expected:raise SystemExit('Unexpected Godot version: '+version)
results=[]
with tempfile.TemporaryDirectory(prefix='space-opera-s02-') as temp:
 copy=Path(temp)/'game';shutil.copytree(root/'game',copy,ignore=shutil.ignore_patterns('.godot'))
 for name,args in [('fresh-import',['--headless','--path',str(copy),'--import']),('behavior',['--headless','--fixed-fps','60','--path',str(copy),'--script','res://tests/run_s02.gd'])]:
  env=dict(os.environ,S02_CHECKS_PATH=str(out/'checks.json'))
  result=subprocess.run([bin,*args],cwd='/tmp',env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=120)
  (out/(name+'.log')).write_text(result.stdout)
  ok=result.returncode==0 and not any(x in result.stdout for x in ['SCRIPT ERROR:','ERROR:'])
  results.append({'name':name,'exit':result.returncode,'pass':ok})
  if not ok:break
(out/'validation.json').write_text(json.dumps({'version':version,'results':results,'scope':'S02 technical checks only; visual and owner verdict separate'},indent=2)+'\n')
print(json.dumps(results,indent=2))
raise SystemExit(0 if all(r['pass'] for r in results) else 1)
