/* ── Home page logic ──────────────────────────────────────── */

const fromInput  = document.getElementById('from-input');
const toInput    = document.getElementById('to-input');
const fromDrop   = document.getElementById('from-dropdown');
const toDrop     = document.getElementById('to-dropdown');
const fromClear  = document.getElementById('from-clear');
const toClear    = document.getElementById('to-clear');
const accessibleToggle = document.getElementById('accessible');
const directionsBtn    = document.getElementById('directions-btn');
const btnText          = document.getElementById('btn-text');

// Currently selected location objects { code, name, floor }
let fromLoc = null;
let toLoc   = null;

// ── URL param pre-fill (from Departments "Get Directions" link) ──
const params = new URLSearchParams(window.location.search);
const presetTo = params.get('to');

if (presetTo) {
  // Load the location name for the preset code
  getLocation(presetTo)
    .then(loc => {
      if (loc) {
        toLoc = loc;
        toInput.value = loc.name;
        showClear(toClear, true);
      }
    })
    .catch(() => {});
}

// ── Autocomplete logic ─────────────────────────────────────────
let fromTimer, toTimer;

function setupAutocomplete(input, dropdown, clearBtn, setFn) {
  let timer;

  input.addEventListener('input', () => {
    const q = input.value.trim();
    clearBtn.style.display = q ? 'flex' : 'none';

    // Deselect current selection if user types again
    setFn(null);

    clearTimeout(timer);
    if (q.length < 2) { closeDrop(dropdown); return; }

    timer = setTimeout(async () => {
      try {
        const results = await searchLocations(q);
        renderDropdown(dropdown, results, (loc) => {
          input.value = loc.name;
          setFn(loc);
          closeDrop(dropdown);
          clearBtn.style.display = 'flex';
        });
      } catch {
        closeDrop(dropdown);
      }
    }, 300);
  });

  input.addEventListener('focus', () => {
    if (input.value.trim().length >= 2) input.dispatchEvent(new Event('input'));
  });
}

function renderDropdown(dropdown, results, onSelect) {
  if (!results.length) {
    dropdown.innerHTML = '<div class="autocomplete-empty">No locations found</div>';
    dropdown.style.display = 'block';
    return;
  }

  dropdown.innerHTML = results.map(loc => `
    <div class="autocomplete-item" data-code="${loc.code}">
      <span class="autocomplete-item-icon">${locationIcon(loc)}</span>
      <div>
        <div class="autocomplete-item-name">${loc.name}</div>
        <div class="autocomplete-item-sub">Floor ${loc.floor} · ${loc.code}</div>
      </div>
    </div>
  `).join('');

  dropdown.querySelectorAll('.autocomplete-item').forEach((el, i) => {
    el.addEventListener('click', () => onSelect(results[i]));
  });

  dropdown.style.display = 'block';
}

function closeDrop(dropdown) {
  dropdown.style.display = 'none';
  dropdown.innerHTML = '';
}

function showClear(btn, show) {
  btn.style.display = show ? 'flex' : 'none';
}

function locationIcon(loc) {
  const icons = {
    entrance: '🏥', elevator: '🛗', stairwell: '🪜',
    corridor: '🛤️', room: '🚪',
  };
  const catIcons = {
    department: '🏥', facility: '⚙️', transit: '🛤️', administrative: '🏢',
  };
  return icons[loc.type] || catIcons[loc.category] || '📍';
}

// Wire up both fields
setupAutocomplete(fromInput, fromDrop, fromClear, (loc) => { fromLoc = loc; });
setupAutocomplete(toInput,   toDrop,   toClear,   (loc) => { toLoc   = loc; });

// Clear buttons
fromClear.addEventListener('click', () => {
  fromInput.value = '';
  fromLoc = null;
  fromClear.style.display = 'none';
  closeDrop(fromDrop);
  fromInput.focus();
});

toClear.addEventListener('click', () => {
  toInput.value = '';
  toLoc = null;
  toClear.style.display = 'none';
  closeDrop(toDrop);
  toInput.focus();
});

// Close dropdowns when clicking outside
document.addEventListener('click', (e) => {
  if (!e.target.closest('#from-wrap')) closeDrop(fromDrop);
  if (!e.target.closest('#to-wrap'))   closeDrop(toDrop);
});

// ── Quick-access chips ─────────────────────────────────────────
document.querySelectorAll('.chip[data-code]').forEach(chip => {
  chip.addEventListener('click', async () => {
    const code = chip.dataset.code;
    const name = chip.dataset.name;

    // If no From, set it to Main Lobby as default start
    if (!fromLoc) {
      fromInput.value = 'Main Lobby (Ground Floor)';
      fromLoc = { code: 'GF-LOBBY', name: 'Main Lobby', floor: 0 };
      showClear(fromClear, true);
    }

    toInput.value = name;
    toLoc = { code, name, floor: chip.dataset.floor || 0 };
    showClear(toClear, true);
    closeDrop(toDrop);
  });
});

// ── Get Directions ─────────────────────────────────────────────
directionsBtn.addEventListener('click', async () => {
  if (!fromLoc) { showToast('Please select your current location'); fromInput.focus(); return; }
  if (!toLoc)   { showToast('Please select your destination');       toInput.focus();   return; }
  if (fromLoc.code === toLoc.code) { showToast('You are already there!'); return; }

  setLoading(true);

  try {
    const route = await getRoute(fromLoc.code, toLoc.code, accessibleToggle.checked);
    localStorage.setItem('pes_route', JSON.stringify(route));
    window.location.href = '/navigate.html';
  } catch (err) {
    showToast(err.message || 'Could not find a route');
    setLoading(false);
  }
});

function setLoading(loading) {
  directionsBtn.disabled = loading;
  btnText.innerHTML = loading
    ? '<span class="spinner"></span> Finding route…'
    : '🗺️ Get Directions';
}

// ── Toast helper ───────────────────────────────────────────────
function showToast(msg) {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 2800);
}
