# Setup

## 1. Install MySQL 8+ and create an empty schema

```bash
mysql -u root -p -e "CREATE DATABASE hospital_db"
```

Flyway migrations (`src/main/resources/db/migration/`) create the tables
and seed a default admin + sample doctor login automatically on first
`mvnw spring-boot:run` — no manual SQL script to run.

## 2. Configure secrets as environment variables

Nothing sensitive lives in `application.properties` — it only contains
`${VAR:default}` placeholders.

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

```bash
export DB_PASSWORD=yourpassword
export APP_ENCRYPTION_KEY=$(openssl rand -base64 32)
./mvnw spring-boot:run
```

## 3. Run

```bash
./mvnw spring-boot:run
```

Visit `http://localhost:8080`.

- Default admin login (seeded by Flyway): `admin@hospital.com` / `admin123`
- Default doctor login: `doctor@hospital.com` / `doctor123`
- Default patient login: `patient@hospital.com` / `patient123`
- Or register a new patient at `/signup`

**Change or remove these default credentials before any real deployment.**

## Testing

```bash
./mvnw test
```

17 tests across repository-slice tests (`@DataJpaTest` against H2, overlap
queries), service tests (auto-discharge, ML prediction, LLM analysis with a
mocked HTTP client), and a Spring context load test.

## Dependency updates

`.github/dependabot.yml` opens a PR whenever a Maven or GitHub Actions
dependency has a newer version available — review and merge (or close)
these individually.
