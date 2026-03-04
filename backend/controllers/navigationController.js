const { getRoute, searchLocations, getDestinationMenu } = require('../services/navigationService');

/**
 * POST /api/v1/navigation/route
 * Body: { from: "GF-REC", to: "3F-CARD", accessible: false }
 *
 * Returns full step-by-step directions + voice script.
 */
exports.getRoute = async (req, res, next) => {
  try {
    const { from, to, accessible } = req.body;

    if (!from || !to) {
      return res.status(400).json({
        success: false,
        message: 'Both "from" and "to" location codes are required.',
      });
    }

    const route = await getRoute(
      from.trim().toUpperCase(),
      to.trim().toUpperCase(),
      accessible === true || accessible === 'true'
    );

    res.json({ success: true, data: route });
  } catch (err) {
    if (err.message.includes('not found') || err.message.includes('No navigable')) {
      return res.status(404).json({ success: false, message: err.message });
    }
    next(err);
  }
};

/**
 * GET /api/v1/navigation/search?q=cardiology
 * Quick location search for the navigation search bar.
 */
exports.searchLocations = async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Query must be at least 2 characters.',
      });
    }

    const locations = await searchLocations(q.trim());
    res.json({ success: true, count: locations.length, data: locations });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/v1/navigation/menu
 * All navigable destinations grouped by floor – used by mobile UI dropdowns.
 */
exports.getMenu = async (req, res, next) => {
  try {
    const menu = await getDestinationMenu();
    res.json({ success: true, data: menu });
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/v1/navigation/floors
 * Summary: which floors exist and how many departments are on each.
 */
exports.getFloors = async (req, res, next) => {
  try {
    const menu = await getDestinationMenu();
    const summary = menu.map(({ floor, floorName, locations }) => ({
      floor,
      floorName,
      departmentCount: locations.length,
    }));
    res.json({ success: true, data: summary });
  } catch (err) {
    next(err);
  }
};
