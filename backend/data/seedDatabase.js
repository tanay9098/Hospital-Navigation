/**
 * Database Seeder
 * ---------------
 * Populates MongoDB with the complete PES Hospital blueprint:
 *   – All location nodes (with bidirectional connections)
 *   – All department metadata
 *
 * Run:  npm run seed   OR   node data/seedDatabase.js
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const mongoose  = require('mongoose');
const Location  = require('../models/Location');
const Department= require('../models/Department');
const { locations, connections, departments } = require('./hospitalBlueprint');

// ── Direction reversal map ────────────────────────────────────────────────────
const REVERSE = {
  north: 'south', south: 'north',
  east:  'west',  west:  'east',
  northeast: 'southwest', southwest: 'northeast',
  northwest: 'southeast', southeast: 'northwest',
  up: 'down', down: 'up',
};

async function seed() {
  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/pes_hospital_nav';
  await mongoose.connect(uri);
  console.log('Connected to MongoDB:', uri);

  // ── Clear existing data ───────────────────────────────────────────────────
  await Location.deleteMany({});
  await Department.deleteMany({});
  console.log('Cleared existing Location and Department documents.');

  // ── Build adjacency map from the connection list ──────────────────────────
  // adjacencyMap: { code: [{ locationCode, distance, direction }] }
  const adjacencyMap = {};

  for (const [from, to, dist, dir] of connections) {
    if (!adjacencyMap[from]) adjacencyMap[from] = [];
    if (!adjacencyMap[to])   adjacencyMap[to]   = [];

    adjacencyMap[from].push({ locationCode: to,   distance: dist, direction: dir });
    adjacencyMap[to].push  ({ locationCode: from, distance: dist, direction: REVERSE[dir] || dir });
  }

  // ── Insert locations with their connections ───────────────────────────────
  const locationDocs = locations.map((loc) => ({
    ...loc,
    connections: adjacencyMap[loc.code] || [],
  }));

  await Location.insertMany(locationDocs);
  console.log(`Inserted ${locationDocs.length} locations.`);

  // ── Insert departments ────────────────────────────────────────────────────
  await Department.insertMany(departments);
  console.log(`Inserted ${departments.length} departments.`);

  // ── Summary ───────────────────────────────────────────────────────────────
  const totalEdges = Object.values(adjacencyMap).reduce((s, arr) => s + arr.length, 0);
  console.log(`\n✓ Seed complete.`);
  console.log(`  Locations : ${locationDocs.length}`);
  console.log(`  Edges     : ${totalEdges} (bidirectional)`);
  console.log(`  Departments: ${departments.length}`);

  // Quick sanity check: find a route by looking at adjacency
  const gfCor = adjacencyMap['GF-COR'] || [];
  console.log(`\n  Ground Floor Central Corridor connects to ${gfCor.length} neighbour(s).`);

  await mongoose.disconnect();
  console.log('Disconnected. Done.\n');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
