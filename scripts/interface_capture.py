"""Shared native interface capture orchestration; synthetic state only."""
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ENGINE = '/Applications/Godot.app/Contents/MacOS/Godot'
SIZES = ('1152x882', '1280x980')


def capture_interface(slice_name, variant, size):
    """Keep historical replay explicit; current captures need no local evidence."""
    if slice_name not in ('UI-04', 'UI-05') or size not in SIZES:
        raise ValueError('Unsupported interface slice or window size')
    if variant not in ('before', 'after') or (slice_name == 'UI-05' and variant != 'after'):
        raise ValueError('Only UI-04 supports a retained before-source replay')
    baseline = ROOT / 'evidence/UI-04/before-source/game/scripts/player_experience.gd'
    if variant == 'before' and not baseline.is_file():
        raise FileNotFoundError('UI-04 before replay needs its retained local before-source; use after for current source.')

    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = ROOT / 'evidence' / slice_name / f'{variant}-{size}-{stamp}'
    output.mkdir(parents=True)
    shutil.copy2(ROOT / 'tests/fixtures/interface-cases.json', output / 'cases.json')
    key = slice_name.replace('-', '')
    harness = 'capture_' + key.lower() + '.gd'
    with tempfile.TemporaryDirectory(prefix='space-opera-interface-') as temporary:
        temporary = Path(temporary)
        game = temporary / 'game'
        shutil.copytree(ROOT / 'game', game, ignore=shutil.ignore_patterns('.godot'))
        if variant == 'before':
            shutil.copy2(baseline, game / 'scripts/player_experience.gd')
        manifest = {
            str(path.relative_to(game)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(game.rglob('*')) if path.is_file()
        }
        (output / 'runtime-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        environment = dict(os.environ, B8_SAVE_DIR=str(temporary / 'saves'), B2_TEST_NO_QUIT='1')
        environment.update({
            key + '_OUT': str(output),
            key + '_VARIANT': variant,
            key + '_CASES': str(output / 'cases.json'),
        })
        for namespace in ('S03', 'S04', 'B2', 'B25', 'B3', 'B4', 'B5', 'B6', 'B7'):
            environment[namespace + '_SAVE_DIR'] = str(temporary / ('FORBIDDEN-' + namespace))
        stages = (
            ('import', ['--headless', '--import']),
            ('capture', ['--resolution', size, '--audio-driver', 'Dummy', '--fixed-fps', '60',
                         '--script', 'res://tests/' + harness]),
        )
        for label, arguments in stages:
            log_path = output / (label + '.log')
            with log_path.open('w') as log:
                run = subprocess.run(
                    [ENGINE, '--path', str(game), *arguments], env=environment,
                    stdout=log, stderr=subprocess.STDOUT, timeout=150,
                )
            if run.returncode or 'ERROR:' in log_path.read_text():
                raise RuntimeError('Capture failed; retained log: ' + str(log_path))
    return output
