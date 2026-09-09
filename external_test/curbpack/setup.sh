#!/bin/sh
# Reset this checkout, then apply one named R-state.
# Usage: setup.sh <R-id> [ref]
#        setup.sh --list
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel)
list=$here/states.list
if [ "${1:-}" = "--list" ]; then
  cat "$list"
  exit 0
fi
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "usage: setup.sh <R-id> [ref]" >&2
  echo "known states:" >&2
  cat "$list" >&2
  exit 2
fi
state=$1
ref=${2:-main}
if ! grep -qx "$state" "$list"; then
  echo "setup.sh: unknown state $state (not in states.list)" >&2
  exit 2
fi
# Duplicate IDs in the registry are a setup defect.
dup=$(sort "$list" | uniq -d)
if [ -n "$dup" ]; then
  echo "setup.sh: duplicate state id in states.list:" >&2
  printf '%s\n' "$dup" >&2
  exit 2
fi
script=$here/states/$state.sh
if [ ! -f "$script" ]; then
  echo "setup.sh: missing $script" >&2
  exit 2
fi
"$here/reset.sh" "$ref"
cd "$root"
"$script"
