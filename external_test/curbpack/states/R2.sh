#!/bin/sh
# R2 — missing required file (EV-002).
# Remove SECURITY.md so HOUSE-SECURITY-MD cannot pass.
set -eu
rm -f SECURITY.md
