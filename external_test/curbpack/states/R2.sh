#!/usr/bin/env bash
# R2 — missing required file (EV-002).
# Remove SECURITY.md so HOUSE-SECURITY-MD cannot pass.
set -euo pipefail

export FILE_TO_MANIPULATE="SECURITY.md"

test -f "$FILE_TO_MANIPULATE"
rm "$FILE_TO_MANIPULATE"
