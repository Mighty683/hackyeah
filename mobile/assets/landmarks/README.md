# Landmark demo photos

Generated with the built-in image generation tool on 2026-10-03. These are fictional recognition photos, not photographs of the map positions or real TAURON Arena neighbourhood places. Full prompts are in `prompts.json`.

- `red-shop.png`: red brick shop, striped awning and green door.
- `yellow-slide.png`: playground with a yellow slide.
- `blue-bus-stop.png`: blue glass bus shelter.

Parent **Walk together → Load demo landmarks** copies these into app-private storage and adds three independent fictional pins. It preserves existing points and edited demo points. Repeating the action adds only missing demo IDs. Demo records retain a visible fictional label after editing. No ordering, paths, routing or safety verification are encoded.

The UI decodes smaller thumbnails for the map and detail cards. Deleting demo copies does not remove these bundled source assets; reloading requires an explicit parent action.
