/**
 * Location model – wraps the NeDB 'locations' datastore with a
 * Mongoose-compatible API via NeDBModel.
 *
 * Text search fields: name, description
 */
const NeDBModel = require('../db/NeDBModel');
const { locations } = require('../db/stores');

module.exports = new NeDBModel(locations, ['name', 'description']);
