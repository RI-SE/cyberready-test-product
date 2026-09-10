# Repository states (R1…Rn)

This file is the live registry required by Curbpack
[controlled test prerequisites](https://github.com/RI-SE/curbpack/blob/main/docs/testing/procedures/0_controlled_repo_setup.md).
`setup.sh` accepts only IDs listed in `states.list`. Add, remove or change a
state in `states.list`, `states/<ID>.sh` and this table together.

Curbpack suite cases (EV-002, …) *use* these states; they are not the setup
interface. The product ref is a living starting tree. Scripts mutate it.
`--commit` records the mutation on a local `test_<user>_<date>_<id>` branch.
`reset.sh` leaves that branch in place until someone deletes it by hand.
Do not push those branches. Do not merge them into `main`.

| ID | Repository state | Seeded condition | Expected structural result | Used by |
|---|---|---|---|---|
| R1 | Starting Glucose Log product content — no extra mutation | Required files present (`SECURITY.md`, `.well-known/security.txt`, `docs/annex-vii/risk_assessment.md`, `docs/annex-vii/support_period.md`, `docs/annex-vii/user_manual_security.md`, `docs/incident/art14-path.md`, `docs/medtech/software_safety_class.md`, `docs/medtech/soup_list.md`, `docs/medtech/problem_resolution.md`, `package.json`); heading `## Classification Rationale` present; `package.json` dependency maps empty and no banned axios pin | Selected pack instance completes with the predeclared clean result (no missing required file/section) | PK-001, EV-001, PV-001, RP-001, DT-001 |
| R2 | R1 with `SECURITY.md` removed (absent, not empty); other R1 content unchanged | `SECURITY.md` removed | `HOUSE-SECURITY-MD` does not pass | EV-002 (`setup.sh R2 --commit`) |
| R3 | R1 with heading `## Classification Rationale` removed from `docs/medtech/software_safety_class.md`; file remains, other content unchanged | Heading removed | `MD-SW-CLASS` does not pass | EV-003 (`setup.sh R3 --commit`) |
