# B2 art production

B2 adds a distinct furnished temporary shelter and a separate autonomous recruit illustration. These assets are integrated into the chapter, rather than serving as a concept image or a substitute for spatial play. Historical S02/S04 artwork and masters remain unchanged. The chapter's final evidence record owns exact source/asset identity and the final moving review; no owner verdict is supplied here.

## Original editable source and runtime exports

[assets/b2/build_vectors.py](../assets/b2/build_vectors.py) is the editable drawing source. It regenerates all 31 runtime SVG illustrations and separate directional body parts under [game/art/b2](../game/art/b2). The three `*_master.svg` files are independently editable composite masters whose identified groups match the exported cutouts. No external asset, paid service, copied franchise character, new lore, or asset purchase was used. This is original authored vector artwork, not an image-generation result; no model, seed, or generation time is claimed.

The shelter contains a cot, hamper, two storage lockers, a bench, an orientation desk, a circulation runner, wall lamps, and a visibly shared-refuge sign. Usable floor and furnishing collision are owned by `chapter_locations.gd` and the controller, not the artwork. Front-to-back occlusion uses each furnishing's floor contact under the same sorting node as the actors. The orientation desk corresponds to blocked cell `(5,1)`; player interaction takes place adjacent to it. There is no feed terminal or claim of ownership/privacy. Native labels render the room name and public-space wording; SVG text is not relied on by the runtime importer.

The concourse deliberately retains the existing illustrated floor and cabinet artwork, with new door framing and tangible package/cache cutouts. The two rooms use different floor composition, furniture and movement routes, rather than a recolor.

## Moving recruit

[recruit_visual.gd](../game/scripts/recruit_visual.gd) owns presentation only and receives actual movement through `update_motion(direction, moving, delta)`. The shared follower owns pathfinding/collision. The recruit is 94 game pixels high beside the existing 100-pixel protagonist and 45-pixel pet. A wider hood, short poncho, goggles, satchel/backpack and heavy boots distinguish its silhouette. Toward, away and side masters preserve the same garment identity; the side is mirrored for leftward movement. Limbs are cut out once per view and rotated about explicit pivots. The passing/rest position restores exact pivots; the visible facing group alone receives the gait. Hatching stays within individual silhouettes.

The pet keeps its retained illustration; its actual follow/fetch behavior and motion remain under the shared chapter follower. No articulated new pet gait or companion combat is claimed.

## API and ownership

`chapter_art.gd` exposes `configure(controller)` followed by `set_location("concourse" | "shelter")`. It owns only scenery. Every sorted prop it creates is tracked, hidden and freed on a location switch. Collision, journey state, interactions, party membership and saving remain controller-owned. Package/cache visibility derives from committed controller state.

## Production and review record

One original vector construction recipe produced the room kit and the three recruit views. There was no generation wait or artist-owner drawing session. Authoring, integration and rework were performed in this implementation run; a stopwatch was not maintained, so active minutes are unknown rather than inferred from elapsed tool duration.

The first isolated runtime-art preview failed because a local `draw_ellipse` helper collided with a newly available native CanvasItem method. Its actual failure log is retained at [attempt-01-parser-failure.log](../assets/b2/review/attempt-01-parser-failure.log). Renaming the helper to `ink_ellipse` repaired that bounded cause. The second preview rendered a six-second normal-time synthetic recruit walk/turn with the existing protagonist and pet. Its images and log are in [assets/b2/review](../assets/b2/review). That art-only fixture cannot pass ordinary gameplay, doorway navigation, pause, save or owner acceptance. The native renderer also reported a CoreAudio device-start error in that preview; audio was not part of this art check and no sound-quality pass is claimed.

The initial preview showed that the vector pieces read cleaner/flatter than the historical raster actor. Subtle silhouette-bound crosshatching and native wall labels were then added. Final moving chapter evidence must cover the resulting files after those changes, including normal Mac input and both rooms. The retained initial screenshots are explicitly earlier iterations, not final-candidate proof.

Known aesthetic limits: the new authored kit is more graphic and less painterly than the existing generated raster characters, directional coverage remains four facing groups, the cutout gait is intentionally modest, and the pet's underlying illustration still has its historical limited leg articulation. These remain subject to owner aesthetic review; neither a generated still nor a successful runtime import supplies that review.
