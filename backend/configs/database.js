/**
 * Database initialisation – NeDB edition.
 *
 * Loads all three datastores from disk and creates the indexes that the
 * application depends on.  Called once at startup from server.js.
 */
const { locations, departments, ivrSessions } = require('../db/stores');

const connectDB = async () => {
  // Load datastore files from disk (creates them if they don't exist yet)
  await locations.loadDatabaseAsync();
  await departments.loadDatabaseAsync();
  await ivrSessions.loadDatabaseAsync();

  // Unique index on location code (replaces Mongoose unique:true)
  await locations.ensureIndexAsync({ fieldName: 'code', unique: true });
  // Unique index on IVR call ID
  await ivrSessions.ensureIndexAsync({ fieldName: 'callSid', unique: true });

  console.log('NeDB datastores loaded and indexed.');
};

module.exports = connectDB;
