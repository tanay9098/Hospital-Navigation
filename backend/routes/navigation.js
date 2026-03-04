const router = require('express').Router();
const ctrl   = require('../controllers/navigationController');

// POST /api/v1/navigation/route  { from, to, accessible }
router.post('/route',  ctrl.getRoute);

// GET  /api/v1/navigation/search?q=...
router.get('/search',  ctrl.searchLocations);

// GET  /api/v1/navigation/menu  – all destinations grouped by floor
router.get('/menu',    ctrl.getMenu);

// GET  /api/v1/navigation/floors – floor list with department counts
router.get('/floors',  ctrl.getFloors);

module.exports = router;
