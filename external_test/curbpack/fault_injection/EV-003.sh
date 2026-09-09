#!/bin/sh
# EV-003 — missing required section
# Drop the Classification Rationale header so MD-SW-CLASS cannot pass.
set -eu
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
# portable: rewrite without the required header line
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    "## Classification Rationale") continue ;;
  esac
  printf '%s\n' "$line"
done < docs/medtech/software_safety_class.md > "$tmp"
mv "$tmp" docs/medtech/software_safety_class.md
trap - EXIT
