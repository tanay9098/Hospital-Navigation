/**
 * start.js – All-in-one launcher
 * --------------------------------
 * 1. Seeds hospital.db with the hospital blueprint on first run.
 * 2. Starts the Express server.
 *
 * Data is stored in backend/data/hospital.db (SQLite file).
 * Run:  node start.js   (or: npm start)
 */

require('dotenv').config();
const { spawn } = require('child_process');
const path      = require('path');
const fs        = require('fs');
const { DB_FILE } = require('./db/sqlite');

async function main() {
  const needsSeed = !fs.existsSync(DB_FILE) || fs.statSync(DB_FILE).size === 0;

  if (needsSeed) {
    console.log('[1/2] Seeding hospital blueprint into SQLite...\n');

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
    console.log('[1/1] SQLite DB found. Starting Express server...\n');
  }

  require('./server');
}

main().catch((err) => {
  console.error('\nFailed to start:', err.message);
  process.exit(1);
});
