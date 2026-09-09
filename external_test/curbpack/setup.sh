#!/bin/sh
# Reset this checkout, then apply one fault_injection script.
# Usage: setup.sh <case> [ref]
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel)
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "usage: setup.sh <case> [ref]" >&2
  exit 2
fi
case_id=${1%.sh}
ref=${2:-main}
"$here/reset.sh" "$ref"
script=$here/fault_injection/$case_id.sh
if [ ! -f "$script" ]; then
  echo "setup.sh: missing $script" >&2
  exit 2
fi
cd "$root"
sh "$script"
