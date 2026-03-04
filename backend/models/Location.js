const mongoose = require('mongoose');

/**
 * Represents a single node in the hospital navigation graph.
 * A location can be a room, corridor, elevator, stairwell, or entrance.
 * Each location stores its adjacencies (edges) for Dijkstra pathfinding.
 */
const ConnectionSchema = new mongoose.Schema(
  {
    locationCode: { type: String, required: true },
    distance: { type: Number, required: true }, // metres (or seconds for vertical)
    direction: {
      type: String,
      enum: ['north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest', 'up', 'down'],
      required: true,
    },
  },
  { _id: false }
);

const LocationSchema = new mongoose.Schema(
  {
    // e.g. "GF-REC", "3F-CARD" – unique, human-readable identifier used by the graph
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    name: { type: String, required: true, trim: true },
    floor: { type: Number, required: true, min: 0, max: 8 },
    type: {
      type: String,
      enum: ['room', 'corridor', 'elevator', 'stairwell', 'entrance'],
      required: true,
    },
    category: {
      type: String,
      enum: ['department', 'facility', 'transit', 'administrative'],
      required: true,
    },
    description: { type: String, default: '' },
    // Relative 2-D position on the floor plan (arbitrary units, 0-100 scale)
    coordinates: {
      x: { type: Number, default: 0 },
      y: { type: Number, default: 0 },
    },
    // Adjacency list – populated by the seeder, bidirectional
    connections: [ConnectionSchema],
    // Whether this location is wheelchair / mobility-aid accessible
    isAccessible: { type: Boolean, default: true },
    // IVR keypad shortcut number for this location within its floor menu
    ivrMenuNumber: { type: Number, default: null },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

// Text index for free-text search
LocationSchema.index({ name: 'text', description: 'text' });
LocationSchema.index({ floor: 1, type: 1 });

module.exports = mongoose.model('Location', LocationSchema);
