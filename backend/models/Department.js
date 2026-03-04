const mongoose = require('mongoose');

/**
 * Rich metadata for hospital departments / facilities.
 * Links to the Location node via locationCode for navigation.
 */
const DepartmentSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    shortName: { type: String, trim: true },
    // The Location.code of this department's physical entrance
    locationCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    floor: { type: Number, required: true, min: 0, max: 8 },
    description: { type: String, default: '' },
    specialties: [{ type: String }],
    contactNumber: { type: String, default: '' },
    workingHours: {
      weekdays: { type: String, default: '8:00 AM – 6:00 PM' },
      weekends: { type: String, default: '9:00 AM – 1:00 PM' },
      is24x7: { type: Boolean, default: false },
    },
    // Number the user presses in the floor's IVR sub-menu to select this department
    ivrMenuNumber: { type: Number, default: null },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

DepartmentSchema.index({ name: 'text', description: 'text', specialties: 'text' });
DepartmentSchema.index({ floor: 1 });

module.exports = mongoose.model('Department', DepartmentSchema);
