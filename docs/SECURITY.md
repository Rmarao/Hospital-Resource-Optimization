# Security

- Authentication is handled by Spring Security (`SecurityConfig`), with a
  custom `AppUserDetailsService` checking the Admin/Doctor/Patient tables in
  turn. Passwords are BCrypt-hashed (`PasswordEncoder`), not plaintext.
- CSRF protection is enabled; every form includes a hidden `_csrf` token.
- Role-based access control is enforced at the URL level
  (`/admin/**`, `/doctor/**`, `/patient/**`), and cross-checked again inside
  controllers wherever an action could otherwise act on another user's data
  (e.g. a doctor discharging a patient, or responding to an appointment
  request, only succeeds if that record actually belongs to them).
- Login and signup are rate-limited (in-memory sliding window, capped size)
  against brute-force/enumeration.
- Bean Validation (`@Validated` + constraint annotations) guards signup,
  doctor registration, and clinical-note submission.
- All entity fields that can contain user-supplied free text (names,
  addresses, medical history, notes, appointment reasons, etc.) are
  HTML-escaped at render time (`com.hospital.util.Esc`) before being written
  into a JSP scriptlet, to prevent stored XSS from a patient's own
  self-registration data reaching an admin's or doctor's browser session.

## Production data protection

- **Backups**: no automated backup job is included. Run a scheduled
  `mysqldump` (e.g. via cron or Windows Task Scheduler) against `hospital_db`
  and store dumps somewhere off the DB host. At minimum:
  ```bash
  mysqldump -u root -p hospital_db > backup_$(date +%F).sql
  ```
- **TLS**: the app serves plain HTTP on 8080. For any real deployment, put
  it behind a reverse proxy (nginx/Caddy) terminating TLS, or configure a
  Tomcat SSL connector directly — don't expose port 8080 to the internet
  unencrypted.
- **Encryption at rest**: `medical_history` and the Google Fit tokens are
  encrypted with AES-256-GCM (`AesGcmStringConverter`) — see the
  `APP_ENCRYPTION_KEY` env var in [SETUP.md](SETUP.md).
- **Audit log**: sensitive patient-data actions are recorded in the
  `audit_logs` table via `AuditLogService` — actor, action, entity, and
  timestamp. Viewable in the admin Audit Log page.
- **Third-party data**: `LLMAnalysisService` sends patient medical history
  text to Groq for AI triage. This is currently enabled by default — review
  Groq's data retention/processing terms before handling real patient data
  at scale.
