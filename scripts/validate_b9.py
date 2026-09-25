"""Qualification against the retained exported executable/PCK, never the editor.
Headless branch fixtures and ordinary renderer movie have separate evidence classes.
"""
from pathlib import Path
import os,sys,json,time,subprocess,plistlib,shutil,hashlib
ROOT=Path(__file__).resolve().parents[1]
BUILD=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else Path((ROOT/'evidence/B9/latest-build.txt').read_text())
APP=BUILD/(json.loads((BUILD/'candidate.json').read_text()).get('app_name','Space Opera RPG Personal Beta')+'.app')
EXE=APP/'Contents/MacOS'/plistlib.loads((APP/'Contents/Info.plist').read_bytes())['CFBundleExecutable']
OUT=BUILD/('qualification-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));OUT.mkdir()
SAVE=OUT/'synthetic-saves';SAVE.mkdir()
# HOME and cwd contain no project or editor; all gameplay loads from the bundle PCK.
HOME=OUT/'disposable-home';HOME.mkdir()
env={'PATH':'/usr/bin:/bin','HOME':str(HOME),'TMPDIR':'/tmp','LANG':'en_US.UTF-8','B8_SAVE_DIR':str(SAVE),'B9_SAVE_DIR':str(SAVE),'B8_CHECKS_PATH':str(OUT/'b8-checks.json'),'B8_ERGONOMICS_PATH':str(OUT/'b8-ergonomics.json'),'B2_EXTERNAL_LIVE_PID':str(os.getpid())}
for key in ['S03','S04','B2','B25','B3','B4','B5','B6','B7']:env[key+'_SAVE_DIR']=str(OUT/('FORBIDDEN-'+key))
stages=[('packaged-branches','run_b8.gd',True),('packaged-save-and-quit','restart_b8.gd',False),('packaged-separate-process-continue','restart_b8.gd',False),('packaged-sessions-failures','ergonomics_b8.gd',True),('packaged-session-continue','restart_b8.gd',False)]
results=[]
for name,script,noquit in stages:
 e=dict(env)
 if noquit:e['B2_TEST_NO_QUIT']='1'
 if name in ['packaged-sessions-failures','packaged-session-continue']:
  d=SAVE/'ergonomics';d.mkdir(exist_ok=True);e.update(B8_SAVE_DIR=str(d),B9_SAVE_DIR=str(d))
 args=[str(EXE),'--headless','--fixed-fps','60','--','--b9-check='+{'run_b8.gd':'branches','restart_b8.gd':'restart','ergonomics_b8.gd':'sessions'}[script]]
 if name=='packaged-save-and-quit':args+=['--quit-check']
 start=time.monotonic()
 try:
  p=subprocess.run(args,cwd='/tmp',env=e,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=600);code=p.returncode;log=p.stdout
 except subprocess.TimeoutExpired as error:code=124;log=str(error.stdout)
 (OUT/(name+'.log')).write_text(log)
 checks_path=OUT/('b8-checks.json' if name=='packaged-branches' else 'b8-ergonomics.json')
 passed=code==0 and 'ERROR:' not in log and 'FAIL ' not in log
 if noquit:passed=passed and checks_path.exists() and bool(json.loads(checks_path.read_text())) and all(x['passed'] for x in json.loads(checks_path.read_text()))
 results.append({'stage':name,'code':code,'passed':passed,'seconds':time.monotonic()-start,'command':args})
 print(name,passed,flush=True)
 (OUT/'results.json').write_text(json.dumps(results,indent=2))
 if not passed:break
results.append({'stage':'historical-namespace-isolation','passed':not list(OUT.glob('FORBIDDEN-*'))})
from audit_b7_arithmetic import audit
a= audit(OUT);results.append({'stage':'independent-arithmetic','passed':a['passed'],'snapshots':a['snapshots']})
(OUT/'results.json').write_text(json.dumps({'artifact':str(APP),'executable_sha256':hashlib.sha256(EXE.read_bytes()).hexdigest(),'results':results},indent=2))
print(OUT,flush=True)
sys.exit(0 if all(x['passed'] for x in results) else 1)
