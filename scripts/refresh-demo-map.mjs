import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { parseArgs } from 'node:util';
import osmtogeojson from 'osmtogeojson';
import bboxClip from '@turf/bbox-clip';
import rewind from '@turf/rewind';

// Official arena GPS location. WGS84 degree lengths keep this rectangle ~2 km square.
const center = [19 + 59 / 60 + 30.1 / 3600, 50 + 4 / 60 + 2.89 / 3600];
const latitudeRadians = center[1] * Math.PI / 180;
const metersPerLatitudeDegree = 111132.92 - 559.82 * Math.cos(2 * latitudeRadians)
  + 1.175 * Math.cos(4 * latitudeRadians) - 0.0023 * Math.cos(6 * latitudeRadians);
const metersPerLongitudeDegree = 111412.84 * Math.cos(latitudeRadians)
  - 93.5 * Math.cos(3 * latitudeRadians) + 0.118 * Math.cos(5 * latitudeRadians);
const bbox = [
  center[0] - 1000 / metersPerLongitudeDegree, center[1] - 1000 / metersPerLatitudeDegree,
  center[0] + 1000 / metersPerLongitudeDegree, center[1] + 1000 / metersPerLatitudeDegree,
];
const overpassBounds = [bbox[1], bbox[0], bbox[3], bbox[2]].join(',');
const selectors = [
  'way[highway]', 'nwr[building]', 'nwr[landuse]', 'nwr[leisure]',
  'nwr[natural~"^(water|wood|scrub|grassland|wetland)$"]', 'nwr[waterway]',
  'way[railway]', 'nwr[amenity]', 'nwr[shop]', 'nwr[tourism]', 'nwr[public_transport]',
];
const query = `[out:json][timeout:60];\n(\n${selectors.map((selector) => `  ${selector}(${overpassBounds});`).join('\n')}\n);\nout body; >; out skel qt;\n`;
const { values } = parseArgs({ options: { input: { type: 'string' }, 'source-url': { type: 'string' } } });
const endpoint = 'https://overpass-api.de/api/interpreter';
const osmEndpoint = `https://api.openstreetmap.org/api/0.6/map.json?bbox=${bbox.join(',')}`;
let sourceEndpoint = values['source-url'] ?? endpoint;

async function fetchMap() {
  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'User-Agent': 'HackYeah-DoBazy-Demo/0.1' },
      body: new URLSearchParams({ data: query }),
      signal: AbortSignal.timeout(70_000),
    });
    if (!response.ok) throw new Error(`Overpass returned HTTP ${response.status}`);
    const osm = await response.json();
    if (osm.remark) throw new Error(osm.remark);
    return osm;
  } catch (error) {
    console.warn(`Overpass unavailable (${error.message}); trying the OSM bounding-box API.`);
    sourceEndpoint = osmEndpoint;
    const response = await fetch(osmEndpoint, { signal: AbortSignal.timeout(60_000) });
    if (!response.ok) throw new Error(`OSM API returned HTTP ${response.status}`);
    return response.json();
  }
}

function mapLayer(tags) {
  if (tags.building && tags.building !== 'no') return 'building';
  if (tags.highway) return 'road';
  if (tags.railway) return 'railway';
  if (tags.natural === 'water' || tags.waterway || tags.landuse === 'reservoir') return 'water';
  if (tags.leisure || ['wood', 'scrub', 'grassland', 'wetland'].includes(tags.natural)
    || ['grass', 'forest', 'meadow', 'recreation_ground', 'village_green'].includes(tags.landuse)) return 'park';
  if (tags.landuse) return 'landuse';
  return 'poi';
}

function clipFeature(feature) {
  const tags = feature.properties.tags ?? {};
  // Relation helper nodes/ways are not separate game features.
  if (feature.properties.tainted) return null;
  const selected = tags.highway || tags.building || tags.landuse || tags.leisure
    || ['water', 'wood', 'scrub', 'grassland', 'wetland'].includes(tags.natural)
    || tags.waterway || tags.railway || tags.amenity || tags.shop || tags.tourism || tags.public_transport;
  if (!selected) return null;
  const type = feature.geometry.type;
  let clipped;
  if (type === 'Point') {
    const [longitude, latitude] = feature.geometry.coordinates;
    if (longitude < bbox[0] || longitude > bbox[2] || latitude < bbox[1] || latitude > bbox[3]) return null;
    clipped = feature;
  } else if (['LineString', 'MultiLineString', 'Polygon', 'MultiPolygon'].includes(type)) {
    clipped = bboxClip(feature, bbox);
    if (!clipped.geometry.coordinates.length) return null;
    clipped = rewind(clipped);
  } else {
    throw new Error(`Unexpected geometry: ${type}`);
  }
  return {
    type: 'Feature', id: feature.id,
    properties: { ...tags, osmId: feature.id, layer: mapLayer(tags) },
    geometry: clipped.geometry,
  };
}

const osm = values.input ? JSON.parse(await readFile(values.input, 'utf8')) : await fetchMap();
if (osm.remark) throw new Error(`Incomplete Overpass response: ${osm.remark}`);
if (!Array.isArray(osm.elements) || !osm.elements.length) throw new Error('Empty Overpass response');
const features = osmtogeojson(osm, { flatProperties: false }).features.map(clipFeature).filter(Boolean);
if (!features.some((feature) => feature.id === 'way/292867512')) throw new Error('Tauron Arena missing from snapshot');
const counts = {};
for (const feature of features) counts[feature.properties.layer] = (counts[feature.properties.layer] ?? 0) + 1;
const collection = {
  type: 'FeatureCollection', bbox,
  metadata: {
    id: 'tauron-arena-2km', name: 'TAURON Arena Kraków — 2 × 2 km',
    center, widthMeters: 2000, heightMeters: 2000,
    mockApi: true, dataSource: 'OpenStreetMap',
    attribution: '© OpenStreetMap contributors', license: 'ODbL-1.0',
    licenseUrl: 'https://www.openstreetmap.org/copyright',
    centerSourceUrl: 'https://www.tauronarenakrakow.pl/en/how-to-get-there/',
    endpoint: sourceEndpoint, downloadedAt: new Date().toISOString(),
    osmTimestamp: osm.osm3s?.timestamp_osm_base ?? null, featureCounts: counts,
  },
  features,
};
const json = `${JSON.stringify(collection)}\n`;
const mobileData = new URL('../mobile/assets/maps/', import.meta.url);
await mkdir(mobileData, { recursive: true });
await writeFile(new URL('tauron-arena.geojson', mobileData), json);
await writeFile(new URL('tauron-arena.overpassql', mobileData), query);
console.log(JSON.stringify({ features: features.length, bytes: Buffer.byteLength(json), layers: counts, bbox }, null, 2));
