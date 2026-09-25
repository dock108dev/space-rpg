"""Verify cleanup from current source exported without local evidence or caches."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    output = ROOT / 'evidence/M4' / ('run-' + stamp)
    output.mkdir(parents=True)
    results = []
    with tempfile.TemporaryDirectory(prefix='space-opera-clean-export-') as temporary:
        exported = Path(temporary)
        for folder in ('game', 'scripts', 'tests'):
            shutil.copytree(ROOT / folder, exported / folder,
                            ignore=shutil.ignore_patterns('.godot', '__pycache__', '.DS_Store'))
        assert not (exported / 'evidence').exists()
        manifest = {
            str(path.relative_to(exported)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in sorted(exported.rglob('*')) if path.is_file()
        }
        (output / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        cases = json.loads((exported / 'tests/fixtures/interface-cases.json').read_text())
        states = [case['expected'] for case in cases]
        assert any(state['journey'] == 'arrival' for state in states)
        assert any(state['location'] == 'objective' and not state['expedition']['cleared']
                   and state['care']['recruit'] == 'healthy' for state in states)
        assert any(state['location'] == 'home' and state['expedition']['reported'] for state in states)
        stages = (
            ('capture-helper', [sys.executable, '-m', 'unittest', 'discover', '-s', 'scripts/tests']),
            ('focused-source', ['bash', 'scripts/validate.sh', 'M3']),
        )
        for label, command in stages:
            run = subprocess.run(command, cwd=exported, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, text=True, timeout=180)
            (output / (label + '.log')).write_text(run.stdout)
            results.append({'stage': label, 'passed': run.returncode == 0, 'exit': run.returncode})
            if run.returncode:
                break
        if (exported / 'evidence/M3').exists():
            shutil.copytree(exported / 'evidence/M3', output / 'focused-source-evidence')
    (output / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(output)
    return 0 if all(result['passed'] for result in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
