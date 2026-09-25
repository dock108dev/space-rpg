# UI-04 — Command adventure clarity

**TECHNICALLY COMPLETE — source presentation only.** Current B8/B9 player scene after M1/M2. Preserve frozen B9 and B10, owner data and existing work.

Scope: matched current-source synthetic before/after views of character setup, ordinary opening, expedition, completed home, larger text, help/history and save failure. Clean up copy, hierarchy and repeated presentation while preserving rules, state, teaching, command choices, stop and recovery. Use the portable UI requirements and existing Glass UI Starter 01 adaptation; no claim of full Starter 02 adoption. No new navigation, packaging or release.

Delivery: [matched screenshots and concise observations](../../evidence/UI-04/README.md), with 58 passing native UI checks across two sizes and [passing B8 gameplay/save/restart checks](../../evidence/B8/run-20260924T233444Z/results.json). Source snapshot comparisons differ only in display-history strings; no rules or schemas changed. Python syntax and whitespace checks pass.

Validation entry points: `python3 scripts/capture_ui04.py after 1152x882`, `python3 scripts/capture_ui04.py after 1280x980`, and `bash scripts/validate.sh B8`. The capture helper uses a disposable project and retained synthetic fixture. Its `before` mode restores the retained incoming player script inside that copy, preserving an honest comparison after edits. No owner data is used.

No engineering slice remains active. B10 is unstarted; installed B9 is unchanged. Global scaling and a replacement package remain separate suggestions, not implemented work. No commit, push, signing, publication or owner acceptance.
