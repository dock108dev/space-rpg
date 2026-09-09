"""Import fresh runtime and exercise actual S04 scene with disposable saves."""
import os, subprocess, tempfile, shutil, json, time
from pathlib import Path
from s03_evidence import record_runtime
root=Path(__file__).resolve().parents[1]
out=root/'evidence/S04'/('run-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()))
out.mkdir(parents=True)
binary=os.environ.get('GODOT_BIN','/Applications/Godot.app/Contents/MacOS/Godot')
version=subprocess.check_output([binary,'--version'],text=True,timeout=20).strip()
if version!='4.6.2.stable.official.71f334935':raise SystemExit('Unexpected Godot version: '+version)
results=[]
with tempfile.TemporaryDirectory(prefix='space-opera-s04-') as tmp:
    copy=Path(tmp)/'game'
    shutil.copytree(root/'game',copy,ignore=shutil.ignore_patterns('.godot'))
    digest=record_runtime(out,copy)
    env=dict(os.environ,S03_SAVE_DIR=str(Path(tmp)/'s03-saves'),S04_SAVE_DIR=str(Path(tmp)/'saves'),S04_CHECKS_PATH=str(out/'s04-checks.json'),S03_CHECKS_PATH=str(out/'checks.json'),S02_CHECKS_PATH=str(out/'s02-checks.json'))
    stages=[('fresh-import',['--headless','--path',str(copy),'--import']),('s04-behavior',['--headless','--fixed-fps','60','--path',str(copy),'--script','res://tests/run_s04.gd']),('s04-full-restart',['--headless','--fixed-fps','60','--path',str(copy),'--script','res://tests/restart_s04.gd']),('s03-behavior',['--headless','--fixed-fps','60','--path',str(copy),'--script','res://tests/run_s03.gd']),('s02-regression',['--headless','--fixed-fps','60','--path',str(copy),'--script','res://tests/run_s02.gd'])]
    for name,args in stages:
        start=time.monotonic()
        result=subprocess.run([binary,*args],env=env,cwd='/tmp',text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=150)
        (out/(name+'.log')).write_text(result.stdout)
        ok=result.returncode==0 and not any(s in result.stdout for s in ['SCRIPT ERROR:','ERROR:'])
        results.append(dict(name=name,exit=result.returncode,passed=ok,tool_wall_seconds=time.monotonic()-start))
        if not ok:break
    if (Path(tmp)/'saves').exists():shutil.copytree(Path(tmp)/'saves',out/'validation-saves')
(out/'results.json').write_text(json.dumps(dict(version=version,runtime_manifest_sha256=digest,results=results),indent=2)+'\n')
print(out);print(json.dumps(results,indent=2))
raise SystemExit(0 if all(x['passed'] for x in results) else 1)
