"""Visible-engine tour, disposable saves, retained capture outcome."""
import os, subprocess, tempfile, json, time, sys, shutil
from pathlib import Path
from s03_evidence import record_runtime
root=Path(__file__).resolve().parents[1]
out=root/'evidence/S04'/('capture-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()))
out.mkdir(parents=True)
binary=os.environ.get('GODOT_BIN','/Applications/Godot.app/Contents/MacOS/Godot')
if subprocess.check_output([binary,'--version'],text=True).strip()!='4.6.2.stable.official.71f334935':raise SystemExit('Godot baseline mismatch')
with tempfile.TemporaryDirectory(prefix='s04-visible-') as temp:
    copy=Path(temp)/'game';shutil.copytree(root/'game',copy,ignore=shutil.ignore_patterns('.godot'))
    saves=str(Path(temp)/'saves')
    digest=record_runtime(out,copy)
    imported=subprocess.run([binary,'--headless','--path',str(copy),'--import'],text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
    (out/'fresh-import.log').write_text(imported.stdout)
    if imported.returncode or 'ERROR:' in imported.stdout:raise SystemExit('Capture import failed')
    env=dict(os.environ,S04_SAVE_DIR=saves,S04_CAPTURE_DIR=str(out))
    # Preserve gameplay-scale 1280x720 window; record actual movie dimensions from engine/ffprobe.
    args=[binary,'--path',str(copy),'--resolution','1280x720','--disable-vsync','--write-movie',str(out/'encounter.avi'),'--fixed-fps','30','--script','res://tests/visible_s04.gd']
    start=time.monotonic()
    with (out/'visible.log').open('w') as log:
        try:result=subprocess.run(args,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=240);code=result.returncode
        except subprocess.TimeoutExpired:code=124
    log=(out/'visible.log').read_text()
    passed=code==0 and 'TOUR_FINAL' in log and 'ERROR:' not in log
    (out/'result.json').write_text(json.dumps(dict(exit=code,passed=passed,runtime_manifest_sha256=digest,tool_wall_seconds=time.monotonic()-start,arguments=args),indent=2)+'\n')
    print(out,code,flush=True)
if not passed:sys.exit(1)
subprocess.run(['ffmpeg','-v','error','-i',str(out/'encounter.avi'),'-c:v','libx264','-crf','20','-pix_fmt','yuv420p','-an',str(out/'encounter.mp4')],check=True,timeout=90)
