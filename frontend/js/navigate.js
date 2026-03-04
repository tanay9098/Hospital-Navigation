/* ── Navigate page logic ──────────────────────────────────── */

const route = JSON.parse(localStorage.getItem('pes_route') || 'null');

if (!route) {
  // No data – send back to home
  window.location.href = '/index.html';
}

// ── Populate summary banner ────────────────────────────────────
document.getElementById('from-name').textContent = route.from.name;
document.getElementById('to-name').textContent   = route.to.name;
document.getElementById('from-floor').textContent = floorLabel(route.from.floor);
document.getElementById('to-floor').textContent   = floorLabel(route.to.floor);
document.getElementById('route-distance').textContent = route.distance + 'm';
document.getElementById('route-time').textContent     = route.estimatedTimeText;
document.getElementById('route-steps').textContent    = route.totalSteps + ' steps';

// ── Render step cards ──────────────────────────────────────────
const stepsList = document.getElementById('steps-list');

const STEP_META = {
  start:    { icon: '🏥', cls: 'start'    },
  walk:     { icon: '🚶', cls: 'walk'     },
  elevator: { icon: '🛗', cls: 'elevator' },
  stairs:   { icon: '🪜', cls: 'stairs'   },
  transit:  { icon: '➡️', cls: 'transit'  },
  arrival:  { icon: '✅', cls: 'arrival'  },
};

route.steps.forEach((step, i) => {
  const meta = STEP_META[step.type] || STEP_META.walk;

  const card = document.createElement('div');
  card.className = 'step-card';
  card.innerHTML = `
    <div class="step-number-col">
      <span class="step-number">${i + 1}</span>
      <div class="step-icon-badge ${meta.cls}">${meta.icon}</div>
    </div>
    <div class="step-content">
      <div class="step-text">${step.text}</div>
      ${step.distance > 0
        ? `<div class="step-distance">📏 ${step.distance} m</div>`
        : ''}
    </div>
    <button
      class="btn-icon"
      id="voice-btn-${i}"
      title="Read this step aloud"
      data-voice="${encodeURIComponent(step.voice)}"
    >🔊</button>
  `;

  stepsList.appendChild(card);
});

// ── Voice / Speech ─────────────────────────────────────────────
let currentUtterance = null;
let currentBtnIndex   = null;

function stopSpeech() {
  window.speechSynthesis.cancel();
  if (currentBtnIndex !== null) {
    const btn = document.getElementById(`voice-btn-${currentBtnIndex}`);
    if (btn) { btn.textContent = '🔊'; btn.classList.remove('playing'); }
    currentBtnIndex = null;
  }
  const mainBtn = document.getElementById('read-all-btn');
  if (mainBtn) { mainBtn.textContent = '🔊 Read Full Route'; mainBtn.classList.remove('active'); }
  currentUtterance = null;
}

function speak(text, btnId) {
  if (!window.speechSynthesis) {
    showToast('Voice not supported in this browser');
    return;
  }

  stopSpeech(); // cancel any ongoing speech

  const utter = new SpeechSynthesisUtterance(text);
  utter.lang  = 'en-IN';
  utter.rate  = 0.88;
  utter.pitch = 1;

  utter.onend   = () => stopSpeech();
  utter.onerror = () => stopSpeech();

  currentUtterance = utter;
  currentBtnIndex  = btnId;

  if (typeof btnId === 'number') {
    const btn = document.getElementById(`voice-btn-${btnId}`);
    if (btn) { btn.textContent = '⏹'; btn.classList.add('playing'); }
  }

  window.speechSynthesis.speak(utter);
}

// Per-step voice buttons
document.querySelectorAll('[id^="voice-btn-"]').forEach(btn => {
  btn.addEventListener('click', () => {
    const idx  = parseInt(btn.id.replace('voice-btn-', ''), 10);
    const text = decodeURIComponent(btn.dataset.voice);

    if (btn.classList.contains('playing')) {
      stopSpeech();
    } else {
      speak(text, idx);
    }
  });
});

// "Read full route" button
document.getElementById('read-all-btn').addEventListener('click', function () {
  if (currentUtterance) { stopSpeech(); return; }

  this.textContent = '⏹ Stop Reading';
  this.classList.add('active');

  speak(route.voiceScript, 'all');
});

// ── Share / copy directions ────────────────────────────────────
document.getElementById('share-btn').addEventListener('click', async () => {
  const text = route.textSummary;
  if (navigator.share) {
    try {
      await navigator.share({ title: `Directions to ${route.to.name}`, text });
    } catch {}
  } else if (navigator.clipboard) {
    await navigator.clipboard.writeText(text);
    showToast('Directions copied to clipboard');
  }
});

// ── Helpers ───────────────────────────────────────────────────
function floorLabel(floor) {
  if (floor === 0) return 'Ground Floor';
  const s = ['th','st','nd','rd'];
  const v = floor % 100;
  return floor + (s[(v-20)%10] || s[v] || s[0]) + ' Floor';
}

function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 2800);
}
