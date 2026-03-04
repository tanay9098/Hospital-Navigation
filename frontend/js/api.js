/**
 * API wrapper for PES Hospital Navigation backend.
 * All paths are relative (/api/v1/...) because the frontend
 * is served directly by the Express backend – no CORS needed.
 */

const BASE = '/api/v1';

async function request(method, path, body) {
  const opts = {
    method,
    headers: { 'Content-Type': 'application/json' },
  };
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(BASE + path, opts);
  const json = await res.json();

  if (!res.ok) {
    throw new Error(json.message || `Request failed (${res.status})`);
  }
  return json;
}

/** Search locations by name/keyword. Returns array of location objects. */
async function searchLocations(query) {
  if (!query || query.trim().length < 2) return [];
  const data = await request('GET', `/locations/search?q=${encodeURIComponent(query.trim())}`);
  return data.data || [];
}

/** Get a single location by its code. */
async function getLocation(code) {
  const data = await request('GET', `/locations/${encodeURIComponent(code)}`);
  return data.data;
}

/**
 * Compute shortest route.
 * @param {string}  from        Location code (e.g. "GF-REC")
 * @param {string}  to          Location code (e.g. "3F-CARD")
 * @param {boolean} accessible  Avoid stairwells
 */
async function getRoute(from, to, accessible = false) {
  const data = await request('POST', '/navigation/route', { from, to, accessible });
  return data.data;
}

/** Get all departments on a given floor (0–8). */
async function getDepartmentsByFloor(floor) {
  const data = await request('GET', `/departments/floor/${floor}`);
  return data.data || [];
}

/** Get the full list of floors with department counts. */
async function getFloors() {
  const data = await request('GET', '/navigation/floors');
  return data.data || [];
}

/** Health check */
async function healthCheck() {
  return request('GET', '/health');
}
