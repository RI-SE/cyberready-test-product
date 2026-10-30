# Glucose Log

A tiny local web app that stores blood-glucose values a user types in.

This repository is **[RI-SE/cyberready-test-product](https://github.com/RI-SE/cyberready-test-product)**, a **CyberReady reference/test product** named **glucose-log**. It exists so developers can run a real, understandable application and later exercise Curbpack and CTAM against it.

It is **not** a medical device, **not** a clinical tool, and **not** medically validated. It does not calculate insulin, recommend treatment, or make clinical decisions. It only stores numbers.

## Get it running

The app is Python 3 and the standard library. There is nothing to install with pip, venv, or npm.

On a Mac you need Git, `make`, and `python3`. A stock macOS install often has none of those until Apple's command line tools are present:

```bash
xcode-select --install
```

That typically provides `/usr/bin/make` and `/usr/bin/python3`. Check:

```bash
make --version
python3 --version
```

Then:

```bash
git clone https://github.com/RI-SE/cyberready-test-product.git
cd cyberready-test-product
make start
```

`make start` checks that `python3` can import `hashlib`, `http.server`, `secrets`, and `sqlite3`, creates `var/`, starts http://127.0.0.1:8080, and opens that URL in the default browser.

Log in with **demo** / **demo** (shown on the home and login pages).

If `python3` is still missing after the command line tools, install Python 3 (Homebrew `brew install python` is enough) and retry `make start`. If the interpreter is not named `python3`:

```bash
make start PYTHON=python
```

If port 8080 is already taken, `make start` waits and then times out. Stop the other process, or use another port:

```bash
make start PORT=8081
```

Stop the server with:

```bash
make stop
```

`make` with no arguments lists the commands.

## Tests

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

`curbpack.json` at the repository root selects the packs and names the directories curbcheck reads. The path fields point at `external_test/curbpack`:

```json
{
  "packs": ["house-policy", "cra-baseline", "medtech-iec62304", "nis2"],
  "packs_dir": "external_test/curbpack/packs",
  "claims_dir": "external_test/curbpack/claims",
  "results_dir": "external_test/curbpack",
  "reports_dir": "external_test/curbpack/reports",
  "unsigned_requirements": "reject"
}
```

The checked-in file also carries `search_hints`. Packs are `external_test/curbpack/packs/<pack-id>/pack.json`. Claims are `external_test/curbpack/claims/<claim-id>.json`. A requested run result is `external_test/curbpack/run-result_<UTC>.json`. A review report is `external_test/curbpack/reports/review-report_<UTC>.json`. `.curbpack.json` is not the selection file.

`medtech-iec62304` used to load `cra-baseline` through `extends`. That relation is gone. `cra-baseline` is named in this file because the pack is on disk and has to be listed itself. A description that says "Extends" does not add a pack.

CTAM reuses those R/P ids and adds its own states under `external_test/ctam/`, applied with `SUT=ctam`. A verification case sources the verification-run environment (which restores the disposable clone to `$REFERENCE_PRODUCT_COMMIT`), then runs `setup.sh` with an R-id.

### Run curbcheck

From this repository, with `curbcheck` on `PATH`:

```bash
curbcheck
```

That reads `curbpack.json`. `--repo` is required when the current directory has no `curbpack.json`. `--packs` replaces `external_test/curbpack/packs`. `--out` replaces the run-result file under `external_test/curbpack`.

### Step 1 — record the baseline

Use a fresh disposable clone of this test product. The command does not start the application server:

```bash
curbcheck
```

The configured packs are house-policy and medtech-iec62304. Record any unexpected failure before continuing. This is not a substitute for `make test`.

### Step 2 — remove one file and observe its claim

Move one file to a backup, run `curbcheck`, then restore it and recheck. Each row was tested independently against a passing baseline.

| Remove X | Expected new failed gate Y |
|---|---|
| `SECURITY.md` | `HOUSE-SECURITY-MD` |
| `.well-known/security.txt` | `HOUSE-SECURITY-TXT` |
| `docs/annex-vii/risk_assessment.md` | `CRA-ANNEX-VII-RISK` |
| `docs/medtech/software_safety_class.md` | `MD-SW-CLASS` |
| `docs/medtech/problem_resolution.md` | `MD-PROBLEM-RESOLUTION` |

For example, from the cyberready-test-product root:

```bash
mv SECURITY.md SECURITY.md.saved
curbcheck
mv SECURITY.md.saved SECURITY.md
curbcheck
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
