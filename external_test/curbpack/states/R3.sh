#!/usr/bin/env bash
# R3 — missing required section (EV-003).
# Drop the Classification Rationale header so MD-SW-CLASS cannot pass.
set -euo pipefail

export FILE_TO_MANIPULATE="docs/medtech/software_safety_class.md"
export REPLACE_SRC="## Classification Rationale"
export REPLACE_TARGET=""

test -f "$FILE_TO_MANIPULATE"
grep -Fq "$REPLACE_SRC" "$FILE_TO_MANIPULATE"

tmp="${FILE_TO_MANIPULATE}.tmp"
sed "s|${REPLACE_SRC}|${REPLACE_TARGET}|g" "$FILE_TO_MANIPULATE" > "$tmp"
mv "$tmp" "$FILE_TO_MANIPULATE"
