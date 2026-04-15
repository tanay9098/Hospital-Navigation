/**
 * IVRSession model – wraps the NeDB 'ivrsessions' datastore with a
 * Mongoose-compatible API via NeDBModel.
 *
 * Sessions expire naturally when the process restarts (in-process data only).
 * For a persistent setup, implement TTL cleanup in a cron or background task.
 */
const NeDBModel = require('../db/NeDBModel');
const { ivrSessions } = require('../db/stores');

module.exports = new NeDBModel(ivrSessions, []);
