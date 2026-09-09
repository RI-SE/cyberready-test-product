#!/bin/sh
# EV-002 — missing required file
# Remove SECURITY.md so HOUSE-SECURITY-MD cannot pass.
set -eu
rm -f SECURITY.md
