# Tauron Arena demo map

`tauron-arena.geojson` is a real OpenStreetMap snapshot bundled with the Android game for offline play. No API key or runtime server is needed.

- Center: **19.99169444° E, 50.06746944° N**, from the [arena's official GPS coordinates](https://www.tauronarenakrakow.pl/en/how-to-get-there/).
- Area: approximately **2,000 × 2,000 meters**, one kilometer each side of the center. The WGS84 bounding box uses local ellipsoid degree lengths; geometry is clipped at its edges.
- Coordinate order: `[longitude, latitude]`. Bounding box: `[west, south, east, north]`.
- Layers: `building`, `road`, `railway`, `water`, `park`, `landuse`, `poi`. Original OSM tags and stable OSM feature IDs are retained.
- `metadata` records the source URL, download time, area, attribution, and feature counts. The legacy `mockApi: true` field means a fixed snapshot; the geographic features are real.

The Android scene starts at the arena, renders this geography, and uses a fictional base in the northeast. Character movement is free across the map; road routing, building collisions, GPS, and resource simulation are outside this phase.

## Refresh

From the workspace root:

```sh
pnpm maps:refresh
```

This downloads OSM data using Overpass, converts it to GeoJSON, clips it, and writes the bundled snapshot and query in this directory. If Overpass is unavailable, it tries the official OSM bounding-box API. The game never accesses either external service. Rebuild/reload the mobile app after refreshing.

To convert a previously downloaded OSM JSON export:

```sh
pnpm maps:refresh --input /path/to/osm.json --source-url https://example.com/original-export
```

The accompanying `tauron-arena.overpassql` documents the feature query. Incomplete OSM geometries are omitted. The initial fixture uses the official OSM API because Overpass was unreachable.

## Attribution

Map data **© OpenStreetMap contributors**, available under the **Open Database License (ODbL) 1.0**. Preserve attribution when displaying the map and the license notice when redistributing the dataset. [OpenStreetMap copyright and license](https://www.openstreetmap.org/copyright).
