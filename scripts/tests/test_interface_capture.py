"""Check routing and isolation without running native windows or owner sessions."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import interface_capture


class InterfaceCaptureTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / 'game/scripts').mkdir(parents=True)
        (self.root / 'game/scripts/player_experience.gd').write_text('current source')
        (self.root / 'tests/fixtures').mkdir(parents=True)
        (self.root / 'tests/fixtures/interface-cases.json').write_text('[]')
        self.root_patch = patch.object(interface_capture, 'ROOT', self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)

    def test_current_routes_and_disposable_state(self):
        for slice_name in ('UI-04', 'UI-05'):
            with self.subTest(slice=slice_name), patch.object(interface_capture.subprocess, 'run') as run:
                run.return_value = subprocess.CompletedProcess([], 0)
                output = interface_capture.capture_interface(slice_name, 'after', '1152x882')
                self.assertEqual(run.call_count, 2)
                arguments, options = run.call_args
                key = slice_name.replace('-', '')
                self.assertIn('res://tests/capture_' + key.lower() + '.gd', arguments[0])
                environment = options['env']
                self.assertEqual(environment[key + '_CASES'], str(output / 'cases.json'))
                self.assertNotEqual(environment['B8_SAVE_DIR'], environment['B7_SAVE_DIR'])
                self.assertFalse(Path(environment['B8_SAVE_DIR']).parent.exists())
                self.assertIn('scripts/player_experience.gd', json.loads((output / 'runtime-manifest.json').read_text()))

    def test_missing_historical_baseline_fails_before_capture(self):
        with self.assertRaisesRegex(FileNotFoundError, 'retained local before-source'):
            interface_capture.capture_interface('UI-04', 'before', '1152x882')
        self.assertFalse((self.root / 'evidence').exists())

    def test_historical_replay_uses_baseline(self):
        baseline = self.root / 'evidence/UI-04/before-source/game/scripts/player_experience.gd'
        baseline.parent.mkdir(parents=True)
        baseline.write_text('historical source')
        def inspect(arguments, **options):
            game = Path(arguments[arguments.index('--path') + 1])
            self.assertEqual((game / 'scripts/player_experience.gd').read_text(), 'historical source')
            return subprocess.CompletedProcess(arguments, 0)
        with patch.object(interface_capture.subprocess, 'run', side_effect=inspect):
            interface_capture.capture_interface('UI-04', 'before', '1280x980')

    def test_failure_retains_log_and_rejects_unsupported_mode(self):
        with patch.object(interface_capture.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1)):
            with self.assertRaisesRegex(RuntimeError, 'retained log'):
                interface_capture.capture_interface('UI-05', 'after', '1280x980')
        self.assertTrue(list((self.root / 'evidence/UI-05').glob('*/import.log')))
        with self.assertRaises(ValueError):
            interface_capture.capture_interface('UI-05', 'before', '1152x882')


if __name__ == '__main__':
    unittest.main()
