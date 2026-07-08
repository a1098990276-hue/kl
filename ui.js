// ui.js - UI utilities, modals, navigation, and helpers

const $ = id => document.getElementById(id);

const fmt = (n, d = 2) => {
  const num = +n || 0;
  return num.toLocaleString('ar-SA', { minimumFractionDigits: d, maximumFractionDigits: d });
};

const fmtDate = (dateStr) => {
  if (!dateStr) return '-';
  const d = new Date(dateStr);
  return d.toLocaleDateString('ar-SA', { year: 'numeric', month: '2-digit', day: '2-digit' });
};

const today = () => new Date().toISOString().split('T')[0];

const todayAr = () => new Date().toLocaleDateString('ar-SA', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

const TITLES = {
  dash: 'لوحة التحكم', pos: 'نقطة البيع POS', invs: 'الفواتير', custs: 'العملاء',
  purs: 'المشتريات', sups: 'الموردون', jv: 'القيود اليومية', coa: 'شجرة الحسابات',
  trial: 'ميزان المراجعة', stock: 'المخزون', assets: 'الأصول الثابتة', exps: 'المصروفات',
  reps: 'التقارير المالية', zatca: 'ZATCA', cfg: 'الإعدادات',
  ledger: 'دفتر الأستاذ العام', vouchers: 'سندات القبض والصرف', stmt: 'كشوفات الحسابات',
  'ret-sales': 'مرتجعات المبيعات', 'ret-purs': 'مرتجعات المشتريات',
  balance: 'الميزانية العمومية', aging: 'أعمار الديون', banks: 'الحسابات البنكية',
  quotes: 'عروض الأسعار', cheques: 'إدارة الشيكات', 'cost-center': 'مراكز التكلفة',
  cashflow: 'التدفقات النقدية', budget: 'الموازنة التقديرية', audit: 'سجل المراجعة'
};

const Modal = {
  open(id) { const m = $(id); if (m) m.classList.add('on'); },
  close(id) { const m = $(id); if (m) m.classList.remove('on'); },
  closeAll() { document.querySelectorAll('.modal.on').forEach(m => m.classList.remove('on')); },
  init() {
    document.querySelectorAll('.modal').forEach(m => {
      m.addEventListener('click', e => { if (e.target === m) m.classList.remove('on'); });
    });
    document.addEventListener('keydown', e => { if (e.key === 'Escape') Modal.closeAll(); });
  }
};

const Nav = {
  currentPage: null,
  loaders: {},
  register(pageId, fn) { this.loaders[pageId] = fn; },
  async go(id, btn) {
    document.querySelectorAll('.pg').forEach(p => p.classList.remove('on'));
    document.querySelectorAll('.nb').forEach(b => b.classList.remove('on'));
    const page = $(`p-${id}`);
    if (page) page.classList.add('on');
    if (btn) btn.classList.add('on');
    // Find and highlight the correct sidebar button if not passed
    if (!btn) {
      document.querySelectorAll('.nb').forEach(b => {
        const onclick = b.getAttribute('onclick');
        if (onclick && onclick.includes("'" + id + "'")) b.classList.add('on');
      });
    }
    $('pg-title').innerText = TITLES[id] || id;
    if (this.loaders[id]) await this.loaders[id]();
    this.currentPage = id;
  },
  init() { $('today-lbl').innerText = todayAr(); }
};

const Toast = {
  show(msg, type = 'success', dur = 3000) {
    const t = document.createElement('div');
    const icon = type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle';
    const bg = type === 'success' ? 'linear-gradient(135deg,#059669,#10b981)' : type === 'error' ? 'linear-gradient(135deg,#dc2626,#ef4444)' : 'linear-gradient(135deg,#2563eb,#3b82f6)';
    t.innerHTML = `<i class="fas fa-${icon}"></i><span>${msg}</span>`;
    t.style.cssText = `position:fixed;bottom:24px;left:50%;transform:translateX(-50%);padding:12px 28px;background:${bg};color:#fff;border-radius:12px;font-size:.85rem;font-weight:600;display:flex;align-items:center;gap:10px;z-index:99999;animation:slideUp .3s ease;box-shadow:0 8px 24px rgba(0,0,0,.25);direction:rtl;font-family:inherit;`;
    document.body.appendChild(t);
    setTimeout(() => { t.style.opacity = '0'; t.style.transition = 'opacity .3s'; setTimeout(() => t.remove(), 300); }, dur);
  }
};

// Date range picker helper
function getDateRange(period) {
  const now = new Date();
  let from, to;
  to = now.toISOString().split('T')[0];
  switch (period) {
    case 'today':
      from = to; break;
    case 'week':
      const weekStart = new Date(now); weekStart.setDate(now.getDate() - now.getDay());
      from = weekStart.toISOString().split('T')[0]; break;
    case 'month':
      from = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`; break;
    case 'quarter':
      const qm = Math.floor(now.getMonth() / 3) * 3;
      from = `${now.getFullYear()}-${String(qm + 1).padStart(2, '0')}-01`; break;
    case 'year':
      from = `${now.getFullYear()}-01-01`; break;
    default:
      from = '2020-01-01';
  }
  return { from, to };
}

function filterByDate(items, dateField, from, to) {
  return items.filter(item => {
    const d = item[dateField];
    if (!d) return false;
    return d >= from && d <= to;
  });
}

function populateSelect(selectId, items, valueField, labelField, defaultOption) {
  const sel = $(selectId);
  if (!sel) return;
  const opts = items.map(i => `<option value="${i[valueField]}">${i[labelField]}</option>`).join('');
  sel.innerHTML = (defaultOption ? `<option value="">${defaultOption}</option>` : '') + opts;
}

export { $, fmt, fmtDate, today, todayAr, TITLES, Modal, Nav, Toast, getDateRange, filterByDate, populateSelect };
