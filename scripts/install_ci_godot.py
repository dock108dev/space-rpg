"""Fetch the exact official macOS editor into a disposable CI directory."""
import argparse
import hashlib
from pathlib import Path
import urllib.request
import zipfile

URL = 'https://github.com/godotengine/godot-builds/releases/download/4.6.2-stable/Godot_v4.6.2-stable_macos.universal.zip'
SHA256 = '666b2a64e4b5c59db0e4974605b888eb72eb7d4e60e870d2be6cc19727b50807'


def install(destination):
    destination = destination.resolve()
    destination.mkdir(parents=True, exist_ok=False)
    archive = destination / 'godot.zip'
    with urllib.request.urlopen(URL, timeout=90) as response, archive.open('wb') as output:
        while chunk := response.read(1024 * 1024):
            output.write(chunk)
    if hashlib.sha256(archive.read_bytes()).hexdigest() != SHA256:
        raise RuntimeError('Godot archive checksum mismatch; refusing extraction')
    with zipfile.ZipFile(archive) as zipped:
        for name in zipped.namelist():
            if not (destination / name).resolve().is_relative_to(destination):
                raise RuntimeError('Unsafe Godot archive member')
        zipped.extractall(destination)
    binary = destination / 'Godot.app/Contents/MacOS/Godot'
    binary.chmod(0o755)
    return binary


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    print(install(parser.parse_args().destination))
