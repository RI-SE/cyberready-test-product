# Risk Assessment

This draft describes how glucose-log is operated as a local CyberReady reference/test product.
It is a structural evidence file for human review. It is not a CRA conformity assessment and does not claim that glucose-log is secure for production or for clinical use.

## Product Overview

glucose-log is a single-process Python 3 web application (`src/app.py`) that stores blood-glucose numbers a signed-in user types in. It binds to http://127.0.0.1:8080, uses a local SQLite file under the gitignored var directory, and writes security-relevant events to a local audit log in that same directory.

Intended use: local demonstration and later Curbpack/CTAM exercise. Not a medical device. It does not calculate insulin, recommend treatment, diagnose, or make clinical decisions.

Operating environment: a developer workstation. The process is not intended to be exposed on a public network.

## Identified Risks

| Risk ID | Description | Severity | Mitigation |
|---------|-------------|----------|------------|
| R-001 | Unauthenticated write or read of measurements | High | Session cookie required before reading or saving measurements; unauthenticated attempts redirect to login and are audited. |
| R-002 | SQL injection via login or glucose fields | High | All SQLite access uses parameterized queries. Non-numeric glucose values are rejected. Covered by `make test`. |
| R-003 | Passwords stored in plaintext | High | Passwords are stored as PBKDF2-HMAC-SHA256 (`salt$digest`) in SQLite, never as the demo password string. |
| R-004 | Guessable local demo account | Medium | The demo login is printed on the home and login pages on purpose for classroom use. The server listens on 127.0.0.1 only. |
| R-005 | Session reuse after logout | Medium | Logout deletes the in-memory session token and clears the cookie. Sessions do not survive process restart. |
| R-006 | Local SQLite or audit log left on disk | Medium | The var directory is gitignored. Disposal is deletion of that directory and the clone, as described in the user manual security file. |
| R-007 | Cross-site scripting of stored values | Medium | HTML output runs through `html.escape`. There is no client-side script besides none. |

## Residual Risk Statement

After the mitigations above, residual risk for glucose-log is that anyone with local access to the workstation can read the SQLite database and the audit log in the var directory, and that the published demo password is usable on that local instance. That is accepted for a reference product that is not deployed as a network service.
