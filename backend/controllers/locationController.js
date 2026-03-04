const Location = require('../models/Location');
const { searchLocations, getDestinationMenu, clearCache } = require('../services/navigationService');

// GET /api/v1/locations
exports.getAllLocations = async (req, res, next) => {
  try {
    const { type, category, accessible } = req.query;
    const filter = { isActive: true };
    if (type)       filter.type     = type;
    if (category)   filter.category = category;
    if (accessible === 'true') filter.isAccessible = true;

    const locations = await Location.find(filter, '-connections')
      .sort({ floor: 1, name: 1 })
      .lean();

    res.json({ success: true, count: locations.length, data: locations });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/locations/floor/:floor
exports.getLocationsByFloor = async (req, res, next) => {
  try {
    const floor = parseInt(req.params.floor, 10);
    if (isNaN(floor) || floor < 0 || floor > 8) {
      return res.status(400).json({ success: false, message: 'Floor must be a number between 0 and 8.' });
    }

    const locations = await Location.find({ floor, isActive: true }, '-connections')
      .sort({ name: 1 })
      .lean();

    res.json({ success: true, floor, count: locations.length, data: locations });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/locations/search?q=cardiology
exports.searchLocations = async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'Search query must be at least 2 characters.' });
    }

    const locations = await searchLocations(q.trim());
    res.json({ success: true, count: locations.length, data: locations });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/locations/menu  – grouped by floor for UI/IVR dropdowns
exports.getMenu = async (req, res, next) => {
  try {
    const menu = await getDestinationMenu();
    res.json({ success: true, data: menu });
  } catch (err) {
    next(err);
  }
};

// GET /api/v1/locations/:code
exports.getLocationByCode = async (req, res, next) => {
  try {
    const location = await Location.findOne({
      code: req.params.code.toUpperCase(),
      isActive: true,
    }).lean();

    if (!location) {
      return res.status(404).json({ success: false, message: `Location "${req.params.code}" not found.` });
    }

    res.json({ success: true, data: location });
  } catch (err) {
    next(err);
  }
};

// POST /api/v1/locations  (admin – create a location and invalidate graph cache)
exports.createLocation = async (req, res, next) => {
  try {
    const location = await Location.create(req.body);
    clearCache();
    res.status(201).json({ success: true, data: location });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/v1/locations/:code
exports.updateLocation = async (req, res, next) => {
  try {
    const location = await Location.findOneAndUpdate(
      { code: req.params.code.toUpperCase() },
      req.body,
      { new: true, runValidators: true }
    );

    if (!location) {
      return res.status(404).json({ success: false, message: `Location "${req.params.code}" not found.` });
    }

    clearCache();
    res.json({ success: true, data: location });
  } catch (err) {
    next(err);
  }
};
