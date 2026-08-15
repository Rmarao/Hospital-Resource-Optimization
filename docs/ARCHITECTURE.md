# Architecture

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
  `audit_logs` via `AuditLogService`.

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

## Notes / known limitations

- `equipment_failure_model.ser` is gitignored and regenerated by training on
  `ai4i2020.csv` the first time the app starts against a fresh checkout —
  expect a brief delay on that first run only.
- No client-side JavaScript framework — dropdowns/toggles that don't need a
  server round-trip use plain `<details>`/`<summary>`, keeping the frontend
  dependency-free.
- Containerized deployment (Docker) was removed for now while the app is
  still actively changing; it's recoverable from git history and will come
  back once things settle.
