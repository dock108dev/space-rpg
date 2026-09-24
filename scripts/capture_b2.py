"""Normal game-time B2 moving tour of actual chapter, disposable synthetic state.

Godot fixed-fps movie capture changes render throughput, not simulation time_scale.
The compressed movie is 30 fps and must be reviewed at 1x playback speed.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
from s03_evidence import record_runtime

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "evidence/B2" / ("capture-" + time.strftime("%Y%m%dT%H%M%SZ", time.gmtime()))
OUT.mkdir(parents=True)
BINARY = os.environ.get("GODOT_BIN", "/Applications/Godot.app/Contents/MacOS/Godot")
version = subprocess.check_output([BINARY, "--version"], text=True, timeout=20).strip()
if version != "4.6.2.stable.official.71f334935":
    raise SystemExit("Unexpected Godot: " + version)
passed = False
with tempfile.TemporaryDirectory(prefix="space-opera-b2-visible-") as temporary:
    temp = Path(temporary)
    game = temp / "game"
    shutil.copytree(ROOT / "game", game, ignore=shutil.ignore_patterns(".godot"))
    digest = record_runtime(OUT, game)
    imported = subprocess.run([BINARY, "--headless", "--path", str(game), "--import"],
                              text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=150)
    (OUT / "fresh-import.log").write_text(imported.stdout)
    env = dict(os.environ, B2_SAVE_DIR=str(temp / "saves"), B2_CAPTURE_DIR=str(OUT))
    arguments = [BINARY, "--path", str(game), "--resolution", "1280x720", "--disable-vsync", "--audio-driver", "Dummy",
                 "--write-movie", str(OUT / "b2-tour.avi"), "--fixed-fps", "30",
                 "--script", "res://tests/visible_b2.gd"]
    start = time.monotonic()
    code = imported.returncode
    if code == 0 and "ERROR:" not in imported.stdout:
        with (OUT / "visible.log").open("w") as logfile:
            try:
                result = subprocess.run(arguments, env=env, stdout=logfile, stderr=subprocess.STDOUT, timeout=600)
                code = result.returncode
            except subprocess.TimeoutExpired:
                code = 124
        output = (OUT / "visible.log").read_text()
        passed = code == 0 and "TOUR_FINAL" in output and "ERROR:" not in output and "tour actual save and quit" in output
    if (temp / "saves").exists():
        shutil.copytree(temp / "saves", OUT / "synthetic-saves")
    (OUT / "result.json").write_text(json.dumps(dict(version=version, exit=code, passed=passed,
        runtime_manifest_sha256=digest, tool_wall_seconds=time.monotonic() - start,
        arguments=arguments, synthetic=True, control="scripted ordinary input/controller actions; no debug progression",
        engine_time_scale=1, movie_frames_per_second=30, intended_playback_speed=1), indent=2) + "\n")
print(OUT, code, flush=True)
if not passed:
    sys.exit(1)
subprocess.run(["ffmpeg", "-v", "error", "-i", str(OUT / "b2-tour.avi"), "-c:v", "libx264",
                "-crf", "20", "-pix_fmt", "yuv420p", "-an", str(OUT / "b2-tour.mp4")], check=True, timeout=150)
metadata = subprocess.check_output(["ffprobe", "-v", "error", "-show_entries",
    "stream=width,height,r_frame_rate,nb_frames,duration:format=duration", "-of", "json", str(OUT / "b2-tour.mp4")], text=True)
(OUT / "movie-metadata.json").write_text(metadata)
print(metadata)
