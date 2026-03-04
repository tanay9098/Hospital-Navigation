/**
 * IVR Service – manages call session state and generates TwiML XML responses.
 *
 * Compatible with Twilio's TwiML standard. The webhook endpoint at
 * POST /api/v1/ivr/webhook is the entry point for every call.
 *
 * State machine:
 *   WELCOME → FROM_FLOOR → FROM_DEPT → TO_FLOOR → TO_DEPT → NAVIGATE → DONE
 *                                  ↘ EMERGENCY (shortcut)
 */

const IVRSession = require('../models/IVRSession');
const Location   = require('../models/Location');
const { getRoute, floorLabel } = require('./navigationService');
const { generateIVRScript }    = require('../utils/directionsGenerator');

const HOSPITAL_NAME = process.env.HOSPITAL_NAME || 'PES Hospital Electronic City';
const BASE_URL      = process.env.API_BASE_URL   || 'http://localhost:5000';
const GATHER_URL    = `${BASE_URL}/api/v1/ivr/gather`;

// ── TwiML builders ────────────────────────────────────────────────────────────

function twiml(body) {
  return `<?xml version="1.0" encoding="UTF-8"?>\n<Response>\n${body}\n</Response>`;
}

function say(text, voice = 'alice') {
  return `  <Say voice="${voice}">${sanitise(text)}</Say>`;
}

function gather(numDigits, actionPath, prompt, voice = 'alice') {
  return `  <Gather numDigits="${numDigits}" action="${BASE_URL}${actionPath}" method="POST">
    <Say voice="${voice}">${sanitise(prompt)}</Say>
  </Gather>
  ${say('We did not receive any input. Please call again.')}`;
}

function pause(seconds = 1) {
  return `  <Pause length="${seconds}"/>`;
}

function sanitise(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

// ── Session helpers ───────────────────────────────────────────────────────────

async function getOrCreateSession(callSid, callerPhone) {
  let session = await IVRSession.findOne({ callSid });
  if (!session) {
    session = await IVRSession.create({ callSid, callerPhone, state: 'WELCOME' });
  }
  return session;
}

// ── Floor / department menus ──────────────────────────────────────────────────

async function getFloorLocations(floor) {
  return Location.find(
    { floor, isActive: true, type: { $in: ['room', 'entrance'] }, ivrMenuNumber: { $ne: null } },
    'code name ivrMenuNumber isAccessible'
  ).sort({ ivrMenuNumber: 1 }).lean();
}

function buildFloorMenu() {
  const floors = [
    '0 for Ground Floor',
    '1 for Floor 1 – OPD Block A',
    '2 for Floor 2 – OPD Block B',
    '3 for Floor 3 – Cardiology',
    '4 for Floor 4 – Gynecology',
    '5 for Floor 5 – Neurology and Psychiatry',
    '6 for Floor 6 – Surgery',
    '7 for Floor 7 – Oncology',
    '8 for Floor 8 – Administration',
  ];
  return 'Press ' + floors.join('. Press ') + '.';
}

function buildDepartmentMenu(locations) {
  return locations
    .map((l) => `Press ${l.ivrMenuNumber} for ${l.name}`)
    .join('. ') + '.';
}

// ── Main state-machine handlers ───────────────────────────────────────────────

/**
 * Initial call webhook – greet and start the flow.
 */
async function handleWelcome(callSid, callerPhone) {
  const session = await getOrCreateSession(callSid, callerPhone);
  session.state = 'FROM_FLOOR';
  await session.save();

  const prompt =
    `Welcome to ${HOSPITAL_NAME} Navigation System. ` +
    `Press 1 for Navigation Assistance. ` +
    `Press 2 for Emergency. ` +
    `Press 9 to repeat this menu.`;

  return twiml(gather(1, '/api/v1/ivr/gather', prompt));
}

/**
 * Handle a DTMF digit and advance the state machine.
 */
async function handleGather(callSid, digit) {
  const session = await IVRSession.findOne({ callSid });
  if (!session) return twiml(say('Session expired. Please call again.'));

  switch (session.state) {

    case 'WELCOME':
    case 'FROM_FLOOR': {
      if (digit === '2') {
        session.state = 'EMERGENCY';
        await session.save();
        return twiml(
          say(`Emergency detected. Please proceed immediately to the Emergency Department on the Ground Floor near the Main Entrance. If you need an ambulance, stay on the line.`) +
          '\n  <Hangup/>'
        );
      }
      if (digit === '9' || digit === '1') {
        session.state = 'FROM_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Please select your CURRENT floor number. ${buildFloorMenu()}`));
      }
      // Unexpected digit in welcome – re-prompt
      return twiml(gather(1, '/api/v1/ivr/gather',
        `Press 1 for Navigation, or 2 for Emergency.`));
    }

    // Expecting floor digit 0-8 for the FROM location
    case 'FROM_FLOOR': {
      const floor = parseInt(digit, 10);
      if (isNaN(floor) || floor < 0 || floor > 8) {
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Invalid floor. ${buildFloorMenu()}`));
      }
      session.fromFloor = floor;
      session.state = 'FROM_DEPT';
      await session.save();

      const depts = await getFloorLocations(floor);
      if (depts.length === 0) {
        session.state = 'FROM_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `No selectable locations on Floor ${floor}. ${buildFloorMenu()}`));
      }

      return twiml(gather(1, '/api/v1/ivr/gather',
        `You selected Floor ${floor}. ${buildDepartmentMenu(depts)} Press 0 to go back.`));
    }

    // Expecting department number for the FROM location
    case 'FROM_DEPT': {
      if (digit === '0') {
        session.state = 'FROM_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Going back. ${buildFloorMenu()}`));
      }
      const num = parseInt(digit, 10);
      const depts = await getFloorLocations(session.fromFloor);
      const chosen = depts.find((d) => d.ivrMenuNumber === num);
      if (!chosen) {
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Invalid selection. ${buildDepartmentMenu(depts)} Press 0 to go back.`));
      }
      session.fromLocationCode = chosen.code;
      session.state = 'TO_FLOOR';
      await session.save();

      return twiml(gather(1, '/api/v1/ivr/gather',
        `You are at ${chosen.name}. Now select your DESTINATION floor. ${buildFloorMenu()}`));
    }

    // Expecting floor digit 0-8 for the TO location
    case 'TO_FLOOR': {
      const floor = parseInt(digit, 10);
      if (isNaN(floor) || floor < 0 || floor > 8) {
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Invalid floor. ${buildFloorMenu()}`));
      }
      session.toFloor = floor;
      session.state = 'TO_DEPT';
      await session.save();

      const depts = await getFloorLocations(floor);
      if (depts.length === 0) {
        session.state = 'TO_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `No selectable destinations on Floor ${floor}. ${buildFloorMenu()}`));
      }

      return twiml(gather(1, '/api/v1/ivr/gather',
        `Destination floor ${floor}. ${buildDepartmentMenu(depts)} Press 0 to go back.`));
    }

    // Expecting department number for the TO location
    case 'TO_DEPT': {
      if (digit === '0') {
        session.state = 'TO_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Going back. ${buildFloorMenu()}`));
      }
      const num = parseInt(digit, 10);
      const depts = await getFloorLocations(session.toFloor);
      const chosen = depts.find((d) => d.ivrMenuNumber === num);
      if (!chosen) {
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Invalid selection. ${buildDepartmentMenu(depts)} Press 0 to go back.`));
      }
      session.toLocationCode = chosen.code;
      session.currentDirectionStep = 0;
      session.state = 'NAVIGATE';
      await session.save();

      // Compute route and cache it
      try {
        const route = await getRoute(session.fromLocationCode, session.toLocationCode, false);
        session.cachedRoute = route;
        await session.save();

        const totalSteps = route.steps.length;
        const firstStep  = route.steps[0];

        return twiml(
          say(`Route found. ${totalSteps} steps to ${chosen.name}. Estimated time: ${route.estimatedTimeText}.`) +
          '\n' + pause(1) +
          '\n' + gather(1, '/api/v1/ivr/gather',
            `Step 1: ${firstStep.voice} Press 1 for the next step. Press 2 to repeat. Press 0 to restart.`)
        );
      } catch (err) {
        session.state = 'FROM_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Sorry, could not find a route. ${buildFloorMenu()}`));
      }
    }

    // Reading out navigation steps
    case 'NAVIGATE': {
      if (!session.cachedRoute) {
        session.state = 'FROM_FLOOR';
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Session data lost. Please start again. ${buildFloorMenu()}`));
      }

      const steps = session.cachedRoute.steps || [];

      if (digit === '2') {
        // Repeat current step
        const step = steps[session.currentDirectionStep] || steps[steps.length - 1];
        return twiml(gather(1, '/api/v1/ivr/gather',
          `${step.voice} Press 1 for next. Press 2 to repeat. Press 0 to restart.`));
      }

      if (digit === '0') {
        session.state = 'FROM_FLOOR';
        session.fromFloor = null;
        session.fromLocationCode = null;
        session.toFloor = null;
        session.toLocationCode = null;
        session.cachedRoute = null;
        session.currentDirectionStep = 0;
        await session.save();
        return twiml(gather(1, '/api/v1/ivr/gather',
          `Restarting navigation. ${buildFloorMenu()}`));
      }

      // digit === '1' → next step
      session.currentDirectionStep += 1;
      await session.save();

      if (session.currentDirectionStep >= steps.length) {
        session.state = 'DONE';
        await session.save();
        return twiml(
          say(`You have reached your destination: ${session.cachedRoute.to.name}. Thank you for using ${HOSPITAL_NAME} Navigation. Goodbye.`) +
          '\n  <Hangup/>'
        );
      }

      const nextStep = steps[session.currentDirectionStep];
      const isLast   = session.currentDirectionStep === steps.length - 1;
      const hint      = isLast ? 'Press 2 to repeat.' : 'Press 1 for next step. Press 2 to repeat. Press 0 to restart.';

      return twiml(gather(1, '/api/v1/ivr/gather',
        `Step ${session.currentDirectionStep + 1} of ${steps.length}: ${nextStep.voice} ${hint}`));
    }

    default:
      session.state = 'FROM_FLOOR';
      await session.save();
      return twiml(gather(1, '/api/v1/ivr/gather',
        `Let us start over. ${buildFloorMenu()}`));
  }
}

module.exports = { handleWelcome, handleGather };
