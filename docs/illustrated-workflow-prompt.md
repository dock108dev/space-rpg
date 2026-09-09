# Prompt: prove the illustrated game workflow

I now have an actual illustrated human walking, stopping and turning in Godot on my Mac. The look received positive feedback; a duplicate-limb defect was caught in motion and repaired. This is not yet an accepted complete game.

Use this as the standard for our graphics work:

1. Start from an actual visual reference I selected. Preserve that reference and match its illustrated qualities. Do not silently replace the look with primitive shapes, emoji, a text interface, or an unrelated art style.
2. Build the smallest real engine sample that tests the hardest visual requirement first. For this project that was a roughly 100-pixel-tall human walking toward, away, left and right on a plain floor—before building detailed scenery.
3. Our working stack is Godot 4.6.2 Standard, GDScript, Compatibility renderer; built-in image generation for illustrated masters; Krita 5.3.3 for editable layered cleanup and transparent PNG exports; Godot AnimationPlayer for rigid cutouts. Use the existing project's appropriate engine if different, but explain concrete capability or access problems rather than hand-waving that graphics cannot work.
4. Generate and retain a character master, then use it as an identity reference for other views. A request for transparency may return a painted checkerboard: inspect the actual alpha channel. Clean the asset in the art editor, retain layered masters and record pivots, export dimensions and import settings.
5. Every animated limb layer must contain only that limb. Paint or reconstruct surfaces hidden behind it. Our first pass accidentally carried neighboring limbs into the masks, producing apparent extra arms and legs when animated. Good still images did not reveal that defect.
6. Put the real art into the running game early. Verify actual display scaling—our first Retina window was half the intended logical size. Show motion at gameplay scale and let me operate it. Inspect joint gaps, duplicate silhouettes, foot sliding, direction consistency, alpha edges and readability.
7. Keep technical behavior, visual quality, production repeatability and my feedback separate. Passing an import or movement test does not prove that the graphics look good. A compliment on appearance is not acceptance of broken animation.
8. Make one focused repair pass when the rig fails. If cutouts still cannot meet the target, test authored animation frames for the same character. If outside art help is actually needed, give me the exact bounded asset brief and dependency.

Show me the moving result. Explain what you actually tried, what failed and what you will change. Preserve source assets and reproducible launch instructions. Do not promise that a generated still image automatically solves animation, and do not declare the graphics impossible without testing a concrete production workflow.
