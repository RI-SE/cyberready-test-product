#!/bin/sh
# Reset this Glucose Log checkout to a commit-ish (default: main).
# Discards uncommitted changes. Used as teardown and as the first step of setup.
set -eu
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cd "$root"
ref=${1:-main}
git fetch --quiet 2>/dev/null || true
git checkout --force --quiet "$ref"
git clean -fd --quiet
