# Problem Resolution

How defects in glucose-log are taken in, fixed, and checked.
This describes the actual small-product process. It is not a certified quality-management system.

## Process

1. **Intake.** Sensitive reports go to security@test-product.invalid (`SECURITY.md`). Non-sensitive defects are recorded in the Git history of this repository.
2. **Triage.** Decide whether the issue is a security-relevant behaviour (auth, SQL, session, validation, audit) or ordinary product defect.
3. **Fix.** Change `src/app.py` and, when the behaviour is specified, `tests/test_app.py`. Do not add insulin or treatment logic.
4. **Verification.** Run `make test`. For user-visible behaviour, run `make start`, exercise the flow, then `make stop`.
5. **Release of the correction.** A normal Git commit on this product line. No product branches per pack, and no claim that the commit is a regulatory release.
