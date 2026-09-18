/* LXR-LAWMAN — the desk on the LXR UI Kit | © 2026 iBoss21 / LXRCore
   Works on the server's desk: { station, job, onDuty[], bounties[], canPost, limits }. */
(function () {
  const $ = (id) => document.getElementById(id);
  const app = $('app');
  const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'lxr-lawman';
  let D = null, L = {};
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  const money = (n) => (Math.round((Number(n) || 0) * 100) / 100).toFixed(2);
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const post = (name, body) => fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) }).then(r => r.json()).catch(() => ({ ok: false }));
  const sound = (name, set) => post('sound', { name, set });
  const pad = (i) => String(i).padStart(2, '0');
  const when = (s) => { const d = new Date(s); return isNaN(d) ? String(s || '').slice(0, 10) : d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' }); };

  let toastEl;
  function toast(msg, bad) {
    if (!toastEl) { toastEl = document.createElement('div'); toastEl.className = 'lxr-toast lw-toast'; document.body.appendChild(toastEl); }
    toastEl.textContent = msg; toastEl.classList.toggle('is-bad', !!bad); toastEl.classList.toggle('is-ok', !bad); toastEl.classList.add('show');
    setTimeout(() => toastEl.classList.remove('show'), 2500);
  }
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }

  function render() {
    $('station-label').textContent = (D.station && D.station.label) || '';
    $('job-label').textContent = D.job.label; $('grade').textContent = D.job.grade || '';
    $('btn-duty').textContent = t(D.job.onduty ? 'ui.go_off_duty' : 'ui.go_on_duty');
    $('btn-duty').classList.toggle('lxr-btn-ghost', !!D.job.onduty);
    $('btn-duty').disabled = !D.canPost && !D.job.onduty && D.job.name === 'bountyhunter';
    const r = $('roster'); r.innerHTML = ''; $('duty-count').textContent = pad(D.onDuty.length);
    if (!D.onDuty.length) r.innerHTML = `<div class="lw-empty">${esc(t('ui.nobody_on_duty'))}</div>`;
    D.onDuty.forEach(o => { const row = document.createElement('div'); row.className = 'lxr-row'; row.innerHTML = `<span class="lxr-row-body"><span class="lxr-row-name">${esc(o.name)}</span><span class="lxr-row-sub">${esc(o.grade || '')} · ${esc(o.job)}</span></span>`; r.appendChild(row); });
    const p = $('post'); p.innerHTML = '';
    if (D.canPost) {
      p.innerHTML = `<input class="lw-in" id="p-cid" placeholder="${esc(t('ui.citizen_id'))}"><input class="lw-in" id="p-amt" type="number" min="${D.limits.bountyMin}" max="${D.limits.bountyMax}" step="0.25" placeholder="$"><input class="lw-in" id="p-why" maxlength="120" placeholder="${esc(t('ui.for_what'))}"><button class="lxr-btn lxr-btn-sm" id="p-go">${esc(t('ui.post'))}</button>`;
      $('p-go').addEventListener('click', () => act('post', { citizenid: $('p-cid').value.trim(), amount: Number($('p-amt').value), reason: $('p-why').value.trim() }));
    } else p.classList.add('lxr-hidden');
    const b = $('board'); b.innerHTML = ''; $('board-count').textContent = pad(D.bounties.length);
    if (!D.bounties.length) b.innerHTML = `<div class="lw-empty">${esc(t('ui.board_empty'))}</div>`;
    D.bounties.forEach((x, i) => {
      const row = document.createElement('div'); row.className = 'lw-row';
      row.innerHTML = `<span class="lw-row__i">${pad(i + 1)}</span><div><div class="lw-row__name">${esc(x.name)}</div><div class="lw-row__sub">${esc(x.reason || '')}${x.posted_by ? ' · ' + esc(t('ui.posted_by')) + ' ' + esc(x.posted_by) : ''} · ${esc(when(x.created_at))}</div></div><span class="lw-row__amt">$${money(x.amount)}</span>${D.canPost ? `<button class="lxr-btn lxr-btn-ghost lxr-btn-sm">${esc(t('ui.pull'))}</button>` : '<span></span>'}`;
      const btn = row.querySelector('button'); if (btn) btn.addEventListener('click', () => act('pull', { id: x.id }));
      b.appendChild(row);
    });
  }
  async function act(name, body) {
    const r = await post(name, body);
    if (!r.ok) { if (r.why) toast(t('error.' + r.why), true); return; }
    if (r.data) { D = r.data; render(); }
    sound('NAV_UP');
  }
  $('btn-duty').addEventListener('click', () => act('duty'));
  $('btn-close').addEventListener('click', () => post('close'));
  document.addEventListener('keydown', (e) => { if (D && (e.key === 'Backspace' || e.key === 'Escape') && e.target.tagName !== 'INPUT') post('close'); });

  function open(m) {
    D = m.data; L = m.locale || {};
    document.body.classList.toggle('lang-ka', m.lang === 'ka');
    applyLocale(); app.classList.remove('lxr-hidden'); render();
  }
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.theme || (m.brand && m.brand.theme)) document.documentElement.dataset.theme = m.theme || m.brand.theme;
    if (m.action === 'open') open(m);
    if (m.action === 'close') { app.classList.add('lxr-hidden'); D = null; }
  });
  if (window.__LXR_MOCK__) open(window.__LXR_MOCK__);
})();
