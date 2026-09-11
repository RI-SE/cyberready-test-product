#!/bin/sh
# Apply one named R-state. R1–R3 mutate this frozen checkout. R4–R5 run
# the matching states/*.sh, which write disposable trees under
# $CURBPACK_ROOT/tmp and do not mutate this checkout.
# Usage: setup.sh --list
#        setup.sh <R-id> [--commit]
#
# Precondition: this script is in $REFERENCE_PRODUCT_ROOT, HEAD is
# exactly $REFERENCE_PRODUCT_COMMIT, and the working tree is clean.
# Those values come from a sourced verification-run.sh. This script
# does not restore, fetch, reset, or clean the checkout. Do not pass a
# commit on the command line. R-state scripts are executed from this
# frozen checkout. --commit records the mutation on a local branch
# named test_<user>_<YYYYMMDD>_<id>. Local only: do not push.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
list=$here/states.list

if [ "${1:-}" = "--list" ]; then
  if [ $# -ne 1 ]; then
    echo "setup.sh: --list cannot be combined with other arguments" >&2
    exit 2
  fi
  cat "$list"
  exit 0
fi

commit=0
state=
for arg in "$@"; do
  case $arg in
    --commit) commit=1 ;;
    --list)
      echo "setup.sh: --list cannot be combined with other arguments" >&2
      exit 2
      ;;
    --*)
      echo "setup.sh: unknown option $arg" >&2
      exit 2
      ;;
    *)
      if [ -z "$state" ]; then
        state=$arg
      else
        echo "setup.sh: unexpected argument $arg" >&2
        echo "usage: setup.sh <R-id> [--commit]" >&2
        echo "baseline is REFERENCE_PRODUCT_COMMIT, not a CLI ref" >&2
        exit 2
      fi
      ;;
  esac
done

if [ -z "$state" ]; then
  echo "usage: setup.sh <R-id> [--commit]" >&2
  echo "       setup.sh --list" >&2
  echo "known states:" >&2
  cat "$list" >&2
  exit 2
fi

if [ -z "${REFERENCE_PRODUCT_ROOT:-}" ]; then
  echo "setup.sh: REFERENCE_PRODUCT_ROOT is empty; source verification-run.sh first" >&2
  exit 2
fi
if [ -z "${REFERENCE_PRODUCT_COMMIT:-}" ]; then
  echo "setup.sh: REFERENCE_PRODUCT_COMMIT is empty; source verification-run.sh first" >&2
  exit 2
fi
if [ "$(git -C "$REFERENCE_PRODUCT_ROOT" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
  echo "setup.sh: REFERENCE_PRODUCT_ROOT is not a Git repository: $REFERENCE_PRODUCT_ROOT" >&2
  exit 2
fi
root=$REFERENCE_PRODUCT_ROOT
fixture_dir=$root/.git/curbpack-fixture

script_root=$(git -C "$here" rev-parse --show-toplevel)
if [ "$script_root" != "$root" ]; then
  echo "setup.sh: this script is in $script_root, but REFERENCE_PRODUCT_ROOT is $root" >&2
  exit 2
fi

if ! expected=$(git -C "$root" rev-parse --verify "${REFERENCE_PRODUCT_COMMIT}^{commit}" 2>/dev/null); then
  echo "setup.sh: REFERENCE_PRODUCT_COMMIT is not a commit in this clone: $REFERENCE_PRODUCT_COMMIT" >&2
  exit 2
fi
head=$(git -C "$root" rev-parse HEAD)
if [ "$head" != "$expected" ]; then
  echo "setup.sh: HEAD is $head, but REFERENCE_PRODUCT_COMMIT is $expected" >&2
  exit 2
fi
status=$(git -C "$root" status --porcelain)
if [ -n "$status" ]; then
  echo "setup.sh: reference-product working tree is not clean: $root" >&2
  printf '%s\n' "$status" >&2
  exit 2
fi

if ! grep -qx "$state" "$list"; then
  echo "setup.sh: unknown state $state (not in states.list)" >&2
  exit 2
fi
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

echo "setup.sh: apply $state"
printf '%-25s %s\n' \
  "Reference-product commit:" "$REFERENCE_PRODUCT_COMMIT" \
  "Reference-product root:" "$REFERENCE_PRODUCT_ROOT"

mkdir -p "$fixture_dir"
printf '%s\n' "$expected" >"$fixture_dir/origin"
printf '%s\n' "$state" >"$fixture_dir/state"

cd "$root"
CURBPACK_R_STATE=$state
export CURBPACK_R_STATE
"$script"

if [ "$commit" -eq 1 ]; then
  if git diff --quiet && git diff --cached --quiet &&
    [ -z "$(git ls-files --others --exclude-standard)" ]; then
    git rev-parse HEAD >"$fixture_dir/head"
  else
    user=$(printf '%s' "${USER:-user}" | tr -c 'A-Za-z0-9._-' '_' | tr -s '_')
    user=$(printf '%s' "$user" | sed 's/^_//;s/_$//')
    [ -n "$user" ] || user=user
    day=$(date +%Y%m%d)
    uniq=$(date +%s)$$
    branch=test_${user}_${day}_${uniq}
    n=0
    while git show-ref --verify --quiet "refs/heads/$branch"; do
      n=$((n + 1))
      branch=test_${user}_${day}_${uniq}$n
    done
    git checkout -b "$branch"
    git add -A
    git -c user.name="curbpack-fixture" -c user.email="curbpack-fixture@invalid" \
      commit -m "curbpack fixture $state on $branch"
    printf '%s\n' "$branch" >"$fixture_dir/branch"
    git rev-parse HEAD >"$fixture_dir/head"
    echo "fixture branch: $branch (local only; do not push; kept until you delete it)"
  fi
fi
