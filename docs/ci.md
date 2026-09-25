# Pull-request CI

`.github/workflows/ci.yml` runs **Source checks (macOS)** for every pull request, pushes to `main`, and manual dispatch. There are no path filters that could leave a required check pending. It uses one `macos-26` runner, Python 3.14.5 and official Godot 4.6.2. This is source validation, not packaged release certification.

The Godot installer downloads the official universal macOS archive into RUNNER_TEMP and verifies a fixed SHA-256 before extraction. The focused source validator honors GODOT_BIN and verifies the exact engine version. No export templates, package manager dependencies, credentials, signing or publishing are needed. There is no dependency cache to conceal a dirty import or missing input. Review version, URL, checksum and engine-version guard together when changing Godot.

The job runs `python3 -m compileall -q scripts`, then `bash scripts/validate.sh M4`. The export checker copies current source without local evidence/caches and runs focused Python tests plus focused import, startup, save/validator and namespace checks. It does not run native walkthroughs or the full historical suite. Diagnostic logs and assertions are uploaded on success/failure when available, retained for seven days; synthetic saves, source archives and personal character data are not uploaded.

The workflow has contents:read only, disables checkout credential persistence, uses pull_request rather than pull_request_target, pins every action by full commit SHA, has a 15-minute timeout and cancels superseded runs per PR/ref. Dependency updates are grouped monthly for Actions only; this standard-library Python project has no pip lockfile to install or scan. Managed GitHub CodeQL remains separate and unchanged.

Workflow configuration and local execution are separate from hosted results. A new pull request should show `Source checks (macOS)`; managed CodeQL, where configured, reports `Analyze (python)`. This repository's workflow does not configure branch protection or make checks required. Check the actual pull request for results on its exact commit.

The standard macOS runner is a source-test environment, not packaged macOS 27 qualification. Hosted image behavior, artifact upload and security analysis on changed source must be verified from the corresponding Actions run. Local source checks alone cannot establish those results.

References: [GitHub-hosted runner labels](https://docs.github.com/en/actions/reference/runners/github-hosted-runners), [official Godot 4.6.2 assets](https://github.com/godotengine/godot-builds/releases/tag/4.6.2-stable).
