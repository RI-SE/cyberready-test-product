# Glucose Log

A tiny local web app that stores blood-glucose values a user types in.

This repository is a **CyberReady reference/test product**. It exists so developers can run a real, understandable application and later exercise Curbpack and CTAM against it.

It is **not** a medical device, **not** a clinical tool, and **not** medically validated. It does not calculate insulin, recommend treatment, or make clinical decisions. It only stores numbers.

## Run

From a clone of this repository:

```bash
make start
```

That command:

1. checks that Python 3 and the standard library modules are available
2. creates `var/` and initializes the SQLite database if needed
3. starts the server at http://127.0.0.1:8080
4. opens that URL in the default browser

Stop it with:

```bash
make stop
```

Run the test suite with:

```bash
make test
```

## Login

Local demo account (created on first start):

- username: `demo`
- password: `demo`

Passwords are stored as PBKDF2-HMAC-SHA256 hashes, not plaintext.

## Add and view measurements

1. Open the home page, then log in.
2. On `/measurements`, enter a numeric glucose value and click **Save**.
3. The same page lists previously stored measurements for the signed-in user.
4. Use **Log out** when finished.

Values are stored as entered. There is no clinical interpretation.

## Data on disk

Runtime files live in `var/` (gitignored):

- `var/glucose.db` — SQLite database (`users`, `measurements`)
- `var/audit.log` — local security-relevant events (login, save, unauthorized access)
- `var/app.pid` / `var/server.log` — process bookkeeping for `make start` / `make stop`

## Curbpack

This product is configured for the currently supported pack:

```text
house-policy
```

See `.curbpack.json` and `curbpack-ref.txt`. Pack files live in Curbpack, not in this repository.

From a sibling `curbpack` checkout pinned to `curbpack-ref.txt`:

```bash
pin=$(awk -F': ' '/^curbpack_commit:/{print $2; exit}' curbpack-ref.txt)
( cd ../curbpack && git checkout "$pin" && go build -o /tmp/curbpack ./cmd/curbpack )
/tmp/curbpack review --repo . --json
```

`review --repo` is in-repo document triage. It is not a product verdict, certification, or CE marking.
