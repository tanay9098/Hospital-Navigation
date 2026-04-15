/**
 * Department model – SQLite-backed via SQLiteModel.
 *
 * workingHours is stored as three flat columns (wh_weekdays, wh_weekends,
 * wh_is_24x7) and reconstructed into the { weekdays, weekends, is24x7 }
 * shape by the post-processing in _rowToDoc (via jsonColumns on workingHours).
 *
 * Actually, for simplicity workingHours is stored as a JSON blob.
 * Specialties is also JSON (string array).
 */

const SQLiteModel = require('../db/SQLiteModel');

module.exports = new SQLiteModel({
  table: 'departments',
  columns: {
    id:           'id',
    name:         'name',
    shortName:    'short_name',
    locationCode: 'location_code',
    floor:        'floor',
    description:  'description',
    specialties:  'specialties',
    contactNumber:'contact_number',
    workingHours: 'working_hours',
    ivrMenuNumber:'ivr_menu_num',
    isActive:     'is_active',
    createdAt:    'created_at',
    updatedAt:    'updated_at',
  },
  jsonColumns:  ['specialties', 'workingHours'],
  textColumns:  ['name', 'description', 'specialties'],
  pk: 'id',
});
