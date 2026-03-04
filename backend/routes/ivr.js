const router = require('express').Router();
const ctrl   = require('../controllers/ivrController');

// Twilio calls this when a new call arrives
router.post('/webhook', ctrl.webhook);

// Twilio calls this after every DTMF gather
router.post('/gather',  ctrl.gather);

// Documentation / debug endpoint
router.get('/menu',     ctrl.getMenuStructure);

module.exports = router;
