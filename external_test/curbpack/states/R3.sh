#!/bin/sh
# R3 — missing required section (EV-003).
# Drop the Classification Rationale header so MD-SW-CLASS cannot pass.
set -eu
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    "## Classification Rationale") continue ;;
  esac
  printf '%s\n' "$line"
done < docs/medtech/software_safety_class.md > "$tmp"
mv "$tmp" docs/medtech/software_safety_class.md
trap - EXIT
