/* ── Departments page logic ───────────────────────────────── */

const FLOORS = [
  { num: 0, label: 'GF',  name: 'Ground Floor'   },
  { num: 1, label: '1',   name: 'Floor 1'         },
  { num: 2, label: '2',   name: 'Floor 2'         },
  { num: 3, label: '3',   name: 'Floor 3'         },
  { num: 4, label: '4',   name: 'Floor 4'         },
  { num: 5, label: '5',   name: 'Floor 5'         },
  { num: 6, label: '6',   name: 'Floor 6'         },
  { num: 7, label: '7',   name: 'Floor 7'         },
  { num: 8, label: '8',   name: 'Floor 8'         },
];

let activeFloor = 0;

// ── Build floor tab bar ────────────────────────────────────────
const tabBar = document.getElementById('floor-tabs');

FLOORS.forEach(f => {
  const tab = document.createElement('button');
  tab.className   = 'floor-tab' + (f.num === 0 ? ' active' : '');
  tab.textContent = f.label;
  tab.title       = f.name;
  tab.addEventListener('click', () => selectFloor(f.num, tab));
  tabBar.appendChild(tab);
});

// ── Floor selection ────────────────────────────────────────────
function selectFloor(floor, tabEl) {
  // Update active tab
  document.querySelectorAll('.floor-tab').forEach(t => t.classList.remove('active'));
  tabEl.classList.add('active');
  activeFloor = floor;

  // Update section title
  const fl = FLOORS.find(f => f.num === floor);
  document.getElementById('floor-title').textContent =
    fl ? fl.name : `Floor ${floor}`;

  loadDepartments(floor);
}

// ── Load and render departments ────────────────────────────────
const listEl  = document.getElementById('dept-list');
const emptyEl = document.getElementById('dept-empty');

async function loadDepartments(floor) {
  listEl.innerHTML  = '<div class="empty-state"><span class="empty-state-icon">⏳</span>Loading…</div>';
  emptyEl.style.display = 'none';

  try {
    const depts = await getDepartmentsByFloor(floor);

    if (!depts.length) {
      listEl.innerHTML = '';
      emptyEl.style.display = 'block';
      return;
    }

    listEl.innerHTML = depts.map(d => deptCard(d)).join('');
  } catch (err) {
    listEl.innerHTML = `<div class="empty-state"><span class="empty-state-icon">❌</span>${err.message}</div>`;
  }
}

function deptCard(dept) {
  const hours = dept.workingHours?.is24x7
    ? '<span class="dept-badge badge-24x7">24 / 7</span>'
    : `<span class="dept-badge badge-hours">⏰ ${dept.workingHours?.weekdays || 'Check on site'}</span>`;

  const phone = dept.contactNumber
    ? `<a href="tel:${dept.contactNumber}" style="color:var(--blue); font-weight:600;">${dept.contactNumber}</a>`
    : '';

  return `
    <div class="dept-card">
      <div class="dept-icon">${deptIcon(dept)}</div>
      <div class="dept-info">
        <div class="dept-name">${dept.name}</div>
        <div class="dept-detail">
          ${hours}
          ${phone ? `<span>📞 ${phone}</span>` : ''}
          <span class="text-muted" style="font-size:11px;">${dept.locationCode}</span>
        </div>
        ${dept.description
          ? `<div class="text-sm text-muted mt-4" style="line-height:1.4;">${dept.description}</div>`
          : ''}
      </div>
      <a
        href="/index.html?to=${encodeURIComponent(dept.locationCode)}"
        class="btn btn-outline"
        style="align-self:center; flex-shrink:0; white-space:nowrap;"
        title="Get directions to ${dept.name}"
      >→ Go</a>
    </div>
  `;
}

// Map department specialties/names to emoji icons
function deptIcon(dept) {
  const name = dept.name.toLowerCase();
  if (name.includes('emergency') || name.includes('trauma'))   return '🚨';
  if (name.includes('cardio') || name.includes('heart') || name.includes('cardiac')) return '❤️';
  if (name.includes('pharmacy'))                               return '💊';
  if (name.includes('pediatric') || name.includes('child'))    return '👶';
  if (name.includes('gynecol') || name.includes('maternity') || name.includes('nicu') || name.includes('labor')) return '🤱';
  if (name.includes('ortho') || name.includes('bone') || name.includes('joint')) return '🦴';
  if (name.includes('neuro') || name.includes('brain'))        return '🧠';
  if (name.includes('psychi') || name.includes('mental') || name.includes('counsel')) return '🧘';
  if (name.includes('oncol') || name.includes('cancer') || name.includes('chemo') || name.includes('radiation')) return '🩺';
  if (name.includes('eye') || name.includes('ophthal'))        return '👁️';
  if (name.includes('ent') || name.includes('ear'))            return '👂';
  if (name.includes('skin') || name.includes('derm'))          return '🩹';
  if (name.includes('lung') || name.includes('pulmon') || name.includes('resp')) return '🫁';
  if (name.includes('surgery') || name.includes('operation') || name.includes('theatre')) return '🔪';
  if (name.includes('blood') || name.includes('lab') || name.includes('pathol')) return '🧪';
  if (name.includes('radiol') || name.includes('x-ray') || name.includes('mri')) return '🩻';
  if (name.includes('physio'))                                 return '🏋️';
  if (name.includes('reception'))                              return '🛎️';
  if (name.includes('billing'))                                return '🧾';
  if (name.includes('medical records'))                        return '📋';
  if (name.includes('conference') || name.includes('admin'))   return '🏢';
  if (name.includes('cafeteria') || name.includes('food'))     return '🍽️';
  return '🏥';
}

// ── Load initial floor on page load ───────────────────────────
loadDepartments(0);
