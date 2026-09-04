# Support Period

This file states how long the glucose-log reference tree is intended to receive security-relevant updates.
It is a structural draft for human review, not a commercial support contract and not a CRA conformity claim.

glucose-log is a CyberReady reference/test product. Support here means: keep the documented behaviour, tests, and evidence files aligned with the Curbpack revision recorded in `curbpack-ref.txt`.

## End of Support

Security-relevant maintenance of this glucose-log tree is intended through 2027-12-31.

That date matches the `Expires` field in `.well-known/security.txt`. After that date, this repository should be treated as an archival snapshot unless a later commit extends the date in both places.

## Rationale

The window is one calendar year plus the remainder of 2026 from the date this file was written (2026-09-04). It is long enough to exercise house-policy, cra-baseline (via medtech extends), and medtech-iec62304 against one product history, and short enough that the security contact expiry does not silently outlive the product statement.
