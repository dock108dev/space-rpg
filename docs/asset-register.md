# Asset register

| ID | Asset and editable source | Production / display | Status |
|---|---|---|---|
| REF-001 | [Selected C comparison](reference/visual-comparison.png) | Original retained unchanged; style reference only | Owner selected C |
| HUM-toward | [Krita master](../source-assets/S02/masters/human-toward.kra); generated original 1254x1254 | 1254×1254 part exports; 100 game px high; foot/joint pivots in rig.json; side mirrored for left | Motion repair reviewed; collar non-urgent |
| HUM-away | [Krita master](../source-assets/S02/masters/human-away.kra); generated original 1254x1254 | 1254×1254 part exports; 100 game px high; foot/joint pivots in rig.json; side mirrored for left | Motion repair reviewed; collar non-urgent |
| HUM-side | [Krita master](../source-assets/S02/masters/human-side.kra); generated original 1197x1314 | 1254×1254 part exports; 100 game px high; foot/joint pivots in rig.json; side mirrored for left | Motion repair reviewed; collar non-urgent |
| FLOOR | [Krita master](../source-assets/S02/masters/floor.kra); original 1672×941 | 1040×475 game ground layer; export 1672×941; bottom-center pivot | Integrated; source and RGBA export retained |
| CABINET_A | [Krita master](../source-assets/S02/masters/cabinet_a.kra); original 1536×1024 | 85 px high; 130×42 footprint; export 1135×769; bottom-center pivot | Integrated; source and RGBA export retained |
| PET | [Krita master](../source-assets/S02/masters/pet.kra); original 1378×1142 | 45 px high; radius 8; placeholder bob/flip; export 871×683; bottom-center pivot | Integrated; source and RGBA export retained |
| CREATURE | [Krita master](../source-assets/S02/masters/creature.kra); original 1402×1122 | 85 px high; held lowered pose and short lunge; export 915×937; bottom-center pivot | Integrated; source and RGBA export retained |
| DOORWAY | [Krita master](../source-assets/S02/masters/doorway.kra); original 1470×1070 | 330×215; separated posts/lintel; local lintel fade; export 1272×881; bottom-center pivot | Integrated; source and RGBA export retained |
| CABINET_B | [Krita master](../source-assets/S02/masters/cabinet_b.kra); original 1023×1537 | 130 px high; 60×26 footprint; export 732×1435; bottom-center pivot | Integrated; source and RGBA export retained |

All generated assets used the built-in image tool. Prompts, reference roles and measured waits: [generation record](../source-assets/S02/prompts.md). Model/version, seed and credit usage unavailable. Cleanup was scripted inside Krita; no owner drawing time is claimed.

Human rig `source_dimensions` currently denotes its normalized working canvas, not original generator dimensions; original dimensions above are measured directly. Export dimensions and pivots are accurate.

Godot imports: lossless (`compress/mode=0`), alpha-border fix enabled, no mipmaps, linear canvas texture filtering. Imported PNGs and `.import` sidecars are in reviewed runtime identity; editable sources stay outside game/.

Cabinet B was generated as an edit using A’s cleaned master as identity/construction reference, then A’s KRA was opened, retained hidden, canvas adjusted and B’s cleaned layer added. Same threshold/crop/export recipe, palette, perspective and pivot convention. A is low/single-door; B tall/two-door. This demonstrates a prop recipe, not a whole location or second character.

Generation provenance: OpenAI individual terms page checked at creation (Jan 1, 2026 effective), https://openai.com/policies/row-terms-of-use/; actual account agreement type unavailable. No claim of exclusive rights or distribution authorization. Krita official free 5.3.3 from https://krita.org/en/download/; no paid store/API/asset purchase.

Engine-drawn terminal, control, shield and simple recess wall layout are sample placeholders. Wall texture reuses the retained doorway stone. None creates approved lore, a feed, ownership or privacy.
