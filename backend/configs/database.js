/**
 * Database initialisation – SQLite edition.
 * Opens (or creates) backend/data/hospital.db and ensures the schema exists.
 * Called once at startup from server.js before the HTTP server starts.
 */

const { init, DB_FILE } = require('../db/sqlite');

const connectDB = async () => {
  init();
  console.log(`SQLite database ready: ${DB_FILE}`);
};

module.exports = connectDB;
