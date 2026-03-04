const { handleWelcome, handleGather } = require('../services/ivrService');

/**
 * POST /api/v1/ivr/webhook
 * Twilio calls this when a new call is received.
 * Responds with TwiML XML.
 */
exports.webhook = async (req, res, next) => {
  try {
    const callSid     = req.body.CallSid    || req.body.callSid    || 'unknown';
    const callerPhone = req.body.From       || req.body.from       || 'unknown';

    const xml = await handleWelcome(callSid, callerPhone);

    res.set('Content-Type', 'text/xml');
    res.send(xml);
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/v1/ivr/gather
 * Twilio posts here when the user presses a key (DTMF gather).
 */
exports.gather = async (req, res, next) => {
  try {
    const callSid = req.body.CallSid || req.body.callSid || 'unknown';
    const digit   = req.body.Digits  || req.body.digits  || '';

    const xml = await handleGather(callSid, digit.charAt(0));

    res.set('Content-Type', 'text/xml');
    res.send(xml);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/v1/ivr/menu
 * Returns the IVR menu structure as JSON (for debugging / documentation).
 */
exports.getMenuStructure = async (req, res) => {
  res.json({
    success: true,
    data: {
      description: 'PES Hospital IVR Navigation Menu Structure',
      entryPoint: 'POST /api/v1/ivr/webhook',
      gatherEndpoint: 'POST /api/v1/ivr/gather',
      flow: [
        { state: 'WELCOME',   options: { '1': 'Navigation', '2': 'Emergency', '9': 'Repeat' } },
        { state: 'FROM_FLOOR', options: { '0': 'Ground Floor', '1': 'Floor 1', '2': 'Floor 2', '3': 'Floor 3', '4': 'Floor 4', '5': 'Floor 5', '6': 'Floor 6', '7': 'Floor 7', '8': 'Floor 8' } },
        { state: 'FROM_DEPT', options: 'Dynamic – based on floor selection (1–9, 0 = back)' },
        { state: 'TO_FLOOR',  options: { '0-8': 'Floor selection', '0': 'Back' } },
        { state: 'TO_DEPT',   options: 'Dynamic – based on floor selection' },
        { state: 'NAVIGATE',  options: { '1': 'Next step', '2': 'Repeat step', '0': 'Restart' } },
      ],
    },
  });
};
