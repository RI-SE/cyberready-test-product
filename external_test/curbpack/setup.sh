#!/bin/sh
# Reset this checkout, then apply one named R-state.
# Usage: setup.sh --list
#        setup.sh <R-id> [ref] [--commit]
#
# R-states are working-tree mutations of a living product ref. --commit
# records the mutation on a local branch named
# test_<user>_<YYYYMMDD>_<id>. Local only: do not push. reset.sh does not delete it.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel)
list=$here/states.list
fixture_dir=$root/.git/curbpack-fixture

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
ref=
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
      elif [ -z "$ref" ]; then
        ref=$arg
      else
        echo "setup.sh: unexpected argument $arg" >&2
        echo "usage: setup.sh <R-id> [ref] [--commit]" >&2
        exit 2
      fi
      ;;
  esac
done

if [ -z "$state" ]; then
  echo "usage: setup.sh <R-id> [ref] [--commit]" >&2
  echo "       setup.sh --list" >&2
  echo "known states:" >&2
  cat "$list" >&2
  exit 2
fi
ref=${ref:-main}

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

"$here/reset.sh" "$ref"
mkdir -p "$fixture_dir"
printf '%s\n' "$ref" >"$fixture_dir/origin"
printf '%s\n' "$state" >"$fixture_dir/state"

cd "$root"
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
