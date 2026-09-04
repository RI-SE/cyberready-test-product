# Art 14 reporting path

This file records how glucose-log would report actively exploited or severe incidents under CRA Article 14.
It is a dated in-repo path for human review. It is not a live Single Reporting Platform check, not EU Login evidence, and not a claim that glucose-log is CRA-compliant.

## Reporting clock (CRA Art 14)

For glucose-log, actively exploited or severe incidents are reported by the named owner below to security@test-product.invalid, using the contact in `SECURITY.md` and `.well-known/security.txt`. Reporting under Article 14 applies from 11 September 2026, including products already on the market. This file does not submit anything to an EU platform.

Because glucose-log is a local reference product with no production fleet, a “severe incident” here means: a vulnerability in `src/app.py` that would let a local user read or change another user’s measurements, bypass login, or execute SQL.

## Handling clock (not this file)

Vulnerability handling and the public security contact for glucose-log live in `SECURITY.md` and `.well-known/security.txt`. They sit on a later clock than Article 14 reporting. This path is not Annex I Part II handling evidence.

## Named owner

Product security on-call for glucose-log is the maintainer of this repository. Escalation is the engineering owner named in `SECURITY.md`.

## Rehearsal dated artifact

Rehearsal status: file rehearsal of this reporting path while writing the glucose-log evidence set. Not a live submission.

Drafted: 2026-09-04
Last tabletop: 2026-09-04
Record: this file. Reports go to security@test-product.invalid as stated in SECURITY.md. Not a live SRP submission.
