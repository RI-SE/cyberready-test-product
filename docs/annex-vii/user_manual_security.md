# User Manual — Security

Security-relevant operating notes for glucose-log, the local CyberReady reference product.
This is not a medical user manual and not a claim that the product is safe to expose on a network.

## Secure Configuration

1. Run only via `make start` on the machine that should hold the SQLite file.
2. Confirm the process listens on http://127.0.0.1:8080 — not on `0.0.0.0`.
3. Use the local demo account printed on the home page (username `demo`, password `demo`). That password is for classroom use on localhost, not for a shared deployment.
4. Keep the local var directory off Git. It contains the SQLite database and the audit log.
5. Do not put production secrets in `README.md`, `SECURITY.md`, or `.well-known/security.txt`.
6. Stop the process with `make stop` when finished.

Default-secure behaviour already in the binary: parameterized SQL, hashed passwords, session cookie with `HttpOnly` and `SameSite=Lax`, authentication before measurement access, and HTML escaping of stored values.

## Product Disposal

To decommission a local glucose-log instance:

1. `make stop` if the server is running.
2. Delete the local var directory (SQLite database, audit log, pidfile, server log).
3. Delete the clone if the working tree is no longer needed.

There is no cloud copy. Disposal is local filesystem deletion.
