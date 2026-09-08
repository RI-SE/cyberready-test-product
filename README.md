# Glucose Log

A tiny local web app that stores blood-glucose values a user types in.

This repository is **[RI-SE/cyberready-test-product](https://github.com/RI-SE/cyberready-test-product)**, a **CyberReady reference/test product** named **glucose-log**. It exists so developers can run a real, understandable application and later exercise Curbpack and CTAM against it.

It is **not** a medical device, **not** a clinical tool, and **not** medically validated. It does not calculate insulin, recommend treatment, or make clinical decisions. It only stores numbers.

## Run

From a clone of this repository, `make` lists the available commands.

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

That prints one compact line per case, grouped as unit, functional, and
integration. Subsets: `make test-unit`, `make test-functional`,
`make test-integration`.

## Login

The home page and the login page print the local demo account:

- username: `demo`
- password: `demo`

The login form is prefilled. Passwords in SQLite are PBKDF2-HMAC-SHA256 hashes, not plaintext.

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

`.curbpack.json` selects:

```text
house-policy
medtech-iec62304
```

`medtech-iec62304` extends `cra-baseline`, so CRA Annex VII / Art 14 gates run through that pack. Do not also list `cra-baseline` unless you intend to name it twice; Compose already loads the base.

Pack JSON lives in Curbpack, not here. See `curbpack-ref.txt`.

Use a labelled pre-beta binary that includes the merged hardening reference in
`curbpack-ref.txt`. Keep its absolute path in `CURBPACK_BIN` so PATH cannot select
an older release. This reference is for Curbpack, not the application's version.

### Step 1 — record the baseline

Use a fresh disposable clone of this test product. The commands below do not
require starting the application server:

```bash
export CURBPACK_BIN=/absolute/path/to/curbpack-prebeta
"$CURBPACK_BIN" version
"$CURBPACK_BIN" scan
"$CURBPACK_BIN" check --json
"$CURBPACK_BIN" review --repo . --json
```

The configured packs are house-policy and medtech-iec62304 (including its CRA
base). The baseline gate check should pass; record any unexpected existing
failure before continuing. `review --repo` is document triage, not a product
verdict or a substitute for `make test`.

### Step 2 — remove one file and observe its gate

Move one file to a backup, run `check`, then restore it and recheck. Each row
was tested independently against a passing baseline. **Do not run `share` or
`--heal` while a file is absent:** those commands can recreate draft inputs.

| Remove X | Expected new failed gate Y |
|---|---|
| `SECURITY.md` | `HOUSE-SECURITY-MD` |
| `.well-known/security.txt` | `HOUSE-SECURITY-TXT` |
| `docs/annex-vii/risk_assessment.md` | `CRA-ANNEX-VII-RISK` |
| `docs/medtech/software_safety_class.md` | `MD-SW-CLASS` |
| `docs/medtech/problem_resolution.md` | `MD-PROBLEM-RESOLUTION` |

For example, from the test-product root:

```bash
mv SECURITY.md SECURITY.md.saved
"$CURBPACK_BIN" check --json       # expected exit 1; HOUSE-SECURITY-MD
mv SECURITY.md.saved SECURITY.md
"$CURBPACK_BIN" check --json       # expected exit 0 again
```

Restore the file even if a result differs. The selected packs do not define an
application-test-presence gate: deleting a Python test is not this exercise.
Application tests are `tests/test_unit.py`, `tests/test_functional.py` and
`tests/test_integration.py`, run with `make test`.

### Step 3 — create and review the restored handoff

```bash
"$CURBPACK_BIN" share --bundle
"$CURBPACK_BIN" review review-pack --json
```

Open `review-pack/evidence-bundle.html`. Integrity and declared artifact coverage
are separate from authenticity and applicability. These commands do not grant
certification, CE marking, or a product approval. Keep this private test product
and its reports out of public Curbpack issues and pull requests.
