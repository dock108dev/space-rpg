# Synthetic validation inputs

These are deliberately versioned test inputs, not owner saves or acceptance evidence. Original local evidence remains untouched.

| File | Provenance / consumers |
| --- | --- |
| `unopened-character.json` | Byte-for-byte M3 retained synthetic fixture from `evidence/M3/run-20260925T000613553128Z/fixture.json`, originally a UI-05 synthetic qualification snapshot. Used by focused M3 schema and save tests. |
| `interface-cases.json` | Byte-for-byte synthetic restart cases from `evidence/B8/run-20260924T231431Z/synthetic-saves/restarts.json`. Used by UI-04/UI-05 source capture and explicit packaged UI-05 checks. |

The retained cases supply opening, unresolved yard and completed home states. Tests write copies or disposable sessions, never these inputs. Do not replace these with real character data. Native interface replay remains synthetic technical evidence.

SHA-256:

- `unopened-character.json`: `fa7897242786b91f0e48167bda4d02e3c5af390ffaaf39460dbe0d830c007939`
- `interface-cases.json`: `ad5fb8657aae0633aca2e5e3b09c39e08fdc3cfcbcfbef016c69a896e4fc28a0`
