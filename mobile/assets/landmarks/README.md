# Landmark demo photos

Generated with the built-in image generation tool on 2026-10-03. These are fictional recognition photos, not photographs of the map positions or real TAURON Arena neighbourhood places. Full prompts are in `prompts.json`.

- `red-shop.png`: red brick shop, striped awning and green door.
- `yellow-slide.png`: playground with a yellow slide.
- `blue-bus-stop.png`: blue glass bus shelter.

On first launch after a fresh installation, the app copies these into app-private storage and adds three independent fictional photo pins, plus one fictional **Home** practice place. Existing saved records, including empty saved records, are preserved. Interrupted first-launch setup can be retried without duplicating records. No child details or contacts are generated.

Parent **Walk together → Load demo landmarks** remains an explicit way to add missing photo pins. It preserves existing points and edited demo points. Repeating the action adds only missing demo IDs. Demo records retain a visible fictional label after editing. No ordering, paths, routing or safety verification are encoded. Home is a fictional practice pin, not a verified safe destination, and does not offer real walking guidance.

The UI decodes smaller thumbnails for the map and detail cards. Deleting demo copies or all saved details does not remove these bundled source assets and does not rerun first-launch setup; reloading photo points requires an explicit parent action.

`demo-home.png` was generated with built-in `image_gen` on 2026-10-03; its prompt is recorded in `prompts.json`. It is bundled display imagery for the fictional Home destination, alongside its home icon. It is not a photo landmark or a photograph of the pin's real location. Existing demo Home pins at the original seed position display the image without changing stored family records. Uploading personal photos to family targets remains future work.
