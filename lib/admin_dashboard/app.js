const SUPABASE_URL = 'https://gmrfwpntjvcrsbqpvzur.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtcmZ3cG50anZjcnNicXB2enVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3OTg0NzUsImV4cCI6MjA5MjM3NDQ3NX0.lf2Bk1Jc2LBzDO46i_Bu7ND2kn950LFCfuyaIJUHwjc';

const db = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/* ==========================================
   AUTH
========================================== */

function requireAuth() {
  const token = sessionStorage.getItem('sakina_admin_token');
  if (!token) window.location.href = 'login.html';
}

function logout() {
  sessionStorage.clear();
  window.location.href = 'login.html';
}

/* ==========================================
   HELPERS
========================================== */

function formatDate(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleDateString();
}

function getStatusBadgeClass(status) {
  switch (status) {
    case 'pending': return 'badge-pending';
    case 'available':
    case 'approved':
    case 'active': return 'badge-approved';
    case 'hidden':
    case 'rejected': return 'badge-hidden';
    default: return '';
  }
}

function getGenderBadgeClass(gender) {
  if (!gender) return '';
  return gender.toLowerCase().includes('female') ? 'badge-female' : 'badge-male';
}

/* ==========================================
   MODAL
========================================== */

let _modalConfirmFn = null;

function openModal(title, text, confirmLabel, confirmClass, onConfirm) {
  document.getElementById('modal-title').textContent = title;
  document.getElementById('modal-text').textContent = text;
  const btn = document.getElementById('modal-confirm-btn');
  btn.textContent = confirmLabel;
  btn.className = `btn-panel ${confirmClass}`;
  _modalConfirmFn = onConfirm;
  document.getElementById('confirm-modal').classList.add('open');
}

function closeModal() {
  document.getElementById('confirm-modal').classList.remove('open');
  _modalConfirmFn = null;
}

document.addEventListener('DOMContentLoaded', () => {
  const btn = document.getElementById('modal-confirm-btn');
  if (btn) btn.addEventListener('click', () => { if (_modalConfirmFn) _modalConfirmFn(); closeModal(); });
});

/* ==========================================
   NOTIFICATIONS
========================================== */

function toggleNotifPanel() {
  document.getElementById('notif-panel')?.classList.toggle('open');
}

function clearNotifications() {
  const list = document.getElementById('notif-list');
  if (list) list.innerHTML = '<p style="padding:12px;color:#888;">No notifications.</p>';
  const badge = document.getElementById('notif-badge');
  if (badge) badge.textContent = '0';
}

/* ==========================================
   DASHBOARD
========================================== */

async function renderDashboard() {
  try {
    const [
      { count: pendingListings },
      { count: activeListings },
      { count: hostsCount },
      { count: reportsCount },
      { count: servicesCount }
    ] = await Promise.all([
      db.from('property_listings').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      db.from('property_listings').select('*', { count: 'exact', head: true }).eq('status', 'available'),
      db.from('landlord').select('*', { count: 'exact', head: true }),
      db.from('report').select('*', { count: 'exact', head: true }),
      db.from('service').select('*', { count: 'exact', head: true })
    ]);

    document.getElementById('stat-pending').textContent = pendingListings || 0;
    document.getElementById('stat-active').textContent = activeListings || 0;
    document.getElementById('stat-hosts').textContent = hostsCount || 0;
    document.getElementById('stat-reports').textContent = reportsCount || 0;
    document.getElementById('stat-services').textContent = servicesCount || 0;
  } catch (err) {
    console.error('Dashboard error:', err);
  }
}

/* ==========================================
   CHARTS
========================================== */

async function renderCharts() {
  const { data: reports } = await db.from('report').select('status');
  const reportCounts = {};
  (reports || []).forEach(r => {
    const key = r.status || 'unknown';
    reportCounts[key] = (reportCounts[key] || 0) + 1;
  });

  const reportChart = document.getElementById('chart-reports');
  if (reportChart) {
    new Chart(reportChart, {
      type: 'doughnut',
      data: { labels: Object.keys(reportCounts), datasets: [{ data: Object.values(reportCounts) }] }
    });
  }

  const { data: listings } = await db.from('property_listings').select('created_at');
  const months = {};
  (listings || []).forEach(l => {
    if (!l.created_at) return;
    const month = new Date(l.created_at).toLocaleString('default', { month: 'short' });
    months[month] = (months[month] || 0) + 1;
  });

  const propertyChart = document.getElementById('chart-property');
  if (propertyChart) {
    new Chart(propertyChart, {
      type: 'line',
      data: {
        labels: Object.keys(months),
        datasets: [{ label: 'Listings per Month', data: Object.values(months), fill: true, tension: 0.3 }]
      }
    });
  }
}

/* ==========================================
   RECENT ACTIVITY
========================================== */

async function renderActivity() {
  const container = document.getElementById('activity-list');
  if (!container) return;

  const [{ data: listings }, { data: reports }, { data: services }] = await Promise.all([
    db.from('property_listings').select('title,created_at,status'),
    db.from('report').select('type,created_at,status'),
    db.from('service').select('name,created_at')
  ]);

  const activity = [];
  (listings || []).forEach(l => activity.push({ text: `New listing: ${l.title}`, date: l.created_at }));
  (reports || []).forEach(r => activity.push({ text: `Report: ${r.type}`, date: r.created_at }));
  (services || []).forEach(s => activity.push({ text: `Service: ${s.name}`, date: s.created_at }));
  activity.sort((a, b) => new Date(b.date) - new Date(a.date));

  container.innerHTML = activity.slice(0, 8).map(a => `
    <div class="activity-item">
      <div>${a.text}</div>
      <small>${formatDate(a.date)}</small>
    </div>
  `).join('');
}

/* ==========================================
   LISTINGS
========================================== */

let _allListings = [];

async function renderListings() {
  const tbody = document.getElementById('listings-tbody');
  if (!tbody) return;
  tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:24px;">Loading...</td></tr>';

  try {
    const { data, error } = await db
      .from('property_listings')
      .select('*, location:location!location_listing_id_fkey(address, city)')
      .order('created_at', { ascending: false });

    if (error) throw error;
    _allListings = data || [];
    renderListingsTable(_allListings);
  } catch (err) {
    console.error('Listings error:', err);
    tbody.innerHTML = `<tr><td colspan="8" style="text-align:center;color:red;">Error: ${err.message}</td></tr>`;
  }
}

function renderListingsTable(listings) {
  const tbody = document.getElementById('listings-tbody');
  if (!tbody) return;

  if (!listings.length) {
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:24px;color:#888;">No listings found.</td></tr>';
    return;
  }

  tbody.innerHTML = listings.map(l => `
    <tr>
      <td><span class="id-chip">${l.listing_id?.slice(0,8) || '—'}</span></td>
      <td>${l.title || '—'}</td>
      <td>${l.landlord_id?.slice(0,8) || '—'}</td>
      <td>${l.property_type || '—'}</td>
      <td><span class="badge ${getGenderBadgeClass(l.gender_preference)}">${l.gender_preference || '—'}</span></td>
      <td>EGP ${(l.rent_price || 0).toLocaleString()}</td>
      <td><span class="badge ${getStatusBadgeClass(l.status)}">${l.status || '—'}</span></td>
      <td>
        <div class="action-btns">
          <button class="btn-action btn-view" onclick="openListingPanel('${l.listing_id}')">View</button>
          ${l.status === 'pending' ? `
            <button class="btn-action btn-approve" onclick="updateListingStatus('${l.listing_id}', 'available')">Approve</button>
            <button class="btn-action btn-reject" onclick="updateListingStatus('${l.listing_id}', 'hidden')">Reject</button>
          ` : ''}
          ${l.status === 'available' ? `<button class="btn-action btn-reject" onclick="updateListingStatus('${l.listing_id}', 'hidden')">Hide</button>` : ''}
          ${l.status === 'hidden' ? `<button class="btn-action btn-approve" onclick="updateListingStatus('${l.listing_id}', 'available')">Restore</button>` : ''}
          <button class="btn-action btn-reject" style="background:#7a1a1a;" onclick="deleteListing('${l.listing_id}', '${(l.title||'').replace(/'/g,"\\'")}')">Delete</button>
        </div>
      </td>
    </tr>
  `).join('');
}

async function updateListingStatus(id, status) {
  const labels = { available: 'Approve', hidden: 'Hide/Reject' };
  openModal(
    `${labels[status] || 'Update'} Listing`,
    `Are you sure you want to ${status === 'available' ? 'approve' : 'hide'} this listing?`,
    'Confirm',
    status === 'available' ? 'btn-panel-approve' : 'btn-panel-reject',
    async () => {
      await db.from('property_listings').update({ status }).eq('listing_id', id);
      renderListings();
    }
  );
}

async function deleteListing(id, title) {
  openModal(
    'Delete Listing',
    `Are you sure you want to permanently delete "${title}"? This cannot be undone.`,
    'Delete',
    'btn-panel-reject',
    async () => {
      const { data, error } = await db
        .from('property_listings')
        .delete()
        .eq('listing_id', id)
        .select();

      if (error) {
        alert('Could not delete listing: ' + error.message);
        return;
      }
      if (!data || data.length === 0) {
        alert('Nothing was deleted — likely an RLS policy blocking deletes.');
        return;
      }
      renderListings();
    }
  );
}

async function openListingPanel(id) {
  const listing = _allListings.find(l => l.listing_id === id);
  if (!listing) return;

  document.getElementById('panel-title').textContent = listing.title || 'Listing Details';

  // Photos
  const photosEl = document.getElementById('panel-photos');
  const images = listing.image_url ? (Array.isArray(listing.image_url) ? listing.image_url : [listing.image_url]) : [];
  photosEl.innerHTML = images.length
    ? images.map(url => `<img src="${url}" style="width:100%;border-radius:8px;object-fit:cover;height:160px;" onerror="this.style.display='none'" />`).join('')
    : '<p style="color:#888;">No photos available.</p>';

  // Fields
  document.getElementById('panel-fields').innerHTML = `
    <div class="panel-field-row"><span class="panel-field-label">Type</span><span class="panel-field-value">${listing.property_type || '—'}</span></div>
    <div class="panel-field-row"><span class="panel-field-label">Price</span><span class="panel-field-value">EGP ${(listing.rent_price || 0).toLocaleString()}/mo</span></div>
    <div class="panel-field-row"><span class="panel-field-label">Rooms</span><span class="panel-field-value">${listing.available_rooms || '—'}</span></div>
    <div class="panel-field-row"><span class="panel-field-label">Gender</span><span class="panel-field-value">${listing.gender_preference || '—'}</span></div>
    <div class="panel-field-row"><span class="panel-field-label">Status</span><span class="panel-field-value"><span class="badge ${getStatusBadgeClass(listing.status)}">${listing.status}</span></span></div>
    <div class="panel-field-row"><span class="panel-field-label">Address</span><span class="panel-field-value">${listing.location?.address || listing.location?.city || '—'}</span></div>
    <div class="panel-field-row"><span class="panel-field-label">Listed</span><span class="panel-field-value">${formatDate(listing.created_at)}</span></div>
  `;

  document.getElementById('panel-description').textContent = listing.description || 'No description.';
  document.getElementById('panel-amenities').innerHTML = '<p style="color:#888;font-size:13px;">—</p>';

  // Host
  try {
    const { data: host } = await db.from('users').select('full_name, email').eq('user_id', listing.landlord_id).maybeSingle();
    document.getElementById('panel-host-name').textContent = host?.full_name || '—';
    document.getElementById('panel-host-email').textContent = host?.email || '—';
  } catch (_) {}

  // Footer actions
  const footer = document.getElementById('panel-footer');
  footer.innerHTML = '';
  if (listing.status === 'pending') {
    footer.innerHTML = `
      <button class="btn-panel btn-panel-approve" onclick="updateListingStatus('${id}', 'available');closeDetailPanel()">Approve</button>
      <button class="btn-panel btn-panel-reject" onclick="updateListingStatus('${id}', 'hidden');closeDetailPanel()">Reject</button>
    `;
  }

  document.getElementById('detail-panel').classList.add('open');
}

function closeDetailPanel() {
  document.getElementById('detail-panel')?.classList.remove('open');
}

function exportTable() {
  if (typeof jspdf === 'undefined' && typeof window.jspdf === 'undefined') {
    alert('PDF export not available.');
    return;
  }
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF();
  doc.text('Sakina — Listings', 14, 16);
  doc.autoTable({ html: '.data-table', startY: 22 });
  doc.save('listings.pdf');
}

/* ==========================================
   SERVICES
========================================== */

let _allServices = [];
let _activeServiceFilter = 'all';

async function renderServices() {
  const tbody = document.getElementById('services-tbody');
  if (!tbody) return;
  tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:24px;">Loading...</td></tr>';

  try {
    const { data, error } = await db
      .from('service')
      .select('*, service_provider(*)')
      .order('created_at', { ascending: false });

    if (error) throw error;
    _allServices = data || [];
    updateServiceTabs();
    renderServicesTable(_allServices);
  } catch (err) {
    console.error('Services error:', err);
    tbody.innerHTML = `<tr><td colspan="8" style="text-align:center;color:red;">Error: ${err.message}</td></tr>`;
  }
}

function updateServiceTabs() {
  const counts = { all: _allServices.length, pending: 0, approved: 0, rejected: 0 };
  _allServices.forEach(s => { if (counts[s.status] !== undefined) counts[s.status]++; });
  Object.entries(counts).forEach(([k, v]) => {
    const el = document.getElementById(`svc-tab-count-${k}`);
    if (el) el.textContent = v;
  });
}

function renderServicesTable(services) {
  const tbody = document.getElementById('services-tbody');
  if (!tbody) return;

  const filtered = _activeServiceFilter === 'all' ? services : services.filter(s => s.status === _activeServiceFilter);

  if (!filtered.length) {
    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:24px;color:#888;">No services found.</td></tr>';
    return;
  }

  tbody.innerHTML = filtered.map(s => `
    <tr>
      <td><span class="id-chip">${s.service_id?.slice(0,8) || '—'}</span></td>
      <td>${s.name || '—'}</td>
      <td>${s.category || '—'}</td>
      <td>${s.type || '—'}</td>
      <td>${s.starting_price ? `EGP ${Number(s.starting_price).toLocaleString()}` : '—'}</td>
      <td>${formatDate(s.created_at)}</td>
      <td><span class="badge ${getStatusBadgeClass(s.status)}">${s.status || '—'}</span></td>
      <td>
        <div class="action-btns">
          <button class="btn-action btn-view" onclick="openServicePanel('${s.service_id}')">View</button>
          ${s.status === 'pending' ? `
            <button class="btn-action btn-approve" onclick="updateServiceStatus('${s.service_id}', 'approved')">Approve</button>
            <button class="btn-action btn-reject" onclick="updateServiceStatus('${s.service_id}', 'rejected')">Reject</button>
          ` : ''}
          ${s.status === 'approved' ? `<button class="btn-action btn-reject" onclick="updateServiceStatus('${s.service_id}', 'rejected')">Reject</button>` : ''}
          ${s.status === 'rejected' ? `<button class="btn-action btn-approve" onclick="updateServiceStatus('${s.service_id}', 'approved')">Approve</button>` : ''}
          <button class="btn-action btn-reject" style="background:#7a1a1a;" onclick="deleteService('${s.service_id}', '${(s.name||'').replace(/'/g,"\\'")}')">Delete</button>
        </div>
      </td>
    </tr>
  `).join('');
}

async function updateServiceStatus(id, status) {
  openModal(
    `${status === 'approved' ? 'Approve' : 'Reject'} Service`,
    `Are you sure you want to ${status} this service?`,
    'Confirm',
    status === 'approved' ? 'btn-panel-approve' : 'btn-panel-reject',
    async () => {
      await db.from('service').update({ status }).eq('service_id', id);
      renderServices();
    }
  );
}

function openServicePanel(id) {
  const s = _allServices.find(x => x.service_id === id);
  if (!s) return;

  document.getElementById('svc-panel-title').textContent = s.name || 'Service';
  document.getElementById('svc-panel-business').textContent = s.name || '—';
  document.getElementById('svc-panel-owner').textContent = s.service_provider?.owner_name || '—';
  document.getElementById('svc-panel-contact').textContent = s.service_provider?.contact || s.contact_info || '—';
  document.getElementById('svc-panel-category').textContent = s.category || '—';
  document.getElementById('svc-panel-type').textContent = s.type || '—';
  document.getElementById('svc-panel-location').textContent = s.location || '—';
  document.getElementById('svc-panel-date').textContent = formatDate(s.created_at);
  document.getElementById('svc-panel-status').innerHTML = `<span class="badge ${getStatusBadgeClass(s.status)}">${s.status}</span>`;
  document.getElementById('svc-panel-desc').textContent = s.description || 'No description.';
  document.getElementById('svc-panel-price').textContent = s.starting_price ? `EGP ${Number(s.starting_price).toLocaleString()}` : '—';

  const photos = s.image_url ? (Array.isArray(s.image_url) ? s.image_url : [s.image_url]) : [];
  document.getElementById('svc-panel-photos').innerHTML = photos.length
    ? photos.map(url => `<img src="${url}" style="width:100%;border-radius:8px;object-fit:cover;height:160px;" onerror="this.style.display='none'" />`).join('')
    : '<p style="color:#888;">No photos.</p>';

  const footer = document.getElementById('svc-panel-footer');
  footer.style.display = 'flex';
  footer.innerHTML = s.status === 'pending' ? `
    <button class="btn-panel btn-panel-approve" onclick="updateServiceStatus('${id}','approved');closeServicePanel()">Approve</button>
    <button class="btn-panel btn-panel-reject" onclick="updateServiceStatus('${id}','rejected');closeServicePanel()">Reject</button>
  ` : '';

  document.getElementById('svc-panel').classList.add('open');
}

function closeServicePanel() {
  document.getElementById('svc-panel')?.classList.remove('open');
}

/* ==========================================
   PAGE INIT
========================================== */

document.addEventListener('DOMContentLoaded', async () => {
  requireAuth();

  const page = document.body.dataset.page;

  if (page === 'dashboard') {
    await renderDashboard();
    await renderCharts();
    await renderActivity();
  }

  if (page === 'listings') {
    await renderListings();
  }

  if (page === 'hosts') {
    renderHosts();
  }

  if (page === 'services') {
    await renderServices();

    // Tab filtering
    document.getElementById('service-tabs')?.addEventListener('click', e => {
      const btn = e.target.closest('[data-filter]');
      if (!btn) return;
      document.querySelectorAll('#service-tabs .report-tab').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      _activeServiceFilter = btn.dataset.filter;
      renderServicesTable(_allServices);
    });
  }
});

/* ==========================================
   HOSTS
========================================== */

let _allHosts = [];

async function renderHosts() {
  const tbody = document.getElementById('hosts-tbody');
  if (!tbody) return;
  tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:24px;">Loading...</td></tr>';

  try {
    const { data: landlords, error: lErr } = await db
      .from('landlord')
      .select('landlord_id, status');

    if (lErr) throw lErr;

    const ids = (landlords || []).map(l => l.landlord_id).filter(Boolean);
    if (!ids.length) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:24px;color:#888;">No hosts found.</td></tr>';
      return;
    }

    const statusMap = {};
    (landlords || []).forEach(l => { statusMap[l.landlord_id] = l.status; });

    const { data: users, error: uErr } = await db
      .from('users')
      .select('user_id, full_name, email')
      .in('user_id', ids);

    if (uErr) throw uErr;

    const { data: listings } = await db
      .from('property_listings')
      .select('landlord_id');

    const listingCountMap = {};
    (listings || []).forEach(l => {
      listingCountMap[l.landlord_id] = (listingCountMap[l.landlord_id] || 0) + 1;
    });

    _allHosts = (users || []).map(u => ({
      ...u,
      listingCount: listingCountMap[u.user_id] || 0,
      status: statusMap[u.user_id] || 'active',
    }));

    renderHostsTable(_allHosts);

  } catch (err) {
    console.error('Hosts error:', err);
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;color:red;padding:24px;">Error: ${err.message}</td></tr>`;
  }
}

function renderHostsTable(hosts) {
  const tbody = document.getElementById('hosts-tbody');
  if (!tbody) return;

  if (!hosts.length) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;padding:24px;color:#888;">No hosts found.</td></tr>';
    return;
  }

  tbody.innerHTML = hosts.map(h => `
    <tr>
      <td>${h.full_name || '—'}</td>
      <td>${h.email || '—'}</td>
      <td>${h.listingCount}</td>
      <td><span class="badge ${h.status === 'suspended' ? 'badge-hidden' : 'badge-approved'}">${h.status === 'suspended' ? 'Suspended' : 'Active'}</span></td>
      <td>
        <div class="action-btns">
          <button class="btn-action btn-view" onclick="openHostPanel('${h.user_id}')">View</button>
          ${h.status === 'suspended'
            ? `<button class="btn-action btn-approve" onclick="confirmUnsuspendHost('${h.user_id}', '${(h.full_name || '').replace(/'/g, "\\'")}')">Unsuspend</button>`
            : `<button class="btn-action btn-reject" onclick="confirmSuspendHost('${h.user_id}', '${(h.full_name || '').replace(/'/g, "\\'")}')">Suspend</button>`}
        </div>
      </td>
    </tr>
  `).join('');
}

function confirmSuspendHost(hostId, name) {
  openModal(
    'Suspend Host',
    `Are you sure you want to suspend ${name}? Their listings will be hidden.`,
    'Suspend',
    'btn-panel-reject',
    async () => {
      const { error: hostErr } = await db
        .from('landlord')
        .update({ status: 'suspended' })
        .eq('landlord_id', hostId);

      if (hostErr) {
        alert('Could not suspend host: ' + hostErr.message);
        return;
      }

      const { error: listErr } = await db
        .from('property_listings')
        .update({ status: 'hidden' })
        .eq('landlord_id', hostId);

      if (listErr) {
        alert('Host suspended, but could not hide their listings: ' + listErr.message);
      }

      // update local data immediately instead of re-fetching
      const host = _allHosts.find(h => h.user_id === hostId);
      if (host) host.status = 'suspended';
      renderHostsTable(_allHosts);

      closeHostPanel();
    }
  );
}

function confirmUnsuspendHost(hostId, name) {
  openModal(
    'Unsuspend Host',
    `Restore ${name}'s account to active?`,
    'Unsuspend',
    'btn-panel-approve',
    async () => {
      const { error } = await db
        .from('landlord')
        .update({ status: 'active' })
        .eq('landlord_id', hostId);

      if (error) {
        alert('Could not unsuspend host: ' + error.message);
        return;
      }

      const host = _allHosts.find(h => h.user_id === hostId);
      if (host) host.status = 'active';
      renderHostsTable(_allHosts);

      closeHostPanel();
    }
  );
}

async function openHostPanel(hostId) {
  const host = _allHosts.find(h => h.user_id === hostId);
  if (!host) return;

  document.getElementById('host-panel-title').textContent = host.full_name || 'Host Details';
  document.getElementById('host-panel-name').textContent = host.full_name || '—';
  document.getElementById('host-panel-email').textContent = host.email || '—';
  document.getElementById('host-panel-listings').textContent = host.listingCount;
  document.getElementById('host-panel-status').innerHTML = host.status === 'suspended'
    ? '<span class="badge badge-hidden">Suspended</span>'
    : '<span class="badge badge-approved">Active</span>';

  const { data: listings } = await db
    .from('property_listings')
    .select('title, status, rent_price')
    .eq('landlord_id', hostId);

  const listEl = document.getElementById('host-panel-listings-list');
  listEl.innerHTML = (listings || []).length
    ? (listings || []).map(l => `
        <div class="panel-field-row">
          <span class="panel-field-label">${l.title || 'Untitled'}</span>
          <span class="panel-field-value">
            <span class="badge ${getStatusBadgeClass(l.status)}">${l.status}</span>
            &nbsp;EGP ${(l.rent_price || 0).toLocaleString()}
          </span>
        </div>
      `).join('')
    : '<p style="color:#888;font-size:13px;">No listings yet.</p>';

  document.getElementById('host-panel').classList.add('open');
}

function confirmSuspendHost(hostId, name) {
  openModal(
    'Suspend Host',
    `Are you sure you want to suspend ${name}? Their listings will be hidden.`,
    'Suspend',
    'btn-panel-reject',
    async () => {
      const { error: hostErr } = await db
        .from('landlord')
        .update({ status: 'suspended' })
        .eq('landlord_id', hostId);

      if (hostErr) {
        alert('Could not suspend host: ' + hostErr.message);
        return;
      }

      const { error: listErr } = await db
        .from('property_listings')
        .update({ status: 'hidden' })
        .eq('landlord_id', hostId);

      if (listErr) {
        alert('Host suspended, but could not hide their listings: ' + listErr.message);
      }

      closeHostPanel();
      renderHosts();
    }
  );
}

function confirmUnsuspendHost(hostId, name) {
  openModal(
    'Unsuspend Host',
    `Restore ${name}'s account to active?`,
    'Unsuspend',
    'btn-panel-approve',
    async () => {
      const { error } = await db
        .from('landlord')
        .update({ status: 'active' })
        .eq('landlord_id', hostId);

      if (error) {
        alert('Could not unsuspend host: ' + error.message);
        return;
      }

      closeHostPanel();
      renderHosts();
    }
  );
}

/* ==========================================
   ADD / REMOVE SERVICE (Admin)
========================================== */

function openAddServiceModal() {
  document.getElementById('add-service-modal').classList.add('open');
}

function closeAddServiceModal() {
  document.getElementById('add-service-modal').classList.remove('open');
  document.getElementById('add-service-form').reset();
}

async function submitAddService() {
  const name = document.getElementById('svc-name').value.trim();
  const category = document.getElementById('svc-category').value.trim();
  const type = document.getElementById('svc-type').value.trim();
  const price = document.getElementById('svc-price').value.trim();
  const description = document.getElementById('svc-description').value.trim();

  if (!name || !category) {
    alert('Name and category are required.');
    return;
  }

  const { error } = await db.from('service').insert({
    name,
    category,
    type: type || null,
    starting_price: price ? Number(price) : null,
    description: description || null,
    status: 'approved',
    created_at: new Date().toISOString(),
  });

  if (error) {
    alert('Error adding service: ' + error.message);
    return;
  }

  closeAddServiceModal();
  renderServices();
}

async function deleteService(id, name) {
  openModal(
    'Delete Service',
    `Are you sure you want to permanently delete "${name}"? This cannot be undone.`,
    'Delete',
    'btn-panel-reject',
    async () => {
      const { data, error } = await db
        .from('service')
        .delete()
        .eq('service_id', id)
        .select();

      if (error) {
        alert('Could not delete service: ' + error.message);
        return;
      }
      if (!data || data.length === 0) {
        alert('Nothing was deleted — likely an RLS policy blocking deletes on "service".');
        return;
      }
      renderServices();
    }
  );
}