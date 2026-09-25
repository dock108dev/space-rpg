"""Installer trust boundary checks without network access."""
import hashlib
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import install_ci_godot


class GodotInstallerTests(unittest.TestCase):
    def test_checksum_failure_never_extracts(self):
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / 'engine'
            with patch.object(install_ci_godot.urllib.request, 'urlopen', return_value=io.BytesIO(b'bad')):
                with self.assertRaisesRegex(RuntimeError, 'checksum mismatch'):
                    install_ci_godot.install(destination)
            self.assertFalse((destination / 'Godot.app').exists())

    def test_verified_archive_and_existing_directory(self):
        data = io.BytesIO()
        with zipfile.ZipFile(data, 'w') as archive:
            archive.writestr('Godot.app/Contents/MacOS/Godot', b'synthetic executable')
        payload = data.getvalue()
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / 'engine'
            with patch.object(install_ci_godot, 'SHA256', hashlib.sha256(payload).hexdigest()), patch.object(
                    install_ci_godot.urllib.request, 'urlopen', return_value=io.BytesIO(payload)):
                binary = install_ci_godot.install(destination)
            self.assertEqual(binary.read_bytes(), b'synthetic executable')
            self.assertTrue(binary.stat().st_mode & 0o100)
            with self.assertRaises(FileExistsError):
                install_ci_godot.install(destination)
