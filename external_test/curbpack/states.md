# Repository states (R1…Rn)

This file is the live registry required by Curbpack Test Procedures §3.1.
`setup.sh` accepts only IDs listed in `states.list`. Add, remove or change a
state in `states.list`, `states/<ID>.sh` and this table together.

Curbpack suite cases (EV-002, …) *use* these states; they are not the setup
interface. The product ref is a living starting tree. Scripts mutate it.
`--commit` records the mutation on a local `test_<user>_<date>_<id>` branch.
`reset.sh` leaves that branch in place until someone deletes it by hand.
Do not push those branches. Do not merge them into `main`.

| ID | Repository state | Seeded condition | Expected structural result | Used by |
|---|---|---|---|---|
| R1 | Starting product content | All pack-required files present as on the chosen product ref | Selected pack instance completes with the predeclared clean result (no missing required file/section) | PK-001, EV-001, PV-001, RP-001, DT-001 |
| R2 | Missing required file | `SECURITY.md` removed | `HOUSE-SECURITY-MD` does not pass | EV-002 (`setup.sh R2 --commit`) |
| R3 | Missing required section | `## Classification Rationale` removed from `docs/medtech/software_safety_class.md` | `MD-SW-CLASS` does not pass | EV-003 (`setup.sh R3 --commit`) |
