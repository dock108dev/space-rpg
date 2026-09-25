from pathlib import Path
import os,subprocess,json,tempfile,shutil,time
from s03_evidence import record_runtime
root=Path(__file__).resolve().parents[1]
out=root/'evidence/B8'/('presentation-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));out.mkdir(parents=True)
cases=Path(os.environ['B8_PRESENTATION_CASES']).resolve()
binary='/Applications/Godot.app/Contents/MacOS/Godot'
with tempfile.TemporaryDirectory(prefix='b8-presentation-') as temp:
 game=Path(temp)/'game';shutil.copytree(root/'game',game,ignore=shutil.ignore_patterns('.godot'))
 record_runtime(out,game)
 with (out/'import.log').open('w') as log:
  imported=subprocess.run([binary,'--headless','--path',str(game),'--import'],stdout=log,stderr=subprocess.STDOUT,timeout=150)
 if imported.returncode or 'ERROR:' in (out/'import.log').read_text():raise SystemExit('Import failed; see '+str(out/'import.log'))
 for variant in ['before','after']:
  env=dict(os.environ,B8_PRESENTATION_DIR=str(out),B8_PRESENTATION_VARIANT=variant,B8_PRESENTATION_CASES=str(cases),B8_SAVE_DIR=str(out/'synthetic-sessions'),B2_TEST_NO_QUIT='1')
  with (out/(variant+'.log')).open('w') as log:
   run=subprocess.run([binary,'--path',str(game),'--resolution','1152x882','--disable-vsync','--audio-driver','Dummy','--fixed-fps','30','--script','res://tests/presentation_b8.gd'],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=360)
  if run.returncode or 'ERROR:' in (out/(variant+'.log')).read_text():raise SystemExit('Failed '+variant)
print(out)
