// Shared UI polish layer: toasts, animated counters/bars, confirm modals,
// submit-button loading state. Pure vanilla JS, no framework/build step —
// keeps the app dependency-free. Loaded on every page via the shared
// admin-sidebar / doctor-navbar / patient-navbar fragments.
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    initToasts();
    initAnimatedCounters();
    initAnimatedBars();
    initConfirmModals();
    initSubmitSpinners();
  });

  // ---------- Toasts: convert server-rendered .alert banners into
  // dismissible, auto-expiring floating toasts. ----------
  function initToasts() {
    var alerts = document.querySelectorAll('.alert');
    if (!alerts.length) return;

    var root = document.getElementById('toast-root');
    if (!root) {
      root = document.createElement('div');
      root.id = 'toast-root';
      root.className = 'toast-root';
      document.body.appendChild(root);
    }

    alerts.forEach(function (alertEl) {
      var toneClass = ['success', 'error', 'warning', 'info'].find(function (t) {
        return alertEl.classList.contains(t);
      }) || 'info';

      alertEl.classList.remove('alert');
      alertEl.classList.add('toast', toneClass);

      var closeBtn = document.createElement('button');
      closeBtn.className = 'toast-close';
      closeBtn.setAttribute('aria-label', 'Dismiss');
      closeBtn.textContent = '×';
      alertEl.appendChild(closeBtn);

      var progress = document.createElement('div');
      progress.className = 'toast-progress';
      progress.style.width = '100%';
      alertEl.appendChild(progress);

      root.appendChild(alertEl);

      var DURATION = 6000;
      var start = Date.now();
      requestAnimationFrame(function () {
        progress.style.transition = 'width ' + DURATION + 'ms linear';
        progress.style.width = '0%';
      });

      var dismissed = false;
      function dismiss() {
        if (dismissed) return;
        dismissed = true;
        alertEl.classList.add('leaving');
        setTimeout(function () { alertEl.remove(); }, 260);
      }

      var timer = setTimeout(dismiss, DURATION);
      closeBtn.addEventListener('click', function () {
        clearTimeout(timer);
        dismiss();
      });
      alertEl.addEventListener('mouseenter', function () { clearTimeout(timer); });
      alertEl.addEventListener('mouseleave', function () {
        var remaining = Math.max(DURATION - (Date.now() - start), 1200);
        timer = setTimeout(dismiss, remaining);
      });
    });
  }

  // ---------- Animated stat counters: count up any stat-card .value
  // that's a plain integer (optionally with thousands separators). ----------
  function initAnimatedCounters() {
    var targets = document.querySelectorAll('.stat-card .value');
    targets.forEach(function (el) {
      var raw = el.textContent.trim();
      if (!/^\d{1,3}(,\d{3})*$|^\d+$/.test(raw)) return; // skip non-numeric labels
      var target = parseInt(raw.replace(/,/g, ''), 10);
      if (isNaN(target)) return;

      var duration = 700;
      var startTime = null;
      function step(ts) {
        if (startTime === null) startTime = ts;
        var progress = Math.min((ts - startTime) / duration, 1);
        var eased = 1 - Math.pow(1 - progress, 3);
        el.textContent = Math.round(target * eased).toLocaleString();
        if (progress < 1) requestAnimationFrame(step);
        else el.textContent = target.toLocaleString();
      }
      el.textContent = '0';
      requestAnimationFrame(step);
    });
  }

  // ---------- Animated progress/occupancy bars: grow from 0 to their
  // server-rendered target width on load (the width transition itself is
  // already defined in CSS on .progress-fill). ----------
  function initAnimatedBars() {
    var bars = document.querySelectorAll('.progress-fill');
    bars.forEach(function (bar) {
      var target = bar.style.width;
      if (!target) return;
      bar.style.width = '0%';
      requestAnimationFrame(function () {
        requestAnimationFrame(function () { bar.style.width = target; });
      });
    });
  }

  // ---------- Confirm modals: replace window.confirm() with a styled
  // in-page dialog for any <form data-confirm="message">. ----------
  function initConfirmModals() {
    var forms = document.querySelectorAll('form[data-confirm]');
    forms.forEach(function (form) {
      form.addEventListener('submit', function (e) {
        if (form.dataset.confirmed === 'true') return; // already confirmed, let it through
        e.preventDefault();
        showConfirmModal(form.dataset.confirm, function () {
          form.dataset.confirmed = 'true';
          form.requestSubmit ? form.requestSubmit() : form.submit();
        });
      });
    });
  }

  function showConfirmModal(message, onConfirm) {
    var overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML =
      '<div class="modal" role="alertdialog" aria-modal="true">' +
      '  <h3><i class="icon icon-alert-triangle"></i> Please confirm</h3>' +
      '  <p></p>' +
      '  <div class="modal-actions">' +
      '    <button type="button" class="btn btn-sm" data-role="cancel">Cancel</button>' +
      '    <button type="button" class="btn btn-danger btn-sm" data-role="ok">Confirm</button>' +
      '  </div>' +
      '</div>';
    overlay.querySelector('p').textContent = message;
    document.body.appendChild(overlay);

    function close() { overlay.remove(); document.removeEventListener('keydown', onKey); }
    function onKey(e) { if (e.key === 'Escape') close(); }

    overlay.addEventListener('click', function (e) { if (e.target === overlay) close(); });
    overlay.querySelector('[data-role="cancel"]').addEventListener('click', close);
    overlay.querySelector('[data-role="ok"]').addEventListener('click', function () {
      close();
      onConfirm();
    });
    document.addEventListener('keydown', onKey);
    overlay.querySelector('[data-role="ok"]').focus();
  }

  // ---------- Submit-button loading state: gives feedback during the
  // POST-redirect-GET round trip instead of the button looking inert. ----------
  function initSubmitSpinners() {
    document.querySelectorAll('form').forEach(function (form) {
      form.addEventListener('submit', function () {
        // If this form uses the confirm-modal flow, don't spin until it's
        // actually confirmed (submit fires again once dataset.confirmed=true).
        if (form.hasAttribute('data-confirm') && form.dataset.confirmed !== 'true') return;
        var btn = form.querySelector('button[type="submit"]');
        if (!btn || btn.disabled) return;
        btn.dataset.originalHtml = btn.innerHTML;
        btn.innerHTML = '<span class="btn-spinner"></span>' + btn.textContent.trim();
        btn.disabled = true;
      });
    });

    // Browsers can restore a bfcache'd page with buttons still mid-spin
    // (e.g. the user hit back after submitting) — put them back.
    window.addEventListener('pageshow', function (e) {
      if (!e.persisted) return;
      document.querySelectorAll('button[data-original-html]').forEach(function (btn) {
        btn.innerHTML = btn.dataset.originalHtml;
        btn.disabled = false;
        delete btn.dataset.originalHtml;
      });
    });
  }
})();
