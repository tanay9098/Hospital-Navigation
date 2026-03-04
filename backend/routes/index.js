const router = require('express').Router();

// Health check
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'PES Hospital Navigation API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

router.use('/locations',   require('./locations'));
router.use('/departments', require('./departments'));
router.use('/navigation',  require('./navigation'));
router.use('/ivr',         require('./ivr'));

module.exports = router;
