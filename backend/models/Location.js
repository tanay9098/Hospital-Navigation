/**
 * Location model – SQLite-backed via SQLiteModel.
 *
 * Stored JSON columns: coordinates ({ x, y }), connections (array)
 * Text search columns: name, description
 */

const SQLiteModel = require('../db/SQLiteModel');

module.exports = new SQLiteModel({
  table: 'locations',
  columns: {
    id:           'id',
    code:         'code',
    name:         'name',
    floor:        'floor',
    type:         'type',
    category:     'category',
    description:  'description',
    coordinates:  'coordinates',
    connections:  'connections',
    isAccessible: 'is_accessible',
    ivrMenuNumber:'ivr_menu_num',
    isActive:     'is_active',
    createdAt:    'created_at',
    updatedAt:    'updated_at',
  },
  jsonColumns:  ['coordinates', 'connections'],
  textColumns:  ['name', 'description'],
  pk: 'id',
});
