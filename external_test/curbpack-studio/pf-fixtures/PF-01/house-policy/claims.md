# house-policy — claims on glucose-log

Structural gates only. A pass means the file/shape is present, not that
the text is true, sufficient, or approved.

| Gate | Target | Claim in this product |
|---|---|---|
| HOUSE-SECURITY-MD | `SECURITY.md` | Vulnerability reports go to security@cyberready-test-product.invalid. Product security on-call is the maintainer. |
| HOUSE-SECURITY-TXT | `.well-known/security.txt` | Contact mailto:security@cyberready-test-product.invalid; Expires 2027-12-31. |
| HOUSE-DEP-AXIOS-PIN | `package.json` | No axios pin. `dependencies` and `devDependencies` are empty. The app is Python, not Node. |
| HOUSE-SECRET-PATHS | listed secret-ish paths | No AWS keys, PEM blocks, or api_key assignments in those files. |
| HOUSE-ANTI-PLACEHOLDER | `SECURITY.md`, `security.txt` | Contact and response text are specific to glucose-log; no TODO / lorem / `[insert …]`. |

CTAM maps a separate sentence in `src/app.py`: the product does not calculate
insulin, recommend treatment, or make clinical decisions. That sentence is
not a house-policy gate.
