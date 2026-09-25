"""B6 connected-world checks with copied runtime and disposable synthetic chapter saves.

Every attempt retains its input manifest/archive, logs, final save bytes and results.
Positive journeys use the real chapter controller; fixtures are marked in test names.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
from s03_evidence import record_runtime

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "evidence/B6" / ("run-" + time.strftime("%Y%m%dT%H%M%SZ", time.gmtime()))
OUT.mkdir(parents=True)
BINARY = os.environ.get("GODOT_BIN", "/Applications/Godot.app/Contents/MacOS/Godot")
VERSION = subprocess.check_output([BINARY, "--version"], text=True, timeout=20).strip()
if VERSION != "4.6.2.stable.official.71f334935":
    raise SystemExit("Unexpected Godot version: " + VERSION)
results = []
with tempfile.TemporaryDirectory(prefix="space-opera-b6-validation-") as temporary:
    temp = Path(temporary)
    game = temp / "game"
    shutil.copytree(ROOT / "game", game, ignore=shutil.ignore_patterns(".godot"))
    digest = record_runtime(OUT, game)
    env = dict(os.environ, B6_SAVE_DIR=str(temp / "saves"), B6_CHECKS_PATH=str(OUT / "b6-checks.json"), B2_EXTERNAL_LIVE_PID=str(os.getpid()))
    env.update(B5_SAVE_DIR=str(temp / "FORBIDDEN-B5"))
    # Poison unrelated namespace paths: B6 must never create any of these.
    env.update(B4_SAVE_DIR=str(temp / "FORBIDDEN-B4"), B3_SAVE_DIR=str(temp / "FORBIDDEN-B3"), B25_SAVE_DIR=str(temp / "FORBIDDEN-B25"), S03_SAVE_DIR=str(temp / "FORBIDDEN-S03"), S04_SAVE_DIR=str(temp / "FORBIDDEN-S04"), B2_SAVE_DIR=str(temp / "FORBIDDEN-B2"))
    (temp / "saves").mkdir()
    stages = [
        ("fresh-import", ["--headless", "--path", str(game), "--import"]),
        ("b6-language-corpus", ["--headless", "--path", str(game), "--script", "res://tests/language_b6.gd"]),
        ("b6-journeys-branches-recovery", ["--headless", "--fixed-fps", "60", "--path", str(game), "--script", "res://tests/run_b6.gd"]),
        ("b6-actual-save-and-quit", ["--headless", "--fixed-fps", "60", "--path", str(game), "--script", "res://tests/restart_b6.gd", "--", "--quit-check"]),
        ("b6-separate-process-continue", ["--headless", "--fixed-fps", "60", "--path", str(game), "--script", "res://tests/restart_b6.gd"]),
    ]
    for name, arguments in stages:
        started = time.monotonic()
        try:
            stage_env = dict(env, B2_TEST_NO_QUIT="1") if name in ["b6-journeys-branches-recovery", "b6-presentation-keyboard"] else env
            run = subprocess.run([BINARY, *arguments], env=stage_env, cwd="/tmp", text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=240)
            output, code = run.stdout, run.returncode
        except subprocess.TimeoutExpired as error:
            output = (error.stdout or b"").decode(errors="replace") if isinstance(error.stdout, bytes) else (error.stdout or "")
            output += "\nVALIDATION_TIMEOUT\n"
            code = 124
        (OUT / (name + ".log")).write_text(output)
        passed = code == 0 and "ERROR:" not in output and "FAIL " not in output
        results.append(dict(name=name, exit=code, passed=passed, seconds=time.monotonic() - started,
                            arguments=[BINARY, *arguments]))
        if not passed:
            break
    forbidden = [str(p.relative_to(temp)) for p in temp.glob("FORBIDDEN-*")]
    results.append(dict(name="historical-namespace-write-isolation", passed=not forbidden, unexpected=forbidden))
    if (temp / "saves").exists():
        shutil.copytree(temp / "saves", OUT / "synthetic-saves")
    save_manifest = "".join(hashlib.sha256(p.read_bytes()).hexdigest() + "  " + str(p.relative_to(OUT)) + "\n"
                            for p in sorted((OUT / "synthetic-saves").rglob("*")) if p.is_file())
    (OUT / "synthetic-saves.sha256").write_text(save_manifest)
from audit_b6_arithmetic import audit
arithmetic = audit(OUT)
results.append(dict(name="independent-original-input-arithmetic", passed=arithmetic["passed"], snapshots=arithmetic["snapshots"]))
(OUT / "results.json").write_text(json.dumps(dict(version=VERSION, runtime_manifest_sha256=digest,
    synthetic=True, time_scale=1, results=results), indent=2) + "\n")
print(OUT)
print(json.dumps(results, indent=2))
raise SystemExit(0 if all(item["passed"] for item in results) else 1)
