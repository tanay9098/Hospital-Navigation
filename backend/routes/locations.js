const router = require('express').Router();
const ctrl   = require('../controllers/locationController');

router.get('/search',       ctrl.searchLocations);
router.get('/menu',         ctrl.getMenu);
router.get('/floor/:floor', ctrl.getLocationsByFloor);
router.get('/:code',        ctrl.getLocationByCode);
router.get('/',             ctrl.getAllLocations);
router.post('/',            ctrl.createLocation);
router.patch('/:code',      ctrl.updateLocation);

module.exports = router;
