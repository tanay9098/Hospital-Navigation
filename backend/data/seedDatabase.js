/**
 * Database Seeder – SQLite edition
 * ----------------------------------
 * Populates hospital.db with the complete PES Hospital blueprint:
 *   – All location nodes (with bidirectional connections)
 *   – All department metadata
 *
 * Run:  npm run seed   OR   node data/seedDatabase.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const connectDB    = require('../configs/database');
const Location     = require('../models/Location');
const Department   = require('../models/Department');
const { locations, connections, departments } = require('./hospitalBlueprint');

const REVERSE = {
  north: 'south', south: 'north',
  east:  'west',  west:  'east',
  northeast: 'southwest', southwest: 'northeast',
  northwest: 'southeast', southeast: 'northwest',
  up: 'down', down: 'up',
};

async function seed() {
  await connectDB();

  // ── Clear existing data ───────────────────────────────────────────────────
  await Location.deleteMany({});
  await Department.deleteMany({});
  console.log('Cleared existing data.');

  // ── Build bidirectional adjacency map ─────────────────────────────────────
  const adjacencyMap = {};

  for (const [from, to, dist, dir] of connections) {
    if (!adjacencyMap[from]) adjacencyMap[from] = [];
    if (!adjacencyMap[to])   adjacencyMap[to]   = [];

    adjacencyMap[from].push({ locationCode: to,   distance: dist, direction: dir });
    adjacencyMap[to].push  ({ locationCode: from, distance: dist, direction: REVERSE[dir] || dir });
  }

  // ── Insert locations ──────────────────────────────────────────────────────
  const locationDocs = locations.map((loc) => ({
    isActive:     true,
    isAccessible: true,
    description:  '',
    ivrMenuNumber:null,
    coordinates:  { x: 0, y: 0 },
    ...loc,
    connections: adjacencyMap[loc.code] || [],
  }));

  await Location.insertMany(locationDocs);
  console.log(`Inserted ${locationDocs.length} locations.`);

  // ── Insert departments ────────────────────────────────────────────────────
  const departmentDocs = departments.map((dept) => ({
    isActive:      true,
    description:   '',
    specialties:   [],
    contactNumber: '',
    ivrMenuNumber: null,
    workingHours: {
      weekdays: '8:00 AM – 6:00 PM',
      weekends: '9:00 AM – 1:00 PM',
      is24x7:   false,
    },
    ...dept,
  }));

  await Department.insertMany(departmentDocs);
  console.log(`Inserted ${departmentDocs.length} departments.`);

  const totalEdges = Object.values(adjacencyMap).reduce((s, a) => s + a.length, 0);
  console.log(`\n✓ Seed complete.`);
  console.log(`  Locations  : ${locationDocs.length}`);
  console.log(`  Edges      : ${totalEdges} (bidirectional)`);
  console.log(`  Departments: ${departmentDocs.length}`);

  const gfCor = adjacencyMap['GF-COR'] || [];
  console.log(`\n  Ground Floor Central Corridor → ${gfCor.length} neighbours.`);
  console.log('Done.\n');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
