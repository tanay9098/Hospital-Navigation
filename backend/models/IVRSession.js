/**
 * IVRSession model – SQLite-backed via SQLiteModel.
 *
 * Primary key is callSid (Twilio call ID), not a UUID.
 * cachedRoute is stored as a JSON blob.
 */

const SQLiteModel = require('../db/SQLiteModel');

const model = new SQLiteModel({
  table: 'ivr_sessions',
  columns: {
    id:                   'id',           // unused pk slot; callSid is logical PK
    callSid:              'call_sid',
    callerPhone:          'caller_phone',
    state:                'state',
    fromFloor:            'from_floor',
    fromLocationCode:     'from_location_code',
    toFloor:              'to_floor',
    toLocationCode:       'to_location_code',
    currentDirectionStep: 'current_direction_step',
    cachedRoute:          'cached_route',
    expiresAt:            'expires_at',
    createdAt:            'created_at',
    updatedAt:            'updated_at',
  },
  jsonColumns: ['cachedRoute'],
  textColumns: [],
  pk: 'callSid',   // use callSid as the logical primary key
});

// Override create so we don't need a separate UUID id — call_sid IS the PK
const origCreate = model.create.bind(model);
model.create = async function (doc) {
  const { getDB } = require('../db/sqlite');
  const row = {
    call_sid:               doc.callSid,
    caller_phone:           doc.callerPhone || 'unknown',
    state:                  doc.state || 'WELCOME',
    from_floor:             doc.fromFloor ?? null,
    from_location_code:     doc.fromLocationCode ?? null,
    to_floor:               doc.toFloor ?? null,
    to_location_code:       doc.toLocationCode ?? null,
    current_direction_step: doc.currentDirectionStep || 0,
    cached_route:           doc.cachedRoute ? JSON.stringify(doc.cachedRoute) : null,
    expires_at:             doc.expiresAt ? doc.expiresAt.toISOString?.() || doc.expiresAt : null,
  };
  getDB().prepare(`
    INSERT INTO ivr_sessions (${Object.keys(row).join(',')})
    VALUES (${Object.keys(row).map(() => '?').join(',')})
  `).run(...Object.values(row));
  return this._attachSave(this._findOne({ callSid: doc.callSid }));
};

module.exports = model;
