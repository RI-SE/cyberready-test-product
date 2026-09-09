#!/bin/sh
# R1 — clean committed Glucose Log (no mutation).
# Verify the files EV-001 / PK-001 rely on after reset.
set -eu
test -f SECURITY.md
test -f .well-known/security.txt
test -f docs/medtech/software_safety_class.md
test -f docs/annex-vii/risk_assessment.md
