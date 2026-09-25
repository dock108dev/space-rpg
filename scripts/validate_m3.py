"""Focused SSOT import, startup, validator and save round-trip checks only."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,os,shutil,subprocess,tempfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'evidence/M3'/datetime.now(timezone.utc).strftime('run-%Y%m%dT%H%M%S%fZ');OUT.mkdir(parents=True)
BINARY=os.environ.get('GODOT_BIN','/Applications/Godot.app/Contents/MacOS/Godot')
version=subprocess.check_output([BINARY,'--version'],text=True,timeout=20).strip()
if version!='4.6.2.stable.official.71f334935':raise SystemExit('Unexpected Godot version: '+version)
results=[]
# Static guards cover regressions that can otherwise silently select old behavior.
assert not (ROOT/'game/tests/debug_b8.gd').exists()
assert not (ROOT/'game/tests/font_b8.gd').exists()
assert 'B8_DEBUG_FILE' not in ''.join(p.read_text() for p in (ROOT/'game').rglob('*.gd'))
assert 'projected' not in (ROOT/'game/scripts/experience_save.gd').read_text()
assert 'save_store=create_save_store()' in (ROOT/'game/scripts/chapter_opening.gd').read_text()
for name in ['command_adventure','connected_world','preparation','owned_home','companions_care','expedition','player_experience']:
 text=(ROOT/f'game/scripts/{name}.gd').read_text();ready=text.split('func _ready()',1)[1].split('\nfunc ',1)[0]
 assert 'save_store=' not in ready and 'get_environment(' not in ready,name
with tempfile.TemporaryDirectory(prefix='space-opera-m3-launcher-') as stub_dir:
 stub=Path(stub_dir)/'godot';stub.write_text('#!/bin/bash\nif [[ "${1:-}" == --version ]]; then echo 4.6.2.stable.official.71f334935; else printf "%s\\n" "$@"; fi\n');stub.chmod(0o755)
 for extra,scene in [([], 'visual_sample'),(['--headless'],'visual_sample'),(['res://scenes/integrated_loop.tscn','--headless'],'integrated_loop')]:
  run=subprocess.run(['bash',str(ROOT/'scripts/launch_sample.sh'),*extra],env=dict(os.environ,GODOT_BIN=str(stub)),capture_output=True,text=True,check=True)
  args=run.stdout.splitlines();assert args.count('res://scenes/'+scene+'.tscn')==1 and sum(x.endswith('.tscn') for x in args)==1
 results.append(dict(stage='explicit-historical-launch-routing',passed=True,cases=3))
fixture=ROOT/'tests/fixtures/unopened-character.json'
shutil.copy2(fixture,OUT/'fixture.json')
with tempfile.TemporaryDirectory(prefix='space-opera-m3-') as tmp:
 tmp=Path(tmp);game=tmp/'game';shutil.copytree(ROOT/'game',game,ignore=shutil.ignore_patterns('.godot'))
 (OUT/'runtime-manifest.json').write_text(json.dumps({str(p.relative_to(game)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(game.rglob('*')) if p.is_file()},indent=2))
 env=dict(os.environ,B8_SAVE_DIR=str(tmp/'sessions'),B2_TEST_NO_QUIT='1',M3_FIXTURE=str(OUT/'fixture.json'),M3_CHECKS=str(OUT/'checks.json'))
 for key in ['B2','B25','B3','B4','B5','B6','B7','S03','S04']:env[key+'_SAVE_DIR']=str(tmp/('UNUSED-'+key))
 for label,args in [('import',['--import']),('focused-ssot',['--script','res://tests/ssot_m3.gd']),('normal-startup',['--quit-after','10'])]:
  p=subprocess.run([BINARY,'--headless','--path',str(game),*args],env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=120)
  (OUT/(label+'.log')).write_text(p.stdout);passed=p.returncode==0 and 'ERROR:' not in p.stdout and 'FAIL ' not in p.stdout
  results.append(dict(stage=label,passed=passed,exit=p.returncode))
  if not passed:break
 results.append(dict(stage='historical-roots-not-created',passed=not list(tmp.glob('UNUSED-*'))))
(OUT/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(OUT);print(results)
raise SystemExit(0 if all(x['passed'] for x in results) else 1)
