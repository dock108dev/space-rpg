"""Retained, isolated macOS export. Never overwrites an attempt or touches owner saves."""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,sys,time,zipfile,stat
ROOT=Path(__file__).resolve().parents[1]
ENGINE=Path('/Applications/Godot.app/Contents/MacOS/Godot')
TEMPLATE=Path.home()/'Library/Application Support/Godot/export_templates/4.6.2.stable/macos.zip'
VERSION='4.6.2.stable.official.71f334935'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def manifest(base,paths):
 return ''.join(f'{sha(p)}  {p.relative_to(base)}\n' for p in sorted(paths) if p.is_file() and not p.is_symlink())
def archive(app,out):
 with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for p in sorted([app,*app.rglob('*')]):
   name=str(p.relative_to(app.parent))+('/' if p.is_dir() else '')
   i=zipfile.ZipInfo(name,(2026,9,24,0,0,0));i.create_system=3;i.external_attr=p.lstat().st_mode<<16;i.compress_type=zipfile.ZIP_DEFLATED
   z.writestr(i, b'' if p.is_dir() else os.readlink(p).encode() if p.is_symlink() else p.read_bytes())
def main(evidence="B9", project="project-b9.godot", preset="export_presets.cfg", app_name="Space Opera RPG Personal Beta", preset_name="B9 Personal Mac"):
 attempt=ROOT/'evidence'/evidence/('build-'+time.strftime('%Y%m%dT%H%M%SZ',time.gmtime()));attempt.mkdir(parents=True)
 (ROOT/'evidence'/evidence/'latest-build.txt').write_text(str(attempt))
 source=[p for folder in ['game','scripts','docs','packaging','assets'] for p in (ROOT/folder).rglob('*') if p.is_file() and not any(x in p.parts for x in ['.godot','__pycache__','.DS_Store'])]
 source += [p for p in ROOT.iterdir() if p.is_file()]
 (attempt/'source-art.sha256').write_text(manifest(ROOT,source))
 (attempt/'git-status.txt').write_text(subprocess.check_output(['git','status','--porcelain=v1','--untracked-files=all'],cwd=ROOT,text=True))
 game=attempt/'staging/game';shutil.copytree(ROOT/'game',game,ignore=shutil.ignore_patterns('.godot','.DS_Store'))
 shutil.copy2(ROOT/'packaging'/project,game/'project.godot');shutil.copy2(ROOT/'packaging'/preset,game/'export_presets.cfg')
 # Adapt test lifecycle only, never gameplay: release export uses a guarded Node
 # diagnostic instead of editor-only --script SceneTree entry points.
 diag=game/'diagnostics';diag.mkdir()
 shutil.copy2(ROOT/'packaging/diagnostic_base.gd',diag/'base.gd')
 for test in (game/'tests').glob('*.gd'):
  content=test.read_text().replace('extends SceneTree','extends "res://diagnostics/base.gd"').replace('res://tests/','res://diagnostics/').replace('func _initialize()', 'func _ready()').replace('await process_frame','await get_tree().process_frame')
  (diag/test.name).write_text(content)
 version=subprocess.check_output([str(ENGINE),'--version'],text=True).strip();assert version==VERSION,version
 app=attempt/(app_name+'.app')
 results=[]
 for label,args in [('import',['--headless','--path',str(game),'--import']),('export',['--headless','--path',str(game),'--export-release',preset_name,str(app)])]:
  proc=subprocess.run([str(ENGINE),*args],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=300)
  (attempt/(label+'.log')).write_text(proc.stdout);results.append({'stage':label,'code':proc.returncode,'command':[str(ENGINE),*args]})
  if proc.returncode or 'ERROR:' in proc.stdout:raise RuntimeError(label+' failed; retained '+str(attempt))
 # Official archive contains universal binaries only. Thin the exported executable
 # before final signing/identity; never alter the installed template.
 import plistlib
 plist=plistlib.loads((app/'Contents/Info.plist').read_bytes())
 exe=app/'Contents/MacOS'/plist['CFBundleExecutable']
 subprocess.run(['/Library/Developer/CommandLineTools/usr/bin/lipo',str(exe),'-thin','arm64','-output',str(exe)+'.arm64'],check=True)
 os.replace(str(exe)+'.arm64',exe);exe.chmod(0o755)
 for name in ['GODOT-LICENSE.txt','GODOT-COPYRIGHT.txt']:shutil.copy2(ROOT/'packaging'/name,app/'Contents/Resources'/name)
 subprocess.run(['codesign','--force','--deep','--sign','-','--timestamp=none',str(app)],check=True)
 for label,args in [('signature' ,['codesign','--verify','--deep','--strict','--verbose=2',str(app)]),('signing-info',['codesign','-dvvv',str(app)]),('gatekeeper',['spctl','--assess','--type','execute','--verbose=4',str(app)])]:
  proc=subprocess.run(args,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True);(attempt/(label+'.log')).write_text(proc.stdout);results.append({'stage':label,'code':proc.returncode})
 (attempt/'app-files.sha256').write_text(manifest(app,app.rglob('*')))
 (attempt/'staged-runtime.sha256').write_text(manifest(game,[p for p in game.rglob('*') if '.godot' not in p.parts]))
 archive(app,attempt/(app_name+'.zip'))
 meta={'app_name':app_name,'attempt':attempt.name,'status':'exported; qualification pending','source_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),'engine':version,'engine_sha256':sha(ENGINE),'template_sha256':sha(TEMPLATE),'source_manifest_sha256':sha(attempt/'source-art.sha256'),'app_manifest_sha256':sha(attempt/'app-files.sha256'),'archive_sha256':sha(attempt/(app_name+'.zip')),'results':results}
 (attempt/'candidate.json').write_text(json.dumps(meta,indent=2)+'\n');print(attempt)
if __name__=='__main__':main()
