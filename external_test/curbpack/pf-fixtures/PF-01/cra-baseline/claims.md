# cra-baseline — claims on glucose-log

Loaded in this product via `medtech-iec62304` `extends`. Structural drafts
for human review; not CRA essential-requirements conformity.

| Gate | Target | Claim in this product |
|---|---|---|
| CRA-ANNEX-VII-RISK | `docs/annex-vii/risk_assessment.md` | glucose-log is a local Python 3 app (`src/app.py`) on 127.0.0.1:8080. Risks R-001–R-007 cover auth, SQL, password storage, demo account, sessions, local files, XSS. |
| CRA-ANNEX-VII-SUPPORT | `docs/annex-vii/support_period.md` | Security-relevant maintenance intended through 2027-12-31, aligned with `security.txt` Expires. |
| CRA-ANNEX-VII-MANUAL | `docs/annex-vii/user_manual_security.md` | Run via `make start` on localhost; demo/demo is classroom-only; dispose by deleting `var/` and the clone. |
| CRA-ART14-PATH | `docs/incident/art14-path.md` | Named owner is the maintainer; reports to security@cyberready-test-product.invalid; reporting clock from 2026-09-11. File rehearsal, not a live SRP submission. |
| CRA-ANTI-PLACEHOLDER | annex + Art 14 paths | Those drafts name glucose-log and have no TODO / lorem / `[insert …]`. |
| CRA-DEP-AXIOS-PIN | `package.json` | Same as house-policy: no axios. |
