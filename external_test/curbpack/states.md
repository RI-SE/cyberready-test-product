# Repository states (R1…Rn)

This file is the live registry required by Curbpack Test Procedures §3.1.
`setup.sh` accepts only IDs listed in `states.list`. Add, remove or change a
state in `states.list`, `states/<ID>.sh` and this table together.

Curbpack suite cases (EV-002, …) *use* these states; they are not the setup
interface.

| ID | Repository state | Seeded condition | Expected structural result | Used by |
|---|---|---|---|---|
| R1 | Clean committed Glucose Log | All pack-required files present as on the frozen product commit | Selected pack instance completes with the predeclared clean result (no missing required file/section) | PK-001, EV-001, PV-001, RP-001, DT-001 |
| R2 | Missing required file | `SECURITY.md` removed | `HOUSE-SECURITY-MD` does not pass | EV-002 |
| R3 | Missing required section | `## Classification Rationale` removed from `docs/medtech/software_safety_class.md` | `MD-SW-CLASS` does not pass | EV-003 |
