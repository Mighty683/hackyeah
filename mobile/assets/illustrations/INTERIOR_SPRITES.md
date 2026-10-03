# Interior furniture sprites

`interior-furniture-v1.png` was generated on 2026-10-03 with the built-in
imagegen tool, using `child-poses.png` as a rendering-style reference only.
It is a 1254 × 1254 RGBA atlas with genuine transparency. Keep the atlas intact.

`MissionHomePlan` loads the atlas once; `MissionHomePlanPainter` draws individual
source rectangles into the existing fictional top-down apartment. Architecture,
window openings and wooden door leaves remain native drawings. The revised layout
has one central hallway, living room and kitchen on the left, and a bedroom with
a reading corner on the right. Soft wall faces replace dark blueprint lines; no
nested room or doubled outer shell remains. No background is baked
into the atlas and no safety meaning is attached to its furniture.

The source rectangles are measured from the actual output, since generated grid
cells are not perfectly uniform:

| Sprite | Padded source rectangle (left, top, right, bottom) |
| --- | --- |
| Sofa | 40, 190, 533, 484 |
| Bed | 590, 50, 845, 596 |
| Stove counter | 990, 45, 1160, 597 |
| Sink counter | 120, 650, 285, 1205 |
| Dining table and chairs | 428, 732, 805, 1090 |
| Plant | 873, 734, 1215, 1108 |

## Generation prompt

Use case: illustration-story
Asset type: transparent furniture sprite atlas for Tuptu's top-down apartment plans.
Primary request: Create ONE square transparent sprite sheet with exactly SIX separate furniture sprites in a clean 3-column by 2-row equal-cell grid. The attached child sheet is STYLE REFERENCE ONLY for the soft, friendly illustrated rendering; do not include any people.
Camera: strict orthographic directly overhead, 90-degree bird's-eye view. Top surfaces only. No isometric perspective, no front facades, no room walls or flooring.
Grid order: TOP LEFT a wide muted sage-blue two-seat sofa with two cushions and upholstered arms, backrest at top of cell. TOP CENTER a single bed vertical with pale oak frame, lavender blanket, white pillow at top. TOP RIGHT a long narrow vertical kitchen worktop containing a dark four-ring stovetop and pale oak counter. BOTTOM LEFT a long narrow vertical kitchen worktop containing a steel sink basin and tap, pale oak counter. BOTTOM CENTER a small pale oak dining table vertical with two sage chairs, one each left and right. BOTTOM RIGHT one round potted leafy green houseplant viewed directly overhead.
Style: polished friendly children's picture-book furniture sprites, gently painted dimensional surfaces and clear recognizable silhouettes, similar softness and rounded edges to the reference child but restrained colors. Muted sage, slate blue, lavender, pale warm wood and ivory. Ordinary home furniture, subtle detail, no heavy black outlines, no glossy shine.
Composition: exactly six isolated objects, one per equal grid cell, centered. Each object entirely inside its cell with at least 12 percent clear transparent padding on every side. No object intersects another cell. Preserve the differing object proportions: sofa horizontal, bed/worktops/table vertical, plant circular.
Background: TRUE TRANSPARENT alpha everywhere between and around objects. No white rectangles, no checkerboard painted into image, no backdrop, no ground shadows extending outside sprites.
Constraints: no characters, no text, no letters, no numbers, no labels, no borders, no tiles, no room plans, no UI, no highlights, no arrows, no watermark.
