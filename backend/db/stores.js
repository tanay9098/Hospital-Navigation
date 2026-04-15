/**
 * NeDB datastore singletons.
 * Each store maps 1-to-1 with a former Mongoose model / MongoDB collection.
 * Datastores are created here but NOT loaded until connectDB() is called.
 */

const Datastore = require('@seald-io/nedb');
const path      = require('path');

const DB_DIR = path.join(__dirname, '../data/nedb');

const locations   = new Datastore({ filename: path.join(DB_DIR, 'locations.db')   });
const departments = new Datastore({ filename: path.join(DB_DIR, 'departments.db') });
const ivrSessions = new Datastore({ filename: path.join(DB_DIR, 'ivrsessions.db') });

module.exports = { locations, departments, ivrSessions };
