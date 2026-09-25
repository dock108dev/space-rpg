# M2 — Local security hardening

**TECHNICALLY COMPLETE — source only.** Authorized by the supplied security implementation request. Build on completed M1; preserve frozen B9-20260924-01, all previous evidence and owner state. B10 remains NOT STARTED.

Scope: inspect actual offline desktop trust boundaries; prevent linked save/preference paths from redirecting access and bound command parsing before allocation. Add focused synthetic security tests, run affected source checks, and document classified findings and remaining work. No package/signing, provider/network collection, owner-state access, commit or publication.

Baseline: current uncommitted source after M1, with file hashes and before copies in evidence/M2. B9 candidate identity remains evidence/B9/candidate.json; source changes do not requalify that app.

## Delivered

- SEC-01 (medium): refuse linked session/snapshot/preference/selector paths and linked writer recovery. Outside synthetic targets remain unchanged.
- SEC-02 (low): reject whole commands over 1,000 characters before parsing/bookkeeping; enforce 128-step/action bounds before expanding/appending.
- SEC-03 (low): cap optional preference files at 4 KiB; retain normal usable defaults with a warning.

[Security understanding, classified findings, accepted patterns and prioritized remaining work](../security.md) is the current security guide. No new hosted-service stack, account model or security boundary was invented.

## Actual validation

- `bash scripts/validate.sh M2`: copied-runtime import and 23 focused checks PASS. [Results](../../evidence/M2/run-20260924T231430583077Z/results.json).
- `bash scripts/validate.sh B8`: 394 gameplay/branch checks, 24 setup/save/input checks, separate-process save/Continue, namespace isolation and 432 independently reconciled snapshots PASS. [Results](../../evidence/B8/run-20260924T231431Z/results.json).
- `bash scripts/validate.sh M1`: 19 inherited error-handling checks and two expected startup failures PASS. [Results](../../evidence/M1/run-20260924T231610034593Z/results.json).
- Python syntax for the new runner, shell syntax and whitespace checks PASS.
- Installed B9 executable/PCK, retained archive and all 461 frozen staged runtime inputs remain hash-identical. [Preservation](../../evidence/M2/preservation.json).

The first M2 test attempt had a test-script type-inference error; its failure is retained. It was corrected before the final security and gameplay checks. No runtime check failure was relabeled as success.

No engineering slice is active. B10 remains NOT STARTED. No owner-state access, packaging/signing or release. The source change requires a separately authorized replacement build to reach the installed app. Dependency advisories, wider-distribution decisions and stronger hostile-local-process isolation remain separate, prioritized in the security guide.
