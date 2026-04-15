/**
 * Department model – wraps the NeDB 'departments' datastore with a
 * Mongoose-compatible API via NeDBModel.
 *
 * Text search fields: name, description, specialties
 */
const NeDBModel = require('../db/NeDBModel');
const { departments } = require('../db/stores');

module.exports = new NeDBModel(departments, ['name', 'description', 'specialties']);
