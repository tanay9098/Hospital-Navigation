const Location = require('../models/Location');
const dijkstra = require('../utils/dijkstra');
const { generateDirections } = require('../utils/directionsGenerator');

// In-memory graph cache: { code: [{ code, weight, direction, isStairwell }] }
let _graphCache = null;
let _locationCache = null; // code → Location doc

/**
 * Load and cache the full hospital graph from MongoDB.
 * Invalidate by calling clearCache().
 */
async function loadGraph() {
  if (_graphCache) return { graph: _graphCache, locationMap: _locationCache };

  const locations = await Location.find({ isActive: true }).lean();

  const graph = {};
  const locationMap = {};

  for (const loc of locations) {
    locationMap[loc.code] = loc;
    graph[loc.code] = (loc.connections || []).map((conn) => ({
      code: conn.locationCode,
      weight: conn.distance,
      direction: conn.direction,
      isStairwell: false, // will refine below
    }));
  }

  // Mark stairwell edges so Dijkstra can skip them on accessible-only routes
  for (const loc of locations) {
    if (loc.type === 'stairwell') {
      for (const edge of graph[loc.code] || []) {
        edge.isStairwell = true;
      }
      // Also mark edges going INTO stairwells
      for (const edges of Object.values(graph)) {
        for (const edge of edges) {
          if (edge.code === loc.code) edge.isStairwell = true;
        }
      }
    }
  }

  _graphCache = graph;
  _locationCache = locationMap;

  return { graph, locationMap };
}

function clearCache() {
  _graphCache = null;
  _locationCache = null;
}

/**
 * Core navigation function.
 *
 * @param {string}  fromCode         Source location code (e.g. "GF-REC")
 * @param {string}  toCode           Destination location code (e.g. "3F-CARD")
 * @param {boolean} accessibleOnly   Avoid stairwells (use lifts only)
 * @returns {Object}  Full navigation response
 */
async function getRoute(fromCode, toCode, accessibleOnly = false) {
  const { graph, locationMap } = await loadGraph();

  const fromLoc = locationMap[fromCode];
  const toLoc   = locationMap[toCode];

  if (!fromLoc) throw new Error(`Source location "${fromCode}" not found.`);
  if (!toLoc)   throw new Error(`Destination location "${toCode}" not found.`);

  const result = dijkstra(graph, fromCode, toCode, accessibleOnly);

  if (!result.found) {
    throw new Error(`No navigable path from "${fromLoc.name}" to "${toLoc.name}".`);
  }

  // Hydrate the path with full location documents
  const pathLocations = result.path.map((code) => locationMap[code]);

  const { steps, voiceScript, textSummary } = generateDirections(pathLocations);

  // Estimate walking time: 1 m/s walking + 60 s per elevator floor change
  const walkingTime = Math.ceil(result.distance / 1); // seconds

  return {
    from: { code: fromLoc.code, name: fromLoc.name, floor: fromLoc.floor },
    to:   { code: toLoc.code,   name: toLoc.name,   floor: toLoc.floor   },
    distance:      result.distance,
    estimatedTime: walkingTime,       // seconds
    estimatedTimeText: formatTime(walkingTime),
    accessible:    accessibleOnly,
    totalSteps:    steps.length,
    steps,
    voiceScript,
    textSummary,
  };
}

/**
 * Search locations by partial name or department keyword.
 */
async function searchLocations(query) {
  const locations = await Location.find(
    { $text: { $search: query }, isActive: true },
    { score: { $meta: 'textScore' } }
  )
    .sort({ score: { $meta: 'textScore' } })
    .limit(10)
    .lean();

  return locations;
}

/**
 * Return a flat list of navigable destinations grouped by floor.
 * Excludes pure transit nodes (corridors, elevators, stairwells).
 */
async function getDestinationMenu() {
  const locations = await Location.find(
    { isActive: true, type: { $in: ['room', 'entrance'] } },
    'code name floor type category ivrMenuNumber isAccessible'
  )
    .sort({ floor: 1, name: 1 })
    .lean();

  // Group by floor
  const floors = {};
  for (const loc of locations) {
    if (!floors[loc.floor]) floors[loc.floor] = [];
    floors[loc.floor].push(loc);
  }

  return Object.entries(floors).map(([floor, locs]) => ({
    floor: Number(floor),
    floorName: floorLabel(Number(floor)),
    locations: locs,
  }));
}

// ── helpers ──────────────────────────────────────────────────────────────────

function formatTime(seconds) {
  if (seconds < 60) return `${seconds} seconds`;
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return secs ? `${mins} min ${secs} sec` : `${mins} min`;
}

function floorLabel(floor) {
  if (floor === 0) return 'Ground Floor';
  const suffix = ['th', 'st', 'nd', 'rd'];
  const v = floor % 100;
  return floor + (suffix[(v - 20) % 10] || suffix[v] || suffix[0]) + ' Floor';
}

module.exports = { getRoute, searchLocations, getDestinationMenu, clearCache, floorLabel };
