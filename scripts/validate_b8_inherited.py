"""Run inherited entry points in a disposable project; preserve historical evidence."""
from pathlib import Path
import subprocess,tempfile,shutil,json,time
root=Path(__file__).resolve().parents[1]
out=root/'evidence/B8'/('inherited-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));out.mkdir(parents=True)
results=[]
with tempfile.TemporaryDirectory(prefix='b8-inherited-') as tmp:
 p=Path(tmp)
 for folder in ['game','scripts']:shutil.copytree(root/folder,p/folder,ignore=shutil.ignore_patterns('.godot','__pycache__'))
 for f in root.glob('Launch*.command'):shutil.copy2(f,p/f.name)
 for stage in ['B7','B6','B5','B4','B3','B2.5','B2','S04','S03','S02']:
  run=subprocess.run(['bash',str(p/'scripts/validate.sh'),stage],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=600)
  (out/(stage+'.log')).write_text(run.stdout)
  results.append({'stage':stage,'exit':run.returncode,'passed':run.returncode==0})
 shutil.copytree(p/'evidence',out/'retained')
(out/'results.json').write_text(json.dumps(results,indent=2))
print(out);print(json.dumps(results,indent=2))
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
