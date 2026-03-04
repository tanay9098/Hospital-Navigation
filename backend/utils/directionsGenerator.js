/**
 * Converts a raw Dijkstra path (array of Location documents)
 * into human-readable text + voice instructions.
 */

const DIRECTION_REVERSE = {
  north: 'south', south: 'north',
  east: 'west',   west: 'east',
  northeast: 'southwest', southwest: 'northeast',
  northwest: 'southeast', southeast: 'northwest',
  up: 'down', down: 'up',
};

// Cardinal → friendly walking phrase (assumes traveller entered from south / main entrance)
const DIRECTION_PHRASE = {
  north:     'straight ahead',
  south:     'back towards the entrance',
  east:      'to your right',
  west:      'to your left',
  northeast: 'ahead and to your right',
  northwest: 'ahead and to your left',
  southeast: 'behind and to your right',
  southwest: 'behind and to your left',
};

function friendlyDirection(dir) {
  return DIRECTION_PHRASE[dir] || dir;
}

function formatDistance(metres) {
  if (metres < 10) return 'a few steps';
  return `about ${Math.round(metres)} metres`;
}

/**
 * Build step-by-step directions from an ordered array of Location documents.
 * Each pair of consecutive locations has an edge stored in location.connections.
 *
 * @param {Array}  locations  Ordered Location docs from start → end
 * @returns {{ steps: Array, voiceScript: string, textSummary: string }}
 */
function generateDirections(locations) {
  if (!locations || locations.length === 0) {
    return { steps: [], voiceScript: '', textSummary: 'No route found.' };
  }

  if (locations.length === 1) {
    const loc = locations[0];
    const text = `You are already at ${loc.name} on Floor ${loc.floor}.`;
    return { steps: [{ step: 1, text, voice: text, type: 'arrival' }], voiceScript: text, textSummary: text };
  }

  const steps = [];

  // Opening step
  const start = locations[0];
  steps.push({
    step: 1,
    type: 'start',
    locationCode: start.code,
    locationName: start.name,
    floor: start.floor,
    text: `Start at ${start.name} on Floor ${start.floor}.`,
    voice: `You are starting at ${start.name} on floor ${start.floor}.`,
    distance: 0,
  });

  // Intermediate steps
  for (let i = 0; i < locations.length - 1; i++) {
    const from = locations[i];
    const to   = locations[i + 1];

    // Find the edge connecting from → to
    const edge = (from.connections || []).find((c) => c.locationCode === to.code);
    const distance  = edge ? edge.distance : 0;
    const direction = edge ? edge.direction : 'straight';

    let text, voice, type;

    if (direction === 'up' || direction === 'down') {
      // Vertical movement
      const verb = direction === 'up' ? 'up' : 'down';
      if (from.type === 'elevator') {
        type  = 'elevator';
        text  = `Take the elevator ${verb} to Floor ${to.floor}.`;
        voice = `Take the elevator ${verb} to floor ${to.floor}. Wait for the doors to open, then exit.`;
      } else {
        type  = 'stairs';
        text  = `Take the stairwell ${verb} to Floor ${to.floor}.`;
        voice = `Use the stairwell to go ${verb} to floor ${to.floor}.`;
      }
    } else if (to.type === 'elevator' || to.type === 'stairwell') {
      type  = 'transit';
      text  = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)} to reach ${to.name}.`;
      voice = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)} to reach ${to.name}.`;
    } else if (to.type === 'entrance') {
      type  = 'transit';
      text  = `Head ${friendlyDirection(direction)} for ${formatDistance(distance)} towards ${to.name}.`;
      voice = `Head ${friendlyDirection(direction)} for ${formatDistance(distance)} towards ${to.name}.`;
    } else if (i === locations.length - 2) {
      // Last step = arrival
      type  = 'arrival';
      text  = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)}. You have arrived at ${to.name}.`;
      voice = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)}. You have arrived at your destination: ${to.name}, on floor ${to.floor}.`;
    } else {
      type  = 'walk';
      text  = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)}.`;
      voice = `Walk ${friendlyDirection(direction)} for ${formatDistance(distance)}.`;
    }

    steps.push({
      step: steps.length + 1,
      type,
      locationCode: to.code,
      locationName: to.name,
      floor: to.floor,
      direction,
      distance,
      text,
      voice,
    });
  }

  const voiceScript = steps.map((s) => s.voice).join(' ');
  const textSummary = steps.map((s) => `${s.step}. ${s.text}`).join('\n');

  return { steps, voiceScript, textSummary };
}

/**
 * Build the IVR-optimised voice script (shorter sentences, pauses noted with commas).
 * Twilio reads commas as brief pauses.
 */
function generateIVRScript(steps) {
  return steps
    .map((s) => s.voice)
    .join(', ');
}

module.exports = { generateDirections, generateIVRScript, DIRECTION_REVERSE };
