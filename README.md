# Hospital Resource Optimization

A Spring Boot 4 (Java 17) hospital management system with three portals —
**Admin**, **Doctor**, and **Patient** — for managing beds, ICU units,
operating theatres, oxygen tanks, and blood bank stock, plus an ML-driven
equipment failure predictor and an LLM-assisted patient triage flow.

## Stack

- **Backend**: Spring Boot 4, Spring MVC, Spring Data JPA, Spring Security
- **Views**: JSP + JSTL (server-rendered), a small dependency-free CSS design
  system (custom properties, mask-icon SVGs, no client-side framework)
- **DB**: MySQL, schema/migrations managed by Flyway
- **Caching**: Caffeine (short-TTL caches for dashboard stats and alert
  aggregation, so heavy pages don't re-scan tables on every request)
- **ML**: [Tribuo](https://tribuo.org) (Oracle's Java ML library) — trains a
  CART decision tree on the public **AI4I 2020 Predictive Maintenance
  dataset** to predict equipment (X-Ray/CT/MRI) failure risk, with a
  rule-based fallback if training fails
- **LLM**: Groq API (Llama 3.3) — analyzes a patient's medical history text
  and returns a structured JSON triage recommendation (department, severity,
  urgency, resources needed)
- **Integrations**: Google Fit OAuth (steps/calories/heart-rate for patients)

## Features

**Admin**
- Dashboard with live resource occupancy bars (beds/ICU/OT/oxygen), a
  patient risk-level distribution chart, and today's schedule/admissions
- Bed, ICU, OT, oxygen tank, and blood bank inventory management
- Doctor and patient management, with search and CSV export on both
- AI-assisted patient triage: severity scoring, auto-assign best-fit doctor,
  auto-allocate bed/ICU/OT based on the recommendation
- Doctor weekly availability calendar
- Alerts center (low blood stock, expiring blood, low oxygen, high-risk
  equipment) with a live notification bell showing a preview dropdown
- Audit log viewer

**Doctor**
- Assigned-patient list with clinical history, current bed/ICU/OT status
- Add clinical notes/prescriptions; book OT procedures (with conflict
  detection against the OT and the doctor's own schedule); discharge patients
  from bed/ICU (restricted to their own assigned patients)
- Set weekly availability
- Review and approve/reject patient appointment/follow-up requests, with a
  notification bell for pending ones
- Profile editing + password change

**Patient**
- Self-service signup and dashboard: assigned doctor, current admission,
  upcoming procedures, clinical notes/prescriptions
- Upcoming-care reminders banner (next procedure, next follow-up, expected
  discharge — derived from existing data, no extra tracking)
- Request an appointment/follow-up with their assigned doctor
- Printable visit/discharge summary
- Google Fit integration (steps/calories/heart-rate)
- Profile editing + password change

## Project layout

```
src/main/java/com/hospital/
  model/        JPA entities — Admin, Doctor, Patient, Bed, Icu, Ot,
                OxygenTank, BloodBank, BedAdmission, IcuAdmission, OtSchedule,
                DoctorPatient, DoctorAvailability, EquipmentLog,
                PatientRecommendation, PatientNote, AppointmentRequest,
                AuditLog
  repository/   Spring Data JPA repositories, incl. overlap-detection
                queries for double-booking beds/ICU/OT
  service/      MachinePredictionService (Tribuo ML), LLMAnalysisService
                (Groq), GoogleFitService (OAuth + Fitness API),
                AutoDischargeService (@Scheduled midnight discharge job +
                6-hourly equipment simulation), AlertsService (cached alert
                aggregation), DashboardStatsService (cached resource counts),
                AuditLogService, RateLimiterService
  security/     SecurityConfig, AppUserDetailsService, AppUserPrincipal,
                LoginSuccessHandler, LoginFailureHandler,
                RateLimitedAuthenticationProvider
  crypto/       AesGcmStringConverter (field-level encryption at rest)
  util/         Esc (HTML-escaping helper for JSP scriptlets), Csv (RFC
                4180 field escaping), Names (doctor-title normalization)
  config/       CacheConfig, GlobalExceptionHandler,
                NavbarNotificationAdvice (injects notification-bell counts
                into every admin/doctor page via @ControllerAdvice)
  controller/   LoginController, SignupController, DashboardController
                (3 dashboards), AdminDoctorController, AdminPatientController,
                AdminResourceController, AdminAlertsController,
                AdminAuditController, AdminAvailabilityController,
                DoctorController, DoctorAvailabilityController,
                DoctorProfileController, PatientAppointmentController,
                PatientProfileController, PatientSummaryController,
                MachinePredictionController, PatientFitnessController,
                StaticPageController
src/main/webapp/WEB-INF/views/   JSP pages for login/signup + admin/doctor/patient
                                  portals, fragments/ for shared navbar/sidebar includes
src/main/resources/              application.properties, ai4i2020.csv (ML training data),
                                  db/migration/ (Flyway)
```

## How the core flows work

- **Auth**: Spring Security (`SecurityConfig`) with a custom
  `AppUserDetailsService` checking the Admin/Doctor/Patient tables in turn.
  Only patients can self-register; admins/doctors are seeded via Flyway
  (`V2__seed_data.sql`) or created by an admin.
- **Scheduling conflicts**: `BedAdmissionRepository`, `IcuAdmissionRepository`,
  and `OtScheduleRepository` all have custom `@Query` methods that detect
  date/time overlaps before a booking is allowed; the assign endpoints run
  in a `SERIALIZABLE` transaction to close the check-then-insert race. The
  same conflict checks are reused by both the admin scheduling flow and the
  doctor's own OT-booking endpoint.
- **Equipment prediction**: `MachinePredictionService` cleans the bundled
  AI4I CSV, trains a CART classifier via Tribuo on first run, serializes it
  to `equipment_failure_model.ser` (gitignored, regenerated on first
  startup), and reuses it afterward. Hospital sensor readings (room/internal
  temp, usage intensity, etc.) are remapped onto the dataset's feature space
  (Kelvin, RPM, torque, tool wear) to get a LOW/MEDIUM/HIGH risk prediction.
- **Patient triage**: `LLMAnalysisService` sends the patient's free-text
  medical history to Groq, gets back a structured JSON recommendation, then
  can auto-score/assign the best-fit doctor (weighted by specialization
  match, experience, and current caseload) and auto-allocate a bed/ICU/OT
  slot based on what the recommendation says the patient needs.
- **Auto-discharge**: a `@Scheduled` cron job runs nightly to discharge
  patients past their discharge date and free up beds/ICU/OT.
- **Clinical notes**: doctors can record a diagnosis/prescription/advice per
  patient (`PatientNote`); patients see their own note history on their
  dashboard and in their printable visit summary.
- **Appointment requests**: a patient can request a follow-up with their
  assigned doctor; the doctor sees it in a dedicated queue (and the
  navbar notification bell) and approves or rejects it.
- **Alerts**: `AlertsService` aggregates low/expiring blood stock, low
  oxygen tanks, and equipment currently predicted HIGH risk into one
  30s-cached summary, shared by the admin Alerts page and the navbar bell
  so the two can't drift out of sync.
- **Audit log**: sensitive patient-data actions (doctor assignment, bed/ICU/OT
  admission/release/booking, AI triage, clinical notes, doctor account
  create/delete, CSV exports, profile/password changes) are recorded in
  `audit_logs` via `AuditLogService` — see "Production data protection" below.

## Setup

1. **Install MySQL 8+** and create an empty schema:
   ```
   mysql -u root -p -e "CREATE DATABASE hospital_db"
   ```
   Flyway migrations (`src/main/resources/db/migration/`) create the tables
   and seed a default admin + sample doctor login automatically on first
   `mvnw spring-boot:run` — no manual SQL script to run.

2. **Configure secrets as environment variables** (nothing sensitive lives in
   `application.properties` — it only contains `${VAR:default}` placeholders):

   | Variable | Required | Default | Purpose |
   |---|---|---|---|
   | `DB_URL` | no | `jdbc:mysql://localhost:3306/hospital_db?...` | MySQL JDBC URL |
   | `DB_USERNAME` | no | `root` | MySQL username |
   | `DB_PASSWORD` | **yes** | `changeme` (will fail to connect) | MySQL password |
   | `GROQ_API_KEY` | no | `CHANGE_ME` | Free key from https://console.groq.com — app falls back to a default triage recommendation without it |
   | `GOOGLE_FIT_CLIENT_ID` / `GOOGLE_FIT_CLIENT_SECRET` | no | `CHANGE_ME` | From Google Cloud Console — only needed for the patient fitness page |
   | `GOOGLE_FIT_REDIRECT_URI` | no | `http://localhost:8080/patient/fitness/callback` | OAuth redirect URI |
   | `APP_ENCRYPTION_KEY` | **yes** (for any persistent environment) | ephemeral (regenerated each restart) | Base64 AES-256 key encrypting medical history + Google Fit tokens at rest. Generate with `openssl rand -base64 32`. |

   Set these in your shell before running, e.g.:
   ```
   export DB_PASSWORD=yourpassword
   export APP_ENCRYPTION_KEY=$(openssl rand -base64 32)
   ./mvnw spring-boot:run
   ```

3. **Run**:
   ```
   ./mvnw spring-boot:run
   ```
   Visit `http://localhost:8080`.

   Default admin login (seeded by Flyway): `admin@hospital.com` / `admin123`
   Default doctor login: `doctor@hospital.com` / `doctor123`
   Patients register themselves at `/signup`.

   **Change or remove these default credentials before any real deployment.**

### Docker

A `Dockerfile` (multi-stage: builds the WAR, runs it on Tomcat) and
`docker-compose.yml` (app + MySQL, with a healthcheck gate so the app
doesn't start before the DB is ready) are included:

```
cp .env.example .env   # fill in DB_PASSWORD, APP_ENCRYPTION_KEY, etc.
docker compose up --build
```

This runs the app with the `prod` Spring profile
(`application-prod.properties` — no stack traces to clients, health details
gated to authorized requests, devtools disabled).

## Security

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
  ```
  mysqldump -u root -p hospital_db > backup_$(date +%F).sql
  ```
- **TLS**: the app serves plain HTTP on 8080. For any real deployment, put
  it behind a reverse proxy (nginx/Caddy) terminating TLS, or configure a
  Tomcat SSL connector directly — don't expose port 8080 to the internet
  unencrypted.
- **Encryption at rest**: `medical_history` and the Google Fit tokens are
  encrypted with AES-256-GCM (`AesGcmStringConverter`) — see the
  `APP_ENCRYPTION_KEY` env var above.
- **Audit log**: sensitive patient-data actions are recorded in the
  `audit_logs` table via `AuditLogService` — actor, action, entity, and
  timestamp. Viewable in the admin Audit Log page.
- **Third-party data**: `LLMAnalysisService` sends patient medical history
  text to Groq for AI triage. This is currently enabled by default — review
  Groq's data retention/processing terms before handling real patient data
  at scale.

## Database migrations

Schema changes are versioned Flyway migrations under
`src/main/resources/db/migration/` (`V1__init_schema.sql` through
`V6__strip_doctor_title_prefix.sql`). To make a schema change, add a new
`V{n}__description.sql` file — never edit an already-applied migration.
`spring.jpa.hibernate.ddl-auto=validate` means Hibernate will refuse to
start if the entities and the Flyway-managed schema disagree, which is
intentional (it catches drift early). Tests use Hibernate `ddl-auto=create-drop`
against an in-memory H2 database instead (`src/test/resources/application.properties`),
so Flyway is disabled there.

## Testing

```
./mvnw test
```

17 tests across repository-slice tests (`@DataJpaTest` against H2, overlap
queries), service tests (auto-discharge, ML prediction, LLM analysis with a
mocked HTTP client), and a Spring context load test.

## CI

`.github/workflows/ci.yml` runs `mvnw test` on every push/PR;
`.github/dependabot.yml` keeps Maven and GitHub Actions dependencies patched.

## Notes / known limitations

- `equipment_failure_model.ser` is gitignored and regenerated by training on
  `ai4i2020.csv` the first time the app starts against a fresh checkout —
  expect a brief delay on that first run only.
- No client-side JavaScript framework — dropdowns/toggles that don't need a
  server round-trip use plain `<details>`/`<summary>`, keeping the frontend
  dependency-free.
