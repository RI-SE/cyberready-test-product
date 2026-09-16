# Repository states (R1…Rn)

This file is the live registry of **scripts** that implement the R-states
defined by Curbpack
[controlled test prerequisites](https://github.com/RI-SE/curbpack/blob/main/docs/testing/procedures/0_controlled_repo_setup.md).
Curbpack defines what each R-id means. These scripts are the executable
manifestation. Do not change a state's meaning here.

`setup.sh` accepts only IDs listed in `states.list`. Add, remove or change a
state in `states.list`, `states/<ID>.sh` and this table together.

Curbpack suite cases (EV-002, …) *use* these states; they are not the setup
interface. Each independent case sources the verification-run environment
(restoring the frozen checkout), then prepares the named R-state.
R1–R9: `setup.sh` applies the state to this checkout. `--commit` records
the mutation on a local `test_<user>_<date>_<id>` branch. Those branches
remain until someone deletes them by hand. Do not push those branches.
Do not merge them into `main`. R4 and R5 replace this checkout with
demo-app based content from Curbpack testdata. They do not create
`tmp/R4` or `tmp/R5`. R6 and R7 add dated fixture docs and commit them
with the author metadata required by the fresh/owned checks; `--commit`
then records an already-clean tree. R8 and R9 change or remove
`src/app.py` and commit that tree; `--commit` then records an
already-clean tree.

| ID | Repository state | Seeded condition | Expected structural result | Used by |
|---|---|---|---|---|
| R1 | Starting Glucose Log product content — no extra mutation | Required files present (`SECURITY.md`, `.well-known/security.txt`, `docs/annex-vii/risk_assessment.md`, `docs/annex-vii/support_period.md`, `docs/annex-vii/user_manual_security.md`, `docs/incident/art14-path.md`, `docs/medtech/software_safety_class.md`, `docs/medtech/soup_list.md`, `docs/medtech/problem_resolution.md`, `package.json`); heading `## Classification Rationale` present; `package.json` dependency maps empty and no banned axios pin | Selected pack instance completes with the predeclared clean result (no missing required file/section) | Curbpack, CTAM |
| R2 | R1 with `SECURITY.md` removed (absent, not empty); other R1 content unchanged | `SECURITY.md` removed | `HOUSE-SECURITY-MD` does not pass | Curbpack |
| R3 | R1 with heading `## Classification Rationale` removed from `docs/medtech/software_safety_class.md`; file remains, other content unchanged | Heading removed | `MD-SW-CLASS` does not pass | Curbpack |
| R4 | demo-app content with token-only honesty-eval `SECURITY.md` and `package.json` identifying `acme-widget` (Curbpack definition) | Curbpack `testdata/demo-app` + `testdata/honesty-eval/token-only/SECURITY.md` on this checkout; `package.json` name `acme-widget` | `HOUSE-ANTI-PLACEHOLDER` does not pass | Curbpack |
| R5 | demo-app content with thin rule-satisfying honesty-eval `SECURITY.md` and original demo-app `package.json` (Curbpack definition) | Curbpack `testdata/demo-app` + `testdata/honesty-eval/real/SECURITY.md` on this checkout; original demo-app `package.json` | house-policy structural pass; no substance claim | Curbpack |
| R6 | R1 plus stale `docs/review-log.md` and `docs/owned-policy.md` committed as `Owner <owner@example.com>` dated `2022-01-01T00:00:00Z` | Authored commit with old dates on those two paths | `FIX-FRESH-REVIEW` does not pass under `fresh-owned-test` | Curbpack |
| R7 | R1 plus `docs/review-log.md` and `docs/owned-policy.md` committed as `Wrong Author <wrong@example.com>` dated `2026-09-13T12:00:00Z` | Authored commit with wrong author email on those two paths | `FIX-OWNED-POLICY` does not pass under `fresh-owned-test` | Curbpack |
| R8 | R1 with reviewed `src/app.py` insulin-disclaimer bytes changed; path remains | `src/app.py` committed with the disclaimer line edited once | Git artifact bytes differ; path still present | CTAM |
| R9 | R1 with `src/app.py` removed (absent, not empty); other R1 content unchanged | `src/app.py` removed | Git path/span absent at the comparison commit | CTAM |
