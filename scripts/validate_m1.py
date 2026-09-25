"""Focused source error handling checks; copied runtime, disposable synthetic state."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'evidence/M1' / datetime.now(timezone.utc).strftime('run-%Y%m%dT%H%M%S%fZ')
OUT.mkdir(parents=True)
BINARY = os.environ.get('GODOT_BIN', '/Applications/Godot.app/Contents/MacOS/Godot')
results = []
with tempfile.TemporaryDirectory(prefix='space-opera-m1-') as temp:
    temp = Path(temp)
    game = temp / 'game'
    shutil.copytree(ROOT / 'game', game, ignore=shutil.ignore_patterns('.godot'))
    manifest = {str(p.relative_to(game)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in sorted(game.rglob('*')) if p.is_file()}
    (OUT / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    env = dict(os.environ, M1_SAVE_DIR=str(temp / 'saves'), B8_SAVE_DIR=str(temp / 'sessions'), B2_TEST_NO_QUIT='1')
    for key in ['B7', 'B6', 'B5', 'B4', 'B3', 'B25', 'B2', 'S04', 'S03']:
        env[key + '_SAVE_DIR'] = str(temp / ('FORBIDDEN-' + key))
    for name, args in [('import', ['--import']), ('failures', ['--script', 'res://tests/error_handling_m1.gd'])]:
        try:
            run = subprocess.run([BINARY, '--headless', '--path', str(game), *args],
                                 env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=150)
            code, output = run.returncode, run.stdout
        except subprocess.TimeoutExpired as error:
            code = 124
            output = error.stdout or b''
            if isinstance(output, bytes): output = output.decode(errors='replace')
            output += '\nVALIDATION_TIMEOUT\n'
        (OUT / (name + '.log')).write_text(output)
        passed = code == 0 and 'ERROR:' not in output and 'FAIL ' not in output
        results.append(dict(stage=name, code=code, passed=passed))
        if not passed: break
    if all(r['passed'] for r in results):
        # Deliberately break only this disposable copy's boot target.
        scene = game / 'scenes/player_experience.tscn'
        scene.rename(scene.with_suffix('.disabled'))
        for name, extra in [('missing-scene', []), ('missing-diagnostic', ['--', '--b9-check=branches'])]:
            with (OUT / (name + '.log')).open('w') as log:
                try:
                    run = subprocess.run([BINARY, '--headless', '--path', str(game),
                                          'res://scenes/b9_start.tscn', *extra],
                                         env=dict(env, B9_SAVE_DIR=str(temp / 'diagnostics')),
                                         stdout=log, stderr=subprocess.STDOUT, timeout=30)
                    code = run.returncode
                except subprocess.TimeoutExpired:
                    code = 124
            output = (OUT / (name + '.log')).read_text()
            results.append(dict(stage=name, code=code, passed=code == 2 and 'B9_STARTUP_FAILED' in output))
    if (temp / 'saves').exists(): shutil.copytree(temp / 'saves', OUT / 'synthetic-saves')
(OUT / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print(OUT)
print(json.dumps(results))
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
