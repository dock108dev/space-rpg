# UI-05 updated Mac package

Separate current-source delivery: **Space Opera RPG Updated Beta.app**, bundle `org.personal.spaceoperarpg.updatedbeta`, version 0.9.1 / build 10. Arm64, Godot 4.6.2 official matching export template; same local macOS 27.0 minimum as B9. Preserve original B9 app, archive, source and latest-build pointer.

The source exporter `python3 scripts/package_ui05.py` delegates to the parameterized B9 exporter with distinct project settings, preset, evidence root, app name and archive. It includes M1, M2, UI-04 and UI-05. Runtime save schema is unchanged; the app's distinct custom user directory deliberately provides a fresh personal namespace. No owner-save migration or inspection occurs.

Exact candidate and validation are retained in `evidence/UI-05/candidate.json`. Build inputs, staged runtime, bundle contents, archive and executable/PCK hashes identify the candidate; Git HEAD alone does not. Delivery documentation and validator absolute-path handling may be finalized after export and are retained separately in the delivery manifest; runtime game source must still match the export input manifest.

Validation entry points, accepting an absolute or repository-relative retained build directory:

```
python3 scripts/validate_b9.py evidence/UI-05/build-20260924T235524Z
python3 scripts/validate_ui05.py evidence/UI-05/build-20260924T235524Z
python3 scripts/capture_b9.py evidence/UI-05/build-20260924T235524Z
```

The first runs packaged gameplay, actual Save and quit, separate-process Continue, multi-character failures and independent arithmetic. The second runs packaged M1/M2 failures, resource/platform inventory and native 100%/125% interface views at both supported sizes. Normal boot is also checked separately with no diagnostic selector. The third retains a normal-speed scripted fresh-character journey and exact separate-process restart, using the exported app rather than editor resources. These are synthetic technical checks, not owner review.

Release diagnostics remain a named allowlist requiring an explicit absolute B9_SAVE_DIR. UI-05 adds named interface, errors and security harnesses; it does not expose arbitrary script selection. Harness SceneTree lifecycle adaptation adds get_root to the guarded Node base. Signing remains ad-hoc. No notarization, publication, credential use or security bypass.
