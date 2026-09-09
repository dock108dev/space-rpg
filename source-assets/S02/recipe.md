# S02 illustrated recipe — working version

Style: bottom-left C panel of REF-001; fine dark ink contours, muted olive/brown/slate, restrained textured shading, soft upper-left light. Test costume/species/layout only. Human 100 logical game pixels high; outline approximately 1 pixel at that scale. No permanent creative decision implied.

1. Built-in image generation produces a retained master. Three human views use the front master as identity reference. Side mirrored for left: asymmetric illumination is a known limitation.
2. Run `krita_cleanup.py` inside Krita Tools → Scripts → Scripter. Original RGB background pixels are removed under a deliberately dark-costume threshold; polygon masks separate limbs into editable paint layers. Original reference remains hidden. Export through Krita as RGBA/sRGB PNG. Reopen the KRA and verify named layers. This is agent-scripted cleanup inside Krita, not owner hand painting.
3. Defect found in first rig: side masks carried adjoining limbs, and torso carried near-arm pixels. Focused repair isolates one limb per mask and paints a jacket continuation behind the arm; hidden far limbs reuse the clean near-limb shape. Retained review-v1 archive documents failure. No external art service or paid API used.
4. Six rigid parts per view; head, torso/pelvis, near/far arm, near/far leg. Pivots and foot anchors are in exports/human-rig.json. Full 1254-square transparent exports; no runtime background extraction. AnimationPlayer uses a 0.64-second cycle, counter-swing and front/back projected step offsets. These are tuning hypotheses. No knee articulation yet.
5. Godot default lossless PNG import, linear filtering, no mipmaps. `.import` records included in identity; `.godot` excluded. Correct Retina test window is 2560×1440 physical pixels = 1280×720 macOS points with a 1280×720 logical canvas.

Generation model, seed, credit usage: unavailable. Built-in tool used. OpenAI individual terms page checked at creation: https://openai.com/policies/row-terms-of-use/ (effective Jan 1, 2026); account agreement type not exposed. No distribution or exclusivity claim. Reference is retained owner-provided project output.

Cabinet recipe/repeatability: executed; see the record below.

## Executed prop recipe

`krita_props.py` applies the same bright-neutral background removal, alpha-bounds crop, sRGB RGBA export and KRA save/reopen to A and B. Cabinet A's cleaned export was the generation reference for B. B starts by opening A's KRA and preserving its original layer hidden, then adds the newly cleaned two-door silhouette. Palette, right-side perspective and panel construction remain shared. Both have bottom-center anchors and identical import settings. Cabinet A is displayed at 85 px high; B at 130 px. Collision footprints are authored in the scene's geometry list.

Doorway exports use independent left, right and lintel layers; all preserve full-frame margins so offsets align. Simple recess wall surfaces reuse a stone patch from this master. Floor stays independent of sortable actors/props. Pet is a following placeholder with flip and slight bob, not a completed articulated walk cycle. Creature demonstrates an anchored body pose change, held preparation, lunge and recovery; no enemy-intent text appears.

Measured cleanup/save/reopen/export: see exports/props.json. Stage effort: evidence/S02/effort.csv. Prompt/script/animation/integration authoring were not separately timed and remain UNAVAILABLE, not zero. These records do not substantiate an end-to-end production-time comparison or the S01 estimates. Owner activity duration is unmeasured.
