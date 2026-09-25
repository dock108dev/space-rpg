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

## B2 shelter and recruit

B2 adds an original editable SVG shelter kit, concourse accents and three directional six-part recruit rigs under `game/art/b2`, with the generator and masters under `assets/b2`. Existing generated raster cutouts/masters remain preserved. See [production and provenance](B2-art-production.md) and [final integrated evidence](../evidence/B2/README.md). The more graphic vector finish and retained human/pet motion limits are explicit; visual engineering review is not owner aesthetic acceptance.

## B3 connected-world scenery

B3 adds authored editable vector masters/exports in `game/art/b3/`: hub arcade and approach ridge backgrounds, partition, gate, board, access panel, filled/empty pallet, rocks and survey marker. These extend the existing B2 SVG scenery system and reuse its doorway plus the retained raster cutout protagonist/pet and vector recruit. No generated raster assets, purchased art or external source material were added. New collision footprints correspond to the illustrated props; opening access changes both the central gate and walkable geometry. The two-place palette/geometry distinction and motion require the B3 native/movie review; this register is not visual acceptance. Active authoring time was not separately measured.

## B4 authored preparation props

`game/art/b4/bench.svg` and `range.svg` are original editable vector props authored in this slice, using the established muted outline palette alongside retained cutout actors. The hub bench and approach target/lane are integrated in the actual sorted game scene. Equipment has a colored foot-ring indicator (thicker at the improved tier); the target tips on a successful impact test. No generated-image or external asset purchase was used for B4. This is engineering visual evidence, not owner acceptance of final art.

## B5 owned-home assets

Six editable SVG masters/exports under `game/art/b5`: home interior, Reading chair, Task lamp, Keepsake shelf, sealed locker and repaired/open locker. Extend existing B3/B4 vector illustration alongside retained raster cutout actors; no image-generation or asset purchase. Props are separate depth-sorted nodes and correspond to protected one-cell footprints. Four sockets and a distinct public hub doorway integrate into ordinary world travel. Measured authoring-time claims are not made. Native engineering review supports readable current layout, not owner art acceptance.

## B6 — retained artwork, new runtime presentation

B6 reuses the exact B5/B4/B3/S02 environment and cutout actor assets. No image generation, external asset acquisition or source-master replacement. `companions_care.gd` adds code-drawn breach, cover, injury and pulse/shot marks, downed recruit rotation and evacuation fade. The final B6 source/art manifest/archive binds these effects together with all reused assets. Existing delivery archives remain unchanged; visual engineering review is separate from owner acceptance.

## B7 relay yard

Original editable SVG geometry/props: `game/art/b7/yard.svg`, `core.svg`, `core_empty.svg`, `wheel.svg`. Project-authored additions to the existing vector scenery system, with retained illustrated cutout actors; no generated raster, purchased asset or new art-direction acceptance. Collision/route placement and known mixed-style limits: [B7 art record](B7-art-and-review.md). Final manifest includes exact artwork.

## B8 appearance and presentation

No original illustrated masters were replaced. `player_experience.gd` applies a torso-only palette shader (amber/teal/plum), actual rig preview and continuous stride/arm poses to retained human cutouts. Recruit joints form a seated downed pose; pet contact/shadows and care/rescue feedback are improved. All original raster/vector assets remain intact. System-font fallback uses installed macOS fonts without copying/distributing them. No new purchased/generated raster asset or audio dependency. See [review and limits](B8-review-and-balance.md).
