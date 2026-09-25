"""Exact-package checks with fresh synthetic roots; no owner profile access."""
from pathlib import Path
import json, os, plistlib, shutil, subprocess, sys
from datetime import datetime, timezone
ROOT=Path(__file__).resolve().parents[1]
build=Path(sys.argv[1]).resolve()
app=build/(json.loads((build/'candidate.json').read_text())['app_name']+'.app')
exe=app/'Contents/MacOS'/plistlib.loads((app/'Contents/Info.plist').read_bytes())['CFBundleExecutable']
out=build/('interface-security-'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ'));out.mkdir()
results=[]
for mode,size in [('errors',None),('security',None),('platform',None),('interface','1152x882'),('interface','1280x980')]:
 stage=out/(mode+('-'+size if size else ''));stage.mkdir();saves=stage/'synthetic-sessions';saves.mkdir();home=stage/'disposable-home';home.mkdir()
 env=dict(PATH='/usr/bin:/bin',HOME=str(home),TMPDIR='/tmp',LANG='en_US.UTF-8',B8_SAVE_DIR=str(saves),B9_SAVE_DIR=str(saves),M1_SAVE_DIR=str(stage/'error-fixtures'),M2_SAVE_DIR=str(stage/'security-fixtures'),B2_TEST_NO_QUIT='1',B9_PLATFORM_OUTPUT=str(stage/'platform.json'),UI05_OUT=str(stage),UI05_VARIANT='after',UI05_CASES=str(stage/'cases.json'))
 for key in ['S03','S04','B2','B25','B3','B4','B5','B6','B7']:env[key+'_SAVE_DIR']=str(stage/('FORBIDDEN-'+key))
 if mode=='errors':(saves/'current-session.txt').write_text('invalid')
 if mode=='security':(saves/'presentation.cfg').write_text('x'*4097)
 if mode=='interface':shutil.copy2(ROOT/'tests/fixtures/interface-cases.json',stage/'cases.json')
 args=[str(exe),*(['--resolution',size] if size else ['--headless']),'--fixed-fps','60','--','--b9-check='+mode]
 with (stage/'run.log').open('w') as log:
  p=subprocess.run(args,cwd='/tmp',env=env,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 log=(stage/'run.log').read_text();passed=p.returncode==0 and 'ERROR:' not in log and 'FAIL ' not in log and not list(stage.glob('FORBIDDEN-*'))
 if mode=='interface':passed=passed and all(c['passed'] for c in json.loads((stage/'checks.json').read_text()))
 results.append(dict(stage=stage.name,passed=passed,exit=p.returncode,command=args));print(stage.name,passed,flush=True)
 (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
 if not passed:raise SystemExit('Failed '+str(stage))
print(out)
