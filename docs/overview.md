# Glucose Log overview

Glucose Log (`glucose-log` in `package.json`) is a single-process local web application. A developer runs `make start`, which launches `src/app.py` on http://127.0.0.1:8080 and opens a browser.

It is a CyberReady reference/test product. It stores blood-glucose numbers entered by a signed-in user. It does not interpret those numbers or make treatment decisions.

## Runtime shape

One Python 3 process using the standard library:

- `http.server` serves server-rendered HTML
- `sqlite3` stores users and measurements in `var/glucose.db`
- PBKDF2-HMAC-SHA256 hashes passwords
- an in-memory session cookie authenticates later requests
- JSON lines are appended to `var/audit.log` for login, logout, saves, and unauthorized access

There is no separate frontend build, no container, and no ORM. `package.json` names the product and lists empty dependency maps so Curbpack can evaluate manifest bans; the application is not a Node program.

## Pages

| Path | Role |
|---|---|
| `GET /` | Home |
| `GET /login`, `POST /login` | Login form and authentication |
| `GET /measurements`, `POST /measurements` | Enter and list stored measurements (authenticated) |
| `GET /logout` | End the session |

## Data handling

Measurements belong to the signed-in user id. There is no remote backup. Retention is “until the operator deletes `var/`”. Disposal is described in `docs/annex-vii/user_manual_security.md`.

## Major files

- `src/app.py` — application, HTML pages, database access, sessions, audit log
- `Makefile` — `start`, `stop`, `test`
- `tests/test_app.py` — HTTP behaviour tests
- `package.json` — product name `glucose-log`; empty npm dependency maps
- `docs/overview.md` — this file
- `docs/annex-vii/` — CRA-shaped drafts (risk, support period, user manual security)
- `docs/incident/art14-path.md` — Article 14 reporting path record
- `docs/medtech/` — IEC 62304-inspired drafts (class, SOUP, problem resolution)
- `README.md` — how to run the product
- `SECURITY.md` — vulnerability reporting
- `.well-known/security.txt` — security contact
- `.curbpack.json` — `house-policy` and `medtech-iec62304` (extends `cra-baseline`)

Generated SQLite data, audit logs, and the process pidfile stay under `var/` and are not tracked in Git.
