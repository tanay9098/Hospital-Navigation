/**
 * start.js – All-in-one launcher for local development
 * -------------------------------------------------------
 * 1. Seeds NeDB with the hospital blueprint (if not already seeded)
 * 2. Starts the Express server
 *
 * No external database required – NeDB stores data in backend/data/nedb/.
 * Run:  node start.js   (or: npm start)
 */

require('dotenv').config();
const { spawn } = require('child_process');
const path      = require('path');
const fs        = require('fs');

const DB_DIR        = path.join(__dirname, 'data/nedb');
const LOCATIONS_DB  = path.join(DB_DIR, 'locations.db');

async function main() {
  const alreadySeeded = fs.existsSync(LOCATIONS_DB) && fs.statSync(LOCATIONS_DB).size > 0;

  if (!alreadySeeded) {
    console.log('[1/2] Seeding hospital blueprint into NeDB...\n');

    await new Promise((resolve, reject) => {
      const seeder = spawn(process.execPath, ['data/seedDatabase.js'], {
        cwd: path.join(__dirname),
        env: { ...process.env },
        stdio: 'inherit',
      });

      seeder.on('close', (code) => {
        if (code === 0) resolve();
        else reject(new Error(`Seeder exited with code ${code}`));
      });
    });

    console.log('\n[2/2] Starting Express server...\n');
  } else {
    console.log('[1/1] NeDB already seeded. Starting Express server...\n');
  }

  // server.js calls connectDB() internally before listening
  require('./server');
}

main().catch((err) => {
  console.error('\nFailed to start:', err.message);
  process.exit(1);
});
