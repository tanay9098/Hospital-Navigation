const mongoose = require('mongoose');

/**
 * Tracks the state of an active IVR (Interactive Voice Response) call session.
 * State machine steps the caller through: floor → location → destination → directions.
 */
const IVRSessionSchema = new mongoose.Schema(
  {
    // Twilio CallSid or any unique call identifier
    callSid: { type: String, required: true, unique: true, index: true },
    callerPhone: { type: String, default: 'unknown' },
    // Current step in the IVR navigation flow
    state: {
      type: String,
      enum: [
        'WELCOME',      // Initial greeting
        'FROM_FLOOR',   // Asking for source floor number
        'FROM_DEPT',    // Asking for source department on that floor
        'TO_FLOOR',     // Asking for destination floor
        'TO_DEPT',      // Asking for destination department
        'NAVIGATE',     // Reading out directions step by step
        'EMERGENCY',    // Emergency fast-track
        'DONE',         // Session complete
      ],
      default: 'WELCOME',
    },
    // Accumulated navigation choices
    fromFloor: { type: Number, default: null },
    fromLocationCode: { type: String, default: null },
    toFloor: { type: Number, default: null },
    toLocationCode: { type: String, default: null },
    // Step index when reading out directions one by one over IVR
    currentDirectionStep: { type: Number, default: 0 },
    // Cached serialised route so we don't re-compute on every key press
    cachedRoute: { type: mongoose.Schema.Types.Mixed, default: null },
    // Sessions auto-expire after 30 minutes of inactivity
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 30 * 60 * 1000),
      index: { expires: 0 },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('IVRSession', IVRSessionSchema);
