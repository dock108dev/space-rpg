"""Normal-speed scripted ordinary journey on the exact release package."""
from pathlib import Path
import subprocess,os,time,json,plistlib,sys,hashlib
root=Path(__file__).resolve().parents[1];build=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else Path((root/'evidence/B9/latest-build.txt').read_text())
app=build/(json.loads((build/'candidate.json').read_text()).get('app_name','Space Opera RPG Personal Beta')+'.app');exe=app/'Contents/MacOS'/plistlib.loads((app/'Contents/Info.plist').read_bytes())['CFBundleExecutable']
out=build/('capture-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));out.mkdir();saves=out/'synthetic-saves';saves.mkdir();home=out/'disposable-home';home.mkdir()
env={'PATH':'/usr/bin:/bin','HOME':str(home),'TMPDIR':'/tmp','LANG':'en_US.UTF-8','B9_SAVE_DIR':str(saves),'B8_SAVE_DIR':str(saves),'B8_CAPTURE_DIR':str(out)}
results=[]
for name,mode in [('chapter','tour'),('restart','tour-restart')]:
 args=[str(exe),'--disable-vsync','--write-movie',str(out/(name+'.avi')),'--fixed-fps','30','--','--b9-check='+mode]
 start=time.monotonic()
 with (out/(name+'.log')).open('w') as log:
  try:p=subprocess.run(args,cwd='/tmp',env=env,stdout=log,stderr=subprocess.STDOUT,timeout=900);code=p.returncode
  except subprocess.TimeoutExpired:code=124
 text=(out/(name+'.log')).read_text();passed=code==0 and 'TOUR_FINAL' in text and 'ERROR:' not in text and 'FAIL ' not in text
 results.append({'stage':name,'passed':passed,'exit':code,'seconds':time.monotonic()-start,'command':args})
 (out/'results.json').write_text(json.dumps({'app_manifest_sha256':hashlib.sha256((build/'app-files.sha256').read_bytes()).hexdigest(),'control':'scripted ordinary input/controller actions; fresh generated session; no debug progression','engine_time_scale':1,'fps':30,'playback_speed':1,'results':results},indent=2))
 if not passed:print(out,flush=True);sys.exit(1)
 subprocess.run(['ffmpeg','-v','error','-i',str(out/(name+'.avi')),'-c:v','libx264','-crf','20','-pix_fmt','yuv420p','-an',str(out/(name+'.mp4'))],check=True,timeout=180)
 # Exact state comparison in a further new process, using ordinary emitted snapshot.
 with (out/(name+'-exact-continue.log')).open('w') as log:
  p=subprocess.run([str(exe),'--headless','--','--b9-check=restart'],env=env,cwd='/tmp',stdout=log,stderr=subprocess.STDOUT,timeout=90)
 assert p.returncode==0 and 'FAIL' not in (out/(name+'-exact-continue.log')).read_text()
 print(name,'PASS',out,flush=True)
(out/'concat.txt').write_text("file 'chapter.mp4'\nfile 'restart.mp4'\n")
subprocess.run(['ffmpeg','-v','error','-f','concat','-safe','0','-i',str(out/'concat.txt'),'-c','copy',str(out/'B9-chapter-and-restart.mp4')],check=True)
(out/'movie-metadata.json').write_text(subprocess.check_output(['ffprobe','-v','error','-show_entries','stream=width,height,r_frame_rate,nb_frames,duration:format=duration','-of','json',str(out/'B9-chapter-and-restart.mp4')],text=True))
